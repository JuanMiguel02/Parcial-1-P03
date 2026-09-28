defmodule CentroAcopioLeche do
  def main do
    cargar_modulos()

    productores = Datos.productores()
    tanques = Datos.tanques()
    {entregas_validas, entregas_rechazadas} =
      Datos.entregas()
      |> Validador.clasificar_entregas(productores, tanques)

    entregas_rechazadas =
      Enum.map(entregas_rechazadas, fn {entrega, motivo} ->
        Map.put(entrega, :motivo, motivo)
      end)

    reporte =
      ProcesadorReportes.generar_reporte(
        entregas_validas,
        entregas_rechazadas,
        tanques,
        productores
      )

    IO.puts("Entregas válidas: #{length(entregas_validas)}")
    IO.puts("Entregas rechazadas: #{length(entregas_rechazadas)}")
    IO.puts(ImpresorReportes.mostrar(reporte))

    productor = Util.ingresar("Ingrese el código del productor", :texto)
    comprobante = GeneradorComprobante.generar_comprobante_productor(productor, productores, entregas_validas)
    IO.puts(comprobante)

  end

  defp cargar_modulos do
    for archivo <- [
          "Util.ex",
          "CalidadLeche.ex",
          "Liquidacion.ex",
          "Datos.ex",
          "Validador.exs",
          "ProcesadorReportes.exs",
          "ImpresorReportes.exs",
          "GeneradorComprobante.ex"
        ] do
      Code.require_file(Path.join(__DIR__, archivo))
    end
  end
end

CentroAcopioLeche.main()
