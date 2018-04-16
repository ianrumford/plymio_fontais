defmodule PlymioFontaisFormDoctest1Test do
  use ExUnit.Case, async: true
  use PlymioFontaisHelperTest
  import Plymio.Fontais.Form

  doctest Plymio.Fontais.Form
end
