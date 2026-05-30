using FMOD.Studio;
using FMODUnity;
using STOP_MODE = FMOD.Studio.STOP_MODE;
using UnityEngine;

public class PlayerAudio : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private EventReference jumpEvent;
    [SerializeField] private EventReference doubleJumpEvent;
    [SerializeField] private EventReference fallEvent;
    [SerializeField] private EventReference heavyImpactEvent;
    [SerializeField] private EventReference footstepsEvent;
    [SerializeField] private EventReference leavesEvent;
    [SerializeField] private EventReference rockEvent;
    [SerializeField] private EventReference sandEvent;
    [SerializeField] private EventReference woodEvent;
    [SerializeField] private EventReference landingEvent;

    [Header("Paint / Ink")]
    [SerializeField] private EventReference paintSpreadEvent;
    [SerializeField] public float paintSpreadCooldown = 0.08f;
    private float lastPaintSpreadTime;
    [SerializeField] private EventReference paintStartEvent;
    [SerializeField] private EventReference paintLoopEvent;
    [SerializeField] private EventReference paintEndEvent;
    [SerializeField] private EventReference tpMarkEvent;
    [SerializeField] private EventReference tpTravelEvent;
    [SerializeField] private EventReference tpImpactEvent;
    [SerializeField] private EventReference swimLoopEvent;
    [SerializeField] private EventReference swimEnterEvent;
    [SerializeField] private EventReference swimExitEvent;
    [SerializeField] private EventReference swimBoostEvent;
    [SerializeField] private EventReference blueBoostEvent;
    [SerializeField] private EventReference objectGrabEvent;
    [SerializeField] private EventReference objectSpinEvent;
    [SerializeField] private EventReference objectImpactEvent;
    [SerializeField] private EventReference whipThrowEvent;
    [SerializeField] private EventReference whipAttachEvent;
    [SerializeField] private EventReference whipSwingEvent;
    [SerializeField] private EventReference whipReleaseEvent;
    [SerializeField] private EventReference blackActivateEvent;
    [SerializeField] private EventReference paintSurfaceImpactEvent;
    [SerializeField] private EventReference blueActivateEvent;
    [SerializeField] private EventReference blueAirControlEvent;
    [SerializeField] private EventReference objectThrowEvent;
    [SerializeField] private EventReference blackMasteryEvent;
    [SerializeField] private EventReference inkwellEvent;
    
    [Header("Single Events")]
    [SerializeField] private EventReference coinGetEvent;

    private EventInstance blackMasteryInstance;

    private EventInstance paintLoopInstance;
    private EventInstance swimLoopInstance;
    private EventInstance objectSpinInstance;
    private EventInstance whipSwingInstance;
    
    private EventInstance coinGetInstance;

    private void Start()
    {
        InitInstances();
    }

    private void InitInstances()
    {
        if (!paintLoopEvent.IsNull)
            paintLoopInstance = RuntimeManager.CreateInstance(paintLoopEvent);

        if (!swimLoopEvent.IsNull)
            swimLoopInstance = RuntimeManager.CreateInstance(swimLoopEvent);

        if (!objectSpinEvent.IsNull)
            objectSpinInstance = RuntimeManager.CreateInstance(objectSpinEvent);

        if (!blackMasteryEvent.IsNull)
            blackMasteryInstance = RuntimeManager.CreateInstance(blackMasteryEvent);

        if (!whipSwingEvent.IsNull)
            whipSwingInstance = RuntimeManager.CreateInstance(whipSwingEvent);
        
        if (!coinGetEvent.IsNull)
            coinGetInstance = RuntimeManager.CreateInstance(coinGetEvent);
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
        RuntimeManager.PlayOneShot(heavyImpactEvent, transform.position);
    }

    public void PlayLanding()
    {
        RuntimeManager.PlayOneShot(landingEvent, transform.position);
    }

    public void PlayPaintSpread()
    {
        if (paintSpreadEvent.IsNull) return;
        if (Time.time < lastPaintSpreadTime + paintSpreadCooldown) return;

        lastPaintSpreadTime = Time.time;
        RuntimeManager.PlayOneShot(paintSpreadEvent, transform.position);
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

    public void PlayTpMark()
    {
        if (!tpMarkEvent.IsNull)
            RuntimeManager.PlayOneShot(tpMarkEvent, transform.position);
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

    public void PlaySwimEnter()
    {
        if (!swimEnterEvent.IsNull)
            RuntimeManager.PlayOneShot(swimEnterEvent, transform.position);
    }

    public void PlaySwimExit()
    {
        if (!swimExitEvent.IsNull)
            RuntimeManager.PlayOneShot(swimExitEvent, transform.position);
    }

    public void PlaySwimBoost()
    {
        if (!swimBoostEvent.IsNull)
            RuntimeManager.PlayOneShot(swimBoostEvent, transform.position);
    }

    public void PlayBlueBoost()
    {
        if (!blueBoostEvent.IsNull)
            RuntimeManager.PlayOneShot(blueBoostEvent, transform.position);
    }
    

    public void PlayObjectImpact(Vector3 position)
    {
        if (!objectImpactEvent.IsNull)
            RuntimeManager.PlayOneShot(objectImpactEvent, position);
    }

    public void PlayWhipThrow()
    {
        if (!whipThrowEvent.IsNull)
            RuntimeManager.PlayOneShot(whipThrowEvent, transform.position);
    }

    public void PlayWhipAttach()
    {
        if (!whipAttachEvent.IsNull)
            RuntimeManager.PlayOneShot(whipAttachEvent, transform.position);
    }

    public void StartWhipSwing()
    {
        if (whipSwingInstance.isValid())
            whipSwingInstance.start();
    }

    public void StopWhipSwing()
    {
        if (whipSwingInstance.isValid())
            whipSwingInstance.stop(STOP_MODE.ALLOWFADEOUT);
    }

    public void PlayWhipRelease()
    {
        if (!whipReleaseEvent.IsNull)
            RuntimeManager.PlayOneShot(whipReleaseEvent, transform.position);
    }

    public void PlayFootstep(FootstepSurfaceType surfaceType, FootstepSpeedType speedType)
    {
        EventReference ev = surfaceType switch
        {
            FootstepSurfaceType.Leaves => leavesEvent,
            FootstepSurfaceType.Rock   => rockEvent,
            FootstepSurfaceType.Sand   => sandEvent,
            FootstepSurfaceType.Wood   => woodEvent,
            _                          => default
        };

        if (ev.IsNull) return;

        RuntimeManager.PlayOneShot(ev, transform.position);
    }

    private void OnDestroy()
    {
        ReleaseInstance(paintLoopInstance);
        ReleaseInstance(swimLoopInstance);
        ReleaseInstance(objectSpinInstance);
        ReleaseInstance(blackMasteryInstance);
        ReleaseInstance(whipSwingInstance);
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
    
    public void PlayInkwell()
    {
        if (!inkwellEvent.IsNull)
            RuntimeManager.PlayOneShot(inkwellEvent, transform.position);
    }
    
    public void PlayCoinGet()
    {
        if (coinGetInstance.isValid())
            coinGetInstance.start();
    }
}