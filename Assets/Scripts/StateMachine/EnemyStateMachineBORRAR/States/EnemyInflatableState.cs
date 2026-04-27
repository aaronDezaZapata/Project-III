using UnityEngine;

public class EnemyInflatableState : EnemyBaseState
{
   
    private float _currentProgress = 0f;
    private float _currentFatness = 0f;

    
    private int _deathProgressID;
    private int _inflationAmountID;
    private bool _isDead = false;

    

    private Material _enemyMat;

    [Tooltip("Velocidad a la que se llena al atacar")]
    public float inflationSpeed = 0.05f;

    [Tooltip("Velocidad a la que se vacía si dejas de atacar")]
    public float deflationSpeed = 1.0f;

    [Tooltip("Valor máximo de gordura (InflationAmount) al morir")]
    public float maxFatness = .009f;

    public EnemyInflatableState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        if (stateMachine.agent != null && stateMachine.agent.isOnNavMesh) stateMachine.agent.isStopped = true;
        
        if (stateMachine.Mat == null)
        {
            
            SkinnedMeshRenderer r = stateMachine.GetComponentInChildren<SkinnedMeshRenderer>();

            if (r != null)
            {
                
                stateMachine.Mat = r;
            }
            else
            {
                Debug.LogError("No se encontró ningún Renderer en el enemigo El shader no funcionara.");
            }
        }
    

        _deathProgressID = Shader.PropertyToID("_DeathProgress");
        _inflationAmountID = Shader.PropertyToID("_InflationAmount");

        
        UpdateShaderValues();
    }

    public override void Tick(float deltaTime)
    {
        
        if (stateMachine._sprayResetTimer > 0)
        {
            stateMachine._sprayResetTimer -= Time.deltaTime;
            stateMachine.isGettingAttacked = true;
        }
        else
        {
            stateMachine.isGettingAttacked = false;
        }

        if (stateMachine.isGettingAttacked)
        {
            Inflate();
        }
        /*
        else
        {
            Deflate();
        }
        */

        // If we want deflate _currentProgress <= 0.0f &&
        if (!stateMachine.isGettingAttacked)
        {
            //_currentProgress = 0f;
            UpdateShaderValues();

            
            stateMachine.SwitchState(typeof(EnemyChaseState));
        }
    }

    public override void Exit()
    {
        if (stateMachine.agent != null) stateMachine.agent.isStopped = false;
    }

    void Inflate()
    {
        
        _currentProgress += inflationSpeed * Time.deltaTime;

        
        _currentFatness = Mathf.Lerp(0, maxFatness, _currentProgress);

        UpdateShaderValues();

        
        if (_currentProgress >= maxFatness)
        {
            PopEnemy();
        }
    }

    void Deflate()
    {
        
        if (_currentProgress <= 0f) return;

        // Resta valor desinflamos
        _currentProgress -= deflationSpeed * Time.deltaTime;

        
        _currentFatness = Mathf.Lerp(0, maxFatness, _currentProgress);

        
        if (_currentProgress < 0f) _currentProgress = 0f;

        UpdateShaderValues();
    }

    void UpdateShaderValues()
    {
        if (stateMachine.Mat != null)
        {
            stateMachine.Mat.sharedMaterial.SetFloat(_deathProgressID, _currentProgress);
            stateMachine.Mat.sharedMaterial.SetFloat(_inflationAmountID, _currentFatness);
        }
    }

    void PopEnemy()
    {
        _isDead = true;
        Debug.Log("¡PUM! El enemigo explotó.");

        GameObject.Destroy(stateMachine.transform.parent.gameObject);
    }

}
