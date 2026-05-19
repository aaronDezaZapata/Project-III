using FMOD.Studio;
using FMODUnity;
using STOP_MODE = FMOD.Studio.STOP_MODE;
using UnityEngine;

public class AmbientDetailEmitter : MonoBehaviour
{
    [SerializeField] private EventReference _ambienceEvent;
    [SerializeField] private bool _playOnEnable = true;

    private EventInstance _instance;

    private void OnEnable()
    {
        if (!_playOnEnable || _ambienceEvent.IsNull) return;

        _instance = RuntimeManager.CreateInstance(_ambienceEvent);
        RuntimeManager.AttachInstanceToGameObject(_instance, transform);
        _instance.start();
    }

    private void OnDisable()
    {
        StopInstance();
    }

    private void OnDestroy()
    {
        StopInstance();
    }

    private void StopInstance()
    {
        if (_instance.isValid())
        {
            _instance.stop(STOP_MODE.ALLOWFADEOUT);
            _instance.release();
        }
    }
}
