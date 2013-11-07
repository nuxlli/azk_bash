defmodule Azk.Cli.Commands.Info do
  use Azk.Cli.Command

  @shortdoc "Show information about azk application"

  def run(app_path, _argv) do
    app = AzkApp.new(app_path).load!
    IO.inspect(app)
  end
end
