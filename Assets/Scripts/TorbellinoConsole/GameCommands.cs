using UnityEngine;

namespace TorbellinoConsoleSystem.Game
{
    public static class GameCommands
    {
        private const string STATEMACHINE_COMPONENT_TYPE = "PlayerStateMachine";
        private static string playerName = "Player";

        private static GameObject GetPlayer()
        {
            GameObject player = GameManager.Instance.GetPlayer().gameObject;
            if (player == null)
                Debug.LogWarning($"[TorbellinoConsole] No GameObject named '{playerName}' found.");
            return player;
        }

        [ConsoleCommand("teleport", "Teleports the player. Usage: teleport <x> <y> <z>")]
        public static string Teleport(float x, float y, float z)
        {
            GameObject player = GetPlayer();
            if (player == null)
                return $"<color=red>Player '{playerName}' not found. Use 'playername <n>' to set the correct name.</color>";
            player.transform.position = new Vector3(x, y, z);
            return $"<color=#00FF88>Teleported '{playerName}' to ({x}, {y}, {z})</color>";
        }

        [ConsoleCommand("tp", "Alias for teleport. Usage: tp <x> <y> <z>")]
        public static string TeleportAlias(float x, float y, float z) => Teleport(x, y, z);

        [ConsoleCommand("tphere", "Teleports the player to 0,0,0")]
        public static string TeleportToOrigin() => Teleport(0f, 0f, 0f);

        [ConsoleCommand("playerpos", "Prints the player's current world position")]
        public static string GetPlayerPosition()
        {
            GameObject player = GetPlayer();
            if (player == null) return $"<color=red>Player '{playerName}' not found.</color>";
            Vector3 pos = player.transform.position;
            return $"<color=#AAAAFF>Player position: ({pos.x:F2}, {pos.y:F2}, {pos.z:F2})</color>";
        }

        [ConsoleCommand("flymode", "Sets the player to fly state. Calls ChangeState(typeof(StateFly))")]
        public static string SetFlyState(string[] args)
        {
            if (args.Length == 0)
                return "<color=red>Usage: flymode [0|1]</color>";

            string stateTypeName = args[0] switch
            {
                "0" => "PlayerWhiteState",
                "1" => "PlayerFlyState",
                _ => null
            };

            if (stateTypeName == null)
                return $"<color=red>Invalid argument '{args[0]}'. Use 0 (FreeLook) or 1 (Fly).</color>";

            return ChangePlayerState(stateTypeName);
        }

        [ConsoleCommand("state", "Changes player state by class name. Usage: state <StateClassName>")]
        public static string SetState(string[] args)
        {
            if (args.Length == 0)
                return "Usage: state <StateClassName>  (e.g. state PlayerFlyState, state PlayerIdleState)";
            return ChangePlayerState(args[0]);
        }

        private static string ChangePlayerState(string stateTypeName)
        {
            GameObject player = GameManager.Instance.GetPlayer().gameObject;
            if (player == null) return $"<color=red>Player not found.</color>";

            PlayerStateMachine sm = player.GetComponent<PlayerStateMachine>();
            if (sm == null)
                return $"<color=red>No StateMachine found on player.</color>";

            System.Type stateType = null;
            foreach (System.Reflection.Assembly assembly in System.AppDomain.CurrentDomain.GetAssemblies())
            {
                foreach (System.Type t in assembly.GetTypes())
                    if (t.Name == stateTypeName) { stateType = t; break; }
                if (stateType != null) break;
            }

            if (stateType == null)
                return $"<color=red>State type '{stateTypeName}' not found.</color>";

            
            if (!typeof(State).IsAssignableFrom(stateType))
                return $"<color=red>'{stateTypeName}' exists but is not a State subclass.</color>";
            System.Reflection.MethodInfo method = sm.GetType().GetMethod("HasState");
            if (method != null)
            {
                bool hasState = (bool)method.Invoke(sm, new object[] { stateType });
                if (!hasState)
                    return $"<color=red>State '{stateTypeName}' is not registered in the StateMachine. " +
                           $"Add it with AddState() in Awake.</color>";
            }

            sm.SwitchState(stateType);
            return $"<color=#00FF88>State changed to '{stateTypeName}'</color>";
        }

        [ConsoleCommand("playername", "Sets the player GameObject name. Usage: playername <n>")]
        public static string SetPlayerName(string[] args)
        {
            if (args.Length == 0) return $"Current player name: '<color=#FFDD00>{playerName}</color>'";
            playerName = string.Join(" ", args);
            return $"<color=#00FF88>Player name set to '{playerName}'</color>";
        }

        [ConsoleCommand("addcoll", "Adds collectibles to the player. Usage: addcoll <amount>")]
        public static string AddCollectible(string[] args)
        {
            int amount = 1;

            if (args.Length > 0)
            {
                if (!int.TryParse(args[0], out amount) || amount <= 0)
                    return $"<color=red>Invalid amount '{args[0]}'. Must be a positive integer.</color>";
            }

            if (GameManager.Instance == null)
                return "<color=red>GameManager instance not found.</color>";

            for (int i = 0; i < amount; i++)
                GameManager.Instance.CollectStar(1);

            return $"<color=#00FF88>Added {amount} collectible{(amount > 1 ? "s" : "")}.</color>";
        }

    }
}
