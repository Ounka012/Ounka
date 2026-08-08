--[[
    MKRA Hub VIP v4.2 – Mobile Optimized
    Image/Fallback Fixed
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- =========================================================
-- SETTINGS
-- =========================================================

local Settings = {
    Fly = false,
    FlySpeed = 120,
    BoostMode = false,

    InfiniteJumpOrig = false,
    InfiniteJump99 = false,

    HitboxSize = 2,
    AutoClick = false,
    ForceField = false,
    ESP = false,
    Noclip = false,

    SpeedBoostMultiplier = 1,
    WalkSpeedDirect = 16,

    GodMode = false,
    InstantRespawn = false,

    KillAura = false,
    KillAuraRange = 30,
    KillAuraDamage = 30,
    KillAuraNPC = false,
    KillAuraRemote = "",
    KillAuraRemoteArgs = "target,damage",

    KillMobs = false,
    AutoChop = false,
    FlingAll = false,

    AutoClickBall = false,
    BallDistance = 5,

    AutoF = false,
    AutoFPaused = false,

    NPC_ESP = false,
    NPC_ESP_Name = true,
    NPC_ESP_Health = true,
    NPC_ESP_Distance = true,
    NPC_ESP_HideDead = true,
    NPC_ESP_Range = 200,

    VIPFreezeHold = false,
    VIPFreezeKill = false,
}

-- =========================================================
-- IMAGE SETTINGS
-- =========================================================

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"

-- Fallback Roblox image.
-- បើ URL ខាងលើមិនអាច download បាន នឹងប្រើរូបនេះជំនួស។
local FALLBACK_IMAGE = "rbxassetid://7733960981"

local ACCENT = Color3.fromRGB(220, 150, 200)

-- =========================================================
-- NOTIFICATION
-- =========================================================

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- =========================================================
-- IMAGE LOADER
-- =========================================================

local function loadImage()
    local asset = FALLBACK_IMAGE

    -- Try executor request + writefile + getcustomasset
    pcall(function()

        if typeof(request) ~= "function" then
            return
        end

        if typeof(writefile) ~= "function" then
            return
        end

        if typeof(getcustomasset) ~= "function" then
            return
        end

        local response = request({
            Url = IMAGE_URL,
            Method = "GET"
        })

        if response
            and response.StatusCode == 200
            and response.Body
            and #response.Body > 0 then

            local fileName = "mkra_vip_bg.jpg"

            writefile(fileName, response.Body)

            local customAsset = getcustomasset(fileName)

            if customAsset and customAsset ~= "" then
                asset = customAsset
            end
        end
    end)

    return asset
end

-- =========================================================
-- NPC UTILITIES
-- =========================================================

local function getAllNPCs()
    local npcs = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then

            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")

            if hum
                and root
                and hum.Health > 0
                and not Players:GetPlayerFromCharacter(obj) then

                table.insert(npcs, obj)
            end
        end
    end

    return npcs
end

local function destroyAllNPCs()
    for _, npc in ipairs(getAllNPCs()) do
        pcall(function()
            npc:Destroy()
        end)
    end
end

-- =========================================================
-- VIP FREEZE HOLD
-- =========================================================

local freezeHoldRender
local freezeHoldConn
local frozenNPCs = {}

local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function addFreezeNPC(model)
    if frozenNPCs[model] then
        return
    end

    local root = getRoot(model)

    if root then
        pcall(function()
            root:SetNetworkOwner(LocalPlayer)
        end)

        frozenNPCs[model] = {
            root = root,
            cframe = root.CFrame
        }

        local hum = model:FindFirstChildOfClass("Humanoid")

        if hum then
            hum.WalkSpeed = 0
        end
    end
end

local function toggleVIPFreezeHold()

    if freezeHoldRender then
        freezeHoldRender:Disconnect()
        freezeHoldRender = nil
    end

    if freezeHoldConn then
        freezeHoldConn:Disconnect()
        freezeHoldConn = nil
    end

    table.clear(frozenNPCs)

    if not Settings.VIPFreezeHold then
        notify("VIP Freeze Hold", "Disabled", 2)
        return
    end

    for _, npc in ipairs(getAllNPCs()) do
        addFreezeNPC(npc)
    end

    freezeHoldConn = Workspace.DescendantAdded:Connect(function(obj)

        if not Settings.VIPFreezeHold then
            return
        end

        if obj:IsA("Model") then

            task.wait(0.05)

            if obj:FindFirstChildOfClass("Humanoid")
                and not Players:GetPlayerFromCharacter(obj) then

                addFreezeNPC(obj)
            end
        end
    end)

    freezeHoldRender = RunService.RenderStepped:Connect(function()

        for model, data in pairs(frozenNPCs) do

            if not model.Parent then
                frozenNPCs[model] = nil
                continue
            end

            local root = data.root

            if root and root.Parent then
                root.CFrame = data.cframe
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
        end
    end)

    notify("VIP Freeze Hold", "Trying to freeze all NPCs...", 3)
end

-- =========================================================
-- VIP FREEZE KILL
-- =========================================================

local vipKillConn

local function toggleVIPFreezeKill()

    if vipKillConn then
        vipKillConn:Disconnect()
        vipKillConn = nil
    end

    if not Settings.VIPFreezeKill then
        notify("VIP Freeze Kill", "Disabled", 2)
        return
    end

    destroyAllNPCs()

    vipKillConn = RunService.Heartbeat:Connect(function()
        destroyAllNPCs()
    end)

    notify("VIP Freeze Kill", "All NPCs are being eliminated!", 3)
end

-- =========================================================
-- FLY
-- =========================================================

local flyConnection
local bodyVelocity
local bodyGyro

local function startFly()

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
    end

    if bodyGyro then
        bodyGyro:Destroy()
    end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    humanoid.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function()

        if not Settings.Fly then
            return
        end

        if not bodyVelocity or not bodyVelocity.Parent then
            return
        end

        local moveDir = humanoid.MoveDirection
        local speed = Settings.FlySpeed

        if Settings.BoostMode then
            speed *= 2.5
        end

        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir * speed
        else
            bodyVelocity.Velocity = Vector3.zero
        end

        if Workspace.CurrentCamera then
            bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
        end
    end)
end

local function stopFly()

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    local char = LocalPlayer.Character

    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum then
            hum.PlatformStand = false
        end
    end
end

-- =========================================================
-- GOD MODE
-- =========================================================

local godCons = {}

local function disconnectGodMode()
    for _, c in ipairs(godCons) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(godCons)
end

local function connectGodChar(char)

    local hum = char:WaitForChild("Humanoid", 5)

    if not hum then
        return
    end

    local c1 = hum:GetPropertyChangedSignal("Health"):Connect(function()

        if Settings.GodMode
            and hum.Health > 0
            and hum.Health < hum.MaxHealth then

            hum.Health = hum.MaxHealth
        end
    end)

    table.insert(godCons, c1)
end

local function toggleGodMode()

    disconnectGodMode()

    if not Settings.GodMode then
        return
    end

    if LocalPlayer.Character then
        connectGodChar(LocalPlayer.Character)
    end

    table.insert(
        godCons,
        LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.2)
            if Settings.GodMode then
                connectGodChar(char)
            end
        end)
    )
end

-- =========================================================
-- INSTANT RESPAWN
-- =========================================================

local respawnCons = {}

local function toggleInstantRespawn()

    for _, c in ipairs(respawnCons) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(respawnCons)

    if not Settings.InstantRespawn then
        return
    end

    local connection = LocalPlayer.CharacterAdded:Connect(function(char)

        local hum = char:WaitForChild("Humanoid", 5)

        if not hum then
            return
        end

        local deathConnection = hum.Died:Connect(function()

            task.wait(0.1)

            if Settings.InstantRespawn then
                pcall(function()
                    LocalPlayer:LoadCharacter()
                end)
            end
        end)

        table.insert(respawnCons, deathConnection)
    end)

    table.insert(respawnCons, connection)
end

-- =========================================================
-- REMOTE SCANNER
-- =========================================================

local cachedRemotes = {}

local function findPossibleRemotes()

    if #cachedRemotes > 0 then
        return cachedRemotes
    end

    local possibleNames = {
        "Damage",
        "Hit",
        "Sword",
        "Attack",
        "DealDamage",
        "Hurt",
        "Slash",
        "Fire",
        "Punch",
        "WeaponDamage"
    }

    local allRemotes = {}

    local function scan(container)

        for _, obj in ipairs(container:GetDescendants()) do

            if obj:IsA("RemoteEvent") then

                for _, name in ipairs(possibleNames) do

                    if obj.Name:lower():find(name:lower()) then
                        table.insert(allRemotes, obj)
                        break
                    end
                end
            end
        end
    end

    scan(ReplicatedStorage)
    scan(Workspace)

    if #allRemotes == 0 then
        scan(ReplicatedStorage)
        scan(Workspace)

        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(allRemotes, obj)
            end
        end
    end

    cachedRemotes = allRemotes

    return allRemotes
end

local function damageNPC_Universal(targetHum, targetRoot, damage, npcModel)

    local remotes = findPossibleRemotes()

    for _, remote in ipairs(remotes) do

        pcall(function()
            remote:FireServer(targetHum)
        end)

        pcall(function()
            remote:FireServer(targetHum, damage)
        end)

        pcall(function()
            remote:FireServer(targetRoot, damage)
        end)

        if targetHum.Health <= 0
            or not npcModel.Parent then

            return true
        end
    end

    pcall(function()
        targetHum:TakeDamage(damage)
    end)

    if targetHum.Health <= 0
        or not npcModel.Parent then

        return true
    end

    pcall(function()
        targetHum.Health = math.max(
            0,
            targetHum.Health - damage
        )
    end)

    if targetHum.Health <= 0
        or not npcModel.Parent then

        return true
    end

    pcall(function()
        npcModel:Destroy()
    end)

    return true
end

-- =========================================================
-- KILL AURA
-- =========================================================

local kaConn

local function getRemote()

    if Settings.KillAuraRemote == "" then
        return nil
    end

    local remote = ReplicatedStorage:FindFirstChild(
        Settings.KillAuraRemote
    )

    if remote then
        return remote
    end

    remote = LocalPlayer:FindFirstChild(
        Settings.KillAuraRemote
    )

    if remote then
        return remote
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do

        if obj:IsA("RemoteEvent")
            and obj.Name == Settings.KillAuraRemote then

            return obj
        end
    end

    return nil
end

local function getTargets()

    local targets = {}

    for _, plr in ipairs(Players:GetPlayers()) do

        if plr ~= LocalPlayer and plr.Character then

            local hum = plr.Character:FindFirstChildOfClass(
                "Humanoid"
            )

            local root = plr.Character:FindFirstChild(
                "HumanoidRootPart"
            )

            if hum and root and hum.Health > 0 then

                table.insert(targets, {
                    Humanoid = hum,
                    RootPart = root,
                    IsPlayer = true
                })
            end
        end
    end

    if Settings.KillAuraNPC then

        for _, model in ipairs(Workspace:GetDescendants()) do

            if model:IsA("Model")
                and not Players:GetPlayerFromCharacter(model) then

                local hum = model:FindFirstChildOfClass(
                    "Humanoid"
                )

                local root = model:FindFirstChild(
                    "HumanoidRootPart"
                )

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

local function toggleKillAura()

    if kaConn then
        kaConn:Disconnect()
        kaConn = nil
    end

    if not Settings.KillAura then
        return
    end

    kaConn = RunService.Heartbeat:Connect(function()

        local char = LocalPlayer.Character

        if not char then
            return
        end

        local myRoot = char:FindFirstChild(
            "HumanoidRootPart"
        )

        if not myRoot then
            return
        end

        local targets = getTargets()
        local remote = getRemote()

        for _, target in ipairs(targets) do

            local distance =
                (myRoot.Position - target.RootPart.Position).Magnitude

            if distance <= Settings.KillAuraRange then

                if target.IsPlayer then

                    pcall(function()
                        target.Humanoid:TakeDamage(
                            Settings.KillAuraDamage
                        )
                    end)

                elseif remote then

                    local args = {}

                    local rawArgs =
                        Settings.KillAuraRemoteArgs
                        :gsub("%s+", "")

                    for _, argName in ipairs(
                        string.split(rawArgs, ",")
                    ) do

                        if argName == "target" then
                            table.insert(
                                args,
                                target.RootPart
                            )

                        elseif argName == "damage" then
                            table.insert(
                                args,
                                Settings.KillAuraDamage
                            )

                        elseif argName == "humanoid" then
                            table.insert(
                                args,
                                target.Humanoid
                            )
                        end
                    end

                    if #args == 0 then
                        args = {
                            target.RootPart,
                            Settings.KillAuraDamage
                        }
                    end

                    pcall(function()
                        remote:FireServer(unpack(args))
                    end)

                else

                    pcall(function()
                        target.Humanoid.Health =
                            math.max(
                                0,
                                target.Humanoid.Health
                                - Settings.KillAuraDamage
                            )
                    end)
                end
            end
        end
    end)
end

-- =========================================================
-- KILL MOBS
-- =========================================================

local kmConn

local function toggleKillMobs()

    if kmConn then
        kmConn:Disconnect()
        kmConn = nil
    end

    if not Settings.KillMobs then
        return
    end

    kmConn = RunService.Heartbeat:Connect(function()

        for _, npc in ipairs(getAllNPCs()) do

            local hum = npc:FindFirstChildOfClass(
                "Humanoid"
            )

            local root = npc:FindFirstChild(
                "HumanoidRootPart"
            )

            if hum and root then
                damageNPC_Universal(
                    hum,
                    root,
                    Settings.KillAuraDamage,
                    npc
                )
            end
        end
    end)
end

-- =========================================================
-- AUTO CHOP
-- =========================================================

local acConn

local function toggleAutoChop()

    if acConn then
        acConn:Disconnect()
        acConn = nil
    end

    if not Settings.AutoChop then
        return
    end

    acConn = RunService.Heartbeat:Connect(function()

        local char = LocalPlayer.Character

        if not char then
            return
        end

        local root = char:FindFirstChild(
            "HumanoidRootPart"
        )

        if not root then
            return
        end

        local folder = Workspace:FindFirstChild("Trees")

        if not folder then
            return
        end

        local events = ReplicatedStorage:FindFirstChild("Events")
        local chop = events and events:FindFirstChild("Chop")

        if not chop then
            return
        end

        for _, tree in ipairs(folder:GetChildren()) do

            local main = tree:FindFirstChild("Main")

            if main
                and main:IsA("BasePart")
                and (root.Position - main.Position).Magnitude < 20 then

                pcall(function()
                    chop:FireServer(tree)
                end)
            end
        end
    end)
end

-- =========================================================
-- NOCLIP
-- =========================================================

local noclipConn

local function toggleNoclip()

    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end

    if not Settings.Noclip then
        return
    end

    noclipConn = RunService.Stepped:Connect(function()

        local char = LocalPlayer.Character

        if not char then
            return
        end

        for _, part in ipairs(char:GetDescendants()) do

            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- =========================================================
-- FORCEFIELD
-- =========================================================

local function updateForceField()

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local ff = char:FindFirstChildOfClass("ForceField")

    if Settings.ForceField then

        if not ff then
            Instance.new("ForceField", char)
        end

    elseif ff then

        ff:Destroy()
    end
end

-- =========================================================
-- AUTO CLICK
-- =========================================================

local acClickConn

local function isMouseOverUI()

    local mouse = LocalPlayer:GetMouse()

    local success, guiObjects =
        pcall(function()
            return CoreGui:GetGuiObjectsAtPosition(
                mouse.X,
                mouse.Y
            )
        end)

    if not success or not guiObjects then
        return false
    end

    for _, gui in ipairs(guiObjects) do

        if gui:IsA("ScreenGui")
            and (
                gui.Name == "MKRA_Hub"
                or gui.Name == "FlyButton"
            ) then

            return true
        end
    end

    return false
end

local function toggleAutoClick()

    if acClickConn then
        acClickConn:Disconnect()
        acClickConn = nil
    end

    if not Settings.AutoClick then
        return
    end

    acClickConn = RunService.RenderStepped:Connect(function()

        if not isMouseOverUI() then

            pcall(function()
                VirtualUser:ClickButton1(
                    Vector2.new(0, 0)
                )
            end)
        end
    end)
end

-- =========================================================
-- AUTO CLICK BALL
-- =========================================================

local ballConn
local lastBallClick = 0

local function clickBall()

    pcall(function()

        VirtualInputManager:SendMouseButtonEvent(
            0,
            0,
            0,
            true,
            game,
            0
        )

        task.wait()

        VirtualInputManager:SendMouseButtonEvent(
            0,
            0,
            0,
            false,
            game,
            0
        )
    end)
end

local function toggleAutoClickBall()

    if ballConn then
        ballConn:Disconnect()
        ballConn = nil
    end

    if not Settings.AutoClickBall then
        return
    end

    ballConn = RunService.Heartbeat:Connect(function()

        local char = LocalPlayer.Character

        if not char then
            return
        end

        local root = char:FindFirstChild(
            "HumanoidRootPart"
        )

        if not root then
            return
        end

        local now = os.clock()

        if now - lastBallClick < 0.3 then
            return
        end

        for _, part in ipairs(Workspace:GetDescendants()) do

            if part:IsA("BasePart")
                and part.Name:lower():find("ball") then

                if (part.Position - root.Position).Magnitude
                    <= Settings.BallDistance then

                    clickBall()
                    lastBallClick = now
                    break
                end
            end
        end
    end)
end

-- =========================================================
-- AUTO F
-- =========================================================

local autoFConn
local humanoidAF
local origWalkSpeedAF = 16

local function pressF()

    pcall(function()

        VirtualInputManager:SendKeyEvent(
            true,
            Enum.KeyCode.F,
            false,
            nil
        )

        VirtualInputManager:SendKeyEvent(
            false,
            Enum.KeyCode.F,
            false,
            nil
        )
    end)
end

local function toggleAutoF()

    if autoFConn then
        autoFConn:Disconnect()
        autoFConn = nil
    end

    local char = LocalPlayer.Character

    if not char then
        return
    end

    humanoidAF = char:FindFirstChildOfClass("Humanoid")

    if not humanoidAF then
        return
    end

    if Settings.AutoF then

        origWalkSpeedAF = humanoidAF.WalkSpeed

        humanoidAF.WalkSpeed = 0

        humanoidAF:SetStateEnabled(
            Enum.HumanoidStateType.Jumping,
            false
        )

        autoFConn = RunService.Heartbeat:Connect(function()

            if Settings.AutoF
                and not Settings.AutoFPaused then

                pressF()
            end
        end)

    else

        humanoidAF.WalkSpeed = origWalkSpeedAF

        humanoidAF:SetStateEnabled(
            Enum.HumanoidStateType.Jumping,
            true
        )
    end
end

-- =========================================================
-- PLAYER ESP
-- =========================================================

local espCons = {}

local function clearESP()

    for _, c in ipairs(espCons) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(espCons)

    for _, plr in ipairs(Players:GetPlayers()) do

        if plr.Character then

            local hl = plr.Character:FindFirstChild(
                "VIP_ESP"
            )

            if hl then
                hl:Destroy()
            end
        end
    end
end

local function updateESP()

    clearESP()

    if not Settings.ESP then
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do

        if plr ~= LocalPlayer and plr.Character then

            local hl = Instance.new("Highlight")
            hl.Name = "VIP_ESP"
            hl.Adornee = plr.Character
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Parent = plr.Character

            local connection =
                plr.CharacterAdded:Connect(function(char)

                    if not Settings.ESP then
                        return
                    end

                    task.wait(0.5)

                    local newHL = Instance.new("Highlight")
                    newHL.Name = "VIP_ESP"
                    newHL.Adornee = char
                    newHL.FillColor =
                        Color3.fromRGB(255, 0, 0)
                    newHL.FillTransparency = 0.5
                    newHL.OutlineColor =
                        Color3.new(1, 1, 1)
                    newHL.Parent = char
                end)

            table.insert(espCons, connection)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)

    if Settings.ESP then

        plr.CharacterAdded:Connect(function()

            task.wait(0.5)

            if Settings.ESP then
                updateESP()
            end
        end)
    end
end)

-- =========================================================
-- NPC ESP
-- =========================================================

local NPC_ESP_Objects = {}

local function getRootESP(model)

    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function isNPC(model)

    return model:IsA("Model")
        and not Players:GetPlayerFromCharacter(model)
        and model:FindFirstChildOfClass("Humanoid")
        and model:FindFirstChild("HumanoidRootPart")
end

local function createNPC_ESP(npc)

    if NPC_ESP_Objects[npc] then
        return
    end

    if not isNPC(npc) then
        return
    end

    local hum = npc:FindFirstChildOfClass("Humanoid")
    local root = getRootESP(npc)

    if not hum or not root then
        return
    end

    local hl = Instance.new("Highlight")
    hl.FillColor = ACCENT
    hl.FillTransparency = 0.8
    hl.Enabled = false
    hl.Parent = npc

    local bb = Instance.new("BillboardGui")
    bb.Adornee = root
    bb.Size = UDim2.fromOffset(200, 52)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = CoreGui

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 18)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 11
    nl.Parent = bb

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, 0, 0, 6)
    hpBg.Position = UDim2.fromOffset(0, 20)
    hpBg.BackgroundColor3 =
        Color3.fromRGB(40, 40, 50)
    hpBg.Parent = bb

    Instance.new("UICorner", hpBg).CornerRadius =
        UDim.new(0, 3)

    local hpBar = Instance.new("Frame")
    hpBar.Size = UDim2.fromScale(1, 1)
    hpBar.BackgroundColor3 =
        Color3.fromRGB(50, 255, 100)
    hpBar.Parent = hpBg

    Instance.new("UICorner", hpBar).CornerRadius =
        UDim.new(0, 3)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 16)
    info.Position = UDim2.fromOffset(0, 28)
    info.BackgroundTransparency = 1
    info.TextColor3 =
        Color3.fromRGB(200, 200, 200)
    info.Font = Enum.Font.Gotham
    info.TextSize = 9
    info.Parent = bb

    NPC_ESP_Objects[npc] = {
        Highlight = hl,
        Billboard = bb,
        NameLabel = nl,
        HealthBarBg = hpBg,
        HealthBar = hpBar,
        InfoLabel = info,
        Humanoid = hum,
        Root = root
    }
end

local function removeNPC_ESP(npc)

    local data = NPC_ESP_Objects[npc]

    if not data then
        return
    end

    pcall(function()
        data.Highlight:Destroy()
    end)

    pcall(function()
        data.Billboard:Destroy()
    end)

    NPC_ESP_Objects[npc] = nil
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") then
        createNPC_ESP(obj)
    end
end

Workspace.DescendantAdded:Connect(function(obj)

    if obj:IsA("Model") then

        task.wait(0.1)

        createNPC_ESP(obj)
    end
end)

task.spawn(function()

    while task.wait(0.1) do

        local playerRoot

        if LocalPlayer.Character then
            playerRoot =
                getRootESP(LocalPlayer.Character)
        end

        for npc, data in pairs(NPC_ESP_Objects) do

            if not npc.Parent then
                removeNPC_ESP(npc)
                continue
            end

            if not data.Humanoid
                or not data.Root
                or not data.Root.Parent then

                removeNPC_ESP(npc)
                continue
            end

            local alive = data.Humanoid.Health > 0

            local distance = math.huge

            if playerRoot then
                distance =
                    (playerRoot.Position
                    - data.Root.Position).Magnitude
            end

            local visible =
                Settings.NPC_ESP
                and distance <= Settings.NPC_ESP_Range

            if Settings.NPC_ESP_HideDead
                and not alive then

                visible = false
            end

            data.Highlight.Enabled = visible
            data.Billboard.Enabled = visible

            if not visible then
                continue
            end

            if Settings.NPC_ESP_Name then
                data.NameLabel.Text = npc.Name
                data.NameLabel.Visible = true
            else
                data.NameLabel.Visible = false
            end

            if Settings.NPC_ESP_Health then

                local percent = math.clamp(
                    data.Humanoid.Health
                    / math.max(data.Humanoid.MaxHealth, 1),
                    0,
                    1
                )

                data.HealthBar.Size =
                    UDim2.new(percent, 0, 1, 0)

                if percent > 0.6 then

                    data.HealthBar.BackgroundColor3 =
                        Color3.fromRGB(50, 255, 100)

                elseif percent > 0.3 then

                    data.HealthBar.BackgroundColor3 =
                        Color3.fromRGB(255, 200, 50)

                else

                    data.HealthBar.BackgroundColor3 =
                        Color3.fromRGB(255, 50, 50)
                end

                data.HealthBarBg.Visible = true

            else

                data.HealthBarBg.Visible = false
            end

            if Settings.NPC_ESP_Distance then

                data.InfoLabel.Text =
                    math.floor(distance) .. " studs"

                if Settings.NPC_ESP_Health then

                    data.InfoLabel.Text =
                        data.InfoLabel.Text
                        .. " | "
                        .. math.floor(
                            data.Humanoid.Health
                        )
                        .. " HP"
                end

                data.InfoLabel.Visible = true

            else

                data.InfoLabel.Visible = false
            end
        end
    end
end)

-- =========================================================
-- HITBOX
-- =========================================================

task.spawn(function()

    while task.wait(0.5) do

        if Settings.HitboxSize > 2 then

            for _, plr in ipairs(Players:GetPlayers()) do

                if plr ~= LocalPlayer
                    and plr.Character then

                    local hrp =
                        plr.Character:FindFirstChild(
                            "HumanoidRootPart"
                        )

                    if hrp then

                        hrp.Size = Vector3.new(
                            Settings.HitboxSize,
                            Settings.HitboxSize,
                            Settings.HitboxSize
                        )

                        hrp.Transparency = 0.7
                    end
                end
            end
        end
    end
end)

-- =========================================================
-- TELEPORT
-- =========================================================

local function teleportToMouse()

    local mouse = LocalPlayer:GetMouse()

    local target = mouse.Hit

    if not target then
        return
    end

    local char = LocalPlayer.Character

    if char then

        local root =
            char:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = CFrame.new(target.Position)
        end
    end
end

-- =========================================================
-- WALKSPEED
-- =========================================================

local function updateWalkSpeed()

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    if not hum then
        return
    end

    local speed = math.max(
        Settings.SpeedBoostMultiplier * 16,
        Settings.WalkSpeedDirect,
        16
    )

    hum.WalkSpeed = speed
end

-- =========================================================
-- FIND PLAYER
-- =========================================================

local function findPlayer(name)

    name = tostring(name)
        :gsub("%s+", "")
        :lower()

    if name == "" then
        return nil
    end

    for _, plr in ipairs(Players:GetPlayers()) do

        if plr.Name:lower():match(
            "^" .. name
        ) then

            return plr
        end
    end

    return nil
end

-- =========================================================
-- FE KILL
-- =========================================================

local function executeFEKill(targetName)

    local target = findPlayer(targetName)

    if not target
        or not target.Character then

        notify(
            "Kill",
            "រកមិនឃើញគោលដៅ",
            3
        )

        return
    end

    local char =
        LocalPlayer.Character
        or LocalPlayer.CharacterAdded:Wait()

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    local root =
        char:FindFirstChild("HumanoidRootPart")

    if not root or not hum then

        notify(
            "Kill",
            "តួអង្គមិនទាន់រួចរាល់",
            3
        )

        return
    end

    local targetRoot =
        target.Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not targetRoot then
        return
    end

    local savePos = root.CFrame

    pcall(function()
        root.CFrame = targetRoot.CFrame
    end)

    task.wait(0.2)

    pcall(function()
        root.CFrame = savePos
    end)

    notify(
        "Kill",
        "បានសាកល្បងលើ " .. targetName,
        3
    )
end

-- =========================================================
-- FLING
-- =========================================================

local function SkidFling(targetPlayer)

    local character = LocalPlayer.Character

    if not character then
        notify("Fling", "តួអង្គមិនរួចរាល់", 3)
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        humanoid and humanoid.RootPart

    if not humanoid or not root then
        notify("Fling", "តួអង្គមិនរួចរាល់", 3)
        return
    end

    local targetCharacter =
        targetPlayer.Character

    if not targetCharacter then
        return
    end

    local targetHumanoid =
        targetCharacter:FindFirstChildOfClass(
            "Humanoid"
        )

    local targetRoot =
        targetHumanoid
        and targetHumanoid.RootPart

    if not targetRoot then
        return
    end

    local oldPos = root.CFrame

    pcall(function()
        root.CFrame =
            targetRoot.CFrame
            * CFrame.new(0, 0, -2)
    end)

    task.wait(0.15)

    pcall(function()
        root.CFrame = oldPos
    end)

    notify(
        "Fling",
        "បានសាកល្បងលើ " .. targetPlayer.Name,
        3
    )
end

local function executeFling(name)

    if name == "" then
        notify("Fling", "បញ្ចូលឈ្មោះ", 3)
        return
    end

    local target = findPlayer(name)

    if not target then
        notify("Fling", "រកមិនឃើញ", 3)
        return
    end

    SkidFling(target)
end

local function flingAllPlayers()

    for _, plr in ipairs(Players:GetPlayers()) do

        if plr ~= LocalPlayer
            and plr.Character then

            SkidFling(plr)
        end
    end
end

-- =========================================================
-- INFINITE JUMP
-- =========================================================

UserInputService.JumpRequest:Connect(function()

    if not Settings.InfiniteJumpOrig then
        return
    end

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

local infiniteJump99Connection

local function enableInfiniteJump99()

    if infiniteJump99Connection then
        infiniteJump99Connection:Disconnect()
        infiniteJump99Connection = nil
    end

    if not Settings.InfiniteJump99 then
        return
    end

    infiniteJump99Connection =
        UserInputService.JumpRequest:Connect(function()

            local char = LocalPlayer.Character

            if not char then
                return
            end

            local hum =
                char:FindFirstChildOfClass("Humanoid")

            if hum then
                hum:ChangeState(
                    Enum.HumanoidStateType.Jumping
                )
            end
        end)
end

-- =========================================================
-- RAINBOW
-- =========================================================

local function rainbowColor(speed, offset)

    local hue =
        (tick() * (speed or 1)
        + (offset or 0)) % 1

    return Color3.fromHSV(
        hue,
        1,
        1
    )
end

-- =========================================================
-- SOUND
-- =========================================================

local function playBeep()

    pcall(function()

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6034521064"
        sound.Volume = 0.5
        sound.Parent = CoreGui

        sound:Play()

        task.delay(0.3, function()

            pcall(function()
                sound:Destroy()
            end)
        end)
    end)
end

-- =========================================================
-- GUI
-- =========================================================

local function createUI(imageAsset)

    if CoreGui:FindFirstChild("MKRA_Hub") then
        CoreGui.MKRA_Hub:Destroy()
    end

    imageAsset = imageAsset
        or FALLBACK_IMAGE

    local gui = Instance.new("ScreenGui")
    gui.Name = "MKRA_Hub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    -- Floating button
    local toggleBtn =
        Instance.new("ImageButton")

    toggleBtn.Name = "FlyButton"
    toggleBtn.Size =
        UDim2.fromOffset(44, 44)

    toggleBtn.Position =
        UDim2.new(0, 15, 0.5, -22)

    toggleBtn.BackgroundColor3 =
        Color3.fromRGB(20, 20, 20)

    toggleBtn.Image = imageAsset
    toggleBtn.ScaleType =
        Enum.ScaleType.Crop

    toggleBtn.Parent = gui

    Instance.new("UICorner", toggleBtn)
        .CornerRadius = UDim.new(1, 0)

    local toggleStroke =
        Instance.new("UIStroke")

    toggleStroke.Thickness = 3
    toggleStroke.Parent = toggleBtn

    -- Main window
    local main = Instance.new("CanvasGroup")

    main.Size =
        UDim2.new(0, 260, 0, 420)

    main.Position =
        UDim2.new(
            0.5,
            -130,
            0.5,
            -210
        )

    main.BackgroundColor3 =
        Color3.fromRGB(15, 15, 15)

    main.BorderSizePixel = 0
    main.Active = true
    main.GroupTransparency = 1
    main.Visible = false
    main.Parent = gui

    Instance.new("UICorner", main)
        .CornerRadius = UDim.new(0, 10)

    local mainStroke =
        Instance.new("UIStroke")

    mainStroke.Thickness = 2
    mainStroke.Parent = main

    -- Background image
    local bg =
        Instance.new("ImageLabel")

    bg.Size =
        UDim2.fromScale(1, 1)

    bg.BackgroundTransparency = 1
    bg.Image = imageAsset
    bg.ImageTransparency = 0.4
    bg.ScaleType = Enum.ScaleType.Crop
    bg.Parent = main

    Instance.new("UICorner", bg)
        .CornerRadius = UDim.new(0, 10)

    local overlay =
        Instance.new("Frame")

    overlay.Size =
        UDim2.fromScale(1, 1)

    overlay.BackgroundColor3 =
        Color3.fromRGB(10, 10, 12)

    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.Parent = main

    Instance.new("UICorner", overlay)
        .CornerRadius = UDim.new(0, 10)

    -- Top rainbow
    local topRainbow =
        Instance.new("Frame")

    topRainbow.Size =
        UDim2.new(1, 0, 0, 3)

    topRainbow.BackgroundTransparency = 1
    topRainbow.Parent = main

    for i = 0, 59 do

        local segment =
            Instance.new("Frame")

        segment.Size =
            UDim2.new(1 / 60, 0, 1, 0)

        segment.Position =
            UDim2.new(i / 60, 0, 0, 0)

        segment.BackgroundColor3 =
            rainbowColor(0.3, i / 60)

        segment.BorderSizePixel = 0
        segment.Parent = topRainbow
    end

    -- Title bar
    local titleBar =
        Instance.new("Frame")

    titleBar.Size =
        UDim2.new(1, 0, 0, 28)

    titleBar.Position =
        UDim2.new(0, 0, 0, 3)

    titleBar.BackgroundColor3 =
        Color3.fromRGB(25, 25, 25)

    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    Instance.new("UICorner", titleBar)
        .CornerRadius = UDim.new(0, 10)

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(1, -30, 1, 0)

    title.Position =
        UDim2.new(0, 8, 0, 0)

    title.BackgroundTransparency = 1
    title.Text = "MKRA Hub VIP v4.2"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = titleBar

    local minimizeBtn =
        Instance.new("TextButton")

    minimizeBtn.Size =
        UDim2.fromOffset(22, 22)

    minimizeBtn.Position =
        UDim2.new(1, -25, 0, 3)

    minimizeBtn.BackgroundColor3 =
        Color3.fromRGB(200, 50, 50)

    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 =
        Color3.new(1, 1, 1)

    minimizeBtn.Font =
        Enum.Font.SourceSansBold

    minimizeBtn.TextSize = 16
    minimizeBtn.Parent = titleBar

    Instance.new("UICorner", minimizeBtn)
        .CornerRadius = UDim.new(0, 5)

    -- Tabs
    local tabs = {
        "Move",
        "Combat",
        "Farm",
        "VIP",
        "Visual",
        "Util",
        "ESP",
        "Ctrl"
    }

    local tabFrame =
        Instance.new("Frame")

    tabFrame.Size =
        UDim2.new(1, -8, 0, 22)

    tabFrame.Position =
        UDim2.new(0, 4, 0, 35)

    tabFrame.BackgroundColor3 =
        Color3.fromRGB(30, 30, 30)

    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = main

    Instance.new("UICorner", tabFrame)
        .CornerRadius = UDim.new(0, 6)

    local contentFrame =
        Instance.new("Frame")

    contentFrame.Size =
        UDim2.new(1, -8, 1, -95)

    contentFrame.Position =
        UDim2.new(0, 4, 0, 60)

    contentFrame.BackgroundColor3 =
        Color3.fromRGB(20, 20, 20)

    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = main

    Instance.new("UICorner", contentFrame)
        .CornerRadius = UDim.new(0, 8)

    local tabContainers = {}

    for i, tabName in ipairs(tabs) do

        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.new(
                1 / #tabs,
                0,
                1,
                0
            )

        button.Position =
            UDim2.new(
                (i - 1) / #tabs,
                0,
                0,
                0
            )

        button.Text = tabName
        button.BackgroundColor3 =
            Color3.fromRGB(50, 50, 50)

        button.TextColor3 =
            Color3.new(1, 1, 1)

        button.Font = Enum.Font.Gotham
        button.TextSize = 10
        button.Parent = tabFrame

        Instance.new("UICorner", button)
            .CornerRadius = UDim.new(0, 4)

        local container =
            Instance.new("Frame")

        container.Size =
            UDim2.fromScale(1, 1)

        container.BackgroundTransparency = 1
        container.Visible = false
        container.Parent = contentFrame

        tabContainers[tabName] = container

        button.MouseButton1Click:Connect(function()

            for _, c in pairs(tabContainers) do
                c.Visible = false
            end

            container.Visible = true
        end)
    end

    tabContainers.Move.Visible = true

    -- =====================================================
    -- UI HELPERS
    -- =====================================================

    local function getNextY(container)
        local count = 0

        for _, child in ipairs(container:GetChildren()) do

            if child:IsA("GuiObject") then
                count += 1
            end
        end

        return count * 28 + 4
    end

    local function addToggle(
        container,
        text,
        default,
        callback
    )

        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.new(1, -6, 0, 26)

        button.Position =
            UDim2.new(
                0,
                3,
                0,
                getNextY(container)
            )

        button.BackgroundColor3 =
            default
            and Color3.fromRGB(0, 140, 0)
            or Color3.fromRGB(70, 70, 70)

        button.Text =
            text
            .. ": "
            .. (default and "ON" or "OFF")

        button.TextColor3 =
            Color3.new(1, 1, 1)

        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.Parent = container

        Instance.new("UICorner", button)
            .CornerRadius = UDim.new(0, 5)

        local state = default

        button.MouseButton1Click:Connect(function()

            state = not state

            button.Text =
                text
                .. ": "
                .. (state and "ON" or "OFF")

            button.BackgroundColor3 =
                state
                and Color3.fromRGB(0, 140, 0)
                or Color3.fromRGB(70, 70, 70)

            playBeep()

            callback(state)
        end)
    end

    local function addButton(
        container,
        text,
        callback
    )

        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.new(1, -6, 0, 26)

        button.Position =
            UDim2.new(
                0,
                3,
                0,
                getNextY(container)
            )

        button.BackgroundColor3 =
            Color3.fromRGB(70, 70, 70)

        button.Text = text
        button.TextColor3 =
            Color3.new(1, 1, 1)

        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.Parent = container

        Instance.new("UICorner", button)
            .CornerRadius = UDim.new(0, 5)

        button.MouseButton1Click:Connect(function()

            playBeep()
            callback()
        end)
    end

    local function addTextBox(
        container,
        label,
        default,
        callback
    )

        local frame =
            Instance.new("Frame")

        frame.Size =
            UDim2.new(1, -6, 0, 28)

        frame.Position =
            UDim2.new(
                0,
                3,
                0,
                getNextY(container)
            )

        frame.BackgroundTransparency = 1
        frame.Parent = container

        local lbl =
            Instance.new("TextLabel")

        lbl.Size =
            UDim2.new(0, 80, 1, 0)

        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 =
            Color3.new(1, 1, 1)

        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.Parent = frame

        local box =
            Instance.new("TextBox")

        box.Size =
            UDim2.new(1, -85, 1, 0)

        box.Position =
            UDim2.new(0, 85, 0, 0)

        box.BackgroundColor3 =
            Color3.fromRGB(50, 50, 50)

        box.TextColor3 =
            Color3.new(1, 1, 1)

        box.Text = default
        box.Font = Enum.Font.Gotham
        box.TextSize = 10
        box.ClearTextOnFocus = false
        box.Parent = frame

        Instance.new("UICorner", box)
            .CornerRadius = UDim.new(0, 4)

        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
    end

    -- =====================================================
    -- MOVE
    -- =====================================================

    addToggle(
        tabContainers.Move,
        "Fly",
        false,
        function(v)

            Settings.Fly = v

            if v then
                startFly()
            else
                stopFly()
            end
        end
    )

    addTextBox(
        tabContainers.Move,
        "Speed",
        "120",
        function(v)
            Settings.FlySpeed =
                tonumber(v) or 120
        end
    )

    addToggle(
        tabContainers.Move,
        "Boost",
        false,
        function(v)
            Settings.BoostMode = v
        end
    )

    addToggle(
        tabContainers.Move,
        "Noclip",
        false,
        function(v)

            Settings.Noclip = v
            toggleNoclip()
        end
    )

    addTextBox(
        tabContainers.Move,
        "WS Mult",
        "1",
        function(v)

            Settings.SpeedBoostMultiplier =
                tonumber(v) or 1

            updateWalkSpeed()
        end
    )

    addToggle(
        tabContainers.Move,
        "Inf Jump",
        false,
        function(v)
            Settings.InfiniteJumpOrig = v
        end
    )

    -- =====================================================
    -- COMBAT
    -- =====================================================

    addToggle(
        tabContainers.Combat,
        "Kill Aura",
        false,
        function(v)

            Settings.KillAura = v
            toggleKillAura()
        end
    )

    addTextBox(
        tabContainers.Combat,
        "Range",
        "30",
        function(v)

            Settings.KillAuraRange =
                tonumber(v) or 30
        end
    )

    addTextBox(
        tabContainers.Combat,
        "Damage",
        "30",
        function(v)

            Settings.KillAuraDamage =
                tonumber(v) or 30
        end
    )

    addToggle(
        tabContainers.Combat,
        "KA NPCs",
        false,
        function(v)

            Settings.KillAuraNPC = v

            if Settings.KillAura then
                toggleKillAura()
            end
        end
    )

    addTextBox(
        tabContainers.Combat,
        "Remote",
        "",
        function(v)
            Settings.KillAuraRemote = v
        end
    )

    addTextBox(
        tabContainers.Combat,
        "Args",
        "target,damage",
        function(v)
            Settings.KillAuraRemoteArgs = v
        end
    )

    addToggle(
        tabContainers.Combat,
        "Kill Mobs",
        false,
        function(v)

            Settings.KillMobs = v
            toggleKillMobs()
        end
    )

    addToggle(
        tabContainers.Combat,
        "Hitbox",
        false,
        function(v)

            Settings.HitboxSize =
                v and 10 or 2
        end
    )

    addToggle(
        tabContainers.Combat,
        "AutoClick",
        false,
        function(v)

            Settings.AutoClick = v
            toggleAutoClick()
        end
    )

    addToggle(
        tabContainers.Combat,
        "ForceField",
        false,
        function(v)

            Settings.ForceField = v
            updateForceField()
        end
    )

    addToggle(
        tabContainers.Combat,
        "Ball Click",
        false,
        function(v)

            Settings.AutoClickBall = v
            toggleAutoClickBall()
        end
    )

    addTextBox(
        tabContainers.Combat,
        "BallDist",
        "5",
        function(v)

            Settings.BallDistance =
                tonumber(v) or 5
        end
    )

    -- =====================================================
    -- FARM
    -- =====================================================

    addToggle(
        tabContainers.Farm,
        "Auto Chop",
        false,
        function(v)

            Settings.AutoChop = v
            toggleAutoChop()
        end
    )

    addTextBox(
        tabContainers.Farm,
        "WalkSpeed",
        "16",
        function(v)

            Settings.WalkSpeedDirect =
                math.clamp(
                    tonumber(v) or 16,
                    16,
                    500
                )

            updateWalkSpeed()
        end
    )

    addToggle(
        tabContainers.Farm,
        "InfJump99",
        false,
        function(v)

            Settings.InfiniteJump99 = v
            enableInfiniteJump99()
        end
    )

    -- =====================================================
    -- VIP
    -- =====================================================

    addButton(
        tabContainers.VIP,
        "Teleport",
        teleportToMouse
    )

    addToggle(
        tabContainers.VIP,
        "Player ESP",
        false,
        function(v)

            Settings.ESP = v
            updateESP()
        end
    )

    addButton(
        tabContainers.VIP,
        "Heal",
        function()

            local char = LocalPlayer.Character

            if not char then
                return
            end

            local hum =
                char:FindFirstChildOfClass(
                    "Humanoid"
                )

            if hum then
                hum.Health = hum.MaxHealth
            end
        end
    )

    addToggle(
        tabContainers.VIP,
        "God Mode",
        false,
        function(v)

            Settings.GodMode = v
            toggleGodMode()
        end
    )

    addToggle(
        tabContainers.VIP,
        "Instant Resp",
        false,
        function(v)

            Settings.InstantRespawn = v
            toggleInstantRespawn()
        end
    )

    addButton(
        tabContainers.VIP,
        "VIP Speed",
        function()

            Settings.SpeedBoostMultiplier =
                100 / 16

            Settings.FlySpeed = 2500

            updateWalkSpeed()

            notify(
                "Speed",
                "Walk 100, Fly 2500",
                2
            )
        end
    )

    addButton(
        tabContainers.VIP,
        "Reset Speed",
        function()

            Settings.SpeedBoostMultiplier = 1
            Settings.FlySpeed = 120

            updateWalkSpeed()

            notify(
                "Speed",
                "Reset",
                2
            )
        end
    )

    addButton(
        tabContainers.VIP,
        "Spawn Cash",
        function()

            local addMoney =
                ReplicatedStorage:FindFirstChild(
                    "AddMoney"
                )

            if addMoney
                and addMoney:IsA("RemoteEvent") then

                pcall(function()
                    addMoney:FireServer(999999)
                end)
            end

            notify(
                "Cash",
                "សាកល្បង",
                2
            )
        end
    )

    local killBox =
        Instance.new("TextBox")

    killBox.Size =
        UDim2.new(1, -6, 0, 24)

    killBox.Position =
        UDim2.new(
            0,
            3,
            0,
            getNextY(tabContainers.VIP)
        )

    killBox.BackgroundColor3 =
        Color3.fromRGB(50, 50, 50)

    killBox.TextColor3 =
        Color3.new(1, 1, 1)

    killBox.PlaceholderText =
        "ឈ្មោះ (Kill)"

    killBox.Font = Enum.Font.Gotham
    killBox.TextSize = 10
    killBox.Parent = tabContainers.VIP

    Instance.new("UICorner", killBox)
        .CornerRadius = UDim.new(0, 4)

    addButton(
        tabContainers.VIP,
        "FE KILL",
        function()
            executeFEKill(killBox.Text)
        end
    )

    local flingBox =
        Instance.new("TextBox")

    flingBox.Size =
        UDim2.new(1, -6, 0, 24)

    flingBox.Position =
        UDim2.new(
            0,
            3,
            0,
            getNextY(tabContainers.VIP)
        )

    flingBox.BackgroundColor3 =
        Color3.fromRGB(50, 50, 50)

    flingBox.TextColor3 =
        Color3.new(1, 1, 1)

    flingBox.PlaceholderText =
        "ឈ្មោះ (Fling)"

    flingBox.Font = Enum.Font.Gotham
    flingBox.TextSize = 10
    flingBox.Parent = tabContainers.VIP

    Instance.new("UICorner", flingBox)
        .CornerRadius = UDim.new(0, 4)

    addButton(
        tabContainers.VIP,
        "FLING",
        function()
            executeFling(flingBox.Text)
        end
    )

    addToggle(
        tabContainers.VIP,
        "Fling All",
        false,
        function(v)

            Settings.FlingAll = v

            if v then
                flingAllPlayers()
            end
        end
    )

    addToggle(
        tabContainers.VIP,
        "Auto F",
        false,
        function(v)

            Settings.AutoF = v
            toggleAutoF()
        end
    )

    addToggle(
        tabContainers.VIP,
        "Pause AF",
        false,
        function(v)

            Settings.AutoFPaused = v

            if not Settings.AutoF then
                return
            end

            local char = LocalPlayer.Character

            if not char then
                return
            end

            local hum =
                char:FindFirstChildOfClass(
                    "Humanoid"
                )

            if not hum then
                return
            end

            if v then

                hum.WalkSpeed =
                    origWalkSpeedAF

                hum:SetStateEnabled(
                    Enum.HumanoidStateType.Jumping,
                    true
                )

            else

                hum.WalkSpeed = 0

                hum:SetStateEnabled(
                    Enum.HumanoidStateType.Jumping,
                    false
                )
            end
        end
    )

    -- =====================================================
    -- VISUAL
    -- =====================================================

    addTextBox(
        tabContainers.Visual,
        "FOV",
        "70",
        function(v)

            if Workspace.CurrentCamera then

                Workspace.CurrentCamera.FieldOfView =
                    math.clamp(
                        tonumber(v) or 70,
                        70,
                        120
                    )
            end
        end
    )

    addToggle(
        tabContainers.Visual,
        "FullBright",
        false,
        function(v)

            local lighting =
                game:GetService("Lighting")

            if v then

                lighting.Brightness = 2
                lighting.ClockTime = 12
                lighting.FogEnd = 1e5

            else

                lighting.Brightness = 0.5
                lighting.ClockTime = 0
                lighting.FogEnd = 1000
            end
        end
    )

    -- =====================================================
    -- ESP
    -- =====================================================

    addToggle(
        tabContainers.ESP,
        "NPC ESP",
        false,
        function(v)
            Settings.NPC_ESP = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "Name",
        true,
        function(v)
            Settings.NPC_ESP_Name = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "Health",
        true,
        function(v)
            Settings.NPC_ESP_Health = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "Dist",
        true,
        function(v)
            Settings.NPC_ESP_Distance = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "HideDead",
        true,
        function(v)
            Settings.NPC_ESP_HideDead = v
        end
    )

    addTextBox(
        tabContainers.ESP,
        "Range",
        "200",
        function(v)

            Settings.NPC_ESP_Range =
                tonumber(v) or 200
        end
    )

    -- =====================================================
    -- CONTROL
    -- =====================================================

    addToggle(
        tabContainers.Ctrl,
        "VIP Freeze (Hold)",
        false,
        function(v)

            Settings.VIPFreezeHold = v
            toggleVIPFreezeHold()
        end
    )

    addToggle(
        tabContainers.Ctrl,
        "VIP Freeze (Kill)",
        false,
        function(v)

            Settings.VIPFreezeKill = v
            toggleVIPFreezeKill()
        end
    )

    -- =====================================================
    -- UTIL
    -- =====================================================

    addButton(
        tabContainers.Util,
        "Rejoin",
        function()

            pcall(function()
                TeleportService:Teleport(
                    game.PlaceId,
                    LocalPlayer
                )
            end)
        end
    )

    addButton(
        tabContainers.Util,
        "Server Hop",
        function()

            pcall(function()

                local url =
                    "https://games.roblox.com/v1/games/"
                    .. game.PlaceId
                    .. "/servers/Public?limit=100"

                local response =
                    game:HttpGet(url)

                local data =
                    HttpService:JSONDecode(
                        response
                    )

                local ids = {}

                for _, server in ipairs(data.data or {}) do

                    if server.playing
                        and server.id ~= game.JobId then

                        table.insert(
                            ids,
                            server.id
                        )
                    end
                end

                if #ids > 0 then

                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        ids[math.random(#ids)],
                        LocalPlayer
                    )

                else

                    notify(
                        "Hop",
                        "រកមិនឃើញ Server",
                        3
                    )
                end
            end)
        end
    )

    -- =====================================================
    -- CREDIT
    -- =====================================================

    local creditLabel =
        Instance.new("TextLabel")

    creditLabel.Size =
        UDim2.new(1, 0, 0, 16)

    creditLabel.Position =
        UDim2.new(0, 0, 1, -20)

    creditLabel.BackgroundTransparency = 1

    creditLabel.Text =
        "Oun ka (VIP Freeze)"

    creditLabel.TextColor3 =
        Color3.new(1, 1, 1)

    creditLabel.Font =
        Enum.Font.GothamBold

    creditLabel.TextSize = 10
    creditLabel.Parent = main

    -- =====================================================
    -- BOTTOM RAINBOW
    -- =====================================================

    local bottomRainbow =
        Instance.new("Frame")

    bottomRainbow.Size =
        UDim2.new(1, 0, 0, 3)

    bottomRainbow.Position =
        UDim2.new(0, 0, 1, -3)

    bottomRainbow.BackgroundTransparency = 1
    bottomRainbow.Parent = main

    for i = 0, 59 do

        local segment =
            Instance.new("Frame")

        segment.Size =
            UDim2.new(1 / 60, 0, 1, 0)

        segment.Position =
            UDim2.new(i / 60, 0, 0, 0)

        segment.BackgroundColor3 =
            rainbowColor(0.3, i / 60)

        segment.BorderSizePixel = 0
        segment.Parent = bottomRainbow
    end

    -- =====================================================
    -- SPARKLES
    -- =====================================================

    for _ = 1, 8 do

        local spark =
            Instance.new("Frame")

        spark.Size =
            UDim2.fromOffset(4, 4)

        spark.Position =
            UDim2.new(
                math.random(),
                0,
                math.random(),
                0
            )

        spark.BackgroundColor3 =
            Color3.new(1, 1, 1)

        spark.BackgroundTransparency = 0.7
        spark.BorderSizePixel = 0
        spark.Parent = main

        Instance.new("UICorner", spark)
            .CornerRadius = UDim.new(1, 0)
    end

    -- =====================================================
    -- RAINBOW ANIMATION
    -- =====================================================

    task.spawn(function()

        while gui.Parent do

            local hue =
                (tick() * 0.5) % 1

            title.TextColor3 =
                Color3.fromHSV(
                    hue,
                    1,
                    1
                )

            creditLabel.TextColor3 =
                Color3.fromHSV(
                    (hue + 0.3) % 1,
                    1,
                    1
                )

            minimizeBtn.BackgroundColor3 =
                Color3.fromHSV(
                    (hue + 0.6) % 1,
                    1,
                    0.8
                )

            for i, seg in ipairs(
                topRainbow:GetChildren()
            ) do

                if seg:IsA("Frame") then

                    seg.BackgroundColor3 =
                        Color3.fromHSV(
                            (
                                tick() * 0.3
                                + i / 60
                            ) % 1,
                            1,
                            1
                        )
                end
            end

            for i, seg in ipairs(
                bottomRainbow:GetChildren()
            ) do

                if seg:IsA("Frame") then

                    seg.BackgroundColor3 =
                        Color3.fromHSV(
                            (
                                tick() * 0.3
                                + i / 60
                            ) % 1,
                            1,
                            1
                        )
                end
            end

            task.wait()
        end
    end)

    -- =====================================================
    -- MINIMIZE
    -- =====================================================

    local restoreButton

    local function minimizeUI()

        main.Visible = false

        if restoreButton then
            return
        end

        restoreButton =
            Instance.new("TextButton")

        restoreButton.Name =
            "RestoreBtn"

        restoreButton.Size =
            UDim2.fromOffset(36, 36)

        restoreButton.Position =
            main.Position

        restoreButton.BackgroundColor3 =
            Color3.fromHSV(
                tick() % 1,
                1,
                0.8
            )

        restoreButton.Text = "+"
        restoreButton.TextColor3 =
            Color3.new(1, 1, 1)

        restoreButton.Font =
            Enum.Font.SourceSansBold

        restoreButton.TextSize = 20
        restoreButton.Active = true
        restoreButton.Draggable = true
        restoreButton.Parent = gui

        Instance.new("UICorner", restoreButton)
            .CornerRadius = UDim.new(0, 8)

        task.spawn(function()

            while restoreButton
                and restoreButton.Parent do

                restoreButton.BackgroundColor3 =
                    rainbowColor(1, 0)

                task.wait(0.05)
            end
        end)

        restoreButton.MouseButton1Click:Connect(function()

            main.Visible = true

            restoreButton:Destroy()
            restoreButton = nil
        end)
    end

    minimizeBtn.MouseButton1Click:Connect(
        minimizeUI
    )

    -- =====================================================
    -- DRAG SYSTEM
    -- =====================================================

    local function makeDraggable(
        bar,
        frame
    )

        local dragging = false
        local startPos
        local objectPos

        bar.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1

                or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true
                startPos = input.Position
                objectPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(
            function(input)

                if not dragging then
                    return
                end

                if input.UserInputType ==
                    Enum.UserInputType.MouseMovement

                    or input.UserInputType ==
                    Enum.UserInputType.Touch then

                    local delta =
                        input.Position - startPos

                    frame.Position =
                        UDim2.new(
                            objectPos.X.Scale,
                            objectPos.X.Offset
                                + delta.X,

                            objectPos.Y.Scale,
                            objectPos.Y.Offset
                                + delta.Y
                        )
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)

                if input.UserInputType ==
                    Enum.UserInputType.MouseButton1

                    or input.UserInputType ==
                    Enum.UserInputType.Touch then

                    dragging = false
                end
            end
        )
    end

    makeDraggable(titleBar, main)

    -- =====================================================
    -- TOGGLE WINDOW
    -- =====================================================

    local isOpen = false

    local function toggleWindow()

        isOpen = not isOpen

        if isOpen then

            main.Visible = true

            TweenService:Create(
                main,
                TweenInfo.new(0.3),
                {
                    GroupTransparency = 0
                }
            ):Play()

            TweenService:Create(
                toggleBtn,
                TweenInfo.new(0.3),
                {
                    Rotation = 180
                }
            ):Play()

        else

            local animation =
                TweenService:Create(
                    main,
                    TweenInfo.new(0.3),
                    {
                        GroupTransparency = 1
                    }
                )

            animation:Play()

            TweenService:Create(
                toggleBtn,
                TweenInfo.new(0.3),
                {
                    Rotation = 0
                }
            ):Play()

            animation.Completed:Wait()

            main.Visible = false
        end
    end

    -- =====================================================
    -- MOBILE BUTTON DRAG
    -- =====================================================

    local toggleDrag = false
    local toggleMoved = false
    local toggleStart
    local toggleObj

    toggleBtn.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1

            or input.UserInputType ==
            Enum.UserInputType.Touch then

            toggleDrag = true
            toggleMoved = false
            toggleStart = input.Position
            toggleObj = toggleBtn.Position
        end
    end)

    UserInputService.InputChanged:Connect(
        function(input)

            if not toggleDrag then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement

                or input.UserInputType ==
                Enum.UserInputType.Touch then

                local delta =
                    input.Position - toggleStart

                if delta.Magnitude > 5 then
                    toggleMoved = true
                end

                toggleBtn.Position =
                    UDim2.new(
                        toggleObj.X.Scale,
                        toggleObj.X.Offset
                            + delta.X,

                        toggleObj.Y.Scale,
                        toggleObj.Y.Offset
                            + delta.Y
                    )
            end
        end
    )

    toggleBtn.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1

            or input.UserInputType ==
            Enum.UserInputType.Touch then

            if toggleDrag and not toggleMoved then
                toggleWindow()
            end

            toggleDrag = false
        end
    end)

    -- =====================================================
    -- IMAGE ERROR NOTICE
    -- =====================================================

    if imageAsset == FALLBACK_IMAGE then

        task.delay(1, function()

            notify(
                "MKRA Hub",
                "Custom image មិនអាច Load បាន — ប្រើ Fallback",
                4
            )
        end)
    end
end

-- =========================================================
-- START
-- =========================================================

task.spawn(function()

    local imageAsset = loadImage()

    createUI(imageAsset)
end)

-- =========================================================
-- CHARACTER RESPAWN HANDLER
-- =========================================================

LocalPlayer.CharacterAdded:Connect(function()

    task.wait(0.5)

    if Settings.Fly then
        stopFly()
        startFly()
    end

    if Settings.GodMode then
        toggleGodMode()
    end

    if Settings.Noclip then
        toggleNoclip()
    end

    if Settings.ESP then
        updateESP()
    end

    if Settings.KillAura then
        toggleKillAura()
    end

    if Settings.KillMobs then
        toggleKillMobs()
    end

    if Settings.AutoChop then
        toggleAutoChop()
    end

    if Settings.AutoClickBall then
        toggleAutoClickBall()
    end

    if Settings.AutoF then
        toggleAutoF()
    end

    if Settings.VIPFreezeHold then
        toggleVIPFreezeHold()
    end

    if Settings.VIPFreezeKill then
        toggleVIPFreezeKill()
    end

    updateForceField()
    updateWalkSpeed()
end)

-- =========================================================
-- READY
-- =========================================================

notify(
    "MKRA Hub",
    "Mobile Optimized VIP Freeze Ready!",
    3
)