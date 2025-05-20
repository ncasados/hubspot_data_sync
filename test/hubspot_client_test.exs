defmodule HubspotDataSync.HubspotClientTest do
  alias HubspotDataSync.HubspotRatelimit
  alias HubspotDataSync.HubspotClient

  use ExUnit.Case, async: true
  use Mimic

  describe "retrieve_contacts/1" do
    test "can retrieve contacts" do
      Tesla
      |> expect(:get, fn _client, _url, _options ->
        {:ok,
         %Tesla.Env{
           status: 200,
           body:
             JSON.encode!(%{
               "results" => [%{"id" => "123456789", "properties" => %{}}]
             })
         }}
      end)

      assert {:ok, json_string} = HubspotClient.retrieve_contacts()
      assert String.contains?(json_string, "123456789")
    end

    test "can retrieve contacts with after" do
      Tesla
      |> expect(:get, fn _client, _url, _options ->
        {:ok,
         %Tesla.Env{
           status: 200,
           body:
             JSON.encode!(%{
               "paging" => %{"next" => %{"after" => "123456789"}},
               "results" => [%{"id" => "246810121", "properties" => %{}}]
             })
         }}
      end)

      assert {:ok, json_string} = HubspotClient.retrieve_contacts(after: "123456789")
      assert String.contains?(json_string, "246810121")
    end

    test "errors from ratelimit" do
      HubspotRatelimit
      |> expect(:hit, fn _token, _timer, _limit ->
        {:deny, 1000}
      end)

      assert {:error, {:rate_limit, message}} = HubspotClient.retrieve_contacts()
      assert String.contains?(message, "1000")
    end

    test "errors from non-200 status" do
      Tesla
      |> expect(:get, fn _client, _url, _opts ->
        {:ok,
         %Tesla.Env{
           status: 500,
           body:
             JSON.encode!(%{
               "category" => "VALIDATION_ERROR",
               "correlationId" => "a43683b0-5717-4ceb-80b4-104d02915d8c",
               "errors" => [
                 %{
                   "code" => "INVALID_INTEGER",
                   "context" => %{"propertyName" => ["discount"]},
                   "message" => "discount was not a valid number"
                 }
               ],
               "message" => "This will be a human readable message with details about the error.",
               "status" => "error"
             })
         }}
      end)

      assert {:error, body} = HubspotClient.retrieve_contacts()
      assert String.contains?(body, "VALIDATION_ERROR")
    end
  end
end
