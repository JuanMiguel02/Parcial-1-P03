defmodule CentroAcopioLeche do
  @moduledoc """
  Punto de entrada de la aplicación del centro de acopio.
  """

  @doc """
  Ejecuta la secuencia completa de validación, reportes y comprobante.
  """
  def main do
    cargar_modulos()

    productores = Datos.productores()
    tanques = Datos.tanques()

    {entregas_validas, entregas_rechazadas} =
      Datos.entregas()
      |> Validador.clasificar_entregas(productores, tanques)

    entregas_rechazadas = agregar_motivo_a_rechazos(entregas_rechazadas)

    reporte =
      ProcesadorReportes.generar_reporte(
        entregas_validas,
        entregas_rechazadas,
        tanques,
        productores,
        litros_centro_vecino()
      )

    IO.puts(ImpresorReportes.mostrar(reporte))

    codigo_productor = Util.ingresar("Ingrese el código del productor: ", :texto)

    codigo_productor
    |> GeneradorComprobante.generar_comprobante_productor(
      productores,
      entregas_validas
    )
    |> IO.puts()
  end

  defp cargar_modulos do
    [
      "Util.ex",
      "CalidadLeche.exs",
      "Liquidacion.exs",
      "Datos.exs",
      "Validador.exs",
      "ProcesadorReportes.exs",
      "GeneradorReportes.exs",
      "GeneradorComprobante.exs"
    ]
    |> Enum.each(fn archivo -> Code.require_file(Path.join(__DIR__, archivo)) end)
  end

  defp agregar_motivo_a_rechazos(entregas_rechazadas) do
    Enum.map(entregas_rechazadas, fn {entrega, motivo} ->
      Map.put(entrega, :motivo, motivo)
    end)
  end

  defp litros_centro_vecino do
    %{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
  end
end

CentroAcopioLeche.main()
