-- // Only Right Arm Flies Up + Head & Body Stay | Delta Menu

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local HEIGHT = 350
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

-- Основная функция (только рука улетает)
local function updateBody()
    if not ENABLED or not character or not root then return end
    
    root.Velocity = Vector3.new(0,0,0)
    root.AssemblyLinearVelocity = Vector3.new(0,0,0)
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local name = part.Name
            
            if name == "Right Arm" or name == "RightUpperArm" or name == "RightLowerArm" or name == "RightHand" then
                -- Только правая рука улетает
                part.CFrame = root.CFrame * CFrame.new(0, HEIGHT, 0)
                part.Transparency = 1
                part.CanCollide = false
            else
                -- Всё остальное (тело, голова, левая рука, ноги) остаётся нормальным
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
    
    -- Accessories (шапки, волосы и т.д. — не трогаем)
end

-- === МЕНЮ ДЛЯ DELTA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArmFlyMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 160)
Frame.Position = UDim2.new(0.5, -130, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Only Arm Fly"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "ВКЛЮЧИТЬ РУКУ"
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
        ToggleButton.Text = "ВЫКЛЮЧИТЬ РУКУ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        
        if not connection then
            connection = game:GetService("RunService").RenderStepped:Connect(updateBody)
        end
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ РУКУ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        -- Возвращаем руку на место
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

-- Респавн
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    wait(0.5)
    antiDeath()
end)

-- Старт
antiDeath()
print("✅ Only Right Arm Fly загружен!")
print("   Используй меню для включения/выключения.")

-- Для удаления меню: ScreenGui:Destroy()
