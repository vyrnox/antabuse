defmodule Antabuse.Auth.Check do

  alias Nostrum.Api

  alias Antabuse.DB.KV

  @prefix "!"

  def valid_command?(msg) do
    String.starts_with?(msg.content, @prefix)
  end

  def valid_user?(guild, member_id) do
    {guild_owner_id, _} = Integer.parse(guild.owner_id())
    case member_id do
      229206717609541632 ->
        # ^ just for now, to debug.
        true
      ^guild_owner_id ->
        true
      _ ->
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

end
