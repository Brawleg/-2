-- // Invisible Body + Head Stays + Toggle Menu for Delta
-- Все части тела улетают вверх, кроме головы

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local HEIGHT = 400          -- Высота подъёма
local ENABLED = false
local connection = nil

-- Анти-смерть
local function antiDeath()
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end

-- Основная функция скрытия
local function updateBody()
    if not ENABLED or not character or not root then return end
    
    root.Velocity = Vector3.new(0,0,0)
    root.AssemblyLinearVelocity = Vector3.new(0,0,0)
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            if part.Name == "Head" or part.Name == "HumanoidRootPart" then
                -- Голова и хитбокс остаются на месте
                part.Transparency = 0
                part.CanCollide = true
            else
                -- Всё остальное улетает вверх
                local targetCFrame = root.CFrame * CFrame.new(0, HEIGHT, 0)
                part.CFrame = targetCFrame
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    end
    
    -- Accessories (волосы, шапки и т.д.)
    for _, acc in ipairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                handle.CFrame = root.CFrame * CFrame.new(0, HEIGHT + 5, 0)
                handle.Transparency = 1
                handle.CanCollide = false
            end
        end
    end
end

-- Создаём красивое меню для Delta
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BodyFlyMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Body Fly Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.45, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "ВКЛЮЧИТЬ"
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
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        if not connection then
            connection = game:GetService("RunService").RenderStepped:Connect(updateBody)
        end
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        -- Возвращаем всё на место при выключении
        if character then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- Авто-обновление при респавне
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    wait(0.5)
    antiDeath()
end)

-- Инициализация
antiDeath()
print("✅ Body Fly Menu загружен! Голова остаётся на месте.")
print("   Используй кнопку в меню для включения/выключения.")

-- Чтобы полностью удалить меню: ScreenGui:Destroy()
