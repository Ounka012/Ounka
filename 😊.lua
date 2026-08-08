--[[
    MKRA Hub VIP v4.2
    Mobile Optimized
    - Fixed Image Loading
    - Full GUI Drag: Mobile + PC
    - All original features preserved
]]

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ==================== SETTINGS ====================
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

-- ==================== IMAGE ====================
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local IMAGE_FILE = "MKRA_VIP_BG.jpg"

local DEFAULT_IMAGE = "rbxassetid://7733960981"
local ACCENT = Color3.fromRGB(220, 150, 200)

-- ==================== NOTIFY ====================
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- ==================== IMAGE LOADER ====================
local function loadImage()
    local asset = ""

    pcall(function()
        if typeof(request) == "function"
            and typeof(writefile) == "function"
            and typeof(getcustomasset) == "function" then

            local response = request({
                Url = IMAGE_URL,
                Method = "GET"
            })

            if response
                and response.StatusCode == 200
                and response.Body then

                writefile(IMAGE_FILE, response.Body)
                asset = getcustomasset(IMAGE_FILE)
            end
        end
    end)

    if asset == "" then
        asset = DEFAULT_IMAGE
    end

    return asset
end

-- ==================== NPC ====================
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

-- ==================== ROOT ====================
local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

-- ==================== VIP FREEZE ====================
local freezeHoldRender
local freezeHoldConn
local frozenNPCs = {}

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

-- ==================== VIP FREEZE KILL ====================
local vipKillConn

local function toggleVIPFreezeKill()
    if vipKillConn then
        vipKillConn:Disconnect()
        vipKillConn = nil
    end

    if Settings.VIPFreezeKill then
        destroyAllNPCs()

        vipKillConn = RunService.Heartbeat:Connect(function()
            destroyAllNPCs()
        end)

        notify("VIP Freeze Kill", "All NPCs are being eliminated!", 3)
    else
        notify("VIP Freeze Kill", "Disabled", 2)
    end
end

-- ==================== FLY ====================
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

    stopFly()

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

        if not root.Parent then
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

function stopFly()
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

    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if hum then
            hum.PlatformStand = false
        end
    end
end

-- ==================== GOD MODE ====================
local godCons = {}

local function connectGodChar(char)
    local hum = char:WaitForChild("Humanoid")

    local c1 = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if Settings.GodMode and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)

    table.insert(godCons, c1)
end

local function toggleGodMode()
    for _, c in ipairs(godCons) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(godCons)

    if Settings.GodMode then
        if LocalPlayer.Character then
            connectGodChar(LocalPlayer.Character)
        end

        table.insert(
            godCons,
            LocalPlayer.CharacterAdded:Connect(connectGodChar)
        )
    end
end

-- ==================== INSTANT RESPAWN ====================
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
        local hum = char:WaitForChild("Humanoid")

        local diedConnection = hum.Died:Connect(function()
            task.wait(0.1)

            if Settings.InstantRespawn then
                pcall(function()
                    LocalPlayer:LoadCharacter()
                end)
            end
        end)

        table.insert(respawnCons, diedConnection)
    end)

    table.insert(respawnCons, connection)
end

-- ==================== REMOTE SCANNER ====================
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
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(allRemotes, obj)
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(allRemotes, obj)
            end
        end
    end

    cachedRemotes = allRemotes

    return cachedRemotes
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

-- ==================== KILL AURA ====================
local kaConn

local function getRemote()
    if Settings.KillAuraRemote == "" then
        return nil
    end

    local remote = ReplicatedStorage:FindFirstChild(
        Settings.KillAuraRemote
    )

    if not remote then
        remote = LocalPlayer:FindFirstChild(
            Settings.KillAuraRemote
        )
    end

    if not remote then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("RemoteEvent")
                and obj.Name == Settings.KillAuraRemote then

                return obj
            end
        end
    end

    return remote
end

local function getTargets()
    local targets = {}

    for _, plr in ipairs(Players:GetPlayers()) do
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

    if Settings.KillAuraNPC then
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model")
                and not Players:GetPlayerFromCharacter(model) then

                local hum = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")

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

        local myRoot = char:FindFirstChild("HumanoidRootPart")

        if not myRoot then
            return
        end

        local targets = getTargets()
        local remote = getRemote()

        for _, target in ipairs(targets) do
            local distance = (
                myRoot.Position
                - target.RootPart.Position
            ).Magnitude

            if distance <= Settings.KillAuraRange then
                if target.IsPlayer then
                    pcall(function()
                        target.Humanoid:TakeDamage(
                            Settings.KillAuraDamage
                        )
                    end)
                elseif remote then
                    local args = {}

                    for _, arg in ipairs(
                        Settings.KillAuraRemoteArgs
                        :gsub("%s+", "")
                        :split(",")
                    ) do
                        if arg == "target" then
                            table.insert(
                                args,
                                target.RootPart
                            )
                        elseif arg == "damage" then
                            table.insert(
                                args,
                                Settings.KillAuraDamage
                            )
                        elseif arg == "humanoid" then
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
                end
            end
        end
    end)
end

-- ==================== KILL MOBS ====================
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
            local hum = npc:FindFirstChildOfClass("Humanoid")
            local root = npc:FindFirstChild("HumanoidRootPart")

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

-- ==================== AUTO CHOP ====================
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

        local root = char:FindFirstChild("HumanoidRootPart")

        if not root then
            return
        end

        local folder = Workspace:FindFirstChild("Trees")

        if not folder then
            return
        end

        for _, tree in ipairs(folder:GetChildren()) do
            local main = tree:FindFirstChild("Main")

            if main
                and (root.Position - main.Position).Magnitude < 20 then

                pcall(function()
                    ReplicatedStorage.Events.Chop:FireServer(tree)
                end)
            end
        end
    end)
end

-- ==================== NOCLIP ====================
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

        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- ==================== FORCE FIELD ====================
local function updateForceField()
    local char = LocalPlayer.Character

    if not char then
        return
    end

    if Settings.ForceField then
        if not char:FindFirstChild("ForceField") then
            Instance.new("ForceField", char)
        end
    else
        local ff = char:FindFirstChild("ForceField")

        if ff then
            ff:Destroy()
        end
    end
end

-- ==================== AUTO CLICK ====================
local acClickConn

local function isMouseOverUI()
    local mouse = LocalPlayer:GetMouse()

    local guis = CoreGui:GetGuiObjectsAtPosition(
        mouse.X,
        mouse.Y
    )

    for _, gui in ipairs(guis) do
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

-- ==================== AUTO BALL ====================
local ballConn
local lastBallClick = 0

local function clickBall()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(
            0, 0, 0, true, game, 0
        )

        task.wait()

        VirtualInputManager:SendMouseButtonEvent(
            0, 0, 0, false, game, 0
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

        local root = char:FindFirstChild("HumanoidRootPart")

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

                if (
                    part.Position - root.Position
                ).Magnitude <= Settings.BallDistance then

                    clickBall()
                    lastBallClick = now
                    break
                end
            end
        end
    end)
end

-- ==================== AUTO F ====================
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

-- ==================== PLAYER ESP ====================
local espCons = {}

local function updateESP()
    for _, connection in ipairs(espCons) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(espCons)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local old = plr.Character:FindFirstChild("VIP_ESP")

            if old then
                old:Destroy()
            end
        end
    end

    if not Settings.ESP then
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "VIP_ESP"
            highlight.Adornee = plr.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.Parent = plr.Character

            local connection = plr.CharacterAdded:Connect(function(char)
                task.wait(0.5)

                if not Settings.ESP then
                    return
                end

                local newHighlight = Instance.new("Highlight")
                newHighlight.Name = "VIP_ESP"
                newHighlight.Adornee = char
                newHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                newHighlight.FillTransparency = 0.5
                newHighlight.OutlineColor = Color3.new(1, 1, 1)
                newHighlight.Parent = char
            end)

            table.insert(espCons, connection)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if Settings.ESP then
        plr.CharacterAdded:Wait()
        updateESP()
    end
end)

-- ==================== NPC ESP ====================
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
    if NPC_ESP_Objects[npc]
        or not isNPC(npc) then
        return
    end

    local hum = npc:FindFirstChildOfClass("Humanoid")
    local root = getRootESP(npc)

    if not hum or not root then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = ACCENT
    highlight.FillTransparency = 0.8
    highlight.Enabled = false
    highlight.Parent = npc

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(200, 52)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.Parent = billboard

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, 0, 0, 6)
    hpBg.Position = UDim2.fromOffset(0, 20)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    hpBg.Parent = billboard

    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)

    local hpBar = Instance.new("Frame")
    hpBar.Size = UDim2.fromScale(1, 1)
    hpBar.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    hpBar.Parent = hpBg

    Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 3)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 16)
    infoLabel.Position = UDim2.fromOffset(0, 28)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 9
    infoLabel.Parent = billboard

    NPC_ESP_Objects[npc] = {
        Highlight = highlight,
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthBarBg = hpBg,
        HealthBar = hpBar,
        InfoLabel = infoLabel,
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
        local playerRoot =
            LocalPlayer.Character
            and getRootESP(LocalPlayer.Character)

        for npc, data in pairs(NPC_ESP_Objects) do
            if not npc.Parent then
                removeNPC_ESP(npc)
                continue
            end

            if not data.Humanoid
                or not data.Root then
                removeNPC_ESP(npc)
                continue
            end

            local alive = data.Humanoid.Health > 0

            local distance = playerRoot
                and (
                    playerRoot.Position
                    - data.Root.Position
                ).Magnitude
                or math.huge

            local visible =
                Settings.NPC_ESP
                and distance <= Settings.NPC_ESP_Range

            if Settings.NPC_ESP_HideDead and not alive then
                visible = false
            end

            data.Highlight.Enabled = visible
            data.Billboard.Enabled = visible

            if visible then
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
                            .. math.floor(data.Humanoid.Health)
                            .. " HP"
                    end

                    data.InfoLabel.Visible = true
                else
                    data.InfoLabel.Visible = false
                end
            end
        end
    end
end)

-- ==================== HITBOX ====================
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

-- ==================== TELEPORT ====================
local function teleportToMouse()
    local mouse = LocalPlayer:GetMouse()

    if not mouse then
        return
    end

    local char = LocalPlayer.Character

    if char then
        local root = char:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = CFrame.new(mouse.Hit.Position)
        end
    end
end

-- ==================== WALK SPEED ====================
local function updateWalkSpeed()
    local char = LocalPlayer.Character

    if not char then
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")

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

-- ==================== FIND PLAYER ====================
local function findPlayer(name)
    name = tostring(name or "")
        :gsub("%s+", "")
        :lower()

    if name == "" then
        return nil
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():match("^" .. name) then
            return plr
        end
    end

    return nil
end

-- ==================== FE KILL ====================
local function executeFEKill(targetName)
    local target = findPlayer(targetName)

    if not target or not target.Character then
        notify("Kill", "រកមិនឃើញគោលដៅ", 3)
        return
    end

    local char =
        LocalPlayer.Character
        or LocalPlayer.CharacterAdded:Wait()

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not root or not hum then
        notify("Kill", "តួអង្គមិនទាន់រួចរាល់", 3)
        return
    end

    local savepos = root.CFrame

    local torso =
        char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")

    if not torso then
        notify("Kill", "គ្មាន Torso", 3)
        return
    end

    torso.Anchored = true

    local hat = char:FindFirstChildOfClass("Accessory")

    if not hat then
        torso.Anchored = false
        notify("Kill", "ត្រូវការមួក", 3)
        return
    end

    local handle = hat:FindFirstChild("Handle")

    if not handle then
        torso.Anchored = false
        notify("Kill", "មួកគ្មាន Handle", 3)
        return
    end

    local tool = Instance.new("Tool")
    tool.Parent = LocalPlayer.Backpack

    handle.Parent = tool
    handle.Massless = true

    tool.GripPos = Vector3.new(0, 9e99, 0)
    tool.Parent = char

    repeat
        task.wait()
    until char:FindFirstChildOfClass("Tool")

    tool.Grip = CFrame.new()
    torso.Anchored = false

    local targetRoot =
        target.Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not targetRoot then
        handle.Parent = hat
        handle.Massless = false
        tool:Destroy()
        return
    end

    repeat
        task.wait()

        if not char
            or not char:FindFirstChild("HumanoidRootPart") then
            break
        end

        char.HumanoidRootPart.CFrame =
            targetRoot.CFrame

        local targetHum =
            target.Character
            and target.Character:FindFirstChildOfClass("Humanoid")

        if not targetHum then
            break
        end

        if targetHum.Health <= 0 then
            break
        end

        if hum.Health <= 0 then
            break
        end

    until target.Parent ~= Players

    if char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):UnequipTools()
    end

    handle.Parent = hat
    handle.Massless = false

    tool:Destroy()

    if char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = savepos
    end

    notify("Kill", "បានសម្លាប់ " .. targetName, 3)
end

-- ==================== FLING ====================
local function SkidFling(targetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid =
        Character
        and Character:FindFirstChildOfClass("Humanoid")

    local RootPart =
        Humanoid
        and Humanoid.RootPart

    if not Character
        or not Humanoid
        or not RootPart then

        notify("Fling", "តួអង្គមិនរួចរាល់", 3)
        return
    end

    local TCharacter = targetPlayer.Character

    if not TCharacter then
        return
    end

    local THumanoid =
        TCharacter:FindFirstChildOfClass("Humanoid")

    local TRootPart =
        THumanoid
        and THumanoid.RootPart

    local THead =
        TCharacter:FindFirstChild("Head")

    local Accessory =
        TCharacter:FindFirstChildOfClass("Accessory")

    local Handle =
        Accessory
        and Accessory:FindFirstChild("Handle")

    if RootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end

    if THumanoid
        and THumanoid.Sit
        and not Settings.FlingAll then

        notify("Fling", "កំពុងអង្គុយ", 3)
        return
    end

    if THead then
        Workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then
        Workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid then
        Workspace.CurrentCamera.CameraSubject = THumanoid
    end

    if not TCharacter:FindFirstChildWhichIsA("BasePart") then
        return
    end

    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame =
            CFrame.new(BasePart.Position)
            * Pos
            * Ang

        Character:SetPrimaryPartCFrame(
            CFrame.new(BasePart.Position)
            * Pos
            * Ang
        )

        RootPart.Velocity =
            Vector3.new(9e7, 9e8, 9e7)

        RootPart.RotVelocity =
            Vector3.new(9e8, 9e8, 9e8)
    end

    local SFBasePart = function(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0

        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle += 100

                    FPos(
                        BasePart,
                        CFrame.new(0, 1.5, 0)
                            + THumanoid.MoveDirection
                            * BasePart.Velocity.Magnitude
                            / 1.25,
                        CFrame.Angles(
                            math.rad(Angle),
                            0,
                            0
                        )
                    )

                    task.wait()

                    FPos(
                        BasePart,
                        CFrame.new(0, -1.5, 0)
                            + THumanoid.MoveDirection
                            * BasePart.Velocity.Magnitude
                            / 1.25,
                        CFrame.Angles(
                            math.rad(Angle),
                            0,
                            0
                        )
                    )

                    task.wait()

                    FPos(
                        BasePart,
                        CFrame.new(2.25, 1.5, -2.25)
                            + THumanoid.MoveDirection
                            * BasePart.Velocity.Magnitude
                            / 1.25,
                        CFrame.Angles(
                            math.rad(Angle),
                            0,
                            0
                        )
                    )

                    task.wait()

                    FPos(
                        BasePart,
                        CFrame.new(-2.25, -1.5, 2.25)
                            + THumanoid.MoveDirection
                            * BasePart.Velocity.Magnitude
                            / 1.25,
                        CFrame.Angles(
                            math.rad(Angle),
                            0,
                            0
                        )
                    )

                    task.wait()
                else
                    FPos(
                        BasePart,
                        CFrame.new(
                            0,
                            1.5,
                            THumanoid.WalkSpeed
                        ),
                        CFrame.Angles(
                            math.rad(90),
                            0,
                            0
                        )
                    )

                    task.wait()

                    FPos(
                        BasePart,
                        CFrame.new(
                            0,
                            -1.5,
                            -THumanoid.WalkSpeed
                        ),
                        CFrame.Angles(0, 0, 0)
                    )

                    task.wait()
                end
            else
                break
            end

        until BasePart.Velocity.Magnitude > 500
            or BasePart.Parent ~= TCharacter
            or targetPlayer.Parent ~= Players
            or TCharacter ~= targetPlayer.Character
            or THumanoid.Sit
            or Humanoid.Health <= 0
            or tick() > Time + TimeToWait
    end

    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Parent = RootPart
    BV.Velocity =
        Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce =
        Vector3.new(math.huge, math.huge, math.huge)

    Humanoid:SetStateEnabled(
        Enum.HumanoidStateType.Seated,
        false
    )

    if TRootPart and THead then
        if (
            TRootPart.Position - THead.Position
        ).Magnitude > 5 then
            SFBasePart(THead)
        else
            SFBasePart(TRootPart)
        end
    elseif TRootPart then
        SFBasePart(TRootPart)
    elseif THead then
        SFBasePart(THead)
    elseif Handle then
        SFBasePart(Handle)
    end

    BV:Destroy()

    Humanoid:SetStateEnabled(
        Enum.HumanoidStateType.Seated,
        true
    )

    Workspace.CurrentCamera.CameraSubject = Humanoid

    if getgenv().OldPos then
        repeat
            RootPart.CFrame =
                getgenv().OldPos
                * CFrame.new(0, 0.5, 0)

            Character:SetPrimaryPartCFrame(
                getgenv().OldPos
                * CFrame.new(0, 0.5, 0)
            )

            Humanoid:ChangeState(
                Enum.HumanoidStateType.GettingUp
            )

            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.zero
                    part.RotVelocity = Vector3.zero
                end
            end

            task.wait()

        until (
            RootPart.Position
            - getgenv().OldPos.Position
        ).Magnitude < 25
    end
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
        if plr ~= LocalPlayer and plr.Character then
            task.spawn(function()
                SkidFling(plr)
            end)
        end
    end
end

-- ==================== INFINITE JUMP ====================
UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJumpOrig then
        return
    end

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum
        and hum:GetState()
            ~= Enum.HumanoidStateType.Jumping then

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

            if char then
                local hum =
                    char:FindFirstChildOfClass("Humanoid")

                if hum then
                    hum:ChangeState(
                        Enum.HumanoidStateType.Jumping
                    )
                end
            end
        end)
end

-- ==================== RAINBOW ====================
local function rainbowColor(speed, offset)
    local hue =
        (tick() * (speed or 1) + (offset or 0)) % 1

    return Color3.fromHSV(hue, 1, 1)
end

-- ==================== BEEP ====================
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

-- ==================== GUI ====================
local function createUI(imageAsset)

    if CoreGui:FindFirstChild("MKRA_Hub") then
        CoreGui.MKRA_Hub:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MKRA_Hub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    -- ==================== FLOAT BUTTON ====================
    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.fromOffset(46, 46)
    toggleBtn.Position = UDim2.new(
        0,
        15,
        0.5,
        -23
    )
    toggleBtn.BackgroundColor3 =
        Color3.fromRGB(20, 20, 20)
    toggleBtn.Image =
        imageAsset ~= ""
        and imageAsset
        or DEFAULT_IMAGE
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Parent = gui

    Instance.new("UICorner", toggleBtn).CornerRadius =
        UDim.new(1, 0)

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Thickness = 3
    toggleStroke.Parent = toggleBtn

    -- ==================== MAIN ====================
    local main = Instance.new("CanvasGroup")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(280, 450)
    main.Position = UDim2.new(
        0.5,
        -140,
        0.5,
        -225
    )
    main.BackgroundColor3 =
        Color3.fromRGB(15, 15, 15)
    main.BorderSizePixel = 0
    main.Active = true
    main.GroupTransparency = 1
    main.Visible = false
    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius =
        UDim.new(0, 10)

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 2
    mainStroke.Parent = main

    -- ==================== BACKGROUND IMAGE ====================
    local bg = Instance.new("ImageLabel")
    bg.Name = "Background"
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundTransparency = 1
    bg.Image =
        imageAsset ~= ""
        and imageAsset
        or DEFAULT_IMAGE
    bg.ImageTransparency = 0.35
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ZIndex = 0
    bg.Parent = main

    Instance.new("UICorner", bg).CornerRadius =
        UDim.new(0, 10)

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 =
        Color3.fromRGB(10, 10, 12)
    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Parent = main

    Instance.new("UICorner", overlay).CornerRadius =
        UDim.new(0, 10)

    -- ==================== RAINBOW TOP ====================
    local topRainbow = Instance.new("Frame")
    topRainbow.Size = UDim2.new(1, 0, 0, 3)
    topRainbow.BackgroundTransparency = 1
    topRainbow.ZIndex = 10
    topRainbow.Parent = main

    for i = 0, 59 do
        local seg = Instance.new("Frame")
        seg.Size = UDim2.new(1 / 60, 0, 1, 0)
        seg.Position =
            UDim2.new(i / 60, 0, 0, 0)
        seg.BackgroundColor3 =
            rainbowColor(0.3, i / 60)
        seg.BorderSizePixel = 0
        seg.Parent = topRainbow
    end

    -- ==================== TITLE BAR ====================
    local titleBar = Instance.new("Frame")
    titleBar.Name = "DragBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.fromOffset(0, 3)
    titleBar.BackgroundColor3 =
        Color3.fromRGB(25, 25, 25)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 20
    titleBar.Parent = main

    Instance.new("UICorner", titleBar).CornerRadius =
        UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -35, 1, 0)
    title.Position = UDim2.fromOffset(8, 0)
    title.BackgroundTransparency = 1
    title.Text = "MKRA Hub VIP v4.2"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 21
    title.Parent = titleBar

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.fromOffset(24, 24)
    minimizeBtn.Position =
        UDim2.new(1, -27, 0, 3)
    minimizeBtn.BackgroundColor3 =
        Color3.fromRGB(200, 50, 50)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 =
        Color3.new(1, 1, 1)
    minimizeBtn.Font =
        Enum.Font.SourceSansBold
    minimizeBtn.TextSize = 16
    minimizeBtn.ZIndex = 22
    minimizeBtn.Parent = titleBar

    Instance.new("UICorner", minimizeBtn).CornerRadius =
        UDim.new(0, 5)

    -- ==================== TABS ====================
    local tabFrame = Instance.new("Frame")
    tabFrame.Size =
        UDim2.new(1, -8, 0, 24)
    tabFrame.Position =
        UDim2.fromOffset(4, 36)
    tabFrame.BackgroundColor3 =
        Color3.fromRGB(30, 30, 30)
    tabFrame.BorderSizePixel = 0
    tabFrame.ZIndex = 20
    tabFrame.Parent = main

    Instance.new("UICorner", tabFrame).CornerRadius =
        UDim.new(0, 6)

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

    local tabContainers = {}

    local contentFrame = Instance.new("Frame")
    contentFrame.Size =
        UDim2.new(1, -8, 1, -100)
    contentFrame.Position =
        UDim2.fromOffset(4, 64)
    contentFrame.BackgroundColor3 =
        Color3.fromRGB(20, 20, 20)
    contentFrame.BorderSizePixel = 0
    contentFrame.ZIndex = 5
    contentFrame.Parent = main

    Instance.new("UICorner", contentFrame).CornerRadius =
        UDim.new(0, 8)

    for i, tabName in ipairs(tabs) do

        local btn = Instance.new("TextButton")
        btn.Size =
            UDim2.new(1 / #tabs, 0, 1, 0)
        btn.Position =
            UDim2.new((i - 1) / #tabs, 0, 0, 0)

        btn.Text = tabName
        btn.BackgroundColor3 =
            Color3.fromRGB(50, 50, 50)
        btn.TextColor3 =
            Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 9
        btn.ZIndex = 21
        btn.Parent = tabFrame

        Instance.new("UICorner", btn).CornerRadius =
            UDim.new(0, 4)

        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.fromScale(1, 1)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.ScrollBarThickness = 3
        container.CanvasSize =
            UDim2.new(0, 0, 0, 0)
        container.Visible = false
        container.ZIndex = 6
        container.Parent = contentFrame

        tabContainers[tabName] = container

        btn.MouseButton1Click:Connect(function()
            for _, c in pairs(tabContainers) do
                c.Visible = false
            end

            container.Visible = true
        end)
    end

    tabContainers["Move"].Visible = true

    -- ==================== UI HELPERS ====================
    local function getNextY(container)
        local count = 0

        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("GuiObject") then
                count += 1
            end
        end

        return count * 30 + 4
    end

    local function updateCanvas(container)
        local count = 0

        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("GuiObject") then
                count += 1
            end
        end

        container.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                count * 30 + 10
            )
    end

    local function addToggle(
        container,
        text,
        default,
        callback
    )
        local button = Instance.new("TextButton")

        button.Size =
            UDim2.new(1, -8, 0, 26)

        button.Position =
            UDim2.fromOffset(
                4,
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
        button.TextSize = 10
        button.ZIndex = 10
        button.Parent = container

        Instance.new("UICorner", button).CornerRadius =
            UDim.new(0, 5)

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

        updateCanvas(container)
    end

    local function addButton(
        container,
        text,
        callback
    )
        local button = Instance.new("TextButton")

        button.Size =
            UDim2.new(1, -8, 0, 26)

        button.Position =
            UDim2.fromOffset(
                4,
                getNextY(container)
            )

        button.BackgroundColor3 =
            Color3.fromRGB(70, 70, 70)

        button.Text = text
        button.TextColor3 =
            Color3.new(1, 1, 1)

        button.Font = Enum.Font.Gotham
        button.TextSize = 10
        button.ZIndex = 10
        button.Parent = container

        Instance.new("UICorner", button).CornerRadius =
            UDim.new(0, 5)

        button.MouseButton1Click:Connect(function()
            playBeep()
            callback()
        end)

        updateCanvas(container)
    end

    local function addTextBox(
        container,
        label,
        default,
        callback
    )
        local frame = Instance.new("Frame")

        frame.Size =
            UDim2.new(1, -8, 0, 28)

        frame.Position =
            UDim2.fromOffset(
                4,
                getNextY(container)
            )

        frame.BackgroundTransparency = 1
        frame.ZIndex = 10
        frame.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size =
            UDim2.fromOffset(80, 28)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 =
            Color3.new(1, 1, 1)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment =
            Enum.TextXAlignment.Left
        lbl.ZIndex = 11
        lbl.Parent = frame

        local box = Instance.new("TextBox")
        box.Size =
            UDim2.new(1, -85, 1, 0)
        box.Position =
            UDim2.fromOffset(85, 0)

        box.BackgroundColor3 =
            Color3.fromRGB(50, 50, 50)

        box.TextColor3 =
            Color3.new(1, 1, 1)

        box.PlaceholderColor3 =
            Color3.fromRGB(170, 170, 170)

        box.Text = default
        box.Font = Enum.Font.Gotham
        box.TextSize = 10
        box.ClearTextOnFocus = false
        box.ZIndex = 11
        box.Parent = frame

        Instance.new("UICorner", box).CornerRadius =
            UDim.new(0, 4)

        box.FocusLost:Connect(function()
            callback(box.Text)
        end)

        updateCanvas(container)

        return box
    end

    -- ==================== MOVE ====================
    addToggle(
        tabContainers["Move"],
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
        tabContainers["Move"],
        "Speed",
        "120",
        function(v)
            Settings.FlySpeed =
                tonumber(v)
                or 120
        end
    )

    addToggle(
        tabContainers["Move"],
        "Boost",
        false,
        function(v)
            Settings.BoostMode = v
        end
    )

    addToggle(
        tabContainers["Move"],
        "Noclip",
        false,
        function(v)
            Settings.Noclip = v
            toggleNoclip()
        end
    )

    addTextBox(
        tabContainers["Move"],
        "WS Mult",
        "1",
        function(v)
            Settings.SpeedBoostMultiplier =
                tonumber(v)
                or 1

            updateWalkSpeed()
        end
    )

    addToggle(
        tabContainers["Move"],
        "Inf Jump",
        false,
        function(v)
            Settings.InfiniteJumpOrig = v
        end
    )

    -- ==================== COMBAT ====================
    addToggle(
        tabContainers["Combat"],
        "Kill Aura",
        false,
        function(v)
            Settings.KillAura = v
            toggleKillAura()
        end
    )

    addTextBox(
        tabContainers["Combat"],
        "Range",
        "30",
        function(v)
            Settings.KillAuraRange =
                tonumber(v)
                or 30
        end
    )

    addTextBox(
        tabContainers["Combat"],
        "Damage",
        "30",
        function(v)
            Settings.KillAuraDamage =
                tonumber(v)
                or 30
        end
    )

    addToggle(
        tabContainers["Combat"],
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
        tabContainers["Combat"],
        "Remote",
        "",
        function(v)
            Settings.KillAuraRemote = v
        end
    )

    addTextBox(
        tabContainers["Combat"],
        "Args",
        "target,damage",
        function(v)
            Settings.KillAuraRemoteArgs = v
        end
    )

    addToggle(
        tabContainers["Combat"],
        "Kill Mobs",
        false,
        function(v)
            Settings.KillMobs = v
            toggleKillMobs()
        end
    )

    addToggle(
        tabContainers["Combat"],
        "Hitbox",
        false,
        function(v)
            Settings.HitboxSize =
                v and 10 or 2
        end
    )

    addToggle(
        tabContainers["Combat"],
        "AutoClick",
        false,
        function(v)
            Settings.AutoClick = v
            toggleAutoClick()
        end
    )

    addToggle(
        tabContainers["Combat"],
        "ForceField",
        false,
        function(v)
            Settings.ForceField = v
            updateForceField()
        end
    )

    addToggle(
        tabContainers["Combat"],
        "Ball Click",
        false,
        function(v)
            Settings.AutoClickBall = v
            toggleAutoClickBall()
        end
    )

    addTextBox(
        tabContainers["Combat"],
        "BallDist",
        "5",
        function(v)
            Settings.BallDistance =
                tonumber(v)
                or 5
        end
    )

    -- ==================== FARM ====================
    addToggle(
        tabContainers["Farm"],
        "Auto Chop",
        false,
        function(v)
            Settings.AutoChop = v
            toggleAutoChop()
        end
    )

    addTextBox(
        tabContainers["Farm"],
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
        tabContainers["Farm"],
        "InfJump99",
        false,
        function(v)
            Settings.InfiniteJump99 = v
            enableInfiniteJump99()
        end
    )

    -- ==================== VIP ====================
    addButton(
        tabContainers["VIP"],
        "Teleport",
        teleportToMouse
    )

    addToggle(
        tabContainers["VIP"],
        "Player ESP",
        false,
        function(v)
            Settings.ESP = v
            updateESP()
        end
    )

    addButton(
        tabContainers["VIP"],
        "Heal",
        function()
            local char = LocalPlayer.Character

            if char then
                local hum =
                    char:FindFirstChildOfClass(
                        "Humanoid"
                    )

                if hum then
                    hum.Health =
                        hum.MaxHealth
                end
            end
        end
    )

    addToggle(
        tabContainers["VIP"],
        "God Mode",
        false,
        function(v)
            Settings.GodMode = v
            toggleGodMode()
        end
    )

    addToggle(
        tabContainers["VIP"],
        "Instant Resp",
        false,
        function(v)
            Settings.InstantRespawn = v
            toggleInstantRespawn()
        end
    )

    addButton(
        tabContainers["VIP"],
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
        tabContainers["VIP"],
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
        tabContainers["VIP"],
        "Spawn Cash",
        function()
            local addMoney =
                ReplicatedStorage:FindFirstChild(
                    "AddMoney"
                )

            if addMoney then
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
        addTextBox(
            tabContainers["VIP"],
            "Kill",
            "",
            function() end
        )

    killBox.PlaceholderText =
        "ឈ្មោះអ្នកលេង"

    addButton(
        tabContainers["VIP"],
        "FE KILL",
        function()
            executeFEKill(
                killBox.Text
            )
        end
    )

    local flingBox =
        addTextBox(
            tabContainers["VIP"],
            "Fling",
            "",
            function() end
        )

    flingBox.PlaceholderText =
        "ឈ្មោះអ្នកលេង"

    addButton(
        tabContainers["VIP"],
        "FLING",
        function()
            executeFling(
                flingBox.Text
            )
        end
    )

    addToggle(
        tabContainers["VIP"],
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
        tabContainers["VIP"],
        "Auto F",
        false,
        function(v)
            Settings.AutoF = v
            toggleAutoF()
        end
    )

    addToggle(
        tabContainers["VIP"],
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

            if hum then
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
        end
    )

    -- ==================== VISUAL ====================
    addTextBox(
        tabContainers["Visual"],
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
        tabContainers["Visual"],
        "FullBright",
        false,
        function(v)
            if v then
                Lighting.Brightness = 2
                Lighting.ClockTime = 12
                Lighting.FogEnd = 100000
            else
                Lighting.Brightness = 0.5
                Lighting.ClockTime = 0
                Lighting.FogEnd = 1000
            end
        end
    )

    -- ==================== ESP ====================
    addToggle(
        tabContainers["ESP"],
        "NPC ESP",
        false,
        function(v)
            Settings.NPC_ESP = v
        end
    )

    addToggle(
        tabContainers["ESP"],
        "Name",
        true,
        function(v)
            Settings.NPC_ESP_Name = v
        end
    )

    addToggle(
        tabContainers["ESP"],
        "Health",
        true,
        function(v)
            Settings.NPC_ESP_Health = v
        end
    )

    addToggle(
        tabContainers["ESP"],
        "Dist",
        true,
        function(v)
            Settings.NPC_ESP_Distance = v
        end
    )

    addToggle(
        tabContainers["ESP"],
        "HideDead",
        true,
        function(v)
            Settings.NPC_ESP_HideDead = v
        end
    )

    addTextBox(
        tabContainers["ESP"],
        "Range",
        "200",
        function(v)
            Settings.NPC_ESP_Range =
                tonumber(v)
                or 200
        end
    )

    -- ==================== CONTROL ====================
    addToggle(
        tabContainers["Ctrl"],
        "VIP Freeze (Hold)",
        false,
        function(v)
            Settings.VIPFreezeHold = v
            toggleVIPFreezeHold()
        end
    )

    addToggle(
        tabContainers["Ctrl"],
        "VIP Freeze (Kill)",
        false,
        function(v)
            Settings.VIPFreezeKill = v
            toggleVIPFreezeKill()
        end
    )

    -- ==================== UTIL ====================
    addButton(
        tabContainers["Util"],
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
        tabContainers["Util"],
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

                for _, server in ipairs(
                    data.data or {}
                ) do
                    if server.playing
                        and server.id ~= game.JobId then

                        table.insert(
                            ids,
                            server.id
                        )
                    end
                end

                if #ids > 0 then
                    TeleportService:
                        TeleportToPlaceInstance(
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

    -- ==================== CREDIT ====================
    local creditLabel = Instance.new("TextLabel")
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
    creditLabel.ZIndex = 20
    creditLabel.Parent = main

    -- ==================== BOTTOM RAINBOW ====================
    local bottomRainbow = Instance.new("Frame")
    bottomRainbow.Size =
        UDim2.new(1, 0, 0, 3)
    bottomRainbow.Position =
        UDim2.new(0, 0, 1, -3)
    bottomRainbow.BackgroundTransparency = 1
    bottomRainbow.ZIndex = 20
    bottomRainbow.Parent = main

    for i = 0, 59 do
        local seg = Instance.new("Frame")
        seg.Size =
            UDim2.new(1 / 60, 0, 1, 0)
        seg.Position =
            UDim2.new(i / 60, 0, 0, 0)
        seg.BackgroundColor3 =
            rainbowColor(0.3, i / 60)
        seg.BorderSizePixel = 0
        seg.Parent = bottomRainbow
    end

    -- ==================== SPARKLES ====================
    for _ = 1, 8 do
        local spark = Instance.new("Frame")

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
        spark.ZIndex = 15
        spark.Parent = main

        Instance.new("UICorner", spark).CornerRadius =
            UDim.new(1, 0)
    end

    -- ==================== ANIMATION ====================
    task.spawn(function()
        while gui.Parent do
            task.wait(0.03)

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

            for i, seg in ipairs(
                bottomRainbow:GetChildren()
            ) do
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

            toggleStroke.Color =
                Color3.fromHSV(
                    hue,
                    1,
                    1
                )

            mainStroke.Color =
                Color3.fromHSV(
                    hue,
                    1,
                    1
                )
        end
    end)

    -- ==================== MINIMIZE ====================
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
            UDim2.fromOffset(40, 40)

        restoreButton.Position =
            UDim2.new(
                main.Position.X.Scale,
                main.Position.X.Offset,
                main.Position.Y.Scale,
                main.Position.Y.Offset
            )

        restoreButton.BackgroundColor3 =
            rainbowColor(1, 0)

        restoreButton.Text = "+"
        restoreButton.TextColor3 =
            Color3.new(1, 1, 1)

        restoreButton.Font =
            Enum.Font.SourceSansBold

        restoreButton.TextSize = 22
        restoreButton.Active = true
        restoreButton.ZIndex = 100
        restoreButton.Parent = gui

        Instance.new("UICorner", restoreButton).CornerRadius =
            UDim.new(0, 8)

        restoreButton.MouseButton1Click:Connect(function()
            main.Visible = true

            restoreButton:Destroy()
            restoreButton = nil
        end)

        task.spawn(function()
            while restoreButton
                and restoreButton.Parent do

                restoreButton.BackgroundColor3 =
                    rainbowColor(1, 0)

                task.wait(0.05)
            end
        end)
    end

    minimizeBtn.MouseButton1Click:Connect(
        minimizeUI
    )

    -- ==================== FULL DRAG SYSTEM ====================
    -- Mobile + PC
    -- Drag in ALL directions
    -- Uses TitleBar as the drag handle

    local function makeDraggable(handle, frame)
        local dragging = false
        local dragStart = nil
        local startPosition = nil

        handle.InputBegan:Connect(function(input)
            if input.UserInputType
                == Enum.UserInputType.MouseButton1
                or input.UserInputType
                == Enum.UserInputType.Touch then

                dragging = true
                dragStart = input.Position
                startPosition = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState
                        == Enum.UserInputState.End then

                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            if input.UserInputType
                == Enum.UserInputType.MouseMovement
                or input.UserInputType
                == Enum.UserInputType.Touch then

                local delta =
                    input.Position - dragStart

                frame.Position =
                    UDim2.new(
                        startPosition.X.Scale,
                        startPosition.X.Offset
                            + delta.X,

                        startPosition.Y.Scale,
                        startPosition.Y.Offset
                            + delta.Y
                    )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType
                == Enum.UserInputType.MouseButton1
                or input.UserInputType
                == Enum.UserInputType.Touch then

                dragging = false
            end
        end)
    end

    makeDraggable(titleBar, main)

    -- ==================== FLOAT BUTTON DRAG ====================
    -- Separate drag system so clicking still opens the GUI.

    local toggleDragging = false
    local toggleMoved = false
    local toggleStart = nil
    local toggleStartPosition = nil

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType
            == Enum.UserInputType.MouseButton1
            or input.UserInputType
            == Enum.UserInputType.Touch then

            toggleDragging = true
            toggleMoved = false
            toggleStart = input.Position
            toggleStartPosition = toggleBtn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not toggleDragging then
            return
        end

        if input.UserInputType
            == Enum.UserInputType.MouseMovement
            or input.UserInputType
            == Enum.UserInputType.Touch then

            local delta =
                input.Position - toggleStart

            if delta.Magnitude > 5 then
                toggleMoved = true
            end

            toggleBtn.Position =
                UDim2.new(
                    toggleStartPosition.X.Scale,
                    toggleStartPosition.X.Offset
                        + delta.X,

                    toggleStartPosition.Y.Scale,
                    toggleStartPosition.Y.Offset
                        + delta.Y
                )
        end
    end)

    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType
            == Enum.UserInputType.MouseButton1
            or input.UserInputType
            == Enum.UserInputType.Touch then

            if toggleDragging
                and not toggleMoved then

                if main.Visible then
                    local anim =
                        TweenService:Create(
                            main,
                            TweenInfo.new(0.25),
                            {
                                GroupTransparency = 1
                            }
                        )

                    anim:Play()

                    TweenService:Create(
                        toggleBtn,
                        TweenInfo.new(0.25),
                        {
                            Rotation = 0
                        }
                    ):Play()

                    anim.Completed:Wait()

                    main.Visible = false
                else
                    main.Visible = true

                    main.GroupTransparency = 1

                    TweenService:Create(
                        main,
                        TweenInfo.new(0.25),
                        {
                            GroupTransparency = 0
                        }
                    ):Play()

                    TweenService:Create(
                        toggleBtn,
                        TweenInfo.new(0.25),
                        {
                            Rotation = 180
                        }
                    ):Play()
                end
            end

            toggleDragging = false
        end
    end)

    -- ==================== INITIAL STATE ====================
    main.Visible = false
    main.GroupTransparency = 1

    notify(
        "MKRA Hub",
        "Mobile Optimized VIP Freeze Ready!",
        3
    )
end

-- ==================== START ====================
task.spawn(function()
    local imageAsset = loadImage()

    createUI(imageAsset)
end)

-- ==================== CHARACTER RESPAWN ====================
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