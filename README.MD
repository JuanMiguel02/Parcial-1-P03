# Centro de Acopio de Leche — Programación III

Proyecto desarrollado en **Elixir** para la gestión, validación, procesamiento de calidad (porcentaje de grasa ponderado) y liquidación semanal de entregas de leche en un centro de acopio.

# Información del Proyecto

* Universidad del Quindío
* Programación III (Parcial 1)
* Julián E. Gutiérrez Posada
* Integrantes:
  * Juan Miguel Henao Gaviria
  * Valeria Zapata Giraldo

# Instrucciones
## Copiar el repositorio

```bash
git clone https://github.com/JuanMiguel02/Parcial-1-P03
```

---

## Ejecutar el programa de Elixir

### 1. Ejecutar el script simple (`.exs`)
```bash
elixir Principal.exs
```

# Estructura del Código

* Configuracion.exs: Parámetros globales y constantes.
* Datos.exs: Colecciones con la información inicial de productores, tanques y entregas registradas.
* Validador.exs: Evaluación de las reglas de negocio y clasificación de entregas mediante encadenamiento con 'with'.
* ValidacionRegistro.exs: Parseo y validación del formato para la entrega adicional solicitada por consola.
* CalidadLeche.exs: Cálculos de calidad y promedios de porcentaje de grasa ponderados por volumen (R6).
* Liquidacion.exs: Lógica para el cálculo de ajustes por calidad, bonificaciones diarias por volumen y deducciones de transporte.
* ProcesamientoReportes.exs: Consolidación y procesamiento de indicadores para los reportes R1 a R8.
* GeneracionReportes.exs: Formateo de texto legible para la visualización del reporte general en consola.
* GeneracionComprobante.exs: Generación del comprobante de pago individual por código de productor.
* CombinacionInformacionCentroVecino.exs: Módulo de investigación para la fusión de mapas de producción mediante 'Map.merge/3'.
* Util.ex: Funciones auxiliares.
* Principal.exs: Orquestador principal del flujo y medición de rendimiento mediante ':timer.tc/1'.
