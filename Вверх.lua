-- // Infinite Air Jump (Прыжки в воздухе) + Красивое меню для Delta
-- Новый независимый скрипт

local player = game.Players.LocalPlayer
local ENABLED = false
local connection = nil

-- Основная функция прыжка в воздухе
local function enableAirJump()
    if connection then return end
    
    connection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if not ENABLED then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and root and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            -- Прыжок в воздухе
            root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z) -- высота прыжка (можно изменить)
        end
    end)
end

local function disableAirJump()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

-- === МЕНЮ ДЛЯ DELTA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AirJumpMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 170)
Frame.Position = UDim2.new(0.5, -140, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Прыжки в Воздухе"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0.35, 0)
Status.BackgroundTransparency = 1
Status.Text = "Выключено"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 60)
ToggleButton.Position = UDim2.new(0.075, 0, 0.55, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "ВКЛЮЧИТЬ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = ToggleButton

-- Логика переключения
ToggleButton.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    
    if ENABLED then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 100)
        Status.Text = "Включено"
        Status.TextColor3 = Color3.fromRGB(80, 255, 80)
        enableAirJump()
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Status.Text = "Выключено"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)
        disableAirJump()
    end
end)

-- Респавн персонажа
player.CharacterAdded:Connect(function()
    wait(0.5)
    if ENABLED then
        disableAirJump()
        enableAirJump()
    end
end)

print("✅ Infinite Air Jump загружен для Delta!")
print("   Используй меню для включения/выключения.")

-- ScreenGui:Destroy() -- для полного удаления меню
