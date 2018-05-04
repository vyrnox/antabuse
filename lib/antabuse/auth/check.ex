defmodule Antabuse.Auth.Check do

  alias Nostrum.Api

  alias Antabuse.DB.KV

  @prefix "!"

  @bot_id 439592034550939649

  def is_bot(user_id) do
    if user_id == @bot_id do true else false end
  end

  # find the mod role.
  def get_mod_role(guild, mod_role_name) do
    {guild_id, _} = Integer.parse(guild.id)
    guild_roles = Api.get_guild_roles!(guild_id)
    role = Enum.find guild_roles, fn role -> role.name() == mod_role_name end
    if role do role.id else nil end
  end

  def rule_exists(guild, member_id, target_id, command) do
    KV.guild_modrule_exists(guild, member_id, target_id, command)
  end

  # is this request coming from a valid mod channel?
  def valid_channel(guild, channel_id) do
    {guild_id, _} = Integer.parse(guild.id)
    guild_modchannel_id = KV.guild_fetch_modchannel(guild)
    if guild_modchannel_id do {guild_modchannel_id, _} = Integer.parse(guild_modchannel_id) end
    if channel_id == guild_modchannel_id do true else false end
  end

  def valid_command?(msg) do
    String.starts_with?(msg.content, @prefix)
  end

  def valid_superuser(guild, member_id) do
    {guild_owner_id, _} = Integer.parse(guild.owner_id())
    case member_id do
      229206717609541632 ->
        # ^ just for now, to debug.
        true
      ^guild_owner_id ->
        true
      _ ->
        false
    end
  end

  def valid_user(guild, member_id) do
    # yes, we can have a mod role but disallow bot use (lol!)
    guild_blacklist = KV.guild_fetch_blacklist(guild)
    blacklisted = Enum.find guild_blacklist, fn blisted -> blisted == member_id end
    if blacklisted do
      false
    else
      # What is the mod role id?
      {mod_role_id, _} = Integer.parse(KV.guild_fetch_mod_role(guild))
      {guild_id, _} = Integer.parse(guild.id)
      {:ok, member} = Api.get_guild_member(guild_id, member_id)
      member_roles = member.roles
      role = Enum.find member_roles, fn role_id -> role_id == mod_role_id end
      if role do true else false end
    end
  end

end
