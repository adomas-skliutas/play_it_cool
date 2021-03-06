defmodule PlayItCoolWeb.OAuth.Google do
  @moduledoc """
  This is Google OAuth2 strategy. WIP
  """

  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  def client do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: "",
      client_secret: "",
      redirect_uri: "http://localhost:4000/auth/google/callback",
      site: "https://accounts.google.com",
      authorize_url: "https://accounts.google.com/o/oauth2/auth",
      token_url: "https://accounts.google.com/o/oauth2/token"
    )
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], _headers \\ []) do
    OAuth2.Client.get_token!(
      client(),
      Keyword.merge(params, client_secret: client().client_secret)
    )
  end

  # strategy callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
