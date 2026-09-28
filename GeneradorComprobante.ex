defmodule GeneradorComprobante do
  def generar_comprobante_productor(codigo_productor, productores, entregas) do

    codigo_productor_limpio = codigo_productor |> String.upcase() |>String.trim()

    case Enum.find(productores, fn productor -> to_string(productor.codigo) == codigo_productor_limpio end) do
      nil -> "El código del productor '#{codigo_productor_limpio}' no existe en el sistema."

      productor ->
        liquidacion = Liquidacion.liquidar_productor(productor, entregas)
        renderizar_comprobante(liquidacion)
    end
  end

  defp renderizar_comprobante(liquidacion) do
    detalle_texto =
      if Enum.empty?(liquidacion.detalle_dias) do
        "  • No registra entregas válidas."
      else
        liquidacion.detalle_dias
        |> Util.convertir_coleccion_mensaje(fn d ->
          "  • Día #{d.dia}: #{d.cantidad_entregas} entregas | #{formatear_numero(d.litros)} L | Valor: $#{formatear_dinero(d.valor_entregas)} | Bono: $#{formatear_dinero(d.bonificacion)} | Transporte: $#{formatear_dinero(d.transporte)}\n"
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
    "  • Litros entregados: #{formatear_numero(liquidacion.litros)} L\n" <>
    "  • Valor de las entregas: $#{formatear_dinero(liquidacion.valor_entregas)}\n" <>
    "  • Total de bonificaciones: $#{formatear_dinero(liquidacion.bonificaciones)}\n" <>
    "  • Descuento por transporte: $#{formatear_dinero(liquidacion.transporte)}\n" <>
    "  • Neto a pagar: $#{formatear_dinero(liquidacion.neto)}"
  end

  defp formatear_dinero(valor) when is_number(valor) do
    str = :erlang.float_to_binary(valor * 1.0, decimals: 2)
    [entera, decimal] = String.split(str, ".")
    "#{formatear_numero(entera)}.#{decimal}"
  end
  defp formatear_dinero(valor), do: to_string(valor)

  defp formatear_numero(valor) when is_number(valor) or is_binary(valor) do
    valor
    |> to_string()
    |> String.replace(~r/\B(?=(\d{3})+(?!\d))/, ".")
  end

end
