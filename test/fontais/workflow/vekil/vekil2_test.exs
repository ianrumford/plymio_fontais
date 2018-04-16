defmodule PlymioFontaisWorkflowVekilVekil2ModuleA do
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
    :defp_update_field_passthru,
    :def_produce
  ])
  |> Map.values()
  |> Code.eval_quoted([], __ENV__)

  Plymio.Fontais.Workflow.__vekil__()
  |> Map.fetch!(:def_produce)
  |> Macro.postwalk(fn
    {:produce, ctx, args} -> {:produce1, ctx, args}
    {:express, ctx, args} -> {:express1, ctx, args}
    x -> x
  end)
  |> Code.eval_quoted([], __ENV__)

  Plymio.Fontais.Workflow.__vekil__()
  |> Map.fetch!(:def_produce)
  |> Macro.postwalk(fn
    {:produce, ctx, args} -> {:produce2, ctx, args}
    {:express, ctx, args} -> {:express2, ctx, args}
    x -> x
  end)
  |> Code.eval_quoted([], __ENV__)

  def express(%__MODULE__{} = state) do
    {:ok, {:express, state}}
  end

  def express1(%__MODULE__{} = state) do
    {:ok, {:express1, state}}
  end

  def express2(%__MODULE__{} = state) do
    {:ok, {:express2, state}}
  end
end

defmodule PlymioFontaisWorkflowVekilVekil2Test do
  use PlymioFontaisHelperTest
  alias PlymioFontaisWorkflowVekilVekil2ModuleA, as: TestMod
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

  test "produce: 100a" do
    assert {:ok, {:express, %TestMod{}}} = TestMod.new!() |> TestMod.produce()
    assert {:ok, {:express1, %TestMod{}}} = TestMod.new!() |> TestMod.produce1()
    assert {:ok, {:express2, %TestMod{}}} = TestMod.new!() |> TestMod.produce2()
  end
end
