local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MyPersonalHub"
screenGui.ResetOnSpawn = false

_G.HeadSize = _G.HeadSize or 25
_G.HitboxEnabled = false

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
local tabButtons = {"Visuals", "Scripts", "Combat", "Settings"}

local function showTab(name)
    for tabName, frame in pairs(tabs) do
        frame.Visible = (tabName == name)
    end
end

local MenuButtons = {}

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
    MenuButtons[btnName] = {Instance = btn, Callback = scriptCode}
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
        stretchedConnection = runService.RenderStepped:Connect(function()
            if not StretchedActive then if stretchedConnection then stretchedConnection:Disconnect() end return end
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
        end)
    else
        if stretchedConnection then stretchedConnection:Disconnect() stretchedConnection = nil end
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
CreateButton("SPEED: OFF", "Scripts", function(self)
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

local flying = false; local fv, fg
local function cleanFly()
    flying = false
    local char = player.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if fg then fg:Destroy() fg = nil end
    if fv then fv:Destroy() fv = nil end
end
CreateButton("FLY: OFF", "Scripts", function(self)
    flying = not flying
    self.Text = flying and "FLY: ON" or "FLY: OFF"
    self.BackgroundColor3 = flying and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if flying then
        local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then flying = false return end
        fg = Instance.new("BodyGyro", root); fg.P = 9e4; fg.maxTorque = Vector3.new(9e9, 9e9, 9e9); fg.cframe = root.CFrame
        fv = Instance.new("BodyVelocity", root); fv.velocity = Vector3.new(0, 0, 0); fv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        hum.PlatformStand = true
        task.spawn(function()
            while flying do
                runService.RenderStepped:Wait()
                if not root or not flying then break end
                local cam = workspace.CurrentCamera; local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    fv.velocity = cam.CFrame.LookVector * (moveDir.Magnitude * 60)
                    if moveDir:Dot(cam.CFrame.LookVector) < 0 then fv.velocity = cam.CFrame.LookVector * (-60) end
                else fv.velocity = Vector3.new(0, 0, 0) end
                fg.cframe = cam.CFrame
            end
            cleanFly()
        end)
    else cleanFly() end
end)

local noclipEnabled = false; local noclipConn
CreateButton("NOCLIP: OFF", "Scripts", function(self)
    noclipEnabled = not noclipEnabled
    self.Text = noclipEnabled and "NOCLIP: ON" or "NOCLIP: OFF"
    self.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    if noclipEnabled then noclipConn = runService.Stepped:Connect(function()
        if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end)
    else if noclipConn then noclipConn:Disconnect() end 
        if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    end
end)

local InfJump = false
CreateButton("INF JUMP: OFF", "Scripts", function(self)
    InfJump = not InfJump
    self.Text = InfJump and "INF JUMP: ON" or "INF JUMP: OFF"
    self.BackgroundColor3 = InfJump and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)
game:GetService("UserInputService").JumpRequest:Connect(function() if InfJump then player.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping") end end)

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
    if sfActive then sfLoop = runService.RenderStepped:Connect(applySlowFall) else if sfLoop then sfLoop:Disconnect() sfLoop = nil end end
end)

local tpGui = Instance.new("ScreenGui", game:GetService("CoreGui")); tpGui.Enabled = false
local tpFrame = Instance.new("Frame", tpGui); tpFrame.Size = UDim2.new(0, 160, 0, 90); tpFrame.Position = UDim2.new(0.5, -80, 0.5, -45); tpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); tpFrame.Active = true; tpFrame.Draggable = true
Instance.new("UICorner", tpFrame)
local saved1, saved2, loop1, loop2 = nil, nil, false, false
local function makeTpBtn(txt, pos, col)
    local b = Instance.new("TextButton", tpFrame); b.Size = UDim2.new(0, 65, 0, 30); b.Position = pos; b.BackgroundColor3 = col; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", b); return b
end
local s1 = makeTpBtn("SET 1", UDim2.new(0,10,0,10), Color3.fromRGB(46,139,87))
local t1 = makeTpBtn("TP 1", UDim2.new(0,85,0,10), Color3.fromRGB(30,144,255))
local s2 = makeTpBtn("SET 2", UDim2.new(0,10,0,50), Color3.fromRGB(46,139,87))
local t2 = makeTpBtn("TP 2", UDim2.new(0,85,0,50), Color3.fromRGB(30,144,255))

s1.MouseButton1Click:Connect(function() saved1 = player.Character.HumanoidRootPart.CFrame; s1.Text = "OK!"; task.wait(0.5); s1.Text = "SET 1" end)
s2.MouseButton1Click:Connect(function() saved2 = player.Character.HumanoidRootPart.CFrame; s2.Text = "OK!"; task.wait(0.5); s2.Text = "SET 2" end)

local function tpHandler(btn, pos, isLoopName)
    local down = true; task.spawn(function() task.wait(3); if down and pos then 
        if isLoopName == "1" then loop1 = true while loop1 and tpGui.Enabled do player.Character.HumanoidRootPart.CFrame = pos; t1.Text = "LOOP"; task.wait(1) end
        else loop2 = true while loop2 and tpGui.Enabled do player.Character.HumanoidRootPart.CFrame = pos; t2.Text = "LOOP"; task.wait(1) end end
    end end)
    btn.MouseButton1Up:Connect(function() down = false; if ((isLoopName=="1" and not loop1) or (isLoopName=="2" and not loop2)) and pos then player.Character.HumanoidRootPart.CFrame = pos end end)
end
t1.MouseButton1Down:Connect(function() if loop1 then loop1 = false; t1.Text = "TP 1" else tpHandler(t1, saved1, "1") end end)
t2.MouseButton1Down:Connect(function() if loop2 then loop2 = false; t2.Text = "TP 2" else tpHandler(t2, saved2, "2") end end)

CreateButton("TP POS: OFF", "Scripts", function(self)
    tpGui.Enabled = not tpGui.Enabled
    self.Text = tpGui.Enabled and "TP POS: ON" or "TP POS: OFF"
    self.BackgroundColor3 = tpGui.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

-----------------------------------------------------------
-- РАЗДЕЛ [ COMBAT ]
-----------------------------------------------------------
local hitboxGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
hitboxGui.Name = "HitboxSettingsMenu"
hitboxGui.Enabled = false

local hFrame = Instance.new("Frame", hitboxGui)
hFrame.Size = UDim2.new(0, 180, 0, 120)
hFrame.Position = UDim2.new(0.5, 230, 0.4, -60)
hFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
hFrame.Active = true; hFrame.Draggable = true
Instance.new("UICorner", hFrame).CornerRadius = UDim.new(0, 10)

local hTitle = Instance.new("TextLabel", hFrame)
hTitle.Size = UDim2.new(1, 0, 0, 35); hTitle.Text = "HITBOX MENU"; hTitle.TextColor3 = Color3.new(1,1,1)
hTitle.BackgroundTransparency = 1; hTitle.Font = Enum.Font.GothamBold; hTitle.TextSize = 14

local hCloseBtn = Instance.new("TextButton", hFrame)
hCloseBtn.Size = UDim2.new(0, 28, 0, 28); hCloseBtn.Position = UDim2.new(1, -33, 0, 4)
hCloseBtn.Text = "X"; hCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60); hCloseBtn.TextColor3 = Color3.new(1,1,1)
hCloseBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", hCloseBtn).CornerRadius = UDim.new(1, 0)

local hInput = Instance.new("TextBox", hFrame)
hInput.Size = UDim2.new(0, 140, 0, 40); hInput.Position = UDim2.new(0.5, -70, 0, 55)
hInput.Text = tostring(_G.HeadSize); hInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hInput.TextColor3 = Color3.new(1,1,1); hInput.Font = Enum.Font.Gotham; hInput.TextSize = 18
Instance.new("UICorner", hInput)

hCloseBtn.MouseButton1Click:Connect(function() hitboxGui.Enabled = false end)
hInput.FocusLost:Connect(function()
    local num = tonumber(hInput.Text)
    if num then _G.HeadSize = num else hInput.Text = tostring(_G.HeadSize) end
end)

CreateButton("HITBOX: OFF", "Combat", function(self)
    _G.HitboxEnabled = not _G.HitboxEnabled
    self.Text = _G.HitboxEnabled and "HITBOX: ON" or "HITBOX: OFF"
    self.BackgroundColor3 = _G.HitboxEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    hitboxGui.Enabled = _G.HitboxEnabled
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.HitboxEnabled then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player then
                    pcall(function()
                        local char = p.Character
                        if char then
                            local parts = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"}
                            for _, name in pairs(parts) do
                                local part = char:FindFirstChild(name)
                                if part then
                                    part.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                                    part.Transparency = 0.8
                                    part.BrickColor = BrickColor.new("Bright blue")
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end)

local AimSettings = { Aimbot = false, WallCheck = true, Sens = 1, Pred = 0, LockedTarget = nil }
local AimGui = Instance.new("ScreenGui", game:GetService("CoreGui")); AimGui.Enabled = false

local function MakeAimDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    runService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local ac = Instance.new("TextButton", AimGui); ac.Size = UDim2.new(0, 55, 0, 55); ac.Position = UDim2.new(0, 25, 0.4, 0); ac.BackgroundColor3 = Color3.fromRGB(255, 0, 0); ac.Text = "AIM"; ac.TextColor3 = Color3.new(1,1,1); ac.Font = Enum.Font.GothamBold; Instance.new("UICorner", ac).CornerRadius = UDim.new(1, 0)
local wc = Instance.new("TextButton", AimGui); wc.Size = UDim2.new(0, 55, 0, 55); wc.Position = UDim2.new(0, 25, 0.4, 65); wc.BackgroundColor3 = Color3.fromRGB(0, 255, 0); wc.Text = "WALL"; wc.TextColor3 = Color3.new(1,1,1); wc.Font = Enum.Font.GothamBold; Instance.new("UICorner", wc).CornerRadius = UDim.new(1, 0)
MakeAimDraggable(ac); MakeAimDraggable(wc)

local function IsAlive(p) return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 end
local function IsVisible(targetChar) if not AimSettings.WallCheck then return true end local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {player.Character, targetChar}; local result = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, targetChar.Head.Position - workspace.CurrentCamera.CFrame.Position, params); return result == nil end

ac.MouseButton1Click:Connect(function() AimSettings.Aimbot = not AimSettings.Aimbot; if not AimSettings.Aimbot then AimSettings.LockedTarget = nil end; ac.BackgroundColor3 = AimSettings.Aimbot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) end)
wc.MouseButton1Click:Connect(function() AimSettings.WallCheck = not AimSettings.WallCheck; wc.BackgroundColor3 = AimSettings.WallCheck and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) end)

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

CreateButton("AIMBOT: OFF", "Combat", function(self)
    AimGui.Enabled = not AimGui.Enabled
    self.Text = AimGui.Enabled and "AIMBOT: ON" or "AIMBOT: OFF"
    self.BackgroundColor3 = AimGui.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

-----------------------------------------------------------
-- РАЗДЕЛ [ SETTINGS ] (С АВТОЗАГРУЗКОЙ)
-----------------------------------------------------------
local HttpService = game:GetService("HttpService")
local fileName = "MyHubConfig.json"

local function SaveConfig()
    local config = {
        Esp = _G.EspEnabled,
        Stretched = StretchedActive,
        SpeedEnabled = speedEnabled,
        SpeedValue = currentSpeed,
        Fly = flying,
        Noclip = noclipEnabled,
        InfJump = InfJump,
        SlowFall = sfActive,
        Hitbox = _G.HitboxEnabled,
        HitboxSize = _G.HeadSize,
        AimbotGui = AimGui.Enabled
    }
    local success, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(config))
    end)
    return success
end

local function LoadConfig()
    if not isfile(fileName) then return end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(fileName))
    end)
    
    if success and data then
        if data.Esp ~= _G.EspEnabled then MenuButtons["ESP"].Callback(MenuButtons["ESP"].Instance) end
        if data.Stretched ~= StretchedActive then MenuButtons["Stretched"].Callback(MenuButtons["Stretched"].Instance) end
        if data.SpeedEnabled ~= speedEnabled then MenuButtons["SPEED: OFF"].Callback(MenuButtons["SPEED: OFF"].Instance) end
        if data.Fly ~= flying then MenuButtons["FLY: OFF"].Callback(MenuButtons["FLY: OFF"].Instance) end
        if data.Noclip ~= noclipEnabled then MenuButtons["NOCLIP: OFF"].Callback(MenuButtons["NOCLIP: OFF"].Instance) end
        if data.InfJump ~= InfJump then MenuButtons["INF JUMP: OFF"].Callback(MenuButtons["INF JUMP: OFF"].Instance) end
        if data.SlowFall ~= sfActive then MenuButtons["Slow Fall"].Callback(MenuButtons["Slow Fall"].Instance) end
        if data.Hitbox ~= _G.HitboxEnabled then MenuButtons["HITBOX: OFF"].Callback(MenuButtons["HITBOX: OFF"].Instance) end
        if data.AimbotGui ~= AimGui.Enabled then MenuButtons["AIMBOT: OFF"].Callback(MenuButtons["AIMBOT: OFF"].Instance) end
        
        currentSpeed = data.SpeedValue or 50
        speedInput.Text = tostring(currentSpeed)
        _G.HeadSize = data.HitboxSize or 25
        hInput.Text = tostring(_G.HeadSize)
    end
end

local function ResetConfig()
    if _G.EspEnabled then MenuButtons["ESP"].Callback(MenuButtons["ESP"].Instance) end
    if StretchedActive then MenuButtons["Stretched"].Callback(MenuButtons["Stretched"].Instance) end
    if speedEnabled then MenuButtons["SPEED: OFF"].Callback(MenuButtons["SPEED: OFF"].Instance) end
    if flying then MenuButtons["FLY: OFF"].Callback(MenuButtons["FLY: OFF"].Instance) end
    if noclipEnabled then MenuButtons["NOCLIP: OFF"].Callback(MenuButtons["NOCLIP: OFF"].Instance) end
    if InfJump then MenuButtons["INF JUMP: OFF"].Callback(MenuButtons["INF JUMP: OFF"].Instance) end
    if sfActive then MenuButtons["Slow Fall"].Callback(MenuButtons["Slow Fall"].Instance) end
    if _G.HitboxEnabled then MenuButtons["HITBOX: OFF"].Callback(MenuButtons["HITBOX: OFF"].Instance) end
    if AimGui.Enabled then MenuButtons["AIMBOT: OFF"].Callback(MenuButtons["AIMBOT: OFF"].Instance) end
    
    currentSpeed = 50; speedInput.Text = "50"
    _G.HeadSize = 25; hInput.Text = "25"
end

CreateButton("Save", "Settings", function(self)
    if SaveConfig() then self.Text = "Saved!"; task.wait(0.8); self.Text = "Save" end
end)

CreateButton("Load", "Settings", function(self)
    LoadConfig(); self.Text = "Loaded!"; task.wait(0.8); self.Text = "Load"
end)

CreateButton("Reset", "Settings", function(self)
    ResetConfig(); self.Text = "Reset!"; task.wait(0.8); self.Text = "Reset"
end)

-- АВТОЗАГРУЗКА ПРИ ИНЖЕКТЕ
task.spawn(function()
    task.wait(0.5)
    LoadConfig()
end)

-----------------------------------------------------------
-- КНОПКА СВЕРНУТЬ (M)
-----------------------------------------------------------
local minBtn = Instance.new("TextButton", screenGui); minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(0, 10, 0, 10); minBtn.Text = "M"
minBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); minBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)
minBtn.MouseButton1Click:Connect(function() 
    mainFrame.Visible = not mainFrame.Visible 
    if not mainFrame.Visible then hitboxGui.Enabled = false elseif _G.HitboxEnabled then hitboxGui.Enabled = true end
end)
