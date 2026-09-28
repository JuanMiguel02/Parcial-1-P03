defmodule ImpresorReportes do
  def mostrar(reporte) do
    """
    +------------------------------------------------------+
    |                    REPORTE GENERAL                    |
    +------------------------------------------------------+

    1) Entregas rechazadas
    #{render_entregas_rechazadas(reporte.entregas_rechazadas)}

    2) Ocupación por tanque
    #{render_tanques(reporte.tanques)}

    3) Producción por día
    #{render_litros_por_dia(reporte.litros_por_dia)}

    4) Liquidaciones
    #{render_liquidaciones(reporte.liquidaciones)}

    5) Productor con más litros
    #{render_productor_mas_litros(reporte.productor_mas_litros)}

    6) Productor con mejor calidad
    #{render_productor_mejor_calidad(reporte.productor_mejor_calidad)}

    7) Total pagado
    #{render_total_pagado(reporte.total_pagado)}

    8) Productores en todos los tanques
    #{render_productores_todos_los_tanques(reporte.productores_en_todos_los_tanques)}
    """
  end

  defp render_entregas_rechazadas(%{total_rechazos: total, detalle: detalle, conteo_por_motivo: conteo}) do
    detalle_texto =
      case detalle do
        [] -> "  No hubo entregas rechazadas."
        _ ->
          detalle
          |> Enum.map(fn rechazada ->
            "  - #{rechazada.productor} / #{rechazada.tanque} / día #{rechazada.dia}: #{formatear_motivo(rechazada.motivo)}"
          end)
          |> Enum.join("\n")
      end

    motivos_texto =
      conteo
      |> Enum.map(fn {motivo, cantidad} -> "  - #{formatear_motivo(motivo)}: #{cantidad}" end)
      |> Enum.join("\n")

    "  Total de rechazos: #{total}\n" <>
      detalle_texto <> "\n  Conteo por motivo:\n" <> motivos_texto
  end

  defp formatear_motivo(motivo) when is_atom(motivo), do: motivo |> Atom.to_string() |> String.replace("_", " ")
  defp formatear_motivo(motivo), do: to_string(motivo)

  defp render_tanques([]), do: "  No hay datos de tanques."
  defp render_tanques(tanques) do
    tanques
    |> Util.convertir_coleccion_mensaje(fn t ->
      "  - #{t.nombre}: #{t.litros_almacenados} L / #{t.capacidad_maximo} L (#{t.ocupacion_tanque}%)\n"
    end)
    |> Enum.join()
  end

  defp render_litros_por_dia(%{detalle_diario: detalle, resumen: resumen}) do
    texto_detalle =
      detalle
      |> Util.convertir_coleccion_mensaje(fn r ->
        "  - Día #{r.dia}: #{r.litros} L #{if r.alcanzo_meta == "Sí", do: "(cumplió meta)", else: "(no cumplió)"}\n"
      end)
      |> Enum.join()

    texto_resumen =
      """
      Resumen:
        - Cumplió todos los días: #{resumen.cumplio_todos_los_dias}
        - Cumplió al menos un día: #{resumen.cumplio_al_menos_un_dia}
      """

    texto_detalle <> "\n" <> texto_resumen
  end

  defp render_productor_mas_litros(%{detalle_diario: detalle, productor_mas_dias: ganador}) do
    if detalle == [] do
      "  No hay información."
    else
      texto_detalle =
        detalle
        |> Util.convertir_coleccion_mensaje(fn r ->
          ganadores = Enum.map_join(r.ganadores, ", ", & &1.nombre)
          "  - Día #{r.dia}: #{if ganadores == "", do: "Ninguno", else: ganadores} (#{r.max_litros} L)\n"
        end)
        |> Enum.join()

      texto_detalle <> "\n  Ganador más frecuente: #{ganador}\n"
    end
  end

  defp render_liquidaciones([]), do: "  No hay liquidaciones."
  defp render_liquidaciones(liquidaciones) do
    liquidaciones
    |> Enum.map(fn liquidacion ->
      "  - #{liquidacion.nombre} (#{liquidacion.codigo})\n" <>
        "      Litros: #{liquidacion.litros}\n" <>
        "      Valor de entregas: $#{formatear_dinero(liquidacion.valor_entregas)}\n" <>
        "      Bonificaciones: $#{formatear_dinero(liquidacion.bonificaciones)}\n" <>
        "      Transporte: $#{formatear_dinero(liquidacion.transporte)}\n" <>
        "      Neto: $#{formatear_dinero(liquidacion.neto)}"
    end)
    |> Enum.join("\n")
  end

  defp render_productor_mejor_calidad(nil), do: "  No hay productores con al menos 3 entregas."
  defp render_productor_mejor_calidad(productores) do
    productores
    |> Enum.map(fn %{productor: productor, grasa_ponderada: grasa, total_entregas: total} ->
      nombre = if productor, do: productor.nombre, else: "Desconocido"
      "  - #{nombre}: #{grasa}% de grasa ponderada (#{total} entregas)"
    end)
    |> Enum.join("\n")
  end

  defp render_total_pagado(total) do
    "  Litros totales: #{total.total_litros}\n" <>
      "  Total bruto: $#{formatear_dinero(total.total_bruto)}\n" <>
      "  Bonificaciones: $#{formatear_dinero(total.total_bonos_empresa)}\n" <>
      "  Transporte: $#{formatear_dinero(total.total_transporte)}\n" <>
      "  Total neto pagado: $#{formatear_dinero(total.total_pagado)}\n" <>
      "  Costo promedio por litro: $#{formatear_dinero(total.costo_promedio_litro)}"
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

  defp render_productores_todos_los_tanques(productores) do
    case productores do
      [] ->
        "  No hubo productores en todos los tanques."

      _ ->
        productores
        |> Enum.map(fn p ->
          if p == nil, do: "  - Desconocido", else: "  - #{p.nombre}"
        end)
        |> Enum.join("\n")
    end
  end
end
