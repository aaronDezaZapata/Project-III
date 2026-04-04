using FMOD.Studio;
using FMODUnity;
using STOP_MODE = FMOD.Studio.STOP_MODE;
using UnityEngine;

public class AmbientDetailEmitter : MonoBehaviour
{
    [SerializeField] private EventReference ambienceEvent;
    [SerializeField] private bool playOnEnable = true;

    private EventInstance instance;

    private void OnEnable()
    {
        if (!playOnEnable || ambienceEvent.IsNull) return;

        instance = RuntimeManager.CreateInstance(ambienceEvent);
        RuntimeManager.AttachInstanceToGameObject(instance, transform);
        instance.start();
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
        if (instance.isValid())
        {
            instance.stop(STOP_MODE.ALLOWFADEOUT);
            instance.release();
        }
    }
}