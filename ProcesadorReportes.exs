defmodule ProcesadorReportes do
  @moduledoc """
  Genera los reportes estadísticos y financieros del centro de acopio.

  Recibe entregas válidas, entregas rechazadas, tanques y productores, y
  devuelve un mapa con la información necesaria para su impresión.
  """

  @meta_diaria 2000

  @doc """
  Genera el conjunto completo de reportes de la operación semanal.

  Las entregas rechazadas deben incluir el campo `:motivo`. Las entregas
  recibidas en `entregas` deben haber sido validadas previamente.
  """
  def generar_reporte(entregas, entregas_rechazadas, tanques, productores) do
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
        porcentaje_ocupacion = Float.round(litros_actuales / tanque.capacidad * 100, 2)

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
  # e indicac de si se alcanzó la meta diaria
  defp generar_reporte_litros_recibidos_dias(entregas) do
    litros_por_dia =
      Enum.reduce(entregas, %{}, fn entrega, acumulador ->
        Map.update(acumulador, entrega.dia, entrega.litros, fn suma -> suma + entrega.litros end)
      end)

    reporte =
      Enum.map(1..6, fn dia ->
        total = Map.get(litros_por_dia, dia, 0)

        %{
          dia: dia,
          litros: total,
          alcanzo_meta: total >= @meta_diaria
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

  # Función auxiliar de R5 que devuelve a los productores que más litros entregaron por día
  defp calcular_ganadores_diarios(entregas, productores) do
    entregas_por_dia = Enum.group_by(entregas, fn e -> e.dia end)

    Enum.map(1..6, fn dia ->
      entregas_del_dia = Map.get(entregas_por_dia, dia, [])

      if entregas_del_dia == [] do
        %{dia: dia, ganadores: [], max_litros: 0}
      else
        litros_por_productor =
          Enum.reduce(entregas_del_dia, %{}, fn e, acc ->
            Map.update(acc, e.productor, e.litros, fn suma -> suma + e.litros end)
          end)

        {_cod_max, max_litros} =
          Enum.max_by(litros_por_productor, fn {_cod, litros} -> litros end)

        ganadores_del_dia =
          litros_por_productor
          |> Enum.filter(fn {_cod, litros} -> litros == max_litros end)
          |> Enum.map(fn {cod, _litros} ->
            productor_info = Enum.find(productores, fn p -> p.codigo == cod end)

            %{
              codigo: cod,
              nombre: if(productor_info, do: productor_info.nombre, else: "Desconocido")
            }
          end)

        %{dia: dia, ganadores: ganadores_del_dia, max_litros: max_litros}
      end
    end)
  end

  #Función auxiliar de R5 que devuelve al productor o los productores que más litros entregaron en más días
  defp calcular_ganador_frecuente(reporte_diario) do
    ganadores =
      reporte_diario
      |> Enum.flat_map(& &1.ganadores)

    case ganadores do
      [] ->
        "Ninguno"

      _ ->
        victorias =
          Enum.frequencies_by(ganadores, & &1.nombre)

        max_victorias =
          victorias
          |> Map.values()
          |> Enum.max()

        victorias
        |> Enum.filter(fn {_nombre, cantidad} -> cantidad == max_victorias end)
        |> Enum.map(fn {nombre, cantidad} -> "#{nombre} (#{cantidad} días)" end)
        |> Enum.join(", ")
    end
  end

  # R6 genera el reporte del productor con mejor calidad de leche
  defp generar_reporte_productor_mejor_calidad(entregas, productores) do
    candidatos =
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

    if candidatos == [] do
      nil
    else
      max_grasa = Enum.max_by(candidatos, & &1.grasa_ponderada).grasa_ponderada
      Enum.filter(candidatos, fn candidato -> candidato.grasa_ponderada == max_grasa end)
    end
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

  #Devuelve los productores que realizaron entregas en todos los tanques.

  #La comparación se hace usando los identificadores de tanque presentes en
  #tanques y las entregas válidas de cada productor.

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
