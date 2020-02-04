defmodule FileServer.Operations do
  def hash_dir(path) do
    FileServer.crawl(path)
    |> process(path)
    |> List.flatten()
  end

  def process({:folder, path, files}, _) do
    files
    |> Enum.map(&(Task.async(fn -> process(&1, path) end)))
    |> Enum.map(&(Task.await(&1)))
  end
  def process({:file, file_path}, path) do
    # Hash and store
    file_path
  end
end
