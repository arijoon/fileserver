defmodule FileServer.Operations do
  import Server.Items
  def reset_dir(path) do
    # Clear all entries
    Server.Items.delete_all(path)
    process_dir(path)
    |> Server.Items.add_all()
  end

  def process_dir(path) do
    FileServer.crawl(path)
    |> process(path)
    |> List.flatten()
  end

  def new_file(file_path, filename, folder) do
    case File.exists?(FileServer.from_root(file_path)) do
      true -> process({:file, file_path, filename}, folder) |> create_item()
      _ -> {:error}
    end
  end

  defp process({:folder, path, files}, _) do
    files
    |> Enum.map(&(Task.async(fn -> process(&1, path) end)))
    |> Enum.map(&(Task.await(&1, 10_000)))
  end
  defp process({:file, file_path, filename}, folder) do
    # Hash and store
    %{filename: filename, hash: FileServer.hash_file(file_path), path: folder,
     added: FileServer.last_modified(file_path), user: FileServer.Utils.user_from_filename(filename)}
  end
end
