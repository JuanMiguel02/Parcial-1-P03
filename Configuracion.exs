# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
defmodule Parametros do
  @moduledoc """
  Centraliza algunos de los los parámetros  de operación del centro de acopio de leche.

  Por ejemplo, proporciona los días de recepción y los límites usados al validar entregas
  y generar reportes.
  """

  @dias_recepcion 1..6
  @meta_diaria_centro 2000
  @maximo_litros_entrega 800

  @doc "Devuelve el rango de días de recepción, del 1 al 6."
  def dias_recepcion, do: @dias_recepcion

  @doc "Devuelve la meta diaria del centro, expresada en litros."
  def meta_diaria_centro, do: @meta_diaria_centro

  @doc "Devuelve el máximo de litros permitido por entrega."
  def maximo_litros_entrega, do: @maximo_litros_entrega
end
