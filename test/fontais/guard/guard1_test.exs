defmodule PlymioFontaisCodiGuard1Test do
  use PlymioFontaisHelperTest
  require Plymio.Fontais.Guard
  import Plymio.Fontais.Guard

  defguard is_even(value) when is_integer(value) and rem(value, 2) == 0

  def filled_or_nil(v)

  def filled_or_nil(v) when is_filled_list(v) do
    v
  end

  def filled_or_nil(_) do
    nil
  end

  test "is_filled_list: 100a" do
    assert [1, 2, 3] |> is_filled_list
    refute [] |> is_filled_list

    fun1 = fn
      v when is_filled_list(v) -> true
      _ -> false
    end

    assert [1, 2, 3] |> fun1.()
    refute [] |> fun1.()
    refute 42 |> fun1.()
    refute :not_a_list |> fun1.()
  end
end
