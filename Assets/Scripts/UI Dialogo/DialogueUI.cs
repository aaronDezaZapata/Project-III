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
        //[SerializeField]MovementPlayer playerMovement;

        private void Awake()
        {
            //EventForGame.instance.activarDialogo.AddListener(UpdateUI);
            //playerConversant = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerConversant>();
            //playerMovement = GameObject.FindGameObjectWithTag("Player").GetComponent<MovementPlayer>();
            nextButton.onClick.AddListener(Next);
            //UpdateUI();
        }

        void Start()
        {
            //playerConversant = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerConversant>();
            //playerMovement = GameObject.FindGameObjectWithTag("Player").GetComponent<MovementPlayer>();
            //nextButton.onClick.AddListener(Next);
            
            
        }

        private void Update()
        {
            
            if (Input.GetKeyDown(KeyCode.Comma))
            {
                if(playerConversant.HasNext())
                {
                    Next();
                }
                else
                {
                    //playerMovement.bikeLockControls = false;
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
                // Si no hay más texto, cerramos la ventana
                CloseDialogue();
            }
        }

        void CloseDialogue()
        {
            // Desactivar el objeto visual o el canvas
            gameObject.SetActive(false);
            // O si el script está en un objeto hijo del canvas raíz:
            // transform.parent.gameObject.SetActive(false);
        }

        public void UpdateUI()
        {
            AIText.text = playerConversant.GetText();
            nextButton.gameObject.SetActive(playerConversant.HasNext());
        }
    }
}

