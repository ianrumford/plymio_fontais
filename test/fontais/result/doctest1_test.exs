defmodule PlymioFontaisResultDoctest1Test do
  use ExUnit.Case, async: true
  use PlymioFontaisHelperTest
  require Plymio.Fontais.Guard
  import Plymio.Fontais.Result

  doctest Plymio.Fontais.Result
end
