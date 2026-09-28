defmodule GeneradorComprobante do
  @moduledoc """
  Genera comprobantes de liquidación individuales para los productores.
  """

  @doc """
  Genera el comprobante de liquidación de un productor.

  El código se normaliza antes de buscarlo. Si no existe en `productores`,
  retorna un mensaje informativo; en caso contrario, genera el comprobante
  con las entregas válidas del productor.
  """
  def generar_comprobante_productor(codigo_productor, productores, entregas) do

    codigo_productor_limpio = codigo_productor |> String.upcase() |>String.trim()

    case Enum.find(productores, fn productor -> to_string(productor.codigo) == codigo_productor_limpio end) do
      nil -> "El código del productor '#{codigo_productor_limpio}' no existe en el sistema."

      productor ->
        liquidacion = Liquidacion.liquidar_productor(productor, entregas)
        renderizar_comprobante(liquidacion)
    end
  end

  #Devuelve el comprobante (en texto) a partir del mapa que contiene la liquidación completa del productor
  defp renderizar_comprobante(liquidacion) do
    detalle_texto =
      if Enum.empty?(liquidacion.detalle_dias) do
        "  • No registra entregas válidas."
      else
        liquidacion.detalle_dias
        |> Util.convertir_coleccion_mensaje(fn d ->
          "  • Día #{d.dia}: #{d.cantidad_entregas} entregas | #{Util.formatear_numero(d.litros)} L | Valor: $#{Util.formatear_dinero(d.valor_entregas)} | Bono: $#{Util.formatear_dinero(d.bonificacion)} | Transporte: $#{Util.formatear_dinero(d.transporte)}\n"
        end)
        |> Enum.join()
        |> String.trim_trailing()
      end

    "COMPROBANTE DE LIQUIDACIÓN\n\n" <>
    "Productor: #{liquidacion.nombre} (#{liquidacion.codigo})\n\n" <>
    "Detalle por día:\n" <>
    "#{detalle_texto}\n\n" <>
    "Resumen:\n" <>
    "  • Total de entregas: #{liquidacion.total_entregas}\n" <>
    "  • Litros entregados: #{Util.formatear_numero(liquidacion.litros)} L\n" <>
    "  • Valor de las entregas: $#{Util.formatear_dinero(liquidacion.valor_entregas)}\n" <>
    "  • Total de bonificaciones: $#{Util.formatear_dinero(liquidacion.bonificaciones)}\n" <>
    "  • Descuento por transporte: $#{Util.formatear_dinero(liquidacion.transporte)}\n" <>
    "  • Neto a pagar: $#{Util.formatear_dinero(liquidacion.neto)}"
  end

end
