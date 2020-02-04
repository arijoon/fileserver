defmodule FileServer.Operations do
  def hash_dir(path) do
    FileServer.crawl(path)
    |> process(path)
    |> List.flatten()
  end

  def process({:folder, path, files}, _) do
    files
    |> Enum.map(&(Task.async(fn -> process(&1, path) end)))
    |> Enum.map(&(Task.await(&1, 10_000)))
  end
  def process({:file, file_path, filename}, folder) do
    # Hash and store
    %{filename: filename, hash: FileServer.hash_file(file_path), folder: folder}
  end
end
