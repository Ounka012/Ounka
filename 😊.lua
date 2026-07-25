--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║         MKRA HUB - COMPLETE REFACTORED VERSION              ║
    ║  Optimized | Full-Featured | Production-Ready              ║
    ║  Features: Fly, Combat, Farming, Utilities, VIP Features   ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES INITIALIZATION
-- ═══════════════════════════════════════════════════════════════
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    TeleportService = game:GetService("TeleportService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    HttpService = game:GetService("HttpService"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION & CONSTANTS
-- ═══════════════════════════════════════════════════════════════
local CONFIG = {
    UI_NAME = "MkraHub_" .. tostring(LocalPlayer.UserId),
    RAINBOW_SPEED = 0.3,
    ANIMATION_TICK = 0.05,
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
        -- Movement
        Fly = false,
        FlySpeed = 120,
        BoostMode = false,
        FullMapFly = false,
        FullMapFlySpeed = 200,
        FullMapFlyNoclip = false,
        Noclip = false,
        InfiniteJumpOrig = false,
        InfiniteJump99 = false,
        SpeedBoostMultiplier = 1,
        WalkSpeedDirect = 16,
        
        -- Combat
        KillAura = false,
        KillAuraRange = 30,
        KillAuraDamage = 30,
        KillAuraNPC = false,
        KillAuraRemote = "",
        KillAuraRemoteArgs = "target,damage",
        KillMobs = false,
        HitboxSize = 2,
        AutoClick = false,
        ForceField = false,
        
        -- Farming
        AutoChop = false,
        
        -- Visual
        ESP = false,
        
        -- Special
        GodMode = false,
        InstantRespawn = false,
        FlingAll = false,
    },
    Connections = {
        Fly = nil,
        FullMapFly = nil,
        KillAura = nil,
        KillMobs = nil,
        AutoChop = nil,
        Noclip = nil,
        AutoClick = nil,
        InfiniteJump99 = nil,
        ESP = {},
        God = {},
        Respawn = {},
    },
    Physics = {
        BodyVelocity = nil,
        BodyGyro = nil,
        FullMapBodyVelocity = nil,
        FullMapBodyGyro = nil,
    },
    UI = {
        MainWindow = nil,
        TabContainers = {},
        RestoreButton = nil,
    }
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

--- Notification System
local function Notify(title, text, duration)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or CONFIG.DEFAULT_TIMEOUT
        })
    end)
end

--- Rainbow Color Generator
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

--- Get Player by Name
local function FindPlayer(name)
    name = (name or ""):gsub("%s+", ""):lower()
    if name == "" then return nil end
    
    for _, plr in pairs(Services.Players:GetPlayers()) do
        if plr.Name:lower():match("^" .. name) then return plr end
    end
    return nil
end

--- Get NPC by Name
local function FindNPC(name)
    name = (name or ""):gsub("%s+", ""):lower()
    for _, descendant in pairs(Services.Workspace:GetDescendants()) do
        if descendant:IsA("Model") and not Services.Players:GetPlayerFromCharacter(descendant) then
            local hum = descendant:FindFirstChildOfClass("Humanoid")
            local root = descendant:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if name == "" or descendant.Name:lower():match("^" .. name) then
                    return descendant
                end
            end
        end
    end
    return nil
end

--- Get Valid Character
local function GetCharacter()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("Humanoid")) and char or nil
end

--- Get Humanoid Root Part
local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

--- Disconnect All Connections
local function DisconnectAll(connTable)
    if type(connTable) == "table" then
        for _, conn in pairs(connTable) do
            if conn and typeof(conn) == "RBXScriptConnection" then
                pcall(function() conn:Disconnect() end)
            end
        end
    end
    return {}
end

--- Destroy Part
local function DestroyPart(part)
    if part then
        pcall(function() part:Destroy() end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MOVEMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════
local Movement = {}

function Movement:StartFly()
    local char = GetCharacter()
    if not char then return end
    
    local root = GetRootPart()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    
    -- Cleanup
    self:StopFly()
    
    -- Create physics bodies
    State.Physics.BodyVelocity = Instance.new("BodyVelocity")
    State.Physics.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    State.Physics.BodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
    State.Physics.BodyVelocity.Parent = root
    
    State.Physics.BodyGyro = Instance.new("BodyGyro")
    State.Physics.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    State.Physics.BodyGyro.CFrame = root.CFrame
    State.Physics.BodyGyro.Parent = root
    
    humanoid.PlatformStand = true
    
    -- Connection
    State.Connections.Fly = Services.RunService.RenderStepped:Connect(function()
        local currentChar = GetCharacter()
        if not currentChar then
            self:StopFly()
            return
        end
        
        local hum = currentChar:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        local moveDir = hum.MoveDirection
        local speed = State.Settings.FlySpeed
        
        if State.Settings.BoostMode then
            speed = speed * 2.5
        end
        
        if State.Physics.BodyVelocity then
            State.Physics.BodyVelocity.Velocity = moveDir.Magnitude > 0 and (moveDir * speed) or Vector3.zero
        end
        
        if State.Physics.BodyGyro then
            State.Physics.BodyGyro.CFrame = Camera.CFrame
        end
    end)
end

function Movement:StopFly()
    if State.Connections.Fly then
        pcall(function() State.Connections.Fly:Disconnect() end)
        State.Connections.Fly = nil
    end
    
    DestroyPart(State.Physics.BodyVelocity)
    DestroyPart(State.Physics.BodyGyro)
    State.Physics.BodyVelocity = nil
    State.Physics.BodyGyro = nil
    
    local char = GetCharacter()
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

function Movement:StartFullMapFly()
    local char = GetCharacter()
    if not char then return end
    
    local root = GetRootPart()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    
    self:StopFullMapFly()
    
    -- Physics bodies
    State.Physics.FullMapBodyVelocity = Instance.new("BodyVelocity")
    State.Physics.FullMapBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    State.Physics.FullMapBodyVelocity.Velocity = Vector3.zero
    State.Physics.FullMapBodyVelocity.Parent = root
    
    State.Physics.FullMapBodyGyro = Instance.new("BodyGyro")
    State.Physics.FullMapBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    State.Physics.FullMapBodyGyro.CFrame = root.CFrame
    State.Physics.FullMapBodyGyro.Parent = root
    
    humanoid.PlatformStand = true
    
    -- Noclip
    if State.Settings.FullMapFlyNoclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- Connection
    State.Connections.FullMapFly = Services.RunService.RenderStepped:Connect(function()
        if not GetCharacter() or not State.Settings.FullMapFly then
            self:StopFullMapFly()
            return
        end
        
        local dir = Vector3.zero
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + Camera.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - Camera.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - Camera.CFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + Camera.CFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end
        
        if State.Physics.FullMapBodyVelocity then
            State.Physics.FullMapBodyVelocity.Velocity = dir.Magnitude > 0 and (dir.Unit * State.Settings.FullMapFlySpeed) or Vector3.zero
        end
        
        if State.Physics.FullMapBodyGyro then
            State.Physics.FullMapBodyGyro.CFrame = Camera.CFrame
        end
    end)
end

function Movement:StopFullMapFly()
    if State.Connections.FullMapFly then
        pcall(function() State.Connections.FullMapFly:Disconnect() end)
        State.Connections.FullMapFly = nil
    end
    
    DestroyPart(State.Physics.FullMapBodyVelocity)
    DestroyPart(State.Physics.FullMapBodyGyro)
    State.Physics.FullMapBodyVelocity = nil
    State.Physics.FullMapBodyGyro = nil
    
    local char = GetCharacter()
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        
        if State.Settings.FullMapFlyNoclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

function Movement:UpdateWalkSpeed()
    local char = GetCharacter()
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local speed = math.max(
        State.Settings.SpeedBoostMultiplier * 16,
        State.Settings.WalkSpeedDirect,
        16
    )
    
    pcall(function() hum.WalkSpeed = speed end)
end

function Movement:ToggleNoclip()
    if State.Connections.Noclip then
        pcall(function() State.Connections.Noclip:Disconnect() end)
        State.Connections.Noclip = nil
    end
    
    if State.Settings.Noclip then
        State.Connections.Noclip = Services.RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end

function Movement:SetInfiniteJump(enabled)
    if State.Connections.InfiniteJump99 then
        pcall(function() State.Connections.InfiniteJump99:Disconnect() end)
        State.Connections.InfiniteJump99 = nil
    end
    
    if enabled then
        State.Connections.InfiniteJump99 = Services.UserInputService.JumpRequest:Connect(function()
            local char = GetCharacter()
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
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
                table.insert(targets, {
                    Humanoid = hum,
                    RootPart = root,
                    IsPlayer = true
                })
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
                    table.insert(targets, {
                        Humanoid = hum,
                        RootPart = root,
                        IsPlayer = false
                    })
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
            local char = GetCharacter()
            if not char then return end
            
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
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(unpack(args))
                                else
                                    remote:InvokeServer(unpack(args))
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

function Combat:ToggleAutoChop()
    if State.Connections.AutoChop then
        pcall(function() State.Connections.AutoChop:Disconnect() end)
        State.Connections.AutoChop = nil
    end
    
    if State.Settings.AutoChop then
        State.Connections.AutoChop = Services.RunService.Heartbeat:Connect(function()
            local char = GetCharacter()
            if not char then return end
            
            local root = GetRootPart()
            if not root then return end
            
            local folder = Services.Workspace:FindFirstChild("Trees")
            if not folder then return end
            
            for _, tree in ipairs(folder:GetChildren()) do
                local main = tree:FindFirstChild("Main")
                if main and (root.Position - main.Position).Magnitude < 20 then
                    pcall(function()
                        if Services.ReplicatedStorage:FindFirstChild("Events") and
                           Services.ReplicatedStorage.Events:FindFirstChild("Chop") then
                            Services.ReplicatedStorage.Events.Chop:FireServer(tree)
                        end
                    end)
                end
            end
        end)
    end
end

function Combat:ToggleAutoClick()
    if State.Connections.AutoClick then
        pcall(function() State.Connections.AutoClick:Disconnect() end)
        State.Connections.AutoClick = nil
    end
    
    if State.Settings.AutoClick then
        local lastClick = 0
        State.Connections.AutoClick = Services.RunService.Heartbeat:Connect(function()
            if not GetCharacter() then return end
            
            local mouse = LocalPlayer:GetMouse()
            local cx, cy = mouse.X, mouse.Y
            
            if tick() - lastClick >= 0.05 then
                pcall(function()
                    Services.VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                    Services.VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                end)
                lastClick = tick()
            end
        end)
    end
end

function Combat:UpdateForceField()
    if State.Settings.ForceField and GetCharacter() then
        if not GetCharacter():FindFirstChild("ForceField") then
            pcall(function() Instance.new("ForceField", GetCharacter()) end)
        end
    elseif GetCharacter() then
        local ff = GetCharacter():FindFirstChild("ForceField")
        if ff then ff:Destroy() end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SPECIAL FEATURES
-- ═══════════════════════════════════════════════════════════════
local Special = {}

function Special:ToggleGodMode()
    State.Connections.God = DisconnectAll(State.Connections.God)
    
    if State.Settings.GodMode then
        local function connectGodChar(char)
            local hum = char:WaitForChild("Humanoid")
            local conn = hum.HealthChanged:Connect(function()
                if State.Settings.GodMode and hum.Health < hum.MaxHealth then
                    pcall(function() hum.Health = hum.MaxHealth end)
                end
            end)
            table.insert(State.Connections.God, conn)
        end
        
        local char = GetCharacter()
        if char then connectGodChar(char) end
        
        table.insert(State.Connections.God, LocalPlayer.CharacterAdded:Connect(connectGodChar))
    end
end

function Special:ToggleInstantRespawn()
    State.Connections.Respawn = DisconnectAll(State.Connections.Respawn)
    
    if State.Settings.InstantRespawn then
        local c1 = LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid")
            local c2 = hum.Died:Connect(function()
                task.wait(0.1)
                if State.Settings.InstantRespawn then
                    pcall(function() LocalPlayer:LoadCharacter() end)
                end
            end)
            table.insert(State.Connections.Respawn, c2)
        end)
        table.insert(State.Connections.Respawn, c1)
    end
end

function Special:ToggleESP()
    State.Connections.ESP = DisconnectAll(State.Connections.ESP)
    
    for _, plr in pairs(Services.Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local hl = plr.Character:FindFirstChild("MKRA_ESP")
                if hl then hl:Destroy() end
            end
        end)
    end
    
    if State.Settings.ESP then
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local function attach(ch)
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "MKRA_ESP"
                        hl.Adornee = ch
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.Parent = ch
                    end)
                end
                
                if plr.Character then attach(plr.Character) end
                local c = plr.CharacterAdded:Connect(function(ch)
                    task.wait(0.5)
                    attach(ch)
                end)
                table.insert(State.Connections.ESP, c)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- REMOTE SCANNING
-- ═══════════════════════════════════════════════════════════════
local RemoteScanner = {}

function RemoteScanner:ScanKickRemotes()
    local kickRemotes = {}
    local names = {
        "Kick", "KickPlayer", "KickUser", "RemovePlayer", "BanPlayer",
        "Admin", "AdminKick", "AdminBan", "ModKick", "KickEvent",
        "ServerKick", "PlayerKick", "KickRemote", "KickFunction",
        "Ban", "BanUser", "ServerKick", "RemovePlayerFromServer"
    }
    
    local function search(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, n in ipairs(names) do
                    if obj.Name:lower():find(n:lower()) then
                        table.insert(kickRemotes, {
                            Remote = obj,
                            Name = obj:GetFullName(),
                            Type = obj.ClassName
                        })
                        break
                    end
                end
            end
        end
    end
    
    if Services.ReplicatedStorage then search(Services.ReplicatedStorage) end
    if Services.Workspace then search(Services.Workspace) end
    if LocalPlayer then search(LocalPlayer) end
    
    return kickRemotes
end

function RemoteScanner:ScanBackdoorRemotes()
    local backdoorRemotes = {}
    local names = {
        "Admin", "Command", "Function", "Backdoor", "MainRemote", "ServerControl",
        "AdminHandler", "RemoteAdmin", "Moderation", "ServerCommand",
        "Cmd", "Exe", "Run", "Exec", "ServerExec", "Execute",
        "DoCmd", "ServerFunction", "AdminPanel", "ModPanel",
        "Owner", "OwnerCmd", "OwnerCommand", "AdminCommand"
    }
    
    local function search(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, n in ipairs(names) do
                    if obj.Name:lower():find(n:lower()) then
                        table.insert(backdoorRemotes, {
                            Remote = obj,
                            Name = obj:GetFullName(),
                            Type = obj.ClassName
                        })
                        break
                    end
                end
            end
        end
    end
    
    if Services.ReplicatedStorage then search(Services.ReplicatedStorage) end
    if Services.Workspace then search(Services.Workspace) end
    if LocalPlayer then search(LocalPlayer) end
    
    return backdoorRemotes
end

-- ═══════════════════════════════════════════════════════════════
-- UI SYSTEM
-- ═══════════════════════════════════════════════════════════════
local UI = {}

function UI:CreateMainWindow()
    -- Cleanup old UI
    local oldUI = Services.CoreGui:FindFirstChild(CONFIG.UI_NAME)
    if oldUI then oldUI:Destroy() end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = CONFIG.UI_NAME
    screenGui.Parent = Services.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 320, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
    mainFrame.BackgroundColor3 = THEME.Dark
    mainFrame.BackgroundTransparency = THEME.Transparent
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    -- Top Rainbow Bar
    self:CreateRainbowBar(mainFrame, UDim2.new(0, 0, 0, 0), 4)
    
    -- Title Bar
    self:CreateTitleBar(mainFrame)
    
    -- Tab Bar
    self:CreateTabBar(mainFrame)
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -110)
    contentFrame.Position = UDim2.new(0, 5, 0, 85)
    contentFrame.BackgroundColor3 = THEME.DarkMedium
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)
    
    -- Create ScrollingFrame for content
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
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "✨ MKRA HUB ✨"
    titleLabel.TextColor3 = THEME.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar
    
    -- Close Button
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
    
    local tabs = {"Move", "Combat", "Farm", "VIP", "Visual"}
    
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
    
    self:LoadTab("Move")
end

function UI:LoadTab(tabName)
    local scroll = State.UI.MainWindow.ScrollFrame
    scroll:ClearAllChildren()
    
    if tabName == "Move" then
        self:BuildMoveTab(scroll)
    elseif tabName == "Combat" then
        self:BuildCombatTab(scroll)
    elseif tabName == "Farm" then
        self:BuildFarmTab(scroll)
    elseif tabName == "VIP" then
        self:BuildVIPTab(scroll)
    elseif tabName == "Visual" then
        self:BuildVisualTab(scroll)
    end
    
    -- Update canvas size
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scroll:GetChildren() * 35 + 20)
end

function UI:BuildMoveTab(container)
    self:AddToggle(container, "Fly (Joystick)", State.Settings.Fly, function(v)
        State.Settings.Fly = v
        if v then Movement:StartFly() else Movement:StopFly() end
    end)
    
    self:AddToggle(container, "Fly Full Map (WASD)", State.Settings.FullMapFly, function(v)
        State.Settings.FullMapFly = v
        if v then Movement:StartFullMapFly() else Movement:StopFullMapFly() end
    end)
    
    self:AddTextBox(container, "Full Fly Speed", tostring(State.Settings.FullMapFlySpeed), function(v)
        State.Settings.FullMapFlySpeed = tonumber(v) or 200
    end)
    
    self:AddTextBox(container, "Joystick Speed", tostring(State.Settings.FlySpeed), function(v)
        State.Settings.FlySpeed = tonumber(v) or 120
    end)
    
    self:AddToggle(container, "Boost (x2.5)", State.Settings.BoostMode, function(v)
        State.Settings.BoostMode = v
    end)
    
    self:AddToggle(container, "Noclip", State.Settings.Noclip, function(v)
        State.Settings.Noclip = v
        Movement:ToggleNoclip()
    end)
    
    self:AddTextBox(container, "WS Multiplier", tostring(State.Settings.SpeedBoostMultiplier), function(v)
        State.Settings.SpeedBoostMultiplier = tonumber(v) or 1
        Movement:UpdateWalkSpeed()
    end)
    
    self:AddToggle(container, "Inf Jump (Orig)", State.Settings.InfiniteJumpOrig, function(v)
        State.Settings.InfiniteJumpOrig = v
    end)
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
    
    self:AddToggle(container, "Hitbox", State.Settings.HitboxSize > 2, function(v)
        State.Settings.HitboxSize = v and 10 or 2
    end)
    
    self:AddToggle(container, "AutoClick", State.Settings.AutoClick, function(v)
        State.Settings.AutoClick = v
        Combat:ToggleAutoClick()
    end)
    
    self:AddToggle(container, "ForceField", State.Settings.ForceField, function(v)
        State.Settings.ForceField = v
        Combat:UpdateForceField()
    end)
end

function UI:BuildFarmTab(container)
    self:AddToggle(container, "Auto Chop", State.Settings.AutoChop, function(v)
        State.Settings.AutoChop = v
        Combat:ToggleAutoChop()
    end)
    
    self:AddToggle(container, "Kill Mobs", State.Settings.KillMobs, function(v)
        State.Settings.KillMobs = v
        Combat:ToggleKillMobs()
    end)
    
    self:AddTextBox(container, "WalkSpeed (16-500)", tostring(State.Settings.WalkSpeedDirect), function(v)
        State.Settings.WalkSpeedDirect = math.clamp(tonumber(v) or 16, 16, 500)
        Movement:UpdateWalkSpeed()
    end)
    
    self:AddToggle(container, "Inf Jump (99)", State.Settings.InfiniteJump99, function(v)
        State.Settings.InfiniteJump99 = v
        Movement:SetInfiniteJump(v)
    end)
end

function UI:BuildVIPTab(container)
    self:AddToggle(container, "ESP", State.Settings.ESP, function(v)
        State.Settings.ESP = v
        Special:ToggleESP()
    end)
    
    self:AddToggle(container, "God Mode", State.Settings.GodMode, function(v)
        State.Settings.GodMode = v
        Special:ToggleGodMode()
    end)
    
    self:AddToggle(container, "Instant Respawn", State.Settings.InstantRespawn, function(v)
        State.Settings.InstantRespawn = v
        Special:ToggleInstantRespawn()
    end)
    
    self:AddButton(container, "Heal", function()
        local char = GetCharacter()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end)
    
    self:AddButton(container, "Teleport to Mouse", function()
        local mouse = LocalPlayer:GetMouse()
        local root = GetRootPart()
        if mouse and root then
            pcall(function() root.CFrame = CFrame.new(mouse.Hit.Position) end)
        end
    end)
end

function UI:BuildVisualTab(container)
    self:AddTextBox(container, "FOV (70-120)", tostring(Camera.FieldOfView), function(v)
        local fov = math.clamp(tonumber(v) or 70, 70, 120)
        pcall(function() Camera.FieldOfView = fov end)
    end)
    
    self:AddToggle(container, "FullBright", false, function(v)
        local lighting = game:GetService("Lighting")
        if v then
            lighting.Brightness = 2
            lighting.ClockTime = 12
            lighting.FogEnd = 100000
        else
            lighting.Brightness = 1
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
        end
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

function UI:AddButton(container, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, #container:GetChildren() * 35)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = THEME.Button
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
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
-- CHARACTER EVENTS
-- ═══════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    
    if State.Settings.Fly then
        Movement:StopFly()
        Movement:StartFly()
    end
    
    if State.Settings.FullMapFly then
        Movement:StopFullMapFly()
        Movement:StartFullMapFly()
    end
    
    if State.Settings.Noclip then
        Movement:ToggleNoclip()
    end
    
    Movement:UpdateWalkSpeed()
end)

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════
UI:CreateMainWindow()

Notify(
    "✨ MKRA HUB ✨",
    "Successfully loaded! All features ready.",
    5
)
