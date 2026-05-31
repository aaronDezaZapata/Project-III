using System;
using UnityEngine;

public enum TutorialSection
{
    MOVE, JUMP, DOUBLEJUMP, POPUP, ABSORB, SHOOTING, GEYSER, WHIP
}

public class TutorialSectionTrigger : MonoBehaviour
{
    [SerializeField] private TutorialSection section;
    
    public static event Action<TutorialSection> OnSectionEnter;
    
    private void OnTriggerEnter(Collider other)
    {
        OnSectionEnter?.Invoke(section);
    }
    
    private void OnTriggerExit(Collider other)
    {
        OnSectionEnter?.Invoke(section);
    }
}
