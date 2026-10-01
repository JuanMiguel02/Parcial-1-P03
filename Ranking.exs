# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
defmodule Ranking do
  @moduledoc """
  Módulo encargado de clasificar y ordenar colecciones de datos basadas en mapas
  u otras estructuras

  Permite aplicar criterios de ordenamiento dinámicos, limitar el número de
  resultados y gestionar empates en las primeras posiciones mediante opciones
  configurables pasadas como una Keyword List.
  """

  @doc """
  Calcula la clasificación de una lista de mapas o estructuras.

  ## Opciones (`opts`)

    * `:por` - Atributo del mapa/estructura a evaluar (ej. `:litros`, `:grasa_ponderada`). Obligatorio.
    * `:orden` - Criterio de ordenamiento: `:desc` (por defecto) o `:asc`.
    * `:limite` - Cantidad de elementos a retornar: `:todos` (por defecto) o un entero mayor a `0`.
    * `:permitir_empates` - Booleano (`false` por defecto). Si es `true` y `limite: 1`,
      retorna todos los elementos que igualen el valor máximo del primer lugar.

  ## Ejemplos

      iex> candidatos = [
      ...>   %{nombre: "Ana", grasa: 4.5},
      ...>   %{nombre: "Carlos", grasa: 5.1},
      ...>   %{nombre: "Beatriz", grasa: 5.1}
      ...> ]
      iex> Ranking.calcular(candidatos, por: :grasa, limite: 1, permitir_empates: true)
      [
        %{nombre: "Carlos", grasa: 5.1},
        %{nombre: "Beatriz", grasa: 5.1}
      ]

      iex> Ranking.calcular(candidatos, por: :grasa, limite: 2)
      [
        %{nombre: "Carlos", grasa: 5.1},
        %{nombre: "Beatriz", grasa: 5.1}
      ]

  """
  def calcular(coleccion, opts \\ [])

  def calcular([], _opts), do: []

  def calcular(coleccion, opts) do
    criterio = Keyword.get(opts, :por)
    orden = Keyword.get(opts, :orden, :desc)
    limite = Keyword.get(opts, :limite, :todos)
    permitir_empates = Keyword.get(opts, :permitir_empates, false)

    # 1. Ordenamos la colección según el criterio indicado
    lista_ordenada = Util.ordenar_coleccion(coleccion, orden, &Map.get(&1, criterio))

    # 2. Manejo de empates en el primer puesto o corte tradicional por límite
    if permitir_empates and limite == 1 do
      primer_valor = Map.get(hd(lista_ordenada), criterio)
      Enum.filter(lista_ordenada, &(Map.get(&1, criterio) == primer_valor))
    else
      aplicar_limite(lista_ordenada, limite)
    end
  end

  defp aplicar_limite(lista, :todos), do: lista
  defp aplicar_limite(lista, n) when is_integer(n), do: Enum.take(lista, n)
end
