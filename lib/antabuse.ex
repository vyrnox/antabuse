defmodule AbuseProducer do
  def start_link do
    import Supervisor.Spec

    children = [AbuseConsumer]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule AbuseConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    case msg.content do
      "!mute" ->
        Api.create_message(msg.channel_id, "Stub for !mute")
        # Save user's role state.
        # Remove all user's roles.
        # Add mute role to user.
        # Deafen and mute the user.

      "!unmute" ->
        Api.create_message(msg.channel_id, "Stub for !unmute")
        # Restore user's role state and clear dictionary entry for user.
        # Remove mute role from user.
        # Undeafen and unmute the user.

      _ ->
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end

