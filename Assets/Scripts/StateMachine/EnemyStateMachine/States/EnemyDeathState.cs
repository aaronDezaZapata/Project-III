using UnityEngine;

public class EnemyDeathState : EnemyBaseState
{
    private float _currentProgress = 0f;
    private float _currentFatness = 0f;
    private float _targetSpeed = 1f; // Esta es la velocidad que recibiremos desde fuera

    // IDs de Shader
    private int _deathProgressID;
    private int _inflationAmountID;
    private Material _enemyMat;

    // Configuraci�n fija
    private float maxFatness = 1.0f;

    public void ConfigureDeath(float speed, float maxFatnessValue = 1.0f)
    {
        _targetSpeed = speed;
        maxFatness = maxFatnessValue;
    }

    public EnemyDeathState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        if (stateMachine.agent != null && stateMachine.agent.isActiveAndEnabled)
        {
            stateMachine.agent.isStopped = true;
            stateMachine.agent.velocity = Vector3.zero; // Frenado total
        }

        // 2. Obtener Material (Optinizado)
        if (_enemyMat == null)
        {
            Renderer r = stateMachine.GetComponentInChildren<Renderer>();
            if (r != null) _enemyMat = r.material;
            else Debug.LogError("EnemyDeathState: No se encontr� Renderer.");
        }

        // 3. Cachear IDs
        _deathProgressID = Shader.PropertyToID("_DeathProgress");
        _inflationAmountID = Shader.PropertyToID("_InflationAmount");

        // 4. Asegurarnos que empezamos desde 0 (o desde donde se qued� si ya estaba medio inflado)
        // Si quieres que siempre empiece de 0, descomenta la siguiente l�nea:
        // _currentProgress = 0f; 

        // Si prefieres que contin�e desde la inflamaci�n actual (m�s fluido):
        if (_enemyMat != null)
        {
            _currentProgress = _enemyMat.GetFloat(_deathProgressID);
        }
    }

    public override void Tick(float deltaTime)
    {
        // Solo sumamos (Nunca restamos porque es muerte inevitable)
        _currentProgress += _targetSpeed * deltaTime;

        // Calculamos gordura
        _currentFatness = Mathf.Lerp(0, maxFatness, _currentProgress);

        UpdateShaderValues();

        // Check de Explosi�n
        if (_currentProgress >= 1.0f)
        {
            Explode();
        }
    }

    public override void Exit()
    {
        
    }

    void UpdateShaderValues()
    {
        if (_enemyMat != null)
        {
            _enemyMat.SetFloat(_deathProgressID, _currentProgress);
            _enemyMat.SetFloat(_inflationAmountID, _currentFatness);
        }
    }

    void Explode()
    {
        // Instancia aqu� tus part�culas de explosi�n si tienes
        // Object.Instantiate(explosionPrefab, stateMachine.transform.position, Quaternion.identity);

        // Destruimos el objeto ra�z del enemigo
        Object.Destroy(stateMachine.transform.parent.gameObject);
    }
}
