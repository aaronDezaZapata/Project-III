using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using TMPro;

namespace TorbellinoConsoleSystem
{
    public class TorbellinoConsole : MonoBehaviour
    {
        [Header("UI References")]
        [SerializeField] private GameObject consolePanel;
        [SerializeField] private TMP_InputField inputField;
        [SerializeField] private TextMeshProUGUI outputText;
        [SerializeField] private ScrollRect scrollRect;
        [SerializeField] private TextMeshProUGUI suggestionText;

        [Header("Settings")]
        [SerializeField] private KeyCode toggleKey = KeyCode.BackQuote;
        [SerializeField] private int maxLogLines = 500;
        [SerializeField] private bool logUnityMessages = true;

        private CommandRegistry commandRegistry;
        private ConsoleHistory  consoleHistory;
        private ConsoleTheme    activeTheme;
        private const string    THEME_PREFS_KEY = "TorbellinoConsole_Theme";

        private List<string> outputLines = new List<string>();
        private string currentInput = "";

        private static TorbellinoConsole instance;
        public static TorbellinoConsole Instance => instance;

        private void Awake()
        {
            if (instance != null && instance != this)
            {
                Destroy(gameObject);
                return;
            }
            instance = this;
            DontDestroyOnLoad(gameObject);

            commandRegistry = new CommandRegistry();
            consoleHistory  = new ConsoleHistory();

            RegisterDefaultCommands();
            ScanForCommands();

            string savedTheme = PlayerPrefs.GetString(THEME_PREFS_KEY, "dark");
            ApplyTheme(ConsoleTheme.Get(savedTheme));

            if (logUnityMessages)
                Application.logMessageReceived += HandleUnityLog;
        }

        private void Start()
        {
            if (consolePanel != null)
                consolePanel.SetActive(false);

            if (inputField != null)
            {
                inputField.onValueChanged.AddListener(OnInputChanged);
                inputField.onSubmit.AddListener(OnSubmit);
            }

            Log("TorbellinoConsole initialized. Type 'help' for available commands.", LogType.System);
        }

        private void Update()
        {
            if (Input.GetKeyDown(toggleKey))
                ToggleConsole();

            if (consolePanel != null && consolePanel.activeSelf)
            {
                if (inputField != null)
                {
                    try
                    {
                        if (!inputField.isFocused)
                        {
                            inputField.Select();
                            inputField.ActivateInputField();
                        }
                    }
                    catch { }
                }

                HandleHistoryNavigation();
                HandleAutoComplete();
            }
        }

        public void ToggleConsole()
        {
            if (consolePanel == null) return;

            bool isActive = !consolePanel.activeSelf;
            consolePanel.SetActive(isActive);

            PlayerInput playerInput = FindPlayerInput();
            if (playerInput != null)
                playerInput.enabled = !isActive;

            if (isActive && inputField != null)
            {
                inputField.text = "";
                StartCoroutine(ActivateInputFieldDelayed());
                consoleHistory.ResetNavigation();
            }
        }

        private const string PLAYER_NAME = "Player";
        private UnityEngine.InputSystem.PlayerInput FindPlayerInput()
        {
            GameObject player = GameObject.Find(PLAYER_NAME);
            if (player == null) return null;
            return player.GetComponent<UnityEngine.InputSystem.PlayerInput>();
        }

        private System.Collections.IEnumerator ActivateInputFieldDelayed()
        {
            yield return new WaitForEndOfFrame();
            if (inputField != null)
            {
                inputField.Select();
                inputField.ActivateInputField();
            }
        }

        private void OnInputChanged(string input)
        {
            currentInput = input;
            consoleHistory.ResetNavigation();
            UpdateSuggestions();
        }

        private void OnSubmit(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
            {
                inputField.ActivateInputField();
                return;
            }

            ExecuteCommand(input);
            consoleHistory.Push(input);
            inputField.text = "";
            inputField.ActivateInputField();
        }

        private void ExecuteCommand(string commandLine)
        {
            Log($"> {commandLine}", LogType.Command);

            string[] parts = ParseCommandLine(commandLine);
            if (parts.Length == 0) return;

            string commandName = parts[0].ToLower();
            string[] args = parts.Skip(1).ToArray();

            if (commandRegistry.TryExecute(commandName, args, out string result))
            {
                if (!string.IsNullOrEmpty(result))
                    Log(result, LogType.Output);
            }
            else
            {
                Log($"Unknown command: '{commandName}'. Type 'help' for available commands.", LogType.Error);
            }
        }

        private void HandleHistoryNavigation()
        {
            if (Input.GetKeyDown(KeyCode.UpArrow))
            {
                string prev = consoleHistory.NavigateUp();
                if (prev != null)
                {
                    inputField.text = prev;
                    inputField.MoveTextEnd(false);
                }
            }
            else if (Input.GetKeyDown(KeyCode.DownArrow))
            {
                string next = consoleHistory.NavigateDown();
                if (next != null)
                {
                    inputField.text = next;
                    inputField.MoveTextEnd(false);
                }
            }
        }

        private void HandleAutoComplete()
        {
            if (Input.GetKeyDown(KeyCode.Tab) && !string.IsNullOrWhiteSpace(currentInput))
            {
                List<string> suggestions = commandRegistry.GetSuggestions(currentInput);
                if (suggestions.Count == 1)
                {
                    inputField.text = suggestions[0];
                    inputField.MoveTextEnd(false);
                }
            }
        }

        private void UpdateSuggestions()
        {
            if (suggestionText == null) return;

            if (string.IsNullOrWhiteSpace(currentInput))
            {
                suggestionText.text = "";
                return;
            }

            List<string> suggestions = commandRegistry.GetSuggestions(currentInput);
            suggestionText.text = suggestions.Count > 0
                ? "Suggestions: " + string.Join(", ", suggestions.Take(5))
                : "";
        }

       

        public void Log(string message, LogType type = LogType.Output)
        {
            string coloredMessage = FormatLogMessage(message, type);
            outputLines.Add(coloredMessage);

            if (outputLines.Count > maxLogLines)
                outputLines.RemoveAt(0);

            UpdateOutputDisplay();
        }

        
        public void LogError(string msg)   => Log($"[ERROR] {msg}", LogType.Error);
        public void LogWarning(string msg) => Log($"[WARN]  {msg}", LogType.Warning);
        public void LogSuccess(string msg) => Log(msg, LogType.Success);
        public void LogSystem(string msg)  => Log(msg, LogType.System);

        private string FormatLogMessage(string message, LogType type)
        {
            string color = type switch
            {
                LogType.Command => "#00FFFF",
                LogType.Output  => "#FFFFFF",
                LogType.Warning => "#FFFF00",
                LogType.Error   => "#FF4444",
                LogType.System  => "#00FF00",
                LogType.Success => "#00FF88",
                _               => "#FFFFFF"
            };

           
            if (activeTheme != null)
            {
                color = type switch
                {
                    LogType.Command => "#00FFFF",
                    LogType.Output  => "#" + ConsoleTheme.ToHex(activeTheme.OutputTextColor),
                    LogType.Warning => "#" + ConsoleTheme.ToHex(activeTheme.WarningColor),
                    LogType.Error   => "#" + ConsoleTheme.ToHex(activeTheme.ErrorColor),
                    LogType.System  => "#" + ConsoleTheme.ToHex(activeTheme.SystemColor),
                    LogType.Success => "#" + ConsoleTheme.ToHex(activeTheme.SuccessColor),
                    _               => "#FFFFFF"
                };
            }

            return $"<color={color}>{message}</color>";
        }

        private void UpdateOutputDisplay()
        {
            if (outputText == null) return;

            outputText.text = string.Join("\n", outputLines);
            outputText.ForceMeshUpdate();

            if (scrollRect != null && scrollRect.content != null)
            {
                float textHeight  = outputText.preferredHeight;
                float minHeight   = scrollRect.viewport.rect.height;
                float contentHeight = Mathf.Max(textHeight + 20, minHeight);
                scrollRect.content.sizeDelta = new Vector2(scrollRect.content.sizeDelta.x, contentHeight);
            }

            Canvas.ForceUpdateCanvases();
            if (scrollRect != null)
                StartCoroutine(ScrollToBottom());
        }

        private System.Collections.IEnumerator ScrollToBottom()
        {
            yield return null;
            if (scrollRect != null)
                scrollRect.verticalNormalizedPosition = 0f;
        }

        

        private void ApplyTheme(ConsoleTheme theme)
        {
            activeTheme = theme;

            Image panelImage = consolePanel != null ? consolePanel.GetComponent<Image>() : null;
            if (panelImage != null) panelImage.color = theme.BackgroundColor;

            Image inputImage = inputField != null ? inputField.GetComponent<Image>() : null;
            if (inputImage != null) inputImage.color = theme.InputBackgroundColor;

            if (outputText   != null) outputText.color = theme.OutputTextColor;
            if (suggestionText != null) suggestionText.color = theme.SuggestionColor;
            if (inputField?.textComponent != null) inputField.textComponent.color = theme.InputTextColor;
        }

       

        private void HandleUnityLog(string message, string stackTrace, UnityEngine.LogType type)
        {
            LogType consoleType = type switch
            {
                UnityEngine.LogType.Error     => LogType.Error,
                UnityEngine.LogType.Warning   => LogType.Warning,
                UnityEngine.LogType.Exception => LogType.Error,
                _                             => LogType.Output
            };
            Log(message, consoleType);
        }

        private string[] ParseCommandLine(string commandLine)
        {
            List<string> parts = new List<string>();
            bool inQuotes = false;
            string current = "";

            foreach (char c in commandLine)
            {
                if (c == '"')         inQuotes = !inQuotes;
                else if (c == ' ' && !inQuotes)
                {
                    if (!string.IsNullOrEmpty(current)) { parts.Add(current); current = ""; }
                }
                else current += c;
            }

            if (!string.IsNullOrEmpty(current)) parts.Add(current);
            return parts.ToArray();
        }

        private void RegisterDefaultCommands()
        {
            commandRegistry.Register("help", "Shows all available commands", (args) =>
            {
                List<CommandInfo> commands = commandRegistry.GetAllCommands();
                string result = "Available Commands:\n";
                foreach (CommandInfo cmd in commands.OrderBy(c => c.Name))
                    result += $"  <color=#00FFFF>{cmd.Name}</color> - {cmd.Description}\n";
                return result;
            });

            commandRegistry.Register("clear", "Clears the console output", (args) =>
            {
                outputLines.Clear();
                UpdateOutputDisplay();
                return "";
            });

            commandRegistry.Register("quit", "Quits the application", (args) =>
            {
#if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
#else
                Application.Quit();
#endif
                return "Quitting application...";
            });

            commandRegistry.Register("time", "Gets/sets time scale. Usage: time <scale>", (args) =>
            {
                if (args.Length > 0 && float.TryParse(args[0], out float scale))
                {
                    Time.timeScale = scale;
                    return $"Time scale set to {scale}";
                }
                return $"Current time scale: {Time.timeScale}";
            });

            commandRegistry.Register("fps", "Shows current FPS", (args) =>
            {
                float fps = 1.0f / Time.deltaTime;
                return $"FPS: {fps:F1}";
            });

            commandRegistry.Register("theme", "Changes console theme. Usage: theme <dark|matrix|amber|cyberpunk>", (args) =>
            {
                if (args.Length == 0) return "Available themes: dark, matrix, amber, cyberpunk";
                ApplyTheme(ConsoleTheme.Get(args[0]));
                PlayerPrefs.SetString(THEME_PREFS_KEY, args[0]);
                PlayerPrefs.Save();
                return $"Theme set to '{args[0]}'";
            });

            commandRegistry.Register("history", "Shows command history. Use 'history clear' to wipe it.", (args) =>
            {
                if (args.Length > 0 && args[0] == "clear")
                {
                    consoleHistory.Clear();
                    return "History cleared.";
                }
                List<string> all = consoleHistory.GetAll();
                return all.Count == 0 ? "No history yet." : string.Join("\n", all);
            });
        }

        private void ScanForCommands()
        {
            foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                try
                {
                    foreach (Type type in assembly.GetTypes())
                    {
                        MethodInfo[] methods = type.GetMethods(BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
                        foreach (MethodInfo method in methods)
                        {
                            ConsoleCommandAttribute attribute = method.GetCustomAttribute<ConsoleCommandAttribute>();
                            if (attribute != null)
                                RegisterAttributeCommand(method, attribute);
                        }
                    }
                }
                catch (ReflectionTypeLoadException) { }
            }
        }

        private void RegisterAttributeCommand(MethodInfo method, ConsoleCommandAttribute attribute)
        {
            string commandName = string.IsNullOrEmpty(attribute.CommandName)
                ? method.Name.ToLower()
                : attribute.CommandName;

            commandRegistry.Register(commandName, attribute.Description, (args) =>
            {
                try
                {
                    ParameterInfo[] parameters = method.GetParameters();
                    object[] invokeArgs;

                    if (parameters.Length == 1 && parameters[0].ParameterType == typeof(string[]))
                        invokeArgs = new object[] { args };
                    else if (parameters.Length == 0)
                        invokeArgs = null;
                    else
                        invokeArgs = ConvertArguments(args, parameters);

                    var result = method.Invoke(null, invokeArgs);
                    return result?.ToString() ?? "";
                }
                catch (Exception e)
                {
                    return $"Error executing command: {e.Message}";
                }
            });
        }

        private object[] ConvertArguments(string[] args, ParameterInfo[] parameters)
        {
            var result = new object[parameters.Length];
            for (int i = 0; i < parameters.Length; i++)
            {
                result[i] = i >= args.Length
                    ? (parameters[i].HasDefaultValue ? parameters[i].DefaultValue : null)
                    : Convert.ChangeType(args[i], parameters[i].ParameterType);
            }
            return result;
        }

        public static void RegisterCommand(string name, string description, Func<string[], string> action)
        {
            if (instance != null)
                instance.commandRegistry.Register(name, description, action);
        }

        private void OnDestroy()
        {
            if (logUnityMessages)
                Application.logMessageReceived -= HandleUnityLog;
        }
    }

    public enum LogType
    {
        Output,
        Command,
        Warning,
        Error,
        System,
        Success
    }
}
