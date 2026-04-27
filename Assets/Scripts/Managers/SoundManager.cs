using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager Instance;

    [Header("Audio Sources")]
    [SerializeField] private AudioSource musicSource;
    [SerializeField] private AudioSource sfxSource;

    private void Awake()
    {
        // Patron Singleton: para que solo haya uno y persista entre escenas
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    // MÉTODOS PARA MÚSICA 
    public void PlayMusic(AudioClip clip, float volume = 1f)
    {
        musicSource.clip = clip;
        musicSource.volume = volume;
        musicSource.loop = true; 
        musicSource.Play();
    }

    public void StopMusic()
    {
        musicSource.Stop();
    }

    // MÉTODOS PARA EFECTOS DE SONIDO (SFX)
    public void PlaySFX(AudioClip clip, float volume = 1f)
    {
        // PlayOneShot permite solapar sonidos sin cortarlos
        sfxSource.PlayOneShot(clip, volume);
    }
}
