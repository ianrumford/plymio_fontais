defmodule BadKeyError do
  @moduledoc ~S"""
  The `BadKeyError` `Exception` is a general pupose exception to signal
  that one or more `key(s)` in `term` are invalid in some way.
  """

  defexception [:key, :term]

  def message(exception) do
    exception.key
    |> case do
      [key] ->
        "bad key #{inspect(key)} for: #{inspect(exception.term)}"

      keys ->
        "bad keys #{inspect(keys)} for: #{inspect(exception.term)}"
    end
  end
end
