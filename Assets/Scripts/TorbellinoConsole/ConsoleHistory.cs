using System.Collections.Generic;
using UnityEngine;

namespace TorbellinoConsoleSystem
{
    public class ConsoleHistory
    {
        private const string PREFS_KEY       = "TorbellinoConsole_History";
        private const string PREFS_COUNT_KEY = "TorbellinoConsole_HistoryCount";
        private const int    MAX_HISTORY     = 50;

        private List<string> history = new List<string>();
        private int navigateIndex = -1;

        public ConsoleHistory() { Load(); }

        public void Push(string command)
        {
            if (string.IsNullOrWhiteSpace(command)) return;
            if (history.Count > 0 && history[history.Count - 1] == command) { navigateIndex = -1; return; }
            history.Add(command);
            if (history.Count > MAX_HISTORY) history.RemoveAt(0);
            navigateIndex = -1;
            Save();
        }

        public string NavigateUp()
        {
            if (history.Count == 0) return null;
            if (navigateIndex == -1) navigateIndex = history.Count - 1;
            else if (navigateIndex > 0) navigateIndex--;
            return history[navigateIndex];
        }

        public string NavigateDown()
        {
            if (navigateIndex == -1) return null;
            navigateIndex++;
            if (navigateIndex >= history.Count) { navigateIndex = -1; return string.Empty; }
            return history[navigateIndex];
        }

        public void ResetNavigation() => navigateIndex = -1;
        public List<string> GetAll()  => new List<string>(history);

        public void Clear()
        {
            history.Clear();
            navigateIndex = -1;
            PlayerPrefs.DeleteKey(PREFS_KEY);
            PlayerPrefs.DeleteKey(PREFS_COUNT_KEY);
            PlayerPrefs.Save();
        }

        private void Save()
        {
            PlayerPrefs.SetInt(PREFS_COUNT_KEY, history.Count);
            for (int i = 0; i < history.Count; i++)
                PlayerPrefs.SetString($"{PREFS_KEY}_{i}", history[i]);
            PlayerPrefs.Save();
        }

        private void Load()
        {
            int count = PlayerPrefs.GetInt(PREFS_COUNT_KEY, 0);
            history.Clear();
            for (int i = 0; i < count; i++)
            {
                string cmd = PlayerPrefs.GetString($"{PREFS_KEY}_{i}", null);
                if (!string.IsNullOrEmpty(cmd)) history.Add(cmd);
            }
        }
    }
}
