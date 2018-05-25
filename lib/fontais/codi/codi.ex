defmodule Plymio.Fontais.Codi do
  @moduledoc false

  @vekil_basics %{
    doc_false:
      quote do
        @doc false
      end,
    def_minimal_types:
      quote do
        @type kv :: Plymio.Fontais.kv()
        @type opts :: Plymio.Fontais.opts()
        @type error :: Plymio.Fontais.error()
        @type result :: Plymio.Fontais.result()
      end
  }

  @vekil [
           @vekil_basics,
           Plymio.Fontais.Error,
           Plymio.Fontais.Codi.State,
           Plymio.Fontais.Codi.Workflow.Produce
         ]
         |> Plymio.Fontais.Vekil.ProxyForomDict.create_proxy_forom_dict!()

  def __vekil__() do
    @vekil
  end
end
