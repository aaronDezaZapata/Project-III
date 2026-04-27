using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Dialogo
{
    public class PlayerConversant : MonoBehaviour
    {
        [SerializeField] DialoguesAssetMenu currentDialogue;
        DialogoNode currentNode = null;

        public string GetText()
        {
            if(currentNode == null)
            {
                return "";
            }
           return currentNode.GetDialogo();
        }

        

        public void GetDialogue(DialoguesAssetMenu currentDialogue)
        {
            this.currentDialogue = currentDialogue;
            currentNode = currentDialogue.GetRootNode();
        }

        public void Next()
        {
            DialogoNode[] children = currentDialogue.GetAllChildren(currentNode).ToArray();

            if (children.Length > 0)
            {
                currentNode = children[0];
            }
        }

        public bool HasNext()
        {
            if (currentNode == null || currentDialogue == null) return false;
            return currentDialogue.GetAllChildren(currentNode).Count() > 0;
        }

        public string GetSpeakerName()
        {
            if (currentNode == null) return "";
            return currentNode.GetSpeakerName();
        }

    }
}
