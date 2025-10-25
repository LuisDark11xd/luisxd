-- =========================================================
--  CLASH HUB v2.0: AIMBOT con Persistencia Separada
-- =========================================================

local Player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Mouse = Player:GetMouse() 

-- ESTADOS GLOBALES
local isAimbotActive = false
local currentTarget = nil 
local AIMBOT_RADIUS = 300 

-- CONSTANTES DE LA GUI
local GUI_COLOR = Color3.new(0.1, 0.1, 0.3) -- Azul Oscuro
local BUTTON_COLOR = Color3.new(0.1, 0.4, 0.8) -- Azul

-- Referencias dinámicas
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil
local Camera = game.Workspace.CurrentCamera

-- Nombres de las GUIs separadas
local MAIN_GUI_NAME = "ClashHUB_MainGui"
local MIN_GUI_NAME = "ClashHUB_MinButtonGui"


-- =========================================================
--  UTILIDADES DEL JUGADOR Y AIMBOT
-- =========================================================

local function updatePlayerRefs(char)
    Character = char
    local successH, hum = pcall(function() return char:WaitForChild("Humanoid", 5) end)
    local successHRP, hrp = pcall(function() return char:WaitForChild("HumanoidRootPart", 5) end)

    if successH and successHRP and hum and hrp then
        Humanoid = hum
        HumanoidRootPart = hrp
    end
end

Player.CharacterAdded:Connect(updatePlayerRefs)


-- Lógica del Aimbot (Se mantiene igual, solo para referencia)
local function findNearestTarget(currentHRP)
    local nearestPlayer = nil
    local minDistance = AIMBOT_RADIUS
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= Player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = targetPlayer.Character.HumanoidRootPart
            local targetHead = targetPlayer.Character:FindFirstChild("Head") 
            
            if targetHead and targetPlayer.Character.Humanoid.Health > 0 then
                local distance = (currentHRP.Position - targetHRP.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestPlayer = targetPlayer
                end
            end
        end
    end
    return nearestPlayer
end

RunService.Stepped:Connect(function()
    if isAimbotActive and HumanoidRootPart then
        local target = currentTarget
        
        if not target or not target.Character or target.Character.Humanoid.Health <= 0 then
            currentTarget = findNearestTarget(HumanoidRootPart)
            target = currentTarget
        end

        if target and target.Character and target.Character.Humanoid.Health > 0 then
            local targetHead = target.Character:FindFirstChild("Head")
            if targetHead then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            end
        else
            currentTarget = nil
        end
    end
end)

local function toggleAimbot(state)
    isAimbotActive = state
    if not state then
        currentTarget = nil 
    else
        if HumanoidRootPart then
            currentTarget = findNearestTarget(HumanoidRootPart)
        end
    end
end


-- =========================================================
--  LÓGICA DE LA GUI (Botón Circular y MainFrame Separados)
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

local function createToggleHackButton(name, container, callback, currentState)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    local state = currentState 
    
    local function updateText(current)
        btn.Text = name .. " (" .. (current and "ON" or "OFF") .. ")"
        btn.BackgroundColor3 = current and Color3.new(0.1, 0.5, 0.1) or BUTTON_COLOR 
        btn.TextColor3 = Color3.new(1, 1, 1) 
    end
    
    updateText(state)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        updateText(state)
    end)
    return btn
end

-- Declaración anticipada
local createMainGUI 

-- Función para abrir la GUI grande (MainFrame)
local function openGUI(PlayerGui)
    local mainGui = PlayerGui:FindFirstChild(MAIN_GUI_NAME)
    if not mainGui then
        createMainGUI(PlayerGui)
    else
        mainGui.MainFrame.Visible = true
    end
    
    -- Ocultar el botón circular (que siempre estará visible en su propia Gui)
    local minButtonGui = PlayerGui:FindFirstChild(MIN_GUI_NAME)
    if minButtonGui and minButtonGui:FindFirstChild("MinimizedButton") then
        minButtonGui.MinimizedButton.Visible = false
    end
end


-- Función para crear la GUI principal (Se elimina al morir)
createMainGUI = function(PlayerGui)
    -- Destrucción segura de la anterior
    local existingMainGui = PlayerGui:FindFirstChild(MAIN_GUI_NAME)
    if existingMainGui then existingMainGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = MAIN_GUI_NAME
    ScreenGui.ResetOnSpawn = true -- <<-- CLAVE: SE ELIMINA AL MORIR

    -- 1. MainFrame (Fondo Azul Oscuro)
    local MainFrame = Instance.new("Frame", ScreenGui) 
    MainFrame.Name = "MainFrame" -- Referencia para el botón minimizar
    MainFrame.Size = UDim2.new(0, 240, 0, 200)
    MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = GUI_COLOR
    MainFrame.BorderColor3 = Color3.new(0.1, 0.1, 0.15)
    MainFrame.Visible = true -- Siempre visible al crearse
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8) 

    -- Título Principal (Clash HUB con letras RGB)
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "Clash HUB"
    Title.Size = UDim2.new(1, 0, 0.18, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 26
    
    -- Subtítulo
    local SubTitle = Instance.new("TextLabel", MainFrame)
    SubTitle.Text = "By Luis_Dark11"
    SubTitle.Size = UDim2.new(1, 0, 0.1, 0)
    SubTitle.Position = UDim2.new(0, 0, 0.18, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    SubTitle.Font = Enum.Font.SourceSans
    SubTitle.TextSize = 14

    -- [RGB LOOP para el Título Principal]
    task.spawn(function()
        while Title.Parent do
            for h = 0, 1, 0.05 do
                Title.TextColor3 = Color3.fromHSV(h, 1, 1)
                task.wait(0.05)
            end
        end
    end)

    local LayoutFrame = Instance.new("Frame", MainFrame)
    LayoutFrame.Size = UDim2.new(1, 0, 0.6, 0) 
    LayoutFrame.Position = UDim2.new(0, 0, 0.3, 0) 
    LayoutFrame.BackgroundTransparency = 1 

    local ListLayout = Instance.new("UIListLayout", LayoutFrame)
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    makeDraggable(MainFrame)

    -- CREACIÓN DE BOTONES
    createToggleHackButton("Aimbot", LayoutFrame, toggleAimbot, isAimbotActive)
    
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
        MainFrame.Visible = false
        -- Hacer visible el botón circular
        local minButtonGui = PlayerGui:FindFirstChild(MIN_GUI_NAME)
        if minButtonGui and minButtonGui:FindFirstChild("MinimizedButton") then
            minButtonGui.MinimizedButton.Visible = true
        end
    end)
end


-- Función para crear la GUI del botón circular (Persistente)
local function createMinButtonGUI(PlayerGui)
    -- Destrucción segura de la anterior
    local existingMinGui = PlayerGui:FindFirstChild(MIN_GUI_NAME)
    if existingMinGui then existingMinGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = MIN_GUI_NAME
    ScreenGui.ResetOnSpawn = false -- <<-- CLAVE: NO SE ELIMINA AL MORIR

    -- 2. Mini-botón Flotante (Circular)
    local MinimizedButton = Instance.new("TextButton", ScreenGui)
    MinimizedButton.Name = "MinimizedButton"
    MinimizedButton.Size = UDim2.new(0, 45, 0, 45)
    MinimizedButton.Text = "CL"
    MinimizedButton.Font = Enum.Font.SourceSansBold
    MinimizedButton.TextSize = 20
    MinimizedButton.Visible = false -- Oculto al inicio
    MinimizedButton.ZIndex = 2 
    MinimizedButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    Instance.new("UICorner", MinimizedButton).CornerRadius = UDim.new(0.5, 0)

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

    MinimizedButton.MouseButton1Click:Connect(function()
        openGUI(PlayerGui)
    end)
    
    return MinimizedButton
end


-- =========================================================
--  BLOQUE DE INICIALIZACIÓN PRINCIPAL
-- =========================================================

local PlayerGui = Player:WaitForChild("PlayerGui", 30)

if PlayerGui then
    -- 1. Inicializa referencias del jugador
    if Player.Character then
        updatePlayerRefs(Player.Character)
    end
    
    -- 2. Crea el botón circular (PERSISTENTE)
    createMinButtonGUI(PlayerGui)
    
    -- 3. Abre la GUI principal (NO persistente)
    openGUI(PlayerGui)
end
