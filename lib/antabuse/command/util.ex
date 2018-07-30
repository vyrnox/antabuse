defmodule Antabuse.Command.Util do

  # create a command array for dispatcher.
  def get_command_type(command) do
    IO.puts "Got command: #{command}"

    # Associate commands with categories for different modules:
    case command do
      "!clear" -> "channel"
      "!mute" -> "user"
      "!unmute" -> "user"
      "!modon" -> "guild"
      "!modoff" -> "guild"
      "!blacklist" -> "guild"
      "!whitelist" -> "guild"
      "!modrule" -> "guild"
      "!modchan" -> "guild"
      "!backup" -> "guild"
      "!restore" -> "guild"
      _ -> "bad"
    end
  end

end
