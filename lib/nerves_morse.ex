defmodule NervesMorse do
  @moduledoc """
  Documentation for NervesMorse.
  """

  def to_morse(string) when is_binary(string) do
    string
    |> Morse.encode()
  end
end
