defmodule FileServer.Operations do
  import Server.Items
  import Logger

  @worker_count 50

  def reset_dir(path) do
    info("Starting to re hash dir: #{path}")
    # Clear all entries
    Server.Items.delete_all(path)
    result = process_dir(path)
    |> Server.Items.add_all()

    info("Finished rehashing dir: #{path}")
    result
  end

  def process_dir(path) do
    lst = FileServer.crawl(path)
    |> reformat(path)
    |> List.flatten()
    count = get_chunk(length(lst))
    lst
    |> Enum.chunk_every(count)
    |> Enum.map(fn chunk ->
      Task.async(fn ->
        chunk
        |> Enum.map(&process/1)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10_000))
    |> List.flatten()
  end

  def new_file(file_path, filename, folder) do
    case File.exists?(FileServer.from_root(file_path)) do
      true -> process({:file, file_path, filename, folder}) |> create_item()
      _ -> {:error}
    end
  end

  defp process({:file, file_path, filename, folder}) do
    # Hash and store
    %{filename: filename, hash: FileServer.hash_file(file_path), path: folder,
     added: FileServer.last_modified(file_path), user: FileServer.Utils.user_from_filename(filename)}
  end

  defp reformat({:folder, path, files}, _folder) do
    files
    |> Enum.map(fn f -> reformat(f, path) end)
  end
  defp reformat(file = {:file, _path, _files}, folder) do
    Tuple.append(file, folder)
  end

  defp get_chunk(size) when size < @worker_count, do: 1
  defp get_chunk(size), do: Float.ceil(size/@worker_count) |> trunc()
end
