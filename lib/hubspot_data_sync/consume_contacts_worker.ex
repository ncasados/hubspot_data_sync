defmodule HubspotDataSync.ConsumeContactsWorker do
  alias HubspotDataSync.HubspotClient
  alias HubspotDataSync.Contact

  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"next" => %{"after" => v_after}}}) do
    with {:ok, response} <- HubspotClient.retrieve_contacts(after: v_after) do
      results = Map.get(response, "results")

      paging = Map.get(response, "paging")

      if is_nil(paging) do
        store_results(results)
      else
        queue_next_page_and_store_results(paging, results)
      end
    end
  end

  def perform(%Oban.Job{args: %{}}) do
    with {:ok, response} <- HubspotClient.retrieve_contacts() do
      results = Map.get(response, "results")

      paging = Map.get(response, "paging")

      if is_nil(paging) do
        store_results(results)
      else
        queue_next_page_and_store_results(paging, results)
      end
    end
  end

  defp queue_next_page_and_store_results(paging, results) do
    Task.async_stream(
      [fn -> queue_next_page(paging) end, fn -> store_results(results) end],
      & &1.()
    )
    |> Stream.run()
  end

  defp queue_next_page(paging) do
    __MODULE__.new(paging)
    |> Oban.insert()
  end

  defp store_results(results) do
    {:ok, results |> Enum.map(fn contact ->
      contact = %{external_id: contact["id"], properties: contact["properties"]}
      Contact.create(contact)
    end)}
  end
end
