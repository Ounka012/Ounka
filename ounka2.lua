-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==================== SETTINGS ====================
local Settings = {
    KillAura = false,
    KillAuraRemote = "AttackRemote",
    KillAuraRange = 15,
    KillAuraDamage = 25,
    KillAuraNPC = false,
    KillAuraRemoteArgs = "target,damage",

    KillMobs = false,

    KillBosses = false,
    BossRemote = "BossAttack",
    BossRemoteArgs = "target,damage",
    BossDamage = 50,
    BossRange = 100,
    BossWhitelist = {}
}

-- ==================== UTILITY ====================
-- អនុគមន៍ split សាមញ្ញ (មិនប្រើ pattern)
local function split(s, delimiter)
    local result = {}
    if s == "" then return result end
    local from = 1
    local delim_from, delim_to = string.find(s, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(s, from, delim_from-1))
        from = delim_to + 1
        delim_from, delim_to = string.find(s, delimiter, from)
    end
    table.insert(result, string.sub(s, from))
    return result
end

-- ==================== KILL AURA ====================
local kaConn

local function getRemote()
    if Settings.KillAuraRemote == "" then return nil end
    local r = ReplicatedStorage:FindFirstChild(Settings.KillAuraRemote)
    if not r then r = LocalPlayer:FindFirstChild(Settings.KillAuraRemote) end
    if not r then
        for _, v in Workspace:GetDescendants() do
            if v.Name == Settings.KillAuraRemote and v:IsA("RemoteEvent") then return v end
        end
    end
    return r
end

local function getTargets()
    local t = {}
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(t, {Humanoid = hum, RootPart = root, IsPlayer = true})
            end
        end
    end
    if Settings.KillAuraNPC then
        for _, m in Workspace:GetDescendants() do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local root = m:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(t, {Humanoid = hum, RootPart = root, IsPlayer = false})
                end
            end
        end
    end
    return t
end

local function toggleKillAura()
    if kaConn then kaConn:Disconnect() end
    if Settings.KillAura then
        kaConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local targets = getTargets()
            local remote = getRemote()
            for _, target in pairs(targets) do
                local dist = (myRoot.Position - target.RootPart.Position).Magnitude
                if dist <= Settings.KillAuraRange then
                    if target.IsPlayer then
                        target.Humanoid:TakeDamage(Settings.KillAuraDamage)
                    else
                        if remote then
                            local args = {}
                            local argStr = Settings.KillAuraRemoteArgs:gsub("%s+", "")
                            for _, a in pairs(split(argStr, ",")) do
                                if a == "target" then table.insert(args, target.RootPart)
                                elseif a == "damage" then table.insert(args, Settings.KillAuraDamage)
                                elseif a == "humanoid" then table.insert(args, target.Humanoid) end
                            end
                            if #args == 0 then args = {target.RootPart, Settings.KillAuraDamage} end
                            pcall(function() remote:FireServer(unpack(args)) end)
                        else
                            target.Humanoid.Health = math.max(0, target.Humanoid.Health - Settings.KillAuraDamage)
                        end
                    end
                end
            end
        end)
    end
end

-- ==================== KILL MOBS ====================
local kmConn

local function toggleKillMobs()
    if kmConn then kmConn:Disconnect() end
    if Settings.KillMobs then
        kmConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local folder = Workspace:FindFirstChild("Mobs")
            if not folder then return end
            for _, mob in folder:GetChildren() do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChildOfClass("Humanoid")
                if mobRoot and mobHum and mobHum.Health > 0 then
                    if (root.Position - mobRoot.Position).Magnitude < 25 then
                        pcall(function()
                            ReplicatedStorage.Events.Attack:FireServer(mobHum)
                        end)
                    end
                end
            end
        end)
    end
end

-- ==================== KILL BOSSES ====================
local kbConn

local function getBossRemote()
    if Settings.BossRemote == "" then return nil end
    local r = ReplicatedStorage:FindFirstChild(Settings.BossRemote)
    if not r then r = LocalPlayer:FindFirstChild(Settings.BossRemote) end
    if not r then
        for _, v in Workspace:GetDescendants() do
            if v.Name == Settings.BossRemote and v:IsA("RemoteEvent") then return v end
        end
    end
    return r
end

local function isBoss(model)
    if not model:IsA("Model") then return false end
    if model:GetAttribute("IsBoss") == true then return true end
    local lower = model.Name:lower()
    if #Settings.BossWhitelist > 0 then
        for _, name in ipairs(Settings.BossWhitelist) do
            if lower == name:lower() then return true end
        end
        return false
    end
    return lower:find("boss") ~= nil
end

local function getBossTargets()
    local t = {}
    for _, model in Workspace:GetDescendants() do
        if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
            if isBoss(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(t, {Humanoid = hum, RootPart = root, Model = model})
                end
            end
        end
    end
    return t
end

local function toggleKillBosses()
    if kbConn then kbConn:Disconnect() end
    if Settings.KillBosses then
        kbConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local bosses = getBossTargets()
            local remote = getBossRemote()
            for _, boss in pairs(bosses) do
                local dist = (myRoot.Position - boss.RootPart.Position).Magnitude
                if dist <= Settings.BossRange then
                    if remote then
                        local args = {}
                        local argStr = Settings.BossRemoteArgs:gsub("%s+", "")
                        for _, a in pairs(split(argStr, ",")) do
                            if a == "target" then table.insert(args, boss.RootPart)
                            elseif a == "damage" then table.insert(args, Settings.BossDamage)
                            elseif a == "humanoid" then table.insert(args, boss.Humanoid) end
                        end
                        if #args == 0 then args = {boss.RootPart, Settings.BossDamage} end
                        pcall(function() remote:FireServer(unpack(args)) end)
                    else
                        boss.Humanoid.Health = math.max(0, boss.Humanoid.Health - Settings.BossDamage)
                    end
                end
            end
        end)
    end
end

-- ==================== GUI BUTTON ====================
local function createToggleButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MyScriptUI"
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 10)
    btn.Text = "Kill Bosses: OFF"
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = gui

    local dragging = false
    local dragStart = nil
    local startPos = nil

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local kbEnabled = Settings.KillBosses
    btn.MouseButton1Click:Connect(function()
        if dragging then return end
        kbEnabled = not kbEnabled
        Settings.KillBosses = kbEnabled
        toggleKillBosses()
        if kbEnabled then
            btn.Text = "Kill Bosses: ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.Text = "Kill Bosses: OFF"
            btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

-- ==================== INITIALIZATION ====================
createToggleButton()
toggleKillAura()
toggleKillMobs()
toggleKillBosses()

print("✅ ស្គ្រីបដំណើរការ! ចុចប៊ូតុងដើម្បីបើក Kill Bosses")
