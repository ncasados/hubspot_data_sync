defmodule HubspotDataSync.ConsumeContactWorkerTest do
  alias HubspotDataSync.HubspotClient

  use ExUnit.Case, async: true
  use Mimic
  use Oban.Testing, repo: HubspotDataSync.Repo
  use HubspotDataSync.RepoCase

  test "can enqueue the Oban Job" do
    assert {:ok, _job} =
             HubspotDataSync.ConsumeContactsWorker.new(%{})
             |> Oban.insert()

    assert_enqueued worker: HubspotDataSync.ConsumeContactsWorker, args: %{}
  end

  test "can execute the job" do
    HubspotClient
    |> expect(:retrieve_contacts, fn ->
      {:ok, %{"results" => [%{"id" => "123456789", "properties" => %{}}]}}
    end)

    assert {:ok, [ok: contact]} = perform_job(HubspotDataSync.ConsumeContactsWorker, %{}, [])
    assert contact.external_id == "123456789"
  end

  test "can enqueue next page of records" do
    HubspotClient
    |> expect(:retrieve_contacts, fn ->
      {:ok,
       %{
         "paging" => %{"next" => %{"after" => "123456789"}},
         "results" => [%{"id" => "123456789", "properties" => %{}}]
       }}
    end)

    assert :ok = perform_job(HubspotDataSync.ConsumeContactsWorker, %{}, [])

    assert_enqueued worker: HubspotDataSync.ConsumeContactsWorker,
                    args: %{"next" => %{"after" => "123456789"}}
  end

  test "error when hubspot doesn't work" do
    HubspotClient
    |> expect(:retrieve_contacts, fn ->
      {:error, 500}
    end)

    assert {:error, 500} = perform_job(HubspotDataSync.ConsumeContactsWorker, %{})
  end
end
