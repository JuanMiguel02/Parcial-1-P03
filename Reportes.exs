defmodule Reportes do
  @entregas Datos.entregas()
  @tanques Datos.tanques()
  @productores Datos.productores()

  def generar_reporte() do
    generar_reporte_tanques(@entregas, @tanques)
    |> IO.inspect()

    generar_reporte_litros_recibidos_dias(@entregas, 2000)
    |> IO.inspect()

    generar_reporte_productor_mas_litros_entregados(@entregas, @productores)
    |> IO.inspect()
  end

   defp generar_reporte_entregas_rechazadas(entregas) do

   end

  defp generar_reporte_tanques(entregas, tanques) do

    litros_por_tanque = Enum.reduce(entregas, %{}, fn entrega, acumulador ->
      Map.update(acumulador, entrega.tanque, entrega.litros, fn suma -> suma + entrega.litros end)
    end)

    ocupacion_tanques = Enum.map(tanques, fn tanque ->
      litros_actuales = Map.get(litros_por_tanque, tanque.id, 0)
      porcentaje_ocupacion = Float.round((litros_actuales / tanque.capacidad) * 100, 2)

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

  defp generar_reporte_litros_recibidos_dias(entregas, meta) do
    litros_por_dia = Enum.reduce(entregas, %{}, fn entrega, acumulador ->
      Map.update(acumulador, entrega.dia, entrega.litros, fn suma -> suma + entrega.litros end)
    end)

    reporte = Enum.map(1..6, fn dia ->
      total = Map.get(litros_por_dia, dia, 0)
      %{
        dia: dia,
        litros: total,
        alcanzo_meta: if(total >= meta, do: "Sí", else: "No")
      }
    end)

    completado_todos_los_dias = if Enum.all?(reporte, fn r -> r.alcanzo_meta end), do: "Si", else: "No"
    completado_al_menos_un_dia = if Enum.any?(reporte, fn r -> r.alcanzo_meta end), do: "Si", else: "No"

    %{
      detalle_diario: reporte,
      resumen: %{
        cumplio_todos_los_dias: completado_todos_los_dias,
        cumplio_al_menos_un_dia: completado_al_menos_un_dia
      }
    }

  end

  defp generar_reporte_liquidacion_productores(entregas) do

  end

  defp generar_reporte_productor_mas_litros_entregados(entregas, productores) do
    reporte_diario = calcular_ganadores_diarios(entregas, productores)
    productor_mas_dias = calcular_ganador_frecuente(reporte_diario)

    %{
      detalle_diario: reporte_diario,
      productor_mas_dias: productor_mas_dias
    }

  end

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

  # 3. Lógica para calcular el ganador global más frecuente
  defp calcular_ganador_frecuente(reporte_diario) do
    todos_los_ganadores = Enum.flat_map(reporte_diario, fn r -> r.ganadores end)

    if todos_los_ganadores == [] do
      "Ninguno"
    else
      victorias_por_productor =
        Enum.reduce(todos_los_ganadores, %{}, fn ganador, acc ->
          Map.update(acc, ganador, 1, fn cantidad -> cantidad + 1 end)
        end)

      {_ganador, max_victorias} =
        Enum.max_by(victorias_por_productor, fn {_ganador, victorias} -> victorias end)

      victorias_por_productor
      |> Enum.filter(fn {_ganador, victorias} -> victorias == max_victorias end)
      |> Enum.map(fn {ganador, victorias} ->
        "#{ganador.nombre} (#{victorias} días)"
      end)
      |> Enum.join(", ")
    end
  end

end

Reportes.generar_reporte()
