defmodule Plymio.Fontais.Codi do
  @moduledoc false

  alias Plymio.Fontais.Vekil, as: PFV
  require Plymio.Fontais.Workflow
  require Plymio.Fontais.Error

  @vekil [
           Plymio.Fontais.Error,
           Plymio.Fontais.Workflow
         ]
         |> PFV.create_vekil!()

  def __vekil__() do
    @vekil
  end
end
