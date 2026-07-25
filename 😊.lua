--[[
    MKRA HUB (Original GUI + Image Background)
    Features: Kill Aura, Kill Aura NPCs, Kill Mobs
    Image: https://files.catbox.moe/ka5x56.jpg
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CoreGui = game:GetService("CoreGui"),
}

local LocalPlayer = Services.Players.LocalPlayer

-- ====== រូបភាព ======
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

-- ═══════════════════════════════════════════════════════════════
-- CONFIG & THEME (ដូចកូដដើម)
-- ═══════════════════════════════════════════════════════════════
local CONFIG = {
    UI_NAME = "MkraHub_KillOnly",
    RAINBOW_SPEED = 0.3,
}

local THEME = {
    Dark = Color3.fromRGB(20, 20, 20),
    DarkMedium = Color3.fromRGB(25, 25, 25),
    Medium = Color3.fromRGB(30, 30, 30),
    Button = Color3.fromRGB(60, 60, 60),
    Active = Color3.fromRGB(0, 120, 200),
    Success = Color3.fromRGB(0, 140, 0),
    Error = Color3.fromRGB(220, 50, 50),
    Text = Color3.new(1, 1, 1),
    Transparent = 0.05,
}

-- ═══════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════
local State = {
    Settings = {
        KillAura = false,
        KillAuraRange = 30,
        KillAuraDamage = 30,
        KillAuraNPC = false,
        KillMobs = false,
    },
    Connections = {
        KillAura = nil,
        KillMobs = nil,
    },
}

-- ═══════════════════════════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════════════════════════
local function GetCharacter()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("Humanoid")) and char or nil
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local RainbowCache = {}
local function GetRainbowColor(speed, offset)
    local t = tick()
    if not RainbowCache["rainbow"] or (t - (RainbowCache["rainbow"].time or 0) > 0.1) then
        local hue = (t * (speed or 1) + (offset or 0)) % 1
        RainbowCache["rainbow"] = { color = Color3.fromHSV(hue, 1, 1), time = t }
    end
    return RainbowCache["rainbow"].color
end

-- ═══════════════════════════════════════════════════════════════
-- COMBAT (ORIGINAL MKRA HUB LOGIC)
-- ═══════════════════════════════════════════════════════════════
local Combat = {}

function Combat:GetKARemote()
    local searchNames = {"Attack", "Damage", "Hit", "Kill", "DealDamage", "Fire"}
    for _, v in ipairs(Services.ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in ipairs(searchNames) do
                if v.Name:lower():find(n:lower()) then
                    return v
                end
            end
        end
    end
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in ipairs(searchNames) do
                if v.Name:lower():find(n:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

function Combat:GetKATargets()
    local targets = {}
    -- អ្នកលេង
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(targets, { Humanoid = hum, RootPart = root, IsPlayer = true })
            end
        end
    end
    -- NPCs (បើបើក)
    if State.Settings.KillAuraNPC then
        for _, m in ipairs(Services.Workspace:GetDescendants()) do
            if m:IsA("Model") and not Services.Players:GetPlayerFromCharacter(m) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local root = m:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(targets, { Humanoid = hum, RootPart = root, IsPlayer = false })
                end
            end
        end
    end
    return targets
end

function Combat:ToggleKillAura()
    if State.Connections.KillAura then
        pcall(function() State.Connections.KillAura:Disconnect() end)
        State.Connections.KillAura = nil
    end

    if State.Settings.KillAura then
        local remote = nil
        if State.Settings.KillAuraNPC then
            remote = self:GetKARemote()
        end

        State.Connections.KillAura = Services.RunService.Heartbeat:Connect(function()
            local char = GetCharacter()
            if not char then return end
            local myRoot = GetRootPart()
            if not myRoot then return end

            local targets = self:GetKATargets()
            for _, t in pairs(targets) do
                if (myRoot.Position - t.RootPart.Position).Magnitude <= State.Settings.KillAuraRange then
                    if t.IsPlayer then
                        pcall(function() t.Humanoid:TakeDamage(State.Settings.KillAuraDamage) end)
                    else
                        if remote then
                            pcall(function()
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(t.Humanoid, State.Settings.KillAuraDamage)
                                else
                                    remote:InvokeServer(t.Humanoid, State.Settings.KillAuraDamage)
                                end
                            end)
                        else
                            pcall(function()
                                t.Humanoid.Health = math.max(0, t.Humanoid.Health - State.Settings.KillAuraDamage)
                            end)
                        end
                    end
                end
            end
        end)
    end
end

function Combat:ToggleKillMobs()
    if State.Connections.KillMobs then
        pcall(function() State.Connections.KillMobs:Disconnect() end)
        State.Connections.KillMobs = nil
    end

    if State.Settings.KillMobs then
        State.Connections.KillMobs = Services.RunService.Heartbeat:Connect(function()
            local char = GetCharacter()
            if not char then return end
            local root = GetRootPart()
            if not root then return end

            local folder = Services.Workspace:FindFirstChild("Mobs")
            if not folder then return end

            for _, mob in ipairs(folder:GetChildren()) do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChildOfClass("Humanoid")
                if mobRoot and mobHum and mobHum.Health > 0 then
                    if (root.Position - mobRoot.Position).Magnitude < 25 then
                        pcall(function()
                            if Services.ReplicatedStorage:FindFirstChild("Events") and
                               Services.ReplicatedStorage.Events:FindFirstChild("Attack") then
                                Services.ReplicatedStorage.Events.Attack:FireServer(mobHum)
                            end
                        end)
                    end
                end
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UI (Original MKRA HUB + Image Background)
-- ═══════════════════════════════════════════════════════════════
local UI = {}

function UI:CreateMainWindow(imageAsset)
    local oldUI = Services.CoreGui:FindFirstChild(CONFIG.UI_NAME)
    if oldUI then oldUI:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = CONFIG.UI_NAME
    screenGui.Parent = Services.CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 320, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
    mainFrame.BackgroundColor3 = THEME.Dark
    mainFrame.BackgroundTransparency = THEME.Transparent
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    -- ✨ រូបភាពផ្ទៃខាងក្រោយ
    local bgImage = Instance.new("ImageLabel", mainFrame)
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = imageAsset or ""
    bgImage.ScaleType = Enum.ScaleType.Stretch
    bgImage.ImageTransparency = 0.3
    bgImage.ZIndex = -1
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)

    -- Top Rainbow Bar
    self:CreateRainbowBar(mainFrame, UDim2.new(0, 0, 0, 0), 4)

    -- Title Bar
    self:CreateTitleBar(mainFrame)

    -- Combat Tab Content
    self:CreateSingleCombatTab(mainFrame)

    -- Bottom Rainbow Bar
    self:CreateRainbowBar(mainFrame, UDim2.new(0, 0, 1, -4), 4)

    return screenGui
end

function UI:CreateRainbowBar(parent, position, height)
    local bar = Instance.new("Frame")
    bar.Name = "RainbowBar"
    bar.Size = UDim2.new(1, 0, 0, height)
    bar.Position = position
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.Parent = parent
    for i = 0, 59 do
        local segment = Instance.new("Frame")
        segment.Size = UDim2.new(1/60, 0, 1, 0)
        segment.Position = UDim2.new(i/60, 0, 0, 0)
        segment.BackgroundColor3 = GetRainbowColor(CONFIG.RAINBOW_SPEED, i/60)
        segment.BorderSizePixel = 0
        segment.Parent = bar
    end
end

function UI:CreateTitleBar(parent)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 4)
    titleBar.BackgroundColor3 = THEME.Medium
    titleBar.BorderSizePixel = 0
    titleBar.Parent = parent
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚔️ bs"
    titleLabel.TextColor3 = THEME.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = THEME.Error
    closeBtn.Text = "×"
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = THEME.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        parent.Visible = false
    end)
end

function UI:CreateSingleCombatTab(parent)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -50)
    contentFrame.Position = UDim2.new(0, 5, 0, 46)
    contentFrame.BackgroundColor3 = THEME.DarkMedium
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = parent
    Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
    scrollFrame.Parent = contentFrame

    -- Helper: Toggle
    local function addToggle(text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * 35)
        frame.BackgroundTransparency = 1
        frame.Parent = scrollFrame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundColor3 = default and THEME.Success or THEME.Button
        btn.Text = text .. ": " .. (default and "ON" or "OFF")
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            btn.BackgroundColor3 = state and THEME.Success or THEME.Button
            callback(state)
        end)
    end

    -- Helper: TextBox
    local function addTextBox(label, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * 35)
        frame.BackgroundTransparency = 1
        frame.Parent = scrollFrame

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 100, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = THEME.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -105, 1, 0)
        box.Position = UDim2.new(0, 105, 0, 0)
        box.BackgroundColor3 = THEME.Button
        box.TextColor3 = THEME.Text
        box.Text = default
        box.Font = Enum.Font.Gotham
        box.TextSize = 11
        box.BorderSizePixel = 0
        box.Parent = frame
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
    end

    -- មុខងារទាំងអស់
    addToggle("Kill Aura", State.Settings.KillAura, function(v)
        State.Settings.KillAura = v
        Combat:ToggleKillAura()
    end)

    addTextBox("KA Range", tostring(State.Settings.KillAuraRange), function(v)
        State.Settings.KillAuraRange = tonumber(v) or 30
    end)

    addTextBox("KA Damage", tostring(State.Settings.KillAuraDamage), function(v)
        State.Settings.KillAuraDamage = tonumber(v) or 30
    end)

    addToggle("KA NPCs", State.Settings.KillAuraNPC, function(v)
        State.Settings.KillAuraNPC = v
        if State.Settings.KillAura then
            Combat:ToggleKillAura()
            Combat:ToggleKillAura()
        end
    end)

    addToggle("Kill Mobs", State.Settings.KillMobs, function(v)
        State.Settings.KillMobs = v
        Combat:ToggleKillMobs()
    end)

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 35 + 10)
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════
local function loadImageAndStart()
    local ok, response = pcall(function() return request({Url=IMAGE_URL, Method="GET"}) end)
    local asset = ""
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        asset = getcustomasset(FILE_NAME)
    end
    UI:CreateMainWindow(asset)
end

loadImageAndStart()

-- ចាប់ផ្ដើមឡើងវិញពេលស្លាប់
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.Settings.KillAura then
        Combat:ToggleKillAura()
        Combat:ToggleKillAura()
    end
    if State.Settings.KillMobs then
        Combat:ToggleKillMobs()
        Combat:ToggleKillMobs()
    end
end)