defmodule FileServer do
  @root_path Application.get_env(:server, :root_path)

  def crawl(path, filename \\ "") do
    from_root(path)
    |> File.ls()
    |> crawl_sub(path, filename)
  end

  defp crawl_sub({:ok, files}, path, _) do
    {:folder, path, files |> Enum.map(&(Path.join(path, &1) |> crawl(&1)))}
  end

  defp crawl_sub({:error, _}, path, filename) do
    {:file, path, filename}
  end

  def hash_file(path) do
    from_root(path)
    |> File.stream!([], 2048)
    |> Enum.reduce(:crypto.hash_init(:md5), fn line, acc -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final
    |> Base.encode16
  end

  def from_root(path) do
    Path.join(@root_path, path)
  end
end
