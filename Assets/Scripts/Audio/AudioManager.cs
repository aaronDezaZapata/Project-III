using System.Collections;
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
    
    [Header("SFX")]
    [SerializeField] private EventReference coinGetEvent;

    [Header("Music Transitions")]
    [SerializeField] private float musicFadeDuration = 1.5f;
    [SerializeField] private float ambienceFadeDuration = 1.0f;

    private EventInstance pauseSnapshotInstance;

    private EventInstance currentMusicInstance;
    private EventInstance outgoingMusicInstance;
    private EventInstance currentAmbienceInstance;
    private EventInstance outgoingAmbienceInstance;
    
    private EventInstance coinGetInstance;

    private Coroutine musicFadeCoroutine;
    private Coroutine ambienceFadeCoroutine;

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
        
        if (!coinGetEvent.IsNull)
            coinGetInstance = RuntimeManager.CreateInstance(coinGetEvent);
    }

    public void SetZone(ZoneType zone)
    {
        if (zone == currentZone && currentMusicInstance.isValid()) return;

        currentZone = zone;

        if (musicFadeCoroutine != null) StopCoroutine(musicFadeCoroutine);
        if (ambienceFadeCoroutine != null) StopCoroutine(ambienceFadeCoroutine);

        musicFadeCoroutine = StartCoroutine(CrossfadeMusic(GetMusicEvent(zone)));
        ambienceFadeCoroutine = StartCoroutine(CrossfadeAmbience(GetAmbienceEvent(zone)));
    }

    public void FadeOutMusic()
    {
        if (musicFadeCoroutine != null) StopCoroutine(musicFadeCoroutine);
        musicFadeCoroutine = StartCoroutine(CrossfadeMusic(default));
    }

    public void FadeOutAmbience()
    {
        if (ambienceFadeCoroutine != null) StopCoroutine(ambienceFadeCoroutine);
        ambienceFadeCoroutine = StartCoroutine(CrossfadeAmbience(default));
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

    private IEnumerator CrossfadeMusic(EventReference newEvent)
    {
        if (outgoingMusicInstance.isValid())
        {
            outgoingMusicInstance.stop(STOP_MODE.IMMEDIATE);
            outgoingMusicInstance.release();
        }

        outgoingMusicInstance = currentMusicInstance;

        if (!newEvent.IsNull)
        {
            currentMusicInstance = RuntimeManager.CreateInstance(newEvent);
            currentMusicInstance.setVolume(0f);
            currentMusicInstance.start();
            ApplyParametersToMusic();
        }
        else
        {
            currentMusicInstance = default;
        }

        float startVolume = 1f;
        if (outgoingMusicInstance.isValid())
            outgoingMusicInstance.getVolume(out startVolume, out _);

        float elapsed = 0f;
        while (elapsed < musicFadeDuration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / musicFadeDuration;

            if (outgoingMusicInstance.isValid())
                outgoingMusicInstance.setVolume(Mathf.Lerp(startVolume, 0f, t));
            if (currentMusicInstance.isValid())
                currentMusicInstance.setVolume(Mathf.Lerp(0f, 1f, t));

            yield return null;
        }

        if (outgoingMusicInstance.isValid())
        {
            outgoingMusicInstance.stop(STOP_MODE.IMMEDIATE);
            outgoingMusicInstance.release();
            outgoingMusicInstance = default;
        }

        if (currentMusicInstance.isValid())
            currentMusicInstance.setVolume(1f);

        musicFadeCoroutine = null;
    }

    private IEnumerator CrossfadeAmbience(EventReference newEvent)
    {
        if (outgoingAmbienceInstance.isValid())
        {
            outgoingAmbienceInstance.stop(STOP_MODE.IMMEDIATE);
            outgoingAmbienceInstance.release();
        }

        outgoingAmbienceInstance = currentAmbienceInstance;

        if (!newEvent.IsNull)
        {
            currentAmbienceInstance = RuntimeManager.CreateInstance(newEvent);
            currentAmbienceInstance.setVolume(0f);
            currentAmbienceInstance.start();
            ApplyParametersToAmbience();
        }
        else
        {
            currentAmbienceInstance = default;
        }

        float startVolume = 1f;
        if (outgoingAmbienceInstance.isValid())
            outgoingAmbienceInstance.getVolume(out startVolume, out _);

        float elapsed = 0f;
        while (elapsed < ambienceFadeDuration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / ambienceFadeDuration;

            if (outgoingAmbienceInstance.isValid())
                outgoingAmbienceInstance.setVolume(Mathf.Lerp(startVolume, 0f, t));
            if (currentAmbienceInstance.isValid())
                currentAmbienceInstance.setVolume(Mathf.Lerp(0f, 1f, t));

            yield return null;
        }

        if (outgoingAmbienceInstance.isValid())
        {
            outgoingAmbienceInstance.stop(STOP_MODE.IMMEDIATE);
            outgoingAmbienceInstance.release();
            outgoingAmbienceInstance = default;
        }

        if (currentAmbienceInstance.isValid())
            currentAmbienceInstance.setVolume(1f);

        ambienceFadeCoroutine = null;
    }

    private void UpdateGlobalParameters()
    {
        ApplyParametersToMusic();
        ApplyParametersToAmbience();
    }

    private void ApplyParametersToMusic()
    {
        if (!currentMusicInstance.isValid()) return;
        currentMusicInstance.setParameterByName(PARAM_ZONE, (float)currentZone);
        currentMusicInstance.setParameterByName(PARAM_INKSTATE, (float)currentInkState);
        currentMusicInstance.setParameterByName(PARAM_UNDERINK, underInk ? 1f : 0f);
    }

    private void ApplyParametersToAmbience()
    {
        if (!currentAmbienceInstance.isValid()) return;
        currentAmbienceInstance.setParameterByName(PARAM_ZONE, (float)currentZone);
        currentAmbienceInstance.setParameterByName(PARAM_INKSTATE, (float)currentInkState);
        currentAmbienceInstance.setParameterByName(PARAM_UNDERINK, underInk ? 1f : 0f);
    }

    private EventReference GetMusicEvent(ZoneType zone) => zone switch
    {
        ZoneType.Beach   => beachMusic,
        ZoneType.Forest  => forestMusic,
        ZoneType.Volcano => volcanoMusic,
        ZoneType.Desk    => deskMusic,
        _                => default
    };

    private EventReference GetAmbienceEvent(ZoneType zone) => zone switch
    {
        ZoneType.Beach   => beachAmbience,
        ZoneType.Forest  => forestAmbience,
        ZoneType.Volcano => volcanoAmbience,
        ZoneType.Desk    => deskAmbience,
        _                => default
    };

    private void OnDestroy()
    {
        ForceStop(ref currentMusicInstance);
        ForceStop(ref outgoingMusicInstance);
        ForceStop(ref currentAmbienceInstance);
        ForceStop(ref outgoingAmbienceInstance);
    }

    private static void ForceStop(ref EventInstance instance)
    {
        if (!instance.isValid()) return;
        instance.stop(STOP_MODE.IMMEDIATE);
        instance.release();
        instance = default;
    }
    
    public void PlayCoinGet()
    {
        if (!coinGetEvent.IsNull)
            RuntimeManager.PlayOneShot(coinGetEvent, GameManager.Instance.GetPlayer().position);
    }
}
