defmodule ImpresorReportes do
  def mostrar(reporte) do
    """
    +------------------------------------------------------+
    |                    REPORTE GENERAL                    |
    +------------------------------------------------------+

    1) Ocupación por tanque
    #{render_tanques(reporte.tanques)}

    2) Producción por día
    #{render_litros_por_dia(reporte.litros_por_dia)}

    3) Productor con más litros
    #{render_productor_mas_litros(reporte.productor_mas_litros)}

    4) Productores en todos los tanques
    #{render_productores_todos_los_tanques(reporte.productores_en_todos_los_tanques)}
    """
  end

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
          "  - Día #{r.dia}: #{Enum.map_join(r.ganadores, ", ", & &1.nombre)} (#{r.max_litros} L)\n"
        end)
        |> Enum.join()

      texto_detalle <> "\n  Ganador más frecuente: #{ganador}\n"
    end
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
