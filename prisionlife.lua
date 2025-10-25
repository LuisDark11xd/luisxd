-- =========================================================
--  PRISON LIFE HUB v21.0: SOLUCIÓN A FALLO DE EJECUCIÓN
-- =========================================================

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- COORDENADAS CONFIRMADAS
local COORDS_POLICE_ZONE = Vector3.new(801.01, 99.98, 2285.53)
local COORDS_PRISON_ZONE = Vector3.new(843.23, 97.99, 2485.55)

-- Estados Globales (Persistencia de Hacks y Minimización)
local isNoclipping = false
local isInfiniteJumping = false
local isMinimized = false

-- Referencias dinámicas
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil

-- Referencia a la GUI (Nombre único para destrucción segura)
local GUI_NAME = "PrisonLifeHUB_21" 

-- =========================================================
--  UTILIDADES DEL JUGADOR Y PERSISTENCIA DE HACKS
-- =========================================================

local function updatePlayerRefs(char)
    Character = char
    local successH, hum = pcall(function() return char:WaitForChild("Humanoid", 5) end)
    local successHRP, hrp = pcall(function() return char:WaitForChild("HumanoidRootPart", 5) end)

    if successH and successHRP and hum and hrp then
        Humanoid = hum
        HumanoidRootPart = hrp
        
        -- Aplica Noclip al nuevo personaje si está activo
        if isNoclipping then
            task.spawn(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                Character.DescendantAdded:Connect(function(part)
                    if part:IsA("BasePart") then part.CanCollide = false end
                end)
            end)
        end
    end
end

-- Solo actualizamos referencias al reaparecer (la GUI se encarga de la persistencia visual)
Player.CharacterAdded:Connect(updatePlayerRefs)

-- =========================================================
--  LÓGICA DE HACKS
-- =========================================================

local function toggleNoclip(state)
    isNoclipping = state
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = not state end
        end
    end
end

local function toggleInfiniteJump(state)
    isInfiniteJumping = state
end

RunService.Stepped:Connect(function()
    if isInfiniteJumping and Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function teleportPlayer(targetVector)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(targetVector)
    end
end

-- =========================================================
--  LÓGICA DE LA GUI
-- =========================================================

local function makeDraggable(guiObject)
    local dragStart = nil
    local startPos = nil
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = guiObject.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Change then
                    local delta = input.Position - dragStart
                    guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            input.InputEnded:Wait()
            connection:Disconnect() 
        end
    end)
end

-- Crea botones de activación/desactivación
local function createToggleHackButton(name, container, callback, currentState)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    local state = currentState 
    
    local function updateText(current)
        btn.Text = name .. " (" .. (current and "ON" or "OFF") .. ")"
        btn.BackgroundColor3 = current and Color3.new(0.1, 0.5, 0.1) or Color3.new(0.1, 0.4, 0.8)
    end
    
    updateText(state)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    -- RGB para el Texto (solo si está OFF)
    task.spawn(function()
        while btn.Parent do
            for h = 0, 1, 0.05 do
                if not state then
                    btn.TextColor3 = Color3.fromHSV(h, 1, 1)
                else
                    btn.TextColor3 = Color3.new(1, 1, 1)
                end
                task.wait(0.05)
            end
        end
    end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        updateText(state)
    end)
    return btn
end

-- Crea botones de acción (TP)
local function createActionButton(name, container, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.9, 0, 0, 35) 
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.new(0.1, 0.4, 0.8)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(callback)
    return btn
end


local function createGUI(PlayerGui)
    
    -- SOLUCIÓN CRÍTICA: Destruir cualquier GUI anterior con el mismo nombre.
    local existingGui = PlayerGui:FindFirstChild(GUI_NAME)
    if existingGui then
        existingGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = GUI_NAME
    ScreenGui.ResetOnSpawn = false -- <<-- PERSISTENCIA ACTIVADA

    -- 1. MainFrame (Fondo Gris)
    local MainFrame = Instance.new("Frame", ScreenGui) 
    MainFrame.Size = UDim2.new(0, 220, 0, 280)
    MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    MainFrame.BorderColor3 = Color3.new(0.15, 0.15, 0.15)
    MainFrame.Visible = not isMinimized 
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8) 

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "Prison Life HUB"
    Title.Size = UDim2.new(1, 0, 0.15, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20

    local LayoutFrame = Instance.new("Frame", MainFrame)
    LayoutFrame.Size = UDim2.new(1, 0, 0.78, 0) 
    LayoutFrame.Position = UDim2.new(0, 0, 0.17, 0) 
    LayoutFrame.BackgroundTransparency = 1 

    local ListLayout = Instance.new("UIListLayout", LayoutFrame)
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- 2. Mini-botón Flotante (Circular)
    local MinimizedButton = Instance.new("TextButton", ScreenGui)
    MinimizedButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizedButton.Text = "P"
    MinimizedButton.Font = Enum.Font.SourceSansBold
    MinimizedButton.TextSize = 20
    MinimizedButton.Visible = isMinimized 
    MinimizedButton.ZIndex = 2 
    MinimizedButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    Instance.new("UICorner", MinimizedButton).CornerRadius = UDim.new(0.5, 0)

    makeDraggable(MainFrame)
    makeDraggable(MinimizedButton)

    -- [RGB LOOP para el Mini-botón]
    task.spawn(function()
        while MinimizedButton.Parent do 
            for h = 0, 1, 0.05 do
                local color = Color3.fromHSV(h, 1, 1)
                MinimizedButton.BackgroundColor3 = color 
                task.wait(0.05)
            end
        end
    end)

    -- CREACIÓN DE BOTONES
    createToggleHackButton("No Clip", LayoutFrame, toggleNoclip, isNoclipping)
    createToggleHackButton("Infinite Jumps", LayoutFrame, toggleInfiniteJump, isInfiniteJumping)
    
    createActionButton("TP: Zona de Policías", LayoutFrame, function() teleportPlayer(COORDS_POLICE_ZONE) end)
    createActionButton("TP: Zona Prisión", LayoutFrame, function() teleportPlayer(COORDS_PRISON_ZONE) end)
    
    -- Botón de Minimizar
    local MinimizeButtonUI = Instance.new("TextButton", MainFrame)
    MinimizeButtonUI.Size = UDim2.new(0.3, 0, 0, 20) 
    MinimizeButtonUI.Position = UDim2.new(0.65, 0, 0.03, 0)
    MinimizeButtonUI.Text = "Minimizar"
    MinimizeButtonUI.Font = Enum.Font.SourceSans
    MinimizeButtonUI.TextSize = 14
    MinimizeButtonUI.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    Instance.new("UICorner", MinimizeButtonUI).CornerRadius = UDim.new(0, 4)

    MinimizeButtonUI.MouseButton1Click:Connect(function()
        isMinimized = true
        MainFrame.Visible = false
        MinimizedButton.Visible = true
    end)

    MinimizedButton.MouseButton1Click:Connect(function()
        isMinimized = false
        MainFrame.Visible = true
        MinimizedButton.Visible = false
    end)
}


-- =========================================================
--  BLOQUE DE INICIALIZACIÓN PRINCIPAL
-- =========================================================

local PlayerGui = Player:WaitForChild("PlayerGui", 30)

if PlayerGui then
    -- Si el personaje ya existe, lo configuramos
    if Player.Character then
        updatePlayerRefs(Player.Character)
    end
    
    -- Creamos la GUI (esto asegura que se destruye la anterior si existe)
    createGUI(PlayerGui)
end
