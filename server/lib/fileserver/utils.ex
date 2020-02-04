defmodule FileServer.Utils do
  def user_from_filename(filename) do
    default = "BASE"
    case String.split(filename, "__", parts: 2) do
      [_, user_file] ->
        case String.split(user_file, "_", parts: 2) do
          [username, _] -> username
          _ -> default
        end
      _ -> default
    end
  end
end
