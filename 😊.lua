-- ==================================================
-- ounCOPYBARA - COMPLETE VERSION (ALL FEATURES RESTORED)
-- ALL FEATURES + NPC KILLER + VIP FREEZE V2.0 + KILL AURA + FLING + MOBILE OPTIMIZED
-- ==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local DEFAULT_IMAGE = "rbxassetid://0"
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"

-- ==================================================
-- SETTINGS (បន្ថែមមុខងារដែលបាត់ទាំងអស់)
-- ==================================================

local Settings = {
    
    Fly = false, FlySpeed = 120, BoostMode = false, Noclip = false,
    SpeedBoostMultiplier = 1, WalkSpeedDirect = 16, InfiniteJumpOrig = false,
    

    KillAura = false, KillAuraRange = 30, KillAuraDamage = 30, KillAuraNPC = false,
    HitboxSize = 2, AutoClick = false, ForceField = false,
    AutoClickBall = false, BallDistance = 5,
    CombatRange = 30, CombatPreview = false,
    

    NPC_ESP = false, NPC_ESP_Name = true, NPC_ESP_Health = true,
    NPC_ESP_Distance = true, NPC_ESP_HideDead = true, NPC_ESP_Range = 200,
    VIPFreezeHold = false, VIPFreezeKill = false, VIPFreeze_Range = 50,
    NPC_Killer = false, NPC_Kill_Range = 50, NPC_Kill_Damage = 30,
    NPC_Kill_Mode = "ALL", NPC_Kill_UseRemotes = true, NPC_Kill_UseRaycast = true,
    KillMobs = false, AutoChop = false,
    

    GodMode = false, InstantRespawn = false, PlayerESP = false,
    FlingAll = false, AutoF = false, AutoFPaused = false,
    FullBright = false, FOV = 70,
}

local State = {
    FlyConnection = nil, NoclipConnection = nil, ESPObjects = {},
    PlayerESPObjects = {}, GodModeConnection = nil, AutoFConnection = nil,
    FreezeConnection = nil, AutoChopConnection = nil, CombatConnection = nil,
    KillAuraConnection = nil, IsRunning = true
}


local function playBeep() end
local function safeNotify(...) end
local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 3}) end)
end

local function getRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function isValidNPC(model)
    if not model or not model:IsA("Model") then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then return false end
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = getRootPart(model)
    return hum ~= nil and root ~= nil
end

local function isValidPlayer(model)
    if not model or not model:IsA("Model") then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model and player ~= LocalPlayer then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = getRootPart(model)
            return hum ~= nil and root ~= nil and hum.Health > 0
        end
    end
    return false
end

-- ==================================================
-- NPC KILLER (5 METHODS)
-- ==================================================

local function killMethod_Direct(npc, damage)
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return pcall(function() hum:TakeDamage(damage) end) and hum.Health <= 0
end

local function killMethod_Health(npc, damage)
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return pcall(function() hum.Health = math.max(0, hum.Health - damage) end) and hum.Health <= 0
end

local function killMethod_Remote(npc)
    local remotes = {}
    local function scan(obj)
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find("attack") or n:find("hit") or n:find("damage") or n:find("kill") then
                table.insert(remotes, obj)
            end
        elseif obj:IsA("Folder") then
            for _, c in ipairs(obj:GetChildren()) do scan(c) end
        end
    end
    pcall(function()
        if game:GetService("ReplicatedStorage") then scan(game:GetService("ReplicatedStorage")) end
        if Workspace then scan(Workspace) end
    end)
    for _, r in ipairs(remotes) do
        if pcall(function() r:FireServer(npc) end) then return true end
    end
    return false
end

local function killMethod_Raycast(npc)
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local npcRoot = getRootPart(npc)
    if not npcRoot then return false end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(char:GetPivot().Position, (npcRoot.Position - char:GetPivot().Position).Unit * 50, rp)
    if result and result.Instance and result.Instance:IsDescendantOf(npc) then
        for _, c in ipairs(tool:GetDescendants()) do
            if c:IsA("RemoteEvent") and c.Name:lower():find("hit") then
                pcall(function() c:FireServer(result.Instance, result.Position) end)
                return true
            end
        end
    end
    return false
end

local function killNPC(npc, damage)
    if not npc or not npc.Parent then return false end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if killMethod_Direct(npc, damage) then return true end
    if killMethod_Health(npc, damage) then return true end
    if Settings.NPC_Kill_UseRemotes and killMethod_Remote(npc) then return true end
    if Settings.NPC_Kill_UseRaycast and killMethod_Raycast(npc) then return true end
    return false
end

-- ==================================================
-- KILL MOBS (ពិសេសសម្រាប់ហ្គេមខ្លះ)
-- ==================================================
local function toggleKillMobs()
    if State.KillMobsConnection then State.KillMobsConnection:Disconnect() end
    if not Settings.KillMobs then return end
    State.KillMobsConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local folder = Workspace:FindFirstChild("Mobs")
        if not folder then return end
        for _, mob in folder:GetChildren() do
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChildOfClass("Humanoid")
            if mobRoot and mobHum and mobHum.Health > 0 and (root.Position - mobRoot.Position).Magnitude < 25 then
                pcall(function() ReplicatedStorage.Events.Attack:FireServer(mobHum) end)
            end
        end
    end)
end

-- ==================================================
-- KILL AURA
-- ==================================================
local function getKA_Targets()
    local targets = {}
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(targets, {Humanoid = hum, RootPart = root, IsPlayer = true})
            end
        end
    end
    if Settings.KillAuraNPC then
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
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

local function toggleKillAura()
    if State.KillAuraConnection then State.KillAuraConnection:Disconnect() end
    if not Settings.KillAura then return end
    State.KillAuraConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local targets = getKA_Targets()
        for _, target in ipairs(targets) do
            if (myRoot.Position - target.RootPart.Position).Magnitude <= Settings.KillAuraRange then
                target.Humanoid:TakeDamage(Settings.KillAuraDamage)
            end
        end
    end)
end

-- ==================================================
-- FLING (រក្សាដើម)
-- ==================================================
local function findPlayer(name)
    name = name:gsub("%s+", ""):lower()
    for _, plr in Players:GetPlayers() do
        if plr.Name:lower():match("^"..name) then return plr end
    end
    return nil
end

local function SkidFling(targetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    if not Character or not Humanoid or not RootPart then return end
    local TCharacter = targetPlayer.Character
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if THead then Workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then Workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid then Workspace.CurrentCamera.CameraSubject = THumanoid end
    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local SFBasePart = function(BasePart)
        local TimeToWait = 2; local Time = tick(); local Angle = 0
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
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                end
            else break end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TCharacter or targetPlayer.Parent ~= Players or tick() > Time + TimeToWait
    end
    workspace.FallenPartsDestroyHeight = 0 / 0
    local BV = Instance.new("BodyVelocity"); BV.Name = "EpixVel"; BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8); BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if TRootPart and THead then if (TRootPart.Position - THead.Position).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
    elseif TRootPart then SFBasePart(TRootPart)
    elseif THead then SFBasePart(THead)
    elseif Handle then SFBasePart(Handle) end
    BV:Destroy(); Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid
    repeat
        RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
        Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
        Humanoid:ChangeState("GettingUp")
        task.wait()
    until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
    workspace.FallenPartsDestroyHeight = getgenv().FPDH or 500
end

local function executeFling(name)
    if name == "" then return end
    local target = findPlayer(name)
    if not target then notify("Fling", "រកមិនឃើញ", 3) return end
    SkidFling(target)
end

local function flingAllPlayers()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character then SkidFling(plr) end
    end
end

local function executeFEKill(targetName)
    local target = findPlayer(targetName)
    if not target or not target.Character then notify("Kill", "រកមិនឃើញគោលដៅ", 3) return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not hum then return end
    local savepos = root.CFrame
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    torso.Anchored = true
    local hat = char:FindFirstChildOfClass("Accessory")
    if not hat then torso.Anchored = false; return end
    local tool = Instance.new("Tool", LocalPlayer.Backpack)
    local handle = hat.Handle; handle.Parent = tool; handle.Massless = true
    tool.GripPos = Vector3.new(0, 9e99, 0); tool.Parent = char
    repeat task.wait() until char:FindFirstChildOfClass("Tool")
    tool.Grip = CFrame.new(); torso.Anchored = false
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    repeat
        task.wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then break end
        char.HumanoidRootPart.CFrame = targetRoot.CFrame
    until target.Character == nil or target.Character:FindFirstChild("Humanoid").Health <= 0
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):UnequipTools() end
    handle.Parent = hat; handle.Massless = false; tool:Destroy()
    if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = savepos end
    notify("Kill", "បានសម្លាប់ ".. targetName, 3)
end

-- ==================================================
-- VIP FREEZE V2.0 (5 METHODS + NUCLEAR)
-- ==================================================

local function freezeNPC_V2(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    pcall(function()
        for _, part in ipairs(npc:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true; part.CanCollide = false
                part.Velocity = Vector3.zero; part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
    pcall(function()
        for _, part in ipairs(npc:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, joint in ipairs(part:GetJoints()) do
                    if joint:IsA("Motor6D") or joint:IsA("Weld") or joint:IsA("Hinge") then joint:Destroy() end
                end
            end
        end
    end)
    pcall(function()
        if hum then
            hum.WalkSpeed = 0; hum.JumpPower = 0; hum.JumpHeight = 0; hum.AutoRotate = false
            hum.PlatformStand = true; hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
    pcall(function()
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = true; hrp.CanCollide = false end
    end)
    pcall(function()
        local root = getRootPart(npc)
        if root and root:IsA("BasePart") then
            local bv = root:FindFirstChild("ouncopybara_Freeze")
            if not bv then bv = Instance.new("BodyVelocity"); bv.Name = "ouncopybara_Freeze"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Parent = root end
            bv.Velocity = Vector3.zero
            local bg = root:FindFirstChild("ouncopybara_FreezeGyro")
            if not bg then bg = Instance.new("BodyGyro"); bg.Name = "ouncopybara_FreezeGyro"; bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.Parent = root end
            bg.CFrame = root.CFrame
        end
    end)
end

local function nuclearFreeze(npc)
    pcall(function()
        for _, part in ipairs(npc:GetDescendants()) do if part:IsA("BasePart") then part:Destroy() end end
        local hum = npc:FindFirstChildOfClass("Humanoid"); if hum then hum:Destroy() end
        npc:Destroy()
    end)
end

local function toggleVIPFreezeHold()
    if State.FreezeConnection then State.FreezeConnection:Disconnect() end
    if not Settings.VIPFreezeHold and not Settings.VIPFreezeKill then return end
    State.FreezeConnection = RunService.Heartbeat:Connect(function()
        if not Settings.VIPFreezeHold and not Settings.VIPFreezeKill then return end
        local char = LocalPlayer.Character; local playerRoot = char and getRootPart(char)
        if not playerRoot then return end
        local range = Settings.VIPFreeze_Range or 50
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isValidNPC(obj) then
                local npcRoot = getRootPart(obj)
                if npcRoot and (playerRoot.Position - npcRoot.Position).Magnitude <= range then
                    if Settings.VIPFreezeHold then freezeNPC_V2(obj) end
                    if Settings.VIPFreezeKill then
                        freezeNPC_V2(obj)
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then pcall(function() hum:TakeDamage(999999); if hum.Health > 0 then hum.Health = 0 end end) end
                    end
                end
            end
        end
    end)
end

local function toggleVIPFreezeKill() toggleVIPFreezeHold() end

-- ==================================================
-- FLY
-- ==================================================

local function startFly()
    if State.FlyConnection then State.FlyConnection:Disconnect() end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = getRootPart(character)
    if not humanoid or not rootPart then return end
    for _, obj in ipairs(rootPart:GetChildren()) do if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or obj:IsA("BodyForce") then obj:Destroy() end end
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero; bv.Parent = rootPart
    local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 1e4; bg.Parent = rootPart
    local bf = Instance.new("BodyForce"); bf.Force = Vector3.new(0, workspace.Gravity * rootPart.AssemblyMass, 0); bf.Parent = rootPart
    State.FlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly or not character or not character.Parent then pcall(function() bv:Destroy() bg:Destroy() bf:Destroy() end) return end
        local camera = Workspace.CurrentCamera; if not camera then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        local speed = Settings.FlySpeed; if Settings.BoostMode then speed = speed * 2 end
        bv.Velocity = dir * speed; bg.CFrame = camera.CFrame
    end)
end

local function stopFly()
    if State.FlyConnection then State.FlyConnection:Disconnect() State.FlyConnection = nil end
    local character = LocalPlayer.Character; if not character then return end
    local rootPart = getRootPart(character); if not rootPart then return end
    pcall(function() for _, obj in ipairs(rootPart:GetChildren()) do if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or obj:IsA("BodyForce") then obj:Destroy() end end end)
end

-- ==================================================
-- NOCLIP
-- ==================================================

local function toggleNoclip()
    if State.NoclipConnection then State.NoclipConnection:Disconnect() State.NoclipConnection = nil end
    if not Settings.Noclip then return end
    State.NoclipConnection = RunService.Stepped:Connect(function()
        if not Settings.Noclip then return end
        local character = LocalPlayer.Character; if not character then return end
        for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end end
    end)
end

local function updateWalkSpeed()
    local character = LocalPlayer.Character; if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = math.max(Settings.SpeedBoostMultiplier * 16, Settings.WalkSpeedDirect, 16) end
end

-- ==================================================
-- ESP SYSTEMS
-- ==================================================

local function createPlayerESP(player)
    if State.PlayerESPObjects[player] then return end
    local character = player.Character; if not character or not isValidPlayer(character) then return end
    local hum = character:FindFirstChildOfClass("Humanoid"); local root = getRootPart(character)
    if not hum or not root then return end
    local highlight = Instance.new("Highlight"); highlight.Name = "PlayerESP"; highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.FillColor = Color3.fromRGB(255,100,100)
    highlight.FillTransparency = 0.7; highlight.OutlineColor = Color3.new(1,1,1); highlight.Enabled = Settings.PlayerESP
    highlight.Parent = character
    State.PlayerESPObjects[player] = { Highlight = highlight, Humanoid = hum, Root = root }
end

local function updateESP() for _, data in pairs(State.PlayerESPObjects) do if data.Highlight then data.Highlight.Enabled = Settings.PlayerESP end end end

local function scanPlayers() for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character then createPlayerESP(player) end end end

local function createNPCESP(npc)
    if State.ESPObjects[npc] then return end
    if not isValidNPC(npc) then return end
    local hum = npc:FindFirstChildOfClass("Humanoid"); local root = getRootPart(npc)
    if not hum or not root then return end
    local highlight = Instance.new("Highlight"); highlight.Name = "NPC_ESP"; highlight.Adornee = npc
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.FillColor = Color3.fromRGB(220,150,200)
    highlight.FillTransparency = 0.75; highlight.OutlineColor = Color3.new(1,1,1); highlight.Enabled = false
    highlight.Parent = npc
    local billboard = Instance.new("BillboardGui"); billboard.Name = "NPC_Info"; billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(180,48); billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true; billboard.Enabled = false; billboard.Parent = CoreGui
    local nameLabel = Instance.new("TextLabel", billboard); nameLabel.Size = UDim2.new(1,0,0,18); nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1); nameLabel.TextSize = 10; nameLabel.Font = Enum.Font.GothamBold; nameLabel.TextStrokeTransparency = 0.5
    local healthBG = Instance.new("Frame", billboard); healthBG.Size = UDim2.new(1,0,0,6); healthBG.Position = UDim2.fromOffset(0,20)
    healthBG.BackgroundColor3 = Color3.fromRGB(35,35,45); healthBG.BorderSizePixel = 0; Instance.new("UICorner", healthBG).CornerRadius = UDim.new(0,4)
    local healthFill = Instance.new("Frame", healthBG); healthFill.Size = UDim2.fromScale(1,1)
    healthFill.BackgroundColor3 = Color3.fromRGB(35,225,110); healthFill.BorderSizePixel = 0; Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0,4)
    local infoLabel = Instance.new("TextLabel", billboard); infoLabel.Size = UDim2.new(1,0,0,18); infoLabel.Position = UDim2.fromOffset(0,27)
    infoLabel.BackgroundTransparency = 1; infoLabel.TextColor3 = Color3.fromRGB(165,170,195); infoLabel.TextSize = 8
    infoLabel.Font = Enum.Font.GothamMedium; infoLabel.TextStrokeTransparency = 0.5
    State.ESPObjects[npc] = { Highlight=highlight, Billboard=billboard, NameLabel=nameLabel, HealthBG=healthBG, HealthFill=healthFill, InfoLabel=infoLabel, Humanoid=hum, Root=root }
end

local function removeNPCESP(npc)
    local data = State.ESPObjects[npc]; if not data then return end
    pcall(function() if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end end)
    State.ESPObjects[npc] = nil
end

local function scanNPCs() for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("Model") and isValidNPC(obj) then createNPCESP(obj) end end end

-- ==================================================
-- KILLER LOOP (NPC + ESP)
-- ==================================================
task.spawn(function()
    while State.IsRunning and task.wait(0.15) do
        if not Settings.NPC_Killer then continue end
        local char = LocalPlayer.Character; local playerRoot = char and getRootPart(char)
        if not playerRoot then continue end
        local nearestNPC, nearestDist = nil, math.huge; local lowestNPC, lowestHP = nil, math.huge
        for npc, data in pairs(State.ESPObjects) do
            if npc.Parent and data.Root and data.Humanoid then
                local dist = (playerRoot.Position - data.Root.Position).Magnitude
                if dist < nearestDist and dist <= Settings.NPC_Kill_Range then nearestDist = dist; nearestNPC = npc end
                if data.Humanoid.Health < lowestHP and dist <= Settings.NPC_Kill_Range then lowestHP = data.Humanoid.Health; lowestNPC = npc end
            end
        end
        for npc, data in pairs(State.ESPObjects) do
            if not npc.Parent or not data.Root or not data.Humanoid then continue end
            if data.Humanoid.Health > 0 and (playerRoot.Position - data.Root.Position).Magnitude <= Settings.NPC_Kill_Range then
                local shouldKill = false
                if Settings.NPC_Kill_Mode == "ALL" then shouldKill = true
                elseif Settings.NPC_Kill_Mode == "NEAREST" then shouldKill = (npc == nearestNPC)
                elseif Settings.NPC_Kill_Mode == "LOWEST_HP" then shouldKill = (npc == lowestNPC) end
                if shouldKill then killNPC(npc, Settings.NPC_Kill_Damage) end
            end
        end
    end
end)

task.spawn(function()
    while State.IsRunning and task.wait(0.1) do
        local char = LocalPlayer.Character; local playerRoot = char and getRootPart(char)
        for npc, data in pairs(State.ESPObjects) do
            if not npc.Parent then removeNPCESP(npc)
            else
                local hum, root = data.Humanoid, data.Root
                if not hum or not root then removeNPCESP(npc)
                else
                    local alive = hum.Health > 0
                    local dist = playerRoot and (playerRoot.Position - root.Position).Magnitude or math.huge
                    local visible = Settings.NPC_ESP
                    if dist > Settings.NPC_ESP_Range then visible = false end
                    if Settings.NPC_ESP_HideDead and not alive then visible = false end
                    data.Highlight.Enabled = visible; data.Billboard.Enabled = visible
                    if visible then
                        data.NameLabel.Visible = Settings.NPC_ESP_Name
                        if Settings.NPC_ESP_Name then data.NameLabel.Text = npc.Name end
                        data.HealthBG.Visible = Settings.NPC_ESP_Health
                        if Settings.NPC_ESP_Health then
                            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                            data.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
                            data.HealthFill.BackgroundColor3 = pct > 0.6 and Color3.fromRGB(50,255,100) or pct > 0.3 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,50,50)
                        end
                        data.InfoLabel.Visible = Settings.NPC_ESP_Distance and playerRoot ~= nil
                        if Settings.NPC_ESP_Distance and playerRoot then data.InfoLabel.Text = math.floor(dist) .. " studs" end
                    end
                end
            end
        end
    end
end)

-- ==================================================
-- GOD MODE / RESPAWN / AUTO F / AUTO CHOP
-- ==================================================

local function toggleGodMode()
    if State.GodModeConnection then State.GodModeConnection:Disconnect() State.GodModeConnection = nil end
    if not Settings.GodMode then return end
    State.GodModeConnection = RunService.RenderStepped:Connect(function()
        if not Settings.GodMode then return end
        local character = LocalPlayer.Character; if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = humanoid.MaxHealth end
    end)
end

local function toggleInstantRespawn()
    if not Settings.InstantRespawn then return end
    LocalPlayer.CharacterAdded:Connect(function(character)
        if not Settings.InstantRespawn then return end
        character:WaitForChild("Humanoid")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Died:Connect(function() task.wait(0.1) LocalPlayer:LoadCharacter() end) end
    end)
end

local function toggleAutoF()
    if State.AutoFConnection then State.AutoFConnection:Disconnect() State.AutoFConnection = nil end
    if not Settings.AutoF then return end
    State.AutoFConnection = RunService.RenderStepped:Connect(function()
        if not Settings.AutoF then return end
        local char = LocalPlayer.Character; if not char then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then pcall(function() if obj.Parent and (obj.Parent.Position - char:GetPivot().Position).Magnitude <= 10 then fireproximityprompt(obj) end end) end
        end
    end)
end

local function toggleAutoChop()
    if State.AutoChopConnection then State.AutoChopConnection:Disconnect() State.AutoChopConnection = nil end
    if not Settings.AutoChop then return end
    State.AutoChopConnection = RunService.RenderStepped:Connect(function()
        if not Settings.AutoChop then return end
        local char = LocalPlayer.Character; local playerRoot = char and getRootPart(char)
        if not playerRoot then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("tree") or obj.Name:lower():find("wood")) then
                local root = getRootPart(obj) or obj:FindFirstChildWhichIsA("BasePart")
                if root and (playerRoot.Position - root.Position).Magnitude < 10 then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
        end
    end)
end

local function toggleCombatPreview()
    if State.CombatConnection then State.CombatConnection:Disconnect() State.CombatConnection = nil end
    if not Settings.CombatPreview then return end
    State.CombatConnection = RunService.RenderStepped:Connect(function()
        if not Settings.CombatPreview then return end
        local char = LocalPlayer.Character; local playerRoot = char and getRootPart(char)
        if not playerRoot then return end
        for npc, data in pairs(State.ESPObjects) do
            if npc.Parent and data.Root then
                local dist = (playerRoot.Position - data.Root.Position).Magnitude
                data.Highlight.FillColor = dist <= Settings.CombatRange and Color3.fromRGB(255,50,50) or Color3.fromRGB(220,150,200)
            end
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJumpOrig then return end
    pcall(function() local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end)
end)

-- ==================================================
-- AUTO CLICK / FORCEFIELD / HITBOX / AUTO CLICK BALL
-- ==================================================
local acClickConn
local function isMouseOverUI()
    local mouse = LocalPlayer:GetMouse()
    local guis = CoreGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
    for _, g in guis do if g:IsA("ScreenGui") and (g.Name == "ouncopybara_Hub" or g.Name == "FlyButton") then return true end end
    return false
end
local function toggleAutoClick()
    if acClickConn then acClickConn:Disconnect() end
    if Settings.AutoClick then acClickConn = RunService.RenderStepped:Connect(function() if not isMouseOverUI() then VirtualUser:ClickButton1(Vector2.new(0,0)) end end) end
end

local function updateForceField()
    if Settings.ForceField and LocalPlayer.Character then
        if not LocalPlayer.Character:FindFirstChild("ForceField") then Instance.new("ForceField", LocalPlayer.Character) end
    elseif LocalPlayer.Character then
        local ff = LocalPlayer.Character:FindFirstChild("ForceField"); if ff then ff:Destroy() end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if Settings.HitboxSize > 2 then
            for _, plr in Players:GetPlayers() do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.Transparency = 0.7
                end
            end
        end
    end
end)

local ballConn; local lastBallClick = 0
local function clickBall()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(); VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end
local function toggleAutoClickBall()
    if ballConn then ballConn:Disconnect() end
    if Settings.AutoClickBall then
        ballConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
            local now = os.clock(); if now - lastBallClick < 0.3 then return end
            for _, part in Workspace:GetDescendants() do
                if part:IsA("BasePart") and part.Name:lower():find("ball") then
                    if (part.Position - root.Position).Magnitude <= Settings.BallDistance then
                        clickBall(); lastBallClick = now; break
                    end
                end
            end
        end)
    end
end

-- ==================================================
-- LOAD IMAGE
-- ==================================================
local function loadImage()
    local asset = ""
    pcall(function()
        if request and writefile and getcustomasset then
            local response = request({ Url = IMAGE_URL, Method = "GET" })
            if response and response.StatusCode == 200 then
                writefile("ouncopybara_bg.jpg", response.Body)
                asset = getcustomasset("ouncopybara_bg.jpg")
            end
        end
    end)
    return asset
end

-- ==================================================
-- CREATE UI
-- ==================================================

local function createUI(imageAsset)
    imageAsset = imageAsset or ""
    if CoreGui:FindFirstChild("ouncopybara_Hub") then CoreGui.ouncopybara_Hub:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ouncopybara_Hub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local Theme = {
        Background = Color3.fromRGB(12,12,18), Surface = Color3.fromRGB(20,20,29),
        Surface2 = Color3.fromRGB(27,27,38), Card = Color3.fromRGB(30,30,42),
        Text = Color3.fromRGB(245,245,250), SubText = Color3.fromRGB(150,150,165),
        Accent = Color3.fromRGB(220,150,200), Success = Color3.fromRGB(75,220,145),
        Warning = Color3.fromRGB(255,190,70), Error = Color3.fromRGB(240,80,100),
        Info = Color3.fromRGB(90,170,255), Stroke = Color3.fromRGB(65,65,82)
    }

    local function corner(obj, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = obj return c end
    local function stroke(obj, color, t, tr) local s = Instance.new("UIStroke") s.Color = color or Theme.Stroke s.Thickness = t or 1 s.Transparency = tr or 0 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Parent = obj return s end

    local NotificationHolder
    local NotificationColors = { Success = Theme.Success, Warning = Theme.Warning, Error = Theme.Error, Info = Theme.Info }
    local NotificationIcons = { Success = "✓", Warning = "!", Error = "×", Info = "i" }

    local function createNotificationHolder()
        if NotificationHolder and NotificationHolder.Parent then return NotificationHolder end
        NotificationHolder = Instance.new("Frame")
        NotificationHolder.Name = "NotificationHolder"
        NotificationHolder.AnchorPoint = Vector2.new(1, 0)
        NotificationHolder.Position = UDim2.new(1, -16, 0, 16)
        NotificationHolder.Size = UDim2.new(0, 340, 1, -32)
        NotificationHolder.BackgroundTransparency = 1
        NotificationHolder.ZIndex = 1000
        NotificationHolder.Parent = gui
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = NotificationHolder
        return NotificationHolder
    end

    local function notify(titleText, messageText, duration, notificationType)
        notificationType = notificationType or "Info"
        duration = tonumber(duration) or 3
        if not NotificationColors[notificationType] then notificationType = "Info" end
        local color = NotificationColors[notificationType]
        local iconText = NotificationIcons[notificationType]
        local holder = createNotificationHolder()
        local card = Instance.new("CanvasGroup")
        card.Size = UDim2.new(1, 0, 0, 78)
        card.BackgroundColor3 = Theme.Surface
        card.BackgroundTransparency = 0.03
        card.BorderSizePixel = 0
        card.GroupTransparency = 1
        card.ClipsDescendants = true
        card.LayoutOrder = -math.floor(os.clock() * 1000)
        card.ZIndex = 1001
        card.Parent = holder
        corner(card, 14); stroke(card, color, 1, 0.35)
        local accent = Instance.new("Frame"); accent.Size = UDim2.new(0, 4, 1, 0); accent.BackgroundColor3 = color; accent.ZIndex = 1002; accent.Parent = card; corner(accent, 8)
        local iconBox = Instance.new("Frame"); iconBox.Size = UDim2.fromOffset(38, 38); iconBox.Position = UDim2.fromOffset(12, 13); iconBox.BackgroundColor3 = color; iconBox.BackgroundTransparency = 0.82; iconBox.ZIndex = 1003; iconBox.Parent = card; corner(iconBox, 12); stroke(iconBox, color, 1, 0.5)
        local icon = Instance.new("TextLabel"); icon.Size = UDim2.fromScale(1, 1); icon.BackgroundTransparency = 1; icon.Text = iconText; icon.TextColor3 = color; icon.Font = Enum.Font.GothamBold; icon.TextSize = 18; icon.ZIndex = 1004; icon.Parent = iconBox
        local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -105, 0, 22); title.Position = UDim2.fromOffset(60, 9); title.BackgroundTransparency = 1; title.Text = tostring(titleText); title.TextColor3 = Theme.Text; title.Font = Enum.Font.GothamBold; title.TextSize = 11; title.ZIndex = 1004; title.Parent = card
        local message = Instance.new("TextLabel"); message.Size = UDim2.new(1, -105, 0, 28); message.Position = UDim2.fromOffset(60, 31); message.BackgroundTransparency = 1; message.Text = tostring(messageText); message.TextColor3 = Theme.SubText; message.Font = Enum.Font.GothamMedium; message.TextSize = 9; message.TextWrapped = true; message.ZIndex = 1004; message.Parent = card
        local close = Instance.new("TextButton"); close.Size = UDim2.fromOffset(25, 25); close.Position = UDim2.new(1, -31, 0, 7); close.BackgroundTransparency = 1; close.Text = "×"; close.TextColor3 = Theme.SubText; close.Font = Enum.Font.GothamBold; close.TextSize = 17; close.AutoButtonColor = false; close.ZIndex = 1005; close.Parent = card
        local progressBG = Instance.new("Frame"); progressBG.Size = UDim2.new(1, -20, 0, 3); progressBG.Position = UDim2.new(0, 10, 1, -7); progressBG.BackgroundColor3 = Theme.Surface2; progressBG.ZIndex = 1006; progressBG.Parent = card; corner(progressBG, 99)
        local progress = Instance.new("Frame"); progress.Size = UDim2.fromScale(1, 1); progress.BackgroundColor3 = color; progress.ZIndex = 1007; progress.Parent = progressBG; corner(progress, 99)
        local removed = false
        local function remove()
            if removed then return end; removed = true
            local tween = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
            tween:Play(); tween.Completed:Connect(function() if card and card.Parent then card:Destroy() end end)
        end
        close.MouseButton1Click:Connect(remove)
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
        TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()
        task.delay(duration, function() if card and card.Parent then remove() end end)
        return card
    end

    safeNotify = notify

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "ToggleButton"; toggleBtn.Size = UDim2.fromOffset(52, 52); toggleBtn.Position = UDim2.new(0, 18, 0.5, -26)
    toggleBtn.BackgroundColor3 = Theme.Surface; toggleBtn.Image = imageAsset ~= "" and imageAsset or DEFAULT_IMAGE; toggleBtn.ScaleType = Enum.ScaleType.Crop; toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = gui; corner(toggleBtn, 16); local toggleStroke = stroke(toggleBtn, Theme.Accent, 2)

    local main = Instance.new("CanvasGroup")
    main.Name = "Main"; main.AnchorPoint = Vector2.new(0.5, 0.5); main.Size = UDim2.new(0.9, 0, 0.9, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Theme.Background; main.GroupTransparency = 1; main.Visible = false; main.Active = true; main.ClipsDescendants = true
    main.Parent = gui; corner(main, 18); local mainStroke = stroke(main, Theme.Stroke, 1, 0.15)

    local bg = Instance.new("Frame"); bg.Size = UDim2.fromScale(1, 1); bg.BackgroundColor3 = Theme.Background; bg.ZIndex = 0; bg.Parent = main; corner(bg, 18)
    local bgGradient = Instance.new("UIGradient"); bgGradient.Rotation = 135; bgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(40,25,45)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(12,12,18)), ColorSequenceKeypoint.new(1, Color3.fromRGB(18,20,35))}); bgGradient.Parent = bg

    local header = Instance.new("Frame"); header.Size = UDim2.new(1, -24, 0, 62); header.Position = UDim2.fromOffset(12, 10); header.BackgroundColor3 = Theme.Surface; header.ZIndex = 10; header.Parent = main; corner(header, 14); stroke(header, Theme.Stroke, 1, 0.45)
    local headerIcon = Instance.new("ImageLabel"); headerIcon.Size = UDim2.fromOffset(42, 42); headerIcon.Position = UDim2.fromOffset(10, 10); headerIcon.BackgroundColor3 = Theme.Card; headerIcon.Image = imageAsset ~= "" and imageAsset or DEFAULT_IMAGE; headerIcon.ScaleType = Enum.ScaleType.Crop; headerIcon.ZIndex = 11; headerIcon.Parent = header; corner(headerIcon, 12); local iconStroke = stroke(headerIcon, Theme.Accent, 1.5)
    local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -115, 0, 25); title.Position = UDim2.fromOffset(62, 7); title.BackgroundTransparency = 1; title.Text = "ouncopybara"; title.TextColor3 = Theme.Text; title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.ZIndex = 11; title.Parent = header
    local subtitle = Instance.new("TextLabel"); subtitle.Size = UDim2.new(1, -115, 0, 20); subtitle.Position = UDim2.fromOffset(63, 32); subtitle.BackgroundTransparency = 1; subtitle.Text = "VIP • v8.0 • ALL FEATURES"; subtitle.TextColor3 = Theme.SubText; subtitle.Font = Enum.Font.GothamMedium; subtitle.TextSize = 9; subtitle.ZIndex = 11; subtitle.Parent = header
    local minimizeBtn = Instance.new("TextButton"); minimizeBtn.Size = UDim2.fromOffset(34, 34); minimizeBtn.Position = UDim2.new(1, -44, 0, 14); minimizeBtn.BackgroundColor3 = Theme.Card; minimizeBtn.Text = "—"; minimizeBtn.TextColor3 = Theme.Text; minimizeBtn.Font = Enum.Font.GothamBold; minimizeBtn.TextSize = 16; minimizeBtn.AutoButtonColor = false; minimizeBtn.ZIndex = 12; minimizeBtn.Parent = header; corner(minimizeBtn, 10); stroke(minimizeBtn, Theme.Stroke, 1)

    local status = Instance.new("Frame"); status.Size = UDim2.new(1, -24, 0, 28); status.Position = UDim2.fromOffset(12, 78); status.BackgroundColor3 = Theme.Surface; status.ZIndex = 10; status.Parent = main; corner(status, 9)
    local statusDot = Instance.new("Frame"); statusDot.Size = UDim2.fromOffset(7, 7); statusDot.Position = UDim2.fromOffset(11, 10); statusDot.BackgroundColor3 = Theme.Success; statusDot.ZIndex = 11; statusDot.Parent = status; corner(statusDot, 99)
    local statusText = Instance.new("TextLabel"); statusText.Size = UDim2.new(1, -30, 1, 0); statusText.Position = UDim2.fromOffset(26, 0); statusText.BackgroundTransparency = 1; statusText.Text = "SYSTEM READY"; statusText.TextColor3 = Theme.SubText; statusText.Font = Enum.Font.GothamMedium; statusText.TextSize = 9; statusText.ZIndex = 11; statusText.Parent = status

    local body = Instance.new("Frame"); body.Size = UDim2.new(1, -24, 1, -120); body.Position = UDim2.fromOffset(12, 112); body.BackgroundTransparency = 1; body.Parent = main

    local sidebar = Instance.new("ScrollingFrame"); sidebar.Size = UDim2.new(0, 96, 1, 0); sidebar.BackgroundColor3 = Theme.Surface; sidebar.ZIndex = 10; sidebar.Parent = body; corner(sidebar, 14); stroke(sidebar, Theme.Stroke, 1, 0.5); sidebar.ScrollBarThickness = 2; sidebar.ScrollBarImageColor3 = Theme.Accent; sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local sideLayout = Instance.new("UIListLayout"); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; sideLayout.SortOrder = Enum.SortOrder.LayoutOrder; sideLayout.Parent = sidebar
    local sidePad = Instance.new("UIPadding"); sidePad.PaddingTop = UDim.new(0, 8); sidePad.PaddingLeft = UDim.new(0, 7); sidePad.PaddingRight = UDim.new(0, 7); sidePad.Parent = sidebar

    local contentFrame = Instance.new("Frame"); contentFrame.Size = UDim2.new(1, -106, 1, 0); contentFrame.Position = UDim2.fromOffset(106, 0); contentFrame.BackgroundColor3 = Theme.Surface; contentFrame.Parent = body; corner(contentFrame, 14); stroke(contentFrame, Theme.Stroke, 1, 0.5)

    local tabs = {
        {"Move","MOVE"},{"Combat","FIGHT"},{"Farm","FARM"},{"VIP","VIP"},
        {"Visual","VIEW"},{"Util","UTIL"},{"ESP","ESP"},{"NPC","KILL"},{"Ctrl","CTRL"}
    }
    local tabContainers = {}; local tabButtons = {}

    for index, info in ipairs(tabs) do
        local tabName, tabText = info[1], info[2]
        local btn = Instance.new("TextButton"); btn.Name = tabName .. "Tab"; btn.Size = UDim2.new(1, 0, 0, 34); btn.BackgroundColor3 = Theme.Card; btn.BackgroundTransparency = 0.65; btn.Text = tabText; btn.TextColor3 = Theme.SubText; btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.AutoButtonColor = false; btn.LayoutOrder = index; btn.ZIndex = 11; btn.Parent = sidebar; corner(btn, 9)
        local indicator = Instance.new("Frame"); indicator.Size = UDim2.fromOffset(3, 18); indicator.Position = UDim2.new(0, 0, 0.5, -9); indicator.BackgroundColor3 = Theme.Accent; indicator.ZIndex = 12; indicator.Parent = btn; corner(indicator, 5)
        tabButtons[tabName] = { Button = btn, Indicator = indicator }
        local container = Instance.new("ScrollingFrame"); container.Name = tabName .. "Container"; container.Size = UDim2.new(1, -12, 1, -12); container.Position = UDim2.fromOffset(6, 6); container.BackgroundTransparency = 1; container.ScrollBarThickness = 2; container.ScrollBarImageColor3 = Theme.Accent; container.AutomaticCanvasSize = Enum.AutomaticSize.Y; container.Visible = false; container.Active = true; container.Interactable = true; container.Parent = contentFrame
        local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 7); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = container
        local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 6); p.PaddingRight = UDim.new(0, 6); p.PaddingTop = UDim.new(0, 6); p.PaddingBottom = UDim.new(0, 6); p.Parent = container
        tabContainers[tabName] = container
        btn.MouseButton1Click:Connect(function()
            for name, c in pairs(tabContainers) do c.Visible = false; local b = tabButtons[name]; b.Button.BackgroundTransparency = 0.65; b.Button.TextColor3 = Theme.SubText; b.Indicator.BackgroundTransparency = 1 end
            container.Visible = true; btn.BackgroundColor3 = Theme.Accent; btn.BackgroundTransparency = 0.82; btn.TextColor3 = Theme.Text; indicator.BackgroundTransparency = 0; playBeep()
        end)
    end

    local function addSection(container, text) local section = Instance.new("TextLabel"); section.Size = UDim2.new(1, 0, 0, 24); section.BackgroundTransparency = 1; section.Text = "  " .. string.upper(text); section.TextColor3 = Theme.Accent; section.Font = Enum.Font.GothamBold; section.TextSize = 10; section.TextXAlignment = Enum.TextXAlignment.Left; section.Parent = container; return section end

    local function addToggle(container, text, default, callback)
        local card = Instance.new("TextButton"); card.Size = UDim2.new(1, 0, 0, 44); card.BackgroundColor3 = Theme.Card; card.Text = ""; card.AutoButtonColor = false; card.Parent = container; corner(card, 11); stroke(card, Theme.Stroke, 1, 0.65)
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -70, 1, 0); label.Position = UDim2.fromOffset(13, 0); label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Theme.Text; label.Font = Enum.Font.GothamMedium; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = card
        local switch = Instance.new("Frame"); switch.Size = UDim2.fromOffset(38, 20); switch.Position = UDim2.new(1, -51, 0.5, -10); switch.BackgroundColor3 = default and Theme.Accent or Theme.Surface2; switch.Parent = card; corner(switch, 99)
        local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(16, 16); knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2); knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.Parent = switch; corner(knob, 99)
        local state = default
        local function refresh() TweenService:Create(switch, TweenInfo.new(0.18), { BackgroundColor3 = state and Theme.Accent or Theme.Surface2 }):Play(); TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2) }):Play() end
        card.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then state = not state; refresh(); playBeep(); pcall(callback, state) end end)
        return card
    end

    local function addButton(container, text, callback)
        local button = Instance.new("TextButton"); button.Size = UDim2.new(1, 0, 0, 42); button.BackgroundColor3 = Theme.Card; button.Text = text; button.TextColor3 = Theme.Text; button.Font = Enum.Font.GothamBold; button.TextSize = 10; button.AutoButtonColor = false; button.Parent = container; corner(button, 11); stroke(button, Theme.Stroke, 1, 0.6)
        button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Surface2 }):Play() end)
        button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Card }):Play() end)
        button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then playBeep(); pcall(callback) end end)
        return button
    end

    local function addTextBox(container, labelText, default, callback)
        local card = Instance.new("Frame"); card.Size = UDim2.new(1, 0, 0, 48); card.BackgroundColor3 = Theme.Card; card.Parent = container; corner(card, 11); stroke(card, Theme.Stroke, 1, 0.65)
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(0.42, 0, 1, 0); label.Position = UDim2.fromOffset(13, 0); label.BackgroundTransparency = 1; label.Text = labelText; label.TextColor3 = Theme.Text; label.Font = Enum.Font.GothamMedium; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = card
        local box = Instance.new("TextBox"); box.Size = UDim2.new(0.48, 0, 0, 30); box.Position = UDim2.new(0.48, 0, 0.5, -15); box.BackgroundColor3 = Theme.Surface2; box.Text = tostring(default or ""); box.TextColor3 = Theme.Text; box.Font = Enum.Font.GothamMedium; box.TextSize = 10; box.ClearTextOnFocus = false; box.TextXAlignment = Enum.TextXAlignment.Center; box.Parent = card; corner(box, 8); stroke(box, Theme.Stroke, 1, 0.4)
        box.FocusLost:Connect(function() pcall(callback, box.Text) end)
        return box
    end

    -- MOVE
    addSection(tabContainers.Move, "Movement")
    addToggle(tabContainers.Move, "Fly", false, function(v) Settings.Fly = v; if v then startFly() else stopFly() end end)
    addTextBox(tabContainers.Move, "Fly Speed", "120", function(v) Settings.FlySpeed = tonumber(v) or 120 end)
    addToggle(tabContainers.Move, "Boost Mode", false, function(v) Settings.BoostMode = v end)
    addToggle(tabContainers.Move, "Noclip", false, function(v) Settings.Noclip = v; toggleNoclip() end)
    addTextBox(tabContainers.Move, "Speed Mult", "1", function(v) Settings.SpeedBoostMultiplier = tonumber(v) or 1; updateWalkSpeed() end)
    addToggle(tabContainers.Move, "Infinite Jump", false, function(v) Settings.InfiniteJumpOrig = v; notify("Infinite Jump", v and "Enabled" or "Disabled", 2) end)

    -- COMBAT
    addSection(tabContainers.Combat, "Combat")
    addToggle(tabContainers.Combat, "Kill Aura", false, function(v) Settings.KillAura = v; toggleKillAura() end)
    addTextBox(tabContainers.Combat, "KA Range", "30", function(v) Settings.KillAuraRange = tonumber(v) or 30 end)
    addTextBox(tabContainers.Combat, "KA Damage", "30", function(v) Settings.KillAuraDamage = tonumber(v) or 30 end)
    addToggle(tabContainers.Combat, "KA NPCs", false, function(v) Settings.KillAuraNPC = v end)
    addToggle(tabContainers.Combat, "Hitbox", false, function(v) Settings.HitboxSize = v and 10 or 2 end)
    addToggle(tabContainers.Combat, "AutoClick", false, function(v) Settings.AutoClick = v; toggleAutoClick() end)
    addToggle(tabContainers.Combat, "ForceField", false, function(v) Settings.ForceField = v; updateForceField() end)
    addToggle(tabContainers.Combat, "Auto Click Ball", false, function(v) Settings.AutoClickBall = v; toggleAutoClickBall() end)
    addTextBox(tabContainers.Combat, "Ball Distance", "5", function(v) Settings.BallDistance = tonumber(v) or 5 end)

    -- FARM
    addSection(tabContainers.Farm, "Farming")
    addToggle(tabContainers.Farm, "Kill Mobs", false, function(v) Settings.KillMobs = v; toggleKillMobs() end)
    addToggle(tabContainers.Farm, "Auto Chop", false, function(v) Settings.AutoChop = v; toggleAutoChop() end)
    addTextBox(tabContainers.Farm, "Walk Speed", "16", function(v) local val = tonumber(v); if val then Settings.WalkSpeedDirect = math.clamp(val, 16, 500); updateWalkSpeed() end end)

    -- VIP
    addSection(tabContainers.VIP, "VIP Tools")
    addButton(tabContainers.VIP, "Teleport to Mouse", function()
        local mouse = LocalPlayer:GetMouse(); local target = mouse.Hit.p
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target)
        end
    end)
    addButton(tabContainers.VIP, "Heal", function()
        local c = LocalPlayer.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.Health = h.MaxHealth; notify("Heal", "Done", 2, "Success") else notify("Heal", "No character", 3, "Warning") end
    end)
    addButton(tabContainers.VIP, "VIP Speed", function() Settings.SpeedBoostMultiplier = 100/16; updateWalkSpeed(); notify("Speed", "VIP Speed ON", 2, "Success") end)
    addButton(tabContainers.VIP, "Reset Speed", function() Settings.SpeedBoostMultiplier = 1; updateWalkSpeed(); notify("Speed", "Reset", 2, "Info") end)
    addButton(tabContainers.VIP, "Spawn Cash", function()
        if ReplicatedStorage:FindFirstChild("AddMoney") then ReplicatedStorage.AddMoney:FireServer(999999) end
        notify("Cash", "សាកល្បង", 2)
    end)
    addToggle(tabContainers.VIP, "Player ESP", false, function(v) Settings.PlayerESP = v; updateESP() end)
    addToggle(tabContainers.VIP, "God Mode", false, function(v) Settings.GodMode = v; toggleGodMode() end)
    addToggle(tabContainers.VIP, "Instant Respawn", false, function(v) Settings.InstantRespawn = v; toggleInstantRespawn() end)

    local killBox = Instance.new("TextBox"); killBox.Size = UDim2.new(1, -10, 0, 28); killBox.Position = UDim2.new(0, 5, 0, #tabContainers.VIP:GetChildren()*32+5); killBox.BackgroundColor3 = Color3.fromRGB(50,50,50); killBox.TextColor3 = Color3.new(1,1,1); killBox.PlaceholderText = "ឈ្មោះគោលដៅ (Kill)"; killBox.Font = Enum.Font.Gotham; killBox.TextSize = 12; killBox.Parent = tabContainers.VIP; corner(killBox, 4)
    addButton(tabContainers.VIP, "KILL (FE)", function() executeFEKill(killBox.Text) end)

    local flingBox = Instance.new("TextBox"); flingBox.Size = UDim2.new(1, -10, 0, 28); flingBox.Position = UDim2.new(0, 5, 0, #tabContainers.VIP:GetChildren()*32+5); flingBox.BackgroundColor3 = Color3.fromRGB(50,50,50); flingBox.TextColor3 = Color3.new(1,1,1); flingBox.PlaceholderText = "ឈ្មោះគោលដៅ (Fling)"; flingBox.Font = Enum.Font.Gotham; flingBox.TextSize = 12; flingBox.Parent = tabContainers.VIP; corner(flingBox, 4)
    addButton(tabContainers.VIP, "FLING", function() executeFling(flingBox.Text) end)
    addToggle(tabContainers.VIP, "Fling All", false, function(v) Settings.FlingAll = v; if v then flingAllPlayers() end end)

    -- VISUAL
    addSection(tabContainers.Visual, "Visual")
    addTextBox(tabContainers.Visual, "FOV", "70", function(v) local val = math.clamp(tonumber(v) or 70, 70, 120); if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = val end end)
    addToggle(tabContainers.Visual, "Full Bright", false, function(v)
        Settings.FullBright = v
        if v then Lighting.Brightness = 2; Lighting.ClockTime = 12; Lighting.FogEnd = 100000
        else Lighting.Brightness = 0.5; Lighting.ClockTime = 0; Lighting.FogEnd = 1000 end
    end)

    -- ESP
    addSection(tabContainers.ESP, "NPC ESP")
    addToggle(tabContainers.ESP, "NPC ESP", false, function(v) Settings.NPC_ESP = v end)
    addToggle(tabContainers.ESP, "Show Name", true, function(v) Settings.NPC_ESP_Name = v end)
    addToggle(tabContainers.ESP, "Show Health", true, function(v) Settings.NPC_ESP_Health = v end)
    addToggle(tabContainers.ESP, "Show Distance", true, function(v) Settings.NPC_ESP_Distance = v end)
    addToggle(tabContainers.ESP, "Hide Dead", true, function(v) Settings.NPC_ESP_HideDead = v end)
    addTextBox(tabContainers.ESP, "ESP Range", "200", function(v) Settings.NPC_ESP_Range = tonumber(v) or 200 end)

    -- NPC KILLER
    addSection(tabContainers.NPC, "NPC Killer")
    addToggle(tabContainers.NPC, "🎯 NPC Killer", false, function(v) Settings.NPC_Killer = v; notify("NPC Killer", v and "ON" or "OFF", 2) end)
    addToggle(tabContainers.NPC, "📡 Use Remotes", true, function(v) Settings.NPC_Kill_UseRemotes = v end)
    addToggle(tabContainers.NPC, "🔫 Use Raycast", true, function(v) Settings.NPC_Kill_UseRaycast = v end)
    addTextBox(tabContainers.NPC, "Kill Range", "50", function(v) Settings.NPC_Kill_Range = tonumber(v) or 50 end)
    addTextBox(tabContainers.NPC, "Damage", "30", function(v) Settings.NPC_Kill_Damage = tonumber(v) or 30 end)
    addButton(tabContainers.NPC, "Mode: " .. Settings.NPC_Kill_Mode, function()
        if Settings.NPC_Kill_Mode == "ALL" then Settings.NPC_Kill_Mode = "NEAREST"
        elseif Settings.NPC_Kill_Mode == "NEAREST" then Settings.NPC_Kill_Mode = "LOWEST_HP"
        else Settings.NPC_Kill_Mode = "ALL" end
        notify("Mode", Settings.NPC_Kill_Mode, 2)
    end)

    -- UTIL
    addSection(tabContainers.Util, "Utilities")
    addButton(tabContainers.Util, "Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    addButton(tabContainers.Util, "Server Hop", function()
        local json = HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
        local ids = {}
        for _, v in json.data do if v.playing and v.id ~= game.JobId then table.insert(ids, v.id) end end
        if #ids > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, ids[math.random(#ids)], LocalPlayer) else notify("Hop", "រកមិនឃើញ", 3) end
    end)
    addToggle(tabContainers.Util, "Auto F", false, function(v) Settings.AutoF = v; toggleAutoF() end)

    -- CTRL (VIP FREEZE V2.0 + NUCLEAR)
    addSection(tabContainers.Ctrl, "VIP Freeze V2.0")
    addToggle(tabContainers.Ctrl, "🧊 Freeze Hold", false, function(v) Settings.VIPFreezeHold = v; toggleVIPFreezeHold(); notify("Freeze Hold", v and "ON" or "OFF", 2) end)
    addToggle(tabContainers.Ctrl, "💀 Freeze Kill", false, function(v) Settings.VIPFreezeKill = v; toggleVIPFreezeKill(); notify("Freeze Kill", v and "ON" or "OFF", 2) end)
    addTextBox(tabContainers.Ctrl, "Freeze Range", "50", function(v) Settings.VIPFreeze_Range = tonumber(v) or 50 end)
    addButton(tabContainers.Ctrl, "☢️ NUKE ALL NPCs", function()
        local char = LocalPlayer.Character; local playerRoot = char and getRootPart(char)
        if not playerRoot then notify("NUKE", "No character", 3, "Error") return end
        local range = Settings.VIPFreeze_Range or 50; local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isValidNPC(obj) then
                local npcRoot = getRootPart(obj)
                if npcRoot and (playerRoot.Position - npcRoot.Position).Magnitude <= range then
                    nuclearFreeze(obj); count = count + 1
                end
            end
        end
        notify("☢️ NUKE", "Destroyed " .. count .. " NPCs", 3, "Success")
    end)

    local footer = Instance.new("TextLabel"); footer.Size = UDim2.new(1, -24, 0, 18); footer.Position = UDim2.new(0, 12, 1, -22); footer.BackgroundTransparency = 1; footer.Text = "ouncopybara • VIP • ALL FEATURES"; footer.TextColor3 = Theme.SubText; footer.Font = Enum.Font.GothamMedium; footer.TextSize = 8; footer.TextXAlignment = Enum.TextXAlignment.Center; footer.ZIndex = 20; footer.Parent = main

    tabContainers.Move.Visible = true; tabButtons.Move.Button.BackgroundColor3 = Theme.Accent; tabButtons.Move.Button.BackgroundTransparency = 0.82; tabButtons.Move.Button.TextColor3 = Theme.Text; tabButtons.Move.Indicator.BackgroundTransparency = 0

    local function openUI()
        main.Visible = true; main.GroupTransparency = 1
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.25), { Rotation = 180 }):Play()
    end
    local function closeUI()
        local tween = TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
        tween:Play(); TweenService:Create(toggleBtn, TweenInfo.new(0.22), { Rotation = 0 }):Play(); tween.Completed:Wait(); main.Visible = false
    end

    local restoreButton
    local function minimizeUI()
        main.Visible = false
        if restoreButton then return end
        restoreButton = Instance.new("TextButton"); restoreButton.Size = UDim2.fromOffset(48, 48); restoreButton.Position = UDim2.fromScale(0.5, 0.5); restoreButton.AnchorPoint = Vector2.new(0.5, 0.5); restoreButton.BackgroundColor3 = Theme.Surface; restoreButton.Text = "oun"; restoreButton.TextColor3 = Theme.Text; restoreButton.Font = Enum.Font.GothamBold; restoreButton.TextSize = 12; restoreButton.AutoButtonColor = false; restoreButton.ZIndex = 100; restoreButton.Parent = gui; corner(restoreButton, 14); stroke(restoreButton, Theme.Accent, 2)
        restoreButton.MouseButton1Click:Connect(function() restoreButton:Destroy(); restoreButton = nil; openUI() end)
    end
    minimizeBtn.MouseButton1Click:Connect(minimizeUI)

    local function makeDraggable(handle, frame) local dragging, dragStart, startPos = false, nil, nil
        handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = frame.Position end end)
        UserInputService.InputChanged:Connect(function(input) if not dragging then return end; if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    end
    makeDraggable(header, main)

    local toggleDragging, toggleMoved, toggleStart, toggleStartPosition = false, false, nil, nil
    toggleBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then toggleDragging = true; toggleMoved = false; toggleStart = input.Position; toggleStartPosition = toggleBtn.Position end end)
    UserInputService.InputChanged:Connect(function(input) if not toggleDragging then return end; if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then local delta = input.Position - toggleStart; if delta.Magnitude > 5 then toggleMoved = true end; toggleBtn.Position = UDim2.new(toggleStartPosition.X.Scale, toggleStartPosition.X.Offset + delta.X, toggleStartPosition.Y.Scale, toggleStartPosition.Y.Offset + delta.Y) end end)
    toggleBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if not toggleMoved then if main.Visible then closeUI() else openUI() end end; toggleDragging = false end end)

    task.spawn(function() while gui.Parent do local hue = (os.clock() * 0.18) % 1; local rainbow = Color3.fromHSV(hue, 0.8, 1); mainStroke.Color = rainbow; toggleStroke.Color = rainbow; iconStroke.Color = rainbow; title.TextColor3 = rainbow; task.wait(0.04) end end)

    main.Visible = false; main.GroupTransparency = 1
    scanNPCs(); scanPlayers()
    Workspace.DescendantAdded:Connect(function(obj) if obj:IsA("Model") then task.wait(0.1); if isValidNPC(obj) then createNPCESP(obj) end end)
    Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function() task.wait(0.5); if Settings.PlayerESP then createPlayerESP(player) end end) end)
    task.delay(0.5, function() notify("ouncopybara", "All Features Restored! v8.0", 3, "Success") end)
    print("✅ ouncopybara - ALL FEATURES RESTORED!")
end

task.spawn(function()
    local image = loadImage()
    createUI(image)
end)

game:BindToClose(function()
    State.IsRunning = false
    if State.FlyConnection then State.FlyConnection:Disconnect() end
    if State.NoclipConnection then State.NoclipConnection:Disconnect() end
    if State.GodModeConnection then State.GodModeConnection:Disconnect() end
    if State.AutoFConnection then State.AutoFConnection:Disconnect() end
    if State.FreezeConnection then State.FreezeConnection:Disconnect() end
    if State.AutoChopConnection then State.AutoChopConnection:Disconnect() end
    if State.CombatConnection then State.CombatConnection:Disconnect() end
    if State.KillAuraConnection then State.KillAuraConnection:Disconnect() end
    if State.KillMobsConnection then State.KillMobsConnection:Disconnect() end
    if acClickConn then acClickConn:Disconnect() end
    if ballConn then ballConn:Disconnect() end
end)