# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
defmodule CombinacionLitros do
  @moduledoc """
  Módulo para resolver el punto de investigación sobre:
  combinación de información entre centros de acopio mediante Map.merge/3.
  """

  @doc """
  Combina los mapas de litros diarios de dos centros de acopio.
  Suma las cantidades de los días compartidos y conserva los días exclusivos de cada uno.
  """
  def combinar_litros_diarios(litros_locales, centro_vecino) do
    Map.merge(litros_locales, centro_vecino, fn _dia, litros1, litros2 ->
      litros1 + litros2
    end)
  end

  @doc """
  Ejecuta la demostración del ejercicio de investigación y muestra los resultados.
  """
  def demostrar_combinacion(reporte_litros) do
    litros_locales =
      reporte_litros.detalle_diario
      |> Enum.map(fn item -> {item.dia, item.litros} end)
      |> Map.new()

    centro_vecino = %{1 => 1850.5, 2 => 2100.0, 3 => 1640.0, 5 => 2350.0, 7 => 800.0}

    litros_combinados = combinar_litros_diarios(litros_locales, centro_vecino)

    "\n+-----------------------INVESTIGACIÓN: COMBINACIÓN MAP.MERGE/3-----------------------+"
    |> Util.mostrar(:mensaje)

    "Litros locales por día: #{inspect(litros_locales)}"
    |> Util.mostrar(:mensaje)

    "Litros centro vecino:   #{inspect(centro_vecino)}"
    |> Util.mostrar(:mensaje)

    "Litros combinados:      #{inspect(litros_combinados)}"
    |> Util.mostrar(:mensaje)
  end
end
