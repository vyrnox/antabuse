defmodule Antabuse.Command.Guild do
  alias Nostrum.Api
  alias Antabuse.DB.KV
  alias Antabuse.Auth.Check


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

  def execute(["!modrule", rule, from_user, to_user], msg, guild) do
    {member_id, _} = Integer.parse(String.replace(from_user, ~r/[^\d]/, ""))
    {target_id, _} = Integer.parse(String.replace(to_user, ~r/[^\d]/, ""))

    if Check.valid_superuser(guild, msg.author.id) do
      KV.guild_add_modrule(guild, member_id, target_id, rule)
      Api.create_message(msg.channel_id, content: "Added #{rule} block from #{from_user} to #{to_user}.")
    else
      Api.create_message(msg.channel_id, content: "You can't use this command.")
    end
  end

  def execute(["!modrule", rule, from_user, to_user, pass], msg, guild) do
    if pass == "pass" do
      {member_id, _} = Integer.parse(String.replace(from_user, ~r/[^\d]/, ""))
      {target_id, _} = Integer.parse(String.replace(to_user, ~r/[^\d]/, ""))

      if Check.valid_superuser(guild, msg.author.id) do
        KV.guild_remove_modrule(guild, member_id, target_id, rule)
        Api.create_message(msg.channel_id, content: "Removed #{rule} block from #{from_user} to #{to_user}.")
      else
        Api.create_message(msg.channel_id, content: "You can't use this command.")
      end
    end
  end

  def execute(["!modchan", modchannel], msg, guild) do
    {channel_id, _} = Integer.parse(String.replace(modchannel, ~r/[^\d]/, ""))

    # Set the mod channel
    KV.guild_set_modchannel(guild, channel_id)

    Api.create_message(msg.channel_id, content: "Now accepting mod commands from moderators in channel: #{modchannel}")
  end

  def execute(["!modon", rolename], msg, guild) do
    mod_role_id = Check.get_mod_role(guild, rolename)
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
