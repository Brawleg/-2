-- // Infinite Air Jump + Draggable Menu + Кнопка скрытия для Delta

local player = game.Players.LocalPlayer
local ENABLED = false
local connection = nil

-- Функции прыжка
local function enableAirJump()
    if connection then return end
    connection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if not ENABLED then return end
        local character = player.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
        end
    end)
end

local function disableAirJump()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

-- === МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AirJumpMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 190)
MainFrame.Position = UDim2.new(0.5, -140, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Заголовок (перетаскивание)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Прыжки в Воздухе"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Кнопка скрытия меню
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 35, 0, 35)
HideButton.Position = UDim2.new(1, -40, 0, 3)
HideButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HideButton.Text = "👁"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.TextScaled = true
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = TitleBar

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 8)
HideCorner.Parent = HideButton

-- Статус
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0.3, 0)
Status.BackgroundTransparency = 1
Status.Text = "Выключено"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame

-- Кнопка Вкл/Выкл
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 60)
ToggleButton.Position = UDim2.new(0.075, 0, 0.52, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "ВКЛЮЧИТЬ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = ToggleButton

-- === Перетаскивание меню ===
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- === Логика кнопки скрытия ===
local menuVisible = true
HideButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
    HideButton.Text = menuVisible and "👁" or "👁‍🗨"
end)

-- Логика включения/выключения прыжков
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

-- Респавн
player.CharacterAdded:Connect(function()
    wait(0.5)
    if ENABLED then
        disableAirJump()
        enableAirJump()
    end
end)

print("✅ Air Jump с кнопкой скрытия загружен!")
print("   Зажми заголовок — двигать | Кнопка 👁 — скрыть/показать меню")

-- ScreenGui:Destroy() -- если нужно полностью удалить
