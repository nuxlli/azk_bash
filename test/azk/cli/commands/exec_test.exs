defmodule Azk.Cli.Commands.Exec.Test do
  use Azk.TestCase

  alias Azk.Cli.Commands.Exec
  alias Azk.Deployers.Bindfs

  setup_all do
    app = Azk.Cli.AzkApp.new(fixture_path(:full_azkfile)).load!
    {:ok, app: app}
  end

  test "deploy application", var do
    app = var[:app]
    _out = capture_io fn ->
      Exec.run(app.path, [])
    end
  end
end
