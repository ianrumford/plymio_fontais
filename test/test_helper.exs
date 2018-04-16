ExUnit.start()

defmodule PlymioFontaisHelperTest do
  defmacro __using__(_opts \\ []) do
    quote do
      use ExUnit.Case, async: true
      import PlymioFontaisHelperTest
    end
  end
end
