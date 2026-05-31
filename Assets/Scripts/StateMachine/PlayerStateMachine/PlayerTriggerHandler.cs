using UnityEngine;

public class PlayerTriggerHandler : MonoBehaviour
{
    private PlayerStateMachine _player;
    private string _currentPuddleTag = "";

    private void Awake()
    {
        _player = GetComponent<PlayerStateMachine>();
    }

    private void OnTriggerEnter(Collider other)
    {
        switch (other.tag)
        {
            case "CharcoAzul":
            case "CharcoNegro":
            case "CharcoRojo":
            case "CharcoVerde":
                _currentPuddleTag = other.tag;
                break;

            case "CheckPoint":
                GameManager.Instance.GetNewCheckPoint(other.transform);
                AudioManager.Instance?.PlayUICheckpoint();
                break;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        
        if (other.tag == _currentPuddleTag)
            _currentPuddleTag = "";
    }

    public void HandlePuddleInteraction()
    {
        switch (_currentPuddleTag)
        {
            case "CharcoAzul":
                _player.PlayerAudio?.PlayInkwell();
                _player.StartFill(Color.blue);
                break;

            case "CharcoRojo":
                _player.PlayerAudio?.PlayInkwell();
                _player.StartFill(Color.red);
                break;

            case "CharcoVerde":
                _player.PlayerAudio?.PlayInkwell();
                _player.StartFill(Color.green);
                break;

            case "CharcoNegro":
                _player.PlayerAudio?.PlayInkwell();
                _player.SwitchState(typeof(PlayerWhiteState));
                break;
        }
    }

    public void CheckForInk()
    {
        Vector3 detectionOrigin = _player.transform.TransformPoint(_player.Controller.center);

        Collider[] hitColliders = Physics.OverlapSphere(detectionOrigin, 0.7f, _player.inkLayer);

        if (hitColliders.Length > 0)
        {
            _player._isOnInk = true;

            if (Physics.Raycast(detectionOrigin, -_player.transform.up, out RaycastHit hit, 1.5f, _player.inkLayer))
                _player.currentInkNormal = hit.normal;
            else
                _player.currentInkNormal = hitColliders[0].transform.forward * -1f;
        }
        else
        {
            _player._isOnInk = false;
            _player.currentInkNormal = Vector3.up;
        }
    }

    public void PaintSurface(Vector3 point, Vector3 normal)
    {
        if (_player.inkDecalPrefab == null) return;

        Quaternion alignmentRotation = Quaternion.FromToRotation(Vector3.up, normal);
        float randomZ = Random.Range(0f, 360f);
        Quaternion finalRotation = alignmentRotation * Quaternion.Euler(90f, 0f, randomZ);

        GameObject splat = Instantiate(_player.inkDecalPrefab, point, finalRotation);
        splat.transform.position += normal * _player.ReticleSurfaceOffset;

        _player.PlayerAudio?.PlayPaintSpread();
    }
}
