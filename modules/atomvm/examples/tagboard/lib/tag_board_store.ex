defmodule TagBoard.Store do
  @nvs_namespace :tagboard_data
  @nvs_key :tags_list

  @max_tags 25

  def add_tag(author, content, timestamp) do
    case read_tags_from_nvs() do
      {:ok, current_tags} ->
        new_tag = %{id: timestamp, author: author, content: content, timestamp: timestamp}

        updated_tags = [new_tag | current_tags]

        limited_tags = :lists.sublist(updated_tags, @max_tags)

        case write_tags_to_nvs(limited_tags) do
          :ok ->
            :ok

          {:error, reason} ->
            :io.format('Failed to write tags to NVS after adding: ~p~n', [reason])
            {:error, reason}
        end

      {:error, reason} ->
        :io.format('Failed to add tag due to NVS read error: ~p~n', [reason])
        {:error, reason}
    end
  end

  def get_tags, do: read_tags_from_nvs()

  def clear_all_tags do
    case :esp.nvs_erase_key(@nvs_namespace, @nvs_key) do
      :ok ->
        :io.format('All tags cleared from NVS.~n')
        :ok

      error ->
        :io.format('Failed to clear tags from NVS: ~p~n', [error])
        {:error, error}
    end
  end

  defp read_tags_from_nvs do
    binary_tags = :esp.nvs_get_binary(@nvs_namespace, @nvs_key, <<>>)

    # :io.format('reading tags from nvs ~p~n~n', [binary_tags])

    if binary_tags == <<"">> do
      {:ok, []}
    else
      try do
        tags = :erlang.binary_to_term(binary_tags)
        # Basic validation: ensure it's a list. If not, treat as empty.
        if is_list(tags) do
          {:ok, tags}
        else
          :io.format('NVS data for tags_list is corrupted or not a list. Returning empty list.~n')
          {:ok, []}
        end
      rescue
        e ->
          :io.format('Failed to deserialize tags from NVS: ~p~n', [e])
          {:error, {:deserialization_error, e}}
      end
    end
  end

  defp write_tags_to_nvs(tags) do
    binary_tags = :erlang.term_to_binary(tags)

    case :esp.nvs_put_binary(@nvs_namespace, @nvs_key, binary_tags) do
      :ok ->
        :ok

      error ->
        :io.format('Failed to write tags to NVS: ~p~n', [error])
        {:error, error}
    end
  end
end
