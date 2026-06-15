-- // Nearby Players Freeze (Anti-Walk) + Delta Menu
-- Замораживает игроков рядом с тобой (не могут ходить)

local player = game.Players.LocalPlayer
local ENABLED = false
local connection = nil
local FREEZE_RADIUS = 25  -- Радиус действия (в студах). Можно менять

local frozenPlayers = {}  -- Для хранения кто заморожен

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

-- Основная функция заморозки
local function updateFreeze()
    if not ENABLED then return end
    
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local myRoot = myChar.HumanoidRootPart
    local myPos = myRoot.Position
    
    -- Проходим по всем игрокам
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherChar = otherPlayer.Character
            local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
            local otherHum = otherChar:FindFirstChild("Humanoid")
            
            if otherRoot and otherHum then
                local distance = (otherRoot.Position - myPos).Magnitude
                
                if distance <= FREEZE_RADIUS then
                    -- Замораживаем
                    otherHum.WalkSpeed = 0
                    otherHum.JumpPower = 0
                    otherHum.PlatformStand = true
                    otherHum.AutoRotate = false
                    
                    -- Дополнительно сбрасываем скорость
                    otherRoot.Velocity = Vector3.new(0, otherRoot.Velocity.Y, 0)
                    otherRoot.AssemblyLinearVelocity = Vector3.new(0, otherRoot.Velocity.Y, 0)
                    
                    frozenPlayers[otherPlayer] = true
                elseif frozenPlayers[otherPlayer] then
                    -- Размораживаем если вышел из радиуса
                    otherHum.WalkSpeed = 16
                    otherHum.JumpPower = 50
                    otherHum.PlatformStand = false
                    otherHum.AutoRotate = true
                    frozenPlayers[otherPlayer] = nil
                end
            end
        end
    end
end

-- === МЕНЮ ДЛЯ DELTA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NearbyFreezeMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 180)
Frame.Position = UDim2.new(0.5, -140, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Nearby Freeze"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.3, 0)
Status.BackgroundTransparency = 1
Status.Text = "Выключено"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 55)
ToggleButton.Position = UDim2.new(0.075, 0, 0.55, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "ВКЛЮЧИТЬ ЗАМОРОЗКУ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Переключение
ToggleButton.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    
    if ENABLED then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ ЗАМОРОЗКУ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        Status.Text = "Включено (Радиус: " .. FREEZE_RADIUS .. ")"
        
        if not connection then
            connection = game:GetService("RunService").Heartbeat:Connect(updateFreeze)
        end
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ ЗАМОРОЗКУ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Status.Text = "Выключено"
        
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        -- Размораживаем всех при выключении
        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local hum = otherPlayer.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                    hum.PlatformStand = false
                    hum.AutoRotate = true
                end
            end
        end
        frozenPlayers = {}
    end
end)

-- Респавн
player.CharacterAdded:Connect(function()
    wait(0.5)
    antiDeath()
end)

-- Инициализация
antiDeath()
print("✅ Nearby Freeze скрипт загружен!")
print("   Включай через меню. Замораживает игроков в радиусе " .. FREEZE_RADIUS .. " студов.")

-- ScreenGui:Destroy() -- для удаления меню
