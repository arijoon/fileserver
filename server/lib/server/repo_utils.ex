defmodule Server.RepoUtils do
    def changeset_to_map(changeset) do
      changeset
      |> Ecto.Changeset.apply_changes()
      |> Map.from_struct()
      |> Enum.reject(fn
        {_key, nil} -> true
        {_key, %DateTime{}} -> false
        {_key, %_struct{}} -> true
        _other -> false
      end)
    end

    def add_timestamps(list) when is_list(list) do
      [{:inserted_at, naive_now()}, {:updated_at, naive_now()} | list]
    end

    defp naive_now() do
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)
    end
end
