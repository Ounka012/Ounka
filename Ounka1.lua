-- =====================================================================
-- EVADE SCRIPT 2026 - VIP LEVEL ULTIMATE (MOBILE OPTIMIZED) - FIXED
-- =====================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ==================== ⚙️ CONFIGURATION ====================
local Config = {
    Speed = 80,
    JumpPower = 70,
    Gravity = 0.5,
    BackgroundImage = "https://files.catbox.moe/ka5x56.jpg", -- រូបផ្ទៃខាងក្រោយ
}

-- ==================== TOGGLES STATE ====================
local Toggles = {
    KillAll = false,
    AutoTrap = false,
    SilentWalk = false,
    VIPESP = false,
    AutoFarm = false,
    NextbotAvoid = false,
    Speed = false,
    Jump = false,
    Gravity = false,
    AutoRevive = false,
    AutoVote = false,
}

-- ==================== 🎨 UI WINDOW (PLAYERGUI) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EvadeVIP_Lotus_Mobile"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0.6, 0, 0.85, 0) 
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(220, 150, 200)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- ==================== BACKGROUND (LOTUS) ====================
local BgContainer = Instance.new("Frame")
BgContainer.Size = UDim2.new(1, 0, 1, 0)
BgContainer.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
BgContainer.BorderSizePixel = 0
BgContainer.ZIndex = -2
BgContainer.Parent = mainFrame

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Image = Config.BackgroundImage
BackgroundImage.BackgroundTransparency = 0.3
BackgroundImage.ImageTransparency = 0.4
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = -1
BackgroundImage.Parent = BgContainer

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Overlay.BackgroundTransparency = 0.5
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 0
Overlay.Parent = BgContainer

-- ==================== TITLE BAR ====================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 18, 25)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 1
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🪷 VIP EVADE ULTIMATE"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 2
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 140)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 2
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ==================== MOBILE TOGGLE BUTTON ====================
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 80, 0, 40)
openBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(220, 150, 200)
openBtn.Text = "🪷 Open VIP"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.BorderSizePixel = 0
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openBtn

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Visible = true
end)

-- ==================== CONTENT FRAME (SCROLLABLE) ====================
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -55)
contentFrame.Position = UDim2.new(0, 0, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ZIndex = 1
contentFrame.Parent = mainFrame

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.ScrollBarThickness = 5
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(220, 150, 200)
contentScroll.ZIndex = 1
contentScroll.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentScroll

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = contentScroll

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end)

-- ==================== UI BUILDERS (TOUCH-FRIENDLY) ====================
local function CreateSection(parent, title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 28)
    section.BackgroundTransparency = 1
    section.Text = "━━━ " .. title .. " ━━━"
    section.TextColor3 = Color3.fromRGB(220, 150, 200)
    section.Font = Enum.Font.GothamBold
    section.TextSize = 13
    section.ZIndex = 1
    section.Parent = parent
end

local function CreateToggle(parent, label, desc, flag)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 75)
    frame.BackgroundColor3 = Color3.fromRGB(35, 22, 30)
    frame.BorderSizePixel = 0
    frame.ZIndex = 1
    frame.Parent = parent

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(120, 80, 110)
    frameStroke.Thickness = 1.5
    frameStroke.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -70, 0.4, 0)
    text.Position = UDim2.new(0, 14, 0, 4)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(250, 250, 255)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.ZIndex = 1
    text.Parent = frame

    local desc_text = Instance.new("TextLabel")
    desc_text.Size = UDim2.new(1, -70, 0.4, 0)
    desc_text.Position = UDim2.new(0, 14, 0.45, 0)
    desc_text.BackgroundTransparency = 1
    desc_text.Text = desc
    desc_text.TextColor3 = Color3.fromRGB(200, 180, 195)
    desc_text.TextXAlignment = Enum.TextXAlignment.Left
    desc_text.Font = Enum.Font.Gotham
    desc_text.TextSize = 11
    desc_text.ZIndex = 1
    desc_text.Parent = frame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 48, 0, 26)
    switch.Position = UDim2.new(1, -60, 0.5, -13)
    switch.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(220, 150, 200) or Color3.fromRGB(90, 90, 110)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1
    switch.Parent = frame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = Toggles[flag] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 2
    clickBtn.Parent = frame

    clickBtn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]
        switch.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(220, 150, 200) or Color3.fromRGB(90, 90, 110)
        knob.Position = Toggles[flag] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(120, 60, 100)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.ZIndex = 1
    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(180, 100, 140)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==================== BUILD UI ====================
CreateSection(contentScroll, "🪷 VIP CORE (ULTIMATE)")
CreateToggle(contentScroll, "🔥 Kill All Nextbots", "សម្លាប់ Nextbot ទាំងអស់ (Instant Win)", "KillAll")
CreateToggle(contentScroll, "🪤 Auto Trap Place", "ដាក់អន្ទាក់ដោយស្វ័យប្រវត្តិ (VIP Farm)", "AutoTrap")
CreateToggle(contentScroll, "👻 Silent Walk", "ដើរស្ងាត់ៗ ល្បឿនលឿន (120)", "SilentWalk")
CreateToggle(contentScroll, "👁️ VIP ESP", "បង្ហាញឈ្មោះ និងចម្ងាយ", "VIPESP")

CreateSection(contentScroll, "🏃 MOVEMENT ENHANCEMENTS")
CreateToggle(contentScroll, "💨 Speed Hack", "បង្កើនល្បឿនដល់ 80", "Speed")
CreateToggle(contentScroll, "🦘 Jump Boost", "បង្កើនកម្លាំងលោត", "Jump")
CreateToggle(contentScroll, "🌌 Low Gravity", "ថយចុះទំនាញ លោតកាន់តែខ្ពស់", "Gravity")

CreateSection(contentScroll, "⚡ SUPPORT TOOLS")
CreateToggle(contentScroll, "💰 Auto Farm", "ស្វ័យប្រមូលកាក់ / ស្ករ", "AutoFarm")
CreateToggle(contentScroll, "🏃 Nextbot Avoid", "គេចចេញពី Bot ដោយស្វ័យប្រវត្តិ", "NextbotAvoid")
CreateToggle(contentScroll, "💖 Auto Revive", "រស់ឡើងវិញដោយស្វ័យប្រវត្តិ", "AutoRevive")
CreateToggle(contentScroll, "🗳️ Auto Vote", "បោះឆ្នោតដោយស្វ័យប្រវត្តិ", "AutoVote")

CreateSection(contentScroll, "⚙️ UTILITIES")
CreateButton(contentScroll, "❌ Disable All", function()
    for flag, _ in pairs(Toggles) do
        Toggles[flag] = false
    end
end)

-- ==================== VIP FEATURES LOGIC ====================

-- 1. KILL ALL NEXTBOTS
task.spawn(function()
    while true do
        task.wait(0.3)
        if Toggles.KillAll then
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Nextbot" and v:IsA("Model") then
                        if v:FindFirstChild("HumanoidRootPart") then
                            v.HumanoidRootPart.CanCollide = false
                            v:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. AUTO TRAP PLACE
task.spawn(function()
    while true do
        task.wait(0.8)
        if Toggles.AutoTrap then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local nearestBot, minDist = nil, math.huge
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Nextbot" and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                        local d = (v.HumanoidRootPart.Position - root.Position).Magnitude
                        if d < minDist and d < 50 then
                            minDist = d
                            nearestBot = v
                        end
                    end
                end
                if nearestBot then
                    local trap = Instance.new("Part")
                    trap.Name = "VIPTrap"
                    trap.Shape = Enum.PartType.Ball
                    trap.Size = Vector3.new(7, 7, 7)
                    trap.Position = nearestBot.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
                    trap.Anchored = true
                    trap.CanCollide = true
                    trap.BrickColor = BrickColor.new("Magenta")
                    trap.Material = Enum.Material.Neon
                    trap.Parent = Workspace
                    task.wait(0.25)
                    trap:Destroy()
                end
            end)
        end
    end
end)

-- 3 & 5. COMBINED MOVEMENT (កែបញ្ហាប៉ះទង្គិចល្បឿន)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            -- អាទិភាពល្បឿន៖ Silent Walk (120) > Speed (80) > ធម្មតា (16)
            if Toggles.SilentWalk then
                hum.WalkSpeed = 120
            elseif Toggles.Speed then
                hum.WalkSpeed = Config.Speed
            else
                hum.WalkSpeed = 16
            end
            
            -- Jump & Gravity
            if Toggles.Jump then
                hum.JumpPower = Config.JumpPower
            elseif Toggles.Gravity then
                hum.JumpPower = Config.JumpPower * (Config.Gravity * 2)
            else
                hum.JumpPower = 50
            end
        end
    end)
end)

-- 4. VIP ESP (Names + Distance) using TextLabels
local vipESPLabels = {}
task.spawn(function()
    while true do
        task.wait(0.15)
        if Toggles.VIPESP then
            pcall(function()
                local camera = Workspace.CurrentCamera
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local char = plr.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local root = char.HumanoidRootPart
                            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                if not vipESPLabels[plr] then
                                    vipESPLabels[plr] = Instance.new("TextLabel")
                                    vipESPLabels[plr].BackgroundTransparency = 0.2
                                    vipESPLabels[plr].BackgroundColor3 = Color3.fromRGB(30, 20, 25)
                                    vipESPLabels[plr].TextScaled = true
                                    vipESPLabels[plr].ZIndex = 10
                                    vipESPLabels[plr].Parent = screenGui
                                    
                                    local corner = Instance.new("UICorner")
                                    corner.CornerRadius = UDim.new(0, 8)
                                    corner.Parent = vipESPLabels[plr]
                                    
                                    local stroke = Instance.new("UIStroke")
                                    stroke.Color = Color3.fromRGB(220, 150, 200)
                                    stroke.Thickness = 1.5
                                    stroke.Parent = vipESPLabels[plr]
                                end
                                
                                local label = vipESPLabels[plr]
                                local dist = math.floor((root.Position - camera.CFrame.Position).Magnitude)
                                label.Text = plr.Name .. " | " .. dist .. "m"
                                label.Size = UDim2.new(0, 140, 0, 28)
                                label.Position = UDim2.new(0, screenPos.X - 70, 0, screenPos.Y - 65)
                                label.TextColor3 = plr.TeamColor == LocalPlayer.TeamColor and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 14
                                label.Visible = true
                            end
                        end
                    end
                end
                for plr, label in pairs(vipESPLabels) do
                    if not plr.Parent then
                        label:Destroy()
                        vipESPLabels[plr] = nil
                    end
                end
            end)
        else
            for _, label in pairs(vipESPLabels) do
                pcall(function() label:Destroy() end)
            end
            vipESPLabels = {}
        end
    end
end)

-- 6. AUTO FARM
task.spawn(function()
    while true do
        task.wait(0.2)
        if Toggles.AutoFarm then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local nearest, minDist = nil, math.huge
                for _, v in pairs(Workspace:GetDescendants()) do
                    if (v.Name == "Coin" or v.Name == "Candy" or v.Name == "CoinPart") and v:IsA("BasePart") then
                        local d = (v.Position - root.Position).Magnitude
                        if d < minDist and d < 100 then
                            minDist = d
                            nearest = v
                        end
                    end
                end
                if nearest and minDist > 5 then
                    root.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
                end
            end)
        end
    end
end)

-- 7. NEXTBOT AVOID
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.NextbotAvoid then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Nextbot" and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                        local d = (v.HumanoidRootPart.Position - root.Position).Magnitude
                        if d < 35 then
                            local dir = (root.Position - v.HumanoidRootPart.Position).Unit
                            root.Velocity = Vector3.new(dir.X * 90, hum.JumpPower + 30, dir.Z * 90)
                        end
                    end
                end
            end)
        end
    end
end)

-- 8. AUTO REVIVE
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.AutoRevive then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then
                    local gui = LocalPlayer:FindFirstChild("PlayerGui")
                    local found = false
                    if gui then
                        for _, g in pairs(gui:GetChildren()) do
                            for _, b in pairs(g:GetDescendants()) do
                                if b:IsA("TextButton") and string.find(b.Text:lower(), "revive") then
                                    b:Fire()
                                    found = true
                                    break
                                end
                            end
                            if found then break end
                        end
                    end
                    if not found then
                        LocalPlayer:LoadCharacter()
                    end
                end
            end)
        end
    end
end)

-- 9. AUTO VOTE
task.spawn(function()
    while true do
        task.wait(2)
        if Toggles.AutoVote then
            pcall(function()
                local gui = LocalPlayer:FindFirstChild("PlayerGui")
                if gui then
                    for _, g in pairs(gui:GetChildren()) do
                        for _, b in pairs(g:GetDescendants()) do
                            if b:IsA("TextButton") and (b.Text == "Vote" or b.Text == "Yes" or b.Text == "No") then
                                b:Fire()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== NOTIFICATION ====================
local notify = Instance.new("TextLabel")
notify.Size = UDim2.new(0, 400, 0, 110)
notify.Position = UDim2.new(0.5, -200, 0, 30)
notify.BackgroundColor3 = Color3.fromRGB(30, 18, 25)
notify.Text = "🪷 VIP EVADE SCRIPT LOADED\n✅ Mobile Optimized!\n✅ Touch Controls Ready!\n🔥 All VIP Features Ready!"
notify.TextColor3 = Color3.fromRGB(220, 150, 200)
notify.Font = Enum.Font.GothamBold
notify.TextSize = 13
notify.TextWrapped = true
notify.BorderSizePixel = 0
notify.ZIndex = 100
notify.Parent = screenGui

local notifyCorner = Instance.new("UICorner")
notifyCorner.CornerRadius = UDim.new(0, 14)
notifyCorner.Parent = notify

local notifyStroke = Instance.new("UIStroke")
notifyStroke.Color = Color3.fromRGB(220, 150, 200)
notifyStroke.Thickness = 2.5
notifyStroke.Parent = notify

task.wait(5)
notify:Destroy()

print("✅ VIP Evade Script (Mobile) Loaded! Tap Open VIP to show UI.")
