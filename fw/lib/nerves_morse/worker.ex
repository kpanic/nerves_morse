defmodule NervesMorse.Worker do
  @moduledoc """
  Simple example to blink my nickname in morse code
  """
  use GenServer

  @string "beatpanic"

  @long_blink_on 2_000
  @blink_on 1_000
  @default_off_duration 1_000
  @off_duration 2_000

  @led_name "led0"

  @wait_for_morse_boot 3

  require Logger

  alias Nerves.Leds

  # Client API
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  # Server callbacks
  def init(state) do
    {:ok, state, {:continue, :encode}}
  end

  def handle_continue(:encode, state) do
    wait_before_morse(@led_name)


    @string
    |> NervesMorse.to_morse()
    |> String.codepoints()
    |> Enum.each(fn morse_char ->
      interpret_morse(morse_char)
      |> led_set()
    end)

    Leds.set([{@led_name, false}])

    {:noreply, state}
  end

  defp wait_before_morse(led_key) do
    for _num <- 0..@wait_for_morse_boot do
      Leds.set([{led_key, true}])
      :timer.sleep(5_000)
      Leds.set([{led_key, false}])
      :timer.sleep(1_000)
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
    IO.inspect("NOT SUPPORTED #{unsupported}")
  end

  defp led_set({on_duration, off_duration}) do
    Leds.set([{@led_name, true}])
    :timer.sleep(on_duration)

    Leds.set([{@led_name, false}])
    :timer.sleep(off_duration)
  end
end
