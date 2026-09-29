# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
defmodule ValidacionRegistro do
  @moduledoc """
  Valida registros de entrega introducidos como texto.

  El formato esperado es `productor;tanque;dia;litros;grasa`.
  """

  # (productor;tanque;dia;litros;grasa)

  @doc """
  Convierte y valida un registro de texto separado por punto y coma.

  Retorna `{:ok, entrega}` cuando el formato es válido, `{:ok, :omitida}`
  cuando la entrada está vacía, o `{:error, :formato_invalido}` en otro caso.
  """
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

  # Validaciones de entrada del usuario

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
