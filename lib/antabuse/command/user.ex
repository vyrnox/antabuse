defmodule Antabuse.Command.User do
  alias Nostrum.Api

  def execute(["!mute", username], msg, guild) do
    IO.puts "Got mute command: #{username}"
    {user_id, _} = Integer.parse(String.replace(username, ~r/[^\d]/, ""))
    {guild_id, _} = Integer.parse(guild.id)
    {:ok, member} = Api.get_guild_member(guild_id, user_id)
    IO.puts "Got member: #{member.user.username}"
    # Save user's role state.
    roles = member.roles
    # Remove all user's roles.
    # Add mute role to user.
    # Deafen and mute the user.
    Api.create_message(msg.channel_id, content: "Muting, deafening and role smashing: #{username}")
  end

  def execute(["!unmute", username], msg, guild) do
    IO.puts "Got unmute command: #{username}"
    # Restore user's role state and clear dictionary entry for user.
    # Remove mute role from user.
    # Undeafen and unmute the user.
    Api.create_message(msg.channel_id, content: "Unmuting, undeafening and role restoring: #{username}")
  end

end

