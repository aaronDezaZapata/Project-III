using UnityEngine;

public class SoundFXManager : MonoBehaviour
{
    public static SoundFXManager Instance { get; private set; }

    [SerializeField] private AudioSource _soundFXObject;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
    }

    public void PlaySoundFXClip(AudioClip clip, Transform spawnTransform, float volume)
    {
        AudioSource source = Instantiate(_soundFXObject, spawnTransform.position, Quaternion.identity);
        source.clip   = clip;
        source.volume = volume;
        source.Play();

        Destroy(source.gameObject, source.clip.length);
    }

    public void PlaySoundFXClipWithRandomPitch(AudioClip clip, Transform spawnTransform, float volume, float minPitch, float maxPitch)
    {
        AudioSource source = Instantiate(_soundFXObject, spawnTransform.position, Quaternion.identity);
        source.clip   = clip;
        source.volume = volume;
        source.pitch  = Random.Range(minPitch, maxPitch);
        source.Play();

        Destroy(source.gameObject, source.clip.length);
    }
}
