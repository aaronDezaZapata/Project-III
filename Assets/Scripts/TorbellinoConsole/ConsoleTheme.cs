using UnityEngine;

namespace TorbellinoConsoleSystem
{
    [System.Serializable]
    public class ConsoleTheme
    {
        public string Name;
        public Color BackgroundColor;
        public Color InputBackgroundColor;
        public Color OutputTextColor;
        public Color InputTextColor;
        public Color SuggestionColor;
        public Color ErrorColor;
        public Color WarningColor;
        public Color SuccessColor;
        public Color SystemColor;

        public static ConsoleTheme Dark => new ConsoleTheme
        {
            Name                 = "dark",
            BackgroundColor      = new Color(0.05f, 0.05f, 0.05f, 0.95f),
            InputBackgroundColor = new Color(0.10f, 0.10f, 0.10f, 1.00f),
            OutputTextColor      = new Color(1.00f, 1.00f, 1.00f, 1.00f),
            InputTextColor       = Color.white,
            SuggestionColor      = new Color(0.50f, 0.80f, 1.00f, 0.80f),
            ErrorColor           = new Color(1.00f, 0.30f, 0.30f, 1.00f),
            WarningColor         = new Color(1.00f, 0.80f, 0.20f, 1.00f),
            SuccessColor         = new Color(0.30f, 1.00f, 0.50f, 1.00f),
            SystemColor          = new Color(0.60f, 0.60f, 0.60f, 1.00f),
        };

        public static ConsoleTheme Matrix => new ConsoleTheme
        {
            Name                 = "matrix",
            BackgroundColor      = new Color(0.00f, 0.05f, 0.00f, 0.97f),
            InputBackgroundColor = new Color(0.00f, 0.10f, 0.00f, 1.00f),
            OutputTextColor      = new Color(0.10f, 1.00f, 0.10f, 1.00f),
            InputTextColor       = new Color(0.20f, 1.00f, 0.20f, 1.00f),
            SuggestionColor      = new Color(0.00f, 0.70f, 0.00f, 0.80f),
            ErrorColor           = new Color(1.00f, 0.20f, 0.20f, 1.00f),
            WarningColor         = new Color(0.80f, 1.00f, 0.00f, 1.00f),
            SuccessColor         = new Color(0.50f, 1.00f, 0.50f, 1.00f),
            SystemColor          = new Color(0.00f, 0.50f, 0.00f, 1.00f),
        };

        public static ConsoleTheme Amber => new ConsoleTheme
        {
            Name                 = "amber",
            BackgroundColor      = new Color(0.07f, 0.04f, 0.00f, 0.97f),
            InputBackgroundColor = new Color(0.12f, 0.07f, 0.00f, 1.00f),
            OutputTextColor      = new Color(1.00f, 0.70f, 0.10f, 1.00f),
            InputTextColor       = new Color(1.00f, 0.80f, 0.20f, 1.00f),
            SuggestionColor      = new Color(1.00f, 0.50f, 0.00f, 0.80f),
            ErrorColor           = new Color(1.00f, 0.20f, 0.20f, 1.00f),
            WarningColor         = new Color(1.00f, 1.00f, 0.00f, 1.00f),
            SuccessColor         = new Color(0.60f, 1.00f, 0.30f, 1.00f),
            SystemColor          = new Color(0.70f, 0.50f, 0.10f, 1.00f),
        };

        public static ConsoleTheme Cyberpunk => new ConsoleTheme
        {
            Name                 = "cyberpunk",
            BackgroundColor      = new Color(0.03f, 0.00f, 0.08f, 0.97f),
            InputBackgroundColor = new Color(0.07f, 0.00f, 0.15f, 1.00f),
            OutputTextColor      = new Color(0.90f, 0.20f, 1.00f, 1.00f),
            InputTextColor       = new Color(1.00f, 0.40f, 1.00f, 1.00f),
            SuggestionColor      = new Color(0.00f, 1.00f, 1.00f, 0.80f),
            ErrorColor           = new Color(1.00f, 0.20f, 0.40f, 1.00f),
            WarningColor         = new Color(1.00f, 0.90f, 0.00f, 1.00f),
            SuccessColor         = new Color(0.00f, 1.00f, 0.60f, 1.00f),
            SystemColor          = new Color(0.60f, 0.00f, 0.80f, 1.00f),
        };

        public static ConsoleTheme Get(string name)
        {
            switch (name.ToLower())
            {
                case "matrix":    return Matrix;
                case "amber":     return Amber;
                case "cyberpunk": return Cyberpunk;
                default:          return Dark;
            }
        }

        public static string ToHex(Color c) => ColorUtility.ToHtmlStringRGB(c);
    }
}
