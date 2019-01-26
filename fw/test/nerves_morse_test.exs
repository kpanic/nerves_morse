defmodule NervesMorseTest do
  use ExUnit.Case
  doctest NervesMorse

  test "greets the world" do
    assert NervesMorse.hello() == :world
  end
end
