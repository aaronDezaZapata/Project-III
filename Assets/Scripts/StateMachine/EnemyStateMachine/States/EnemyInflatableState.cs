using UnityEngine;

public class EnemyInflatableState : EnemyBaseState
{
    // Variables locales del estado
    private float _currentProgress = 0f;
    private float _currentFatness = 0f;

    // IDs de Shader para rendimiento
    private int _deathProgressID;
    private int _inflationAmountID;
    private bool _isDead = false;

    // Referencia rápida al Material

    private Material _enemyMat;

    [Tooltip("Velocidad a la que se llena al atacar")]
    public float inflationSpeed = 0.5f;

    [Tooltip("Velocidad a la que se vacía si dejas de atacar")]
    public float deflationSpeed = 1.0f;

    [Tooltip("Valor máximo de gordura (InflationAmount) al morir")]
    public float maxFatness = 1.0f; // Puedes poner 0.5 o 2.0 según lo gordo que lo quieras

    public EnemyInflatableState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        if (stateMachine.agent != null) stateMachine.agent.isStopped = true;
        // 1. Buscamos el Renderer (puede estar en el objeto o en un hijo si es un modelo 3D)
        if (_enemyMat == null)
        {
            // Buscamos cualquier Renderer (MeshRenderer o SkinnedMeshRenderer)
            Renderer r = stateMachine.GetComponentInChildren<Renderer>();

            if (r != null)
            {
                // .material crea una COPIA INSTANCIADA para este enemigo específico
                _enemyMat = r.material;
            }
            else
            {
                Debug.LogError("¡No se encontró ningún Renderer en el enemigo! El shader no funcionará.");
            }
        }


            // 2. Guardamos los IDs por rendimiento
            _deathProgressID = Shader.PropertyToID("_DeathProgress");
        _inflationAmountID = Shader.PropertyToID("_InflationAmount");

        // 3. Reseteamos valores al inicio
        UpdateShaderValues();
    }

    public override void Tick(float deltaTime)
    {
        // 1. LÓGICA DEL TEMPORIZADOR DE ATAQUE
        // Esto debe estar en Update para que cuente el tiempo
        if (stateMachine._sprayResetTimer > 0)
        {
            stateMachine._sprayResetTimer -= Time.deltaTime;
            stateMachine.isGettingAttacked = true;
        }
        else
        {
            stateMachine.isGettingAttacked = false;
        }


        // --- DECISIÓN: ¿INFLAR O DESINFLAR? ---
        if (stateMachine.isGettingAttacked)
        {
            Inflate();
        }
        else
        {
            Deflate();
        }

        // --- LÓGICA DE SALIDA (Volver a la normalidad) ---
        // Si el progreso llega a 0 Y ya no me atacan...
        if (_currentProgress <= 0.0f && !stateMachine.isGettingAttacked)
        {
            _currentProgress = 0f;
            UpdateShaderValues(); // Asegurar que visualmente es 0

            // Volver a perseguir al jugador (o Idle)
            stateMachine.SwitchState(typeof(EnemyChaseState));
        }
    }

    public override void Exit()
    {
        if (stateMachine.agent != null) stateMachine.agent.isStopped = false;
    }

    void Inflate()
    {
        // Aumentamos el progreso (de 0 a 1)
        _currentProgress += inflationSpeed * Time.deltaTime;

        // Aumentamos la gordura (de 0 a maxFatness)
        // Usamos Lerp para que la gordura vaya acompasada con el progreso
        _currentFatness = Mathf.Lerp(0, maxFatness, _currentProgress);

        UpdateShaderValues();

        // CONDICIÓN DE MUERTE: Si llegamos al 100%
        if (_currentProgress >= 1.0f)
        {
            PopEnemy();
        }
    }

    void Deflate()
    {
        // Si ya está en 0, no hacemos nada
        if (_currentProgress <= 0f) return;

        // Restamos valor (desinflamos)
        _currentProgress -= deflationSpeed * Time.deltaTime;

        // Mantenemos la gordura sincronizada hacia abajo
        _currentFatness = Mathf.Lerp(0, maxFatness, _currentProgress);

        // Aseguramos que no baje de 0
        if (_currentProgress < 0f) _currentProgress = 0f;

        UpdateShaderValues();
    }

    void UpdateShaderValues()
    {
        if (_enemyMat!= null)
        {
            _enemyMat.SetFloat(_deathProgressID, _currentProgress);
            _enemyMat.SetFloat(_inflationAmountID, _currentFatness);
        }
    }

    void PopEnemy()
    {
        _isDead = true;
        Debug.Log("¡PUM! El enemigo explotó.");

        // Opcional: Instanciar partículas de explosión aquí
        // Instantiate(explosionPrefab, transform.position, Quaternion.identity);

        //Destroy // Adiós enemigo
        GameObject.Destroy(stateMachine.gameObject);
    }

}
