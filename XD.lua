--[=[
    ⭐ Experto Script con Rayfield UI (Krnl) ⭐
    Funcionalidades: Speed Hack y Mega Jump.
    Requiere que Krnl pueda cargar la librería Rayfield.
]=]

-- == [ CARGAR LA LIBRERÍA RAYFIELD ] ==
-- Este es el paso crucial. Si esto falla, la GUI no aparecerá.

if not Rayfield then
    warn("Error: No se pudo cargar la librería Rayfield. Asegúrate de tener una conexión y que Krnl soporte la carga de librerías.")
    return
end

-- Inicialización y referencias del jugador
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

if not Humanoid then
    warn("Script Error: No se pudo encontrar Humanoid.")
    return
end

-- Valores por defecto
local defaultSpeed = 16
local defaultJump = 50

-- == [ CONFIGURACIÓN DE LA VENTANA PRINCIPAL DE RAYFIELD ] ==

local Window = Rayfield:CreateWindow({
    Name = "🛠️ Experto Script 🔥", -- Título de la ventana
    LoadingTitle = "Cargando Cheats",
    LoadingSubtitle = "Iniciando funcionalidades de Rayfield...",
    ConfigurationSaving = {
        Enabled = true, -- Guarda la posición de la ventana
        FolderName = nil, -- Nombre de la carpeta de configuraciones (nil para usar el nombre de la ventana)
        FileName = "Experto_Rayfield_Config.json" -- Archivo de configuración
    },
    Keybind = Enum.KeyCode.RightControl -- Tecla para abrir/cerrar la GUI (Ctrl Derecho)
})

-- == [ CREAR PESTAÑAS (TABS) ] ==

local MovementTab = Window:CreateTab("Movimiento", 4483362458) -- ID de icono opcional (un ícono de caminar/correr si está disponible)

-- == [ SECCIÓN DE BOTONES PARA MOVIMIENTO ] ==

-- Speed Hack
MovementTab:CreateToggle({
    Name = "Speed Hack (x3)",
    CurrentValue = false,
    Flag = "speedHackEnabled", -- Identificador para guardar estado
    Callback = function(toggled)
        if toggled then
            Humanoid.WalkSpeed = 50 -- Velocidad aumentada
            Rayfield:Notify({
                Title = "Speed Hack",
                Content = "¡Velocidad aumentada!",
                Duration = 3 -- Duración de la notificación
            })
        else
            Humanoid.WalkSpeed = defaultSpeed -- Volver a la velocidad normal
            Rayfield:Notify({
                Title = "Speed Hack",
                Content = "Velocidad normal restaurada.",
                Duration = 3
            })
        end
    end,
})

-- Mega Jump
MovementTab:CreateToggle({
    Name = "Mega Jump (x3)",
    CurrentValue = false,
    Flag = "megaJumpEnabled",
    Callback = function(toggled)
        if toggled then
            Humanoid.JumpPower = 150 -- Poder de salto aumentado
            Rayfield:Notify({
                Title = "Mega Jump",
                Content = "¡Salto súper cargado!",
                Duration = 3
            })
        else
            Humanoid.JumpPower = defaultJump -- Volver al salto normal
            Rayfield:Notify({
                Title = "Mega Jump",
                Content = "Poder de salto restaurado.",
                Duration = 3
            })
        end
    end,
})

-- == [ FUNCIÓN PARA CERRAR Y LIMPIAR ] ==
-- Rayfield maneja el cierre de la GUI con el Keybind.
-- Podemos añadir una pestaña para "Misc" o "Utilidades" y poner un botón de limpieza forzada.

local UtilityTab = Window:CreateTab("Utilidades", 4483362458) -- Otro ícono o el mismo para simplicidad

UtilityTab:CreateButton({
    Name = "Restaurar Todo y Cerrar",
    Callback = function()
        if Humanoid then
            Humanoid.WalkSpeed = defaultSpeed
            Humanoid.JumpPower = defaultJump
            Rayfield:Notify({
                Title = "Limpieza Completa",
                Content = "Velocidad y Salto restaurados. La GUI se puede ocultar con el Keybind.",
                Duration = 5
            })
        end
        -- Rayfield no tiene un método directo para "destruir" la GUI completa de la misma manera
        -- que una GUI nativa, ya que está diseñada para ser persistente y ocultable.
        -- Puedes simplemente ocultarla con el Keybind (Ctrl Derecho por defecto).
    end,
})

print("Rayfield GUI cargada con éxito. Usa 'RightControl' para abrir/cerrar.")
