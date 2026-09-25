defmodule Datos do
  def productores do
    [
      %{codigo: "P01", nombre: "Marta Gómez", transporte: true},
      %{codigo: "P02", nombre: "Luis Cardona", transporte: false},
      %{codigo: "P03", nombre: "Paco Jones", transporte: true},
      %{codigo: "P04", nombre: "Julian Casablancas", transporte: true},
      %{codigo: "P05", nombre: "Ana Martínez", transporte: true},
      %{codigo: "P06", nombre: "Carlos Restrepo", transporte: false},
      %{codigo: "P07", nombre: "Elena Naranjo", transporte: false},
      %{codigo: "P08", nombre: "Roberto Gómez", transporte: false},
      %{codigo: "P09", nombre: "Sofia Vergara", transporte: true},
      %{codigo: "P10", nombre: "Alex Turner", transporte: false}
    ]
  end

  def tanques do
    [
      %{id: "T1", nombre: "Tanque Norte", capacidad: 5000},
      %{id: "T2", nombre: "Tanque Central", capacidad: 4000},
      %{id: "T3", nombre: "Tanque Sur", capacidad: 6000},
      %{id: "T4", nombre: "Tanque Six Seven", capacidad: 7000}
    ]
  end

  def entregas do
    [
      # ==========================================
      # 80 ENTREGAS VÁLIDAS
      # ==========================================
      # --- Día 1 ---
      %{productor: "P01", tanque: "T1", dia: 1, litros: 140, grasa: 2.8},
      %{productor: "P01", tanque: "T2", dia: 1, litros: 160, grasa: 2.9},
      %{productor: "P02", tanque: "T1", dia: 1, litros: 155, grasa: 3.0},
      %{productor: "P02", tanque: "T2", dia: 1, litros: 175, grasa: 3.1},
      %{productor: "P03", tanque: "T1", dia: 1, litros: 170, grasa: 3.2},
      %{productor: "P03", tanque: "T2", dia: 1, litros: 190, grasa: 3.3},
      %{productor: "P04", tanque: "T1", dia: 1, litros: 185, grasa: 3.4},
      %{productor: "P04", tanque: "T2", dia: 1, litros: 205, grasa: 3.5},
      %{productor: "P05", tanque: "T1", dia: 1, litros: 200, grasa: 3.6},
      %{productor: "P05", tanque: "T2", dia: 1, litros: 220, grasa: 3.7},
      %{productor: "P06", tanque: "T3", dia: 1, litros: 235, grasa: 3.8},
      %{productor: "P06", tanque: "T4", dia: 1, litros: 255, grasa: 3.9},
      %{productor: "P07", tanque: "T3", dia: 1, litros: 250, grasa: 4.0},
      %{productor: "P07", tanque: "T4", dia: 1, litros: 270, grasa: 4.1},

      # --- Día 2 ---
      %{productor: "P01", tanque: "T1", dia: 2, litros: 145, grasa: 2.8},
      %{productor: "P01", tanque: "T2", dia: 2, litros: 165, grasa: 2.9},
      %{productor: "P02", tanque: "T1", dia: 2, litros: 160, grasa: 3.0},
      %{productor: "P02", tanque: "T2", dia: 2, litros: 180, grasa: 3.1},
      %{productor: "P03", tanque: "T1", dia: 2, litros: 175, grasa: 3.2},
      %{productor: "P03", tanque: "T2", dia: 2, litros: 195, grasa: 3.3},
      %{productor: "P04", tanque: "T1", dia: 2, litros: 190, grasa: 3.4},
      %{productor: "P04", tanque: "T2", dia: 2, litros: 210, grasa: 3.5},
      %{productor: "P05", tanque: "T1", dia: 2, litros: 205, grasa: 3.6},
      %{productor: "P05", tanque: "T2", dia: 2, litros: 225, grasa: 3.7},
      %{productor: "P08", tanque: "T3", dia: 2, litros: 280, grasa: 4.2},
      %{productor: "P08", tanque: "T4", dia: 2, litros: 300, grasa: 4.3},
      %{productor: "P09", tanque: "T3", dia: 2, litros: 295, grasa: 4.4},

      # --- Día 3 ---
      %{productor: "P01", tanque: "T3", dia: 3, litros: 190, grasa: 3.0},
      %{productor: "P01", tanque: "T4", dia: 3, litros: 210, grasa: 3.1},
      %{productor: "P02", tanque: "T3", dia: 3, litros: 205, grasa: 3.2},
      %{productor: "P02", tanque: "T4", dia: 3, litros: 225, grasa: 3.3},
      %{productor: "P03", tanque: "T3", dia: 3, litros: 220, grasa: 3.4},
      %{productor: "P03", tanque: "T4", dia: 3, litros: 240, grasa: 3.5},
      %{productor: "P04", tanque: "T3", dia: 3, litros: 235, grasa: 3.6},
      %{productor: "P04", tanque: "T4", dia: 3, litros: 255, grasa: 3.7},
      %{productor: "P09", tanque: "T4", dia: 3, litros: 315, grasa: 4.5},
      %{productor: "P10", tanque: "T1", dia: 3, litros: 280, grasa: 4.6},
      %{productor: "P10", tanque: "T2", dia: 3, litros: 300, grasa: 4.7},
      %{productor: "P06", tanque: "T1", dia: 3, litros: 200, grasa: 3.8},
      %{productor: "P07", tanque: "T2", dia: 3, litros: 220, grasa: 4.0},

      # --- Día 4 ---
      %{productor: "P01", tanque: "T1", dia: 4, litros: 155, grasa: 2.8},
      %{productor: "P01", tanque: "T2", dia: 4, litros: 175, grasa: 2.9},
      %{productor: "P02", tanque: "T1", dia: 4, litros: 170, grasa: 3.0},
      %{productor: "P02", tanque: "T2", dia: 4, litros: 190, grasa: 3.1},
      %{productor: "P03", tanque: "T1", dia: 4, litros: 185, grasa: 3.2},
      %{productor: "P03", tanque: "T2", dia: 4, litros: 205, grasa: 3.3},
      %{productor: "P04", tanque: "T1", dia: 4, litros: 200, grasa: 3.4},
      %{productor: "P04", tanque: "T2", dia: 4, litros: 220, grasa: 3.5},
      %{productor: "P05", tanque: "T3", dia: 4, litros: 250, grasa: 3.8},
      %{productor: "P05", tanque: "T4", dia: 4, litros: 270, grasa: 3.9},
      %{productor: "P06", tanque: "T3", dia: 4, litros: 265, grasa: 4.0},
      %{productor: "P06", tanque: "T4", dia: 4, litros: 285, grasa: 4.1},
      %{productor: "P07", tanque: "T1", dia: 4, litros: 240, grasa: 4.1},

      # --- Día 5 ---
      %{productor: "P01", tanque: "T3", dia: 5, litros: 200, grasa: 3.0},
      %{productor: "P01", tanque: "T4", dia: 5, litros: 220, grasa: 3.1},
      %{productor: "P02", tanque: "T3", dia: 5, litros: 215, grasa: 3.2},
      %{productor: "P02", tanque: "T4", dia: 5, litros: 235, grasa: 3.3},
      %{productor: "P03", tanque: "T3", dia: 5, litros: 230, grasa: 3.4},
      %{productor: "P03", tanque: "T4", dia: 5, litros: 250, grasa: 3.5},
      %{productor: "P04", tanque: "T3", dia: 5, litros: 245, grasa: 3.6},
      %{productor: "P04", tanque: "T4", dia: 5, litros: 265, grasa: 3.7},
      %{productor: "P08", tanque: "T1", dia: 5, litros: 270, grasa: 4.2},
      %{productor: "P08", tanque: "T2", dia: 5, litros: 290, grasa: 4.3},
      %{productor: "P09", tanque: "T1", dia: 5, litros: 285, grasa: 4.4},
      %{productor: "P09", tanque: "T2", dia: 5, litros: 305, grasa: 4.5},
      %{productor: "P10", tanque: "T3", dia: 5, litros: 310, grasa: 4.6},

      # --- Día 6 ---
      %{productor: "P01", tanque: "T1", dia: 6, litros: 165, grasa: 2.8},
      %{productor: "P01", tanque: "T2", dia: 6, litros: 185, grasa: 2.9},
      %{productor: "P02", tanque: "T1", dia: 6, litros: 180, grasa: 3.0},
      %{productor: "P02", tanque: "T2", dia: 6, litros: 200, grasa: 3.1},
      %{productor: "P03", tanque: "T1", dia: 6, litros: 195, grasa: 3.2},
      %{productor: "P03", tanque: "T2", dia: 6, litros: 215, grasa: 3.3},
      %{productor: "P04", tanque: "T1", dia: 6, litros: 210, grasa: 3.4},
      %{productor: "P04", tanque: "T2", dia: 6, litros: 230, grasa: 3.5},
      %{productor: "P05", tanque: "T3", dia: 6, litros: 260, grasa: 3.8},
      %{productor: "P05", tanque: "T4", dia: 6, litros: 280, grasa: 3.9},
      %{productor: "P07", tanque: "T3", dia: 6, litros: 275, grasa: 4.1},
      %{productor: "P07", tanque: "T4", dia: 6, litros: 295, grasa: 4.2},
      %{productor: "P10", tanque: "T4", dia: 6, litros: 330, grasa: 4.7},

      # ==========================================
      # 10 ENTREGAS INVÁLIDAS (2 POR CADA MOTIVO)
      # ==========================================
      # 1. Código de productor inexistente
      %{productor: "P99", tanque: "T1", dia: 1, litros: 200, grasa: 3.5},
      %{productor: "P88", tanque: "T2", dia: 2, litros: 150, grasa: 4.0},

      # 2. Tanque inexistente
      %{productor: "P01", tanque: "T99", dia: 3, litros: 300, grasa: 3.8},
      %{productor: "P02", tanque: "T88", dia: 4, litros: 220, grasa: 3.2},

      # 3. Número de día fuera del rango 1 a 6
      %{productor: "P03", tanque: "T3", dia: 0, litros: 250, grasa: 3.9},
      %{productor: "P04", tanque: "T4", dia: 7, litros: 210, grasa: 3.6},

      # 4. Litros fuera del rango (menores que 0 o mayores a 800)
      %{productor: "P05", tanque: "T1", dia: 5, litros: -10, grasa: 3.5},
      %{productor: "P06", tanque: "T2", dia: 6, litros: 850, grasa: 4.1},

      # 5. Porcentaje de grasa fuera del rango 0 a 15
      %{productor: "P07", tanque: "T3", dia: 1, litros: 300, grasa: -0.5},
      %{productor: "P08", tanque: "T4", dia: 2, litros: 400, grasa: 15.5}
    ]
  end
end
