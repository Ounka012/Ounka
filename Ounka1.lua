-- ================================================================
-- ✨ OUNCOPYBARA - EVADE (Mobile Compatible Edition - FIXED) ✨
-- ================================================================

-- Polyfill for older executors
if not task then
    task = {}
    task.spawn = function(f) coroutine.wrap(f)() end
    task.wait = wait
    task.delay = function(t, f) coroutine.wrap(function() wait(t) f() end)() end
end

local EVADE_CONFIG = {
    AUTO_DASH      = false,
    DASH_SPEED     = 60,
    DASH_COOLDOWN  = 0.12,
    DASH_MODE      = "MoveDirection",
    INSTANT_DASH   = false,
    WALKSPEED      = 16,
    SUPER_JUMP     = false,
    INFINITE_JUMP  = false,
    JUMP_POWER     = 50,
    FULLBRIGHT     = false,
    AUTO_REVIVE    = false,
    AUTO_RESPAWN   = false,
    NO_CLIP        = false,
    FOV            = 70,
    ESP_PLAYERS    = false,
    ESP_BOTS       = false,
}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local TargetGui = CoreGui
pcall(function()
    if gethui then TargetGui = gethui() end
end)
if not TargetGui then
    TargetGui = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetGui:FindFirstChild("ouncopybara") then
    TargetGui.ouncopybara:Destroy()
end

local Theme = {
    Background  = Color3.fromRGB(20, 8, 16),
    Sidebar     = Color3.fromRGB(28, 10, 22),
    Border      = Color3.fromRGB(255, 105, 180),
    Accent      = Color3.fromRGB(255, 20, 147),
    AccentGlow  = Color3.fromRGB(255, 182, 193),
    Text        = Color3.fromRGB(255, 255, 255),
    Muted       = Color3.fromRGB(245, 190, 220),
    Input       = Color3.fromRGB(35, 12, 28),
}

local isMobile = UserInputService.TouchEnabled
local MAIN_SIZE = isMobile and UDim2.new(0, 400, 0, 340) or UDim2.new(0, 580, 0, 440)
local SIDEBAR_WIDTH = isMobile and 95 or 140

local function tween(obj, props, duration)
    local info = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function enableDrag(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragInput, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ouncopybara"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = TargetGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Theme.Border

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.04, 0, 0.18, 0)
toggleBtn.BackgroundColor3 = Theme.Sidebar
toggleBtn.Text = "🌙"
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Theme.AccentGlow
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Thickness = 2.5
toggleStroke.Color = Theme.Accent

enableDrag(toggleBtn)
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -10, 0, 40)
sidebarTitle.Position = UDim2.new(0, 5, 0, isMobile and 20 or 30)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "ouncopybara"
sidebarTitle.Font = Enum.Font.GothamBlack
sidebarTitle.TextSize = isMobile and 12 or 14
sidebarTitle.TextColor3 = Theme.AccentGlow
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Center
sidebarTitle.Parent = sidebar

-- Content
local content = Instance.new("Frame")
content.Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0)
content.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundTransparency = 1
header.Parent = content
enableDrag(mainFrame, header)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 0, 24)
titleLabel.Position = UDim2.new(0, 14, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ouncopybara"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = isMobile and 14 or 17
titleLabel.TextColor3 = Theme.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -50, 0, 16)
welcomeLabel.Position = UDim2.new(0, 14, 0, 28)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome, " .. (LocalPlayer.DisplayName or "Player")
welcomeLabel.Font = Enum.Font.Gotham
welcomeLabel.TextSize = 11
welcomeLabel.TextColor3 = Theme.Muted
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -32, 0, 12)
minimizeBtn.BackgroundColor3 = Theme.Accent
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Theme.Text
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = header
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -74)
scroll.Position = UDim2.new(0, 0, 0, 48)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 880)
scroll.Parent = content

-- UI Builders
local function addToggle(y, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 38)
    container.Position = UDim2.new(0, 8, 0, y)
    container.BackgroundColor3 = Theme.Input
    container.BackgroundTransparency = 0.3
    container.Parent = scroll
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 170, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = isMobile and 11 or 12
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 44, 0, 22)
    toggleFrame.Position = UDim2.new(1, -54, 0.5, -11)
    toggleFrame.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55, 35, 50)
    toggleFrame.Parent = container
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, default and 23 or 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = toggleFrame
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        tween(toggleFrame, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 35, 50)}, 0.15)
        tween(knob, {Position = UDim2.new(0, state and 23 or 2, 0.5, -9)}, 0.15)
    end)
end

local function addTextBox(y, labelText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 30)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 110, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 65, 0, 24)
    box.Position = UDim2.new(1, -115, 0, 3)
    box.BackgroundColor3 = Theme.Input
    box.TextColor3 = Theme.Text
    box.Text = tostring(default)
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.BorderSizePixel = 0
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0, 38, 0, 24)
    setBtn.Position = UDim2.new(1, -42, 0, 3)
    setBtn.BackgroundColor3 = Theme.Accent
    setBtn.Text = "Set"
    setBtn.TextColor3 = Theme.Text
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = 10
    setBtn.Parent = frame
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 5)

    setBtn.MouseButton1Click:Connect(function()
        callback(box.Text)
    end)
end

local function addButton(y, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    btn.MouseButton1Click:Connect(callback)
end

-- Options
addToggle(8,   "Auto Dash",       false, function(v) EVADE_CONFIG.AUTO_DASH = v end)
addTextBox(50, "Dash Speed",      "60",  function(v) EVADE_CONFIG.DASH_SPEED = tonumber(v) or 60 end)
addTextBox(88, "Cooldown",        "0.12",function(v) EVADE_CONFIG.DASH_COOLDOWN = tonumber(v) or 0.12 end)
addToggle(126, "Instant Dash",    false, function(v) EVADE_CONFIG.INSTANT_DASH = v end)

addTextBox(170, "Walk Speed",     "16",  function(v) EVADE_CONFIG.WALKSPEED = tonumber(v) or 16 end)
addToggle(208, "Super Jump",      false, function(v) EVADE_CONFIG.SUPER_JUMP = v end)
addTextBox(250, "Jump Power",     "50",  function(v) EVADE_CONFIG.JUMP_POWER = tonumber(v) or 50 end)
addToggle(288, "Infinite Jump",   false, function(v) EVADE_CONFIG.INFINITE_JUMP = v end)

addToggle(330, "Player ESP",      false, function(v) EVADE_CONFIG.ESP_PLAYERS = v end)
addToggle(368, "Bot ESP",         false, function(v) EVADE_CONFIG.ESP_BOTS = v end)
addToggle(406, "FullBright",      false, function(v) EVADE_CONFIG.FULLBRIGHT = v end)
addToggle(444, "No Clip",         false, function(v) EVADE_CONFIG.NO_CLIP = v end)

addTextBox(486, "FOV",            "70",  function(v)
    EVADE_CONFIG.FOV = tonumber(v) or 70
    if Camera then Camera.FieldOfView = EVADE_CONFIG.FOV end
end)

addToggle(528, "Auto Revive",     false, function(v) EVADE_CONFIG.AUTO_REVIVE = v end)
addToggle(566, "Auto Respawn",    false, function(v) EVADE_CONFIG.AUTO_RESPAWN = v end)

addButton(610, "Teleport Safe Zone", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local zone = Workspace:FindFirstChild("SafeZone") or Workspace:FindFirstChild("Spawns")
    if root and zone then
        root.CFrame = zone:IsA("Model") and zone:GetPivot() or zone.CFrame
    end
end)

addButton(650, "Unload Script", function()
    screenGui:Destroy()
end)

-- Status
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 24)
statusBar.Position = UDim2.new(0, 0, 1, -24)
statusBar.BackgroundColor3 = Theme.Sidebar
statusBar.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -12, 1, 0)
statusText.Position = UDim2.new(0, 8, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "● Ready"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 10
statusText.TextColor3 = Theme.Muted
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusBar

-- Glow
task.spawn(function()
    while screenGui and screenGui.Parent do
        tween(mainStroke, {Color = Color3.fromRGB(255, 182, 193)}, 1.2)
        tween(toggleStroke, {Color = Color3.fromRGB(255, 105, 180)}, 1.2)
        task.wait(1.2)
        tween(mainStroke, {Color = Color3.fromRGB(255, 20, 147)}, 1.2)
        tween(toggleStroke, {Color = Color3.fromRGB(255, 182, 193)}, 1.2)
        task.wait(1.2)
    end
end)

tween(mainFrame, {Size = MAIN_SIZE}, 0.35)

-- ====================== CORE ======================
local lastDashTime = 0

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function performDash()
    local now = os.clock()
    if now - lastDashTime < EVADE_CONFIG.DASH_COOLDOWN then return end

    local root = getRoot()
    local hum = getHumanoid()
    if not root or not hum or hum.MoveDirection.Magnitude < 0.1 then return end

    local dir
    if EVADE_CONFIG.DASH_MODE == "CameraDirection" and Camera then
        local look = Camera.CFrame.LookVector
        dir = Vector3.new(look.X, 0, look.Z)
    else
        dir = hum.MoveDirection
    end

    if dir.Magnitude < 0.1 then return end
    dir = dir.Unit
    lastDashTime = now

    if EVADE_CONFIG.INSTANT_DASH then
        root.CFrame = root.CFrame + dir * (EVADE_CONFIG.DASH_SPEED * 0.16)
    else
        local vel = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(dir.X * EVADE_CONFIG.DASH_SPEED, vel.Y, dir.Z * EVADE_CONFIG.DASH_SPEED)
    end
end

-- ESP (lightweight)
local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then  -- កែពី \~= ទៅ ~=
            local hl = plr.Character:FindFirstChild("OuncESP")
            if EVADE_CONFIG.ESP_PLAYERS then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "OuncESP"
                    hl.FillColor = Color3.fromRGB(255, 182, 193)
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.45
                    hl.Parent = plr.Character
                end
            elseif hl then
                hl:Destroy()
            end
        end
    end
end

-- Loops
RunService.Heartbeat:Connect(function()
    if EVADE_CONFIG.AUTO_DASH then
        performDash()
    end
end)

RunService.Stepped:Connect(function()
    if EVADE_CONFIG.NO_CLIP and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local hum = getHumanoid()
    if hum then
        if not EVADE_CONFIG.AUTO_DASH then
            hum.WalkSpeed = EVADE_CONFIG.WALKSPEED
        end
        if EVADE_CONFIG.SUPER_JUMP then
            hum.JumpPower = EVADE_CONFIG.JUMP_POWER
        end
    end

    if EVADE_CONFIG.FULLBRIGHT then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end

    updateESP()
end)

UserInputService.JumpRequest:Connect(function()
    if EVADE_CONFIG.INFINITE_JUMP then
        local root = getRoot()
        if root then
            local vel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(vel.X, EVADE_CONFIG.JUMP_POWER, vel.Z)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then
        hum.Died:Connect(function()
            if EVADE_CONFIG.AUTO_RESPAWN then
                task.wait(0.5)
                pcall(function() LocalPlayer:LoadCharacter() end)
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Status updater
task.spawn(function()
    local frames = 0
    local last = os.clock()
    while screenGui and screenGui.Parent do
        frames = frames + 1
        local now = os.clock()
        if now - last >= 1 then
            local fps = math.floor(frames / (now - last))
            frames = 0
            last = now
            local ping = 0
            pcall(function()
                ping = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000)
            end)
            statusText.Text = string.format("● FPS: %d | Ping: %dms | Dash: %s", fps, ping, EVADE_CONFIG.AUTO_DASH and "ON" or "OFF")
        end
        task.wait(0.2)
    end
end)

print("✨ ouncopybara Mobile Compatible fixed loaded!")