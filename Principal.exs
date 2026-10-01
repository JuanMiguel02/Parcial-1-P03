# Juan Miguel Henao Gaviria
# Valeria Zapata Giraldo
#Cargar las dependencias automáticamente
Code.require_file("Configuracion.exs")
Code.require_file("Util.ex")
Code.require_file("Datos.exs")
Code.require_file("CalidadLeche.exs")
Code.require_file("Liquidacion.exs")
Code.require_file("ValidacionRegistro.exs")
Code.require_file("Validador.exs")
Code.require_file("Ranking.exs")
Code.require_file("ProcesamientoReportes.exs")
Code.require_file("GeneracionReportes.exs")
Code.require_file("GeneracionComprobante.exs")
Code.require_file("CombinacionInformacionCentroVecino.exs")


defmodule CentroAcopioLeche do
  @moduledoc """
    Módulo principal del Centro de Acopio de Leche.

    Se encarga de: lectura de datos, ingreso de entrega opcional,
    validación de registros, generación del reporte general, emisión de comprobante
    individual y demostración de combinación de mapas con Map.merge/3.
  """
  def main do

    productores = Datos.productores()
    tanques = Datos.tanques()
    entregas_iniciales = Datos.entregas()

    entregas_totales = solicitar_entrega_adicional(entregas_iniciales)

     #Medición de tiempo de ejecución para la clasificación de entregas
    {validas, invalidas} = medir_tiempo("Clasificación de entregas", fn -> Validador.clasificar_entregas(entregas_totales, productores, tanques)
    end)

    rechazadas = Enum.map(invalidas, fn {entrega, motivo} -> Map.put(entrega, :motivo, motivo) end)

    #Medición de tiempo de ejecución para la generación del reporte
    reporte = medir_tiempo("Generación de reporte general", fn -> ProcesamientoReportes.generar_reporte(validas, rechazadas, tanques, productores)
    end)
    Util.mostrar(GeneracionReportes.mostrar(reporte), :mensaje)

    solicitar_y_mostrar_comprobante(productores, validas)

    CombinacionLitros.demostrar_combinacion(reporte.litros_por_dia)


end
    #FUNCIONES PRIVADAS
    defp solicitar_entrega_adicional(entregas_actuales) do
      entrada = "Ingrese una entrega adicional (productor;tanque;dia;litros;grasa) o Enter para omitir: "
      |> Util.ingresar(:texto)

      case ValidacionRegistro.validar_registro(entrada) do
        {:ok, :omitida} ->
          Util.mostrar("Se omitió el ingreso de la entrega adicional.\n", :mensaje)
          entregas_actuales

        {:ok, nueva_entrega} ->
          Util.mostrar("Entrega adicional registrada correctamente.\n", :mensaje)
          entregas_actuales ++ [nueva_entrega]

        {:error, :formato_invalido} ->
          Util.mostrar("Error: Formato inválido. Se continuará con los datos iniciales.\n", :error)
          entregas_actuales
      end
    end

    defp solicitar_y_mostrar_comprobante(productores, entregas_validas) do
      "\nIngrese el código del productor para generar su comprobante: "
      |> Util.ingresar(:texto)
      |> GeneracionComprobante.generar_comprobante_productor(productores, entregas_validas)
      |> Util.mostrar(:mensaje)
    end

    defp medir_tiempo(nombre_proceso, funcion) do
        {tiempo_us, resultado} = :timer.tc(funcion)
        tiempo_ms = tiempo_us / 1000
        Util.mostrar("[timer.tc/1] Tiempo de #{nombre_proceso}: #{tiempo_ms} ms", :mensaje)
        resultado
      end
end
CentroAcopioLeche.main()
