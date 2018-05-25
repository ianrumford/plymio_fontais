defmodule PlymioFontaisProxyForomDict2ModuleA do
  @vekil %{
    mod_a_1: 1,
    mod_a_2: {21, 22},
    mod_a_3: "tre"
  }

  def __vekil__() do
    @vekil
  end
end

defmodule PlymioFontaisProxyForomDict2ModuleB do
  @vekil %{
    mod_b_1: 1,
    mod_b_2: {21, 22},
    mod_b_3: "tre"
  }

  def __vekil__() do
    @vekil
  end
end

defmodule PlymioFontaisProxyForomDict2ModuleC do
  @vekil %{
    mod_c_1: 1,
    mod_c_2: {21, 22},
    mod_c_3: "tre"
  }

  def __vekil__() do
    @vekil
  end
end

defmodule PlymioFontaisProxyForomDict2Test do
  use PlymioFontaisHelperTest
  alias Plymio.Fontais.Vekil.ProxyForomDict, as: PROXYFOROMDICT
  alias PlymioFontaisProxyForomDict2ModuleA, as: TestModA
  alias PlymioFontaisProxyForomDict2ModuleB, as: TestModB
  alias PlymioFontaisProxyForomDict2ModuleC, as: TestModC
  use Plymio.Fontais.Attribute

  test "resolve_proxies: 100a" do
    vekil_100a =
      [
        TestModA,
        TestModB,
        TestModC
      ]
      |> PROXYFOROMDICT.create_proxy_forom_dict!()
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert {:ok, [mod_a_3: "tre"]} =
             vekil_100a
             |> PROXYFOROMDICT.resolve_proxies(:mod_a_3)

    assert {:ok, [mod_a_3: "tre", mod_b_2: {21, 22}, mod_c_1: 1]} =
             vekil_100a |> PROXYFOROMDICT.resolve_proxies([:mod_a_3, :mod_b_2, :mod_c_1])
  end

  test "resolve_proxies: composites 500a" do
    vekil_500a =
      %{
        ak1: "av1",
        ak: :ak1,
        bk1: "bv1",
        bk2: "bv2",
        bk: [:bk1, :bk2],
        ck1: "cv1",
        ck2: "cv2",
        ck3: "cv3",
        ck: [:ck1, :ck2, :ck3],

        # will error
        c_k_broken1: [:ck1, :c_k_broken1],

        # will error
        c_k_broken2: :c_k_broken2,

        # will error
        c_k_broken3a: :c_k_broken3b,
        c_k_broken3b: :c_k_broken3a,

        # will error
        c_k_broken4a: [quote(do: a + b), :c_k_broken4b, quote(do: a - b)],
        c_k_broken4b: [{1} |> Macro.escape(), :c_k_broken4c, "tre"],
        c_k_broken4c: [quote(do: x = x + 1), :c_k_broken4a, quote(do: x = x - 1)]
      }
      |> PROXYFOROMDICT.validate_proxy_forom_dict!()

    assert {:ok, [ak1: "av1"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:ak1)

    assert {:ok, [ak: "av1"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:ak)

    assert {:ok, [bk1: "bv1"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:bk1)

    assert {:ok, [bk2: "bv2"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:bk2)

    assert {:ok, [ck1: "cv1"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:ck1)

    assert {:ok, [ck2: "cv2"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:ck2)

    assert {:ok, [ck3: "cv3"]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:ck3)

    assert {:ok, [bk: ["bv1", "bv2"]]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:bk)

    assert {:ok, [ck: ["cv1", "cv2", "cv3"]]} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:ck)

    assert {:error, error} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:c_k_broken1)

    assert error |> Exception.exception?()
    assert "proxy seen before, got: :c_k_broken1" == error |> Exception.message()

    assert {:error, error} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:c_k_broken2)

    assert error |> Exception.exception?()
    assert "proxy seen before, got: :c_k_broken2" == error |> Exception.message()

    assert {:error, error} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:c_k_broken3a)

    assert error |> Exception.exception?()
    assert "proxy seen before, got: :c_k_broken3a" == error |> Exception.message()

    assert {:error, error} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:c_k_broken3b)

    assert error |> Exception.exception?()
    assert "proxy seen before, got: :c_k_broken3b" == error |> Exception.message()

    assert {:error, error} =
             vekil_500a
             |> PROXYFOROMDICT.resolve_proxies(:c_k_broken4a)

    assert error |> Exception.exception?()
    assert "proxy seen before, got: :c_k_broken4a" == error |> Exception.message()
  end
end
