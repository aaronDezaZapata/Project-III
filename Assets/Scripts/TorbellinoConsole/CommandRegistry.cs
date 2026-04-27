using System;
using System.Collections.Generic;
using System.Linq;

namespace TorbellinoConsoleSystem
{
    public class CommandRegistry
    {
        private Dictionary<string, CommandInfo> commands = new Dictionary<string, CommandInfo>();

        public void Register(string name, string description, Func<string[], string> action)
        {
            string key = name.ToLower();

            commands[key] = new CommandInfo
            {
                Name        = name,
                Description = description,
                Action      = action
            };
        }

        public bool TryExecute(string commandName, string[] args, out string result)
        {
            string key = commandName.ToLower();

            if (commands.TryGetValue(key, out CommandInfo command))
            {
                try
                {
                    result = command.Action(args);
                    return true;
                }
                catch (Exception e)
                {
                    result = $"Error executing command '{commandName}': {e.Message}";
                    return true;
                }
            }

            result = null;
            return false;
        }

        public List<string> GetSuggestions(string input)
        {
            string lowerInput = input.ToLower();
            return commands.Keys
                .Where(cmd => cmd.StartsWith(lowerInput))
                .OrderBy(cmd => cmd)
                .ToList();
        }

        public List<CommandInfo> GetAllCommands() => commands.Values.ToList();

        public bool HasCommand(string name) => commands.ContainsKey(name.ToLower());

        public void Unregister(string name) => commands.Remove(name.ToLower());

        public void Clear() => commands.Clear();
    }

    public class CommandInfo
    {
        public string Name        { get; set; }
        public string Description { get; set; }
        public Func<string[], string> Action { get; set; }
    }
}
