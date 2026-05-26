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

local function CreateButton(btnName, tabParent, scriptCode)
    local btn = Instance.new("TextButton", tabs[tabParent])
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = btnName
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.MouseButton1Click:Connect(function() scriptCode(btn) end)
    return btn
end

-----------------------------------------------------------
-- РАЗДЕЛ [ VISUALS ]
-----------------------------------------------------------
local EspActive = false
_G.EspEnabled = false

CreateButton("ESP", "Visuals", function(self)
    EspActive = not EspActive
    _G.EspEnabled = EspActive
    self.Text = EspActive and "ESP: ON" or "ESP: OFF"
    self.BackgroundColor3 = EspActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

local StretchedActive = false
local stretchedConnection = nil
CreateButton("Stretched", "Visuals", function(self)
    StretchedActive = not StretchedActive
    self.Text = StretchedActive and "STRETCHED: ON" or "STRETCHED: OFF"
    self.BackgroundColor3 = StretchedActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if StretchedActive then
        getgenv().Resolution = {[".gg/scripters"] = 0.65}
        getgenv().gg_scripters = "Aori0001"
        stretchedConnection = runService.RenderStepped:Connect(function()
            if not StretchedActive then if stretchedConnection then stretchedConnection:Disconnect() end return end
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
        end)
    else
        if stretchedConnection then stretchedConnection:Disconnect() stretchedConnection = nil end
        getgenv().gg_scripters = nil
    end
end)

local function createESP(plr)
    local box = Drawing.new("Square"); box.Visible = false; box.Filled = false; box.Color = Color3.fromRGB(255, 0, 100); box.Thickness = 2
    local distanceText = Drawing.new("Text"); distanceText.Visible = false; distanceText.Center = true; distanceText.Outline = true; distanceText.Color = Color3.fromRGB(255, 255, 255); distanceText.Size = 13
    local connection
    connection = runService.RenderStepped:Connect(function()
        if _G.EspEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= player then
            local rootPart = plr.Character.HumanoidRootPart
            local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local headPos = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(0, 0.5, 0))
                local legPos = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y); local width = height / 2
                box.Size = Vector2.new(width, height); box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2); box.Visible = true
                distanceText.Position = Vector2.new(rootPos.X, box.Position.Y - 16)
                local charPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
                distanceText.Text = plr.Name .. " [" .. math.floor((charPos - rootPart.Position).Magnitude) .. "m]"; distanceText.Visible = true
            else box.Visible = false; distanceText.Visible = false end
        else
            box.Visible = false; distanceText.Visible = false
            if not plr.Parent then connection:Disconnect(); box:Remove(); distanceText:Remove() end
        end
    end)
end
for _, v in pairs(game.Players:GetPlayers()) do if v ~= player then createESP(v) end end
game.Players.PlayerAdded:Connect(createESP)

-----------------------------------------------------------
-- РАЗДЕЛ [ SCRIPTS ]
-----------------------------------------------------------
local currentSpeed = 50; local speedEnabled = false; local velocityForce = Instance.new("BodyVelocity"); velocityForce.MaxForce = Vector3.new(1e7, 0, 1e7)
local speedBtn = CreateButton("SPEED: OFF", "Scripts", function(self)
    speedEnabled = not speedEnabled
    self.Text = speedEnabled and "SPEED: ON" or "SPEED: OFF"
    self.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if not speedEnabled then velocityForce.Parent = nil end
end)
local speedInput = Instance.new("TextBox", tabs["Scripts"]); speedInput.Size = UDim2.new(0.9, 0, 0, 35); speedInput.Text = "50"; speedInput.BackgroundColor3 = Color3.fromRGB(10, 10, 10); speedInput.TextColor3 = Color3.fromRGB(0, 255, 150); speedInput.Font = Enum.Font.Code
speedInput.FocusLost:Connect(function() local val = tonumber(speedInput.Text); if val then currentSpeed = val else speedInput.Text = tostring(currentSpeed) end end)
runService.RenderStepped:Connect(function()
    local char = player.Character
    if speedEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then velocityForce.Parent = char.HumanoidRootPart; velocityForce.Velocity = hum.MoveDirection * currentSpeed
        else velocityForce.Velocity = Vector3.new(0, 0, 0) end
    end
end)

local InfiniteJumpEnabled = false
CreateButton("INF JUMP", "Scripts", function(self)
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    self.Text = InfiniteJumpEnabled and "INF JUMP: ON" or "INF JUMP: OFF"
    self.BackgroundColor3 = InfiniteJumpEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)
game:GetService("UserInputService").JumpRequest:Connect(function() if InfiniteJumpEnabled then player.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping") end end)

-- СКОРРЕКТИРОВАННЫЙ SLOW FALL БЕЗ СВОЕГО МЕНЮ
local sfActive = false
local sfLoop = nil

local function applySlowFall()
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = player.Character.HumanoidRootPart
	hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -8, 50), hrp.Velocity.Z)
end

CreateButton("Slow Fall", "Scripts", function(self)
    sfActive = not sfActive
    self.Text = sfActive and "SLOW FALL: ON" or "SLOW FALL: OFF"
    self.BackgroundColor3 = sfActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    
    if sfActive then
        sfLoop = runService.RenderStepped:Connect(function()
            applySlowFall()
        end)
    else
        if sfLoop then 
            sfLoop:Disconnect() 
            sfLoop = nil 
        end
    end
end)

-----------------------------------------------------------
-- РАЗДЕЛ [ COMBAT ]
-----------------------------------------------------------
_G.HeadSize = 15; _G.HitboxEnabled = false
CreateButton("HITBOX", "Combat", function(self)
    _G.HitboxEnabled = not _G.HitboxEnabled
    self.Text = _G.HitboxEnabled and "HITBOX: ON" or "HITBOX: OFF"
    self.BackgroundColor3 = _G.HitboxEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if not _G.HitboxEnabled then for _,v in next, game.Players:GetPlayers() do if v ~= player then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); v.Character.HumanoidRootPart.Transparency = 1 end) end end end
end)
runService.RenderStepped:Connect(function()
    if _G.HitboxEnabled then for _,v in next, game.Players:GetPlayers() do if v ~= player then pcall(function() 
        local hrp = v.Character.HumanoidRootPart; hrp.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize); hrp.Transparency = 0.9; hrp.BrickColor = BrickColor.new("Really blue"); hrp.Material = "Neon"; hrp.CanCollide = false 
    end) end end end
end)

-- ОРИГИНАЛЬНЫЙ AIMBOT СКРИПТ (С ТВОЕЙ КАМЕРОЙ)
local AimSettings = { Aimbot = false, WallCheck = true, Sens = 1, Pred = 0, LockedTarget = nil }
local AimGui = Instance.new("ScreenGui", game:GetService("CoreGui")); AimGui.Enabled = false

local function MakeAimDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    runService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local AimCircle = Instance.new("TextButton", AimGui); AimCircle.Size = UDim2.new(0, 55, 0, 55); AimCircle.Position = UDim2.new(0, 25, 0.4, 0); AimCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0); AimCircle.Text = "AIM"; AimCircle.TextColor3 = Color3.new(1,1,1); AimCircle.Font = Enum.Font.GothamBold; Instance.new("UICorner", AimCircle).CornerRadius = UDim.new(1, 0)
local WallCircle = Instance.new("TextButton", AimGui); WallCircle.Size = UDim2.new(0, 55, 0, 55); WallCircle.Position = UDim2.new(0, 25, 0.4, 65); WallCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0); WallCircle.Text = "WALL"; WallCircle.TextColor3 = Color3.new(1,1,1); WallCircle.Font = Enum.Font.GothamBold; Instance.new("UICorner", WallCircle).CornerRadius = UDim.new(1, 0)
MakeAimDraggable(AimCircle); MakeAimDraggable(WallCircle)

AimCircle.MouseButton1Click:Connect(function() AimSettings.Aimbot = not AimSettings.Aimbot; if not AimSettings.Aimbot then AimSettings.LockedTarget = nil end; AimCircle.BackgroundColor3 = AimSettings.Aimbot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) end)
WallCircle.MouseButton1Click:Connect(function() AimSettings.WallCheck = not AimSettings.WallCheck; WallCircle.BackgroundColor3 = AimSettings.WallCheck and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) end)

local function IsAlive(p) return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 and not p.Character:FindFirstChild("Downed") end
local function IsVisible(targetChar) if not AimSettings.WallCheck then return true end local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {player.Character, targetChar}; local result = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, targetChar.Head.Position - workspace.CurrentCamera.CFrame.Position, params); return result == nil end

runService.RenderStepped:Connect(function()
    if AimSettings.Aimbot then
        if not AimSettings.LockedTarget or not IsAlive(AimSettings.LockedTarget) or not IsVisible(AimSettings.LockedTarget.Character) then
            local bestDist = 500; AimSettings.LockedTarget = nil
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and IsAlive(p) and IsVisible(p.Character) then
                    local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude; if mag < bestDist then bestDist = mag; AimSettings.LockedTarget = p end end
                end
            end
        end
        if AimSettings.LockedTarget then 
            local head = AimSettings.LockedTarget.Character.Head
            local hrp = AimSettings.LockedTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prediction = hrp.AssemblyLinearVelocity * AimSettings.Pred
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, head.Position + prediction), AimSettings.Sens)
            end
        end
    end
end)

CreateButton("aimbot", "Combat", function(self)
    AimGui.Enabled = not AimGui.Enabled
    self.Text = AimGui.Enabled and "AIMBOT: ON" or "AIMBOT: OFF"
    self.BackgroundColor3 = AimGui.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

-----------------------------------------------------------
-- КНОПКА СВЕРНУТЬ (M)
-----------------------------------------------------------
local minBtn = Instance.new("TextButton", screenGui); minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(0, 10, 0, 10)
minBtn.Text = "M"; minBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); minBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)
minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
