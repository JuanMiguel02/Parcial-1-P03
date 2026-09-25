defmodule Util do
  def mostrar(mensaje, :mensaje) do
    mensaje
    |> IO.puts()
  end

  def mostrar(mensaje, :error) do
    IO.puts(:standard_error, mensaje)
  end

  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar(mensaje, :entero) do
    ingresar(mensaje, &Integer.parse/1, :entero)
  end

  def ingresar(mensaje, :real) do
    ingresar(mensaje, &Float.parse/1, :real)
  end

  def ingresar(mensaje, :booleano) do
    ingresar(mensaje,
     fn texto ->
      case String.downcase(texto) do
        "s" -> {true, ""}
        "n" -> {false, ""}
        _ -> :error
      end
    end,
    :booleano)
  end

  def ingresar(mensaje, :coleccion_enteros) do
    ingresar(fn -> ingresar(mensaje, :entero) end, :coleccion)
  end

  def ingresar(mensaje, :coleccion_reales) do
    ingresar(fn -> ingresar(mensaje, :real) end, :coleccion)
  end

  def ingresar(mensaje, :coleccion_textos) do
    ingresar(fn -> ingresar(mensaje, :texto) end, :coleccion)
  end

  def ingresar(ingresar_elemento, :coleccion) do
    ingresar_coleccion(ingresar_elemento, [])
  end

  def convertir_coleccion_mensaje(coleccion, formato \\ fn elemento -> " - #{elemento}\n" end) do
    Enum.map(coleccion , formato)
  end

  def ordenar_coleccion(coleccion, sentido \\ :asc, obtener_campo \\ & &1) do
    Enum.sort_by(coleccion, obtener_campo, sentido)
  end

  def aplicar_filtro_longitud(coleccion, longitud) do
    Enum.filter(coleccion, &(String.length(&1) <= longitud))
  end

  def aplicar_filtro_inicial(coleccion, inicio) do
    Enum.filter(coleccion, &(String.starts_with?(&1, inicio)))
  end

  defp ingresar(mensaje, funcion, tipo_dato) do
    valor = mensaje
    |> ingresar(:texto)
    |> funcion.()

    case valor do
      {numero, _} -> numero
      :error ->
        mostrar("Error, tipo de dato inválido para: #{tipo_dato} ", :error)
        ingresar(mensaje, funcion, tipo_dato)
    end
  end

  defp ingresar_coleccion(ingresar_elemento, coleccion_actual) do
    elemento = ingresar_elemento.()

    nueva_coleccion = [elemento | coleccion_actual]

    case ingresar("\n ¿Hay más datos (s/n)?", :booleano) do
      true -> ingresar_coleccion(ingresar_elemento, nueva_coleccion)
      false -> Enum.reverse(nueva_coleccion)
    end
  end

end
