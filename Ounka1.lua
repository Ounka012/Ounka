-- ============================================================
--   by ouncopybara | DELTA FIXED EDITION v8.2.0
--   Fixed: GUI parent (Delta safe), game loaded guard,
--          ESP range, aimbot fallback, topbar drag,
--          resetCharacter whitelist, cleanup bugs
-- ============================================================

-- DELTA BOOT GUARD ------------------------------------------------
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.4)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local SoundService      = game:GetService("SoundService")
local HttpService       = game:GetService("HttpService")
local PathfindingService= game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local function safeWait(inst, name, t)
    local ok, v = pcall(function() return inst:WaitForChild(name, t or 8) end)
    return ok and v or nil
end

local Camera = workspace.CurrentCamera or safeWait(workspace, "CurrentCamera", 5)
if not Camera then
    repeat task.wait(0.1) until workspace.CurrentCamera
    Camera = workspace.CurrentCamera
end

-- GUIParent (DELTA SAFE) ------------------------------------------
local GUIParent
do
    local ok1, h = pcall(function() return gethui() end)
    if ok1 and h then
        GUIParent = h
    else
        local ok2, c = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and c then
            GUIParent = c
        else
            GUIParent = safeWait(LocalPlayer, "PlayerGui", 10)
                or LocalPlayer:FindFirstChildOfClass("PlayerGui")
        end
    end
    if not GUIParent then
        GUIParent = safeWait(LocalPlayer, "PlayerGui", 10)
    end
end

-- cleanup old instances
pcall(function()
    for _, g in ipairs(GUIParent:GetChildren()) do
        if g.Name:find("AuraUI") or g.Name:find("ouncopybara")
           or g.Name == "by_ouncopybara_ADV" then
            g:Destroy()
        end
    end
end)

-- DEVICE ----------------------------------------------------------
local DEVICE = {
    IsTouch = UserInputService.TouchEnabled,
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    IsTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled,
    ViewportSize = Camera.ViewportSize,
}
local function refreshViewport()
    DEVICE.ViewportSize = Camera.ViewportSize
    DEVICE.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    DEVICE.IsTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
end

-- PERF ------------------------------------------------------------
local Perf = { fps = 60, memory = 0, frames = 0, lastCheck = tick() }
RunService.RenderStepped:Connect(function()
    Perf.frames = Perf.frames + 1
    local now = tick()
    if now - Perf.lastCheck >= 1 then
        Perf.fps = Perf.frames
        Perf.frames = 0
        Perf.lastCheck = now
        pcall(function() Perf.memory = math.floor(collectgarbage("count") or 0) end)
    end
end)

-- CONN MGR --------------------------------------------------------
local ConnMgr = { list = {}, threads = {} }
function ConnMgr.add(c) if c then table.insert(ConnMgr.list, c) end return c end
function ConnMgr.spawn(fn, ...)
    local t = task.spawn(fn, ...); table.insert(ConnMgr.threads, t); return t
end
function ConnMgr.purge()
    for _, c in ipairs(ConnMgr.list) do pcall(function() c:Disconnect() end) end
    for _, t in ipairs(ConnMgr.threads) do pcall(function() task.cancel(t) end) end
    ConnMgr.list, ConnMgr.threads = {}, {}
end

-- SIGNAL ----------------------------------------------------------
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ h = {} }, Signal) end
function Signal:Connect(fn)
    table.insert(self.h, fn)
    return { Disconnect = function()
        local i = table.find(self.h, fn); if i then table.remove(self.h, i) end
    end }
end
function Signal:Fire(...) for _, fn in ipairs(self.h) do task.spawn(fn, ...) end end

-- WORKSPACE CACHE ------------------------------------------------
local WSCache = {
    prompts = setmetatable({}, { __mode = "k" }),
    clicks  = setmetatable({}, { __mode = "k" }),
    npcs    = setmetatable({}, { __mode = "k" }),
    players = setmetatable({}, { __mode = "k" }),
    signal  = Signal.new(),
}
local function WSCache_index(obj)
    pcall(function()
        if obj:IsA("ProximityPrompt") then
            WSCache.prompts[obj] = true; WSCache.signal:Fire(obj, "prompt")
        elseif obj:IsA("ClickDetector") then
            WSCache.clicks[obj] = true; WSCache.signal:Fire(obj, "click")
        elseif obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == obj then isPlayer = true; break end
                end
                if isPlayer then WSCache.players[obj] = true
                else WSCache.npcs[obj] = true end
                WSCache.signal:Fire(obj, isPlayer and "player" or "npc")
            end
        end
    end)
end
local function WSCache_unindex(obj)
    WSCache.prompts[obj] = nil
    WSCache.clicks[obj] = nil
    WSCache.npcs[obj] = nil
    WSCache.players[obj] = nil
end
ConnMgr.add(workspace.DescendantAdded:Connect(WSCache_index))
ConnMgr.add(workspace.DescendantRemoving:Connect(WSCache_unindex))
ConnMgr.spawn(function()
    for _, v in ipairs(workspace:GetDescendants()) do WSCache_index(v) end
end)

-- IMAGE / AUDIO ---------------------------------------------------
local CustomImage = ""
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local IMAGE_FALLBACKS = {
    "rbxassetid://13110332857",
    "rbxassetid://14257626628",
    "rbxassetid://12821066523",
}
task.spawn(function()
    pcall(function()
        if isfile and writefile and getcustomasset and game.HttpGet then
            local f = "aura_icon_adv.jpg"
            pcall(function() if isfile(f) then delfile(f) end end)
            local ok, data = pcall(function() return game:HttpGet(IMAGE_URL, true) end)
            if ok and data and #data > 5000 then
                local b = data:sub(1,1)
                if b == "\255" or b == "\137" then writefile(f, data) end
            end
            if isfile(f) then
                local ok2, a = pcall(getcustomasset, f)
                if ok2 and a and a ~= "" then CustomImage = a end
            end
        end
    end)
end)

local Audio = {
    Enabled = true,
    Sounds = {
        click = "rbxassetid://6034521064",
        toggle = "rbxassetid://6895079853",
    }
}
function Audio:Play(name, vol)
    if not self.Enabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = self.Sounds[name] or self.Sounds.click
        s.Volume = vol or 0.3
        s.Parent = SoundService
        s:Play()
        task.delay(1, function() s:Destroy() end)
    end)
end

-- CFrame serialization -------------------------------------------
local function CFrameToTable(cf)
    local x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22 = cf:GetComponents()
    return {x=x,y=y,z=z,r00=r00,r01=r01,r02=r02,r10=r10,r11=r11,r12=r12,r20=r20,r21=r21,r22=r22}
end
local function TableToCFrame(t)
    if not t or type(t) ~= "table" then return nil end
    local ok, cf = pcall(function()
        return CFrame.new(t.x,t.y,t.z,t.r00,t.r01,t.r02,t.r10,t.r11,t.r12,t.r20,t.r21,t.r22)
    end)
    return ok and cf or nil
end

-- CONFIG MGR ------------------------------------------------------
local ConfigMgr = { File = "aura_config_v8.json", Data = {} }
function ConfigMgr:Save(data)
    pcall(function()
        if not writefile then return end
        local d = data or self.Data
        local s = {}
        for k, v in pairs(d) do
            if k ~= "Themes" and k ~= "BaseCFrames" and k ~= "SavedLocations" then
                local tv = type(v)
                if tv == "string" or tv == "number" or tv == "boolean" then
                    s[k] = v
                end
            end
        end
        if d.BaseCFrames then
            s.BaseCFrames = {}
            for i, cf in ipairs(d.BaseCFrames) do
                if typeof(cf) == "CFrame" then s.BaseCFrames[i] = CFrameToTable(cf) end
            end
        end
        if d.SavedLocations then
            s.SavedLocations = {}
            for name, cf in pairs(d.SavedLocations) do
                if typeof(cf) == "CFrame" then s.SavedLocations[name] = CFrameToTable(cf) end
            end
        end
        writefile(self.File, HttpService:JSONEncode(s))
    end)
end
function ConfigMgr:Load()
    pcall(function()
        if isfile and readfile and isfile(self.File) then
            local raw = readfile(self.File)
            if raw and #raw > 0 then self.Data = HttpService:JSONDecode(raw) end
        end
    end)
    return self.Data or {}
end

-- HELPERS ---------------------------------------------------------
local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0,10); c.Parent = parent; return c
end
local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1,1,1); s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent; return s
end
local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props); t:Play(); return t
end
local INFO_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_SPRING = TweenInfo.new(0.4,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- KEYBINDS --------------------------------------------------------
local Keybinds = { list = {} }
function Keybinds:Register(key, cb) table.insert(self.list, { key=key, cb=cb }) end
function Keybinds:Check(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _, kb in ipairs(self.list) do
        if input.KeyCode == kb.key then
            task.spawn(kb.cb); Audio:Play("toggle")
        end
    end
end

-- CONFIG ----------------------------------------------------------
local Config = {
    BaseCFrames = {}, SavedLocations = {},
    IsAutoOn=false, StiffDuration=1.0, HoldDelay=0.2,
    IsSpeedOn=false, SpeedValue=60,
    IsFlyOn=false, FlySpeed=100,
    IsInfiniteJumpOn=false, IsNoclipOn=false, IsAutoDriveOn=false,
    IsAntiAFK=true, UsePathfind=false, SafeTP=true,
    Theme="Halloween",
    Themes = {
        Halloween = { Accent = Color3.fromRGB(255,132,35), Name="Ghost" },
        Pink   = { Accent = Color3.fromRGB(255,105,180), Name="Pink" },
        Purple = { Accent = Color3.fromRGB(170,0,255),   Name="Purple" },
        Blue   = { Accent = Color3.fromRGB(0,170,255),   Name="Blue" },
        Green  = { Accent = Color3.fromRGB(0,255,150),   Name="Green" },
        Gold   = { Accent = Color3.fromRGB(255,200,0),   Name="Gold" },
        Red    = { Accent = Color3.fromRGB(255,50,50),   Name="Red" },
        Cyan   = { Accent = Color3.fromRGB(0,255,255),   Name="Cyan" },
    },
    ToggleKey = Enum.KeyCode.RightControl,
    AimbotEnabled=false, AimbotFOV=120, AimbotSmooth=0.15,
    AimbotTeamCheck=true, AimbotTargetPart="Head",
    ESPEnabled=false, ESPNames=true, ESPHealth=true,
    ESPTracers=false, ESPRange=1000, ESPPlayers=true, ESPNPCs=true,
    ChamsEnabled=false, ChamsTransparency=0.5,
}

-- load saved
do
    local savedCfg = ConfigMgr:Load()
    if savedCfg and type(savedCfg) == "table" then
        for k, v in pairs(savedCfg) do
            if k ~= "Themes" and k ~= "BaseCFrames" and k ~= "SavedLocations" then
                if Config[k] ~= nil and type(Config[k]) == type(v) then
                    Config[k] = v
                end
            end
        end
        if type(savedCfg.BaseCFrames) == "table" then
            Config.BaseCFrames = {}
            for i, tbl in ipairs(savedCfg.BaseCFrames) do
                local cf = TableToCFrame(tbl)
                if cf then Config.BaseCFrames[i] = cf end
            end
        end
        if type(savedCfg.SavedLocations) == "table" then
            Config.SavedLocations = {}
            for name, tbl in pairs(savedCfg.SavedLocations) do
                local cf = TableToCFrame(tbl)
                if cf then Config.SavedLocations[name] = cf end
            end
        end
    end
    Config.IsAutoOn=false; Config.IsSpeedOn=false; Config.IsFlyOn=false
    Config.IsNoclipOn=false; Config.IsAutoDriveOn=false
    Config.IsInfiniteJumpOn=false; Config.ESPEnabled=false
    Config.ChamsEnabled=false; Config.AimbotEnabled=false
    if type(Config.Theme) ~= "string" or not Config.Themes[Config.Theme] then
        Config.Theme = "Halloween"
    end
end

-- CHARACTER OBSERVER ----------------------------------------------
local CharObs = {
    character=nil, humanoid=nil, root=nil,
    changed=Signal.new(), died=Signal.new(),
}

local BODY_PARTS = {
    Head=1, Torso=1, UpperTorso=1, LowerTorso=1,
    ["Left Arm"]=1, ["Right Arm"]=1,
    ["Left Leg"]=1, ["Right Leg"]=1,
    LeftUpperArm=1, LeftLowerArm=1, LeftHand=1,
    RightUpperArm=1, RightLowerArm=1, RightHand=1,
    LeftUpperLeg=1, LeftLowerLeg=1, LeftFoot=1,
    RightUpperLeg=1, RightLowerLeg=1, RightFoot=1,
    HumanoidRootPart=1,
}

local function resetCharacter()
    pcall(function()
        local char = CharObs.character; if not char then return end
        local hum = CharObs.humanoid
        local hrp = CharObs.root
        if hum then
            hum.PlatformStand = false
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.AutoRotate = true
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and BODY_PARTS[p.Name] then
                p.CanCollide = true
                p.Anchored = false
                pcall(function() p:SetNetworkOwner(nil) end)
            end
        end
        if hrp then
            pcall(function()
                if hrp.Position.Y < -50 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
                end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

local function bindCharacter(char)
    CharObs.character = char
    CharObs.humanoid = safeWait(char, "Humanoid", 5)
    CharObs.root = safeWait(char, "HumanoidRootPart", 5)
    CharObs.changed:Fire(char, CharObs.humanoid, CharObs.root)
    if CharObs.humanoid then
        ConnMgr.add(CharObs.humanoid.Died:Connect(function() CharObs.died:Fire() end))
    end
    task.wait(0.3)
    resetCharacter()
end
if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
ConnMgr.add(LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.5); bindCharacter(c) end))
local function getCharacter() return CharObs.character, CharObs.humanoid, CharObs.root end

-- GODMODE ---------------------------------------------------------
local Godmode = { Enabled=false, HealthValue=999999, AntiVoid=true }
local function applyGodmode()
    pcall(function()
        local char = CharObs.character; if not char then return end
        local hum = CharObs.humanoid
        if hum then
            hum.MaxHealth = Godmode.HealthValue
            hum.Health = Godmode.HealthValue
            hum.BreakJointsOnDeath = false
            hum.NameDisplayDistance = 0
            hum.HealthDisplayDistance = 0
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end)
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("ForceField") then v:Destroy() end
        end
    end)
end
local function disableGodmode()
    pcall(function()
        local _, hum = getCharacter()
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
            hum.BreakJointsOnDeath = true
            hum.NameDisplayDistance = 100
            hum.HealthDisplayDistance = 100
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end)
        end
    end)
end
ConnMgr.spawn(function()
    while task.wait(0.3) do
        if Godmode.Enabled then
            if Godmode.AntiVoid then
                local _, _, hrp = getCharacter()
                if hrp and hrp.Position.Y < -100 then
                    pcall(function()
                        hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end)
                end
            end
            applyGodmode()
        end
    end
end)
CharObs.changed:Connect(function()
    task.wait(0.4)
    if Godmode.Enabled then applyGodmode() end
end)

-- NETWORK ---------------------------------------------------------
local AntiTP = { Enabled=false }
local function grabNet()
    pcall(function()
        local char = CharObs.character; if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and BODY_PARTS[part.Name] then
                pcall(function() part:SetNetworkOwner(LocalPlayer) end)
            end
        end
    end)
end
local function releaseNet()
    pcall(function()
        local char = CharObs.character; if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and BODY_PARTS[part.Name] then
                pcall(function() part:SetNetworkOwner(nil) end)
            end
        end
    end)
end
ConnMgr.spawn(function()
    while task.wait(0.5) do
        if AntiTP.Enabled then grabNet() end
    end
end)

-- COMBAT ----------------------------------------------------------
local Combat = { Aimbot = { Enabled=false }, ESP = { Objects={} } }
local aimbotConn
local guiInset = Vector2.new(0, 36)
pcall(function()
    local ins = UserInputService:GetGuiInset()
    guiInset = Vector2.new(ins.X, ins.Y)
end)

local function toggleAimbot(state)
    Combat.Aimbot.Enabled = state
    Config.AimbotEnabled = state
    if state then
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
        aimbotConn = RunService.RenderStepped:Connect(function()
            if not Combat.Aimbot.Enabled then return end
            local cam = workspace.CurrentCamera
            local _, _, hrp = getCharacter()
            if not hrp or not cam then return end
            local closest, closestDist = nil, Config.AimbotFOV
            local mousePos = UserInputService:GetMouseLocation() - guiInset
            for char in pairs(WSCache.players) do
                if char and char.Parent then
                    local plr = Players:GetPlayerFromCharacter(char)
                    if plr and plr ~= LocalPlayer then
                        local skip = Config.AimbotTeamCheck and plr.Team == LocalPlayer.Team
                        if not skip then
                            local tp = char:FindFirstChild(Config.AimbotTargetPart)
                            if tp and tp:IsA("BasePart") then
                                local sp, onScreen = cam:WorldToViewportPoint(tp.Position)
                                if onScreen then
                                    local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                                    if d < closestDist then closestDist=d; closest=tp end
                                end
                            end
                        end
                    end
                end
            end
            if closest then
                local sp = cam:WorldToViewportPoint(closest.Position)
                local delta = Vector2.new(sp.X, sp.Y) - mousePos
                if mousemoverel then
                    pcall(function()
                        mousemoverel(delta.X * Config.AimbotSmooth, delta.Y * Config.AimbotSmooth)
                    end)
                else
                    pcall(function()
                        cam.CFrame = cam.CFrame * CFrame.Angles(
                            math.rad(-delta.Y * Config.AimbotSmooth * 0.35),
                            math.rad(-delta.X * Config.AimbotSmooth * 0.35), 0)
                    end)
                end
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
    end
end

-- ESP -------------------------------------------------------------
local function createESP(target, isPlayer)
    if Combat.ESP.Objects[target] then return end
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
    local hum = target:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    -- range check
    local _, _, myHrp = getCharacter()
    if myHrp then
        local d = (myHrp.Position - root.Position).Magnitude
        if d > Config.ESPRange then return end
    end
    local esp = {}
    if Config.ChamsEnabled then
        local hl = Instance.new("Highlight")
        hl.Adornee = target
        hl.FillColor = isPlayer and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,200,0)
        hl.FillTransparency = Config.ChamsTransparency
        hl.OutlineColor = Color3.new(1,1,1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = target
        esp.Highlight = hl
    end
    if Config.ESPNames or Config.ESPHealth then
        local bb = Instance.new("BillboardGui")
        bb.Adornee = root
        bb.Size = UDim2.new(0,200,0,60)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true
        bb.Parent = target
        if Config.ESPNames then
            local name = Instance.new("TextLabel", bb)
            name.Size = UDim2.new(1,0,0,18)
            name.BackgroundTransparency = 1
            local pObj = isPlayer and Players:GetPlayerFromCharacter(target)
            name.Text = pObj and pObj.Name or target.Name
            name.TextColor3 = isPlayer and Color3.fromRGB(255,100,100) or Color3.fromRGB(255,220,100)
            name.Font = Enum.Font.GothamBold
            name.TextSize = 12
            name.TextStrokeTransparency = 0.5
        end
        if Config.ESPHealth then
            local hpBG = Instance.new("Frame", bb)
            hpBG.Size = UDim2.new(0.8,0,0,6)
            hpBG.Position = UDim2.new(0.1,0,0,22)
            hpBG.BackgroundColor3 = Color3.fromRGB(40,40,50)
            Corner(hpBG, UDim.new(1,0))
            local hpFill = Instance.new("Frame", hpBG)
            hpFill.Size = UDim2.new(math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1),0,1,0)
            hpFill.BackgroundColor3 = Color3.fromRGB(50,255,100)
            Corner(hpFill, UDim.new(1,0))
            local c = hum.HealthChanged:Connect(function(hp)
                if hpFill and hpFill.Parent then
                    local r = math.clamp(hp/math.max(hum.MaxHealth,1),0,1)
                    hpFill.Size = UDim2.new(r,0,1,0)
                    hpFill.BackgroundColor3 = r>0.5 and Color3.fromRGB(50,255,100)
                        or r>0.25 and Color3.fromRGB(255,200,50)
                        or Color3.fromRGB(255,50,50)
                end
            end)
            ConnMgr.add(c)
        end
        esp.Billboard = bb
    end
    if Config.ESPTracers and isPlayer then
        local tracer = Instance.new("Frame")
        tracer.BackgroundColor3 = Color3.fromRGB(255,105,180)
        tracer.BorderSizePixel = 0
        tracer.ZIndex = 100
        tracer.Parent = GUIParent
        local c = RunService.RenderStepped:Connect(function()
            if not tracer.Parent or not root.Parent then pcall(function() tracer:Destroy() end); return end
            local cam = workspace.CurrentCamera
            local sp, onScreen = cam:WorldToViewportPoint(root.Position)
            if onScreen then
                local mp = UserInputService:GetMouseLocation() - guiInset
                local dx, dy = sp.X-mp.X, sp.Y-mp.Y
                local dist = math.sqrt(dx*dx+dy*dy)
                tracer.Size = UDim2.new(0,dist,0,2)
                tracer.Position = UDim2.new(0,mp.X,0,mp.Y)
                tracer.Rotation = math.deg(math.atan2(dy,dx))
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end)
        ConnMgr.add(c)
        esp.Tracer = tracer
    end
    Combat.ESP.Objects[target] = esp
end

local function removeESP(target)
    local esp = Combat.ESP.Objects[target]
    if esp then
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Tracer then esp.Tracer:Destroy() end
        if esp.Highlight then esp.Highlight:Destroy() end
        Combat.ESP.Objects[target] = nil
    end
end
local function clearAllESP()
    for target in pairs(Combat.ESP.Objects) do removeESP(target) end
end

ConnMgr.spawn(function()
    while task.wait(0.2) do
        if Config.ESPEnabled or Config.ChamsEnabled then
            for char in pairs(WSCache.players) do
                if Config.ESPPlayers and char and char.Parent then createESP(char, true) end
            end
            for char in pairs(WSCache.npcs) do
                if Config.ESPNPCs and char and char.Parent then createESP(char, false) end
            end
            for target in pairs(Combat.ESP.Objects) do
                if not target.Parent then removeESP(target) end
            end
        else
            if next(Combat.ESP.Objects) ~= nil then clearAllESP() end
        end
    end
end)

-- THEME -----------------------------------------------------------
local accent = Config.Themes[Config.Theme].Accent
local accentRegistry, gradientRegistry, switchRegistry = {}, {}, {}
local StrokeGrad
local function RegisterAccent(o,p) table.insert(accentRegistry,{obj=o,prop=p}) end
local function RegisterGradient(g) table.insert(gradientRegistry,g) end

local function ApplyTheme(name)
    local t = Config.Themes[name]; if not t then return end
    Config.Theme = name
    if typeof(t.Accent) ~= "Color3" then t.Accent = Color3.fromRGB(255,105,180) end
    accent = t.Accent
    for _, e in ipairs(accentRegistry) do
        pcall(function() e.obj[e.prop] = accent end)
    end
    local dark = accent:Lerp(Color3.new(0,0,0),0.35)
    local seq = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accent),
        ColorSequenceKeypoint.new(1, dark),
    })
    for _, g in ipairs(gradientRegistry) do
        pcall(function() g.Color = seq end)
    end
    for _, s in ipairs(switchRegistry) do
        if s.get() then s.frame.BackgroundColor3 = accent end
    end
    if StrokeGrad then
        StrokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, accent),
        })
    end
end

-- SCREEN GUI ------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "by_ouncopybara_ADV"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Enabled = true
ScreenGui.Parent = GUIParent
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
end

-- NOTIFICATIONS ---------------------------------------------------
local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "Notifications"
NotifHolder.Size = UDim2.new(0, 280, 1, -20)
NotifHolder.Position = UDim2.new(1, -290, 0, 10)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Active = false
NotifHolder.Parent = ScreenGui
local NotifScale = Instance.new("UIScale")
NotifScale.Scale = 0.9
NotifScale.Parent = NotifHolder

local notifQueue = {}
local activeNotifs = 0
local MAX_NOTIFS = 5

local function renderNotif(data)
    if not data then return end
    activeNotifs = activeNotifs + 1
    local col = (typeof(data.color) == "Color3") and data.color or accent
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1,0,0,72)
    n.Position = UDim2.new(1,20,0,(activeNotifs-1)*80)
    n.BackgroundColor3 = Color3.fromRGB(18,18,24)
    n.BackgroundTransparency = 0.08
    n.BorderSizePixel = 0
    n.Parent = NotifHolder
    Corner(n, UDim.new(0,12))
    Stroke(n, col, 1.2, 0.4)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,-16); bar.Position = UDim2.new(0,6,0,8)
    bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; bar.Parent = n
    Corner(bar, UDim.new(1,0))
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0,28,0,28); iconLbl.Position = UDim2.new(0,18,0.5,-14)
    iconLbl.BackgroundColor3 = col; iconLbl.BackgroundTransparency = 0.7
    iconLbl.Text = data.icon or "i"; iconLbl.TextColor3 = col
    iconLbl.Font = Enum.Font.GothamBold; iconLbl.TextSize = 16
    iconLbl.Parent = n; Corner(iconLbl, UDim.new(1,0))
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,18); ttl.Position = UDim2.new(0,54,0,12)
    ttl.BackgroundTransparency = 1; ttl.Text = data.title or ""
    ttl.TextColor3 = col; ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 12
    ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = n
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1,-70,0,30); msgLbl.Position = UDim2.new(0,54,0,32)
    msgLbl.BackgroundTransparency = 1; msgLbl.Text = data.msg or ""
    msgLbl.TextColor3 = Color3.fromRGB(200,200,210); msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 10; msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top; msgLbl.Parent = n
    local prog = Instance.new("Frame")
    prog.Size = UDim2.new(1,-18,0,2); prog.Position = UDim2.new(0,12,1,-7)
    prog.BackgroundColor3 = col; prog.BackgroundTransparency = 0.4
    prog.BorderSizePixel = 0; prog.Parent = n; Corner(prog, UDim.new(1,0))
    Audio:Play("toggle", 0.2)
    Tween(n, INFO_SPRING, { Position = UDim2.new(0,0,0,n.Position.Y.Offset) })
    Tween(prog, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,0,2) })
    task.delay(3.7, function()
        pcall(function()
            Tween(n, INFO_FAST, { Position=UDim2.new(1,20,0,n.Position.Y.Offset), BackgroundTransparency=1 })
            task.wait(0.2); n:Destroy(); activeNotifs = activeNotifs - 1
            local i = 0
            for _, child in ipairs(NotifHolder:GetChildren()) do
                if child:IsA("Frame") then
                    Tween(child, INFO_FAST, { Position = UDim2.new(0,0,0,i*80) })
                    i = i + 1
                end
            end
            if #notifQueue > 0 then renderNotif(table.remove(notifQueue,1)) end
        end)
    end)
end

local function Notify(title, msg, color, icon)
    local data = { title=title, msg=msg, color=color, icon=icon }
    if activeNotifs >= MAX_NOTIFS then table.insert(notifQueue, data)
    else renderNotif(data) end
end

-- TELEPORT --------------------------------------------------------
local activeTPConn = nil

local function instantTeleport(hrp, targetCFrame, duration)
    if not hrp or not hrp.Parent then return end
    local char = hrp.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    if activeTPConn then pcall(function() activeTPConn:Disconnect() end); activeTPConn = nil end
    local safeCF = Config.SafeTP and (targetCFrame + Vector3.new(0,3,0)) or targetCFrame
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and BODY_PARTS[part.Name] then
            part.CanCollide = false
            part.Anchored = false
        end
    end
    local start = tick()
    local dur = duration or 0.2
    activeTPConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            hrp.CFrame = safeCF
            hrp.AssemblyLinearVelocity = Vector3.zero
        end)
        if tick() - start > dur then
            if activeTPConn then pcall(function() activeTPConn:Disconnect() end); activeTPConn = nil end
        end
    end)
    task.delay(dur + 0.05, function()
        pcall(function()
            if not hrp.Parent then return end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and BODY_PARTS[part.Name] then
                    part.CanCollide = true
                end
            end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
        end)
    end)
end

local function pathfindTeleport(hrp, targetPos)
    local path = PathfindingService:CreatePath({ AgentRadius=3, AgentHeight=5, AgentCanJump=true })
    local ok = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
    if ok and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            instantTeleport(hrp, CFrame.new(wp.Position + Vector3.new(0,3,0)), 0.1)
            task.wait(0.08)
        end
    else
        instantTeleport(hrp, CFrame.new(targetPos), 0.2)
    end
end

-- FARM ------------------------------------------------------------
local function triggerPromptOrClick(maxDist)
    pcall(function()
        local _, _, hrp = getCharacter(); if not hrp then return end
        local pos = hrp.Position
        for prompt in pairs(WSCache.prompts) do
            if prompt.Parent and prompt.Enabled then
                local part = prompt.Parent
                if part:IsA("BasePart") then
                    local d = (pos - part.Position).Magnitude
                    if d <= math.min(prompt.MaxActivationDistance or 15, maxDist or 15) then
                        pcall(fireproximityprompt, prompt)
                    end
                end
            end
        end
        for cd in pairs(WSCache.clicks) do
            if cd.Parent then
                local part = cd.Parent
                if part:IsA("BasePart") then
                    local d = (pos - part.Position).Magnitude
                    if d <= math.min(cd.MaxActivationDistance or 32, maxDist or 32) then
                        pcall(fireclickdetector, cd)
                    end
                end
            end
        end
    end)
end

local isProcessing = false
local updateStatus = function() end

local function handleSteal()
    if not Config.IsAutoOn or isProcessing then return end
    local baseCF = Config.BaseCFrames[1]
    if not baseCF or typeof(baseCF) ~= "CFrame" then
        Notify("Farm", "Set base point first", Color3.fromRGB(255,70,70), "!")
        return
    end
    local _, hum, hrp = getCharacter()
    if not hrp or not hum or hum.Health <= 0 then return end
    isProcessing = true
    local originalLocation = hrp.CFrame
    updateStatus("Collecting...", Color3.fromRGB(255,200,100))
    ConnMgr.spawn(function()
        if not Config.IsAutoOn then isProcessing=false; return end
        triggerPromptOrClick(15)
        task.wait(Config.HoldDelay)
        if not Config.IsAutoOn then isProcessing=false; return end
        updateStatus("To base...", Color3.fromRGB(100,200,255))
        if Config.UsePathfind then pathfindTeleport(hrp, baseCF.Position)
        else instantTeleport(hrp, baseCF, 0.15) end
        task.wait(0.2)
        if not Config.IsAutoOn then isProcessing=false; return end
        task.wait(Config.StiffDuration)
        if not Config.IsAutoOn then isProcessing=false; return end
        triggerPromptOrClick(32)
        task.wait(0.1)
        if not Config.IsAutoOn then isProcessing=false; return end
        updateStatus("Returning...", Color3.fromRGB(100,255,100))
        instantTeleport(hrp, originalLocation + (Config.SafeTP and Vector3.new(0,3,0) or Vector3.zero), 0.05)
        task.wait(0.1)
        resetCharacter()
        isProcessing = false
        updateStatus("Waiting next egg...", Color3.new(1,1,1))
    end)
end

local hookedInteractions = setmetatable({}, { __mode = "k" })
local function hookInteractions(v)
    if hookedInteractions[v] then return end
    hookedInteractions[v] = true
    pcall(function()
        if v:IsA("ProximityPrompt") then
            ConnMgr.add(v.Triggered:Connect(function(plr)
                if plr == LocalPlayer then handleSteal() end
            end))
        elseif v:IsA("ClickDetector") then
            ConnMgr.add(v.MouseClick:Connect(function(plr)
                if plr == LocalPlayer then handleSteal() end
            end))
        end
    end)
end
WSCache.signal:Connect(function(obj) hookInteractions(obj) end)
for _, v in ipairs(workspace:GetDescendants()) do hookInteractions(v) end

-- MOVEMENT --------------------------------------------------------
local flyConn, noclipConn, autoDriveConn, speedConn
local flyObjects = { bv=nil, bg=nil }

local function toggleSpeed(state)
    Config.IsSpeedOn = state
    if state then
        if speedConn then speedConn:Disconnect(); speedConn=nil end
        speedConn = RunService.Heartbeat:Connect(function()
            if not Config.IsSpeedOn then return end
            local _, hum = getCharacter()
            if hum then pcall(function() hum.WalkSpeed = Config.SpeedValue end) end
        end)
    else
        if speedConn then speedConn:Disconnect(); speedConn=nil end
        local _, hum = getCharacter()
        if hum then pcall(function() hum.WalkSpeed = 16 end) end
    end
end

local function enableFly()
    local _, hum, hrp = getCharacter()
    if not hrp or not hum then return end
    Config.IsFlyOn = true
    pcall(function() hum.PlatformStand = true end)
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    bv.P = 1250
    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    bg.P = 3000; bg.D = 100
    flyObjects.bv = bv; flyObjects.bg = bg
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.IsFlyOn or not hum or hum.Health <= 0 then
            Config.IsFlyOn = false
            if flyConn then flyConn:Disconnect(); flyConn=nil end
            pcall(function()
                if flyObjects.bv then flyObjects.bv:Destroy() end
                if flyObjects.bg then flyObjects.bg:Destroy() end
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
            flyObjects.bv=nil; flyObjects.bg=nil
            return
        end
        local cam = workspace.CurrentCamera
        local md = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then md = md - Vector3.new(0,1,0) end
        bv.Velocity = md.Magnitude > 0 and md.Unit * Config.FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

local function disableFly()
    Config.IsFlyOn = false
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    pcall(function()
        if flyObjects.bv then flyObjects.bv:Destroy() end
        if flyObjects.bg then flyObjects.bg:Destroy() end
        flyObjects.bv=nil; flyObjects.bg=nil
        local _, hum = getCharacter()
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end)
end

local function toggleNoclip(state)
    Config.IsNoclipOn = state
    if state then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)
    end
end

local function toggleAutoDrive(state)
    Config.IsAutoDriveOn = state
    if state then
        if not autoDriveConn then
            autoDriveConn = RunService.Stepped:Connect(function()
                if not Config.IsAutoDriveOn then return end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local seat = hum and hum.SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    local car = seat.Parent
                    local hrp = car and (car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart"))
                    if hrp then
                        seat.Throttle = 1
                        local rp = RaycastParams.new()
                        rp.FilterDescendantsInstances = { car }
                        rp.FilterType = Enum.RaycastFilterType.Exclude
                        local ray = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 25, rp)
                        seat.Steer = ray and 1 or 0
                    end
                end
            end)
        end
    else
        if autoDriveConn then autoDriveConn:Disconnect(); autoDriveConn=nil end
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            if seat and seat:IsA("VehicleSeat") then
                seat.Throttle = 0; seat.Steer = 0
            end
        end)
    end
end

ConnMgr.add(UserInputService.JumpRequest:Connect(function()
    if Config.IsInfiniteJumpOn then
        local _, hum = getCharacter()
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end))

ConnMgr.add(LocalPlayer.Idled:Connect(function()
    if Config.IsAntiAFK then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController(); vu:ClickButton2(Vector2.new())
        end)
    end
end))

-- Keybinds
Keybinds:Register(Enum.KeyCode.F1, function()
    Config.ESPEnabled = not Config.ESPEnabled
    Notify("ESP", Config.ESPEnabled and "ON" or "OFF", accent, "E")
end)
Keybinds:Register(Enum.KeyCode.F2, function()
    Config.IsNoclipOn = not Config.IsNoclipOn
    toggleNoclip(Config.IsNoclipOn)
    Notify("Noclip", Config.IsNoclipOn and "ON" or "OFF", accent, "N")
end)
Keybinds:Register(Enum.KeyCode.F3, function()
    toggleAimbot(not Config.AimbotEnabled)
    Notify("Aimbot", Config.AimbotEnabled and "ON" or "OFF", accent, "A")
end)
Keybinds:Register(Enum.KeyCode.F4, function()
    resetCharacter()
    Notify("Reset", "TP unstuck fixed!", Color3.fromRGB(0,255,120), "R")
end)

ConnMgr.add(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    Keybinds:Check(input)
end))

-- UI --------------------------------------------------------------
local BASE_W, BASE_H = 400, 520

local function calcScale()
    refreshViewport()
    local vp = DEVICE.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return 0.85 end
    local maxWPercent, maxHPercent
    if DEVICE.IsMobile then maxWPercent=0.92; maxHPercent=0.88
    elseif DEVICE.IsTablet then maxWPercent=0.75; maxHPercent=0.85
    else maxWPercent=0.45; maxHPercent=0.85 end
    local scaleW = (vp.X*maxWPercent)/BASE_W
    local scaleH = (vp.Y*maxHPercent)/BASE_H
    return math.clamp(math.min(scaleW, scaleH), 0.70, 1.25)
end

local UI_SCALE = calcScale()

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, BASE_W+20, 0, BASE_H+20)
Shadow.Position = UDim2.new(0.5,0,0.5,0)
Shadow.AnchorPoint = Vector2.new(0.5,0.5)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0
Shadow.Parent = ScreenGui
Corner(Shadow, UDim.new(0,20))
local ShadowScale = Instance.new("UIScale")
ShadowScale.Scale = UI_SCALE
ShadowScale.Parent = Shadow

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, BASE_W, 0, BASE_H)
Main.Position = UDim2.new(0.5,0,0.5,0)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(16,16,22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
Corner(Main, UDim.new(0,16))

local MainScale = Instance.new("UIScale")
MainScale.Scale = UI_SCALE
MainScale.Parent = Main

local lastVp = DEVICE.ViewportSize
ConnMgr.add(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    refreshViewport()
    local newVp = DEVICE.ViewportSize
    if math.abs(newVp.X-lastVp.X) < 50 and math.abs(newVp.Y-lastVp.Y) < 50 then
        lastVp = newVp; return
    end
    lastVp = newVp
    task.wait(0.15)
    local newScale = calcScale()
    UI_SCALE = newScale
    Tween(MainScale, INFO_FAST, { Scale = newScale })
    Tween(ShadowScale, INFO_FAST, { Scale = newScale })
    Tween(NotifScale, INFO_FAST, { Scale = math.clamp(newScale*0.9, 0.7, 0.95) })
end))

local BgImage = Instance.new("ImageLabel")
BgImage.Size = UDim2.new(1,0,1,0); BgImage.BackgroundTransparency = 1
BgImage.Image = (CustomImage ~= "" and CustomImage) or IMAGE_FALLBACKS[1]
BgImage.ImageTransparency = 0.82
BgImage.ScaleType = Enum.ScaleType.Crop; BgImage.Parent = Main
Corner(BgImage, UDim.new(0,16))

local Dim = Instance.new("Frame")
Dim.Size = UDim2.new(1,0,1,0)
Dim.BackgroundColor3 = Color3.fromRGB(16,9,27)
Dim.BackgroundTransparency = 0.16
Dim.BorderSizePixel = 0; Dim.Parent = Main
Corner(Dim, UDim.new(0,16))
local DimGrad = Instance.new("UIGradient")
DimGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(47,22,64)),
    ColorSequenceKeypoint.new(0.52, Color3.fromRGB(18,13,31)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(67,30,24)),
})
DimGrad.Rotation = 35; DimGrad.Parent = Dim

local MainStroke = Stroke(Main, accent, 1.5)
StrokeGrad = Instance.new("UIGradient")
StrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, accent),
    ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(1, accent),
})
StrokeGrad.Parent = MainStroke
ConnMgr.spawn(function()
    while Main.Parent do
        StrokeGrad.Rotation = 0
        Tween(StrokeGrad, TweenInfo.new(5, Enum.EasingStyle.Linear), { Rotation = 360 })
        task.wait(5)
    end
end)

-- TOPBAR ----------------------------------------------------------
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1,0,0,52)
Topbar.BackgroundColor3 = Color3.new(1,1,1)
Topbar.BackgroundTransparency = 0.94
Topbar.BorderSizePixel = 0
Topbar.Active = true
Topbar.Parent = Main
local TopbarGradient = Instance.new("UIGradient")
TopbarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150,74,255)),
    ColorSequenceKeypoint.new(0.52, Color3.fromRGB(46,29,61)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,132,35)),
})
TopbarGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.42),
    NumberSequenceKeypoint.new(0.5, 0.78),
    NumberSequenceKeypoint.new(1, 0.35),
})
TopbarGradient.Parent = Topbar

local TopbarTrim = Instance.new("Frame")
TopbarTrim.Size = UDim2.new(1,-24,0,2)
TopbarTrim.Position = UDim2.new(0,12,1,-1)
TopbarTrim.BackgroundColor3 = accent
TopbarTrim.BorderSizePixel = 0
TopbarTrim.Parent = Topbar
local TopbarTrimGradient = Instance.new("UIGradient")
TopbarTrimGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,132,35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(196,105,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(91,237,255)),
})
TopbarTrimGradient.Parent = TopbarTrim

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0,30,0,30); TopIcon.Position = UDim2.new(0,12,0,11)
TopIcon.BackgroundColor3 = accent
TopIcon.Image = (CustomImage ~= "" and CustomImage) or IMAGE_FALLBACKS[2]
TopIcon.ScaleType = Enum.ScaleType.Crop; TopIcon.Parent = Topbar
Corner(TopIcon, UDim.new(1,0))
RegisterAccent(TopIcon, "BackgroundColor3")

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-110,0,17); Title.Position = UDim2.new(0,50,0,10)
Title.BackgroundTransparency = 1; Title.Text = "GHOST MODE - HALLOWEEN"
Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold
Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTruncate = Enum.TextTruncate.AtEnd
Title.Parent = Topbar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1,-110,0,13); Subtitle.Position = UDim2.new(0,50,0,28)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by ouncopybara - " .. Config.Themes[Config.Theme].Name
Subtitle.TextColor3 = accent; Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 9; Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Topbar
RegisterAccent(Subtitle, "TextColor3")

local PerfLabel = Instance.new("TextLabel")
PerfLabel.Size = UDim2.new(0,90,0,14); PerfLabel.Position = UDim2.new(1,-160,0,36)
PerfLabel.BackgroundTransparency = 1; PerfLabel.Font = Enum.Font.Code
PerfLabel.TextSize = 8; PerfLabel.TextColor3 = Color3.fromRGB(150,150,160)
PerfLabel.TextXAlignment = Enum.TextXAlignment.Right
PerfLabel.Parent = Topbar
ConnMgr.spawn(function()
    while Topbar.Parent do
        PerfLabel.Text = string.format("FPS:%d MEM:%d", Perf.fps, Perf.memory)
        task.wait(1)
    end
end)

local function WindowButton(text, color, xOffset)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,26,0,26)
    b.Position = UDim2.new(1, xOffset, 0, 13)
    b.BackgroundColor3 = color; b.Text = text
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
    b.TextSize = 12; b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 5
    b.Parent = Topbar; Corner(b, UDim.new(1,0))
    b.MouseEnter:Connect(function() Tween(b, INFO_FAST, { BackgroundTransparency = 0.25 }) end)
    b.MouseLeave:Connect(function() Tween(b, INFO_FAST, { BackgroundTransparency = 0 }) end)
    return b
end
local CloseBtn = WindowButton("X", Color3.fromRGB(255,70,70), -36)
local MinBtn   = WindowButton("-", Color3.fromRGB(70,70,82), -68)

-- SIDEBAR ---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,100,1,-52)
Sidebar.Position = UDim2.new(0,0,0,52)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Main

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0,10); SidePad.Parent = Sidebar

local PageHost = Instance.new("Frame")
PageHost.Size = UDim2.new(1,-100,1,-52-42)
PageHost.Position = UDim2.new(0,100,0,52)
PageHost.BackgroundTransparency = 1
PageHost.Parent = Main

-- STATUS BAR ------------------------------------------------------
local Statusbar = Instance.new("Frame")
Statusbar.Size = UDim2.new(1,-20,0,30)
Statusbar.Position = UDim2.new(0,10,1,-38)
Statusbar.BackgroundColor3 = Color3.new(1,1,1)
Statusbar.BackgroundTransparency = 0.94
Statusbar.BorderSizePixel = 0
Statusbar.Parent = Main
Corner(Statusbar, UDim.new(0,8))

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0,7,0,7)
StatusDot.Position = UDim2.new(0,12,0.5,-3.5)
StatusDot.BackgroundColor3 = Color3.fromRGB(255,145,55)
StatusDot.BorderSizePixel = 0; StatusDot.Parent = Statusbar
Corner(StatusDot, UDim.new(1,0))

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1,-32,1,0)
StatusText.Position = UDim2.new(0,28,0,0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "System ready"
StatusText.TextColor3 = Color3.fromRGB(220,220,230)
StatusText.Font = Enum.Font.Gotham; StatusText.TextSize = 11
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextTruncate = Enum.TextTruncate.AtEnd
StatusText.Parent = Statusbar

updateStatus = function(txt, col)
    StatusText.Text = txt
    if col and typeof(col) == "Color3" then StatusDot.BackgroundColor3 = col end
end

-- CLICK EFFECT ----------------------------------------------------
local function PlayClickEffect(btn)
    pcall(function()
        local r = Instance.new("Frame")
        r.Size = UDim2.new(0,0,0,0)
        r.Position = UDim2.new(0.5,0,0.5,0)
        r.AnchorPoint = Vector2.new(0.5,0.5)
        r.BackgroundColor3 = Color3.new(1,1,1)
        r.BackgroundTransparency = 0.4
        r.BorderSizePixel = 0
        r.ZIndex = 10
        r.Parent = btn
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(1,0); rc.Parent = r
        Tween(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,500,0,500),
            BackgroundTransparency = 1,
        })
        task.delay(0.55, function() pcall(function() r:Destroy() end) end)
    end)
end

-- TAB SYSTEM ------------------------------------------------------
local tabs = {}
local function SelectTab(tab)
    for _, t in ipairs(tabs) do
        t.Active = false; t.Page.Visible = false
        Tween(t.Button, INFO_FAST, { BackgroundTransparency = 1 })
        Tween(t.Indicator, INFO_FAST, { Size = UDim2.new(0,3,0,0) })
        t.Label.TextColor3 = Color3.fromRGB(140,140,150)
    end
    tab.Active = true; tab.Page.Visible = true
    Tween(tab.Button, INFO_FAST, { BackgroundTransparency = 0.85 })
    Tween(tab.Indicator, INFO_SPRING, { Size = UDim2.new(0,3,0,22) })
    tab.Label.TextColor3 = Color3.new(1,1,1)
end

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-16,0,44)
    btn.BackgroundColor3 = accent
    btn.BackgroundTransparency = 1
    btn.Text = ""; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.LayoutOrder = #tabs + 1
    btn.Parent = Sidebar
    Corner(btn, UDim.new(0,10))

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0,3,0,0)
    indicator.Position = UDim2.new(0,2,0.5,0)
    indicator.AnchorPoint = Vector2.new(0,0.5)
    indicator.BackgroundColor3 = accent
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    Corner(indicator, UDim.new(1,0))

    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(1,0,0,18); ic.Position = UDim2.new(0,0,0,6)
    ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 14
    ic.ZIndex = 2; ic.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,14); lbl.Position = UDim2.new(0,0,0,24)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
    lbl.TextColor3 = Color3.fromRGB(140,140,150)
    lbl.ZIndex = 2; lbl.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1
    page.BorderSizePixel = 0; page.Visible = false
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollBarImageTransparency = 0.5
    page.Parent = PageHost
    local pl = Instance.new("UIListLayout")
    pl.Padding = UDim.new(0,8); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = page
    local pp = Instance.new("UIPadding")
    pp.PaddingRight = UDim.new(0,10); pp.PaddingBottom = UDim.new(0,10); pp.Parent = page

    local tab = { Button=btn, Indicator=indicator, Label=lbl, Page=page, Active=false }
    table.insert(tabs, tab)

    btn.MouseEnter:Connect(function()
        if not tab.Active then Tween(btn, INFO_FAST, { BackgroundTransparency = 0.93 }) end
    end)
    btn.MouseLeave:Connect(function()
        if not tab.Active then Tween(btn, INFO_FAST, { BackgroundTransparency = 1 }) end
    end)
    btn.MouseButton1Click:Connect(function()
        SelectTab(tab); Audio:Play("click", 0.15); PlayClickEffect(btn)
    end)
    RegisterAccent(indicator, "BackgroundColor3")
    RegisterAccent(page, "ScrollBarImageColor3")
    return page
end

-- COMPONENTS ------------------------------------------------------
local function AddSection(page, text, order)
    local l = Instance.new("TextLabel")
    l.LayoutOrder = order; l.Size = UDim2.new(1,4,0,20)
    l.BackgroundTransparency = 1; l.Text = string.upper(text)
    l.TextColor3 = accent; l.Font = Enum.Font.GothamBold; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = page
    RegisterAccent(l, "TextColor3")
end

local function AddToggle(page, title, desc, default, order, callback)
    local row = Instance.new("TextButton")
    row.LayoutOrder = order
    row.Size = UDim2.new(1,0,0, desc and 48 or 40)
    row.BackgroundColor3 = Color3.new(1,1,1)
    row.BackgroundTransparency = 0.95
    row.Text = ""; row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.ClipsDescendants = true
    row.Parent = page; Corner(row, UDim.new(0,10))

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,16)
    ttl.Position = desc and UDim2.new(0,12,0,8) or UDim2.new(0,12,0.5,-8)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = Color3.new(1,1,1); ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.TextTruncate = Enum.TextTruncate.AtEnd
    ttl.ZIndex = 3; ttl.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,-70,0,13); d.Position = UDim2.new(0,12,0,25)
        d.BackgroundTransparency = 1; d.Text = desc
        d.TextColor3 = Color3.fromRGB(130,130,145); d.Font = Enum.Font.Gotham
        d.TextSize = 9; d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextTruncate = Enum.TextTruncate.AtEnd
        d.ZIndex = 3; d.Parent = row
    end

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,22); sw.Position = UDim2.new(1,-52,0.5,-11)
    sw.BackgroundColor3 = Color3.fromRGB(45,45,55)
    sw.BorderSizePixel = 0; sw.ZIndex = 3; sw.Parent = row
    Corner(sw, UDim.new(1,0))
    Stroke(sw, Color3.fromRGB(65,65,78), 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0; knob.ZIndex = 4; knob.Parent = sw
    Corner(knob, UDim.new(1,0))

    local isOn = default and true or false
    local function refresh()
        if isOn then
            sw.BackgroundColor3 = accent
            Tween(knob, INFO_SPRING, { Position = UDim2.new(1,-19,0.5,-8) })
        else
            sw.BackgroundColor3 = Color3.fromRGB(45,45,55)
            Tween(knob, INFO_SPRING, { Position = UDim2.new(0,3,0.5,-8) })
        end
    end
    if isOn then sw.BackgroundColor3 = accent; knob.Position = UDim2.new(1,-19,0.5,-8) end
    table.insert(switchRegistry, { frame = sw, get = function() return isOn end })

    row.MouseButton1Click:Connect(function()
        isOn = not isOn
        refresh()
        Audio:Play("toggle", 0.2); PlayClickEffect(sw)
        if callback then pcall(callback, isOn) end
    end)
    row.MouseEnter:Connect(function() Tween(row, INFO_FAST, { BackgroundTransparency = 0.92 }) end)
    row.MouseLeave:Connect(function() Tween(row, INFO_FAST, { BackgroundTransparency = 0.95 }) end)
    return { Set = function(v) isOn = v and true or false; refresh() end }
end

local function AddSlider(page, title, min, max, default, decimals, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,56)
    row.BackgroundColor3 = Color3.new(1,1,1)
    row.BackgroundTransparency = 0.95
    row.BorderSizePixel = 0; row.Parent = page
    Corner(row, UDim.new(0,10))

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,16); ttl.Position = UDim2.new(0,12,0,9)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = Color3.new(1,1,1); ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0,50,0,16); valLbl.Position = UDim2.new(1,-58,0,9)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default)
    valLbl.TextColor3 = accent; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11; valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row
    RegisterAccent(valLbl, "TextColor3")

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-24,0,5); bar.Position = UDim2.new(0,12,1,-17)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,50)
    bar.BorderSizePixel = 0; bar.Parent = row
    Corner(bar, UDim.new(1,0))

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = accent; fill.BorderSizePixel = 0; fill.Parent = bar
    Corner(fill, UDim.new(1,0))
    local fg = Instance.new("UIGradient"); fg.Parent = fill; RegisterGradient(fg)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0,20,0,20)
    knob.Position = UDim2.new((default-min)/(max-min),-10,0.5,-10)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    knob.ZIndex = 2
    knob.Parent = bar
    Corner(knob, UDim.new(1,0))
    local ks = Stroke(knob, accent, 1.5)
    RegisterAccent(ks, "Color")

    local dragging = false
    local mult = 10 ^ (decimals or 0)
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max-min)*rel) * mult + 0.5) / mult
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-10,0.5,-10)
        valLbl.Text = tostring(val)
        if callback then pcall(callback, val) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end))
    ConnMgr.add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local function AddButton(page, title, order, callback)
    local b = Instance.new("TextButton")
    b.LayoutOrder = order; b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = accent; b.Text = title
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
    b.TextSize = 12; b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ClipsDescendants = true
    b.Parent = page; Corner(b, UDim.new(0,10))
    local grad = Instance.new("UIGradient"); grad.Parent = b; RegisterGradient(grad)
    local scale = Instance.new("UIScale"); scale.Parent = b
    b.MouseEnter:Connect(function() Tween(scale, INFO_FAST, { Scale = 1.03 }) end)
    b.MouseLeave:Connect(function() Tween(scale, INFO_FAST, { Scale = 1 }) end)
    b.MouseButton1Down:Connect(function()
        Tween(scale, INFO_FAST, { Scale = 0.96 }); PlayClickEffect(b)
    end)
    b.MouseButton1Up:Connect(function()
        Tween(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.03 })
    end)
    b.MouseButton1Click:Connect(function() Audio:Play("click", 0.2); pcall(callback) end)
    return b
end

local function AddTextInput(page, title, placeholder, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,44)
    row.BackgroundColor3 = Color3.new(1,1,1)
    row.BackgroundTransparency = 0.95
    row.BorderSizePixel = 0; row.Parent = page
    Corner(row, UDim.new(0,10))

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(0.4,0,1,0); ttl.Position = UDim2.new(0,12,0,0)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = Color3.new(1,1,1); ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.55,0,0,30); box.Position = UDim2.new(0.42,0,0.5,-15)
    box.BackgroundColor3 = Color3.fromRGB(30,30,40)
    box.PlaceholderText = placeholder; box.Text = ""
    box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderColor3 = Color3.fromRGB(100,100,115)
    box.Font = Enum.Font.Gotham; box.TextSize = 12
    box.BorderSizePixel = 0; box.ClearTextOnFocus = false
    box.ZIndex = 2; box.Parent = row
    Corner(box, UDim.new(0,6))
    Stroke(box, Color3.fromRGB(60,60,75), 1)
    box.FocusLost:Connect(function()
        if callback then pcall(callback, box.Text) end
    end)
    return box
end

local function AddThemePicker(page, order)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,52)
    row.BackgroundColor3 = Color3.new(1,1,1)
    row.BackgroundTransparency = 0.95
    row.BorderSizePixel = 0; row.Parent = page
    Corner(row, UDim.new(0,10))
    local names = { "Halloween","Pink","Purple","Blue","Green","Gold","Red","Cyan" }
    for i, name in ipairs(names) do
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.new(0,26,0,26)
        dot.Position = UDim2.new(0, 12 + (i-1)*32, 0.5, -13)
        dot.BackgroundColor3 = Config.Themes[name].Accent
        dot.Text = ""; dot.BorderSizePixel = 0
        dot.AutoButtonColor = false
        dot.ClipsDescendants = true
        dot.ZIndex = 2
        dot.Parent = row; Corner(dot, UDim.new(1,0))
        local st = Stroke(dot, Color3.new(1,1,1), 2, 0.7)
        if name == Config.Theme then st.Transparency = 0 end
        dot.MouseButton1Click:Connect(function()
            ApplyTheme(name); PlayClickEffect(dot)
            Subtitle.Text = "by ouncopybara - " .. Config.Themes[name].Name
            for _, c in ipairs(row:GetChildren()) do
                if c:IsA("TextButton") then
                    local s2 = c:FindFirstChildOfClass("UIStroke")
                    if s2 then s2.Transparency = 0.7 end
                end
            end
            st.Transparency = 0
            Notify("Theme", "Changed to " .. Config.Themes[name].Name,
                Config.Themes[name].Accent, "T")
        end)
    end
end

-- TAB PAGES -------------------------------------------------------
local farmPage = CreateTab("Farm", "F")
AddSection(farmPage, "Farm", 1)
AddButton(farmPage, "Set Base Point", 2, function()
    local _, _, hrp = getCharacter()
    if hrp then
        Config.BaseCFrames[1] = hrp.CFrame
        Notify("Farm", "Base point saved!", Color3.fromRGB(0,255,120), "P")
        ConfigMgr:Save(Config)
    end
end)
AddToggle(farmPage, "Auto Farm", "Auto collect and deliver", false, 3, function(s)
    Config.IsAutoOn = s
    updateStatus(s and "Farm: ON" or "Farm: OFF",
        s and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,200,0))
end)
AddSlider(farmPage, "Farm Delay", 0.5, 5, 1, 1, 4, function(v) Config.StiffDuration = v end)
AddSlider(farmPage, "Hold Delay", 0, 1, 0.2, 1, 5, function(v) Config.HoldDelay = v end)
AddToggle(farmPage, "Use Pathfind", "Avoid detection", false, 6, function(s) Config.UsePathfind = s end)
AddToggle(farmPage, "Safe TP", "Offset 3 studs up", true, 7, function(s) Config.SafeTP = s end)

AddSection(farmPage, "Protection", 8)
AddToggle(farmPage, "Godmode", "Infinite HP + Anti-Void", false, 9, function(s)
    Godmode.Enabled = s
    if s then applyGodmode(); Notify("Godmode", "ON", Color3.fromRGB(0,255,120), "G")
    else disableGodmode(); Notify("Godmode", "OFF", Color3.fromRGB(255,70,70), "G") end
end)
AddToggle(farmPage, "Network Owner", "Control char physics", false, 10, function(s)
    AntiTP.Enabled = s
    if not s then releaseNet() end
end)

local movePage = CreateTab("Move", "M")
AddSection(movePage, "Movement", 1)
AddToggle(movePage, "Speed", "Change walk speed", false, 2, function(s) toggleSpeed(s) end)
AddSlider(movePage, "Speed Value", 16, 500, 60, 0, 3, function(v) Config.SpeedValue = v end)
AddToggle(movePage, "Fly", "Camera-relative flight", false, 4, function(s)
    if s then enableFly() else disableFly() end
end)
AddSlider(movePage, "Fly Speed", 20, 1000, 100, 0, 5, function(v) Config.FlySpeed = v end)
AddToggle(movePage, "Noclip", "Walk through walls [F2]", false, 6, function(s) toggleNoclip(s) end)
AddToggle(movePage, "Auto Drive", "Auto drive vehicle", false, 7, function(s) toggleAutoDrive(s) end)
AddToggle(movePage, "Infinite Jump", "Jump forever", false, 8, function(s) Config.IsInfiniteJumpOn = s end)

local combatPage = CreateTab("Combat", "C")
AddSection(combatPage, "Aimbot", 1)
AddToggle(combatPage, "Aimbot", "Auto target [F3]", false, 2, function(s) toggleAimbot(s) end)
AddSlider(combatPage, "FOV", 30, 360, 120, 0, 3, function(v) Config.AimbotFOV = v end)
AddSlider(combatPage, "Smooth", 0.05, 1, 0.15, 2, 4, function(v) Config.AimbotSmooth = v end)
AddToggle(combatPage, "Team Check", "Skip teammates", true, 5, function(s) Config.AimbotTeamCheck = s end)
AddSection(combatPage, "ESP / Chams", 6)
AddToggle(combatPage, "ESP", "Show info [F1]", false, 7, function(s) Config.ESPEnabled = s end)
AddToggle(combatPage, "Names", "Show names", true, 8, function(s) Config.ESPNames = s end)
AddToggle(combatPage, "Health Bar", "Show health", true, 9, function(s) Config.ESPHealth = s end)
AddToggle(combatPage, "Tracers", "Draw line to target", false, 10, function(s) Config.ESPTracers = s end)
AddToggle(combatPage, "Chams", "Color highlight", false, 11, function(s) Config.ChamsEnabled = s end)
AddSlider(combatPage, "ESP Range", 100, 5000, 1000, 0, 12, function(v) Config.ESPRange = v end)

local tpPage = CreateTab("TP", "T")
AddSection(tpPage, "Save Locations", 1)
local locationBox = AddTextInput(tpPage, "Location Name", "e.g. Home", 2, function() end)

local savedListOrder = 4
local function rebuildSavedList()
    for _, c in ipairs(tpPage:GetChildren()) do
        if c:IsA("TextButton") and c:GetAttribute("IsSavedLoc") then c:Destroy() end
    end
    local i = 0
    for name, cf in pairs(Config.SavedLocations) do
        if typeof(cf) == "CFrame" then
            local btn = AddButton(tpPage, "TP " .. name, savedListOrder + i, function()
                local _, _, hrp = getCharacter()
                if hrp then
                    instantTeleport(hrp, cf, 0.2)
                    task.wait(0.3); resetCharacter()
                    Notify("Teleport", "To " .. name, accent, "T")
                end
            end)
            btn:SetAttribute("IsSavedLoc", true)
            i = i + 1
        end
    end
end

AddButton(tpPage, "Save Current Location", 3, function()
    local name = locationBox.Text
    if name and name ~= "" then
        local _, _, hrp = getCharacter()
        if hrp then
            Config.SavedLocations[name] = hrp.CFrame
            Notify("Location", "Saved: " .. name, accent, "P")
            ConfigMgr:Save(Config)
            rebuildSavedList()
        end
    else
        Notify("Location", "Enter a name!", Color3.fromRGB(255,70,70), "!")
    end
end)
rebuildSavedList()

local setPage = CreateTab("Settings", "S")
AddSection(setPage, "General", 1)
AddToggle(setPage, "Anti AFK", "Prevent idle kick", true, 2, function(s) Config.IsAntiAFK = s end)
AddToggle(setPage, "Sound", "UI sounds on/off", true, 3, function(s) Audio.Enabled = s end)
AddSection(setPage, "Theme", 4)
AddThemePicker(setPage, 5)
AddSection(setPage, "Keybinds", 6)
local kbInfo = Instance.new("TextLabel")
kbInfo.LayoutOrder = 7
kbInfo.Size = UDim2.new(1,0,0,95)
kbInfo.BackgroundTransparency = 1
kbInfo.Text = "F1 - Toggle ESP\nF2 - Toggle Noclip\nF3 - Toggle Aimbot\nF4 - Reset TP Stuck\nRCtrl - Minimize"
kbInfo.TextColor3 = Color3.fromRGB(180,180,195)
kbInfo.Font = Enum.Font.Code
kbInfo.TextSize = 10
kbInfo.TextXAlignment = Enum.TextXAlignment.Left
kbInfo.TextYAlignment = Enum.TextYAlignment.Top
kbInfo.Parent = setPage

AddSection(setPage, "Data", 8)
AddButton(setPage, "Reset TP Stuck (F4)", 9, function()
    resetCharacter()
    Notify("Reset", "Character fixed!", Color3.fromRGB(0,255,120), "R")
end)
AddButton(setPage, "Save Config", 10, function()
    ConfigMgr:Save(Config)
    Notify("Config", "Saved!", accent, "S")
end)

local function CleanupAll()
    pcall(function()
        Config.IsSpeedOn=false; Config.IsFlyOn=false
        Config.IsNoclipOn=false; Config.IsAutoDriveOn=false
        Config.IsAutoOn=false; Config.IsInfiniteJumpOn=false
        Config.ESPEnabled=false; Config.ChamsEnabled=false
        Config.AimbotEnabled=false
        Godmode.Enabled=false; AntiTP.Enabled=false
        Combat.Aimbot.Enabled=false

        if speedConn then speedConn:Disconnect(); speedConn=nil end
        disableFly()
        if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
        if autoDriveConn then autoDriveConn:Disconnect(); autoDriveConn=nil end
        toggleAimbot(false)
        disableGodmode()
        releaseNet()
        clearAllESP()
        resetCharacter()

        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
        ConnMgr.purge()
    end)
end

AddButton(setPage, "Close UI", 11, function()
    CleanupAll()
    ScreenGui:Destroy()
end)

-- MOBILE ADJUST ---------------------------------------------------
if DEVICE.IsMobile then
    Sidebar.Size = UDim2.new(0,92,1,-52)
    PageHost.Size = UDim2.new(1,-92,1,-52-42)
    PageHost.Position = UDim2.new(0,92,0,52)
    SideLayout.Padding = UDim.new(0,5)
    SidePad.PaddingTop = UDim.new(0,8)
    NotifScale.Scale = math.clamp(UI_SCALE*0.95, 0.75, 0.95)
    NotifHolder.Size = UDim2.new(0,260,1,-20)
    NotifHolder.Position = UDim2.new(1,-270,0,10)
end

SelectTab(tabs[1])

-- REOPEN ----------------------------------------------------------
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Size = UDim2.new(0,60,0,60)
ReopenBtn.Position = UDim2.new(0,16,0.5,0)
ReopenBtn.AnchorPoint = Vector2.new(0,0.5)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(20,20,26)
ReopenBtn.Text = ""; ReopenBtn.Visible = false
ReopenBtn.BorderSizePixel = 0
ReopenBtn.AutoButtonColor = false
ReopenBtn.Parent = ScreenGui
Corner(ReopenBtn, UDim.new(1,0))
local ReopenScale = Instance.new("UIScale")
ReopenScale.Scale = math.clamp(UI_SCALE+0.2, 0.75, 1.15)
ReopenScale.Parent = ReopenBtn

local roStroke = Stroke(ReopenBtn, Color3.new(1,1,1), 2, 0.2)
RegisterAccent(roStroke, "Color")

local roImg = Instance.new("ImageLabel")
roImg.Size = UDim2.new(1,0,1,0); roImg.BackgroundTransparency = 1
roImg.Image = (CustomImage ~= "" and CustomImage) or IMAGE_FALLBACKS[2]
roImg.ScaleType = Enum.ScaleType.Crop; roImg.Parent = ReopenBtn
Corner(roImg, UDim.new(1,0))

local minimized = false
local function SetMinimized(state)
    minimized = state
    if state then
        ReopenBtn.Visible = true
        ReopenBtn.Size = UDim2.new(0,0,0,0)
        Tween(ReopenBtn, INFO_SPRING, { Size = UDim2.new(0,60,0,60) })
        Tween(MainScale, INFO_FAST, { Scale = UI_SCALE * 0.85 })
        Main.Visible = false; Shadow.Visible = false
    else
        Main.Visible = true; Shadow.Visible = true
        Tween(MainScale, INFO_SPRING, { Scale = UI_SCALE })
        ReopenBtn.Visible = false
    end
end

MinBtn.MouseButton1Click:Connect(function()
    PlayClickEffect(MinBtn); task.wait(0.1); SetMinimized(true)
end)
CloseBtn.MouseButton1Click:Connect(function()
    PlayClickEffect(CloseBtn); task.wait(0.15)
    CleanupAll(); ScreenGui:Destroy()
end)

-- Reopen drag/click
do
    local dragging, moved = false, false
    local startInput, startPos
    ReopenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            startInput = input.Position; startPos = ReopenBtn.Position
        end
    end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
            ReopenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                           startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end))
    ReopenBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    ReopenBtn.MouseButton1Click:Connect(function()
        if not moved then
            PlayClickEffect(ReopenBtn); task.wait(0.15); SetMinimized(false)
        end
    end)
end

-- Main drag (ignores window buttons)
do
    local dragging = false
    local startInput, mainPos, shadowPos
    local function overButton()
        local mp = UserInputService:GetMouseLocation()
        for _, b in ipairs({CloseBtn, MinBtn}) do
            local ap, as = b.AbsolutePosition, b.AbsoluteSize
            if mp.X >= ap.X and mp.X <= ap.X+as.X
            and mp.Y >= ap.Y and mp.Y <= ap.Y+as.Y then
                return true
            end
        end
        return false
    end
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if overButton() then return end
            dragging = true; startInput = input.Position
            mainPos = Main.Position; shadowPos = Shadow.Position
        end
    end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            Main.Position = UDim2.new(mainPos.X.Scale, mainPos.X.Offset+d.X,
                                      mainPos.Y.Scale, mainPos.Y.Offset+d.Y)
            Shadow.Position = UDim2.new(shadowPos.X.Scale, shadowPos.X.Offset+d.X,
                                        shadowPos.Y.Scale, shadowPos.Y.Offset+d.Y)
        end
    end))
    ConnMgr.add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

ConnMgr.add(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then SetMinimized(not minimized) end
end))

-- INIT ------------------------------------------------------------
Tween(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = UI_SCALE })
task.delay(0.3, function()
    Notify("by ouncopybara", "DELTA FIXED v8.2.0 loaded!", Color3.fromRGB(0,255,120), "OK")
    Notify("Tip", "F4 = fix TP stuck", Color3.fromRGB(100,200,255), "i")
end)
updateStatus("System ready - v8.2.0", Color3.fromRGB(0,255,120))
