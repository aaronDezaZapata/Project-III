using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dialogo;
using TMPro;
using UnityEngine.UI;

namespace UI
{
    public class DialogueUI : MonoBehaviour
    {
        [SerializeField]PlayerConversant playerConversant;
        [SerializeField] TextMeshProUGUI AIText;
        [SerializeField] Button nextButton;

        private void Awake()
        {
            nextButton.onClick.AddListener(Next);
        }

        void Start()
        {
            
        }

        private void Update()
        {
            
            if (Input.GetKeyDown(KeyCode.Comma))
            {
                if(playerConversant.HasNext())
                {
                    Next();
                }
            }
        }

        void Next()
        {
            if (playerConversant.HasNext())
            {
                playerConversant.Next();
                UpdateUI();
            }
            else
            {
                CloseDialogue();
            }
        }

        void CloseDialogue()
        {
            gameObject.SetActive(false);
        }

        public void UpdateUI()
        {
            AIText.text = playerConversant.GetText();
            nextButton.gameObject.SetActive(playerConversant.HasNext());
        }
    }
}

