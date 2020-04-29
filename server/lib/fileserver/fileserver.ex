defmodule FileServer do
  import Logger

  @root_path Application.get_env(:server, :root_path)

  def crawl(path, filename \\ "") do
    from_root(path)
    |> File.ls()
    |> crawl_sub(path, filename)
  end

  defp crawl_sub({:ok, files}, path, _) do
    {:folder, path, files |> Enum.reject(&filter_file/1) |> Enum.map(&(Path.join(path, &1) |> crawl(&1)))}
  end

  defp crawl_sub({:error, _}, path, filename) do
    {:file, path, filename}
  end

  defp filter_file(file), do: String.starts_with?(file, ".")

  def hash_file(path) do
    from_root(path)
    |> File.stream!([], 2048)
    |> Enum.reduce(:crypto.hash_init(:md5), fn line, acc -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final
    |> Base.encode16
  end

  def delete_file(path, filename) do
    Path.join(path, filename)
    |> from_root()
    |> log_action("delete")
    |> File.rm!()
  end

  def from_root(path) do
    Path.join(@root_path, path)
  end

  def last_modified(path) do
    {:ok, stat} = from_root(path)
    |> File.stat()

    stat.mtime |> to_datetime()
  end
  def to_datetime({{y, m, d}, {h, mm, ss}}) do
    %DateTime{year: y, month: m, day: d, hour: h, minute: mm, second: ss,
      utc_offset: 0, std_offset: 0, zone_abbr: "UTC", time_zone: "Etc/UTC"}
  end

  def log_action(path, action) do
    info("#{action} #{path}")
    path
  end
end
