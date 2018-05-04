defmodule Antabuse.Command.Dispatch do

  alias Antabuse.Command.{Channel, Guild, User, Util}
  alias Antabuse.Auth.Check


  def dispatch_command(message, guild) do
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

  def handle_command(message, guild) do
    # debugging
    IO.puts "Got: #{message.author.id} : #{message.content}"

    if ! Check.is_bot(message.author.id) do
      # if owner and valid command, dispatch
      if Check.valid_superuser(guild, message.author.id) do
        if Check.valid_command?(message) do
          dispatch_command(message, guild)
        end
      else
        # otherwise, ensure valid channel as well.
        if Check.valid_user(guild, message.author.id) do
          # Ensure the command is valid.
          if Check.valid_channel(guild, message.channel_id) do
            if Check.valid_command?(message) do
              dispatch_command(message, guild)
            end
          end
        end
      end
    end

  end

end
