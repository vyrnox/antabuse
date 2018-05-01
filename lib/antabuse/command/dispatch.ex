defmodule Antabuse.Command.Dispatch do
  alias Antabuse.Command.{Channel, User, Util}

  def handle_command(message, guild) do
    # debugging
    IO.puts "Got: #{message.content}"

    # Ensure the user on the guild is not the bot and
    # authorized to issue commands.
    if Util.valid_user?(guild.id, message.author.id) do
      IO.puts "Valid user."

      # Ensure the command is valid.
      if Util.valid_command?(message) do
        IO.puts "Valid command."
        message_content = String.trim(message.content)
        message_content = String.split(message_content, " ")

        # Get the command type for execution.
        command_type = Util.get_command_type(Enum.at(message_content, 0))
        case command_type do
          "channel" ->
            IO.puts "Using channel command handler: #{Enum.at(message_content, 0)} #{Enum.at(message_content, 1)}"
            Channel.execute(message_content, message, guild)
          "user" ->
            IO.puts "Using user command handler: #{Enum.at(message_content, 0)} #{Enum.at(message_content, 1)}"
            User.execute(message_content, message, guild)
          _ -> ""
        end

      end

    end

  end

end
