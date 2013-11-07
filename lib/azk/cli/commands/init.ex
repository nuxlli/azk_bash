defmodule Azk.Cli.Commands.Init do
  use Azk.Cli.Command

  @shortdoc "Create a azkfile.json"

  def run(app_path, _argv) do
    IO.puts("#{:uuid.to_string(:uuid.uuid3(:uuid.uuid4, app_path))}")
  end
end
