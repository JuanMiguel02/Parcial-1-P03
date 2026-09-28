defmodule CalidadLeche do

  def calcular_grasa_ponderada(entregas) when is_list(entregas) and entregas != [] do
    suma_grasa_litros = Enum.sum(Enum.map(entregas, fn entrega -> entrega.grasa * entrega.litros end))
    suma_litros = Enum.sum(Enum.map(entregas, fn entrega -> entrega.litros end))

    if suma_litros > 0 do
      suma_grasa_litros / suma_litros
    else
      0.0
    end
  end

end
