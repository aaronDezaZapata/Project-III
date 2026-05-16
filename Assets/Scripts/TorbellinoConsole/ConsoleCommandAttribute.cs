using System;

namespace TorbellinoConsoleSystem
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false)]
    public class ConsoleCommandAttribute : Attribute
    {
        public string CommandName { get; set; }
        public string Description { get; set; }

        public ConsoleCommandAttribute(string commandName = "", string description = "")
        {
            CommandName = commandName;
            Description = description;
        }
    }
}
