defmodule Antabuse.Event.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Antabuse.Command.Dispatch

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _, _w_state}) do
    IO.puts "In ready handle event"
    now = DateTime.utc_now
    Api.update_status(:online, "you debug", 3)
    IO.puts("Antabuse ready at #{now.month}/#{now.day}/#{now.year} #{now.hour}:#{now.minute}:#{now.second}")
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    {:ok, channel} = Api.get_channel(msg.channel_id)
    {:ok, guild} = Api.get_guild(channel.guild_id)
    # debugging;
    IO.puts "(#{guild.name}::#{channel.name}) #{msg.author.username}: #{msg.content}"
    Dispatch.handle_command(msg, guild)
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end

