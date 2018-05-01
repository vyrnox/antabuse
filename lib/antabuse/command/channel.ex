defmodule Antabuse.Command.Channel do
  alias Nostrum.Api

  def execute(["!clear", channel], message, guild) do
    IO.puts "Going to clear: #{channel}"
    {channel_id, _} = Integer.parse(String.replace(channel, ~r/[^\d]/, ""))
    ckm_task = Task.async fn ->
      Api.get_channel_messages!(channel_id, :infinity, {})
    end

    evidence = Task.await ckm_task

    Enum.each evidence, fn message ->
      IO.puts "> #{message.author} #{message.content} #{message.id}"
      Api.delete_message(channel_id, message.id)
    end
  end

end
