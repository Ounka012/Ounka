--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║         MKRA HUB - LITE VERSION (COMBAT & MOBS ONLY)         ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES INITIALIZATION
-- ═══════════════════════════════════════════════════════════════
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
}

local LocalPlayer = Services.Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION & CONSTANTS
-- ═══════════════════════════════════════════════════════════════
local CONFIG = {
    UI_NAME = "MkraHub_" .. tostring(LocalPlayer.UserId),
    RAINBOW_SPEED = 0.3,
    DEFAULT_TIMEOUT = 3,
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
-- STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════
local State = {
    Settings = {
        -- Combat
        KillAura = false,
        KillAuraRange = 30,
        KillAuraDamage = 30,
        KillAuraNPC = false,
        KillAuraRemote = "",
        KillAuraRemoteArgs = "target,damage",
        
        -- Farming
        KillMobs = false,
    },
    Connections = {
        KillAura = nil,
        KillMobs = nil,
    },
    UI = {
        MainWindow = nil,
    }
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function Notify(title, text, duration)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or CONFIG.DEFAULT_TIMEOUT
        })
    end)
end

local RainbowCache = {}
local function GetRainbowColor(speed, offset)
    local t = tick()
    local cacheKey = "rainbow"
    
    if not RainbowCache[cacheKey] or (t - RainbowCache[cacheKey].time > 0.1) then
        local hue = (t * (speed or 1) + (offset or 0)) % 1
        RainbowCache[cacheKey] = {
            color = Color3.fromHSV(hue, 1, 1),
            time = t
        }
    end
    return RainbowCache[cacheKey].color
end

local function GetCharacter()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("Humanoid")) and char or nil
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

-- ═══════════════════════════════════════════════════════════════
-- COMBAT SYSTEM
-- ═══════════════════════════════════════════════════════════════
local Combat = {}

function Combat:GetKARemote()
    if State.Settings.KillAuraRemote == "" then return nil end
    local remoteName = State.Settings.KillAuraRemote
    for _, v in ipairs(Services.ReplicatedStorage:GetDescendants()) do
        if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

function Combat:GetKATargets()
    local targets = {}
    
    -- Players
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(targets, {Humanoid = hum, RootPart = root, IsPlayer = true})
            end
        end
    end
    
    -- NPCs
    if State.Settings.KillAuraNPC then
        for _, m in ipairs(Services.Workspace:GetDescendants()) do
            if m:IsA("Model") and not Services.Players:GetPlayerFromCharacter(m) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local root = m:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(targets, {Humanoid = hum, RootPart = root, IsPlayer = false})
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
        State.Connections.KillAura = Services.RunService.Heartbeat:Connect(function()
            local myRoot = GetRootPart()
            if not myRoot then return end
            
            local targets = self:GetKATargets()
            local remote = self:GetKARemote()
            
            for _, t in pairs(targets) do
                if (myRoot.Position - t.RootPart.Position).Magnitude <= State.Settings.KillAuraRange then
                    if t.IsPlayer then
                        pcall(function() t.Humanoid:TakeDamage(State.Settings.KillAuraDamage) end)
                    else
                        if remote then
                            local args = {}
                            local argStr = State.Settings.KillAuraRemoteArgs:gsub("%s+", "")
                            for a in argStr:gmatch("[^,]+") do
                                a = a:match("^%s*(.-)%s*$")
                                if a == "target" then table.insert(args, t.RootPart)
                                elseif a == "damage" then table.insert(args, State.Settings.KillAuraDamage)
                                elseif a == "humanoid" then table.insert(args, t.Humanoid) end
                            end
                            if #args == 0 then args = {t.RootPart, State.Settings.KillAuraDamage} end
                            
                            pcall(function()
                                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                                else remote:InvokeServer(unpack(args)) end
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
-- UI SYSTEM
-- ═══════════════════════════════════════════════════════════════
local UI = {}

function UI:CreateMainWindow()
    local oldUI = Services.CoreGui:FindFirstChild(CONFIG.UI_NAME)
    if oldUI then oldUI:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = CONFIG.UI_NAME
    screenGui.Parent = Services.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 320, 0, 350) -- បង្រួញទំហំបន្តិច ព្រោះមានតែ ២ Tab
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
    mainFrame.BackgroundColor3 = THEME.Dark
    mainFrame.BackgroundTransparency = THEME.Transparent
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    self:CreateRainbowBar(mainFrame, UDim2.new(0, 0, 0, 0), 4)
    self:CreateTitleBar(mainFrame)
    self:CreateTabBar(mainFrame)
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -110)
    contentFrame.Position = UDim2.new(0, 5, 0, 85)
    contentFrame.BackgroundColor3 = THEME.DarkMedium
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollContent"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    scrollFrame.Parent = contentFrame
    
    State.UI.MainWindow = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ContentFrame = contentFrame,
        ScrollFrame = scrollFrame
    }
    
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
    titleLabel.Text = "✨ MKRA HUB ✨"
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

function UI:CreateTabBar(parent)
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -10, 0, 32)
    tabBar.Position = UDim2.new(0, 5, 0, 48)
    tabBar.BackgroundColor3 = THEME.Button
    tabBar.BorderSizePixel = 0
    tabBar.Parent = parent
    
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)
    
    local tabs = {"Combat", "Farm"}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabName .. "Btn"
        btn.Size = UDim2.new(1/#tabs, -2, 1, -4)
        btn.Position = UDim2.new((i-1)/#tabs, 1, 0, 2)
        btn.BackgroundColor3 = (i == 1) and THEME.Active or THEME.Button
        btn.Text = tabName
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = tabBar
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabBar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = THEME.Button
                end
            end
            btn.BackgroundColor3 = THEME.Active
            self:LoadTab(tabName)
        end)
    end
    
    self:LoadTab("Combat")
end

function UI:LoadTab(tabName)
    local scroll = State.UI.MainWindow.ScrollFrame
    scroll:ClearAllChildren()
    
    if tabName == "Combat" then
        self:BuildCombatTab(scroll)
    elseif tabName == "Farm" then
        self:BuildFarmTab(scroll)
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scroll:GetChildren() * 35 + 20)
end

function UI:BuildCombatTab(container)
    self:AddToggle(container, "Kill Aura", State.Settings.KillAura, function(v)
        State.Settings.KillAura = v
        Combat:ToggleKillAura()
    end)
    
    self:AddTextBox(container, "KA Range", tostring(State.Settings.KillAuraRange), function(v)
        State.Settings.KillAuraRange = tonumber(v) or 30
    end)
    
    self:AddTextBox(container, "KA Damage", tostring(State.Settings.KillAuraDamage), function(v)
        State.Settings.KillAuraDamage = tonumber(v) or 30
    end)
    
    self:AddToggle(container, "KA NPCs", State.Settings.KillAuraNPC, function(v)
        State.Settings.KillAuraNPC = v
    end)
end

function UI:BuildFarmTab(container)
    self:AddToggle(container, "Kill Mobs", State.Settings.KillMobs, function(v)
        State.Settings.KillMobs = v
        Combat:ToggleKillMobs()
    end)
end

function UI:AddToggle(container, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, #container:GetChildren() * 35)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
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

function UI:AddTextBox(container, label, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, #container:GetChildren() * 35)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
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

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════
UI:CreateMainWindow()

Notify("✨ MKRA HUB ✨", "Successfully loaded! Lite Version Ready.", 5)
