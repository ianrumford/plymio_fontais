defmodule PlymioFontaisProxyForomDict1ModuleA do
  @vekil %{
    mod_a_1: 1,
    mod_a_2: :due,
    mod_a_3: "tre"
  }

  def __vekil__() do
    @vekil
  end
end

defmodule PlymioFontaisProxyForomDict1ModuleB do
  @vekil %{
    mod_b_1: 1,
    mod_b_2: :due,
    mod_b_3: "tre"
  }

  def __vekil__() do
    @vekil
  end
end

defmodule PlymioFontaisProxyForomDict1ModuleC do
  @vekil %{
    mod_c_1: 1,
    mod_c_2: :due,
    mod_c_3: "tre"
  }

  def __vekil__() do
    @vekil
  end
end

defmodule PlymioFontaisProxyForomDict1Test do
  use PlymioFontaisHelperTest
  alias Plymio.Fontais.Vekil.ProxyForomDict, as: PROXYFOROMDICT
  alias PlymioFontaisProxyForomDict1ModuleA, as: TestModA
  alias PlymioFontaisProxyForomDict1ModuleB, as: TestModB
  alias PlymioFontaisProxyForomDict1ModuleC, as: TestModC
  use Plymio.Fontais.Attribute

  test "validate_proxy_forom_dict: 100a" do
    assert {:ok, vekil_mod_a} =
             TestModA.__vekil__()
             |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert is_map(vekil_mod_a)

    assert [:mod_a_1, :mod_a_2, :mod_a_3] |> Enum.sort() ==
             vekil_mod_a
             |> Map.keys()
             |> Enum.sort()

    assert 1 = vekil_mod_a |> Map.get(:mod_a_1)
    assert :due = vekil_mod_a |> Map.get(:mod_a_2)
    assert "tre" = vekil_mod_a |> Map.get(:mod_a_3)

    assert {:ok, vekil_mod_b} =
             TestModB.__vekil__()
             |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert is_map(vekil_mod_b)

    assert {:ok, vekil_mod_c} =
             TestModC.__vekil__()
             |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert is_map(vekil_mod_c)
  end

  test "validate_proxy_forom_dict: 200a" do
    vekil = %{key1_200a: [1, 2, 3]}

    assert {:ok, vekil} =
             vekil
             |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert is_map(vekil)

    assert [1, 2, 3] = vekil |> Map.get(:key1_200a)
  end

  test "validate_proxy_forom_dict: 200b" do
    vekil = %{
      key1_200b: [1, 2, 3],
      key2_200b: :due,
      key3_200b: "tre",
      keys_200b: [:key1_200b, :key2_200b, :key3_200b]
    }

    assert {:ok, vekil} =
             vekil
             |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert is_map(vekil)

    assert [1, 2, 3] = vekil |> Map.get(:key1_200b)
    assert [:key1_200b, :key2_200b, :key3_200b] = vekil |> Map.get(:keys_200b)
  end

  test "validate_proxy_forom_dict: 500a" do
    assert {:error, error} =
             42
             |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert error |> Exception.exception?()

    assert "vekil invalid, got: 42" == error |> Exception.message()
  end

  test "validate_proxy_forom_dict: 500b" do
    vekil = %{key1_500b: %{a: 1}}

    assert {:ok, vekil} = vekil |> PROXYFOROMDICT.validate_proxy_forom_dict()

    assert is_map(vekil)

    assert %{a: 1} = vekil |> Map.get(:key1_500b)
  end

  test "create_proxy_forom_dict: 100a" do
    vekil_100a =
      []
      |> PROXYFOROMDICT.create_proxy_forom_dict!()

    assert is_map(vekil_100a)
    assert 0 == vekil_100a |> map_size
  end

  test "create_proxy_forom_dict: 100b" do
    vekil_mod_a = TestModA.__vekil__()

    vekil_size_mod_a = vekil_mod_a |> map_size

    vekil_100b =
      [
        TestModA
      ]
      |> PROXYFOROMDICT.create_proxy_forom_dict!()
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert vekil_size_mod_a == vekil_100b |> map_size
  end

  test "create_proxy_forom_dict: 100c" do
    vekil_mod_a = TestModA.__vekil__()
    vekil_mod_b = TestModB.__vekil__()
    vekil_mod_c = TestModC.__vekil__()

    vekil_size_mod_a = vekil_mod_a |> map_size
    vekil_size_mod_b = vekil_mod_b |> map_size
    vekil_size_mod_c = vekil_mod_c |> map_size

    vekil_100c =
      [
        TestModA,
        TestModB,
        TestModC
      ]
      |> PROXYFOROMDICT.create_proxy_forom_dict!()
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert vekil_size_mod_a + vekil_size_mod_b + vekil_size_mod_c == vekil_100c |> map_size

    assert [
             :mod_a_1,
             :mod_a_2,
             :mod_a_3,
             :mod_c_1,
             :mod_c_2,
             :mod_c_3,
             :mod_b_1,
             :mod_b_2,
             :mod_b_3
           ]
           |> Enum.sort() == vekil_100c |> Map.keys() |> Enum.sort()
  end

  test "create_proxy_forom_dict: 300a" do
    vekil_mod_a = TestModA.__vekil__()
    vekil_size_mod_a = vekil_mod_a |> map_size
    vekil_keys_mod_a = vekil_mod_a |> Map.keys()

    vekil_map_a = %{ak1: 1}
    vekil_size_map_a = vekil_map_a |> map_size
    vekil_keys_map_a = vekil_map_a |> Map.keys()

    vekil_keyword_a = [
      bk1: 21,
      bk2: quote(do: x = x + 1)
    ]

    vekil_size_keyword_a = vekil_keyword_a |> length
    vekil_keys_keyword_a = vekil_keyword_a |> Keyword.keys()

    vekil_300a =
      [
        vekil_map_a,
        vekil_keyword_a,
        TestModA
      ]
      |> PROXYFOROMDICT.create_proxy_forom_dict!()
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert vekil_size_mod_a + vekil_size_map_a + vekil_size_keyword_a == vekil_300a |> map_size

    vekil_300a_keys =
      (vekil_keys_mod_a ++ vekil_keys_map_a ++ vekil_keys_keyword_a)
      |> Enum.sort()

    assert vekil_300a_keys == vekil_300a |> Map.keys() |> Enum.sort()
  end

  test "create_with_override_vekil: 100a" do
    vekil_over_1 =
      %{
        mod_a_1: :vekil_override_1
      }
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    vekil_mod_a = TestModA.__vekil__()

    vekil_size_mod_a = vekil_mod_a |> map_size

    # last wins!
    vekil_100a =
      [
        TestModA,
        vekil_over_1
      ]
      |> PROXYFOROMDICT.create_proxy_forom_dict!()
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert vekil_size_mod_a == vekil_100a |> map_size

    assert [
             :mod_a_1,
             :mod_a_2,
             :mod_a_3
           ]
           |> Enum.sort() == vekil_100a |> Map.keys() |> Enum.sort()

    assert :vekil_override_1 = vekil_100a |> Map.get(:mod_a_1)
    assert :due = vekil_100a |> Map.get(:mod_a_2)
    assert "tre" = vekil_100a |> Map.get(:mod_a_3)
  end

  test "create_with_override_vekil: 100b" do
    vekil_over_1 =
      %{
        mod_a_1: :vekil_override_1
      }
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    vekil_mod_a = TestModA.__vekil__()

    vekil_size_mod_a = vekil_mod_a |> map_size

    # last wins!
    vekil_100b =
      [
        vekil_over_1,
        TestModA
      ]
      |> PROXYFOROMDICT.create_proxy_forom_dict!()
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert vekil_size_mod_a == vekil_100b |> map_size

    assert [
             :mod_a_1,
             :mod_a_2,
             :mod_a_3
           ]
           |> Enum.sort() == vekil_100b |> Map.keys() |> Enum.sort()

    assert 1 = vekil_100b |> Map.get(:mod_a_1)
    assert :due = vekil_100b |> Map.get(:mod_a_2)
    assert "tre" = vekil_100b |> Map.get(:mod_a_3)
  end
end
