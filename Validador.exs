defmodule Validador do

  @doc """
    Valida una entrega individual según las 5 reglas de negocio en orden estricto.
    Retorna {:ok, entrega} si cumple todas las reglas, o {:error, motivo} si falla alguna.
  """
  def validar_entrega(entrega, productores, tanques) do
    with {:ok, _} <- verificar_productor(entrega.productor, productores),
         {:ok, _} <- verificar_tanque(entrega.tanque, tanques),
         {:ok, _} <- verificar_dia(entrega.dia),
         {:ok, _} <- verificar_litros(entrega.litros),
         {:ok, _} <- verificar_grasa(entrega.grasa) do
      {:ok, entrega}
    else
      {:error, motivo} -> {:error, motivo, entrega}
    end
  end

  @doc """
    Procesa toda la lista de entregas y las separa en dos listas: válidas e inválidas.
  """
  def clasificar_entregas(entregas, productores, tanques) do
    {validas_invertidas, invalidas_invertidas} = Enum.reduce(entregas, {[], []}, fn entrega, acumulador -> {validas, invalidas} = acumulador

      case validar_entrega(entrega, productores, tanques) do
        {:ok, entrega_valida} -> {[entrega_valida | validas], invalidas}

        {:error, motivo, entrega_rechazada} -> {validas, [{entrega_rechazada, motivo} | invalidas]}
      end
    end)

    validas = Enum.reverse(validas_invertidas)
    invalidas = Enum.reverse(invalidas_invertidas)
    {validas, invalidas}
  end

#FUNCIONES PRIVADAS PARA VALIDAR CADA REGLA DE NEGOCIO

  defp verificar_productor(codigo, productores) do
    if Enum.any?(productores, fn p -> p.codigo == codigo end) do
      {:ok, codigo}
    else
      {:error, :productor_desconocido}
    end
  end

  defp verificar_tanque(id_tanque, tanques) do
    if Enum.any?(tanques, fn t -> t.id == id_tanque end) do
      {:ok, id_tanque}
    else
      {:error, :tanque_desconocido}
    end
  end

  defp verificar_dia(dia) when is_integer(dia) and dia in 1..6, do: {:ok, dia}
  defp verificar_dia(_), do: {:error, :dia_invalido}

  defp verificar_litros(litros) when is_number(litros) and litros > 0 and litros <= 800, do: {:ok, litros}
  defp verificar_litros(_), do: {:error, :litros_fuera_de_rango}

  defp verificar_grasa(grasa) when is_number(grasa) and grasa >= 0 and grasa <= 15, do: {:ok, grasa}
  defp verificar_grasa(_), do: {:error, :porcentaje_invalido}
end
