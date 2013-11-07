defmodule Azk.Cli.Commands.Exec do
  use Azk.Cli.Command

  @shortdoc "Execute a single command in application context"

  @moduledoc """
  Execute a single command in application context.

  If the `image-app` is not provisioned, run a provision before.

  Examples:
      $ azk exec npm install
  """
  def run(app_path, _argv) do
    _app = AzkApp.new(path: app_path).load!
  end
end

