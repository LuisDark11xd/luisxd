-- =========================================================
--  PRISON LIFE HUB v19.0: Estructura Mínima
-- =========================================================

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Estados Globales
local isNoclipping = false
local isInfiniteJumping = false
local isMinimized = false

-- Referencias (Se inicializan en la función principal)
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil


-- =========================================================
--  UTILIDADES DEL JUGADOR
-- =========================================================

-- Esta función ahora solo se usa para actualizar el Noclip al reaparecer.
local function updatePlayerRefs(char)
    Character = char
    Humanoid = char:FindFirstChild("Humanoid") 
    HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")

    -- Aplicar Noclip inmediatamente al nuevo personaje si está activo
    if isNoclipping and Character and Humanoid and HumanoidRootPart then
        task.spawn(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
end

-- =========================================================
--  LÓGICA DE HACKS
-- =========================================================

local function toggleNoclip(state)
    isNoclipping = state
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
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

    -- RGB Opcional para el Texto (Solo si está OFF)
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


local function createGUI(PlayerGui)
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "PrisonLifeHUB_GUI"
    ScreenGui.ResetOnSpawn = true -- La GUI SE QUITA al morir

    local MainFrame = Instance.new("Frame", ScreenGui) 
    MainFrame.Size = UDim2.new(0, 220, 0, 180)
    MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    MainFrame.BorderColor3 = Color3.new(0.15, 0.15, 0.15)
    MainFrame.Visible = not isMinimized 
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8) 

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "Prison Life HUB"
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20

    local LayoutFrame = Instance.new("Frame", MainFrame)
    LayoutFrame.Size = UDim2.new(1, 0, 0.78, 0) 
    LayoutFrame.Position = UDim2.new(0, 0, 0.22, 0) 
    LayoutFrame.BackgroundTransparency = 1 

    local ListLayout = Instance.new("UIListLayout", LayoutFrame)
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

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

    task.spawn(function()
        while MinimizedButton.Parent do 
            for h = 0, 1, 0.05 do
                local color = Color3.fromHSV(h, 1, 1)
                MinimizedButton.BackgroundColor3 = color 
                task.wait(0.05)
            end
        end
    end)

    createToggleHackButton("No Clip", LayoutFrame, toggleNoclip, isNoclipping)
    createToggleHackButton("Infinite Jumps", LayoutFrame, toggleInfiniteJump, isInfiniteJumping)
    
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
end


-- =========================================================
--  BLOQUE DE INICIALIZACIÓN PRINCIPAL
-- =========================================================

-- Conecta la creación de la GUI al evento de PlayerGui, garantizando que el entorno esté listo.
local PlayerGui = Player:WaitForChild("PlayerGui", 30)

if PlayerGui then
    -- 1. Si el personaje ya existe, lo configuramos
    if Player.Character then
        updatePlayerRefs(Player.Character)
    end
    
    -- 2. Creamos la GUI
    createGUI(PlayerGui)
end

-- 3. Conexión de reaparición (La GUI se quita, pero el código la vuelve a crear)
Player.CharacterAdded:Connect(function(char)
    task.wait(0.2) -- Espera breve para asegurar que PlayerGui se haya limpiado
    updatePlayerRefs(char)
    createGUI(PlayerGui)
end)
