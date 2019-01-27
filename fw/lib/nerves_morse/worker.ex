defmodule NervesMorse.Worker do
  @moduledoc """
  Simple example to blink a string in morse code

  Usage:

  :ok = NervesMorse.Worker.encode("beatpanic")
  {:error, :already_in_progress} = NervesMorse.Worker.encode("beatpanic")
  """

  use GenServer
  require Logger

  @ets_name :nerves_morse_table

  @long_blink_on 2_000
  @blink_on 1_000
  @default_off_duration 1_000
  @off_duration 2_000

  @led_name "led0"

  require Logger

  alias Nerves.Leds

  # Client API
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  # Server callbacks
  def init(_state) do
    :ets.new(@ets_name, [:named_table, :public])
    {:ok, [], {:continue, :led_turn_off}}
  end

  def encode(string) when is_binary(string) do
    case in_progress?() do
      false ->
        GenServer.cast(__MODULE__, {:encode, string})

      true ->
        {:error, :already_in_progress}
    end
  end

  def handle_continue(:led_turn_off, state) do
    Leds.set([{@led_name, false}])
    {:noreply, state}
  end

  def handle_cast({:encode, string}, state) do
    Logger.info("started blinking")

    string
    |> NervesMorse.to_morse()
    |> String.codepoints()
    |> Enum.each(fn morse_char ->
      interpret_morse(morse_char)
      |> led_set()
    end)

    Leds.set([{@led_name, false}])

    :ets.delete(:nerves_morse_table, "in_progress")

    {:noreply, state}
  end

  defp in_progress?() do
    case :ets.lookup(@ets_name, "in_progress") do
      [] ->
        :ets.insert(@ets_name, {"in_progress", true})
        false

      _ ->
        true
    end
  end

  def interpret_morse("-") do
    {@long_blink_on, @default_off_duration}
  end

  def interpret_morse(".") do
    {@blink_on, @default_off_duration}
  end

  def interpret_morse(" ") do
    {@default_off_duration, @off_duration}
  end

  def interpret_morse(unsupported) do
    Logger.info("NOT SUPPORTED #{inspect(unsupported)}")
  end

  defp led_set({on_duration, off_duration}) do
    Leds.set([{@led_name, true}])
    :timer.sleep(on_duration)

    Leds.set([{@led_name, false}])
    :timer.sleep(off_duration)
  end
end
