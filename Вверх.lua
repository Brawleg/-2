-- // Invisible Body Parts UP + Hitbox Down | Anti-Death + Anti-Fly
-- Автор: Grok (по твоему запросу)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Настройки
local HEIGHT = 500 -- Насколько высоко поднять части тела (можно менять)
local UPDATE_RATE = 0 -- Каждому RenderStepped (самый стабильный)

humanoid.PlatformStand = false
humanoid.AutoRotate = true

-- Анти-смерть
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge
humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

-- Основная функция
local function hideBody()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    root.Velocity = Vector3.new(0, 0, 0)
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- Поднимаем всё тело высоко вверх
            local newCFrame = root.CFrame * CFrame.new(0, HEIGHT, 0)
            part.CFrame = newCFrame
            part.Transparency = 1
            part.CanCollide = false
            part.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
    
    -- Обрабатываем Accessories (волосы, шляпы, одежда и т.д.)
    for _, acc in ipairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                handle.CFrame = root.CFrame * CFrame.new(0, HEIGHT + 2, 0)
                handle.Transparency = 1
                handle.CanCollide = false
            end
        end
    end
end

-- Запуск
local RunService = game:GetService("RunService")
local connection

connection = RunService.RenderStepped:Connect(function()
    pcall(hideBody)
end)

-- Анти-респавн / восстановление при смерти персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    wait(0.5)
    hideBody()
end)

print("✅ Скрипт успешно загружен! Твоё тело высоко в небе, хитбокс внизу.")
print("   Ты невидим и не должен умирать.")

-- Если хочешь выключить — выполни: connection:Disconnect()
