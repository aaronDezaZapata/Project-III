using FMOD.Studio;
using FMODUnity;
using UnityEngine;

public class PlayerAudio : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private EventReference jumpEvent;
    [SerializeField] private EventReference doubleJumpEvent;
    [SerializeField] private EventReference fallEvent;
    [SerializeField] private EventReference heavyImpactEvent;
    [SerializeField] private EventReference footstepsEvent;

    [Header("Paint / Ink")]
    [SerializeField] private EventReference paintStartEvent;
    [SerializeField] private EventReference paintLoopEvent;
    [SerializeField] private EventReference paintEndEvent;
    [SerializeField] private EventReference swimLoopEvent;
    [SerializeField] private EventReference blueBoostEvent;
    [SerializeField] private EventReference objectGrabEvent;
    [SerializeField] private EventReference objectSpinEvent;
    [SerializeField] private EventReference blackActivateEvent;
    [SerializeField] private EventReference paintSurfaceImpactEvent;
    [SerializeField] private EventReference blueActivateEvent;
    [SerializeField] private EventReference blueAirControlEvent;
    [SerializeField] private EventReference objectThrowEvent;
    [SerializeField] private EventReference blackMasteryEvent;

    private EventInstance blackMasteryInstance;

    private EventInstance footstepsInstance;
    private EventInstance paintLoopInstance;
    private EventInstance swimLoopInstance;
    private EventInstance objectSpinInstance;

    private const string PARAM_PLAYER_SPEED = "PlayerSpeed";

    private void Start()
    {
        if (!footstepsEvent.IsNull)
            footstepsInstance = RuntimeManager.CreateInstance(footstepsEvent);

        if (!paintLoopEvent.IsNull)
            paintLoopInstance = RuntimeManager.CreateInstance(paintLoopEvent);

        if (!swimLoopEvent.IsNull)
            swimLoopInstance = RuntimeManager.CreateInstance(swimLoopEvent);

        if (!objectSpinEvent.IsNull)
            objectSpinInstance = RuntimeManager.CreateInstance(objectSpinEvent);
    }

    public void PlayJump()
    {
        if (!jumpEvent.IsNull)
            RuntimeManager.PlayOneShot(jumpEvent, transform.position);
    }

    public void PlayDoubleJump()
    {
        if (!doubleJumpEvent.IsNull)
            RuntimeManager.PlayOneShot(doubleJumpEvent, transform.position);
    }

    public void PlayFall()
    {
        if (!fallEvent.IsNull)
            RuntimeManager.PlayOneShot(fallEvent, transform.position);
    }

    public void PlayHeavyImpact()
    {
        if (!heavyImpactEvent.IsNull)
            RuntimeManager.PlayOneShot(heavyImpactEvent, transform.position);
    }

    public void PlayPaintStart()
    {
        if (!paintStartEvent.IsNull)
            RuntimeManager.PlayOneShot(paintStartEvent, transform.position);
    }

    public void StartPaintLoop()
    {
        if (paintLoopInstance.isValid())
            paintLoopInstance.start();
    }

    public void StopPaintLoop()
    {
        if (paintLoopInstance.isValid())
            paintLoopInstance.stop(STOP_MODE.ALLOWFADEOUT);
    }

    public void StartSwimLoop()
    {
        if (swimLoopInstance.isValid())
            swimLoopInstance.start();

        AudioManager.Instance?.SetUnderInk(true);
    }

    public void StopSwimLoop()
    {
        if (swimLoopInstance.isValid())
            swimLoopInstance.stop(STOP_MODE.ALLOWFADEOUT);

        AudioManager.Instance?.SetUnderInk(false);
    }

    public void PlayBlueBoost()
    {
        if (!blueBoostEvent.IsNull)
            RuntimeManager.PlayOneShot(blueBoostEvent, transform.position);
    }

    public void PlayObjectGrab()
    {
        if (!objectGrabEvent.IsNull)
            RuntimeManager.PlayOneShot(objectGrabEvent, transform.position);
    }

    public void StartObjectSpin()
    {
        if (objectSpinInstance.isValid())
            objectSpinInstance.start();
    }

    public void StopObjectSpin()
    {
        if (objectSpinInstance.isValid())
            objectSpinInstance.stop(STOP_MODE.ALLOWFADEOUT);
    }

    public void PlayBlackActivate()
    {
        if (!blackActivateEvent.IsNull)
            RuntimeManager.PlayOneShot(blackActivateEvent, transform.position);
    }

    public void UpdateFootsteps(float speed, bool grounded, bool moving)
    {
        if (!footstepsInstance.isValid()) return;

        footstepsInstance.setParameterByName(PARAM_PLAYER_SPEED, speed);

        PLAYBACK_STATE playbackState;
        footstepsInstance.getPlaybackState(out playbackState);

        bool shouldPlay = grounded && moving;

        if (shouldPlay && playbackState != PLAYBACK_STATE.PLAYING)
            footstepsInstance.start();
        else if (!shouldPlay && playbackState == PLAYBACK_STATE.PLAYING)
            footstepsInstance.stop(STOP_MODE.ALLOWFADEOUT);
    }

    private void OnDestroy()
    {
        ReleaseInstance(footstepsInstance);
        ReleaseInstance(paintLoopInstance);
        ReleaseInstance(swimLoopInstance);
        ReleaseInstance(objectSpinInstance);
    }

    private void ReleaseInstance(EventInstance instance)
    {
        if (instance.isValid())
        {
            instance.stop(STOP_MODE.IMMEDIATE);
            instance.release();
        }
    }

    public void PlayPaintEnd()
    {
        if (!paintEndEvent.IsNull)
            RuntimeManager.PlayOneShot(paintEndEvent, transform.position);
    }

    public void PlayPaintSurfaceImpact()
    {
        if (!paintSurfaceImpactEvent.IsNull)
            RuntimeManager.PlayOneShot(paintSurfaceImpactEvent, transform.position);
    }

    public void PlayBlueActivate()
    {
        if (!blueActivateEvent.IsNull)
            RuntimeManager.PlayOneShot(blueActivateEvent, transform.position);
    }

    public void PlayBlueAirControl()
    {
        if (!blueAirControlEvent.IsNull)
            RuntimeManager.PlayOneShot(blueAirControlEvent, transform.position);
    }

    public void PlayObjectThrow()
    {
        if (!objectThrowEvent.IsNull)
            RuntimeManager.PlayOneShot(objectThrowEvent, transform.position);
    }

    public void StartBlackMastery()
    {
        if (blackMasteryInstance.isValid())
            blackMasteryInstance.start();
    }

    public void StopBlackMastery()
    {
        if (blackMasteryInstance.isValid())
            blackMasteryInstance.stop(STOP_MODE.ALLOWFADEOUT);
    }
}