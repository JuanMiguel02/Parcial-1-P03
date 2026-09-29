defmodule Liquidacion do
  @moduledoc """
  Calcula los valores económicos y las liquidaciones de los productores.

  Incluye valor de entregas, bonificaciones, descuento de transporte y neto
  a pagar, además del detalle agrupado por día.
  """

  @tarifa_base 1800
  @litros_bonificacion 450
  @bonificacion_diaria 25000
  @costo_transporte 18000

  @doc """
    Calcula el valor económico de una entrega individual de leche.

    Multiplica los litros entregados por la tarifa base  y aplica
    un factor de ajuste (bonificación o descuento) según el porcentaje de grasa.
  """

  def valor_entrega(entrega) do
    litros = entrega.litros
    grasa = entrega.grasa

    bruto = litros * @tarifa_base

    porcentaje =
      cond do
        grasa >= 3.5 -> 0.06
        grasa >= 3.0 -> 0.0
        grasa >= 2.5 -> -0.08
        true -> -0.20
      end

    ajuste = bruto * porcentaje
    bruto + ajuste
  end

  # FUNCIONES PRIVADAS PARA CALCULAR LIQUIDACIONES

  defp dias_con_entrega(entregas_productor) do
    entregas_productor
    |> Enum.map(fn entrega -> entrega.dia end)
    |> Enum.uniq()
  end

  defp bonificacion_volumen(entregas_productor) do
    entregas_productor
    |> Enum.group_by(fn entrega -> entrega.dia end)
    |> Enum.reduce(0, fn {_dia, entregas_dia}, ac ->
      litros_dia = Enum.reduce(entregas_dia, 0, fn entrega, suma -> suma + entrega.litros end)

      if litros_dia >= @litros_bonificacion do
        ac + @bonificacion_diaria
      else
        ac
      end
    end)
  end

  defp descuento_transporte(productor, entregas_productor) do
    if productor.transporte do
      dias_activos = length(dias_con_entrega(entregas_productor))
      dias_activos * @costo_transporte
    else
      0
    end
  end

  @doc """
    Liquida el pago total semanal de un productor individual.

    Calcula el subtotal por litros entregados (ajustado por porcentaje de grasa),
    suma las bonificaciones por volumen alcanzadas en días con 450 litros o más,
    y descuenta la tarifa de transporte de los días activos (si aplica).

    Retorna un mapa con el detalle financiero del productor.
  """
  def liquidar_productor(productor, entregas_validas) do
    entregas_p =
      Enum.filter(entregas_validas, fn entrega -> entrega.productor == productor.codigo end)

    detalle_dias = calcular_detalle_dias_entrega(entregas_p, productor)

    litros_totales = Enum.reduce(entregas_p, 0, fn entrega, ac -> ac + entrega.litros end)
    valor_entregas = Enum.reduce(entregas_p, 0, fn entrega, ac -> ac + valor_entrega(entrega) end)
    bonificaciones = bonificacion_volumen(entregas_p)
    transporte = descuento_transporte(productor, entregas_p)
    neto = valor_entregas + bonificaciones - transporte

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      detalle_dias: detalle_dias,
      total_entregas: length(entregas_p),
      litros: litros_totales,
      valor_entregas: valor_entregas,
      bonificaciones: bonificaciones,
      transporte: transporte,
      neto: neto
    }
  end

  # Calcula y agrupa las entregas de un productor por día
  defp calcular_detalle_dias_entrega(entregas, productor) do
    entregas
    |> Enum.group_by(& &1.dia)
    |> Enum.map(fn {dia, entregas_del_dia} ->
      litros_dia = Enum.sum_by(entregas_del_dia, & &1.litros)
      valor_dia = Enum.sum_by(entregas_del_dia, &valor_entrega/1)
      bono_dia = bonificacion_volumen(entregas_del_dia)
      transporte_dia = if productor.transporte, do: @costo_transporte, else: 0

      %{
        dia: dia,
        cantidad_entregas: length(entregas_del_dia),
        litros: litros_dia,
        valor_entregas: valor_dia,
        bonificacion: bono_dia,
        transporte: transporte_dia
      }
    end)
    |> Util.ordenar_coleccion(:asc, fn d -> d.dia end)
  end

  @doc """
    Liquida todos los productores de la lista de entregas válidas.
    Retorna una lista de mapas con el detalle financiero de cada productor.
  """
  def liquidar_todos(productores, entregas_validas) do
    Enum.map(productores, fn productor -> liquidar_productor(productor, entregas_validas) end)
  end
end
