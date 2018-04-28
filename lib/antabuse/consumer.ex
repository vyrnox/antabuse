defmodule Antabuse.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  @prefix "!"

  defp valid_command?(msg) do
    String.starts_with?(msg.content, @prefix)
  end

  defp execute(["!mute", username], msg, guild) do
    IO.puts "Got mute command: #{username}"
    {:ok, member} = Api.get_guild_member(guild.id, username)
    IO.puts "Got member: #{member.username} with role ID list: #{member.roles}"
    # Save user's role state.
    # Remove all user's roles.
    # Add mute role to user.
    # Deafen and mute the user.
    Api.create_message(msg.channel_id, content: "Muting, deafening and role smashing: #{username}")
  end

  defp execute(["!unmute", username], msg, guild) do
    IO.puts "Got unmute command: #{username}"
    # Restore user's role state and clear dictionary entry for user.
    # Remove mute role from user.
    # Undeafen and unmute the user.
    Api.create_message(msg.channel_id, content: "Unmuting, undeafening and role restoring: #{username}")
  end

  def handle_event({:READY, _, _w_state}) do
    now = DateTime.utc_now
    Api.update_status(:online, "you get rekt", 3)
    IO.puts("Antabuse ready at #{now.month}/#{now.day}/#{now.year} #{now.hour}:#{now.minute}:#{now.second}")
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    {:ok, channel} = Api.get_channel(msg.channel_id)
    {:ok, guild} = Api.get_guild(channel.guild_id)
    
    IO.puts "(#{guild.name}::#{channel.name}) #{msg.author.username}: #{msg.content}"

    if valid_command?(msg) do
      msg.content
      |> String.trim()
      |> String.split(" ")
      |> execute(msg, guild)
      IO.puts "Got: #{msg.content}"
    end

  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end

