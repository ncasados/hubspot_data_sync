defmodule HubspotDataSync.HubspotClient do
  @base_url "https://api.hubapi.com"

  def retrieve_contacts(params \\ []) do
    case check_hammer_ratelimit() do
      {:allow, _count} ->
        Tesla.get(client(), "/crm/v3/objects/contacts", query: params)
        |> process_response()

      {:deny, retry_after} ->
        {:error, {:rate_limit, "try again in #{retry_after}ms"}}
    end
  end

  defp process_response({:ok, %Tesla.Env{status: status, body: body}}) when status not in 200..299 do
    {:error, body}
  end

  defp process_response({:ok, %Tesla.Env{body: body}}) do
    {:ok, body}
  end

  defp check_hammer_ratelimit() do
    HubspotDataSync.HubspotRatelimit.hit(hubspot_token(), :timer.seconds(10), 100)
  end

  defp client() do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.BearerAuth, token: hubspot_token()},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ])
  end

  defp hubspot_token() do
    Application.get_env(:hubspot_data_sync, :hubspot_token)
  end
end
