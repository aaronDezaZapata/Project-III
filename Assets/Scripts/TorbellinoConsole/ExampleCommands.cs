using UnityEngine;

namespace TorbellinoConsoleSystem.Examples
{
    /// <summary>
    /// Example commands for TorbellinoConsole.
    /// </summary>
    public static class ExampleCommands
    {
        [ConsoleCommand("hello", "Says hello to the world")]
        public static string SayHello() => "Hello, World!";

        [ConsoleCommand("echo", "Echoes back the input text")]
        public static string Echo(string[] args)
        {
            if (args.Length == 0) return "Usage: echo <text>";
            return string.Join(" ", args);
        }

        [ConsoleCommand("spawn", "Spawns a cube at specified position")]
        public static string SpawnCube(float x, float y, float z)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = new Vector3(x, y, z);
            cube.name = $"TorbellinoConsole_Cube_{x}_{y}_{z}";
            return $"Spawned cube at ({x}, {y}, {z})";
        }

        [ConsoleCommand("multiply", "Multiplies two numbers")]
        public static string Multiply(float a, float b = 1.0f) => $"{a} × {b} = {a * b}";

        [ConsoleCommand("find", "Finds a GameObject by name")]
        public static string FindGameObject(string[] args)
        {
            if (args.Length == 0) return "Usage: find <object_name>";
            string objectName = string.Join(" ", args);
            GameObject obj = GameObject.Find(objectName);
            if (obj != null)
            {
                Vector3 pos = obj.transform.position;
                return $"Found '{objectName}' at ({pos.x:F2}, {pos.y:F2}, {pos.z:F2})";
            }
            return $"GameObject '{objectName}' not found";
        }

        [ConsoleCommand("destroy", "Destroys a GameObject by name")]
        public static string DestroyGameObject(string[] args)
        {
            if (args.Length == 0) return "Usage: destroy <object_name>";
            string objectName = string.Join(" ", args);
            GameObject obj = GameObject.Find(objectName);
            if (obj != null) { Object.Destroy(obj); return $"Destroyed '{objectName}'"; }
            return $"GameObject '{objectName}' not found";
        }

        [ConsoleCommand("scene", "Gets current scene information")]
        public static string GetSceneInfo()
        {
            var scene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
            int objectCount = Object.FindObjectsOfType<GameObject>().Length;
            return $"Scene: {scene.name}\nPath: {scene.path}\nGameObjects: {objectCount}\nBuild Index: {scene.buildIndex}";
        }

        [ConsoleCommand("gc", "Forces garbage collection")]
        public static string ForceGarbageCollection()
        {
            long before = System.GC.GetTotalMemory(false);
            System.GC.Collect();
            long after = System.GC.GetTotalMemory(true);
            return $"Garbage collection completed.\nFreed: {(before - after) / (1024f * 1024f):F2} MB";
        }

        [ConsoleCommand("vsync", "Sets VSync mode (0=off, 1=on)")]
        public static string SetVSync(int mode)
        {
            if (mode < 0 || mode > 1) return "VSync mode must be 0 (off) or 1 (on)";
            QualitySettings.vSyncCount = mode;
            return $"VSync set to {(mode == 0 ? "OFF" : "ON")}";
        }

        [ConsoleCommand("framerate", "Sets target framerate (-1 for unlimited)")]
        public static string SetFrameRate(int fps)
        {
            Application.targetFrameRate = fps;
            return fps == -1 ? "Target framerate set to UNLIMITED" : $"Target framerate set to {fps} FPS";
        }

        [ConsoleCommand("resolution", "Gets current screen resolution")]
        public static string GetResolution()
        {
            Resolution res = Screen.currentResolution;
            return $"Resolution: {Screen.width}x{Screen.height} @ {res.refreshRate}Hz\nFullscreen: {Screen.fullScreen}\nDPI: {Screen.dpi:F1}";
        }

        [ConsoleCommand("getpref", "Gets a PlayerPrefs value")]
        public static string GetPlayerPref(string key)
        {
            if (PlayerPrefs.HasKey(key))
            {
                if (PlayerPrefs.GetInt(key, int.MinValue) != int.MinValue)   return $"{key} = {PlayerPrefs.GetInt(key)}";
                else if (PlayerPrefs.GetFloat(key, float.MinValue) != float.MinValue) return $"{key} = {PlayerPrefs.GetFloat(key)}";
                else return $"{key} = {PlayerPrefs.GetString(key)}";
            }
            return $"Key '{key}' not found in PlayerPrefs";
        }

        [ConsoleCommand("setpref", "Sets a PlayerPrefs string value")]
        public static string SetPlayerPref(string key, string value)
        {
            PlayerPrefs.SetString(key, value);
            PlayerPrefs.Save();
            return $"Set {key} = {value}";
        }
    }
}
