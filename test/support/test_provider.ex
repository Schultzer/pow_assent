defmodule TestProvider do
  @moduledoc false
  use PowAssent.Strategy

  alias PowAssent.Strategy.OAuth2, as: OAuth2Helper

  def authorize_url(config, conn) do
    config
    |> set_config()
    |> OAuth2Helper.authorize_url(conn)
  end

  def callback(config, conn, params) do
    config = set_config(config)

    config
    |> OAuth2Helper.callback(conn, params)
    |> normalize()
  end

  defp set_config(config) do
    [
      site: "http://localhost:4000/",
      authorize_url: "/oauth/authorize",
      token_url: "/oauth/token",
      user_url: "/api/user"
    ]
    |> Keyword.merge(config)
    |> Keyword.put(:strategy, OAuth2.Strategy.AuthCode)
  end

  defp normalize({:ok, %{conn: conn, client: client, user: user}}) do
    user = %{"uid"      => user["uid"],
             "name"     => user["name"],
             "email"    => user["email"]} |> Helpers.prune()

    {:ok, %{conn: conn, client: client, user: user}}
  end
  defp normalize({:error, error}), do: {:error, error}
end