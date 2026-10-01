# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
defmodule ProcesamientoReportes do
  @moduledoc """
  Genera los reportes estadísticos y financieros del centro de acopio.

  Recibe entregas válidas, entregas rechazadas, tanques y productores, y
  devuelve un mapa con la información necesaria para su impresión.
  """

  @doc """
  Genera el conjunto completo de reportes de la operación semanal.

  Las entregas rechazadas deben incluir el campo `:motivo`. Las entregas
  recibidas en `entregas` deben haber sido validadas previamente.
  """
  def procesar_reporte(entregas, entregas_rechazadas, tanques, productores) do
    %{
      entregas_rechazadas: generar_reporte_entregas_rechazadas(entregas_rechazadas),
      tanques: generar_reporte_tanques(entregas, tanques),
      litros_por_dia: generar_reporte_litros_recibidos_dias(entregas),
      liquidaciones: generar_reporte_liquidaciones_ordenado(entregas, productores),
      productor_mas_litros:
        generar_reporte_productor_mas_litros_entregados(entregas, productores),
      total_pagado: generar_reporte_total_pagado(entregas, productores),
      productor_mejor_calidad: generar_reporte_productor_mejor_calidad(entregas, productores),
      productores_en_todos_los_tanques:
        productores_en_todos_los_tanques(entregas, tanques, productores)
    }
  end

  # R1: Genera el reporte para las entregas rechazadas
  defp generar_reporte_entregas_rechazadas(entregas_rechazadas) do
    conteo_por_motivo =
      entregas_rechazadas
      |> Enum.map(fn rechazada -> rechazada.motivo end)
      |> Enum.frequencies()

    %{
      total_rechazos: length(entregas_rechazadas),
      detalle: entregas_rechazadas,
      conteo_por_motivo: conteo_por_motivo
    }
  end

  # R2 Genera el reporte para los tanques
  defp generar_reporte_tanques(entregas, tanques) do
    litros_por_tanque =
      Enum.reduce(entregas, %{}, fn entrega, acumulador ->
        Map.update(acumulador, entrega.tanque, entrega.litros, fn suma ->
          suma + entrega.litros
        end)
      end)

    ocupacion_tanques =
      Enum.map(tanques, fn tanque ->
        litros_actuales = Map.get(litros_por_tanque, tanque.id, 0)

        porcentaje_ocupacion =
          if tanque.capacidad > 0 do
            Float.round(litros_actuales / tanque.capacidad * 100, 2)
          else
            0.0
          end

        %{
          id_tanque: tanque.id,
          nombre: tanque.nombre,
          capacidad_maximo: tanque.capacidad,
          litros_almacenados: litros_actuales,
          ocupacion_tanque: porcentaje_ocupacion
        }
      end)

    Util.ordenar_coleccion(ocupacion_tanques, :desc, & &1.ocupacion_tanque)
  end

  # R3 Genera el reporte de los Litros recibidos por el centro en cada uno de los 6 días
  # e indicación de si se alcanzó la meta diaria
  defp generar_reporte_litros_recibidos_dias(entregas) do
    litros_por_dia =
      Enum.reduce(entregas, %{}, fn entrega, acumulador ->
        Map.update(acumulador, entrega.dia, entrega.litros, fn suma -> suma + entrega.litros end)
      end)

    reporte =
      Enum.map(Parametros.dias_recepcion(), fn dia ->
        total = Map.get(litros_por_dia, dia, 0)

        %{
          dia: dia,
          litros: total,
          alcanzo_meta: total >= Parametros.meta_diaria_centro()
        }
      end)

    %{
      detalle_diario: reporte,
      resumen: %{
        cumplio_todos_los_dias: Enum.all?(reporte, fn %{alcanzo_meta: valor} -> valor end),
        cumplio_al_menos_un_dia: Enum.any?(reporte, fn %{alcanzo_meta: valor} -> valor end)
      }
    }
  end

  # R4 Genera el reporte de las liquidaciones de los productores de mayor a menor
  defp generar_reporte_liquidaciones_ordenado(entregas, productores) do
    liquidaciones = Liquidacion.liquidar_todos(productores, entregas)
    Util.ordenar_coleccion(liquidaciones, :desc, fn liquidacion -> liquidacion.neto end)
  end

  # R5 Genera el reporte Productor con mayor cantidad de litros entregados cada día. Si hay empate aparecen todos.
  # Al final se indica quién ocupó el primer lugar en más días.
  defp generar_reporte_productor_mas_litros_entregados(entregas, productores) do
    reporte_diario = calcular_ganadores_diarios(entregas, productores)
    productor_mas_dias = calcular_ganador_frecuente(reporte_diario)

    %{
      detalle_diario: reporte_diario,
      productor_mas_dias: productor_mas_dias
    }
  end

  # Función auxiliar de R5 que devuelve al productor o los productores que más litros entregaron en más días
  defp calcular_ganadores_diarios(entregas, productores) do
    entregas
    |> Enum.group_by(& &1.dia)
    |> Enum.map(fn {dia, entregas_del_dia} ->
      # 1. Acumulamos litros diarios por productor
      litros_por_productor =
        entregas_del_dia
        |> Enum.reduce(%{}, fn e, acc ->
          Map.update(acc, e.productor, e.litros, &(&1 + e.litros))
        end)
        |> Enum.map(fn {cod, litros} ->
          info = Enum.find(productores, &(&1.codigo == cod))

          %{
            codigo: cod,
            nombre: if(info, do: info.nombre, else: "Desconocido"),
            litros: litros
          }
        end)

      # 2. Extraemos el/los ganadores del día con la función ranking
      ganadores_del_dia =
        Ranking.calcular(litros_por_productor,
          por: :litros,
          orden: :desc,
          limite: 1,
          permitir_empates: true
        )

      max_litros =
        case ganadores_del_dia do
          [primero | _] -> primero.litros
          [] -> 0
        end

      %{dia: dia, ganadores: ganadores_del_dia, max_litros: max_litros}
    end)
    |> Util.ordenar_coleccion(:asc, & &1.dia)
  end

  # Función auxiliar de R5 que devuelve al productor o los productores que más litros entregaron en más días
  defp calcular_ganador_frecuente(reporte_diario) do
    ganadores = Enum.flat_map(reporte_diario, & &1.ganadores)

    case ganadores do
      [] ->
        "Ninguno"

      _ ->
        # Agrupamos por código para evitar colisiones de nombres iguales
        victorias = Enum.frequencies_by(ganadores, & &1.codigo)
        max_victorias = victorias |> Map.values() |> Enum.max()

        victorias
        |> Enum.filter(fn {_codigo, cantidad} -> cantidad == max_victorias end)
        |> Enum.map(fn {codigo, cantidad} ->
          productor = Enum.find(ganadores, &(&1.codigo == codigo))
          "#{productor.nombre} (#{cantidad} días)"
        end)
        |> Enum.join(", ")
    end
  end

  # R6 genera el reporte del productor con mejor calidad de leche
  defp generar_reporte_productor_mejor_calidad(entregas, productores) do
    entregas
    |> Enum.group_by(fn entrega -> entrega.productor end)
    |> Enum.filter(fn {_cod, lista_entregas} -> length(lista_entregas) >= 3 end)
    |> Enum.map(fn {cod_productor, lista_entregas} ->
      grasa_ponderada = CalidadLeche.calcular_grasa_ponderada(lista_entregas)

      info_productor =
        Enum.find(productores, fn productor -> productor.codigo == cod_productor end)

      %{
        productor: info_productor,
        grasa_ponderada: Float.round(grasa_ponderada, 2),
        total_entregas: length(lista_entregas)
      }
    end)
    |> Ranking.calcular(por: :grasa_ponderada, orden: :desc, limite: 1, permitir_empates: true)
  end

  # R7 Genera el resumen general de la empresa, como cuanto se ha pagado, litros ingresados, bonos pagados, etc
  defp generar_reporte_total_pagado(entregas, productores) do
    liquidaciones = Liquidacion.liquidar_todos(productores, entregas)

    total_litros_empresa = Enum.sum(Enum.map(liquidaciones, & &1.litros))
    total_bruto_empresa = Enum.sum(Enum.map(liquidaciones, & &1.valor_entregas))
    total_bonos_empresa = Enum.sum(Enum.map(liquidaciones, & &1.bonificaciones))
    total_transporte_empresa = Enum.sum(Enum.map(liquidaciones, & &1.transporte))
    total_neto_pagado = Enum.sum(Enum.map(liquidaciones, & &1.neto))

    costo_promedio_litro =
      if total_litros_empresa > 0 do
        Float.round(total_neto_pagado / total_litros_empresa, 2)
      else
        0.0
      end

    %{
      total_litros: total_litros_empresa,
      total_bruto: total_bruto_empresa,
      total_bonos_empresa: total_bonos_empresa,
      total_transporte: total_transporte_empresa,
      total_pagado: total_neto_pagado,
      costo_promedio_litro: costo_promedio_litro
    }
  end

  # R8
  # Devuelve los productores que realizaron entregas en todos los tanques.
  # La comparación se hace usando los identificadores de tanque presentes en
  # tanques y las entregas válidas de cada productor.
  def productores_en_todos_los_tanques(entregas_validas, tanques, productores) do
    total_tanques = length(tanques)

    entregas_validas
    |> Enum.group_by(fn e -> e.productor end)
    |> Enum.filter(fn {_cod, entregas} ->
      entregas
      |> Enum.map(fn e -> e.tanque end)
      |> Enum.uniq()
      |> length() == total_tanques
    end)
    |> Enum.map(fn {cod_productor, _} ->
      Enum.find(productores, fn p -> p.codigo == cod_productor end)
    end)
  end
end
