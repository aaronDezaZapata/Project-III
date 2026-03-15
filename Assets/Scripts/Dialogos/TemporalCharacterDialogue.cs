using UnityEngine;
using TMPro;

public class TemporalCharacterDialogue : MonoBehaviour
{
    [Header("UI")]
    public GameObject promptUI;          // Texto
    public GameObject dialoguePanel;     // Panel del diálogo
    public TMP_Text dialogueText;        // Texto dentro del panel

    [Header("Contenido")]
    [TextArea(3, 6)]
    public string message = "Explicación";

    [Header("Configuración")]
    public KeyCode interactionKey = KeyCode.F;
    public string playerTag = "Player";

    private bool playerInRange = false;
    private bool dialogueOpen = false;

    private void Start()
    {
        promptUI.SetActive(false);
        dialoguePanel.SetActive(false);
    }

    private void Update()
    {
        if (playerInRange && Input.GetKeyDown(interactionKey))
        {
            if (!dialogueOpen)
            {
                OpenDialogue();
            }
            else
            {
                CloseDialogue();
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(playerTag))
        {
            playerInRange = true;
            promptUI.SetActive(true);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(playerTag))
        {
            playerInRange = false;
            promptUI.SetActive(false);
            CloseDialogue();
        }
    }
    void OpenDialogue()
    {
        dialogueOpen = true;
        promptUI.SetActive(false);
        dialoguePanel.SetActive(true);
        dialogueText.text = message;
    }

    void CloseDialogue()
    {
        dialogueOpen = false;
        dialoguePanel.SetActive(false);

        if (playerInRange)
            promptUI.SetActive(true);
    }
}