defmodule FileServer.Utils do
  def user_from_filename(filename) do
    default = "Arijoon"
    case String.split(filename, "__", parts: 2) do
      [_, user_file] ->
        case String.split(user_file, "_", parts: 2) do
          [username, _] -> username
          _ -> default
        end
      _ -> default
    end
  end

  def split_name_folder(filepath) when is_binary(filepath) do
    Regex.split(~r/(?<=((\/)|(\\)))/, filepath)
    |> split_name_folder("")
  end

  def split_name_folder([name | []], path), do: {path, name}
  def split_name_folder([h | t], path), do: split_name_folder(t, path <> h)
end
