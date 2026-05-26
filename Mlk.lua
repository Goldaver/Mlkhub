local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MyPersonalHub"
screenGui.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 450, 0, 250)
mainFrame.Position = UDim2.new(0.5, -225, 0.4, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true 

-- БОКОВАЯ ПАНЕЛЬ (Меню слева)
local sideBar = Instance.new("Frame", mainFrame)
sideBar.Size = UDim2.new(0, 100, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sideBar.BorderSizePixel = 1

-- КОНТЕНТНАЯ ЧАСТЬ (Справа)
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -110, 1, -10)
contentFrame.Position = UDim2.new(0, 105, 0, 5)
contentFrame.BackgroundTransparency = 1

-- Таблицы для вкладок (Убрали Visuals)
local tabs = {}
local tabButtons = {"Main", "Scripts", "Settings"}

-- Функция для переключения вкладок
local function showTab(name)
    for tabName, frame in pairs(tabs) do
        frame.Visible = (tabName == name)
    end
end

-- Создаем кнопки и фреймы автоматически
for i, name in ipairs(tabButtons) do
    -- Кнопка
    local btn = Instance.new("TextButton", sideBar)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, (i-1)*40 + 10)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 1

    -- Фрейм контента для этой кнопки
    local f = Instance.new("ScrollingFrame", contentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = (i == 1) 
    f.CanvasSize = UDim2.new(0, 0, 2, 0)
    f.ScrollBarThickness = 2
    tabs[name] = f

    btn.MouseButton1Click:Connect(function()
        showTab(name)
    end)
end

-----------------------------------------------------------
-- МЕСТО ДЛЯ ТВОИХ СКРИПТОВ
-----------------------------------------------------------

-- Сюда можно добавлять новые кнопки в будущем

-----------------------------------------------------------

-- КНОПКА СВЕРНУТЬ (Оставил, чтобы можно было прятать меню)
local minBtn = Instance.new("TextButton", screenGui)
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(0, 10, 0, 10)
minBtn.Text = "M"
minBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
minBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
