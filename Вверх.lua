- // Touch Freeze (Коснулся — заморозил) + Draggable Menu for Delta

local player = game.Players.LocalPlayer
local ENABLED = false
local connection = nil
local frozenPlayers = {}

-- Анти-смерть для себя
local function antiDeath()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
end

-- Разморозка игрока
local function unfreezePlayer(otherPlayer)
    if otherPlayer and otherPlayer.Character then
        local hum = otherPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
end

-- Заморозка игрока
local function freezePlayer(otherPlayer)
    if otherPlayer and otherPlayer.Character then
        local hum = otherPlayer.Character:FindFirstChild("Humanoid")
        local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.PlatformStand = true
            hum.AutoRotate = false
        end
        if root then
            root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
            root.AssemblyLinearVelocity = Vector3.new(0, root.Velocity.Y, 0)
        end
        frozenPlayers[otherPlayer] = true
    end
end

-- Обработка касания
local function onTouch(part)
    if not ENABLED then return end
    local otherChar = part.Parent
    local otherPlayer = game.Players:GetPlayerFromCharacter(otherChar)
    
    if otherPlayer and otherPlayer ~= player then
        freezePlayer(otherPlayer)
    end
end

-- Подключение Touched ко всем частям тела игрока
local function connectTouchEvents(char)
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(onTouch)
        end
    end
end

-- === Draggable Menu ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchFreezeMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 290, 0, 190)
Frame.Position = UDim2.new(0.5, -145, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Touch Freeze"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Делаем менюшку перетаскиваемой
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateInput(input)
    end
end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.28, 0)
Status.BackgroundTransparency = 1
Status.Text = "Выключено"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 55)
ToggleButton.Position = UDim2.new(0.075, 0, 0.52, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "ВКЛЮЧИТЬ (Касание)"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Логика переключения
ToggleButton.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    
    if ENABLED then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        Status.Text = "Включено — касайся игроков"
        
        if not connection then
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                -- Авто-разморозка тех, кто далеко (опционально)
            end)
        end
        
        -- Подключаем касания
        local char = player.Character
        if char then
            connectTouchEvents(char)
        end
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ (Касание)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Status.Text = "Выключено"
        
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        -- Размораживаем всех
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= player then
                unfreezePlayer(p)
            end
        end
        frozenPlayers = {}
    end
end)

-- Респавн
player.CharacterAdded:Connect(function(newChar)
    wait(0.5)
    antiDeath()
    if ENABLED then
        connectTouchEvents(newChar)
    end
end)

-- Инициализация
antiDeath()
print("✅ Touch Freeze + Draggable Menu загружен!")
print("   Включи меню и просто касайся игроков — они заморозятся.")

-- ScreenGui:Destroy() -- для полного удаления
