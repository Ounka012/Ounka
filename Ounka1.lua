-- =========================================================================
-- [ 🌟🌟🌟 BY OUNCOPYBARA - ULTIMATE EDITION 🌟🌟🌟 ]
-- [ Combat + Farm + ESP + Movement + Jump + Noclip + Utilities ]
-- =========================================================================

local success, err = pcall(function()

-- =========================================================================
-- [ SERVICES ]
-- =========================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local SoundService      = game:GetService("SoundService")
local HttpService       = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local VirtualUser       = game:GetService("VirtualUser")
local LocalPlayer       = Players.LocalPlayer

-- =========================================================================
-- [ GUI PARENT ]
-- =========================================================================
local GUIParent
do
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then GUIParent = hui
    else GUIParent = LocalPlayer:WaitForChild("PlayerGui") end
end

pcall(function()
    for _, gui in pairs(GUIParent:GetChildren()) do
        if string.find(gui.Name, "ouncopybara") then gui:Destroy() end
    end
end)

-- =========================================================================
-- [ HELPERS - ASSET ]
-- =========================================================================
local function getAssetSafe(fileName)
    local ok, result = pcall(function()
        if getcustomasset then return getcustomasset(fileName) end
    end)
    if ok and result and result ~= "" then return result end
    ok, result = pcall(function()
        if getsynasset then return getsynasset(fileName) end
    end)
    if ok and result and result ~= "" then return result end
    return ""
end

local function downloadIfNeeded(url, fileName)
    pcall(function()
        if isfile and writefile and game.HttpGet then
            if not isfile(fileName) then writefile(fileName, game:HttpGet(url)) end
        end
    end)
end

-- =========================================================================
-- [ AUDIO + IMAGE ]
-- =========================================================================
task.spawn(function()
    pcall(function()
        downloadIfNeeded("https://files.catbox.moe/rtkvkd.mp3", "ouncopybara_intro_audio.mp3")
        local snd = getAssetSafe("ouncopybara_intro_audio.mp3")
        if snd == "" then return end
        local s = Instance.new("Sound")
        s.SoundId = snd
        s.Volume = 2
        s.Parent = SoundService
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
    end)
end)

local customAssetImage = ""
pcall(function()
    downloadIfNeeded("https://files.catbox.moe/ka5x56.jpg", "ouncopybara_custom_icon.jpg")
    customAssetImage = getAssetSafe("ouncopybara_custom_icon.jpg")
end)

-- =========================================================================
-- [ CONFIG - ULTIMATE ]
-- =========================================================================
local Config = {
    -- Farm
    BaseCFrames = {},
    ActiveBase = 1,
    IsAutoOn = false,
    IsStiffLegsOn = true,
    StiffDuration = 1.0,
    HoldDelay = 0.1,
    TweenSpeed = 0.15,
    StiffLegsRate = 15,
    NormalSpeed = 16,

    -- Combat
    IsCombatOn = false,
    CombatRange = 300,
    AttackCooldown = 0.2,
    TeleportOffset = 3,
    AttackCount = 3,
    CombatMode = "Behind",
    CombatTeamCheck = false,

    -- ESP
    IsESPOn = false,
    ESPColor = Color3.fromRGB(255, 105, 180),
    ESPTeamCheck = false,
    ESPDistance = false,
    ESPHealth = false,

    -- Movement
    IsSpeedOn = false,
    SpeedValue = 60,
    IsFlyOn = false,
    FlySpeed = 80,

    -- Jump
    IsInfiniteJump = false,
    IsAutoJump = false,
    AutoJumpDelay = 0.3,

    -- Noclip
    IsNoclipOn = false,
    NoclipMode = "Character",
    NoclipRange = 30,

    -- Utilities
    IsAntiAFK = true,
    IsAutoSell = false,
    AutoSellDelay = 5,
    IsAntiRagdoll = false,
    IsFullbright = false,
    IsAntiFling = true,

    -- Theme
    Theme = "Pink",
    Themes = {
        Pink     = {Main = Color3.fromRGB(30,20,25),  Accent = Color3.fromRGB(255,105,180), Btn = Color3.fromRGB(60,30,45),  Text = Color3.fromRGB(255,182,193)},
        Purple   = {Main = Color3.fromRGB(25,20,35),  Accent = Color3.fromRGB(170,0,255),    Btn = Color3.fromRGB(50,35,65),  Text = Color3.fromRGB(210,180,255)},
        Blue     = {Main = Color3.fromRGB(15,25,40),  Accent = Color3.fromRGB(0,170,255),    Btn = Color3.fromRGB(30,50,75),  Text = Color3.fromRGB(150,220,255)},
        Green    = {Main = Color3.fromRGB(15,30,20),  Accent = Color3.fromRGB(0,255,120),    Btn = Color3.fromRGB(25,60,40),  Text = Color3.fromRGB(150,255,180)},
        Red      = {Main = Color3.fromRGB(35,15,15),  Accent = Color3.fromRGB(255,50,50),    Btn = Color3.fromRGB(70,25,25),  Text = Color3.fromRGB(255,150,150)},
        Dark     = {Main = Color3.fromRGB(15,15,15),  Accent = Color3.fromRGB(220,220,220),  Btn = Color3.fromRGB(35,35,35),  Text = Color3.fromRGB(240,240,240)},
        Gold     = {Main = Color3.fromRGB(30,25,10),  Accent = Color3.fromRGB(255,200,0),    Btn = Color3.fromRGB(60,50,15),  Text = Color3.fromRGB(255,230,120)},
    },

    -- Keybinds
    ToggleKey = Enum.KeyCode.RightControl,
    CombatKey = Enum.KeyCode.RightShift,
    FarmKey   = Enum.KeyCode.RightAlt,
    JumpKey   = Enum.KeyCode.J,
    NoclipKey = Enum.KeyCode.N,
    FlyKey    = Enum.KeyCode.F,
    SpeedKey  = Enum.KeyCode.H,
}

-- =========================================================================
-- [ STATE VARIABLES ]
-- =========================================================================
local stiffThread = nil
local combatThread = nil
local espConnections = {}
local speedConn = nil
local flyConn = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil
local infJumpConn = nil
local autoJumpThread = nil
local noclipConn = nil
local antiAfkConn = nil
local updateStatus = nil
local isProcessing = false
local NotifyGui = nil

-- =========================================================================
-- [ NOTIFICATION SYSTEM ]
-- =========================================================================
local function notify(text, color)
    pcall(function()
        if not NotifyGui or not NotifyGui.Parent then
            NotifyGui = Instance.new("ScreenGui")
            NotifyGui.Name = "ouncopybara_notify"
            NotifyGui.Parent = GUIParent
            NotifyGui.ResetOnSpawn = false
            NotifyGui.IgnoreGuiInset = true
        end
        local frame = Instance.new("Frame", NotifyGui)
        frame.Size = UDim2.new(0, 280, 0, 42)
        frame.Position = UDim2.new(1, 20, 0, 20 + (#NotifyGui:GetChildren() - 1) * 48)
        frame.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = color or Color3.fromRGB(255, 105, 180)
        stroke.Thickness = 1.5

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(255, 182, 193)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true

        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart),
            {Position = UDim2.new(1, -300, 0, frame.Position.Y.Offset)}):Play()

        task.delay(3, function()
            pcall(function()
                TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(lbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                task.wait(0.35)
                frame:Destroy()
            end)
        end)
    end)
end

-- =========================================================================
-- [ CHARACTER HELPERS ]
-- =========================================================================
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function getHRP(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("HumanoidRootPart")
end

-- =========================================================================
-- [ SAFE ZONE CACHE ]
-- =========================================================================
local SafeZoneKeywords = {"safezone","safe_zone","safe zone","safearea","safe area","lobby"}
local SafeZoneParts = {}
local LastZoneScan = 0
local ZoneScanInterval = 5

local function refreshSafeZones()
    local now = tick()
    if now - LastZoneScan < ZoneScanInterval then return end
    LastZoneScan = now
    table.clear(SafeZoneParts)
    for _, obj in ipairs(workspace:GetChildren()) do
        pcall(function()
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = obj.Name:lower()
                for _, kw in ipairs(SafeZoneKeywords) do
                    if string.find(name, kw, 1, true) then
                        if obj:IsA("BasePart") then
                            table.insert(SafeZoneParts, obj)
                        else
                            local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if p then table.insert(SafeZoneParts, p) end
                        end
                        break
                    end
                end
            end
        end)
    end
end

local function isInsideSafeZone(character)
    if not character then return true end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    if #SafeZoneParts == 0 then return false end
    for _, part in ipairs(SafeZoneParts) do
        if part and part.Parent then
            if (hrp.Position - part.Position).Magnitude < 80 then return true end
        end
    end
    return false
end

-- =========================================================================
-- [ STIFF LEGS ]
-- =========================================================================
local function enableStiffLegs()
    local hrp, hum = getCharacter()
    if not hrp or not hum then return end
    Config.NormalSpeed = hum.WalkSpeed
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end)
    if stiffThread then pcall(function() task.cancel(stiffThread) end) end
    stiffThread = task.spawn(function()
        while Config.IsStiffLegsOn do
            local h, hu = getCharacter()
            if h and hu and hu.Health > 0 then
                pcall(function()
                    for _, t in ipairs(hu:GetPlayingAnimationTracks()) do t:Stop() end
                    hu.WalkSpeed = Config.NormalSpeed
                    hu.JumpPower = 0
                    hu.JumpHeight = 0
                end)
            end
            task.wait(1 / Config.StiffLegsRate)
        end
    end)
end

local function disableStiffLegs()
    Config.IsStiffLegsOn = false
    if stiffThread then pcall(function() task.cancel(stiffThread) end); stiffThread = nil end
    task.delay(0.1, function()
        local _, hum = getCharacter()
        if hum then
            pcall(function()
                hum.WalkSpeed = Config.NormalSpeed
                hum.JumpPower = 50
                hum.JumpHeight = 7.2
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end)
        end
    end)
end

-- =========================================================================
-- [ TELEPORT - SMOOTH ]
-- =========================================================================
local function smoothTeleport(hrp, targetCFrame, speed)
    if not hrp or not hrp.Parent then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    local ti = TweenInfo.new(speed or Config.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, ti, {CFrame = targetCFrame})
    tween:Play()
    local done = false
    tween.Completed:Connect(function() done = true end)
    local start = tick()
    while not done and (tick() - start) < 0.4 do task.wait() end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- =========================================================================
-- [ EGG FARM ]
-- =========================================================================
local function getActiveBaseCFrame()
    return Config.BaseCFrames[Config.ActiveBase] or Config.BaseCFrames[1]
end

local function handleSteal()
    if not Config.IsAutoOn or isProcessing then return end
    local baseCF = getActiveBaseCFrame()
    if not baseCF then return end
    local hrp, hum = getCharacter()
    if not hrp or not hum then return end
    isProcessing = true
    local EggLocation = hrp.CFrame
    if updateStatus then updateStatus("by ouncopybara: កំពុងលួចពង...", Color3.fromRGB(255, 105, 180)) end
    notify("🥚 កំពុងលួចពង!", Color3.fromRGB(255, 200, 100))
    task.spawn(function()
        task.wait(Config.HoldDelay)
        local wasStiff = Config.IsStiffLegsOn
        if wasStiff then enableStiffLegs() end
        smoothTeleport(hrp, baseCF)
        task.wait(Config.StiffDuration)
        smoothTeleport(hrp, EggLocation)
        task.wait(0.05)
        if not wasStiff then
            if stiffThread then pcall(function() task.cancel(stiffThread) end); stiffThread = nil end
            task.delay(0.1, function()
                local _, h = getCharacter()
                if h then pcall(function()
                    h.WalkSpeed = Config.NormalSpeed
                    h.JumpPower = 50
                    h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                end) end
            end)
        end
        isProcessing = false
    end)
end

-- =========================================================================
-- [ COMBAT ]
-- =========================================================================
local function findNearestTarget()
    local myHrp = getHRP(LocalPlayer)
    if not myHrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local tHrp = getHRP(plr)
            if tHrp then
                local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                if tHum and tHum.Health > 0 then
                    if not Config.CombatTeamCheck or plr.Team ~= LocalPlayer.Team then
                        local dist = (myHrp.Position - tHrp.Position).Magnitude
                        if dist < nearestDist and dist <= Config.CombatRange then
                            nearest = plr
                            nearestDist = dist
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function attackTarget(target)
    if not target or not target.Character then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end)
    pcall(function()
        local tChar = target.Character
        if not tChar then return end
        for _, obj in ipairs(tChar:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(fireproximityprompt, obj)
            elseif obj:IsA("ClickDetector") then
                pcall(fireclickdetector, obj)
            end
        end
    end)
end

local function getAttackCFrame(tHrp)
    local mode = Config.CombatMode
    if mode == "Behind" then
        local look = tHrp.CFrame.LookVector
        return CFrame.new(tHrp.Position - look * Config.TeleportOffset, tHrp.Position)
    elseif mode == "Front" then
        local look = tHrp.CFrame.LookVector
        return CFrame.new(tHrp.Position + look * Config.TeleportOffset, tHrp.Position)
    elseif mode == "Above" then
        return CFrame.new(tHrp.Position + Vector3.new(0, Config.TeleportOffset + 2, 0), tHrp.Position)
    elseif mode == "Orbit" then
        local angle = tick() * 3
        return CFrame.new(tHrp.Position + Vector3.new(math.cos(angle) * Config.TeleportOffset, 0, math.sin(angle) * Config.TeleportOffset), tHrp.Position)
    end
    local look = tHrp.CFrame.LookVector
    return CFrame.new(tHrp.Position - look * Config.TeleportOffset, tHrp.Position)
end

local function startCombat()
    if combatThread then pcall(function() task.cancel(combatThread) end) end
    combatThread = task.spawn(function()
        while Config.IsCombatOn do
            refreshSafeZones()
            local myHrp, myHum = getCharacter()
            if myHrp and myHum and myHum.Health > 0 then
                if isInsideSafeZone(LocalPlayer.Character) then
                    if updateStatus then updateStatus("by ouncopybara: ចេញ Safe Zone សិន!", Color3.fromRGB(255, 200, 100)) end
                else
                    local target = findNearestTarget()
                    if target and target.Character then
                        local tHrp = getHRP(target)
                        if tHrp then
                            smoothTeleport(myHrp, getAttackCFrame(tHrp), 0.08)
                            if updateStatus then updateStatus("by ouncopybara: វ៉ៃ " .. target.Name, Color3.fromRGB(255, 50, 100)) end
                            for i = 1, Config.AttackCount do
                                if not Config.IsCombatOn then break end
                                local th = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
                                if not th or th.Health <= 0 then break end
                                attackTarget(target)
                                task.wait(Config.AttackCooldown)
                            end
                        end
                    else
                        if updateStatus then updateStatus("by ouncopybara: រកគោលដៅមិនឃើញ...", Color3.fromRGB(200, 150, 200)) end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

local function stopCombat()
    Config.IsCombatOn = false
    if combatThread then pcall(function() task.cancel(combatThread) end); combatThread = nil end
end

-- =========================================================================
-- [ ESP SYSTEM ]
-- =========================================================================
local function createESP(plr)
    if not Config.IsESPOn then return end
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if espConnections[plr] then return end

    local highlight = Instance.new("Highlight")
    highli