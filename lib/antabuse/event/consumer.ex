defmodule Antabuse.Event.Consumer do
  use Nostrum.Consumer
  require Logger

  alias Nostrum.Api
  alias Antabuse.Command.Dispatch

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _, _w_state}) do
    now = DateTime.utc_now
    Api.update_status(:online, "you debug", 3)
    Logger.info "Antabuse ready at #{now.month}/#{now.day}/#{now.year} #{now.hour}:#{now.minute}:#{now.second}"
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    {:ok, channel} = Api.get_channel(msg.channel_id)
    # handle DMs
    if channel.guild_id do
      {:ok, guild} = Api.get_guild(channel.guild_id)
      Logger.debug "(#{guild.name}::#{channel.name}) #{msg.author.username}: #{msg.content}"
      Dispatch.handle_command(msg, guild)
    else
      Logger.debug "DM: #{msg.author.username}: #{msg.content}"
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
