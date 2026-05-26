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
local tabButtons = {"Visuals", "Scripts", "Combat"}

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
-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК
-----------------------------------------------------------
local function CreateButton(btnName, tabParent, scriptCode)
    local btn = Instance.new("TextButton", tabs[tabParent])
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = btnName
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.MouseButton1Click:Connect(function()
        scriptCode(btn)
    end)
    return btn
end

-----------------------------------------------------------
-- РАЗДЕЛ [ VISUALS ]
-----------------------------------------------------------

-- ESP
local EspActive = false
_G.EspEnabled = false

CreateButton("ESP", "Visuals", function(self)
    EspActive = not EspActive
    _G.EspEnabled = EspActive
    self.Text = EspActive and "ESP: ON" or "ESP: OFF"
    self.BackgroundColor3 = EspActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

-- STRETCHED RES (ИСПРАВЛЕННЫЙ)
local StretchedActive = false
local stretchedConnection = nil

CreateButton("Stretched", "Visuals", function(self)
    StretchedActive = not StretchedActive
    self.Text = StretchedActive and "STRETCHED: ON" or "STRETCHED: OFF"
    self.BackgroundColor3 = StretchedActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    
    if StretchedActive then
        -- Устанавливаем параметры
        getgenv().Resolution = {[".gg/scripters"] = 0.65}
        getgenv().gg_scripters = "Aori0001"
        
        local Camera = workspace.CurrentCamera
        -- Запускаем цикл
        stretchedConnection = runService.RenderStepped:Connect(function()
            if not StretchedActive then 
                if stretchedConnection then stretchedConnection:Disconnect() end
                return 
            end
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
        end)
    else
        -- При выключении
        if stretchedConnection then
            stretchedConnection:Disconnect()
            stretchedConnection = nil
        end
        getgenv().gg_scripters = nil -- Сбрасываем, чтобы можно было запустить снова
    end
end)


local function createESP(plr)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 100)
    box.Thickness = 2
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Color = Color3.fromRGB(255, 255, 255)
    distanceText.Size = 13
    local connection
    connection = runService.RenderStepped:Connect(function()
        if _G.EspEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= player then
            local rootPart = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            if not head then return end
            local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                box.Visible = true
                distanceText.Position = Vector2.new(rootPos.X, box.Position.Y - 16)
                local charPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
                local distance = math.floor((charPos - rootPart.Position).Magnitude)
                distanceText.Text = plr.Name .. " [" .. distance .. "m]"
                distanceText.Visible = true
            else
                box.Visible = false
                distanceText.Visible = false
            end
        else
            box.Visible = false
            distanceText.Visible = false
            if not plr.Parent then
                connection:Disconnect()
                box:Remove()
                distanceText:Remove()
            end
        end
    end)
end
for _, v in pairs(game:GetService("Players"):GetPlayers()) do if v ~= player then createESP(v) end end
game:GetService("Players").PlayerAdded:Connect(createESP)

-----------------------------------------------------------
-- РАЗДЕЛ [ SCRIPTS ]
-----------------------------------------------------------
local currentSpeed = 50 
local speedEnabled = false
local velocityForce = Instance.new("BodyVelocity")
velocityForce.MaxForce = Vector3.new(1e7, 0, 1e7)

local speedBtn = Instance.new("TextButton", tabs["Scripts"])
speedBtn.Size = UDim2.new(0.9, 0, 0, 40)
speedBtn.Text = "SPEED: OFF"
speedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBtn.TextColor3 = Color3.new(1, 1, 1)
speedBtn.Font = Enum.Font.GothamBold

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

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "SPEED: ON" or "SPEED: OFF"
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if not speedEnabled then velocityForce.Parent = nil end
end)

runService.RenderStepped:Connect(function()
    local char = player.Character
    if speedEnabled and char and char:FindFirstChild("HumanoidRootPart") then
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

local InfiniteJumpEnabled = false
CreateButton("INF JUMP", "Scripts", function(self)
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    self.Text = InfiniteJumpEnabled and "INF JUMP: ON" or "INF JUMP: OFF"
    self.BackgroundColor3 = InfiniteJumpEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
	if InfiniteJumpEnabled then
		player.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
	end
end)

CreateButton("ПУСТАЯ КНОПКА 4", "Scripts", function() print("4") end)
CreateButton("ПУСТАЯ КНОПКА 5", "Scripts", function() print("5") end)

-----------------------------------------------------------
-- РАЗДЕЛ [ COMBAT ]
-----------------------------------------------------------
_G.HeadSize = 15 
_G.HitboxEnabled = false
CreateButton("HITBOX", "Combat", function(self)
    _G.HitboxEnabled = not _G.HitboxEnabled
    self.Text = _G.HitboxEnabled and "HITBOX: ON" or "HITBOX: OFF"
    self.BackgroundColor3 = _G.HitboxEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if not _G.HitboxEnabled then
        for i,v in next, game:GetService('Players'):GetPlayers() do
            if v.Name ~= player.Name then
                pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1) v.Character.HumanoidRootPart.Transparency = 1 end)
            end
        end
    end
end)

runService.RenderStepped:Connect(function()
    if _G.HitboxEnabled then
        for i,v in next, game:GetService('Players'):GetPlayers() do
            if v.Name ~= player.Name then
                pcall(function()
                    v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
                    v.Character.HumanoidRootPart.Transparency = 0.90
                    v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue")
                    v.Character.HumanoidRootPart.Material = "Neon"
                    v.Character.HumanoidRootPart.CanCollide = false
                end)
            end
        end
    end
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
