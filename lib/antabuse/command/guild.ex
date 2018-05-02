defmodule Antabuse.Command.Guild do
  alias Nostrum.Api
  alias Antabuse.DB.KV

  # find the mod role.
  def get_mod_role(guild, mod_role_name) do
    {guild_id, _} = Integer.parse(guild.id)
    guild_roles = Api.get_guild_roles!(guild_id)
    role = Enum.find guild_roles, fn role -> role.name() == mod_role_name end
    if role do role.id else nil end
  end

  def execute(["!blacklist", username], msg, guild) do
    {user_id, _} = Integer.parse(String.replace(username, ~r/[^\d]/, ""))
    {guild_id, _} = Integer.parse(guild.id)
    {:ok, member} = Api.get_guild_member(guild_id, user_id)

    # add to blacklist
    KV.guild_add_blacklist(guild, member.user.id)

    Api.create_message(msg.channel_id, content: "Blacklisted #{username} from using this bot.")
  end

  def execute(["!whitelist", username], msg, guild) do
    {user_id, _} = Integer.parse(String.replace(username, ~r/[^\d]/, ""))
    {guild_id, _} = Integer.parse(guild.id)
    {:ok, member} = Api.get_guild_member(guild_id, user_id)
    IO.puts "Got member: #{member.user.username}"

    # add to blacklist
    KV.guild_remove_blacklist(guild, member.user.id)

    Api.create_message(msg.channel_id, content: "Whitelisted #{username} on this bot.")
  end

  def execute(["!modon", rolename], msg, guild) do
    mod_role_id = get_mod_role(guild, rolename)
    IO.puts "Mod role id: #{mod_role_id}"

    # Set the mod role.
    KV.guild_set_mod_role(guild, mod_role_id)

    Api.create_message(msg.channel_id, content: "Now accepting mod commands for users with role: #{rolename}")
  end

  def execute(["!modoff"], msg, guild) do
    KV.guild_set_mod_role(guild, nil)

    Api.create_message(msg.channel_id, content: "Not accepting commands from any role for moderation.")
  end

end
