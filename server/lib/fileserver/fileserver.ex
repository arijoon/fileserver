defmodule FileServer do
  @root_path Application.get_env(:server, :root_path)

  def crawl(path) do
    File.ls(from_root(path))
    |> crawl_sub(path)
  end

  defp crawl_sub({:ok, files}, path) do
    {:folder, path, files |> Enum.map(&(Path.join(path, &1) |> crawl()))}
  end

  defp crawl_sub({:error, _}, path) do
    {:file, path}
  end

  def from_root(path) do
    Path.join(@root_path, path)
  end
end
