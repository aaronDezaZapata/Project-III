using System;

namespace TorbellinoConsoleSystem
{
    /// <summary>
    /// Attribute to mark static methods as console commands.
    /// The method will be automatically registered when TorbellinoConsole initializes.
    /// </summary>
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false)]
    public class ConsoleCommandAttribute : Attribute
    {
        public string CommandName { get; set; }
        public string Description { get; set; }

        /// <summary>
        /// Marks a method as a TorbellinoConsole command.
        /// </summary>
        /// <param name="commandName">The name to use in the console (defaults to method name)</param>
        /// <param name="description">Description shown in help command</param>
        public ConsoleCommandAttribute(string commandName = "", string description = "")
        {
            CommandName = commandName;
            Description = description;
        }
    }
}
