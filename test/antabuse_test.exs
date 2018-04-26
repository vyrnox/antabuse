defmodule AbuseTest do
  use ExUnit.Case
  doctest Abuse

  test "greets the world" do
    assert Abuse.hello() == :world
  end
end
