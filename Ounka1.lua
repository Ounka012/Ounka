-- ================================================================
-- ✨ OUNCOPYBARA - EVADE / AUTO DASH (High Performance Edition)
-- Optimized | Clean Architecture | Modern Velocity
-- ================================================================

local EVADE_CONFIG = {
    AUTO_DASH      = false,
    DASH_SPEED     = 60,
    DASH_COOLDOWN  = 0.12,
    DASH_MODE      = "MoveDirection", -- "MoveDirection" | "CameraDirection"
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

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local TargetGui   = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup old GUI
if TargetGui:FindFirstChild("ouncopybara") then
    TargetGui.ouncopybara:Destroy()
end

-- ====================== THEME ======================
local Theme = {
    Background   = Color3.fromRGB(20, 8, 16),
    Sidebar      = Color3.fromRGB(28, 10, 22),
    Border       = Color3.fromRGB(255, 105, 180),
    Accent       = Color3.fromRGB(255, 20, 147),
    AccentHover  = Color3.fromRGB(255, 105, 180),
    AccentGlow   = Color3.fromRGB(255, 182, 193),
    Text         = Color3.fromRGB(255, 255, 255),
    Muted        = Color3.fromRGB(245, 190, 220),
    Input        = Color3.fromRGB(35, 12, 28),
}

local isMobile     = UserInputService.TouchEnabled
local MAIN_SIZE    = isMobile and UDim2.fromOffset(420, 340) or UDim2.fromOffset(600, 450)
local SIDEBAR_WIDTH = isMobile and 100 or 150

-- ====================== UTILITIES ======================
local function tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
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
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ====================== GUI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ouncopybara"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = TargetGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(0, 0)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Theme.Border

-- Sparkles
local moonSparkles = {}
local symbols = {"☾", "✦", "☽", "✧", "★"}

for i = 1, 35 do
    local sparkle = Instance.new("TextLabel")
    sparkle.Size = UDim2.fromOffset(math.random(10, 16), math.random(10, 16))
    sparkle.Position = UDim2.fromScale(math.random(), math.random())
    sparkle.BackgroundTransparency = 1
    sparkle.Text = symbols[math.random(#symbols)]
    sparkle.TextColor3 = Color3.fromHSV(0.9 + math.random() * 0.08, 0.75, 1)
    sparkle.Font = Enum.Font.GothamBold
    sparkle.TextSize = sparkle.Size.X.Offset
    sparkle.TextTransparency = 0.45
    sparkle.ZIndex = 0
    sparkle.Parent = mainFrame
    table.insert(moonSparkles, sparkle)
end

task.spawn(function()
    while mainFrame.Parent do
        for _, s in ipairs(moonSparkles) do
            if s and s.Parent then
                tween(s, {
                    TextTransparency = math.random(25, 75) / 100,
                    Size = UDim2.fromOffset(math.random(9, 15), math.random(9, 15))
                }, math.random(6, 14) / 10, Enum.EasingStyle.Sine)
            end
        end
        task.wait(0.7)
    end
end)

-- Toggle Button
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size = UDim2.fromOffset(52, 52)
toggleBtn.Position = UDim2.fromScale(0.04, 0.18)
toggleBtn.BackgroundColor3 = Theme.Sidebar
toggleBtn.ClipsDescendants = true
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Thickness = 2.5
toggleStroke.Color = Theme.Accent

task.spawn(function()
    local url = "https://files.catbox.moe/ka5x56.jpg"
    if writefile and getcustomasset then
        local name = "ounc_toggle.jpg"
        if not isfile(name) then
            local ok, data = pcall(game.HttpGet, game, url)
            if ok then writefile(name, data) end
        end
        if isfile(name) then
            toggleBtn.Image = getcustomasset(name)
        else
            toggleBtn.Image = url
        end
    else
        toggleBtn.Image = url
    end
end)

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

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -20)
divider.Position = UDim2.new(1, -1, 0, 10)
divider.BackgroundColor3 = Theme.AccentGlow
divider.BackgroundTransparency = 0.4
divider.BorderSizePixel = 0
divider.Parent = sidebar

-- Avatar
local avatar = Instance.new("ImageLabel")
avatar.Size = isMobile and UDim2.fromOffset(42, 42) or UDim2.fromOffset(62, 62)
avatar.Position = isMobile and UDim2.new(0.5, -21, 0, 18) or UDim2.new(0.5, -31, 0, 35)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxassetid://0"
avatar.Parent = sidebar
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke", avatar)
avatarStroke.Thickness = 2
avatarStroke.Color = Theme.Accent

task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    if ok then avatar.Image = thumb end
end)

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -16, 0, 36)
sidebarTitle.Position = UDim2.new(0, 8, 0, isMobile and 70 or 110)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "ouncopybara"
sidebarTitle.Font = Enum.Font.GothamBlack
sidebarTitle.TextSize = isMobile and 12 or 15
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
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundTransparency = 1
header.Parent = content
enableDrag(mainFrame, header)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 0, 26)
titleLabel.Position = UDim2.new(0, 18, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ouncopybara"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = isMobile and 15 or 19
titleLabel.TextColor3 = Theme.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -60, 0, 18)
welcomeLabel.Position = UDim2.new(0, 18, 0, 30)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome, " .. LocalPlayer.DisplayName
welcomeLabel.Font = Enum.Font.Gotham
welcomeLabel.TextSize = isMobile and 11 or 12
welcomeLabel.TextColor3 = Theme.Muted
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.fromOffset(26, 26)
minimizeBtn.Position = UDim2.new(1, -34, 0, 13)
minimizeBtn.BackgroundColor3 = Theme.Accent
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Theme.Text
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = header
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -80)
scroll.Position = UDim2.new(0, 0, 0, 52)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.fromOffset(0, 920)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = content

-- ====================== UI BUILDERS ======================
local function addToggle(y, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 40)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundColor3 = Theme.Input
    container.BackgroundTransparency = 0.25
    container.Parent = scroll
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 190, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = isMobile and 12 or 13
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.fromOffset(48, 24)
    toggleFrame.Position = UDim2.new(1, -60, 0.5, -12)
    toggleFrame.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55, 35, 50)
    toggleFrame.Parent = container
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(20, 20)
    knob.Position = UDim2.new(0, default and 25 or 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = toggleFrame
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        tween(toggleFrame, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 35, 50)}, 0.18)
        tween(knob, {Position = UDim2.new(0, state and 25 or 2, 0.5, -10)}, 0.18, Enum.EasingStyle.Back)
    end)
end

local function addTextBox(y, labelText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 32)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = isMobile and 11 or 12
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(72, 26)
    box.Position = UDim2.new(1, -120, 0, 3)
    box.BackgroundColor3 = Theme.Input
    box.TextColor3 = Theme.Text
    box.Text = tostring(default)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.fromOffset(40, 26)
    setBtn.Position = UDim2.new(1, -40, 0, 3)
    setBtn.BackgroundColor3 = Theme.Accent
    setBtn.Text = "Set"
    setBtn.TextColor3 = Theme.Text
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = 11
    setBtn.Parent = frame
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 5)

    setBtn.MouseButton1Click:Connect(function()
        callback(box.Text)
    end)
end

local function addButton(y, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    btn.MouseButton1Click:Connect(callback)
end

-- ====================== OPTIONS ======================
addToggle(10,  "Auto Dash",       false, function(v) EVADE_CONFIG.AUTO_DASH = v end)
addTextBox(55, "Dash Speed",      "60",  function(v) EVADE_CONFIG.DASH_SPEED = tonumber(v) or 60 end)
addTextBox(95, "Cooldown",        "0.12",function(v) EVADE_CONFIG.DASH_COOLDOWN = tonumber(v) or 0.12 end)
addToggle(135, "Instant Dash",    false, function(v) EVADE_CONFIG.INSTANT_DASH = v end)

-- Direction Selector
do
    local dirContainer = Instance.new("Frame")
    dirContainer.Size = UDim2.new(1, -20, 0, 40)
    dirContainer.Position = UDim2.new(0, 10, 0, 180)
    dirContainer.BackgroundColor3 = Theme.Input
    dirContainer.BackgroundTransparency = 0.25
    dirContainer.Parent = scroll
    Instance.new("UICorner", dirContainer).CornerRadius = UDim.new(0, 8)

    local dirLabel = Instance.new("TextLabel")
    dirLabel.Size = UDim2.new(0, 100, 1, 0)
    dirLabel.Position = UDim2.new(0, 12, 0, 0)
    dirLabel.BackgroundTransparency = 1
    dirLabel.Text = "Direction:"
    dirLabel.Font = Enum.Font.GothamBold
    dirLabel.TextSize = 13
    dirLabel.TextColor3 = Theme.Text
    dirLabel.TextXAlignment = Enum.TextXAlignment.Left
    dirLabel.Parent = dirContainer

    local moveBtn = Instance.new("TextButton")
    moveBtn.Size = UDim2.fromOffset(64, 26)
    moveBtn.Position = UDim2.new(0, 110, 0, 7)
    moveBtn.BackgroundColor3 = Theme.Accent
    moveBtn.Text = "Move"
    moveBtn.TextColor3 = Theme.Text
    moveBtn.Font = Enum.Font.GothamBold
    moveBtn.TextSize = 11
    moveBtn.Parent = dirContainer
    Instance.new("UICorner", moveBtn).CornerRadius = UDim.new(0, 5)

    local cameraBtn = Instance.new("TextButton")
    cameraBtn.Size = UDim2.fromOffset(64, 26)
    cameraBtn.Position = UDim2.new(0, 182, 0, 7)
    cameraBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 50)
    cameraBtn.Text = "Camera"
    cameraBtn.TextColor3 = Theme.Text
    cameraBtn.Font = Enum.Font.GothamBold
    cameraBtn.TextSize = 11
    cameraBtn.Parent = dirContainer
    Instance.new("UICorner", cameraBtn).CornerRadius = UDim.new(0, 5)

    moveBtn.MouseButton1Click:Connect(function()
        EVADE_CONFIG.DASH_MODE = "MoveDirection"
        moveBtn.BackgroundColor3 = Theme.Accent
        cameraBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 50)
    end)

    cameraBtn.MouseButton1Click:Connect(function()
        EVADE_CONFIG.DASH_MODE = "CameraDirection"
        cameraBtn.BackgroundColor3 = Theme.Accent
        moveBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 50)
    end)
end

addTextBox(230, "Walk Speed",     "16",  function(v) EVADE_CONFIG.WALKSPEED = tonumber(v) or 16 end)
addToggle(270,  "Super Jump",     false, function(v) EVADE_CONFIG.SUPER_JUMP = v end)
addTextBox(315, "Jump Power",     "50",  function(v) EVADE_CONFIG.JUMP_POWER = tonumber(v) or 50 end)
addToggle(355,  "Infinite Jump",  false, function(v) EVADE_CONFIG.INFINITE_JUMP = v end)

addToggle(400,  "Player ESP",     false, function(v) EVADE_CONFIG.ESP_PLAYERS = v end)
addToggle(445,  "Bot / NPC ESP",  false, function(v) EVADE_CONFIG.ESP_BOTS = v end)

addToggle(490,  "FullBright",     false, function(v) EVADE_CONFIG.FULLBRIGHT = v end)
addToggle(535,  "No Clip",        false, function(v) EVADE_CONFIG.NO_CLIP = v end)
addTextBox(580, "FOV",            "70",  function(v)
    EVADE_CONFIG.FOV = tonumber(v) or 70
    if Camera then Camera.FieldOfView = EVADE_CONFIG.FOV end
end)

addToggle(625,  "Auto Revive",    false, function(v) EVADE_CONFIG.AUTO_REVIVE = v end)
addToggle(670,  "Auto Respawn",   false, function(v) EVADE_CONFIG.AUTO_RESPAWN = v end)

addButton(720, "Teleport Safe Zone", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local zone = Workspace:FindFirstChild("SafeZone") or Workspace:FindFirstChild("Spawns")
    if root and zone then
        root.CFrame = zone:IsA("Model") and zone:GetPivot() or zone.CFrame
    end
end)

addButton(765, "Unload Script", function()
    screenGui:Destroy()
end)

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 26)
statusBar.Position = UDim2.new(0, 0, 1, -26)
statusBar.BackgroundColor3 = Theme.Sidebar
statusBar.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -16, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "● Ready"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 11
statusText.TextColor3 = Theme.Muted
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusBar

-- Glow Animation
task.spawn(function()
    while screenGui.Parent do
        tween(mainStroke,   {Color = Color3.fromRGB(255, 182, 193)}, 1.3, Enum.EasingStyle.Sine)
        tween(toggleStroke, {Color = Color3.fromRGB(255, 105, 180)}, 1.3, Enum.EasingStyle.Sine)
        tween(avatarStroke, {Color = Color3.fromRGB(255, 182, 193)}, 1.3, Enum.EasingStyle.Sine)
        task.wait(1.3)
        tween(mainStroke,   {Color = Color3.fromRGB(255, 20, 147)}, 1.3, Enum.EasingStyle.Sine)
        tween(toggleStroke, {Color = Color3.fromRGB(255, 182, 193)}, 1.3, Enum.EasingStyle.Sine)
        tween(avatarStroke, {Color = Color3.fromRGB(255, 20, 147)}, 1.3, Enum.EasingStyle.Sine)
        task.wait(1.3)
    end
end)

-- Entrance
tween(mainFrame, {Size = MAIN_SIZE}, 0.4, Enum.EasingStyle.Back)

-- ====================== CORE LOGIC ======================
local lastDashTime = 0
local originalJumpPower = 50
local originalWalkSpeed = 16

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ===== DASH (Modern) =====
local function performDash()
    local now = os.clock()
    if now - lastDashTime < EVADE_CONFIG.DASH_COOLDOWN then return end

    local root = getRoot()
    local hum  = getHumanoid()
    if not root or not hum or hum.MoveDirection.Magnitude < 0.1 then return end

    local dir
    if EVADE_CONFIG.DASH_MODE == "CameraDirection" and Camera then
        dir = Camera.CFrame.LookVector
        dir = Vector3.new(dir.X, 0, dir.Z)
    else
        dir = hum.MoveDirection
    end

    if dir.Magnitude < 0.1 then return end
    dir = dir.Unit

    lastDashTime = now

    if EVADE_CONFIG.INSTANT_DASH then
        root.CFrame = root.CFrame + dir * (EVADE_CONFIG.DASH_SPEED * 0.18)
    else
        -- Clean velocity-based dash (no BodyVelocity)
        local current = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(
            dir.X * EVADE_CONFIG.DASH_SPEED,
            current.Y, -- keep vertical velocity
            dir.Z * EVADE_CONFIG.DASH_SPEED
        )
    end
end

-- ===== ESP SYSTEM (Optimized) =====
local playerHighlights = {}
local botHighlights = {}

local function createHighlight(model, color, storage)
    if storage[model] and storage[model].Parent then return end
    local hl = Instance.new("Highlight")
    hl.Name = "OuncESP"
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0.1
    hl.Adornee = model
    hl.Parent = model
    storage[model] = hl
end

local function clearHighlights(storage)
    for model, hl in pairs(storage) do
        if hl then hl:Destroy() end
        storage[model] = nil
    end
end

-- Update ESP every 0.25s instead of every frame
task.spawn(function()
    while screenGui.Parent do
        -- Players
        if EVADE_CONFIG.ESP_PLAYERS then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr \~= LocalPlayer and plr.Character then
                    createHighlight(plr.Character, Color3.fromRGB(255, 182, 193), playerHighlights)
                end
            end
        else
            clearHighlights(playerHighlights)
        end

        -- Bots (only scan when enabled)
        if EVADE_CONFIG.ESP_BOTS then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj \~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                    if obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("HumanoidRootPart") then
                        createHighlight(obj, Color3.fromRGB(255, 20, 147), botHighlights)
                    end
                end
            end
        else
            clearHighlights(botHighlights)
        end

        task.wait(0.25)
    end
end)

-- ===== MAIN LOOPS =====
RunService.Heartbeat:Connect(function()
    if EVADE_CONFIG.AUTO_DASH then
        performDash()
    end
end)

RunService.Stepped:Connect(function()
    if EVADE_CONFIG.NO_CLIP and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local hum = getHumanoid()
    if not hum then return end

    -- WalkSpeed
    if not EVADE_CONFIG.AUTO_DASH then
        hum.WalkSpeed = EVADE_CONFIG.WALKSPEED
    end

    -- Super Jump
    if EVADE_CONFIG.SUPER_JUMP then
        hum.JumpPower = EVADE_CONFIG.JUMP_POWER
        hum.JumpHeight = EVADE_CONFIG.JUMP_POWER / 3.5 -- better compatibility
    end

    -- Fullbright
    if EVADE_CONFIG.FULLBRIGHT then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not EVADE_CONFIG.INFINITE_JUMP then return end
    local root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X,
            EVADE_CONFIG.JUMP_POWER,
            root.AssemblyLinearVelocity.Z
        )
    end
end)

-- Auto Respawn + Auto Revive
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    hum.Died:Connect(function()
        if EVADE_CONFIG.AUTO_RESPAWN then
            task.wait(0.4)
            pcall(function() LocalPlayer:LoadCharacter() end)
        end
    end)
end)

-- Auto Revive (basic implementation - works on many Evade-like games)
task.spawn(function()
    while screenGui.Parent do
        if EVADE_CONFIG.AUTO_REVIVE then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then
                -- Try common revive methods
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Revive") 
                        or game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    -- Fallback: force respawn
                    LocalPlayer:LoadCharacter()
                end)
            end
        end
        task.wait(1)
    end
end)

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Status
task.spawn(function()
    local frames, last = 0, os.clock()
    while screenGui.Parent do
        frames += 1
        local now = os.clock()
        if now - last >= 1 then
            local fps = math.floor(frames / (now - last))
            frames = 0
            last = now
            local ping = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000)
            statusText.Text = string.format(
                "● FPS: %d | Ping: %dms | Dash: %s | Jump: %s",
                fps, ping,
                EVADE_CONFIG.AUTO_DASH and "ON" or "OFF",
                EVADE_CONFIG.SUPER_JUMP and "ON" or "OFF"
            )
        end
        task.wait(0.15)
    end
end)

print("✨ ouncopybara High Performance Edition loaded successfully!")