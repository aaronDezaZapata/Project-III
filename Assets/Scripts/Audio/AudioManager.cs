using FMOD.Studio;
using FMODUnity;
using STOP_MODE = FMOD.Studio.STOP_MODE;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [Header("Startup")]
    [SerializeField] private ZoneType startingZone = ZoneType.Beach;

    [Header("Music")]
    [SerializeField] private EventReference beachMusic;
    [SerializeField] private EventReference forestMusic;
    [SerializeField] private EventReference volcanoMusic;
    [SerializeField] private EventReference deskMusic;

    [Header("Ambience")]
    [SerializeField] private EventReference beachAmbience;
    [SerializeField] private EventReference forestAmbience;
    [SerializeField] private EventReference volcanoAmbience;
    [SerializeField] private EventReference deskAmbience;

    [Header("UI")]
    [SerializeField] private EventReference uiCheckpoint;
    [SerializeField] private EventReference uiError;
    [SerializeField] private EventReference uiInkChange;
    [SerializeField] private EventReference uiMenuBack;
    [SerializeField] private EventReference uiMenuConfirm;
    [SerializeField] private EventReference uiPause;

    [Header("Pause Snapshot")]
    [SerializeField] private EventReference pauseSnapshot;

    private EventInstance pauseSnapshotInstance;

    private EventInstance currentMusicInstance;
    private EventInstance currentAmbienceInstance;

    private ZoneType currentZone;
    private InkStateType currentInkState = InkStateType.Base;
    private bool underInk;

    private const string PARAM_ZONE = "Zone";
    private const string PARAM_INKSTATE = "InkState";
    private const string PARAM_UNDERINK = "UnderInk";

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }

        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    private void Start()
    {
        SetZone(startingZone);
    }

    public void SetZone(ZoneType zone)
    {
        currentZone = zone;

        StopMusic();
        StopAmbience();

        EventReference musicEvent = GetMusicEvent(zone);
        EventReference ambienceEvent = GetAmbienceEvent(zone);

        if (!musicEvent.IsNull)
        {
            currentMusicInstance = RuntimeManager.CreateInstance(musicEvent);
            currentMusicInstance.start();
        }

        if (!ambienceEvent.IsNull)
        {
            currentAmbienceInstance = RuntimeManager.CreateInstance(ambienceEvent);
            currentAmbienceInstance.start();
        }

        UpdateGlobalParameters();
    }

    public void SetInkState(InkStateType inkState)
    {
        currentInkState = inkState;
        UpdateGlobalParameters();

        RuntimeManager.PlayOneShot(uiInkChange);
    }

    public void SetUnderInk(bool value)
    {
        underInk = value;
        UpdateGlobalParameters();
    }

    public void SetPaused(bool paused)
    {
        if (pauseSnapshot.IsNull) return;

        if (paused)
        {
            pauseSnapshotInstance = RuntimeManager.CreateInstance(pauseSnapshot);
            pauseSnapshotInstance.start();
        }
        else if (pauseSnapshotInstance.isValid())
        {
            pauseSnapshotInstance.stop(STOP_MODE.ALLOWFADEOUT);
            pauseSnapshotInstance.release();
        }

        PlayUIPause();
    }

    public void PlayUICheckpoint() => RuntimeManager.PlayOneShot(uiCheckpoint);
    public void PlayUIError() => RuntimeManager.PlayOneShot(uiError);
    public void PlayUIMenuBack() => RuntimeManager.PlayOneShot(uiMenuBack);
    public void PlayUIMenuConfirm() => RuntimeManager.PlayOneShot(uiMenuConfirm);
    public void PlayUIPause() => RuntimeManager.PlayOneShot(uiPause);

    private void UpdateGlobalParameters()
    {
        if (currentMusicInstance.isValid())
        {
            currentMusicInstance.setParameterByName(PARAM_ZONE, (float)currentZone);
            currentMusicInstance.setParameterByName(PARAM_INKSTATE, (float)currentInkState);
            currentMusicInstance.setParameterByName(PARAM_UNDERINK, underInk ? 1f : 0f);
        }

        if (currentAmbienceInstance.isValid())
        {
            currentAmbienceInstance.setParameterByName(PARAM_ZONE, (float)currentZone);
            currentAmbienceInstance.setParameterByName(PARAM_INKSTATE, (float)currentInkState);
            currentAmbienceInstance.setParameterByName(PARAM_UNDERINK, underInk ? 1f : 0f);
        }
    }

    private EventReference GetMusicEvent(ZoneType zone)
    {
        switch (zone)
        {
            case ZoneType.Beach: return beachMusic;
            case ZoneType.Forest: return forestMusic;
            case ZoneType.Volcano: return volcanoMusic;
            case ZoneType.Desk: return deskMusic;
            default: return default;
        }
    }

    private EventReference GetAmbienceEvent(ZoneType zone)
    {
        switch (zone)
        {
            case ZoneType.Beach: return beachAmbience;
            case ZoneType.Forest: return forestAmbience;
            case ZoneType.Volcano: return volcanoAmbience;
            case ZoneType.Desk: return deskAmbience;
            default: return default;
        }
    }

    private void StopMusic()
    {
        if (currentMusicInstance.isValid())
        {
            currentMusicInstance.stop(STOP_MODE.ALLOWFADEOUT);
            currentMusicInstance.release();
        }
    }

    private void StopAmbience()
    {
        if (currentAmbienceInstance.isValid())
        {
            currentAmbienceInstance.stop(STOP_MODE.ALLOWFADEOUT);
            currentAmbienceInstance.release();
        }
    }

    private void OnDestroy()
    {
        StopMusic();
        StopAmbience();
    }
}