defmodule Azk.Cli.Command do
  use Behaviour
  alias Azk.Cli.Utils

  @moduledoc """
  A simple module that provides conveniences for creating,
  loading and manipulating commands.
  """

  @doc """
  A command needs to implement `run` which receives
  a list of command line args.
  """
  defcallback run(Keyword.t, [binary]) :: any

  @doc false
  defmacro __using__(_opts) do
    quote do
      alias Azk.Cli.Utils
      alias Azk.Cli.AzkApp

      Enum.each [:shortdoc],
        &(Module.register_attribute(__MODULE__, &1, persist: true))

      @behaviour Azk.Cli.Command
    end
  end

  @doc """
  Loads all commands in all code paths.
  """
  def load_all, do: load_commands(:code.get_path)

  @doc """
  Loads all commands in the given `paths`.
  """
  def load_commands(paths) do
    Enum.reduce(paths, [], fn(path, matches) ->
      { :ok, files } = :erl_prim_loader.list_dir(path |> :unicode.characters_to_list)
      Enum.reduce(files, matches, &(match_commands(&1, &2)))
    end)
  end

  defp match_commands(file_name, modules) do
    if Regex.match?(%r/Elixir\.Azk\.Cli\.Commands\..*\.beam/, file_name) do
      mod = Path.rootname(file_name, '.beam') |> list_to_atom
      if Code.ensure_loaded?(mod), do: [mod | modules], else: modules
    else
      modules
    end
  end

  @doc """
  Receives a command name and retrieves the command module.

  ## Exceptions

  * `Azk.Cli.NoCommandError` - raised if the command could not be found;
  * `Azk.Cli.InvalidCommandError` - raised if the command is not a valid `Azk.Cli.Command`
  """
  def get(command) do
    case Mix.Utils.command_to_module(command, Azk.Cli.Commands) do
      { :module, module } ->
        if is_command?(module) do
          module
        else
          raise Azk.Cli.InvalidCommandError, command: command
        end
      { :error, _ } ->
        raise Azk.Cli.NoCommandError, command: command
    end
  end

  @doc """
  Runs a `command` with the given `args`.

  It may raise an exception if the command was not found
  or it is invalid. Check `get/1` for more information.
  """
  def run(command, args // []) do
    module = get("#{command}")
    module.run(System.cwd!, args)
  end

  @doc """
  Returns all loaded tasks. Modules that are not yet loaded
  won't show up. Check `load_all/0` if you want to preload all commands.
  """
  def all_modules do
    Enum.reduce :code.all_loaded, [], fn({ module, _ }, acc) ->
      case atom_to_list(module) do
        'Elixir.Azk.Cli.Commands.' ++ _ ->
          if is_command?(module), do: [module|acc], else: acc
        _ ->
          acc
      end
    end
  end

  @doc """
  Gets the moduledoc for the given command `module`.
  Returns the moduledoc or `nil`.
  """
  def moduledoc(module) when is_atom(module) do
    case module.__info__(:moduledoc) do
      { _line, moduledoc } -> moduledoc
      nil -> nil
    end
  end

  @doc """
  Gets the shortdoc for the given command `module`.
  Returns the shortdoc or `nil`.
  """
  def shortdoc(module) when is_atom(module) do
    case List.keyfind module.__info__(:attributes), :shortdoc, 0 do
      { :shortdoc, [shortdoc] } -> shortdoc
      _ -> nil
    end
  end

  @doc """
  Returns the task name for the given `module`.
  """
  def command_name(module) do
    Mix.Utils.module_name_to_command(module, 2)
  end

  defp is_command?(module) do
    function_exported?(module, :run, 2)
  end
end
