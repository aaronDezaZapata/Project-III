using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DecalManager : MonoBehaviour
{
    [Header("Materials")]
    [SerializeField] private Material _blackDecalMat;
    [SerializeField] private Material _blueDecalMat;
    [SerializeField] private Material _greenDecalMat;
    [SerializeField] private Material _redDecalMat;

    private void Awake()
    {
        PlayerStates state = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().playerState;
        DecalProjector projector = GetComponent<DecalProjector>();

        switch (state)
        {
            case PlayerStates.RED:   projector.material = _redDecalMat;   break;
            case PlayerStates.BLUE:  projector.material = _blueDecalMat;  break;
            case PlayerStates.GREEN: projector.material = _greenDecalMat; break;
        }
    }
}
