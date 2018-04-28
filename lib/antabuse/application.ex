defmodule Antabuse.Application do
  @moduledoc false

  use Application

  alias Antabuse.Consumer

  def start(_type, _args) do
    import Supervisor.Spec

    children = [Consumer]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
