defmodule UiWeb.MorseController do
  require Logger
  use UiWeb, :controller

  # action_fallback(castrWeb.FallbackController)

  def encode(conn, %{"string" => string}) do
    with :ok <- NervesMorse.Worker.encode(string) do
      conn
      |> put_status(202)
      |> json(%{status: "morse encoding started"})
    else
      {:error, :already_in_progress} ->
        conn
        |> put_status(429)
        |> json(%{
          status: "morse encoding in progress, the led can serve only one request at a time ;)"
        })
    end
  end
end
