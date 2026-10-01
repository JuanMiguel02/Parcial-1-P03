# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
defmodule GeneracionReportes do
  @moduledoc """
  Convierte los datos procesados de los reportes en un resumen de texto.

  El módulo no calcula información de negocio; únicamente organiza y presenta
  los resultados generados por `ProcesamientoReportes`.
  """

  @doc """
  Genera el reporte general en formato de texto.

  El mapa recibido debe contener las claves generadas por
  `ProcesamientoReportes.generar_reporte/5`. El resultado puede imprimirse con
  `IO.puts/1` o utilizarse como texto para otro medio de salida.
  """
  @spec generar_reporte(map()) :: String.t()
  def generar_reporte(reporte) do
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

  # Desestructura el mapa de entregas rechazadas y muestra cada una
  # Además enumera la cantidad de motivos de rechazos
  defp render_entregas_rechazadas(%{
         total_rechazos: total,
         detalle: detalle,
         conteo_por_motivo: conteo
       }) do
    detalle_texto =
      case detalle do
        [] ->
          "  No hubo entregas rechazadas."

        _ ->
          detalle
          |> Util.convertir_coleccion_mensaje(fn rechazada ->
            "  - #{rechazada.productor} / #{rechazada.tanque} / día #{rechazada.dia}/ litros: #{rechazada.litros} / grasa: #{rechazada.grasa}: #{formatear_motivo(rechazada.motivo)} "
          end)
          |> Enum.join("\n")
      end

    motivos_texto =
      conteo
      |> Util.convertir_coleccion_mensaje(fn {motivo, cantidad} ->
        "  - #{formatear_motivo(motivo)}: #{cantidad}"
      end)
      |> Enum.join("\n")

    "  Total de rechazos: #{total}\n" <>
      detalle_texto <> "\n  Conteo por motivo:\n" <> motivos_texto
  end

  # Formatea el motivo que viene como clave en formato snake_case
  defp formatear_motivo(motivo) when is_atom(motivo),
    do: motivo |> Atom.to_string() |> String.replace("_", " ")

  defp formatear_motivo(motivo), do: to_string(motivo)

  # Muestran la información de los tanques como su nombre, capacidad, etc...
  defp render_tanques([]), do: "  No hay datos de tanques."

  defp render_tanques(tanques) do
    tanques
    |> Util.convertir_coleccion_mensaje(fn t ->
      "  - #{t.nombre}: #{t.litros_almacenados} L / #{t.capacidad_maximo} L (#{t.ocupacion_tanque}%)\n"
    end)
    |> Enum.join()
  end

  # Muestran los litros por dia y si se cumplió no la meta diaria
  defp render_litros_por_dia(%{detalle_diario: detalle, resumen: resumen}) do
    texto_detalle =
      detalle
      |> Util.convertir_coleccion_mensaje(fn r ->
        estado_meta = if r.alcanzo_meta, do: "cumplió meta", else: "no cumplió"
        "  - Día #{r.dia}: #{r.litros} L (#{estado_meta})\n"
      end)
      |> Enum.join()

    texto_resumen =
      """
      Resumen:
        - Cumplió todos los días: #{formatear_booleano(resumen.cumplio_todos_los_dias)}
        - Cumplió al menos un día: #{formatear_booleano(resumen.cumplio_al_menos_un_dia)}
      """

    texto_detalle <> "\n" <> texto_resumen
  end

  defp formatear_booleano(true), do: "Sí"
  defp formatear_booleano(false), do: "No"

  # Muestra al productor con mas litros entregados cada día y a quien o quienes ocuparon el primer lugar más dias
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

  # Muestra las liquidaciones de cada productor
  defp render_liquidaciones([]), do: "  No hay liquidaciones."

 defp render_liquidaciones(liquidaciones) do
  liquidaciones
  |> Enum.with_index(1) # Asigna el índice empezando en 1
  |> Util.convertir_coleccion_mensaje(fn {liquidacion, i} ->
    "  #{i}. #{liquidacion.nombre_productor} (#{liquidacion.codigo_productor})\n" <>
      "      Litros: #{liquidacion.litros}\n" <>
      "      Valor de entregas: $#{Util.formatear_dinero(liquidacion.valor_entregas)}\n" <>
      "      Bonificaciones: $#{Util.formatear_dinero(liquidacion.bonificaciones)}\n" <>
      "      Transporte: $#{Util.formatear_dinero(liquidacion.transporte)}\n" <>
      "      Neto: $#{Util.formatear_dinero(liquidacion.neto)}\n"
  end)
  |> Enum.join("\n")
end
  # Muestra al productor con mejor calidad
  defp render_productor_mejor_calidad(nil), do: "  No hay productores con al menos 3 entregas."

  defp render_productor_mejor_calidad(productores) do
    productores
    |> Util.convertir_coleccion_mensaje(fn %{     productor: productor, grasa_ponderada: grasa, total_entregas: total   } ->
      nombre = if productor, do: productor.nombre, else: "Desconocido"
      "  - #{nombre}: #{grasa}% de grasa ponderada (#{total} entregas)"
    end)
    |> Enum.join("\n")
  end

  # Muestra el total pagado por el centro de acopio
  defp render_total_pagado(total) do
    "  Litros totales: #{total.total_litros}\n" <>
      "  Total bruto: $#{Util.formatear_dinero(total.total_bruto)}\n" <>
      "  Bonificaciones: $#{Util.formatear_dinero(total.total_bonos_empresa)}\n" <>
      "  Transporte: $#{Util.formatear_dinero(total.total_transporte)}\n" <>
      "  Total neto pagado: $#{Util.formatear_dinero(total.total_pagado)}\n" <>
      "  Costo promedio por litro: $#{Util.formatear_dinero(total.costo_promedio_litro)}"
  end

  # Muestra a los productores que realizaron al menos una entrega válida en todos los tanques
  defp render_productores_todos_los_tanques(productores) do
    case productores do
      [] ->
        "  No hubo productores en todos los tanques."

      _ ->
        productores
        |> Util.convertir_coleccion_mensaje(fn p ->
          if p == nil, do: "  - Desconocido", else: "  - #{p.nombre}"
        end)
        |> Enum.join("\n")
    end
  end
end
