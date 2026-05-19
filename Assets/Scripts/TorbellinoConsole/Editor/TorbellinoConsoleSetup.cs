using UnityEngine;
using UnityEditor;
using TMPro;
using UnityEngine.UI;
using System.Linq;

namespace TorbellinoConsoleSystem.Editor
{
    public class TorbellinoConsoleSetup : EditorWindow
    {
        [MenuItem("Tools/TorbellinoConsole/Setup Console")]
        public static void SetupConsole()
        {
            TorbellinoConsole existing = Object.FindObjectOfType<TorbellinoConsole>();
            if (existing != null)
            {
                bool replace = EditorUtility.DisplayDialog(
                    "Console Already Exists",
                    "A TorbellinoConsole already exists in the scene. Do you want to replace it?",
                    "Replace", "Cancel"
                );
                if (!replace) return;
                Object.DestroyImmediate(existing.gameObject);
            }

            GameObject consoleRoot = new GameObject("TorbellinoConsole");
            Canvas canvas = consoleRoot.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 9999;

            CanvasScaler scaler = consoleRoot.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920, 1080);

            consoleRoot.AddComponent<GraphicRaycaster>();

            GameObject panel = new GameObject("Panel");
            panel.transform.SetParent(consoleRoot.transform, false);
            Image panelImage = panel.AddComponent<Image>();
            panelImage.color = new Color(0.05f, 0.05f, 0.05f, 0.95f);
            RectTransform panelRect = panel.GetComponent<RectTransform>();
            panelRect.anchorMin = new Vector2(0, 0.5f);
            panelRect.anchorMax = new Vector2(1, 1);
            panelRect.offsetMin = Vector2.zero;
            panelRect.offsetMax = Vector2.zero;

            GameObject scrollView = new GameObject("ScrollView");
            scrollView.transform.SetParent(panel.transform, false);
            RectTransform scrollRect = scrollView.AddComponent<RectTransform>();
            scrollRect.anchorMin = new Vector2(0.01f, 0.15f);
            scrollRect.anchorMax = new Vector2(0.99f, 0.95f);
            scrollRect.offsetMin = Vector2.zero;
            scrollRect.offsetMax = Vector2.zero;
            ScrollRect scrollComponent = scrollView.AddComponent<ScrollRect>();
            scrollComponent.vertical = true;
            scrollComponent.horizontal = false;
            scrollComponent.movementType = ScrollRect.MovementType.Clamped;
            scrollComponent.scrollSensitivity = 20;
            scrollComponent.inertia = true;
            scrollComponent.decelerationRate = 0.135f;
            Image scrollBg = scrollView.AddComponent<Image>();
            scrollBg.color = new Color(0, 0, 0, 0.3f);

            GameObject viewport = new GameObject("Viewport");
            viewport.transform.SetParent(scrollView.transform, false);
            RectTransform viewportRect = viewport.AddComponent<RectTransform>();
            viewportRect.anchorMin = Vector2.zero;
            viewportRect.anchorMax = Vector2.one;
            viewportRect.sizeDelta = Vector2.zero;
            viewportRect.pivot = new Vector2(0, 1);
            Image viewportImage = viewport.AddComponent<Image>();
            viewportImage.color = new Color(0, 0, 0, 0);
            viewport.AddComponent<RectMask2D>();
            scrollComponent.viewport = viewportRect;

            GameObject content = new GameObject("Content");
            content.transform.SetParent(viewport.transform, false);
            RectTransform contentRect = content.AddComponent<RectTransform>();
            contentRect.anchorMin = new Vector2(0, 1);
            contentRect.anchorMax = new Vector2(1, 1);
            contentRect.pivot = new Vector2(0.5f, 1);
            contentRect.anchoredPosition = Vector2.zero;
            contentRect.sizeDelta = new Vector2(0, 300);
            scrollComponent.content = contentRect;

            GameObject outputTextObj = new GameObject("OutputText");
            outputTextObj.transform.SetParent(content.transform, false);
            TextMeshProUGUI outputText = outputTextObj.AddComponent<TextMeshProUGUI>();
            outputText.fontSize = 16;
            outputText.color = Color.white;
            outputText.alignment = TextAlignmentOptions.BottomLeft;
            outputText.enableWordWrapping = true;
            outputText.overflowMode = TextOverflowModes.Overflow;
            outputText.richText = true;
            TMP_FontAsset font = Resources.Load<TMP_FontAsset>("Fonts & Materials/LiberationSans SDF")
                ?? Resources.FindObjectsOfTypeAll<TMP_FontAsset>().FirstOrDefault();
            if (font != null)
            {
                outputText.font = font;
                if (font.material != null)
                {
                    Material mat = new Material(font.material);
                    mat.name = "TorbellinoConsole Output Material";
                    outputText.fontMaterial = mat;
                }
            }
            RectTransform outputRect = outputTextObj.GetComponent<RectTransform>();
            outputRect.anchorMin = Vector2.zero;
            outputRect.anchorMax = Vector2.one;
            outputRect.pivot = new Vector2(0, 0);
            outputRect.offsetMin = new Vector2(10, 10);
            outputRect.offsetMax = new Vector2(-10, -10);

            GameObject suggestionsObj = new GameObject("Suggestions");
            suggestionsObj.transform.SetParent(panel.transform, false);
            TextMeshProUGUI suggestionsText = suggestionsObj.AddComponent<TextMeshProUGUI>();
            suggestionsText.fontSize = 12;
            suggestionsText.color = new Color(0.5f, 0.8f, 1f, 0.8f);
            suggestionsText.alignment = TextAlignmentOptions.Left;
            suggestionsText.font = Resources.Load<TMP_FontAsset>("Fonts & Materials/LiberationSans SDF");
            RectTransform suggestRect = suggestionsObj.GetComponent<RectTransform>();
            suggestRect.anchorMin = new Vector2(0.01f, 0.08f);
            suggestRect.anchorMax = new Vector2(0.99f, 0.12f);
            suggestRect.offsetMin = Vector2.zero;
            suggestRect.offsetMax = Vector2.zero;

            GameObject inputObj = new GameObject("InputField");
            inputObj.transform.SetParent(panel.transform, false);
            Image inputBg = inputObj.AddComponent<Image>();
            inputBg.color = new Color(0.1f, 0.1f, 0.1f, 1f);
            TMP_InputField inputField = inputObj.AddComponent<TMP_InputField>();
            RectTransform inputRect = inputObj.GetComponent<RectTransform>();
            inputRect.anchorMin = new Vector2(0.01f, 0.01f);
            inputRect.anchorMax = new Vector2(0.99f, 0.06f);
            inputRect.offsetMin = Vector2.zero;
            inputRect.offsetMax = Vector2.zero;

            GameObject textArea = new GameObject("Text Area");
            textArea.transform.SetParent(inputObj.transform, false);
            RectTransform textAreaRect = textArea.AddComponent<RectTransform>();
            textAreaRect.anchorMin = Vector2.zero;
            textAreaRect.anchorMax = Vector2.one;
            textAreaRect.offsetMin = new Vector2(10, 5);
            textAreaRect.offsetMax = new Vector2(-10, -5);
            inputField.textViewport = textAreaRect;

            GameObject inputTextObj = new GameObject("Text");
            inputTextObj.transform.SetParent(textArea.transform, false);
            TextMeshProUGUI inputTextComponent = inputTextObj.AddComponent<TextMeshProUGUI>();
            inputTextComponent.fontSize = 16;
            inputTextComponent.color = Color.white;
            inputTextComponent.font = Resources.Load<TMP_FontAsset>("Fonts & Materials/LiberationSans SDF");
            RectTransform inputTextRect = inputTextObj.GetComponent<RectTransform>();
            inputTextRect.anchorMin = Vector2.zero;
            inputTextRect.anchorMax = Vector2.one;
            inputTextRect.offsetMin = Vector2.zero;
            inputTextRect.offsetMax = Vector2.zero;
            inputField.textComponent = inputTextComponent;
            inputField.fontAsset = Resources.Load<TMP_FontAsset>("Fonts & Materials/LiberationSans SDF");

            TorbellinoConsole console = consoleRoot.AddComponent<TorbellinoConsole>();
            SerializedObject serializedConsole = new SerializedObject(console);
            serializedConsole.FindProperty("consolePanel").objectReferenceValue = panel;
            serializedConsole.FindProperty("inputField").objectReferenceValue = inputField;
            serializedConsole.FindProperty("outputText").objectReferenceValue = outputText;
            serializedConsole.FindProperty("scrollRect").objectReferenceValue = scrollComponent;
            serializedConsole.FindProperty("suggestionText").objectReferenceValue = suggestionsText;
            serializedConsole.ApplyModifiedProperties();

            Selection.activeGameObject = consoleRoot;

            EditorUtility.DisplayDialog(
                "TorbellinoConsole Setup Complete",
                "TorbellinoConsole has been set up successfully!\n\n" +
                "Press the ` key (backtick) to toggle the console.\n\n" +
                "Type 'help' to see available commands.",
                "OK"
            );
        }

        [MenuItem("Tools/TorbellinoConsole/Documentation")]
        public static void ShowDocumentation()
        {
            EditorUtility.DisplayDialog(
                "TorbellinoConsole Documentation",
                "USING THE CONSOLE:\n" +
                "• Press ` (backtick) to toggle console\n" +
                "• Type 'help' to see all commands\n" +
                "• Use Up/Down arrows for command history\n" +
                "• Use Tab for auto-completion\n\n" +
                "CREATING COMMANDS:\n\n" +
                "METHOD 1 - Using Attributes:\n" +
                "[ConsoleCommand(\"mycommand\", \"Description\")]\n" +
                "public static string MyCommand() { ... }\n\n" +
                "METHOD 2 - Manual Registration:\n" +
                "TorbellinoConsole.RegisterCommand(\n" +
                "  \"mycommand\", \"Description\",\n" +
                "  (args) => { return \"result\"; }\n" +
                ");",
                "OK"
            );
        }
    }
}
