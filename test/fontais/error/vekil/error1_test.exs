defmodule PlymioFontaisErrorVekilError1ModuleA do
  require Plymio.Fontais.Vekil.ProxyForomDict, as: PROXYFOROMDICT
  use Plymio.Fontais.Attribute

  @codi_opts [
    {@plymio_fontais_key_dict, Plymio.Fontais.Codi.__vekil__()}
  ]

  :defexception_package
  |> PROXYFOROMDICT.reify_proxies(@codi_opts)
end

defmodule PlymioFontaisErrorVekilError1Test do
  use PlymioFontaisHelperTest
  alias PlymioFontaisErrorVekilError1ModuleA, as: TestMod
  use Plymio.Fontais.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset: 1
    ]

  test "error: base 100a" do
    assert error1 = %TestMod{} = TestMod.new!()

    expect_fields =
      [
        :__exception__,
        :message,
        :message_config,
        :message_function,
        :reason,
        :value
      ]
      |> Enum.sort()

    assert expect_fields ==
             error1
             |> Map.from_struct()
             |> Map.keys()
             |> Enum.sort()

    assert is_value_unset(error1.message)
    assert is_value_unset(error1.reason)
    assert is_value_unset(error1.value)
    assert is_value_unset(error1.message_function)
    assert @plymio_fontais_error_default_message_config == error1.message_config
  end

  test "simple: 100a" do
    assert simple1 = %TestMod{} = [message: "simple1 100a"] |> TestMod.new!()
    assert "simple1 100a" = simple1 |> Exception.message()

    assert simple2 = %TestMod{} = [message: "simple2 100a", value: 42] |> TestMod.new!()
    assert "simple2 100a, got: 42" = simple2 |> Exception.message()

    assert simple3 = %TestMod{} = [m: "simple3 100a", v: 42] |> TestMod.new!()
    assert "simple3 100a, got: 42" = simple3 |> Exception.message()

    assert simple2 =
             %TestMod{} = [message: "simple2 100a", value: 42, reason: :simple2] |> TestMod.new!()

    assert "simple2 100a, got: 42" = simple2 |> Exception.message()
    assert :simple2 = simple2.reason
  end

  test "order: 100a" do
    assert order1 =
             %TestMod{} = [format_order: :message, message: "order1 100a"] |> TestMod.new!()

    assert "order1 100a" = order1 |> Exception.message()

    assert order2 =
             %TestMod{} =
             [format_order: :message, message: "order2 100a", value: 42] |> TestMod.new!()

    assert "order2 100a" = order2 |> Exception.message()

    assert order3 = %TestMod{} = [format_order: :value, m: "order3 100a", v: 42] |> TestMod.new!()
    assert "42" = order3 |> Exception.message()
  end

  test "transform: 100a" do
    transform1 = fn _ -> :transform1 end

    assert transform1 =
             %TestMod{} =
             [format_message: transform1, message: "transform1 100a"] |> TestMod.new!()

    assert ":transform1" = transform1 |> Exception.message()

    transform2 = fn state -> state |> Map.get(@plymio_fontais_error_field_message) end

    assert transform2 =
             %TestMod{} =
             [format_message: transform2, message: "transform2 100a", value: 42] |> TestMod.new!()

    assert "transform2 100a" = transform2 |> Exception.message()
  end
end
