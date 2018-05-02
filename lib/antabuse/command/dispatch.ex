defmodule Antabuse.Command.Dispatch do

  alias Antabuse.Command.{Channel, Guild, User, Util}
  alias Antabuse.Auth.Check

  def handle_command(message, guild) do
    # debugging
    IO.puts "Got: #{message.content}"

    # Ensure the user on the guild is not the bot and
    # authorized to issue commands.
    if Check.valid_user?(guild, message.author.id) do
      # Ensure the command is valid.
      if Check.valid_command?(message) do
        message_content = String.trim(message.content)
        message_content = String.split(message_content, " ")

        # Get the command type for execution.
        command_type = Util.get_command_type(Enum.at(message_content, 0))
        case command_type do
          "channel" ->
            Channel.execute(message_content, message, guild)
          "user" ->
            User.execute(message_content, message, guild)
          "guild" ->
            Guild.execute(message_content, message, guild)
          _ -> ""
        end

      end

    end

  end

end
