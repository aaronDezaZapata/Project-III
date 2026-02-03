using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Dialogo
{  
    public class DialogoNode : ScriptableObject
    {
        [SerializeField]
        bool isPlayerSpeaking = false;
        [SerializeField]
        string speakerName = "Personaje";

        [SerializeField]
        [TextArea(3, 10)]
        string dialogo;
        [SerializeField]
        List<string> respuestas = new List<string>();
        [SerializeField]
        Rect rect = new Rect(0,0,200, 160);


        public Rect GetRect() => rect;
        public string GetDialogo() => dialogo;
        public List<string> GetRespuestas() => respuestas;
        public bool IsPlayerSpeaking() => isPlayerSpeaking;
        public string GetSpeakerName() => speakerName;

#if UNITY_EDITOR

        public void SetPosition(Vector2 newPosition)
        {
            Undo.RecordObject(this, "Move Dialogue Node");
            rect.position = newPosition;
            EditorUtility.SetDirty(this);
        }

        public void SetDialogo(string newDialogo)
        {

            if (newDialogo != dialogo)
            {
                Undo.RecordObject(this, "Update Dialogue Text");
                dialogo = newDialogo;
                EditorUtility.SetDirty(this);
            }

        }

        public void AddRespuesta(string childID)
        {
            Undo.RecordObject(this, "Add Dialogue Link");
            respuestas.Add(childID);
            EditorUtility.SetDirty(this);
        }

        public void SetSpeakerName(string newName)
        {
            if (newName != speakerName)
            {
                Undo.RecordObject(this, "Update Speaker Name");
                speakerName = newName;
                EditorUtility.SetDirty(this);
            }
        }

        public void SetSize(Vector2 newSize)
        {
            // Solo guardamos si el tamaño ha cambiado para no ensuciar el sistema de Undo constantemente
            if (rect.size != newSize)
            {
                Undo.RecordObject(this, "Resize Node");
                rect.size = newSize;
                EditorUtility.SetDirty(this);
            }
        }

        public void RemoveRespuesta(string childID)
        {
            Undo.RecordObject(this, "Remove Dialogue Link");
            respuestas.Remove(childID);
            EditorUtility.SetDirty(this);
        }

        public void SetPlayerSpeaking(bool newIsPlayerSpeaking)
        {
            Undo.RecordObject(this, "Change Dialog Speaker");
            isPlayerSpeaking = newIsPlayerSpeaking;
            EditorUtility.SetDirty(this);
        }




#endif




    }
}
