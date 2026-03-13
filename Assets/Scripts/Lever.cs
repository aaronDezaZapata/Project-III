using UnityEngine;

/// <summary>
/// Palanca interactuable.
/// Se suscribe al InteractionEvent del InputHandler cuando el jugador entra en el trigger,
/// y se desuscribe cuando sale. Sin Update, sin polling.
/// </summary>
public class Lever : MonoBehaviour
{
    [Header("Identificador")]
    [Tooltip("ID único que ha de coincidir con el leverID de la plataforma que controla.")]
    public string leverID = "lever_01";

    [Header("Configuración")]
    [SerializeField] private InputHandler input;

    [Tooltip("Si es true, la palanca solo se puede activar una vez.")]
    public bool oneShot = false;

    [Tooltip("Si es true alterna entre activar/desactivar (útil para loop).")]
    public bool toggle = false;

    // ── Estado interno ──────────────────────────────────────────────────────
    private bool _used = false;
    private bool _isOn = false;

    // ── Trigger ─────────────────────────────────────────────────────────────
    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        input.InteractionEvent += Activate;
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        input.InteractionEvent -= Activate;
    }

    // ── Lógica ──────────────────────────────────────────────────────────────
    private void Activate()
    {
        if (oneShot && _used) return;

        if (toggle)
            _isOn = !_isOn;

        _used = true;
        GameManager.Instance.OnLeverActivated?.Invoke(leverID);

        Debug.Log($"[Lever] '{leverID}' activada.");
    }
}