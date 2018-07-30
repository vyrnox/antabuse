defmodule GuildBucket do
  defstruct [:roles, :channels, :members]
end

defmodule Antabuse.Command.Guild do
  alias Nostrum.Api
  alias Antabuse.DB.KV
  alias Antabuse.Auth.Check
  require Logger


  def execute(["!restore", uuid], msg, guild) do
  {guild_id, _} = Integer.parse(guild.id)

  if Check.valid_superuser(guild, msg.author.id) do
    Logger.debug "Got valid restore command from a super user."

    guild_backup = KV.guild_fetch_backup(uuid)
    Logger.debug "Got backup: #{inspect(guild_backup)}"

    members = guild_backup.members
    roles = guild_backup.roles
    channels = guild_backup.channels

    # Clear existing roles
    # Add new roles
    # Clear existing channels
    # Add new channels
    # apply roles to channels
    # apply roles to existing members per old member permissions

    else
      Api.create_message(msg.channel_id, content: "You can't use this command.")
    end
  end

  def execute(["!backup"], msg, guild) do
    {guild_id, _} = Integer.parse(guild.id)

    if Check.valid_superuser(guild, msg.author.id) do
      Logger.debug "Got valid backup command from a super user."

      uuid = UUID.uuid1()

      Logger.debug "Using uuid: #{uuid} ---"

      {:ok, roles} = Api.get_guild_roles(guild_id)
      {:ok, channels} = Api.get_guild_channels(guild_id)
      {:ok, members} = Api.list_guild_members(guild_id, limit: 1000)

      backup = %GuildBucket{roles: roles, channels: channels, members: members}
      KV.guild_set_backup(uuid, backup)


      # get pinned messages per channel ...
      # Enum.each channels, fn channel ->
      #   IO.puts "> #{channel.name} #{channel.id}"
      #
      #   pin_task = Task.async fn ->
      #     {:ok, pinned_messages} = Api.get_pinned_messages(channel.id)
      #     pinned_messages
      #   end
      #   pinned_messages = Task.await pin_task
      #   KV.guild_backup_pinned_messages(uuid, channel.name, pinned_messages)
      # end

      # let the user know it's done!
      {:ok, dm_channel} = Api.create_dm(msg.author.id)
      Api.create_message(dm_channel.id, content: "Done!  UUID: #{uuid}")
    else
      Api.create_message(msg.channel_id, content: "You can't use this command.")
    end
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
