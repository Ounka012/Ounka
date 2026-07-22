
blade_ball_gui = '''--[[
    ⚔️ Blade Ball VIP - Premium GUI
    ⚠️ WARNING: Using scripts may result in account bans.
    This is for educational purposes only.
    
    BAC detects: VirtualInputManager, perfect timing, teleportation
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
--  ការកំណត់ (Settings)
-- ================================================================
local Settings = {
    Enabled = false,
    ParryDistance = 22,
    ClickInterval = 0.25,
    DodgeEnabled = false,
    DodgeDistance = 10,
    ESP = false,
    ESPColor = Color3.fromRGB(255, 220, 100),
    ToggleKey = Enum.KeyCode.F,
    MinReactionTime = 0.05,  -- ពេលវេលាឆ្លើយតបអប្បបរមា (មនុស្សមិនអាចឆ្លើយតប 0ms បានទេ)
    MaxReactionTime = 0.15   -- ពេលវេលាឆ្លើយតបអតិបរមា
}

-- ================================================================
--  Utility Functions
-- ================================================================
local function tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Random delay ដូចមនុស្សពិត (human-like reaction)
local function humanDelay()
    return lerp(Settings.MinReactionTime, Settings.MaxReactionTime, math.random())
end

-- ================================================================
--  លុប GUI ចាស់
-- ================================================================
for _, child in ipairs(CoreGui:GetChildren()) do
    if child.Name:match("BladeBall") or child.Name:match("VIP") then
        pcall(function() child:Destroy() end)
    end
end

-- ================================================================
--  បង្កើត GUI
-- ================================================================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "BladeBall_Premium_" .. tostring(math.random(1000, 9999))
gui.IgnoreGuiInset = true

-- Blur Background
local blur = Instance.new("Frame", gui)
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.new(0, 0, 0)
blur.BackgroundTransparency = 0.5
blur.Visible = false
blur.ZIndex = 0

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 420)
main.Position = UDim2.new(0.5, -200, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.ClipsDescendants = true

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 20)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(100, 100, 220)
mainStroke.Transparency = 0.3

-- Shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1, 70, 1, 70)
shadow.Position = UDim2.new(0, -35, 0, -35)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.55
shadow.ZIndex = -2

-- Background Gradient
local bgGrad = Instance.new("UIGradient", main)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 25))
})
bgGrad.Rotation = 45

-- ====== Header ======
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1

local avatar = Instance.new("Frame", header)
avatar.Size = UDim2.new(0, 40, 0, 40)
avatar.Position = UDim2.new(0, 18, 0, 10)
avatar.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

local avCorner = Instance.new("UICorner", avatar)
avCorner.CornerRadius = UDim.new(1, 0)

local avInner = Instance.new("Frame", avatar)
avInner.Size = UDim2.new(0.8, 0, 0.8, 0)
avInner.Position = UDim2.new(0.1, 0, 0.1, 0)
avInner.BackgroundColor3 = Color3.fromRGB(25, 25, 45)

local avInnerCorner = Instance.new("UICorner", avInner)
avInnerCorner.CornerRadius = UDim.new(1, 0)

local avText = Instance.new("TextLabel", avInner)
avText.Size = UDim2.new(1, 0, 1, 0)
avText.BackgroundTransparency = 1
avText.Text = "⚔️"
avText.Font = Enum.Font.GothamBold
avText.TextSize = 18

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0, 200, 0, 24)
title.Position = UDim2.new(0, 68, 0, 8)
title.BackgroundTransparency = 1
title.Text = "BLADE BALL VIP"
title.Font = Enum.Font.GothamBlack
title.TextSize = 17
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(0, 200, 0, 16)
subtitle.Position = UDim2.new(0, 68, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PREMIUM EDITION"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 16)
closeBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.AutoButtonColor = false

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

local headerLine = Instance.new("Frame", header)
headerLine.Size = UDim2.new(1, -36, 0, 1)
headerLine.Position = UDim2.new(0, 18, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
headerLine.BackgroundTransparency = 0.5

-- ====== Content ======
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -36, 1, -120)
content.Position = UDim2.new(0, 18, 0, 65)
content.BackgroundTransparency = 1

-- Master Toggle (Big Button)
local masterFrame = Instance.new("Frame", content)
masterFrame.Size = UDim2.new(1, 0, 0, 55)
masterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
masterFrame.BackgroundTransparency = 0.2

local masterCorner = Instance.new("UICorner", masterFrame)
masterCorner.CornerRadius = UDim.new(0, 14)

local masterLabel = Instance.new("TextLabel", masterFrame)
masterLabel.Size = UDim2.new(0, 150, 1, 0)
masterLabel.Position = UDim2.new(0, 15, 0, 0)
masterLabel.BackgroundTransparency = 1
masterLabel.Text = "🎮 AUTO PARRY"
masterLabel.Font = Enum.Font.GothamBold
masterLabel.TextSize = 14
masterLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
masterLabel.TextXAlignment = Enum.TextXAlignment.Left

local masterToggle = Instance.new("Frame", masterFrame)
masterToggle.Size = UDim2.new(0, 52, 0, 28)
masterToggle.Position = UDim2.new(1, -67, 0.5, -14)
masterToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

local mtCorner = Instance.new("UICorner", masterToggle)
mtCorner.CornerRadius = UDim.new(1, 0)

local masterKnob = Instance.new("Frame", masterToggle)
masterKnob.Size = UDim2.new(0, 24, 0, 24)
masterKnob.Position = UDim2.new(0, 2, 0.5, -12)
masterKnob.BackgroundColor3 = Color3.new(1, 1, 1)

local mkCorner = Instance.new("UICorner", masterKnob)
mkCorner.CornerRadius = UDim.new(1, 0)

local masterBtn = Instance.new("TextButton", masterFrame)
masterBtn.Size = UDim2.new(1, 0, 1, 0)
masterBtn.BackgroundTransparency = 1
masterBtn.Text = ""

-- Status
local statusLabel = Instance.new("TextLabel", content)
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.Position = UDim2.new(0, 0, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● រង់ចាំបើក..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ====== Slider Function ======
local function createSlider(parent, yPos, name, min, max, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 55)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
    container.BackgroundTransparency = 0.2
    
    local cCorner = Instance.new("UICorner", container)
    cCorner.CornerRadius = UDim.new(0, 12)
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0, 200, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local barBg = Instance.new("Frame", container)
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 0, 32)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    barBg.BorderSizePixel = 0
    
    local barBgCorner = Instance.new("UICorner", barBg)
    barBgCorner.CornerRadius = UDim.new(1, 0)
    
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    barFill.BorderSizePixel = 0
    
    local barFillCorner = Instance.new("UICorner", barFill)
    barFillCorner.CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("TextButton", barBg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Text = ""
    
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)
    
    -- Slider logic
    local dragging = false
    local currentValue = default
    
    local function updateValue(inputX)
        local relX = math.clamp(inputX - barBg.AbsolutePosition.X, 0, barBg.AbsoluteSize.X)
        local value = min + (relX / barBg.AbsoluteSize.X) * (max - min)
        if max > 10 then
            value = math.floor(value)
        else
            value = math.floor(value * 100) / 100
        end
        currentValue = value
        barFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        knob.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
        label.Text = name .. ": " .. value
        callback(value)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return container
end

-- Create Sliders
createSlider(content, 85, "📏 Parry Distance", 10, 50, Settings.ParryDistance, function(v) Settings.ParryDistance = v end)
createSlider(content, 148, "⏱️ Min Reaction", 0.03, 0.2, Settings.MinReactionTime, function(v) Settings.MinReactionTime = v end)
createSlider(content, 211, "⏱️ Max Reaction", 0.1, 0.4, Settings.MaxReactionTime, function(v) Settings.MaxReactionTime = v end)

-- ====== Bottom Toggles ======
local bottomFrame = Instance.new("Frame", main)
bottomFrame.Size = UDim2.new(1, -36, 0, 40)
bottomFrame.Position = UDim2.new(0, 18, 1, -55)
bottomFrame.BackgroundTransparency = 1

local function createMiniToggle(parent, xPos, icon, name, color)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.48, 0, 1, 0)
    frame.Position = UDim2.new(xPos, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
    frame.BackgroundTransparency = 0.2
    
    local fCorner = Instance.new("UICorner", frame)
    fCorner.CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = icon .. " " .. name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(200, 200, 230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("Frame", frame)
    toggle.Size = UDim2.new(0, 36, 0, 20)
    toggle.Position = UDim2.new(1, -46, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    
    local tCorner = Instance.new("UICorner", toggle)
    tCorner.CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    return {frame = frame, toggle = toggle, knob = knob, btn = btn, color = color}
end

local espToggle = createMiniToggle(bottomFrame, 0, "👁️", "ESP", Color3.fromRGB(255, 220, 100))
local dodgeToggle = createMiniToggle(bottomFrame, 0.52, "🏃", "DODGE", Color3.fromRGB(255, 100, 100))

-- ====== Warning Label ======
local warnLabel = Instance.new("TextLabel", main)
warnLabel.Size = UDim2.new(1, -36, 0, 14)
warnLabel.Position = UDim2.new(0, 18, 1, -16)
warnLabel.BackgroundTransparency = 1
warnLabel.Text = "⚠️ Risk of ban exists - Use at your own risk"
warnLabel.Font = Enum.Font.Gotham
warnLabel.TextSize = 9
warnLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
warnLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ====== Floating Toggle Button ======
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0, 55, 0, 55)
floatBtn.Position = UDim2.new(0, 25, 0.5, -27)
floatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
floatBtn.Image = ""

local fbCorner = Instance.new("UICorner", floatBtn)
fbCorner.CornerRadius = UDim.new(1, 0)

local fbStroke = Instance.new("UIStroke", floatBtn)
fbStroke.Thickness = 2
fbStroke.Color = Color3.fromRGB(100, 100, 255)
fbStroke.Transparency = 0.3

local fbInner = Instance.new("Frame", floatBtn)
fbInner.Size = UDim2.new(0.65, 0, 0.65, 0)
fbInner.Position = UDim2.new(0.175, 0, 0.175, 0)
fbInner.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
fbInner.BackgroundTransparency = 0.7

local fbInnerCorner = Instance.new("UICorner", fbInner)
fbInnerCorner.CornerRadius = UDim.new(1, 0)

-- ================================================================
--  មុខងារ (Logic)
-- ================================================================

-- Toggle Animation
local function animateToggle(toggleData, state)
    if state then
        tween(toggleData.toggle, {BackgroundColor3 = toggleData.color}, 0.2)
        tween(toggleData.knob, {Position = UDim2.new(0, toggleData.toggle.AbsoluteSize.X - toggleData.knob.AbsoluteSize.X - 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        tween(toggleData.toggle, {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}, 0.2)
        tween(toggleData.knob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end

-- Master Toggle
masterBtn.MouseButton1Down:Connect(function()
    Settings.Enabled = not Settings.Enabled
    animateToggle({toggle = masterToggle, knob = masterKnob}, Settings.Enabled)
    
    if Settings.Enabled then
        tween(masterFrame, {BackgroundColor3 = Color3.fromRGB(15, 40, 25)}, 0.3)
        masterLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        statusLabel.Text = "● កំពុងដំណើរការ..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    else
        tween(masterFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 38)}, 0.3)
        masterLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        statusLabel.Text = "● បិទ"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
    end
end)

-- ESP Toggle
espToggle.btn.MouseButton1Down:Connect(function()
    Settings.ESP = not Settings.ESP
    animateToggle(espToggle, Settings.ESP)
end)

-- Dodge Toggle
dodgeToggle.btn.MouseButton1Down:Connect(function()
    Settings.DodgeEnabled = not Settings.DodgeEnabled
    animateToggle(dodgeToggle, Settings.DodgeEnabled)
end)

-- ====== Ball Detection ======
local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("ball") or name:find("blade") or name:find("sphere") then
                if obj.Size.Magnitude > 2 and obj.Size.Magnitude < 15 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- ====== ESP System (Subtle) ======
local espObjects = {}

local function createESP(ball)
    if not ball or espObjects[ball] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 60, 0, 20)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚔️"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Settings.ESPColor
    label.TextStrokeTransparency = 0.5
    
    billboard.Parent = ball
    espObjects[ball] = billboard
end

local function clearESP()
    for ball, gui in pairs(espObjects) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    espObjects = {}
end

-- ====== Click Function (Human-like) ======
local lastClick = 0
local function clickMouse()
    local now = tick()
    if now - lastClick < 0.05 then return end -- ការពារការចុចរហូត
    lastClick = now
    
    -- Use VirtualUser instead of VirtualInputManager (less detectable in some cases)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

-- ====== Dodge (Smooth, not teleport) ======
local function dodge(ball)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local dir = (root.Position - ball.Position).Unit
    local targetPos = root.Position + dir * 4
    
    -- Smooth movement instead of teleport
    local startPos = root.Position
    local startTime = tick()
    local duration = 0.15
    
    while tick() - startTime < duration do
        local t = (tick() - startTime) / duration
        t = t * t * (3 - 2 * t) -- smoothstep
        root.CFrame = CFrame.new(startPos:Lerp(targetPos, t))
        RunService.Heartbeat:Wait()
    end
end

-- ====== Main Loop ======
RunService.Heartbeat:Connect(function()
    if not Settings.Enabled then
        clearESP()
        return
    end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local ball = findBall()
    if not ball then
        clearESP()
        return
    end
    
    local dist = (ball.Position - root.Position).Magnitude
    
    -- ESP
    if Settings.ESP then
        createESP(ball)
    else
        clearESP()
    end
    
    -- Dodge (smooth, not teleport)
    if Settings.DodgeEnabled and dist <= Settings.DodgeDistance then
        dodge(ball)
    end
    
    -- Auto Parry with human-like delay
    if dist <= Settings.ParryDistance then
        local reactionTime = humanDelay()
        task.delay(reactionTime, function()
            if Settings.Enabled then
                clickMouse()
            end
        end)
    end
end)

-- ====== GUI Toggle ======
floatBtn.MouseButton1Down:Connect(function()
    if main.Visible then
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        main.Visible = false
        blur.Visible = false
    else
        main.Visible = true
        blur.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        tween(main, {Size = UDim2.new(0, 400, 0, 420)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

closeBtn.MouseButton1Down:Connect(function()
    tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    task.wait(0.2)
    Settings.Enabled = false
    clearESP()
    gui:Destroy()
end)

-- Hover
closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(230, 60, 60)}, 0.15)
end)

-- ====== Keybind ======
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.ToggleKey then
        if main.Visible then
            tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            main.Visible = false
            blur.Visible = false
        else
            main.Visible = true
            blur.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            tween(main, {Size = UDim2.new(0, 400, 0, 420)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
end)

-- ====== Draggable ======
local function makeDraggable(obj)
    local drag, startPos, objPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startPos = input.Position
            objPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            obj.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

makeDraggable(main)
makeDraggable(floatBtn)

-- ====== Rainbow Animation ======
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.015) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        title.TextColor3 = color
        mainStroke.Color = Color3.fromHSV(hue, 0.5, 0.8)
        fbStroke.Color = Color3.fromHSV((hue + 0.3) % 1, 0.8, 1)
        headerLine.BackgroundColor3 = color
        avatar.BackgroundColor3 = color
        fbInner.BackgroundColor3 = Color3.fromHSV((hue + 0.3) % 1, 0.8, 1)
        task.wait(0.05)
    end
end)

-- ====== Entrance Animation ======
main.Size = UDim2.new(0, 0, 0, 0)
blur.Visible = true
tween(main, {Size = UDim2.new(0, 400, 0, 420)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("⚔️ Blade Ball Premium GUI Loaded")
'''

with open('/mnt/agents/output/BladeBall_Premium_GUI.lua', 'w', encoding='utf-8') as f:
    f.write(blade_ball_gui)

print("✅ File saved!")
print(f"📦 Size: {len(blade_ball_gui):,} characters")
