defmodule ValidacionRegistro do
  # (productor;tanque;dia;litros;grasa)

  def main do
    entrada = Util.ingresar("Ingrese una entrega adicional: ", :texto)

    validar_registro(entrada)
    |> IO.inspect()
  end

  def validar_registro(cadena) do
    case String.trim(cadena) do
      "" ->
        # Si apretó Enter, omitimos validaciones y retornamos la señal
        {:ok, :omitida}

      cadena ->
        campos =
          cadena
          |> String.split(";")
          |> Enum.map(&String.trim/1)

        with [productor, tanque, dia_str, litros_str, grasa_str] <- campos,
             :ok <- validar_no_vacio(productor),
             :ok <- validar_no_vacio(tanque),
             {:ok, dia} <- validar_entero(dia_str),
             {:ok, litros} <- validar_flotante(litros_str),
             {:ok, grasa} <- validar_flotante(grasa_str) do
          {:ok,
           %{
             productor: productor,
             tanque: tanque,
             dia: dia,
             litros: litros,
             grasa: grasa
           }}
        else
          _ -> {:error, :formato_invalido}
        end
    end
  end

  defp validar_no_vacio(texto) do
    if String.length(texto) > 0, do: :ok, else: :error
  end

  defp validar_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> :error
    end
  end

  defp validar_flotante(texto) do
    case Float.parse(texto) do
      {numero, ""} ->
        {:ok, numero}

      _ ->
        case Integer.parse(texto) do
          {numero, ""} -> {:ok, numero / 1.0}
          _ -> :error
        end
    end
  end
end

ValidacionRegistro.main()
