defmodule FileServer.Operations do
  def hash_dir(path) do
    FileServer.crawl(path)
    |> process(path)
    |> List.flatten()
  end

  def new_file(file_path, filename, folder) do
    case File.exists?(FileServer.from_root(file_path)) do
      true -> {:ok, process({:file, file_path, filename}, folder)}
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
    %{filename: filename, hash: FileServer.hash_file(file_path), folder: folder,
     last_modified: FileServer.last_modified(file_path)}
  end
end
