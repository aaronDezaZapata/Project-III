using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Video;

public class VideoIntro : MonoBehaviour
{
    [SerializeField] private VideoPlayer _videoPlayer;
    [SerializeField] private string _nextScene;

    private void Start()
    {
        _videoPlayer.isLooping = false;
        _videoPlayer.loopPointReached += OnVideoEnd;
        _videoPlayer.Play();
    }

    private void OnVideoEnd(VideoPlayer vp)
    {
        SceneManager.LoadScene(_nextScene);
    }

    private void OnDestroy()
    {
        _videoPlayer.loopPointReached -= OnVideoEnd;
    }
}
