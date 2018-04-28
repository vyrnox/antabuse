defmodule AntabuseTest do
  use ExUnit.Case
  doctest Antabuse

  test "greets the world" do
    assert Antabuse.hello() == :world
  end
end
