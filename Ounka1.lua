--[[
    MKRA Hub - Full Script (FIXED VIP Tab)
    Fly Full Map, Kick, Backdoor, Kill Aura, Fling, ESP, God, Farm...
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    Fly = false, FlySpeed = 120, BoostMode = false,
    InfiniteJumpOrig = false, InfiniteJump99 = false,
    HitboxSize = 2, AutoClick = false, ForceField = false,
    ESP = false, Noclip = false,
    SpeedBoostMultiplier = 1, WalkSpeedDirect = 16,
    GodMode = false, InstantRespawn = false,
    KillAura = false, KillAuraRange = 30, KillAuraDamage = 30,
    KillAuraNPC = false, KillAuraRemote = "", KillAuraRemoteArgs = "target,damage",
    KillMobs = false, AutoChop = false, FlingAll = false,
    FullMapFly = false, FullMapFlySpeed = 200, FullMapFlyNoclip = false,
}

-- Notification
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- Connection holders
local flyConnection, bodyVelocity, bodyGyro
local fullMapFlyConnection, fullMapBodyVelocity, fullMapBodyGyro
local godCons = {}
local respawnCons = {}
local kaConn, kmConn, acConn, noclipConn, acClickConn, infiniteJump99Conn
local espCons = {}
local autoClickLast = 0
local autoClickInterval = 0.05

-- ===== Rainbow Color =====
local function rainbowColor(speed, offset)
    local hue = (tick() * (speed or 1) + (offset or 0)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- ===== WalkSpeed =====
local function updateWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local speed = math.max(Settings.SpeedBoostMultiplier * 16, Settings.WalkSpeedDirect, 16)
        pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed end)
    end
end

-- ===== Find Player =====
local function findPlayer(name)
    name = (name or ""):gsub("%s+", ""):lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():match("^"..name) then return plr end
    end
    return nil
end

-- ===== Find NPC =====
local function findNPC(name)
    name = (name or ""):gsub("%s+", ""):lower()
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and not Players:GetPlayerFromCharacter(descendant) then
            local hum = descendant:FindFirstChildOfClass("Humanoid")
            local root = descendant:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if name == "" or descendant.Name:lower():match("^"..name) then
                    return descendant
                end
            end
        end
    end
    return nil
end

-- ===== Fly Joystick =====
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
    bodyVelocity.Parent = root
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    humanoid.PlatformStand = true
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local moveDir = hum.MoveDirection
        local speed = Settings.FlySpeed
        if Settings.BoostMode then speed = speed * 2.5 end
        if moveDir.Magnitude > 0 then bodyVelocity.Velocity = moveDir * speed else bodyVelocity.Velocity = Vector3.new(0,0,0) end
        bodyGyro.CFrame = Camera.CFrame
    end)
end
local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

-- ===== Fly Full Map (WASD) =====
local function startFullMapFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if fullMapBodyVelocity then fullMapBodyVelocity:Destroy() end
    if fullMapBodyGyro then fullMapBodyGyro:Destroy() end
    fullMapBodyVelocity = Instance.new("BodyVelocity")
    fullMapBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    fullMapBodyVelocity.Velocity = Vector3.zero
    fullMapBodyVelocity.Parent = root
    fullMapBodyGyro = Instance.new("BodyGyro")
    fullMapBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    fullMapBodyGyro.CFrame = root.CFrame
    fullMapBodyGyro.Parent = root
    humanoid.PlatformStand = true
    if Settings.FullMapFlyNoclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if fullMapFlyConnection then fullMapFlyConnection:Disconnect() end
    fullMapFlyConnection = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character or not Settings.FullMapFly then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            fullMapBodyVelocity.Velocity = dir.Unit * Settings.FullMapFlySpeed
        else
            fullMapBodyVelocity.Velocity = Vector3.zero
        end
        fullMapBodyGyro.CFrame = Camera.CFrame
    end)
end
local function stopFullMapFly()
    if fullMapFlyConnection then fullMapFlyConnection:Disconnect(); fullMapFlyConnection = nil end
    if fullMapBodyVelocity then fullMapBodyVelocity:Destroy(); fullMapBodyVelocity = nil end
    if fullMapBodyGyro then fullMapBodyGyro:Destroy(); fullMapBodyGyro = nil end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        if Settings.FullMapFlyNoclip then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end
local function flyToRandomLocation()
    if not Settings.FullMapFly then Settings.FullMapFly = true; startFullMapFly() end
    local minV, maxV = Vector3.new(-1000,50,-1000), Vector3.new(1000,500,1000)
    local pos = Vector3.new(math.random(minV.X,maxV.X), math.random(minV.Y,maxV.Y), math.random(minV.Z,maxV.Z))
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and fullMapBodyVelocity then
        fullMapBodyVelocity.Velocity = (pos - root.Position).Unit * Settings.FullMapFlySpeed * 2
    end
    task.delay(5, function()
        if Settings.FullMapFly and root then
            root.CFrame = CFrame.new(pos)
        end
    end)
end
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.FullMapFly then
        local mouse = LocalPlayer:GetMouse()
        if mouse and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position) end)
        end
    end
end)

-- ===== God Mode =====
local function connectGodChar(char)
    local hum = char:WaitForChild("Humanoid")
    local c = hum.HealthChanged:Connect(function(health)
        if Settings.GodMode and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)
    table.insert(godCons, c)
end
local function toggleGodMode()
    for _, c in pairs(godCons) do pcall(function() c:Disconnect() end) end
    godCons = {}
    if Settings.GodMode then
        if LocalPlayer.Character then connectGodChar(LocalPlayer.Character) end
        table.insert(godCons, LocalPlayer.CharacterAdded:Connect(connectGodChar))
    end
end

-- ===== Instant Respawn =====
local function toggleInstantRespawn()
    for _, c in pairs(respawnCons) do pcall(function() c:Disconnect() end) end
    respawnCons = {}
    if Settings.InstantRespawn then
        local c1 = LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid")
            local c2 = hum.Died:Connect(function()
                task.wait(0.1)
                if Settings.InstantRespawn then pcall(function() LocalPlayer:LoadCharacter() end) end
            end)
            table.insert(respawnCons, c2)
        end)
        table.insert(respawnCons, c1)
    end
end

-- ===== Kill Aura =====
local function getKARemote()
    if Settings.KillAuraRemote == "" then return nil end
    local n = Settings.KillAuraRemote
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == n and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then return v end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == n and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then return v end
    end
    return nil
end
local function getKATargets()
    local t = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(t, {Humanoid = hum, RootPart = root, IsPlayer = true})
            end
        end
    end
    if Settings.KillAuraNPC then
        for _, m in ipairs(Workspace:GetDescendants()) do
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
    if kaConn then kaConn:Disconnect(); kaConn = nil end
    if Settings.KillAura then
        kaConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local targets = getKATargets()
            local remote = getKARemote()
            for _, t in pairs(targets) do
                if (myRoot.Position - t.RootPart.Position).Magnitude <= Settings.KillAuraRange then
                    if t.IsPlayer then
                        pcall(function() t.Humanoid:TakeDamage(Settings.KillAuraDamage) end)
                    else
                        if remote then
                            local args = {}
                            local argStr = Settings.KillAuraRemoteArgs:gsub("%s+", "")
                            for a in argStr:gmatch("[^,]+") do
                                a = a:match("^%s*(.-)%s*$")
                                if a == "target" then table.insert(args, t.RootPart)
                                elseif a == "damage" then table.insert(args, Settings.KillAuraDamage)
                                elseif a == "humanoid" then table.insert(args, t.Humanoid) end
                            end
                            if #args == 0 then args = {t.RootPart, Settings.KillAuraDamage} end
                            pcall(function()
                                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                                else remote:InvokeServer(unpack(args)) end
                            end)
                        else
                            pcall(function() t.Humanoid.Health = math.max(0, t.Humanoid.Health - Settings.KillAuraDamage) end)
                        end
                    end
                end
            end
        end)
    end
end

-- ===== Kill Mobs =====
local function toggleKillMobs()
    if kmConn then kmConn:Disconnect(); kmConn = nil end
    if Settings.KillMobs then
        kmConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local folder = Workspace:FindFirstChild("Mobs")
            if not folder then return end
            for _, mob in ipairs(folder:GetChildren()) do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChildOfClass("Humanoid")
                if mobRoot and mobHum and mobHum.Health > 0 then
                    if (root.Position - mobRoot.Position).Magnitude < 25 then
                        pcall(function()
                            if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Attack") then
                                ReplicatedStorage.Events.Attack:FireServer(mobHum)
                            end
                        end)
                    end
                end
            end
        end)
    end
end

-- ===== Auto Chop =====
local function toggleAutoChop()
    if acConn then acConn:Disconnect(); acConn = nil end
    if Settings.AutoChop then
        acConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local folder = Workspace:FindFirstChild("Trees")
            if not folder then return end
            for _, tree in ipairs(folder:GetChildren()) do
                local main = tree:FindFirstChild("Main")
                if main and (root.Position - main.Position).Magnitude < 20 then
                    pcall(function()
                        if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Chop") then
                            ReplicatedStorage.Events.Chop:FireServer(tree)
                        end
                    end)
                end
            end
        end)
    end
end

-- ===== Noclip =====
local function toggleNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if Settings.Noclip then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end

-- ===== ForceField =====
local function updateForceField()
    if Settings.ForceField and LocalPlayer.Character then
        if not LocalPlayer.Character:FindFirstChild("ForceField") then
            Instance.new("ForceField", LocalPlayer.Character)
        end
    elseif LocalPlayer.Character then
        local ff = LocalPlayer.Character:FindFirstChild("ForceField")
        if ff then ff:Destroy() end
    end
end

-- ===== AutoClick =====
local function isMouseOverUI()
    local success, mouse = pcall(function() return LocalPlayer:GetMouse() end)
    if not success or not mouse then return false end
    local x, y = mouse.X, mouse.Y
    local guis = {}
    pcall(function() guis = CoreGui:GetGuiObjectsAtPosition(x, y) end)
    for _, g in pairs(guis) do
        if g and (g.Name == "MKRA_Hub" or g.Name == "RestoreBtn") then return true end
        local p = g and g.Parent
        while p do
            if p.Name == "MKRA_Hub" or p.Name == "RestoreBtn" then return true end
            p = p.Parent
        end
    end
    return false
end
local function toggleAutoClick()
    if acClickConn then acClickConn:Disconnect(); acClickConn = nil end
    autoClickLast = 0
    if Settings.AutoClick then
        acClickConn = RunService.Heartbeat:Connect(function()
            if not LocalPlayer.Character then return end
            local cx, cy = nil, nil
            local success, mouse = pcall(function() return LocalPlayer:GetMouse() end)
            if success and mouse then
                cx, cy = mouse.X, mouse.Y
            elseif Camera then
                local vs = Camera.ViewportSize
                cx, cy = vs.X / 2, vs.Y / 2
            else
                cx, cy = 0, 0
            end
            if not UserInputService.TouchEnabled and isMouseOverUI() then return end
            if tick() - autoClickLast >= autoClickInterval then
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                end)
                autoClickLast = tick()
            end
        end)
    end
end

-- ===== ESP =====
local function updateESP()
    for _, c in pairs(espCons) do pcall(function() c:Disconnect() end) end
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local hl = plr.Character:FindFirstChild("VIP_ESP")
                if hl then hl:Destroy() end
            end
        end)
    end
    espCons = {}
    if Settings.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local function attach(ch)
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "VIP_ESP"
                        hl.Adornee = ch
                        hl.FillColor = Color3.fromRGB(255,0,0)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.new(1,1,1)
                        hl.Parent = ch
                    end)
                end
                if plr.Character then attach(plr.Character) end
                local c = plr.CharacterAdded:Connect(function(ch) task.wait(0.5) attach(ch) end)
                table.insert(espCons, c)
            end
        end
    end
end
Players.PlayerAdded:Connect(function(plr) if Settings.ESP then plr.CharacterAdded:Wait() updateESP() end end)

-- ===== Hitbox =====
task.spawn(function()
    local originalSizes = {}
    while task.wait(0.5) do
        if Settings.HitboxSize > 2 then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        originalSizes[plr.Name] = originalSizes[plr.Name] or hrp.Size
                        pcall(function()
                            hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                            hrp.Transparency = 0.7
                        end)
                    end
                end
            end
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if originalSizes[plr.Name] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    pcall(function() hrp.Size = originalSizes[plr.Name]; hrp.Transparency = 0 end)
                end
            end
            originalSizes = {}
        end
    end
end)

-- ===== Infinite Jump =====
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJumpOrig and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
            hum:ChangeState("Jumping")
        end
    end
end)
local function setInfiniteJump99(enabled)
    if infiniteJump99Conn then pcall(function() infiniteJump99Conn:Disconnect() end) infiniteJump99Conn = nil end
    if enabled then
        infiniteJump99Conn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end
        end)
    end
end

-- ===== FE Kill =====
local function executeFEKill(targetName)
    local target = findPlayer(targetName)
    if not target or not target.Character then notify("Kill","រកមិនឃើញ",3) return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not hum then notify("Kill","តួអង្គមិនរួចរាល់",3) return end
    local savepos = root.CFrame
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then notify("Kill","គ្មាន Torso",3) return end
    torso.Anchored = true
    local hat = char:FindFirstChildOfClass("Accessory")
    if not hat then torso.Anchored = false notify("Kill","ត្រូវការមួក",3) return end
    local tool = Instance.new("Tool", LocalPlayer:FindFirstChild("Backpack") or LocalPlayer.Backpack)
    local handle = hat:FindFirstChild("Handle")
    if not handle then torso.Anchored = false notify("Kill","គ្មាន Handle",3) return end
    handle.Parent = tool handle.Massless = true
    tool.GripPos = Vector3.new(0,9e99,0) tool.Parent = char
    repeat task.wait() until char:FindFirstChildOfClass("Tool")
    pcall(function() tool.Grip = CFrame.new() end) torso.Anchored = false
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    repeat task.wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then break end
        pcall(function() char.HumanoidRootPart.CFrame = targetRoot.CFrame end)
    until not target.Character or (target.Character:FindFirstChild("Humanoid") and target.Character:FindFirstChild("Humanoid").Health <= 0)
        or not LocalPlayer.Character or (LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0)
        or (targetRoot and targetRoot.Velocity.Magnitude > 50)
    if char and char:FindFirstChildOfClass("Humanoid") then pcall(function() char:FindFirstChildOfClass("Humanoid"):UnequipTools() end) end
    if handle and hat then handle.Parent = hat handle.Massless = false end
    pcall(function() tool:Destroy() end)
    if char and char:FindFirstChild("HumanoidRootPart") then pcall(function() char.HumanoidRootPart.CFrame = savepos end) end
    notify("Kill","បានសម្លាប់ "..targetName,3)
end

-- ===== Fling (Player) =====
local function SkidFling(targetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Character or not Humanoid or not RootPart then notify("Fling","តួអង្គមិនរួចរាល់",3) return end
    local TCharacter = targetPlayer and targetPlayer.Character
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = TCharacter:FindFirstChild("HumanoidRootPart")
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
    if THumanoid and THumanoid.Sit and not Settings.FlingAll then notify("Fling","កំពុងអង្គុយ",3) return end
    if THead then Camera.CameraSubject = THead
    elseif Handle then Camera.CameraSubject = Handle
    elseif THumanoid then Camera.CameraSubject = THumanoid end
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
    local function FPos(BasePart, Pos, Ang)
        if not BasePart or not RootPart or not Character then return end
        pcall(function()
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end)
    end
    local function SFBasePart(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -(TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0)), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                end
            else break end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TCharacter or targetPlayer.Parent ~= Players or TCharacter ~= targetPlayer.Character or (THumanoid and THumanoid.Sit) or (Humanoid and Humanoid.Health <= 0) or tick() > Time + TimeToWait
    end
    workspace.FallenPartsDestroyHeight = 0/0
    local BV = Instance.new("BodyVelocity") BV.Name = "EpixVel" BV.Parent = RootPart BV.Velocity = Vector3.new(9e8,9e8,9e8) BV.MaxForce = Vector3.new(1/0,1/0,1/0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if TRootPart and THead then
        if (TRootPart.Position - THead.Position).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
    elseif TRootPart then SFBasePart(TRootPart)
    elseif THead then SFBasePart(THead)
    elseif Handle then SFBasePart(Handle)
    else notify("Fling","ខ្វះផ្នែក",3) if BV then pcall(function() BV:Destroy() end) end return end
    pcall(function() BV:Destroy() end)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Camera.CameraSubject = Humanoid
    local oldPos = getgenv().OldPos if not oldPos then oldPos = RootPart.CFrame end
    repeat
        if oldPos then
            pcall(function()
                RootPart.CFrame = oldPos * CFrame.new(0,.5,0)
                Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0,.5,0))
            end)
        end
        Humanoid:ChangeState("GettingUp")
        for _, x in pairs(Character:GetChildren()) do if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0) end end
        task.wait()
    until (RootPart.Position - (oldPos and oldPos.p or RootPart.Position)).Magnitude < 25
    workspace.FallenPartsDestroyHeight = getgenv().FPDH or 500
end
local function executeFling(name)
    if (name or "") == "" then notify("Fling","បញ្ចូលឈ្មោះ",3) return end
    local target = findPlayer(name)
    if not target then notify("Fling","រកមិនឃើញ",3) return end
    SkidFling(target)
end
local function flingAllPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then SkidFling(plr) end
    end
end

-- ===== Fling NPC =====
local function SkidFlingCharacter(targetCharacter)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Character or not Humanoid or not RootPart then notify("Fling NPC","តួអង្គមិនរួចរាល់",3) return end
    local TCharacter = targetCharacter
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
    if THumanoid and THumanoid.Sit then notify("Fling NPC","NPC កំពុងអង្គុយ",3) return end
    if THead then Camera.CameraSubject = THead
    elseif Handle then Camera.CameraSubject = Handle
    elseif THumanoid then Camera.CameraSubject = THumanoid end
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
    local function FPos(BasePart, Pos, Ang)
        if not BasePart or not RootPart or not Character then return end
        pcall(function()
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end)
    end
    local function SFBasePart(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -(TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0)), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                end
            else break end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TCharacter or TCharacter ~= targetCharacter or (THumanoid and THumanoid.Sit) or (Humanoid and Humanoid.Health <= 0) or tick() > Time + TimeToWait
    end
    workspace.FallenPartsDestroyHeight = 0/0
    local BV = Instance.new("BodyVelocity") BV.Name = "EpixVel" BV.Parent = RootPart BV.Velocity = Vector3.new(9e8,9e8,9e8) BV.MaxForce = Vector3.new(1/0,1/0,1/0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if TRootPart and THead then
        if (TRootPart.Position - THead.Position).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
    elseif TRootPart then SFBasePart(TRootPart)
    elseif THead then SFBasePart(THead)
    elseif Handle then SFBasePart(Handle)
    else notify("Fling NPC","ខ្វះផ្នែក",3) if BV then pcall(function() BV:Destroy() end) end return end
    pcall(function() BV:Destroy() end)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Camera.CameraSubject = Humanoid
    local oldPos = getgenv().OldPos if not oldPos then oldPos = RootPart.CFrame end
    repeat
        if oldPos then
            pcall(function()
                RootPart.CFrame = oldPos * CFrame.new(0,.5,0)
                Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0,.5,0))
            end)
        end
        Humanoid:ChangeState("GettingUp")
        for _, x in pairs(Character:GetChildren()) do if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0) end end
        task.wait()
    until (RootPart.Position - (oldPos and oldPos.p or RootPart.Position)).Magnitude < 25
    workspace.FallenPartsDestroyHeight = getgenv().FPDH or 500
end
local function executeFlingNPC(name)
    if (name or "") == "" then
        notify("Fling NPC","កំពុងស្វែងរក NPC ដែលនៅជិត...",2)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local nearest, nearestDist = nil, math.huge
        for _, descendant in pairs(Workspace:GetDescendants()) do
            if descendant:IsA("Model") and not Players:GetPlayerFromCharacter(descendant) then
                local hum = descendant:FindFirstChildOfClass("Humanoid")
                local root = descendant:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < nearestDist then nearestDist = dist; nearest = descendant end
                end
            end
        end
        if nearest then SkidFlingCharacter(nearest); notify("Fling NPC","បាន Fling NPC "..nearest.Name,3)
        else notify("Fling NPC","រកមិនឃើញ NPC ណានៅជិត",3) end
        return
    end
    local target = findNPC(name)
    if not target then notify("Fling NPC","រកមិនឃើញ NPC",3) return end
    SkidFlingCharacter(target)
    notify("Fling NPC","បាន Fling NPC "..target.Name,3)
end

-- ===== KICK SYSTEM =====
local kickRemotes = {}
local function scanForKickRemotes()
    kickRemotes = {}
    local names = {"Kick","KickPlayer","KickUser","RemovePlayer","BanPlayer","Admin","AdminKick","AdminBan","ModKick","KickEvent","ServerKick","PlayerKick","KickRemote","KickFunction","Ban","BanUser","RemoveUser","PlayerRemove","KickFromServer","DisconnectPlayer","ForceKick"}
    local function search(c)
        for _, obj in ipairs(c:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, n in ipairs(names) do
                    if obj.Name:lower():find(n:lower()) then
                        table.insert(kickRemotes, {Remote=obj, Name=obj:GetFullName(), Type=obj.ClassName})
                        break
                    end
                end
            end
        end
    end
    if ReplicatedStorage then search(ReplicatedStorage) end
    if Workspace then search(Workspace) end
    if LocalPlayer then search(LocalPlayer) end
    return kickRemotes
end
local function tryKickPlayer(playerName)
    local target = findPlayer(playerName)
    if not target then notify("Kick","រកមិនឃើញ",3) return false end
    scanForKickRemotes()
    if #kickRemotes == 0 then notify("Kick","គ្មាន Remote Kick",3) return false end
    for _, kr in ipairs(kickRemotes) do
        pcall(function()
            if kr.Type == "RemoteEvent" then
                kr.Remote:FireServer(target); kr.Remote:FireServer(target.Name); kr.Remote:FireServer(target.UserId)
                kr.Remote:FireServer("kick",target); kr.Remote:FireServer("kick",target.Name)
                kr.Remote:FireServer("Kick",target.Name); kr.Remote:FireServer("kick",target.UserId)
                kr.Remote:FireServer({target,"kick"}); kr.Remote:FireServer({target.Name,"kick"})
            else
                kr.Remote:InvokeServer(target); kr.Remote:InvokeServer(target.Name); kr.Remote:InvokeServer(target.UserId)
                kr.Remote:InvokeServer("kick",target); kr.Remote:InvokeServer("kick",target.Name)
                kr.Remote:InvokeServer("Kick",target.Name); kr.Remote:InvokeServer("kick",target.UserId)
                kr.Remote:InvokeServer({target,"kick"}); kr.Remote:InvokeServer({target.Name,"kick"})
            end
        end)
    end
    notify("Kick","បញ្ជូនទៅ "..target.Name,2)
    return true
end
local function kickAllPlayers()
    local c = 0
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and tryKickPlayer(plr.Name) then c = c + 1 end end
    notify("Kick All","បាន Kick "..c.." នាក់",3)
end

-- ===== BACKDOOR SYSTEM =====
local backdoorRemotes = {}
local function scanForBackdoors()
    backdoorRemotes = {}
    local names = {
        "Admin", "Command", "Function", "Backdoor", "MainRemote", "ServerControl",
        "AdminHandler", "RemoteAdmin", "Moderation", "ServerCommand",
        "Cmd", "Exe", "Run", "Exec", "ServerExec", "Execute",
        "DoCmd", "ServerFunction", "AdminPanel", "ModPanel",
        "Owner", "OwnerCmd", "OwnerCommand", "AdminCommand"
    }
    local function search(c)
        for _, obj in ipairs(c:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, n in ipairs(names) do
                    if obj.Name:lower():find(n:lower()) then
                        table.insert(backdoorRemotes, {Remote=obj, Name=obj:GetFullName(), Type=obj.ClassName})
                        break
                    end
                end
            end
        end
    end
    if ReplicatedStorage then search(ReplicatedStorage) end
    if Workspace then search(Workspace) end
    if LocalPlayer then search(LocalPlayer) end
    return backdoorRemotes
end
local function executeBackdoorCommand(command)
    if command == "" then notify("Backdoor","សូមបញ្ចូលពាក្យបញ្ជា",2) return end
    scanForBackdoors()
    if #backdoorRemotes == 0 then notify("Backdoor","រកមិនឃើញ Remote",3) return end
    local executed = 0
    for _, br in ipairs(backdoorRemotes) do
        local success = pcall(function()
            if br.Type == "RemoteEvent" then
                br.Remote:FireServer(command)
                br.Remote:FireServer(command:split(" "))
                br.Remote:FireServer({command})
                br.Remote:FireServer(command:lower())
            else
                br.Remote:InvokeServer(command)
                br.Remote:InvokeServer(command:split(" "))
                br.Remote:InvokeServer({command})
                br.Remote:InvokeServer(command:lower())
            end
        end)
        if success then executed = executed + 1 end
    end
    notify("Backdoor","បានបញ្ជូនទៅ "..executed.." Remote",2)
end

-- ===== UI =====
local function createUI()
    if CoreGui:FindFirstChild("MKRA_Hub") then CoreGui.MKRA_Hub:Destroy() end
    local gui = Instance.new("ScreenGui") gui.Name="MKRA_Hub" gui.Parent=CoreGui gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local main = Instance.new("Frame") main.Size=UDim2.new(0,300,0,460) main.Position=UDim2.new(0.5,-150,0.5,-230)
    main.BackgroundColor3=Color3.fromRGB(20,20,20) main.BackgroundTransparency=0.05 main.BorderSizePixel=0 main.Active=true main.Draggable=true main.Parent=gui
    Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
    local bgImage = Instance.new("ImageLabel") bgImage.Size=UDim2.new(1,0,1,0) bgImage.Image="rbxassetid://125870011858882" bgImage.ScaleType=Enum.ScaleType.Stretch bgImage.BackgroundTransparency=1 bgImage.Parent=main

    -- Rainbow top bar
    local topRainbow = Instance.new("Frame") topRainbow.Size=UDim2.new(1,0,0,4) topRainbow.Position=UDim2.new(0,0,0,0) topRainbow.BackgroundTransparency=1 topRainbow.Parent=main
    for i=0,59 do local seg=Instance.new("Frame") seg.Size=UDim2.new(1/60,0,1,0) seg.Position=UDim2.new(i/60,0,0,0) seg.BackgroundColor3=rainbowColor(0.3,i/60) seg.BorderSizePixel=0 seg.Parent=topRainbow end
    -- Title bar
    local titleBar = Instance.new("Frame") titleBar.Size=UDim2.new(1,0,0,36) titleBar.Position=UDim2.new(0,0,0,4) titleBar.BackgroundColor3=Color3.fromRGB(30,30,30) titleBar.BorderSizePixel=0 titleBar.Parent=main
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,12)
    local logoImage = Instance.new("ImageLabel") logoImage.Size=UDim2.new(1,-40,1,-4) logoImage.Position=UDim2.new(0,10,0,2) logoImage.BackgroundTransparency=1 logoImage.Image="rbxassetid://125870011858882" logoImage.ScaleType=Enum.ScaleType.Fit logoImage.Parent=titleBar
    local minimizeBtn = Instance.new("TextButton") minimizeBtn.Size=UDim2.new(0,28,0,28) minimizeBtn.Position=UDim2.new(1,-32,0,4) minimizeBtn.BackgroundColor3=Color3.fromRGB(220,50,50) minimizeBtn.Text="−" minimizeBtn.TextColor3=Color3.new(1,1,1) minimizeBtn.Font=Enum.Font.SourceSansBold minimizeBtn.TextSize=20 minimizeBtn.Parent=titleBar
    Instance.new("UICorner",minimizeBtn).CornerRadius=UDim.new(0,8)
    -- Tabs
    local tabFrame = Instance.new("Frame") tabFrame.Size=UDim2.new(1,-10,0,28) tabFrame.Position=UDim2.new(0,5,0,44) tabFrame.BackgroundColor3=Color3.fromRGB(40,40,40) tabFrame.BorderSizePixel=0 tabFrame.Parent=main
    Instance.new("UICorner",tabFrame).CornerRadius=UDim.new(0,8)
    local tabs = {"Move","Combat","Farm","VIP","Visual","Util"}
    local tabContainers = {}
    local contentFrame = Instance.new("Frame") contentFrame.Size=UDim2.new(1,-10,1,-100) contentFrame.Position=UDim2.new(0,5,0,78) contentFrame.BackgroundColor3=Color3.fromRGB(25,25,25) contentFrame.BackgroundTransparency=0.1 contentFrame.BorderSizePixel=0 contentFrame.Parent=main
    Instance.new("UICorner",contentFrame).CornerRadius=UDim.new(0,8)

    -- Create tab buttons and containers
    local tabButtons = {} -- store buttons to modify VIP later
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton") btn.Size=UDim2.new(1/#tabs,-2,1,-4) btn.Position=UDim2.new((i-1)/#tabs,1,0,2) btn.Text=tabName btn.BackgroundColor3=Color3.fromRGB(60,60,60) btn.TextColor3=Color3.new(1,1,1) btn.Font=Enum.Font.GothamBold btn.TextSize=12 btn.Parent=tabFrame
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local con = Instance.new("Frame") con.Size=UDim2.new(1,0,1,0) con.BackgroundTransparency=1 con.Visible=(i==1) con.Parent=contentFrame
        tabContainers[tabName]=con
        tabButtons[tabName] = btn
        if tabName ~= "VIP" then
            btn.MouseButton1Click:Connect(function()
                for _,c in pairs(tabContainers) do c.Visible=false end
                con.Visible=true
                for _,b in ipairs(tabFrame:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(60,60,60) end end
                btn.BackgroundColor3=Color3.fromRGB(0,120,200)
            end)
        end
    end

    -- Helper functions (for non-VIP tabs)
    local function addToggle(container,text,default,callback)
        local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-10,0,28) btn.Position=UDim2.new(0,5,0,#container:GetChildren()*32+5) btn.BackgroundColor3=default and Color3.fromRGB(0,140,0) or Color3.fromRGB(80,80,80) btn.Text=text..": "..(default and "ON" or "OFF") btn.TextColor3=Color3.new(1,1,1) btn.Font=Enum.Font.Gotham btn.TextSize=12 btn.Parent=container Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local state=default
        btn.MouseButton1Click:Connect(function()
            state=not state
            btn.Text=text..": "..(state and "ON" or "OFF")
            btn.BackgroundColor3=state and Color3.fromRGB(0,140,0) or Color3.fromRGB(80,80,80)
            callback(state)
        end)
    end
    local function addButton(container,text,callback)
        local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-10,0,28) btn.Position=UDim2.new(0,5,0,#container:GetChildren()*32+5) btn.BackgroundColor3=Color3.fromRGB(70,70,70) btn.Text=text btn.TextColor3=Color3.new(1,1,1) btn.Font=Enum.Font.Gotham btn.TextSize=12 btn.Parent=container Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        btn.MouseButton1Click:Connect(callback)
    end
    local function addTextBox(container,label,default,callback)
        local frame=Instance.new("Frame") frame.Size=UDim2.new(1,-10,0,32) frame.Position=UDim2.new(0,5,0,#container:GetChildren()*32+5) frame.BackgroundTransparency=1 frame.Parent=container
        local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(0,90,1,0) lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=Color3.new(1,1,1) lbl.Font=Enum.Font.Gotham lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=frame
        local box=Instance.new("TextBox") box.Size=UDim2.new(1,-95,1,-2) box.Position=UDim2.new(0,95,0,1) box.BackgroundColor3=Color3.fromRGB(50,50,50) box.TextColor3=Color3.new(1,1,1) box.Text=default box.Font=Enum.Font.Gotham box.TextSize=12 box.Parent=frame Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
        box.FocusLost:Connect(function() callback(box.Text) end)
    end

    -- Move Tab
    addToggle(tabContainers["Move"],"Fly (Joystick)",false,function(v) Settings.Fly=v; if v then startFly() else stopFly() end end)
    addToggle(tabContainers["Move"],"Fly Full Map (WASD)",false,function(v) Settings.FullMapFly=v; if v then startFullMapFly() else stopFullMapFly() end end)
    addToggle(tabContainers["Move"],"Noclip (Full Map)",false,function(v) Settings.FullMapFlyNoclip=v end)
    addTextBox(tabContainers["Move"],"Full Fly Speed","200",function(v) Settings.FullMapFlySpeed=tonumber(v) or 200 end)
    addTextBox(tabContainers["Move"],"Joystick Speed","120",function(v) Settings.FlySpeed=tonumber(v) or 120 end)
    addButton(tabContainers["Move"],"Teleport Random",flyToRandomLocation)
    addToggle(tabContainers["Move"],"Boost (x2.5)",false,function(v) Settings.BoostMode=v end)
    addToggle(tabContainers["Move"],"Noclip (All)",false,function(v) Settings.Noclip=v; toggleNoclip() end)
    addTextBox(tabContainers["Move"],"WS Mult","1",function(v) Settings.SpeedBoostMultiplier=tonumber(v) or 1; updateWalkSpeed() end)
    addToggle(tabContainers["Move"],"Inf Jump (Orig)",false,function(v) Settings.InfiniteJumpOrig=v end)

    -- Combat Tab
    addToggle(tabContainers["Combat"],"Kill Aura",false,function(v) Settings.KillAura=v; toggleKillAura() end)
    addTextBox(tabContainers["Combat"],"KA Range","30",function(v) Settings.KillAuraRange=tonumber(v) or 30 end)
    addTextBox(tabContainers["Combat"],"KA Damage","30",function(v) Settings.KillAuraDamage=tonumber(v) or 30 end)
    addToggle(tabContainers["Combat"],"KA NPCs",false,function(v) Settings.KillAuraNPC=v; if Settings.KillAura then toggleKillAura() end end)
    addTextBox(tabContainers["Combat"],"Remote Name","",function(v) Settings.KillAuraRemote=v end)
    addTextBox(tabContainers["Combat"],"Args","target,damage",function(v) Settings.KillAuraRemoteArgs=v end)
    addToggle(tabContainers["Combat"],"Kill Mobs (99)",false,function(v) Settings.KillMobs=v; toggleKillMobs() end)
    addToggle(tabContainers["Combat"],"Hitbox",false,function(v) Settings.HitboxSize=v and 10 or 2 end)
    addToggle(tabContainers["Combat"],"AutoClick (PC+Mobile)",false,function(v) Settings.AutoClick=v; toggleAutoClick() end)
    addToggle(tabContainers["Combat"],"ForceField",false,function(v) Settings.ForceField=v; updateForceField() end)

    -- Farm Tab
    addToggle(tabContainers["Farm"],"Auto Chop (99)",false,function(v) Settings.AutoChop=v; toggleAutoChop() end)
    addTextBox(tabContainers["Farm"],"WalkSpeed (16-500)","16",function(v) Settings.WalkSpeedDirect=math.clamp(tonumber(v) or 16,16,500); updateWalkSpeed() end)
    addToggle(tabContainers["Farm"],"Inf Jump (99)",false,function(v) Settings.InfiniteJump99=v; setInfiniteJump99(v) end)

    -- VIP Tab with ScrollingFrame (FIXED)
    local vipCon = tabContainers["VIP"]
    vipCon:Destroy()
    local vipScroll = Instance.new("ScrollingFrame")
    vipScroll.Size = UDim2.new(1,0,1,0)
    vipScroll.BackgroundTransparency = 1
    vipScroll.BorderSizePixel = 0
    vipScroll.ScrollBarThickness = 6
    vipScroll.CanvasSize = UDim2.new(0,0,0,0)
    vipScroll.Parent = contentFrame
    vipScroll.Visible = false
    tabContainers["VIP"] = vipScroll

    -- Update VIP button click to show vipScroll
    if tabButtons["VIP"] then
        tabButtons["VIP"].MouseButton1Click:Connect(function()
            for _,c in pairs(tabContainers) do c.Visible = false end
            vipScroll.Visible = true
            for _,b in ipairs(tabFrame:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(60,60,60) end end
            tabButtons["VIP"].BackgroundColor3 = Color3.fromRGB(0,120,200)
        end)
    end

    local vipElements = 0
    local function updateCanvasSize()
        vipScroll.CanvasSize = UDim2.new(0,0,0, vipElements * 32 + 10)
    end
    local function vipAddToggle(text,default,callback)
        local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-10,0,28) btn.Position=UDim2.new(0,5,0,vipElements*32+5) btn.BackgroundColor3=default and Color3.fromRGB(0,140,0) or Color3.fromRGB(80,80,80) btn.Text=text..": "..(default and "ON" or "OFF") btn.TextColor3=Color3.new(1,1,1) btn.Font=Enum.Font.Gotham btn.TextSize=12 btn.Parent=vipScroll Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local state=default
        btn.MouseButton1Click:Connect(function()
            state=not state
            btn.Text=text..": "..(state and "ON" or "OFF")
            btn.BackgroundColor3=state and Color3.fromRGB(0,140,0) or Color3.fromRGB(80,80,80)
            callback(state)
        end)
        vipElements=vipElements+1
        updateCanvasSize()
    end
    local function vipAddButton(text,callback)
        local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-10,0,28) btn.Position=UDim2.new(0,5,0,vipElements*32+5) btn.BackgroundColor3=Color3.fromRGB(70,70,70) btn.Text=text btn.TextColor3=Color3.new(1,1,1) btn.Font=Enum.Font.Gotham btn.TextSize=12 btn.Parent=vipScroll Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        btn.MouseButton1Click:Connect(callback)
        vipElements=vipElements+1
        updateCanvasSize()
    end
    local function vipAddTextBox(label,default,callback)
        local frame=Instance.new("Frame") frame.Size=UDim2.new(1,-10,0,32) frame.Position=UDim2.new(0,5,0,vipElements*32+5) frame.BackgroundTransparency=1 frame.Parent=vipScroll
        local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(0,90,1,0) lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=Color3.new(1,1,1) lbl.Font=Enum.Font.Gotham lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=frame
        local box=Instance.new("TextBox") box.Size=UDim2.new(1,-95,1,-2) box.Position=UDim2.new(0,95,0,1) box.BackgroundColor3=Color3.fromRGB(50,50,50) box.TextColor3=Color3.new(1,1,1) box.Text=default box.Font=Enum.Font.Gotham box.TextSize=12 box.Parent=frame Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
        box.FocusLost:Connect(function() callback(box.Text) end)
        vipElements=vipElements+1
        updateCanvasSize()
    end
    local function vipAddFrameWithBox(placeholder,scanText,scanCallback,btnText,btnCallback)
        local frame=Instance.new("Frame") frame.Size=UDim2.new(1,-10,0,30) frame.Position=UDim2.new(0,5,0,vipElements*32+5) frame.BackgroundTransparency=1 frame.Parent=vipScroll
        local box=Instance.new("TextBox") box.Size=UDim2.new(0,170,1,0) box.Position=UDim2.new(0,0,0,0) box.BackgroundColor3=Color3.fromRGB(50,50,50) box.PlaceholderText=placeholder box.Text="" box.Font=Enum.Font.Gotham box.TextSize=12 box.Parent=frame Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
        local scanBtn=Instance.new("TextButton") scanBtn.Size=UDim2.new(0,95,1,0) scanBtn.Position=UDim2.new(1,-100,0,0) scanBtn.BackgroundColor3=Color3.fromRGB(0,100,200) scanBtn.Text=scanText scanBtn.TextColor3=Color3.new(1,1,1) scanBtn.Font=Enum.Font.Gotham scanBtn.TextSize=11 scanBtn.Parent=frame Instance.new("UICorner",scanBtn).CornerRadius=UDim.new(0,4)
        scanBtn.MouseButton1Click:Connect(function() scanCallback(box) end)
        vipElements=vipElements+1
        updateCanvasSize()
        vipAddButton(btnText, function() btnCallback(box.Text) end)
    end

    -- Populate VIP
    vipAddButton("Teleport to Mouse",function()
        local mouse=LocalPlayer:GetMouse() if mouse and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(mouse.Hit.Position) end) end end)
    vipAddToggle("ESP",false,function(v) Settings.ESP=v; updateESP() end)
    vipAddButton("Heal",function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health=LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MaxHealth end) end end)
    vipAddToggle("God Mode",false,function(v) Settings.GodMode=v; toggleGodMode() end)
    vipAddToggle("Instant Respawn",false,function(v) Settings.InstantRespawn=v; toggleInstantRespawn() end)
    vipAddButton("VIP Speed (100/2500)",function() Settings.SpeedBoostMultiplier=100/16; Settings.FlySpeed=2500; updateWalkSpeed(); notify("Speed","Walk 100, Fly 2500",2) end)
    vipAddButton("Reset Speed",function() Settings.SpeedBoostMultiplier=1; Settings.FlySpeed=120; updateWalkSpeed(); notify("Speed","Reset default",2) end)
    vipAddButton("Spawn Cash",function() pcall(function() if ReplicatedStorage:FindFirstChild("AddMoney") then ReplicatedStorage.AddMoney:FireServer(999999) end end) notify("Cash","សាកល្បង",2) end)
    -- Kill
    vipAddFrameWithBox("ឈ្មោះគោលដៅ (Kill)","ស្កេនឈ្មោះ",function(box)
        local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not myRoot then return end
        local nearest,d=nil,math.huge for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local dist=(myRoot.Position-plr.Character.HumanoidRootPart.Position).Magnitude if dist<d then d=dist nearest=plr end end end
        if nearest then box.Text=nearest.Name end
    end,"KILL (FE)",function(text) executeFEKill(text) end)
    -- Fling Player
    vipAddFrameWithBox("ឈ្មោះគោលដៅ (Fling)","ស្កេនឈ្មោះ",function(box)
        local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not myRoot then return end
        local nearest,d=nil,math.huge for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local dist=(myRoot.Position-plr.Character.HumanoidRootPart.Position).Magnitude if dist<d then d=dist nearest=plr end end end
        if nearest then box.Text=nearest.Name end
    end,"FLING",function(text) executeFling(text) end)
    -- Fling NPC
    vipAddFrameWithBox("ឈ្មោះ NPC (Fling)","ស្កេន NPC",function(box)
        local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not myRoot then return end
        local nearest,nearestDist=nil,math.huge for _,desc in ipairs(Workspace:GetDescendants()) do if desc:IsA("Model") and not Players:GetPlayerFromCharacter(desc) then local hum=desc:FindFirstChildOfClass("Humanoid") local root=desc:FindFirstChild("HumanoidRootPart") if hum and root and hum.Health>0 then local dist=(myRoot.Position-root.Position).Magnitude if dist<nearestDist then nearestDist=dist nearest=desc end end end end
        if nearest then box.Text=nearest.Name end
    end,"FLING NPC",function(text) executeFlingNPC(text) end)
    vipAddToggle("Fling All",false,function(v) Settings.FlingAll=v; if v then flingAllPlayers() end end)
    -- Kick
    vipAddFrameWithBox("ឈ្មោះ (Kick)","ស្កេនឈ្មោះ",function(box)
        local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not myRoot then return end
        local nearest,d=nil,math.huge for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local dist=(myRoot.Position-plr.Character.HumanoidRootPart.Position).Magnitude if dist<d then d=dist nearest=plr end end end
        if nearest then box.Text=nearest.Name end
    end,"KICK",function(text) tryKickPlayer(text) end)
    vipAddButton("KICK ALL",kickAllPlayers)
    vipAddButton("ស្កេនរក Remote Kick",function() scanForKickRemotes() notify("Kick","រកឃើញ "..#kickRemotes.." Remote",3) end)
    -- Backdoor
    vipAddFrameWithBox("ពាក្យបញ្ជា (:kill, :ban...)","ស្កេន Backdoor",function(box)
        scanForBackdoors() notify("Backdoor","រកឃើញ "..#backdoorRemotes.." Remote",3)
    end,"EXECUTE",function(text) executeBackdoorCommand(text) end)
    vipAddButton("ស្កេនរក Backdoor",function() scanForBackdoors() notify("Backdoor","រកឃើញ "..#backdoorRemotes.." Remote",3) end)

    -- Visual Tab
    addTextBox(tabContainers["Visual"],"FOV (70-120)","70",function(v) pcall(function() Camera.FieldOfView=math.clamp(tonumber(v) or 70,70,120) end) end)
    addToggle(tabContainers["Visual"],"FullBright",false,function(v) local lighting=game:GetService("Lighting") if v then lighting.Brightness=2 lighting.ClockTime=12 lighting.FogEnd=100000 else lighting.Brightness=0.5 lighting.ClockTime=0 lighting.FogEnd=1000 end end)
    addToggle(tabContainers["Visual"],"រូបភាពផ្ទៃខាងក្រោយ",true,function(v) bgImage.Visible=v end)

    -- Util Tab
    addButton(tabContainers["Util"],"Rejoin",function() TeleportService:Teleport(game.PlaceId,LocalPlayer) end)
    addButton(tabContainers["Util"],"Server Hop",function()
        pcall(function()
            local json=game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
            local ids={} for _,v in ipairs(json.data or {}) do if v.playing and v.id~=game.JobId then table.insert(ids,v.id) end end
            if #ids>0 then TeleportService:TeleportToPlaceInstance(game.PlaceId,ids[math.random(#ids)],LocalPlayer) else notify("Hop","រកមិនឃើញ",3) end
        end)
    end)

    -- Credit Label
    local creditLabel=Instance.new("TextLabel") creditLabel.Size=UDim2.new(1,0,0,20) creditLabel.Position=UDim2.new(0,0,1,-24) creditLabel.BackgroundTransparency=1 creditLabel.Text="ធ្វើដោយ Oun ka" creditLabel.TextColor3=Color3.new(1,1,1) creditLabel.Font=Enum.Font.GothamBold creditLabel.TextSize=14 creditLabel.Parent=main
    -- Bottom rainbow
    local bottomRainbow=Instance.new("Frame") bottomRainbow.Size=UDim2.new(1,0,0,4) bottomRainbow.Position=UDim2.new(0,0,1,-4) bottomRainbow.BackgroundTransparency=1 bottomRainbow.Parent=main
    for i=0,59 do local seg=Instance.new("Frame") seg.Size=UDim2.new(1/60,0,1,0) seg.Position=UDim2.new(i/60,0,0,0) seg.BackgroundColor3=rainbowColor(0.3,i/60) seg.BorderSizePixel=0 seg.Parent=bottomRainbow end
    -- Sparkles
    local sparkles={} for _=1,15 do local spark=Instance.new("Frame") spark.Size=UDim2.new(0,6,0,6) spark.Position=UDim2.new(math.random(),0,math.random(),0) spark.BackgroundColor3=Color3.new(1,1,1) spark.BorderSizePixel=0 spark.BackgroundTransparency=0.7 spark.Parent=main Instance.new("UICorner",spark).CornerRadius=UDim.new(1,0) table.insert(sparkles,spark) end
    -- Animations
    task.spawn(function()
        while wait() do
            local hue=(tick()*0.5)%1
            creditLabel.TextColor3=Color3.fromHSV((hue+0.3)%1,1,1)
            minimizeBtn.BackgroundColor3=Color3.fromHSV((hue+0.6)%1,1,0.8)
            for i,seg in ipairs(topRainbow:GetChildren()) do seg.BackgroundColor3=Color3.fromHSV((tick()*0.3 + i/60)%1,1,1) end
            for i,seg in ipairs(bottomRainbow:GetChildren()) do seg.BackgroundColor3=Color3.fromHSV((tick()*0.3 + i/60)%1,1,1) end
            for _,spark in ipairs(sparkles) do
                local twinkle=0.4+0.6*math.abs(math.sin(tick()*5+(spark:GetAttribute("Offset") or 0)))
                spark.BackgroundTransparency=1-twinkle
                if not spark:GetAttribute("Offset") then spark:SetAttribute("Offset",math.random()*10) end
            end
        end
    end)
    -- Minimize/Restore
    local restoreButton=nil
    local function minimizeUI()
        main.Visible=false
        if not restoreButton then
            restoreButton=Instance.new("TextButton") restoreButton.Name="RestoreBtn" restoreButton.Size=UDim2.new(0,44,0,44) restoreButton.Position=UDim2.new(main.Position.X.Scale,main.Position.X.Offset,main.Position.Y.Scale,main.Position.Y.Offset) restoreButton.BackgroundColor3=rainbowColor(1,0) restoreButton.Text="+" restoreButton.TextColor3=Color3.new(1,1,1) restoreButton.Font=Enum.Font.SourceSansBold restoreButton.TextSize=28 restoreButton.Active=true restoreButton.Draggable=true restoreButton.Parent=gui Instance.new("UICorner",restoreButton).CornerRadius=UDim.new(0,12)
            task.spawn(function() while restoreButton and restoreButton.Parent do restoreButton.BackgroundColor3=rainbowColor(1,0) wait(0.05) end end)
            restoreButton.MouseButton1Click:Connect(function() main.Visible=true restoreButton:Destroy() restoreButton=nil end)
        else restoreButton.Visible=true end
    end
    minimizeBtn.MouseButton1Click:Connect(minimizeUI)
end

-- Character Added
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.Fly then stopFly(); startFly() end
    if Settings.FullMapFly then stopFullMapFly(); startFullMapFly() end
    if Settings.GodMode then toggleGodMode() end
    if Settings.Noclip then toggleNoclip() end
    if Settings.ESP then updateESP() end
    if Settings.KillAura then toggleKillAura() end
    if Settings.KillMobs then toggleKillMobs() end
    if Settings.AutoChop then toggleAutoChop() end
    updateWalkSpeed()
end)

-- Start
createUI()
notify("MKRA Hub","Loaded! Fly, Kick, Backdoor, All Features",5)