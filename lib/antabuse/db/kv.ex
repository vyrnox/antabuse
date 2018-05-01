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

  def user_save_roles(guild, member) do
    IO.puts("Saving #{member.user.username}'s roles in #{guild.name}'.")
    roles = member.roles
    Redix.command(:redix, ["SET", "#{guild.id}:#{member.user.id}:roles", "test"])
    Redix.command(:redix, ["SET", "#{guild.id}:#{member.user.id}:roles", serialize(roles)])
  end

  def user_fetch_roles(guild, member) do
    IO.puts("Fetching #{member.user.username}'s roles in #{guild.name}'.")
    {:ok, role_data} = Redix.command(:redix, ["GET", "#{guild.id}:#{member.user.id}:roles"])
    deserialize(role_data)
  end

end
