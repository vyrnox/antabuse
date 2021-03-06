defmodule Antabuse.Command.User do
  alias Nostrum.Api
  alias Antabuse.Auth.Check
  alias Antabuse.DB.KV
  require Logger

  # find the mute role.
  def get_mute_role(guild) do
    {guild_id, _} = Integer.parse(guild.id)
    guild_roles = Api.get_guild_roles!(guild_id)
    role = Enum.find guild_roles, fn role -> role.name() == "muted" end
    role.id
  end

  def uncripple(guild, member) do
    r = KV.user_fetch_roles(guild, member)
    options = %{mute: false, deaf: false, roles: r}
    {guild_id, _} = Integer.parse(guild.id)
    Api.modify_guild_member(guild_id, member.user.id, options)
  end

  def cripple(guild, member, mute_role_id) do
    {guild_id, _} = Integer.parse(guild.id)
    # Api.add_guild_member_role(guild.id, member.id, mute_role_id)
    options = %{mute: true, deaf: true, roles: [mute_role_id]}
    Api.modify_guild_member(guild_id, member.user.id, options)
  end

  def execute(["!mute", username], msg, guild) do
    Logger.debug "Got mute command: #{username}"
    {user_id, _} = Integer.parse(String.replace(username, ~r/[^\d]/, ""))
    {guild_id, _} = Integer.parse(guild.id)
    {:ok, member} = Api.get_guild_member(guild_id, user_id)
    Logger.debug "Got member: #{member.user.username}"

    if ! Check.rule_exists(guild, msg.author.id, user_id, "!mute") do
      # Save user's role state.
      KV.user_save_roles(guild, member)

      mute_role_id = get_mute_role(guild)
      Logger.debug "Mute role id: #{mute_role_id}"

      # Remove all user's roles, mute and deafen
      cripple(guild, member, mute_role_id)

      Api.create_message(msg.channel_id, content: "Crippled: #{username}")
    else
      Api.create_message(msg.channel_id, content: "You're blocked from using that command on #{username}")
    end
  end

  def execute(["!unmute", username], msg, guild) do
    Logger.debug "Got unmute command: #{username}"
    {user_id, _} = Integer.parse(String.replace(username, ~r/[^\d]/, ""))
    {guild_id, _} = Integer.parse(guild.id)
    {:ok, member} = Api.get_guild_member(guild_id, user_id)

    if ! Check.rule_exists(guild, msg.author.id, user_id, "!unmute") do
      # Restore the user's roles, unmute and undeafen
      uncripple(guild, member)

      Api.create_message(msg.channel_id, content: "Restored: #{username}")
    else
      Api.create_message(msg.channel_id, content: "You're blocked from using that command on #{username}")
    end
  end

end
