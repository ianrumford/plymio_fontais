defmodule Plymio.Error do
  @moduledoc false

  require Plymio.Fontais.Vekil.ProxyForomDict
  use Plymio.Fontais.Attribute

  @codi_opts [
    {@plymio_fontais_key_dict, Plymio.Fontais.Codi.__vekil__()}
  ]

  :defexception_package
  |> Plymio.Fontais.Vekil.ProxyForomDict.reify_proxies(@codi_opts)

  # PFEM.defexception_package
end
