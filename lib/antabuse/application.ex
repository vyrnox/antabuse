defmodule Antabuse.Application do
  @moduledoc false

  use Application
  alias Antabuse.Event.Consumer
  require Logger

  def start(_type, _args) do
    Logger.debug "We have #{System.schedulers_online()} schedulers online in the VM."

    import Supervisor.Spec, warn: false

    children = [
      Consumer,
      {Redix, [[], [name: :redix]]}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

end
