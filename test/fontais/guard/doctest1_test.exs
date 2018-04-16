defmodule PlymioFontaisGuardDoctest1Test do
  use ExUnit.Case, async: true
  use PlymioFontaisHelperTest
  import Plymio.Fontais.Guard

  doctest Plymio.Fontais.Guard
end
