local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MyPersonalHub"
screenGui.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 450, 0, 250)
mainFrame.Position = UDim2.new(0.5, -225, 0.4, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.Active = true
mainFrame.Draggable = true 

-- БОКОВАЯ ПАНЕЛЬ
local sideBar = Instance.new("Frame", mainFrame)
sideBar.Size = UDim2.new(0, 100, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- КОНТЕНТНАЯ ЧАСТЬ
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -110, 1, -10)
contentFrame.Position = UDim2.new(0, 105, 0, 5)
contentFrame.BackgroundTransparency = 1

local tabs = {}
local tabButtons = {"Main", "Scripts", "Settings"}

local function showTab(name)
    for tabName, frame in pairs(tabs) do
        frame.Visible = (tabName == name)
    end
end

for i, name in ipairs(tabButtons) do
    local btn = Instance.new("TextButton", sideBar)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, (i-1)*40 + 10)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham

    local f = Instance.new("ScrollingFrame", contentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = (i == 1) 
    f.CanvasSize = UDim2.new(0, 0, 2, 0)
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    tabs[name] = f
    btn.MouseButton1Click:Connect(function() showTab(name) end)
end

-----------------------------------------------------------
-- РАЗДЕЛ [ SCRIPTS ] - ВСЁ ТЕПЕРЬ ТУТ
-----------------------------------------------------------

-- 1. ТВОЙ СКОРОСТНОЙ СКРИПТ
local currentSpeed = 50 
local isEnabled = false
local velocityForce = Instance.new("BodyVelocity")
velocityForce.MaxForce = Vector3.new(1e7, 0, 1e7)

local toggleBtn = Instance.new("TextButton", tabs["Scripts"])
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Text = "SPEED: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold

local speedInput = Instance.new("TextBox", tabs["Scripts"])
speedInput.Size = UDim2.new(0.9, 0, 0, 35)
speedInput.Text = "50"
speedInput.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
speedInput.TextColor3 = Color3.fromRGB(0, 255, 150)
speedInput.Font = Enum.Font.Code

speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val then currentSpeed = val else speedInput.Text = tostring(currentSpeed) end
end)

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleBtn.Text = isEnabled and "SPEED: ON" or "SPEED: OFF"
    toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if not isEnabled then velocityForce.Parent = nil end
end)

runService.RenderStepped:Connect(function()
    local char = player.Character
    if isEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            velocityForce.Parent = root
            velocityForce.Velocity = hum.MoveDirection * currentSpeed
        else
            velocityForce.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ПУСТЫХ КНОПОК
local function CreateButton(btnName, scriptCode)
    local btn = Instance.new("TextButton", tabs["Scripts"])
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = btnName
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.MouseButton1Click:Connect(scriptCode)
end

-- 2. ПУСТЫЕ КНОПКИ (Вкладка Scripts)

CreateButton("ПУСТАЯ КНОПКА 1", function()
    -- "ЗДЕСЬ ПИШИ НАЗВАНИЕ"
    -- "СЮДА ВСТАВЛЯЙ СКРИПТ"
    print("Кнопка 1 нажата")
end)

CreateButton("ПУСТАЯ КНОПКА 2", function()
    -- "ЗДЕСЬ ПИШИ НАЗВАНИЕ"
    -- "СЮДА ВСТАВЛЯЙ СКРИПТ"
    print("Кнопка 2 нажата")
end)

CreateButton("ПУСТАЯ КНОПКА 3", function()
    -- "ЗДЕСЬ ПИШИ НАЗВАНИЕ"
    -- "СЮДА ВСТАВЛЯЙ СКРИПТ"
    print("Кнопка 3 нажата")
end)

CreateButton("ПУСТАЯ КНОПКА 4", function()
    -- "ЗДЕСЬ ПИШИ НАЗВАНИЕ"
    -- "СЮДА ВСТАВЛЯЙ СКРИПТ"
    print("Кнопка 4 нажата")
end)

CreateButton("ПУСТАЯ КНОПКА 5", function()
    -- "ЗДЕСЬ ПИШИ НАЗВАНИЕ"
    -- "СЮДА ВСТАВЛЯЙ СКРИПТ"
    print("Кнопка 5 нажата")
end)

-----------------------------------------------------------
-- КНОПКА СВЕРНУТЬ (M)
-----------------------------------------------------------
local minBtn = Instance.new("TextButton", screenGui)
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(0, 10, 0, 10)
minBtn.Text = "M"
minBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
minBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)
minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
