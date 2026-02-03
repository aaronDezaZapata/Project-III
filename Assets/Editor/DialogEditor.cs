using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEngine;

namespace Dialogo.Editor
{
    public class DialogEditor : EditorWindow
    {
        DialoguesAssetMenu selectedDialogue = null;
        [NonSerialized]
        GUIStyle nodeStyle;

        [NonSerialized]
        GUIStyle playerNodeStyle;

        [NonSerialized] 
        GUIStyle textAreaStyle;

        [NonSerialized]
        DialogoNode draggingNode = null;

        [NonSerialized]
        Vector2 draggingOffset;

        [NonSerialized]
        DialogoNode creatingNode = null;

        [NonSerialized]
        DialogoNode deletingNode = null;

        [NonSerialized]
        DialogoNode linkingParentNode = null;

        Vector2 scrollPosition;
        [NonSerialized]
        bool draggingCanvas = false;

        [NonSerialized]
        Vector2 draggingCanvasOffset;

        const float canvasSize = 4000;
        const float backgroundSize = 50; 


        [MenuItem("Window/Editor Dialogo")]
        public static void ShowEditorWindow()
        {
            GetWindow(typeof(DialogEditor),false,"Dialog Editor");
        }

        [OnOpenAsset(1)]
        public static bool OnOpenAsset(int instanceID, int line)
        {
            DialoguesAssetMenu dialogue = EditorUtility.InstanceIDToObject(instanceID) as DialoguesAssetMenu;
            if(dialogue != null)
            {
                ShowEditorWindow();
                return true;
            }
            
            return false;
        }

        private void OnEnable()
        {
            Selection.selectionChanged += SelectionChanged;

            // ESTILOS DE NODO
            nodeStyle = new GUIStyle();
            nodeStyle.normal.background = EditorGUIUtility.Load("node0") as Texture2D;
            nodeStyle.normal.textColor = Color.white;
            nodeStyle.padding = new RectOffset(20, 20, 20, 20);
            nodeStyle.border = new RectOffset(12, 12, 12, 12);

            playerNodeStyle = new GUIStyle();
            playerNodeStyle.normal.background = EditorGUIUtility.Load("node1") as Texture2D;
            playerNodeStyle.normal.textColor = Color.white;
            playerNodeStyle.padding = new RectOffset(20, 20, 20, 20);
            playerNodeStyle.border = new RectOffset(12, 12, 12, 12);

            // Estilo para el área de texto (WordWrap hace que baje de línea)
            textAreaStyle = new GUIStyle(EditorStyles.textArea);
            textAreaStyle.wordWrap = true;
        }

        private void SelectionChanged()
        {
            DialoguesAssetMenu newDialogue  = Selection.activeObject as DialoguesAssetMenu;
            if(newDialogue != null)
            {
                selectedDialogue = newDialogue;
                Repaint();
            }
        }

        private void OnGUI()
        {
            if(selectedDialogue == null)
            {
                EditorGUILayout.LabelField("Dialogue not selected");

            }
            else
            {
                ProcessEvents();

                scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

                Rect canvas = GUILayoutUtility.GetRect(canvasSize, canvasSize);
                Texture2D backgroundTex = Resources.Load("background") as Texture2D;
                Rect textCoords = new Rect(0, 0, canvasSize / backgroundSize, canvasSize / backgroundSize);
                GUI.DrawTextureWithTexCoords(canvas, backgroundTex, textCoords);

                foreach (DialogoNode node in selectedDialogue.GetAllNodes())
                {
                    DrawConnections(node);
                }

                foreach (DialogoNode node in selectedDialogue.GetAllNodes())
                {
                    DrawNode(node);
                }

                EditorGUILayout.EndScrollView();

                if(creatingNode != null)
                {
                    Undo.RecordObject(selectedDialogue, "Dialogo Añadido");
                    selectedDialogue.CreateNode(creatingNode);
                    creatingNode = null;
                }

                if(deletingNode != null)
                {
                    selectedDialogue.DeleteNode(deletingNode);
                    deletingNode = null;
                }

            }
            
        }

        

        void ProcessEvents()
        {
            if(Event.current.type == EventType.MouseDown && draggingNode == null)
            {
                draggingNode = GetNodeAtPoint(Event.current.mousePosition + scrollPosition);
                if(draggingNode != null)
                {
                    draggingOffset = draggingNode.GetRect().position - Event.current.mousePosition;
                    Selection.activeObject = draggingNode;
                }
                else
                {
                    draggingCanvas = true;
                    draggingCanvasOffset = Event.current.mousePosition + scrollPosition;
                    Selection.activeObject = selectedDialogue;
                }
                
            }
            else if(Event.current.type == EventType.MouseDrag && draggingNode != null)
            {
                
                draggingNode.SetPosition(Event.current.mousePosition + draggingOffset);

                GUI.changed = true;
            }
            else if (Event.current.type == EventType.MouseDrag && draggingCanvas)
            {
                scrollPosition = draggingCanvasOffset - Event.current.mousePosition;

                GUI.changed = true;
            }
            else if(Event.current.type == EventType.MouseUp && draggingNode != null)
            {
                draggingNode = null;
            }
            else if (Event.current.type == EventType.MouseUp && draggingCanvas)
            {
                draggingCanvas = false;
            }

        }



        private void DrawNode(DialogoNode node)
        {
            GUIStyle style = nodeStyle;
            if (node.IsPlayerSpeaking())
            {
                style = playerNodeStyle;
            }

            // CALCULO DINAMICO DE ALTURA
            
            float nodeWidth = 200f;

            
            // Restamos 40 pixels aprox por los padding del texto
            float textWidth = nodeWidth - 40f;
            GUIContent content = new GUIContent(node.GetDialogo());
            float textHeight = textAreaStyle.CalcHeight(content, textWidth);

            // Altura base
            
            float baseHeight = 130f;

            // Asignamos el nuevo tamaño al nodo
            node.SetSize(new Vector2(nodeWidth, baseHeight + textHeight));

            //DIBUJADO
            GUILayout.BeginArea(node.GetRect(), style);

            // Zona Superior: Nombre
            GUILayout.BeginHorizontal();
            GUILayout.Label("Nombre:", GUILayout.Width(50));
            string newName = EditorGUILayout.TextField(node.GetSpeakerName());
            node.SetSpeakerName(newName);
            GUILayout.EndHorizontal();

            GUILayout.Space(5);

            // Zona Central: Texto
            GUILayout.Label("Diálogo:");

            // Usamos GUILayout.Height(textHeight) para que el campo de texto mida exactamente lo que necesita el texto
            // Le sumamos un pequeño buffer para que no salga barra de scroll
            string newText = EditorGUILayout.TextArea(node.GetDialogo(), textAreaStyle, GUILayout.Height(textHeight + 10));
            node.SetDialogo(newText);

            GUILayout.Space(5);

            // Zona Inferior: Botones
            GUILayout.BeginHorizontal();

            if (GUILayout.Button("x", GUILayout.Width(20)))
            {
                deletingNode = node;
            }

            DrawLinkButton(node);

            if (GUILayout.Button("+", GUILayout.Width(20)))
            {
                creatingNode = node;
            }

            GUILayout.EndHorizontal();

            GUILayout.EndArea();
        }

        private void DrawLinkButton(DialogoNode node)
        {
            if (linkingParentNode == null)
            {
                if (GUILayout.Button("Link"))
                {
                    linkingParentNode = node;
                }
            }
            else if(linkingParentNode == node)
            {
                if(GUILayout.Button("Cancel")) 
                {
                    linkingParentNode = null;
                } 
                
            }else if (linkingParentNode.GetRespuestas().Contains(node.name))
            {
                if (GUILayout.Button("Unlink"))
                { 
                    linkingParentNode.RemoveRespuesta(node.name);
                    linkingParentNode = null;
                }
            }
            else
            {
                if (GUILayout.Button("respuesta"))
                {
                    linkingParentNode.AddRespuesta(node.name);
                    linkingParentNode = null;
                }
            }
        }

        private void DrawConnections(DialogoNode node)
        {
            foreach(DialogoNode childNode in selectedDialogue.GetAllChildren(node))
            {
                if (childNode == null) continue;
                Vector3 startPosition = new Vector2(node.GetRect().xMax, node.GetRect().center.y);
                Vector3 endPosition = new Vector2(childNode.GetRect().xMin, childNode.GetRect().center.y);
                Vector3 controlPointOffset = endPosition - startPosition;
                controlPointOffset.y = 0;
                controlPointOffset.x *= 0.8f;
                Handles.DrawBezier(
                    startPosition, endPosition,
                    startPosition + controlPointOffset,
                    endPosition - controlPointOffset,
                    Color.white, null, 5f);
            }
        }


        private DialogoNode GetNodeAtPoint(Vector2 point)
        {
            DialogoNode foundNode = null;
            foreach(DialogoNode node in selectedDialogue.GetAllNodes())
            {
                if (node.GetRect().Contains(point))
                {
                    foundNode = node;
                }
            }

            return foundNode;
        }
    }
}
