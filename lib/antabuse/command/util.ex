defmodule Antabuse.Command.Util do

  @prefix "!"

  def valid_command?(msg) do
    String.starts_with?(msg.content, @prefix)
  end

  def valid_user?(guild, sender) do
    true
  end

  # create a command array for dispatcher.

  def get_command_type(command) do
    IO.puts "Got command: #{command}"
    case command do
      "!clear" -> "channel"
      "!mute" -> "user"
      "!unmute" -> "user"
      _ -> "bad"
    end
  end

end

