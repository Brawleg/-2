-- // Right Arm Inside Torso (Hidden) + Delta Menu

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

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

-- Основная функция: рука прячется внутри туловища и смотрит вниз
local function updateArm()
    if not ENABLED or not character or not root or not torso then return end
    
    root.Velocity = Vector3.new(0,0,0)
    root.AssemblyLinearVelocity = Vector3.new(0,0,0)
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local name = part.Name
            
            if name == "Right Arm" or name == "RightUpperArm" or name == "RightLowerArm" or name == "RightHand" then
                -- Прячем руку внутри туловища и поворачиваем вниз
                local hideCFrame = torso.CFrame * CFrame.new(0.5, -0.5, 0) * CFrame.Angles(math.rad(90), 0, 0) -- смотрит вниз
                part.CFrame = hideCFrame
                part.Transparency = 1          -- полностью невидимая
                part.CanCollide = false
                part.AssemblyLinearVelocity = Vector3.new(0,0,0)
            else
                -- Остальное тело нормально
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
end

-- === МЕНЮ ДЛЯ DELTA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArmHideMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 270, 0, 160)
Frame.Position = UDim2.new(0.5, -135, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Скрыть Руку В Тело"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "ВКЛЮЧИТЬ СКРЫТИЕ"
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
        ToggleButton.Text = "ВЫКЛЮЧИТЬ СКРЫТИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        
        if not connection then
            connection = game:GetService("RunService").RenderStepped:Connect(updateArm)
        end
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ СКРЫТИЕ"
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

-- Респавн персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    torso = newChar:FindFirstChild("UpperTorso") or newChar:FindFirstChild("Torso")
    wait(0.5)
    antiDeath()
end)

-- Старт
antiDeath()
print("✅ Скрытие руки внутри туловища загружено!")
print("   Рука будет прятаться внутри тела и смотреть вниз.")

-- ScreenGui:Destroy() -- чтобы удалить меню
