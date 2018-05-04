defmodule Antabuse.DB.SB do
  defstruct value: nil
end

defmodule Antabuse.DB.KV do

  def serialize(data) do
    struct = %Antabuse.DB.SB{value: data}
    :erlang.term_to_binary(struct)
  end

  def deserialize(data) do
    struct = :erlang.binary_to_term(data)
    struct.value
  end

  # Being lazy here with a flat structure for mod rules.  We could alternatively
  # nest a structure of members with targets and rules, which would make clearing
  # easier.

  def guild_modrule_exists(guild, member_id, target_id, rule) do
    IO.puts("Checking rule: #{rule} from #{member_id} to #{target_id} on #{guild.name}.")
    {:ok, modrule_data} = Redix.command(:redix, ["GET", "#{guild.id}:modrules:#{member_id}:#{target_id}"])
    modrule_data = if modrule_data do deserialize(modrule_data) else [] end
    if Enum.find modrule_data, fn mod_rule -> mod_rule == rule end do true else false end
  end

  def guild_add_modrule(guild, member_id, target_id, rule) do
    IO.puts("Adding rule: #{rule} from #{member_id} to #{target_id} on #{guild.name}.")
    {:ok, modrule_data} = Redix.command(:redix, ["GET", "#{guild.id}:modrules:#{member_id}:#{target_id}"])
    modrule_data = if modrule_data do deserialize(modrule_data) else [] end
    if ! Enum.find modrule_data, fn mod_rule -> mod_rule == rule end do
      modrule_data = modrule_data ++ [rule]
      Redix.command(:redix, ["SET", "#{guild.id}:modrules:#{member_id}:#{target_id}", serialize(modrule_data)])
    end
  end

  def guild_remove_modrule(guild, member_id, target_id, rule) do
    {:ok, modrule_data} = Redix.command(:redix, ["GET", "#{guild.id}:modrules:#{member_id}:#{target_id}"])
    modrule_data = if modrule_data do deserialize(modrule_data) else [] end
    if Enum.find modrule_data, fn mod_rule -> mod_rule == rule end do
      modrule_data = List.delete(modrule_data, rule)
      Redix.command(:redix, ["SET", "#{guild.id}:modrules:#{member_id}:#{target_id}", serialize(modrule_data)])
    end
  end

  def guild_fetch_modchannel(guild) do
    IO.puts("Fetching #{guild.name}'s modchan.")
    {:ok, modchan} = Redix.command(:redix, ["GET", "#{guild.id}:modchan"])
    modchan
  end

  def guild_set_modchannel(guild, channel_id) do
    IO.puts("Setting #{guild.name}'s modchan to #{channel_id}.")
    {:ok, modchan} = Redix.command(:redix, ["SET", "#{guild.id}:modchan", "#{channel_id}"])
    modchan
  end

  def guild_fetch_blacklist(guild) do
    IO.puts("Fetching #{guild.name}'s blacklist.")
    {:ok, blist_data} = Redix.command(:redix, ["GET", "#{guild.id}:blacklist"])
    deserialize(blist_data)
  end

  def guild_add_blacklist(guild, member_id) do
    IO.puts("Adding #{member_id} to #{guild.name}'s blacklist.")
    {:ok, blist_data} = Redix.command(:redix, ["GET", "#{guild.id}:blacklist"])
    blist_data = if blist_data do deserialize(blist_data) else [] end
    if ! Enum.find blist_data, fn member -> member == member_id end do
      blist_data = blist_data ++ [member_id]
      Redix.command(:redix, ["SET", "#{guild.id}:blacklist", serialize(blist_data)])
    end
  end

  def guild_remove_blacklist(guild, member_id) do
    {:ok, blist_data} = Redix.command(:redix, ["GET", "#{guild.id}:blacklist"])
    blist_data = if blist_data do deserialize(blist_data) else [] end
    if Enum.find blist_data, fn member -> member == member_id end do
      blist_data = List.delete(blist_data, member_id)
      Redix.command(:redix, ["SET", "#{guild.id}:blacklist", serialize(blist_data)])
    end
  end

  def guild_clear_blacklist(guild) do
    Redix.command(:redix, ["SET", "#{guild.id}:blacklist", nil])
  end

  def guild_fetch_mod_role(guild) do
    IO.puts("Fetching #{guild.name}'s mod role.")
    {:ok, role_data} = Redix.command(:redix, ["GET", "#{guild.id}:mod_role_id"])
    role_data
  end

  def guild_set_mod_role(guild, role_id) do
    IO.puts("Setting #{guild.name}'s mod role.")
    Redix.command(:redix, ["SET", "#{guild.id}:mod_role_id", role_id])
  end

  def user_save_roles(guild, member) do
    roles = member.roles
    Redix.command(:redix, ["SET", "#{guild.id}:#{member.user.id}:roles", serialize(roles)])
  end

  def user_fetch_roles(guild, member) do
    {:ok, role_data} = Redix.command(:redix, ["GET", "#{guild.id}:#{member.user.id}:roles"])
    deserialize(role_data)
  end

end
