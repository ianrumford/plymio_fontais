defmodule PlymioFontaisWorkflowVekilVekil1ModuleA do
  defstruct a: 1, b: :due, c: "tre"

  @type t :: %__MODULE__{}
  @type kv :: {any, any}
  @type opts :: Keyword.t()
  @type error :: struct

  def update_canonical_opts(opts) do
    {:ok, opts}
  end

  Plymio.Fontais.Workflow.__vekil__()
  |> Map.take([
    :def_new,
    :def_new!,
    :def_update,
    :def_update!,
    :defp_update_field_header,
    :defp_update_field_passthru
  ])
  |> Map.values()
  |> Code.eval_quoted([], __ENV__)
end

defmodule PlymioFontaisWorkflowVekilVekil1Test do
  use PlymioFontaisHelperTest
  alias PlymioFontaisWorkflowVekilVekil1ModuleA, as: TestMod
  use Plymio.Fontais.Attribute

  test "new: 100a" do
    assert {:ok, state} = TestMod.new()

    assert %TestMod{} = state

    assert 1 = state.a
    assert :due = state.b
    assert "tre" = state.c
  end

  test "update: 100a" do
    assert {:ok, state} = TestMod.new()

    assert %TestMod{} = state

    assert 1 = state.a
    assert :due = state.b
    assert "tre" = state.c

    {:ok, state} = state |> TestMod.update(a: 11, b: "two")

    assert 11 = state.a
    assert "two" = state.b
    assert "tre" = state.c
  end
end
