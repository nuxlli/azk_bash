defmodule Azk.Cli.Commands.Help do
  use Azk.Cli.Command

  @shortdoc "Print help information for command"

  @moduledoc """
  If given a command name, prints the documentation for that command.
  If no command name is given, prints the short form documentation
  for all commands.

  ## Arguments

      azk help      - prints all commands and their shortdoc
      azk help TASK - prints full docs for the given command
  """
  def run(path, []) do
    Azk.Cli.Command.load_all

    modules = Azk.Cli.Command.all_modules

    docs = lc module inlist modules,
        doc = Azk.Cli.Command.shortdoc(module) do
      { Azk.Cli.Command.command_name(module), doc }
    end

    lc doc inlist docs do
      {name, short} = doc
      IO.puts IO.ANSI.escape("%{bright}#{name}%{reset} — #{short}")
    end

    nil
  end

  def run(path, argv) do
    [command | _] = argv

    IO.puts IO.ANSI.escape "%{bright}help --%{reset}"

    module = Azk.Cli.Command.get(command)
    IO.puts IO.ANSI.escape "%{bright}# azk help #{command}%{reset}\n"

    if doc = Azk.Cli.Command.moduledoc(module) do
      IO.puts IO.ANSI.escape doc
    else
      IO.puts "There is no documentation for this command"
    end

    IO.puts "Location: #{where_is_file(module)}"
  end

  defp where_is_file(module) do
    case :code.where_is_file(atom_to_list(module) ++ '.beam') do
      :non_existing -> "not available"
      location -> Path.expand(Path.dirname(location))
    end
  end

end

