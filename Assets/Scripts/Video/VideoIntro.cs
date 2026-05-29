using System;
using FMOD.Studio;
using FMODUnity;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Video;

public enum VideoType
{
    Ending,
    Credits
}

public class VideoIntro : MonoBehaviour
{
    [SerializeField] private VideoPlayer _videoPlayer;
    [SerializeField] private int _nextScene;
    
    [SerializeField] private VideoType _videoType;
    [SerializeField] private EventReference _creditsAudioClip;
    
    private EventInstance _audioInstance;

    private void Awake()
    {
        _videoPlayer.audioOutputMode = VideoAudioOutputMode.None;
        _videoPlayer.playOnAwake = false;
        
        _videoPlayer.prepareCompleted += OnVideoPrepared;
        _videoPlayer.loopPointReached += OnVideoEnd;

        PlayAudio();
    }

    private void Start()
    {
        PrepareVideo();
    }
    
    private void OnDestroy()
    {
        _videoPlayer.prepareCompleted -= OnVideoPrepared;
        _videoPlayer.loopPointReached -= OnVideoEnd;
        
        _audioInstance.stop(FMOD.Studio.STOP_MODE.IMMEDIATE);
        _audioInstance.release();
    }

    private void PrepareVideo()
    {
        _videoPlayer.Prepare();
    }

    private void Play()
    {
        _videoPlayer.Play();
        _audioInstance.start();
    }

    private void PlayAudio()
    {
        if (_videoType == VideoType.Ending) return;
        
        _audioInstance = RuntimeManager.CreateInstance(_creditsAudioClip);
        _audioInstance.setVolume(1f);
    }

    private void OnVideoPrepared(VideoPlayer vp)
    {
        Play();
    }
    
    private void OnVideoEnd(VideoPlayer vp)
    {
        SceneManager.LoadScene(_nextScene);
    }
}
