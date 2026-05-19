using System;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Health : MonoBehaviour
{
    [SerializeField] private int maxHealth = 100;

    public int health;
    private bool _isInvulnerable;

    public event Action OnTakeDamage;
    public event Action OnDie;
    public event Action OnHealthChanged;

    public bool IsDead => health == 0;
    public int MaxHealth => maxHealth;

    private void Start()
    {
        health = maxHealth;
        OnHealthChanged?.Invoke();
    }

    public void SetInvulnerable(bool isInvulnerable)
    {
        _isInvulnerable = isInvulnerable;
    }

    public void DealDamage(int damage)
    {
        if (health == 0 || _isInvulnerable) return;

        health = Mathf.Max(health - damage, 0);

        OnHealthChanged?.Invoke();
        OnTakeDamage?.Invoke();

        if (health <= 0)
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
            OnDie?.Invoke();
        }
    }
}
