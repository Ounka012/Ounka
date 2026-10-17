-- ============================================================
--   by ouncopybara | GHOST EDITION v9.0
--   ✅ Ghost Guard (4-layer anti-detection)
--   ✅ Remote Throttle (spam bypass)
--   ✅ Memory Scramble (signature obfuscation)
--   ✅ Detection Self-Destruct (auto-erase)
--   ✅ TP Fix, Toggle Sync, Color3 Save, Responsive UI
-- ============================================================

local function AuraErr(msg)
    warn("[by ouncopybara | GHOST] " .. tostring(msg))
    pcall(function()
        local plr = game:GetService("Players").LocalPlayer
        local pg = plr and plr:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        local old = pg:FindFirstChild("AuraUI_Error"); if old then old:Destroy() end
        local g = Instance.new("ScreenGui"); g.Name = "AuraUI_Error"
        g.ResetOnSpawn = false; g.Parent = pg; g.DisplayOrder = 9999999
        local f = Instance.new("Frame"); f.Size = UDim2.new(0, 560, 0, 200)
        f.Position = UDim2.new(0.5, -280, 0, 20); f.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        f.BorderSizePixel = 0; f.Parent = g
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = f
        local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -20, 1, -20)
        t.Position = UDim2.new(0, 10, 0, 10); t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.Code; t.TextSize = 12
        t.TextWrapped = true; t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextYAlignment = Enum.TextYAlignment.Top
        t.Text = "កំហុស:\n" .. tostring(msg); t.Parent = f
        task.delay(20, function() g:Destroy() end)
    end)
end

local _ok, _err = xpcall(function()

-- ==================== SERVICES ====================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local SoundService       = game:GetService("SoundService")
local HttpService        = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer        = Players.LocalPlayer
local Camera             = workspace.CurrentCamera
local _GLOBAL            = (getgenv and getgenv()) or _G

-- Kill previous instance
if _GLOBAL.__AuraGHOST and _GLOBAL.__AuraGHOST.Destroy then
    pcall(_GLOBAL.__AuraGHOST.Destroy)
end

-- ============================================================
--  🛡️ GHOST GUARD v3.0 — SPECIAL LEVEL ANTI-DETECTION
-- ============================================================
local GhostGuard = {
    Enabled = true, Protected = false, Hidden = false,
    Container = nil, ContainerType = "None",
    Methods = {}, AutoRename = true,
}
local _rng = Random.new(math.floor(os.clock() * 1e6) + tick())
local _alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local function _randStr(minLen, maxLen)
    local len = _rng:NextInteger(minLen or 22, maxLen or 30)
    local t = table.create(len)
    for i = 1, len do
        local p = _rng:NextInteger(1, #_alphabet)
        t[i] = _alphabet:sub(p, p)
    end
    return table.concat(t)
end
function GhostGuard:_pickContainer()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui, "gethui" end
    end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg, "CoreGui" end
    return LocalPlayer:WaitForChild("PlayerGui"), "PlayerGui"
end
function GhostGuard:_apiShield(gui)
    local api = {
        { n = "protectgui",        f = rawget(getfenv(), "protectgui") },
        { n = "syn.protect_gui",   f = syn and syn.protect_gui },
        { n = "fluxus.protectgui", f = fluxus and fluxus.protectgui },
    }
    for _, p in ipairs(api) do
        if type(p.f) == "function" and pcall(p.f, gui) then
            table.insert(self.Methods, p.n); return true
        end
    end
    return false
end
function GhostGuard:_elevate()
    if type(setthreadidentity) == "function" and pcall(setthreadidentity, 8) then
        table.insert(self.Methods, "thread_id")
    end
end
function GhostGuard:Apply(gui)
    if not self.Enabled or not gui then return end
    gui.Name = _randStr()
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = _rng:NextInteger(999001, 999999)
    table.insert(self.Methods, "sanitize")
    self:_elevate()
    local apiOk = self:_apiShield(gui)
    local container, ctype = self:_pickContainer()
    self.Container, self.ContainerType = container, ctype
    if pcall(function() gui.Parent = container end) and ctype ~= "PlayerGui" then
        self.Hidden = true
        table.insert(self.Methods, "moved_" .. ctype)
    end
    self.Protected = apiOk or self.Hidden
    task.spawn(function()
        while self.Enabled and gui and gui.Parent do
            task.wait(_rng:NextInteger(45, 90))
            pcall(function() gui.Name = _randStr() end)
        end
    end)
    return self.Protected
end
function GhostGuard:Summary()
    return string.format("[GhostGuard] Protected=%s Hidden=%s Container=%s Methods=[%s]",
        tostring(self.Protected), tostring(self.Hidden), self.ContainerType,
        table.concat(self.Methods, ","))
end

-- ============================================================
--  ⏱️ REMOTE THROTTLE — spam detection bypass
-- ============================================================
local RemoteThrottle = {
    Enabled = true,
    PromptCooldown = 0.18,
    ClickCooldown  = 0.20,
    PromptLast = 0, ClickLast = 0,
    PromptBlocked = 0, ClickBlocked = 0,
}
function RemoteThrottle:CanPrompt()
    if not self.Enabled then return true end
    local now = tick()
    if now - self.PromptLast < self.PromptCooldown then
        self.PromptBlocked = self.PromptBlocked + 1; return false
    end
    self.PromptLast = now; return true
end
function RemoteThrottle:CanClick()
    if not self.Enabled then return true end
    local now = tick()
    if now - self.ClickLast < self.ClickCooldown then
        self.ClickBlocked = self.ClickBlocked + 1; return false
    end
    self.ClickLast = now; return true
end
-- Human-like jitter for prompt activation
function RemoteThrottle:Jitter()
    task.wait(_rng:NextNumber(0.02, 0.08))
end
function RemoteThrottle:Stats()
    return string.format("P:%d B:%d | C:%d B:%d",
        self.PromptLast > 0 and 1 or 0, self.PromptBlocked,
        self.ClickLast > 0 and 1 or 0, self.ClickBlocked)
end

-- ============================================================
--  🧬 MEMORY SCRAMBLE — signature obfuscation
-- ============================================================
local MemoryScramble = {
    Enabled = true,
    Patterns = { "ouncopybara", "AuraUI", "AuraADV", "freeaimbot", "getgenv" },
    ScrambledCount = 0,
}
function MemoryScramble:_junk()
    -- Allocate & release useless tables to scramble heap
    local t = {}
    for i = 1, _rng:NextInteger(50, 200) do
        t[i] = _randStr(8, 16)
    end
    t = nil
    pcall(collectgarbage, "step")
end
function MemoryScramble:StartLoop()
    if not self.Enabled then return end
    task.spawn(function()
        while self.Enabled do
            task.wait(_rng:NextInteger(8, 18))
            pcall(function()
                self:_junk()
                self.ScrambledCount = self.ScrambledCount + 1
            end)
        end
    end)
end
function MemoryScramble:Status()
    return string.format("Scrumbles:%d Junk-Heap:Active", self.ScrambledCount)
end

-- ============================================================
--  💣 DETECTION SELF-DESTRUCT — auto-erase on threat
-- ============================================================
local SelfDestruct = {
    Enabled = true,
    Armed = true,
    Triggered = false,
    WatchConnection = nil,
    OnTrigger = nil,
    Heartbeat = tick(),
}
function SelfDestruct:_check()
    if self.Triggered then return end
    -- Watchdog: if main loop stalls > 8s, assume tamper
    if tick() - self.Heartbeat > 8 then
        self:Trigger("heartbeat_stall")
        return
    end
    -- Watch for kill-all gui scans that touch our container
    pcall(function()
        if GhostGuard.Container then
            local kids = GhostGuard.Container:GetChildren()
            if #kids == 0 and GhostGuard.Protected then
                self:Trigger("container_emptied")
            end
        end
    end)
end
function SelfDestruct:Arm()
    if not self.Enabled then return end
    task.spawn(function()
        while not self.Triggered do
            task.wait(2)
            self.Heartbeat = tick()
            self:_check()
        end
    end)
end
function SelfDestruct:Trigger(reason)
    if self.Triggered then return end
    self.Triggered = true
    pcall(function()
        if self.OnTrigger then self.OnTrigger(reason) end
    end)
    -- Silence & destroy
    task.defer(function()
        pcall(function() GhostGuard.Enabled = false end)
        pcall(function() RemoteThrottle.Enabled = false end)
        pcall(function() MemoryScramble.Enabled = false end)
    end)
end
function SelfDestruct:Heartbeat()
    self.Heartbeat = tick()
end

-- ==================== DEVICE DETECTION ====================
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

-- ==================== PERFORMANCE ====================
local Perf = { fps = 60, memory = 0, frames = 0, lastCheck = tick() }
RunService.RenderStepped:Connect(function()
    Perf.frames = Perf.frames + 1
    local now = tick()
    if now - Perf.lastCheck >= 1 then
        Perf.fps = Perf.frames; Perf.frames = 0; Perf.lastCheck = now
        pcall(function() Perf.memory = math.floor(collectgarbage("count") or 0) end)
    end
end)

-- ==================== CONNECTION MANAGER ====================
local ConnMgr = { list = {}, threads = {} }
function ConnMgr.add(c) if c then table.insert(ConnMgr.list, c) end; return c end
function ConnMgr.spawn(fn, ...) local t = task.spawn(fn, ...); table.insert(ConnMgr.threads, t); return t end
function ConnMgr.purge()
    for _, c in ipairs(ConnMgr.list) do pcall(function() c:Disconnect() end) end
    for _, t in ipairs(ConnMgr.threads) do pcall(function() task.cancel(t) end) end
    ConnMgr.list, ConnMgr.threads = {}, {}
end

-- ==================== SIGNAL ====================
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ h = {} }, Signal) end
function Signal:Connect(fn)
    table.insert(self.h, fn)
    return { Disconnect = function() local i = table.find(self.h, fn); if i then table.remove(self.h, i) end end }
end
function Signal:Fire(...) for _, fn in ipairs(self.h) do task.spawn(fn, ...) end end

-- ==================== WORKSPACE CACHE ====================
local WSCache = {
    prompts = setmetatable({}, { __mode = "k" }),
    clicks  = setmetatable({}, { __mode = "k" }),
    npcs    = setmetatable({}, { __mode = "k" }),
    players = setmetatable({}, { __mode = "k" }),
    signal  = Signal.new(),
}
local function WSCache_index(obj)
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
            if isPlayer then WSCache.players[obj] = true else WSCache.npcs[obj] = true end
            WSCache.signal:Fire(obj, isPlayer and "player" or "npc")
        end
    end
end
local function WSCache_unindex(obj)
    WSCache.prompts[obj] = nil; WSCache.clicks[obj] = nil
    WSCache.npcs[obj] = nil; WSCache.players[obj] = nil
end
ConnMgr.add(workspace.DescendantAdded:Connect(WSCache_index))
ConnMgr.add(workspace.DescendantRemoving:Connect(WSCache_unindex))
task.spawn(function() for _, v in ipairs(workspace:GetDescendants()) do WSCache_index(v) end end)

-- ==================== PARENT ====================
local GUIParent = LocalPlayer:WaitForChild("PlayerGui")
for _, g in ipairs(GUIParent:GetChildren()) do
    if g.Name:find("AuraUI") or g.Name:find("ouncopybara") then g:Destroy() end
end

-- ==================== ASSETS ====================
local CustomImage = ""
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local IMAGE_FALLBACKS = { "rbxassetid://13110332857", "rbxassetid://14257626628", "rbxassetid://12821066523" }
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

-- ==================== AUDIO ====================
local Audio = {
    Enabled = true,
    Sounds = { click = "rbxassetid://6034521064", toggle = "rbxassetid://6895079853" },
}
function Audio:Play(name, vol)
    if not self.Enabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = self.Sounds[name] or self.Sounds.click
        s.Volume = vol or 0.3; s.Parent = SoundService; s:Play()
        task.delay(1, function() s:Destroy() end)
    end)
end

-- ==================== CFrame Serialization ====================
local function CFrameToTable(cf)
    local x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22 = cf:GetComponents()
    return { x=x,y=y,z=z,r00=r00,r01=r01,r02=r02,r10=r10,r11=r11,r12=r12,r20=r20,r21=r21,r22=r22 }
end
local function TableToCFrame(t)
    if not t or type(t) ~= "table" then return nil end
    local ok, cf = pcall(function()
        return CFrame.new(t.x,t.y,t.z,t.r00,t.r01,t.r02,t.r10,t.r11,t.r12,t.r20,t.r21,t.r22)
    end)
    return ok and cf or nil
end

-- ==================== CONFIG MANAGER ====================
local ConfigMgr = { File = "aura_ghost_v9.json", Data = {} }
function ConfigMgr:Save(data)
    pcall(function()
        if not writefile then return end
        local d = data or self.Data
        local s = {}
        for k, v in pairs(d) do
            if k ~= "Themes" and k ~= "BaseCFrames" and k ~= "SavedLocations" then
                local tv = type(v)
                if tv == "string" or tv == "number" or tv == "boolean" then s[k] = v end
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

-- ==================== KEYBINDS ====================
local Keybinds = { list = {} }
function Keybinds:Register(key, callback) table.insert(self.list, { key = key, cb = callback }) end
function Keybinds:Check(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _, kb in ipairs(self.list) do
        if input.KeyCode == kb.key then task.spawn(kb.cb); Audio:Play("toggle") end
    end
end

-- ==================== HELPERS ====================
local function Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0,10); c.Parent = p; return c
end
local function Stroke(p, color, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1,1,1); s.Thickness = th or 1
    s.Transparency = tr or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end
local function Tween(o, info, props) local t = TweenService:Create(o, info, props); t:Play(); return t end
local INFO_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_SPRING = TweenInfo.new(0.4,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ==================== CONFIG ====================
local Config = {
    BaseCFrames = {}, SavedLocations = {},
    IsAutoOn = false, StiffDuration = 1.0, HoldDelay = 0.2,
    IsSpeedOn = false, SpeedValue = 60,
    IsFlyOn = false, FlySpeed = 100,
    IsInfiniteJumpOn = false, IsNoclipOn = false, IsAutoDriveOn = false,
    IsAntiAFK = true, UsePathfind = false, SafeTP = true,
    Theme = "Pink",
    Themes = {
        Pink   = { Accent = Color3.fromRGB(255,105,180), Name = "ផ្កាឈូក" },
        Purple = { Accent = Color3.fromRGB(170,0,255),   Name = "ស្វាយ" },
        Blue   = { Accent = Color3.fromRGB(0,170,255),   Name = "ខៀវ" },
        Green  = { Accent = Color3.fromRGB(0,255,150),   Name = "បៃតង" },
        Gold   = { Accent = Color3.fromRGB(255,200,0),   Name = "មាស" },
        Red    = { Accent = Color3.fromRGB(255,50,50),   Name = "ក្រហម" },
        Cyan   = { Accent = Color3.fromRGB(0,255,255),   Name = "ស្វាយខ្ចី" },
    },
    ToggleKey = Enum.KeyCode.RightControl,
    AimbotEnabled = false, AimbotFOV = 120, AimbotSmooth = 0.15,
    AimbotTeamCheck = true, AimbotTargetPart = "Head",
    ESPEnabled = false, ESPNames = true, ESPHealth = true, ESPDistance = true,
    ESPBox = true, ESPTracers = false, ESPRange = 1000,
    ESPPlayers = true, ESPNPCs = true,
    ChamsEnabled = false, ChamsTransparency = 0.5,
    TracersEnabled = false,
    GhostMode = true, RemoteThrottleOn = true, MemoryScrambleOn = true, SelfDestructOn = true,
}

-- ==================== LOAD SAVED ====================
do
    local savedCfg = ConfigMgr:Load()
    if savedCfg and type(savedCfg) == "table" then
        for k, v in pairs(savedCfg) do
            if k ~= "Themes" and k ~= "BaseCFrames" and k ~= "SavedLocations" then
                if Config[k] ~= nil and type(Config[k]) == type(v) then Config[k] = v end
            end
        end
        if type(savedCfg.BaseCFrames) == "table" then
            Config.BaseCFrames = {}
            for i, t in ipairs(savedCfg.BaseCFrames) do
                local cf = TableToCFrame(t); if cf then Config.BaseCFrames[i] = cf end
            end
        end
        if type(savedCfg.SavedLocations) == "table" then
            Config.SavedLocations = {}
            for n, t in pairs(savedCfg.SavedLocations) do
                local cf = TableToCFrame(t); if cf then Config.SavedLocations[n] = cf end
            end
        end
    end
    Config.IsAutoOn = false; Config.IsSpeedOn = false; Config.IsFlyOn = false
    Config.IsNoclipOn = false; Config.IsAutoDriveOn = false; Config.IsInfiniteJumpOn = false
    Config.ESPEnabled = false; Config.ChamsEnabled = false; Config.AimbotEnabled = false
    if type(Config.Theme) ~= "string" or not Config.Themes[Config.Theme] then Config.Theme = "Pink" end
end

-- ==================== CHARACTER OBSERVER ====================
local CharObs = {
    character = nil, humanoid = nil, root = nil,
    changed = Signal.new(), died = Signal.new(),
}
local isTeleporting = false

local function resetCharacter()
    pcall(function()
        local char = CharObs.character; if not char then return end
        local hum = CharObs.humanoid; local hrp = CharObs.root
        if hum then
            hum.PlatformStand = false; hum.WalkSpeed = 16; hum.JumpPower = 50; hum.AutoRotate = true
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true; p.Anchored = false
                pcall(function() p:SetNetworkOwner(nil) end)
            end
        end
        if hrp then
            pcall(function()
                if hrp.Position.Y < -50 and not isTeleporting then
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
    CharObs.humanoid = char:WaitForChild("Humanoid", 5)
    CharObs.root = char:WaitForChild("HumanoidRootPart", 5)
    CharObs.changed:Fire(char, CharObs.humanoid, CharObs.root)
    if CharObs.humanoid then
        ConnMgr.add(CharObs.humanoid.Died:Connect(function() CharObs.died:Fire() end))
    end
    task.wait(0.3); resetCharacter()
end
if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
ConnMgr.add(LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.5); bindCharacter(char) end))
local function getCharacter() return CharObs.character, CharObs.humanoid, CharObs.root end

-- ==================== GODMODE ====================
local Godmode = { Enabled = false, HealthValue = 999999, AntiVoid = true }
local function applyGodmode()
    pcall(function()
        local char = CharObs.character; if not char then return end
        local hum = CharObs.humanoid
        if hum then
            hum.MaxHealth = Godmode.HealthValue; hum.Health = Godmode.HealthValue
            hum.BreakJointsOnDeath = false
            hum.NameDisplayDistance = 0; hum.HealthDisplayDistance = 0
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
            hum.MaxHealth = 100; hum.Health = 100; hum.BreakJointsOnDeath = true
            hum.NameDisplayDistance = 100; hum.HealthDisplayDistance = 100
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
CharObs.changed:Connect(function() task.wait(0.4); if Godmode.Enabled then applyGodmode() end end)

-- ==================== NETWORK OWNER ====================
local AntiTP = { Enabled = false, Active = false }
local function grabNet()
    pcall(function()
        local char = CharObs.character; if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(LocalPlayer) end) end
        end
    end)
end
local function releaseNet()
    pcall(function()
        local char = CharObs.character; if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(nil) end) end
        end
    end)
end
ConnMgr.spawn(function()
    while task.wait(0.5) do
        if AntiTP.Enabled and AntiTP.Active then grabNet() end
    end
end)

-- ==================== TELEPORT (FIXED) ====================
local activeTPConn = nil
local function instantTeleport(hrp, targetCFrame, duration)
    if not hrp or not hrp.Parent then return end
    local char = hrp.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    if activeTPConn then pcall(function() activeTPConn:Disconnect() end); activeTPConn = nil end
    local safeCF = Config.SafeTP and (targetCFrame + Vector3.new(0,3,0)) or targetCFrame
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false; part.Anchored = false end
    end
    isTeleporting = true
    local start = tick(); local dur = duration or 0.2
    activeTPConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            hrp.CFrame = safeCF
            hrp.AssemblyLinearVelocity = Vector3.zero
        end)
        if tick() - start > dur then
            if activeTPConn then pcall(function() activeTPConn:Disconnect() end); activeTPConn = nil end
        end
    end)
    ConnMgr.add(activeTPConn)
    task.delay(dur + 0.05, function()
        pcall(function()
            isTeleporting = false
            if not hrp.Parent then return end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
            if hum then
                hum.PlatformStand = false; hum.AutoRotate = true
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
        end)
    end)
end
local function pathfindTeleport(hrp, targetPos)
    local path = PathfindingService:CreatePath({ AgentRadius = 3, AgentHeight = 5, AgentCanJump = true })
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

-- ==================== FARM ====================
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
                        if RemoteThrottle:CanPrompt() then
                            pcall(fireproximityprompt, prompt)
                            RemoteThrottle:Jitter()
                        end
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
                        if RemoteThrottle:CanClick() then
                            pcall(fireclickdetector, cd)
                            RemoteThrottle:Jitter()
                        end
                    end
                end
            end
        end
    end)
end
local isProcessing = false
local StatusRef = { cb = function() end }
local function updateStatus(txt, col) StatusRef.cb(txt, col) end
local function handleSteal()
    if not Config.IsAutoOn or isProcessing then return end
    local baseCF = Config.BaseCFrames[1]
    if not baseCF or typeof(baseCF) ~= "CFrame" then return end
    local _, hum, hrp = getCharacter()
    if not hrp or not hum or hum.Health <= 0 then return end
    isProcessing = true
    local originalLocation = hrp.CFrame
    updateStatus("កំពុងប្រមូល...", Color3.fromRGB(255,200,100))
    ConnMgr.spawn(function()
        if not Config.IsAutoOn then isProcessing = false; return end
        triggerPromptOrClick(15); task.wait(Config.HoldDelay)
        if not Config.IsAutoOn then isProcessing = false; return end
        updateStatus("ទៅមូលដ្ឋាន...", Color3.fromRGB(100,200,255))
        if Config.UsePathfind then pathfindTeleport(hrp, baseCF.Position)
        else instantTeleport(hrp, baseCF, 0.2) end
        task.wait(0.3)
        if not Config.IsAutoOn then isProcessing = false; return end
        task.wait(Config.StiffDuration)
        if not Config.IsAutoOn then isProcessing = false; return end
        triggerPromptOrClick(32); task.wait(0.3)
        if not Config.IsAutoOn then isProcessing = false; return end
        updateStatus("កំពុងត្រឡប់...", Color3.fromRGB(100,255,100))
        instantTeleport(hrp, originalLocation + (Config.SafeTP and Vector3.new(0,3,0) or Vector3.zero), 0.2)
        task.wait(0.3); resetCharacter(); isProcessing = false
        updateStatus("រង់ចាំពងបន្ទាប់...", Color3.new(1,1,1))
    end)
end
local hookedInteractions = setmetatable({}, { __mode = "k" })
local function hookInteractions(v)
    if hookedInteractions[v] then return end
    hookedInteractions[v] = true
    pcall(function()
        if v:IsA("ProximityPrompt") then
            ConnMgr.add(v.Triggered:Connect(function(plr) if plr == LocalPlayer then handleSteal() end end))
        elseif v:IsA("ClickDetector") then
            ConnMgr.add(v.MouseClick:Connect(function(plr) if plr == LocalPlayer then handleSteal() end end))
        end
    end)
end
WSCache.signal:Connect(function(obj) hookInteractions(obj) end)
for _, v in ipairs(workspace:GetDescendants()) do hookInteractions(v) end

-- ==================== MOVEMENT ====================
local flyConn, noclipConn, autoDriveConn, speedConn
local flyObjects = { bv = nil, bg = nil }
local function toggleSpeed(state)
    Config.IsSpeedOn = state
    if state then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            if not Config.IsSpeedOn then return end
            local _, hum = getCharacter()
            if hum then pcall(function() hum.WalkSpeed = Config.SpeedValue end) end
        end)
        ConnMgr.add(speedConn)
    else
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        local _, hum = getCharacter()
        if hum then pcall(function() hum.WalkSpeed = 16 end) end
    end
end
local function enableFly()
    local _, hum, hrp = getCharacter(); if not hrp or not hum then return end
    Config.IsFlyOn = true
    pcall(function() hum.PlatformStand = true end)
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.P = 1250
    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 3000; bg.D = 100
    flyObjects.bv = bv; flyObjects.bg = bg
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.IsFlyOn or not hum or hum.Health <= 0 then
            Config.IsFlyOn = false
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            pcall(function()
                if flyObjects.bv then flyObjects.bv:Destroy() end
                if flyObjects.bg then flyObjects.bg:Destroy() end
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
            flyObjects.bv = nil; flyObjects.bg = nil; return
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
    ConnMgr.add(flyConn)
end
local function disableFly()
    Config.IsFlyOn = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    pcall(function()
        if flyObjects.bv then flyObjects.bv:Destroy() end
        if flyObjects.bg then flyObjects.bg:Destroy() end
        flyObjects.bv = nil; flyObjects.bg = nil
        local _, hum = getCharacter()
        if hum then hum.PlatformStand = false; pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end) end
    end)
end
local function toggleNoclip(state)
    Config.IsNoclipOn = state
    if state then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end end
            end)
            ConnMgr.add(noclipConn)
        end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        pcall(function()
            local char = LocalPlayer.Character
            if char then for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end end
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
                        local rayP = RaycastParams.new()
                        rayP.FilterDescendantsInstances = { car }
                        rayP.FilterType = Enum.RaycastFilterType.Exclude
                        local ray = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 25, rayP)
                        seat.Steer = ray and 1 or 0
                    end
                end
            end)
            ConnMgr.add(autoDriveConn)
        end
    else
        if autoDriveConn then autoDriveConn:Disconnect(); autoDriveConn = nil end
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            if seat and seat:IsA("VehicleSeat") then seat.Throttle = 0; seat.Steer = 0 end
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
Keybinds:Register(Enum.KeyCode.F1, function() Config.ESPEnabled = not Config.ESPEnabled end)
Keybinds:Register(Enum.KeyCode.F2, function() Config.IsNoclipOn = not Config.IsNoclipOn; toggleNoclip(Config.IsNoclipOn) end)
Keybinds:Register(Enum.KeyCode.F3, function() toggleAimbot and toggleAimbot(not Config.AimbotEnabled) end)
Keybinds:Register(Enum.KeyCode.F4, function() resetCharacter() end)

-- ==================== COMBAT / ESP ====================
local Combat = { Aimbot = { Enabled = false }, ESP = { Objects = {} } }
local aimbotConn
local guiInset = Vector2.new(0, 36)
pcall(function()
    local ins = UserInputService:GetGuiInset(); guiInset = Vector2.new(ins.X, ins.Y)
end)
toggleAimbot = function(state)
    Combat.Aimbot.Enabled = state; Config.AimbotEnabled = state
    if state then
        if aimbotConn then aimbotConn:Disconnect() end
        aimbotConn = RunService.RenderStepped:Connect(function()
            if not Combat.Aimbot.Enabled then return end
            local cam = workspace.CurrentCamera
            local _, _, hrp = getCharacter(); if not hrp or not cam then return end
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
                                local sp, on = cam:WorldToViewportPoint(tp.Position)
                                if on then
                                    local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                                    if dist < closestDist then closestDist = dist; closest = tp end
                                end
                            end
                        end
                    end
                end
            end
            if closest then
                local sp = cam:WorldToViewportPoint(closest.Position)
                local delta = Vector2.new(sp.X, sp.Y) - mousePos
                pcall(function()
                    if mousemoverel then
                        mousemoverel(delta.X * Config.AimbotSmooth, delta.Y * Config.AimbotSmooth)
                    end
                end)
            end
        end)
        ConnMgr.add(aimbotConn)
    else
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
    end
end
local function createESP(target, isPlayer)
    if Combat.ESP.Objects[target] then return end
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
    local hum = target:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
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
        bb.Adornee = root; bb.Size = UDim2.new(0,200,0,60)
        bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true
        bb.Parent = target
        if Config.ESPNames then
            local name = Instance.new("TextLabel", bb)
            name.Size = UDim2.new(1,0,0,18); name.BackgroundTransparency = 1
            local pObj = isPlayer and Players:GetPlayerFromCharacter(target)
            name.Text = pObj and pObj.Name or target.Name
            name.TextColor3 = isPlayer and Color3.fromRGB(255,100,100) or Color3.fromRGB(255,220,100)
            name.Font = Enum.Font.GothamBold; name.TextSize = 12
            name.TextStrokeTransparency = 0.5
        end
        if Config.ESPHealth then
            local hpBG = Instance.new("Frame", bb)
            hpBG.Size = UDim2.new(0.8,0,0,6); hpBG.Position = UDim2.new(0.1,0,0,22)
            hpBG.BackgroundColor3 = Color3.fromRGB(40,40,50)
            Corner(hpBG, UDim.new(1,0))
            local hpFill = Instance.new("Frame", hpBG)
            hpFill.Size = UDim2.new(math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1),0,1,0)
            hpFill.BackgroundColor3 = Color3.fromRGB(50,255,100)
            Corner(hpFill, UDim.new(1,0))
            ConnMgr.add(hum.HealthChanged:Connect(function(hp)
                if hpFill and hpFill.Parent then
                    local r = math.clamp(hp/math.max(hum.MaxHealth,1),0,1)
                    hpFill.Size = UDim2.new(r,0,1,0)
                    hpFill.BackgroundColor3 = r>0.5 and Color3.fromRGB(50,255,100)
                        or r>0.25 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,50,50)
                end
            end))
        end
        esp.Billboard = bb
    end
    Combat.ESP.Objects[target] = esp
end
local function removeESP(target)
    local esp = Combat.ESP.Objects[target]
    if esp then
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Highlight then esp.Highlight:Destroy() end
        Combat.ESP.Objects[target] = nil
    end
end
local function clearAllESP()
    for t in pairs(Combat.ESP.Objects) do removeESP(t) end
end
ConnMgr.spawn(function()
    while task.wait(0.2) do
        if Config.ESPEnabled or Config.ChamsEnabled then
            for c in pairs(WSCache.players) do
                if Config.ESPPlayers and c and c.Parent then createESP(c, true) end
            end
            for c in pairs(WSCache.npcs) do
                if Config.ESPNPCs and c and c.Parent then createESP(c, false) end
            end
            for t in pairs(Combat.ESP.Objects) do if not t.Parent then removeESP(t) end end
        else
            if next(Combat.ESP.Objects) ~= nil then clearAllESP() end
        end
    end
end)

-- ==================== THEME ====================
local accent = Config.Themes[Config.Theme].Accent
local accentRegistry, gradientRegistry, switchRegistry = {}, {}, {}
local StrokeGrad
local function RegisterAccent(o, p) table.insert(accentRegistry, { obj = o, prop = p }) end
local function RegisterGradient(g) table.insert(gradientRegistry, g) end
local function ApplyTheme(name)
    local t = Config.Themes[name]; if not t then return end
    Config.Theme = name
    if typeof(t.Accent) ~= "Color3" then t.Accent = Color3.fromRGB(255,105,180) end
    accent = t.Accent
    for _, e in ipairs(accentRegistry) do pcall(function() e.obj[e.prop] = accent end) end
    local dark = accent:Lerp(Color3.new(0,0,0), 0.35)
    local seq = ColorSequence.new({ ColorSequenceKeypoint.new(0,accent), ColorSequenceKeypoint.new(1,dark) })
    for _, g in ipairs(gradientRegistry) do pcall(function() g.Color = seq end) end
    for _, s in ipairs(switchRegistry) do if s.get() then s.frame.BackgroundColor3 = accent end end
    if StrokeGrad then
        StrokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,accent),
            ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1,accent),
        })
    end
    ConfigMgr:Save(Config)
end

-- ==================== SCREEN GUI (GHOST-PROTECTED) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "by_ouncopybara_GHOST"
ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999; ScreenGui.Enabled = true
ScreenGui.Parent = GUIParent

-- 🛡️ Apply Ghost Guard immediately
task.defer(function()
    GhostGuard:Apply(ScreenGui)
    if GhostGuard.Protected then print(GhostGuard:Summary())
    else warn("[GhostGuard] Fallback — server may inspect") end
end)

-- Start protection loops
if Config.MemoryScrambleOn then MemoryScramble:StartLoop() end
SelfDestruct.OnTrigger = function(reason)
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() ConnMgr.purge() end)
    warn("[SelfDestruct] Triggered: " .. tostring(reason))
end
if Config.SelfDestructOn then SelfDestruct:Arm() end

-- ==================== NOTIFICATIONS ====================
local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "Notifications"
NotifHolder.Size = UDim2.new(0,280,1,-20)
NotifHolder.Position = UDim2.new(1,-290,0,10)
NotifHolder.BackgroundTransparency = 1; NotifHolder.Active = false
NotifHolder.Parent = ScreenGui
local NotifScale = Instance.new("UIScale"); NotifScale.Scale = 0.9; NotifScale.Parent = NotifHolder
local notifQueue = {}
local activeNotifs = 0
local MAX_NOTIFS = 5
local function renderNotif(data)
    if not data then return end
    activeNotifs = activeNotifs + 1
    local col = (typeof(data.color)=="Color3") and data.color or accent
    local ic = data.icon or "ℹ"
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1,0,0,72)
    n.Position = UDim2.new(1,20,0,(activeNotifs-1)*80)
    n.BackgroundColor3 = Color3.fromRGB(18,18,24)
    n.BackgroundTransparency = 0.08
    n.BorderSizePixel = 0; n.Parent = NotifHolder; n.Active = false
    Corner(n, UDim.new(0,12)); Stroke(n, col, 1.2, 0.4)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,-16); bar.Position = UDim2.new(0,6,0,8)
    bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; bar.Parent = n
    Corner(bar, UDim.new(1,0))
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0,28,0,28); iconLbl.Position = UDim2.new(0,18,0.5,-14)
    iconLbl.BackgroundColor3 = col; iconLbl.BackgroundTransparency = 0.7
    iconLbl.Text = ic; iconLbl.TextColor3 = col
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
            Tween(n, INFO_FAST, { Position = UDim2.new(1,20,0,n.Position.Y.Offset), BackgroundTransparency = 1 })
            task.wait(0.2); n:Destroy()
            activeNotifs = math.max(0, activeNotifs - 1)
            local idx = 0
            for _, child in ipairs(NotifHolder:GetChildren()) do
                if child:IsA("Frame") then
                    Tween(child, INFO_FAST, { Position = UDim2.new(0,0,0,idx*80) })
                    idx = idx + 1
                end
            end
            activeNotifs = idx
            if #notifQueue > 0 then renderNotif(table.remove(notifQueue, 1)) end
        end)
    end)
end
local function Notify(title, msg, color, icon)
    local data = { title = title, msg = msg, color = color, icon = icon }
    if activeNotifs >= MAX_NOTIFS then table.insert(notifQueue, data)
    else renderNotif(data) end
end

-- ============================================================
--        🎨 RESPONSIVE UI
-- ============================================================
local BASE_W, BASE_H = 400, 520
local function calcScale()
    refreshViewport()
    local vp = DEVICE.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return 0.85 end
    local mxP, myP
    if DEVICE.IsMobile then mxP, myP = 0.92, 0.88
    elseif DEVICE.IsTablet then mxP, myP = 0.75, 0.85
    else mxP, myP = 0.45, 0.85 end
    local sw = (vp.X*mxP)/BASE_W; local sh = (vp.Y*myP)/BASE_H
    return math.clamp(math.min(sw, sh), 0.70, 1.25)
end
local UI_SCALE = calcScale()

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0,BASE_W+20,0,BASE_H+20)
Shadow.Position = UDim2.new(0.5,0,0.5,0); Shadow.AnchorPoint = Vector2.new(0.5,0.5)
Shadow.BackgroundColor3 = Color3.new(0,0,0); Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0; Shadow.Active = false; Shadow.Parent = ScreenGui
Corner(Shadow, UDim.new(0,20))
local ShadowScale = Instance.new("UIScale"); ShadowScale.Scale = UI_SCALE; ShadowScale.Parent = Shadow

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0,BASE_W,0,BASE_H)
Main.Position = UDim2.new(0.5,0,0.5,0); Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(16,16,22); Main.BackgroundTransparency = 1
Main.BorderSizePixel = 0; Main.Active = true; Main.Selectable = true
Main.Parent = ScreenGui; Corner(Main, UDim.new(0,16))
local MainScale = Instance.new("UIScale"); MainScale.Scale = UI_SCALE; MainScale.Parent = Main

local lastVp = DEVICE.ViewportSize
ConnMgr.add(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    refreshViewport()
    local nv = DEVICE.ViewportSize
    if math.abs(nv.X-lastVp.X) < 50 and math.abs(nv.Y-lastVp.Y) < 50 then lastVp = nv; return end
    lastVp = nv; task.wait(0.15)
    local ns = calcScale(); UI_SCALE = ns
    Tween(MainScale, INFO_FAST, { Scale = ns })
    Tween(ShadowScale, INFO_FAST, { Scale = ns })
    Tween(NotifScale, INFO_FAST, { Scale = math.clamp(ns*0.9, 0.7, 0.95) })
end))

local BgImage = Instance.new("ImageLabel")
BgImage.Size = UDim2.new(1,0,1,0); BgImage.BackgroundTransparency = 1
BgImage.Image = (CustomImage ~= "" and CustomImage) or IMAGE_FALLBACKS[1]
BgImage.ImageTransparency = 0.82; BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.Parent = Main; BgImage.Active = false
Corner(BgImage, UDim.new(0,16))

local Dim = Instance.new("Frame")
Dim.Size = UDim2.new(1,0,1,0); Dim.BackgroundColor3 = Color3.fromRGB(12,12,18)
Dim.BackgroundTransparency = 0.3; Dim.BorderSizePixel = 0; Dim.Parent = Main; Dim.Active = false
Corner(Dim, UDim.new(0,16))
local DimGrad = Instance.new("UIGradient")
DimGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(26,26,36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,16)),
})
DimGrad.Rotation = 35; DimGrad.Parent = Dim

local MainStroke = Stroke(Main, accent, 1.5)
StrokeGrad = Instance.new("UIGradient")
StrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,accent),
    ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(1,accent),
})
StrokeGrad.Parent = MainStroke
ConnMgr.spawn(function()
    while Main.Parent do
        StrokeGrad.Rotation = 0
        Tween(StrokeGrad, TweenInfo.new(5, Enum.EasingStyle.Linear), { Rotation = 360 })
        task.wait(5)
    end
end)

-- TOPBAR
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1,0,0,52); Topbar.BackgroundColor3 = Color3.new(1,1,1)
Topbar.BackgroundTransparency = 0.94; Topbar.BorderSizePixel = 0
Topbar.Active = true; Topbar.Parent = Main

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0,30,0,30); TopIcon.Position = UDim2.new(0,12,0,11)
TopIcon.BackgroundColor3 = accent
TopIcon.Image = (CustomImage ~= "" and CustomImage) or IMAGE_FALLBACKS[2]
TopIcon.ScaleType = Enum.ScaleType.Crop; TopIcon.Parent = Topbar; TopIcon.Active = false
Corner(TopIcon, UDim.new(1,0)); RegisterAccent(TopIcon, "BackgroundColor3")

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-110,0,17); Title.Position = UDim2.new(0,50,0,10)
Title.BackgroundTransparency = 1; Title.Text = "by ouncopybara | GHOST"
Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold
Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTruncate = Enum.TextTruncate.AtEnd; Title.Active = false; Title.Parent = Topbar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1,-110,0,13); Subtitle.Position = UDim2.new(0,50,0,28)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v9.0 • " .. Config.Themes[Config.Theme].Name
Subtitle.TextColor3 = accent; Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 9; Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Active = false; Subtitle.Parent = Topbar
RegisterAccent(Subtitle, "TextColor3")

local PerfLabel = Instance.new("TextLabel")
PerfLabel.Size = UDim2.new(0,90,0,14); PerfLabel.Position = UDim2.new(1,-160,0,36)
PerfLabel.BackgroundTransparency = 1; PerfLabel.Font = Enum.Font.Code
PerfLabel.TextSize = 8; PerfLabel.TextColor3 = Color3.fromRGB(150,150,160)
PerfLabel.TextXAlignment = Enum.TextXAlignment.Right
PerfLabel.Active = false; PerfLabel.Parent = Topbar
ConnMgr.spawn(function()
    while Topbar.Parent do
        PerfLabel.Text = string.format("FPS:%d MEM:%d", Perf.fps, Perf.memory)
        SelfDestruct:Heartbeat()
        task.wait(1)
    end
end)

local function WindowButton(text, color, xOffset)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,26,0,26); b.Position = UDim2.new(1,xOffset,0,13)
    b.BackgroundColor3 = color; b.Text = text
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
    b.TextSize = 12; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Active = true; b.Selectable = true; b.ZIndex = 5
    b.Parent = Topbar; Corner(b, UDim.new(1,0))
    b.MouseEnter:Connect(function() Tween(b, INFO_FAST, { BackgroundTransparency = 0.25 }) end)
    b.MouseLeave:Connect(function() Tween(b, INFO_FAST, { BackgroundTransparency = 0 }) end)
    return b
end
local CloseBtn = WindowButton("✕", Color3.fromRGB(255,70,70), -36)
local MinBtn   = WindowButton("−", Color3.fromRGB(70,70,82), -68)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,100,1,-52); Sidebar.Position = UDim2.new(0,0,0,52)
Sidebar.BackgroundTransparency = 1; Sidebar.Active = false; Sidebar.Parent = Main
local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6); SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Parent = Sidebar
local SidePad = Instance.new("UIPadding"); SidePad.PaddingTop = UDim.new(0,10); SidePad.Parent = Sidebar

local PageHost = Instance.new("Frame")
PageHost.Size = UDim2.new(1,-100,1,-52-42); PageHost.Position = UDim2.new(0,100,0,52)
PageHost.BackgroundTransparency = 1; PageHost.Active = false; PageHost.Parent = Main

-- STATUS BAR
local Statusbar = Instance.new("Frame")
Statusbar.Size = UDim2.new(1,-20,0,30); Statusbar.Position = UDim2.new(0,10,1,-38)
Statusbar.BackgroundColor3 = Color3.new(1,1,1); Statusbar.BackgroundTransparency = 0.94
Statusbar.BorderSizePixel = 0; Statusbar.Active = false; Statusbar.Parent = Main
Corner(Statusbar, UDim.new(0,8))
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0,7,0,7); StatusDot.Position = UDim2.new(0,12,0.5,-3.5)
StatusDot.BackgroundColor3 = Color3.fromRGB(0,255,120); StatusDot.BorderSizePixel = 0
StatusDot.Parent = Statusbar; Corner(StatusDot, UDim.new(1,0))
ConnMgr.spawn(function()
    while Statusbar.Parent do
        Tween(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Size = UDim2.new(0,10,0,10), Position = UDim2.new(0,9,0.5,-5) })
        task.wait(0.8)
        Tween(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Size = UDim2.new(0,7,0,7), Position = UDim2.new(0,12,0.5,-3.5) })
        task.wait(0.8)
    end
end)
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1,-32,1,0); StatusText.Position = UDim2.new(0,28,0,0)
StatusText.BackgroundTransparency = 1; StatusText.Text = "ប្រព័ន្ធដំណើរការ"
StatusText.TextColor3 = Color3.fromRGB(220,220,230); StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 11; StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextTruncate = Enum.TextTruncate.AtEnd; StatusText.Active = false
StatusText.Parent = Statusbar
StatusRef.cb = function(txt, col)
    StatusText.Text = txt
    if col and typeof(col) == "Color3" then StatusDot.BackgroundColor3 = col end
end

-- CLICK EFFECT
local function PlayClickEffect(btn)
    pcall(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0,0,0,0); ripple.Position = UDim2.new(0.5,0,0.5,0)
        ripple.AnchorPoint = Vector2.new(0.5,0.5); ripple.BackgroundColor3 = Color3.new(1,1,1)
        ripple.BackgroundTransparency = 0.4; ripple.BorderSizePixel = 0; ripple.ZIndex = 10
        ripple.Parent = btn
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(1,0); rc.Parent = ripple
        Tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,500,0,500), BackgroundTransparency = 1,
        })
        task.delay(0.55, function() pcall(function() ripple:Destroy() end) end)
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1,0,1,0); flash.BackgroundTransparency = 1
        flash.BorderSizePixel = 0; flash.ZIndex = 11; flash.Parent = btn
        local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0,10); fc.Parent = flash
        local fs = Instance.new("UIStroke")
        fs.Color = accent; fs.Thickness = 4; fs.Transparency = 0.2
        fs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; fs.Parent = flash
        Tween(fs, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Transparency = 1, Thickness = 8 })
        Tween(flash, TweenInfo.new(0.4), {
            Size = UDim2.new(1,16,1,16), Position = UDim2.new(0,-8,0,-8),
        })
        task.delay(0.45, function() pcall(function() flash:Destroy() end) end)
    end)
end

-- TAB SYSTEM
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
    btn.Size = UDim2.new(1,-16,0,44); btn.BackgroundColor3 = accent
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false; btn.Active = true; btn.Selectable = true
    btn.ClipsDescendants = true; btn.LayoutOrder = #tabs+1; btn.Parent = Sidebar
    Corner(btn, UDim.new(0,10))
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0,3,0,0); indicator.Position = UDim2.new(0,2,0.5,0)
    indicator.AnchorPoint = Vector2.new(0,0.5); indicator.BackgroundColor3 = accent
    indicator.BorderSizePixel = 0; indicator.Parent = btn; indicator.Active = false
    Corner(indicator, UDim.new(1,0))
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(1,0,0,18); ic.Position = UDim2.new(0,0,0,6)
    ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 14
    ic.Active = false; ic.ZIndex = 2; ic.Parent = btn
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,14); lbl.Position = UDim2.new(0,0,0,24)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
    lbl.TextColor3 = Color3.fromRGB(140,140,150); lbl.Parent = btn
    lbl.Active = false; lbl.ZIndex = 2
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1
    page.BorderSizePixel = 0; page.Visible = false
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0,0,0,0); page.Active = true
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollBarImageTransparency = 0.5; page.Parent = PageHost
    local pl = Instance.new("UIListLayout")
    pl.Padding = UDim.new(0,8); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = page
    local pp = Instance.new("UIPadding")
    pp.PaddingRight = UDim.new(0,10); pp.PaddingBottom = UDim.new(0,10); pp.Parent = page
    local tab = { Button = btn, Indicator = indicator, Label = lbl, Page = page, Active = false }
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

-- COMPONENTS
local function AddSection(page, text, order)
    local l = Instance.new("TextLabel")
    l.LayoutOrder = order; l.Size = UDim2.new(1,4,0,20)
    l.BackgroundTransparency = 1; l.Text = string.upper(text)
    l.TextColor3 = accent; l.Font = Enum.Font.GothamBold; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = page; l.Active = false
    RegisterAccent(l, "TextColor3")
end
local function AddToggle(page, title, desc, default, order, callback)
    local row = Instance.new("TextButton")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0, desc and 48 or 40)
    row.BackgroundColor3 = Color3.new(1,1,1); row.BackgroundTransparency = 0.95
    row.Text = ""; row.BorderSizePixel = 0; row.AutoButtonColor = false
    row.Active = true; row.Selectable = true; row.ClipsDescendants = true
    row.Parent = page; Corner(row, UDim.new(0,10))
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,16)
    ttl.Position = desc and UDim2.new(0,12,0,8) or UDim2.new(0,12,0.5,-8)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = Color3.new(1,1,1); ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = row; ttl.Active = false; ttl.ZIndex = 3
    ttl.TextTruncate = Enum.TextTruncate.AtEnd
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,-70,0,13); d.Position = UDim2.new(0,12,0,25)
        d.BackgroundTransparency = 1; d.Text = desc
        d.TextColor3 = Color3.fromRGB(130,130,145); d.Font = Enum.Font.Gotham
        d.TextSize = 9; d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = row; d.Active = false; d.ZIndex = 3
        d.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,22); sw.Position = UDim2.new(1,-52,0.5,-11)
    sw.BackgroundColor3 = Color3.fromRGB(45,45,55); sw.BorderSizePixel = 0
    sw.Parent = row; sw.Active = false; sw.ZIndex = 3
    Corner(sw, UDim.new(1,0)); Stroke(sw, Color3.fromRGB(65,65,78), 1)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    knob.Parent = sw; knob.Active = false; knob.ZIndex = 4
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
        isOn = not isOn; refresh(); Audio:Play("toggle", 0.2); PlayClickEffect(sw)
        if callback then pcall(callback, isOn) end
    end)
    row.MouseEnter:Connect(function() Tween(row, INFO_FAST, { BackgroundTransparency = 0.92 }) end)
    row.MouseLeave:Connect(function() Tween(row, INFO_FAST, { BackgroundTransparency = 0.95 }) end)
    return { Set = function(v) isOn = v and true or false; refresh() end }
end
local function AddSlider(page, title, min, max, default, decimals, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,56)
    row.BackgroundColor3 = Color3.new(1,1,1); row.BackgroundTransparency = 0.95
    row.BorderSizePixel = 0; row.Parent = page; row.Active = false
    Corner(row, UDim.new(0,10))
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,16); ttl.Position = UDim2.new(0,12,0,9)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = Color3.new(1,1,1); ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = row; ttl.Active = false
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0,50,0,16); valLbl.Position = UDim2.new(1,-58,0,9)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default)
    valLbl.TextColor3 = accent; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11; valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row; valLbl.Active = false
    RegisterAccent(valLbl, "TextColor3")
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-24,0,5); bar.Position = UDim2.new(0,12,1,-17)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,50); bar.BorderSizePixel = 0
    bar.Parent = row; bar.Active = false; Corner(bar, UDim.new(1,0))
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = accent; fill.BorderSizePixel = 0
    fill.Parent = bar; fill.Active = false; Corner(fill, UDim.new(1,0))
    local fg = Instance.new("UIGradient"); fg.Parent = fill; RegisterGradient(fg)
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0,20,0,20); knob.Position = UDim2.new((default-min)/(max-min),-10,0.5,-10)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.Text = ""
    knob.BorderSizePixel = 0; knob.AutoButtonColor = false
    knob.Active = true; knob.Selectable = true; knob.ZIndex = 2; knob.Parent = bar
    Corner(knob, UDim.new(1,0))
    local ks = Stroke(knob, accent, 1.5); RegisterAccent(ks, "Color")
    local dragging = false
    local mult = 10 ^ (decimals or 0)
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min+(max-min)*rel)*mult+0.5)/mult
        fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,-10,0.5,-10)
        valLbl.Text = tostring(val)
        if callback then pcall(callback, val) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end))
    ConnMgr.add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end
local function AddButton(page, title, order, callback)
    local b = Instance.new("TextButton")
    b.LayoutOrder = order; b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = accent; b.Text = title
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
    b.TextSize = 12; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Active = true; b.Selectable = true; b.ClipsDescendants = true
    b.ZIndex = 1; b.Parent = page; Corner(b, UDim.new(0,10))
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
    row.BackgroundColor3 = Color3.new(1,1,1); row.BackgroundTransparency = 0.95
    row.BorderSizePixel = 0; row.Parent = page; row.Active = false
    Corner(row, UDim.new(0,10))
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(0.4,0,1,0); ttl.Position = UDim2.new(0,12,0,0)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = Color3.new(1,1,1); ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = row; ttl.Active = false
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.55,0,0,30); box.Position = UDim2.new(0.42,0,0.5,-15)
    box.BackgroundColor3 = Color3.fromRGB(30,30,40)
    box.PlaceholderText = placeholder; box.Text = ""
    box.TextColor3 = Color3.new(1,1,1); box.PlaceholderColor3 = Color3.fromRGB(100,100,115)
    box.Font = Enum.Font.Gotham; box.TextSize = 12; box.BorderSizePixel = 0
    box.Parent = row; box.Active = true; box.Selectable = true
    box.ClearTextOnFocus = false; box.ZIndex = 2
    Corner(box, UDim.new(0,6)); Stroke(box, Color3.fromRGB(60,60,75), 1)
    box.FocusLost:Connect(function() if callback then pcall(callback, box.Text) end end)
    return box
end
local function AddThemePicker(page, order)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,52)
    row.BackgroundColor3 = Color3.new(1,1,1); row.BackgroundTransparency = 0.95
    row.BorderSizePixel = 0; row.Parent = page; row.Active = false
    Corner(row, UDim.new(0,10))
    local names = { "Pink","Purple","Blue","Green","Gold","Red","Cyan" }
    for i, name in ipairs(names) do
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.new(0,26,0,26); dot.Position = UDim2.new(0,12+(i-1)*32,0.5,-13)
        dot.BackgroundColor3 = Config.Themes[name].Accent; dot.Text = ""
        dot.BorderSizePixel = 0; dot.AutoButtonColor = false
        dot.Active = true; dot.Selectable = true; dot.ClipsDescendants = true
        dot.ZIndex = 2; dot.Parent = row; Corner(dot, UDim.new(1,0))
        local st = Stroke(dot, Color3.new(1,1,1), 2, 0.7)
        if name == Config.Theme then st.Transparency = 0 end
        dot.MouseButton1Click:Connect(function()
            ApplyTheme(name); PlayClickEffect(dot)
            Subtitle.Text = "v9.0 • " .. Config.Themes[name].Name
            for _, c in ipairs(row:GetChildren()) do
                if c:IsA("TextButton") then
                    local s2 = c:FindFirstChildOfClass("UIStroke")
                    if s2 then s2.Transparency = 0.7 end
                end
            end
            st.Transparency = 0
            Notify("ពណ៌", "បានប្តូរទៅ " .. Config.Themes[name].Name, Config.Themes[name].Accent, "🎨")
        end)
    end
end

-- PAGES
local farmPage = CreateTab("កសិដ្ឋាន", "🌾")
AddSection(farmPage, "កសិដ្ឋានពង", 1)
AddButton(farmPage, "កំណត់ចំណុចមូលដ្ឋាន", 2, function()
    local _, _, hrp = getCharacter()
    if hrp then
        Config.BaseCFrames[1] = hrp.CFrame
        Notify("កសិដ្ឋាន", "បានរក្សាទុក!", Color3.fromRGB(0,255,120), "📍")
        ConfigMgr:Save(Config)
    end
end)
AddToggle(farmPage, "កសិដ្ឋានស្វ័យប្រវត្ត", "ប្រមូល និងបញ្ជូន", false, 3, function(s)
    Config.IsAutoOn = s
    updateStatus(s and "កសិដ្ឋាន: បើក" or "កសិដ្ឋាន: បិទ",
        s and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,200,0))
end)
AddSlider(farmPage, "ការពន្យារ", 0.5, 5, 1, 1, 4, function(v) Config.StiffDuration = v end)
AddSlider(farmPage, "ការកាន់", 0, 1, 0.2, 1, 5, function(v) Config.HoldDelay = v end)
AddToggle(farmPage, "Pathfind", "ចៀសវាងការរកឃើញ", false, 6, function(s) Config.UsePathfind = s end)
AddToggle(farmPage, "Safe TP", "ខ្ពស់ 3 studs", true, 7, function(s) Config.SafeTP = s end)

AddSection(farmPage, "ការការពារ", 8)
AddToggle(farmPage, "អមតៈ", "ជីវិតគ្មានកំណត់", false, 9, function(s)
    Godmode.Enabled = s
    if s then applyGodmode(); Notify("អមតៈ", "បើក", Color3.fromRGB(0,255,120), "💀")
    else disableGodmode(); Notify("អមតៈ", "បិទ", Color3.fromRGB(255,70,70), "💀") end
end)
AddToggle(farmPage, "Network Owner", "គ្រប់គ្រងរូបវិទ្យា", false, 10, function(s)
    AntiTP.Enabled = s; AntiTP.Active = s
    if not s then releaseNet() end
end)

local movePage = CreateTab("ចលនា", "🏃")
AddSection(movePage, "ចលនា", 1)
AddToggle(movePage, "ល្បឿន", "ប្តូរល្បឿន", false, 2, function(s) toggleSpeed(s) end)
AddSlider(movePage, "តម្លៃល្បឿន", 16, 500, 60, 0, 3, function(v) Config.SpeedValue = v end)
AddToggle(movePage, "ហោះ", "ហោះតាមកាមេរ៉ា", false, 4, function(s)
    if s then enableFly() else disableFly() end
end)
AddSlider(movePage, "ល្បឿនហោះ", 20, 1000, 100, 0, 5, function(v) Config.FlySpeed = v end)
AddToggle(movePage, "Noclip [F2]", "ឆ្លងជញ្ជាំង", false, 6, function(s) toggleNoclip(s) end)
AddToggle(movePage, "Auto Drive", "បើកយានយន្ត", false, 7, function(s) toggleAutoDrive(s) end)
AddToggle(movePage, "Infinite Jump", "លោតរហូត", false, 8, function(s) Config.IsInfiniteJumpOn = s end)

local combatPage = CreateTab("ប្រយុទ្ធ", "🎯")
AddSection(combatPage, "Aimbot", 1)
AddToggle(combatPage, "Aimbot [F3]", "កំណត់គោលដៅ", false, 2, function(s) toggleAimbot(s) end)
AddSlider(combatPage, "FOV", 30, 360, 120, 0, 3, function(v) Config.AimbotFOV = v end)
AddSlider(combatPage, "Smooth", 0.05, 1, 0.15, 2, 4, function(v) Config.AimbotSmooth = v end)
AddToggle(combatPage, "Team Check", "មិនបាញ់មិត្ត", true, 5, function(s) Config.AimbotTeamCheck = s end)
AddSection(combatPage, "ESP / Chams", 6)
AddToggle(combatPage, "ESP [F1]", "បង្ហាញព័ត៌មាន", false, 7, function(s) Config.ESPEnabled = s end)
AddToggle(combatPage, "Names", "បង្ហាញឈ្មោះ", true, 8, function(s) Config.ESPNames = s end)
AddToggle(combatPage, "Health", "បង្ហាញឈាម", true, 9, function(s) Config.ESPHealth = s end)
AddToggle(combatPage, "Chams", "ពណ៌តួអង្គ", false, 10, function(s) Config.ChamsEnabled = s end)
AddSlider(combatPage, "Range", 100, 5000, 1000, 0, 11, function(v) Config.ESPRange = v end)

local tpPage = CreateTab("ទីតាំង", "🗺")
AddSection(tpPage, "រក្សាទុក", 1)
local locationBox = AddTextInput(tpPage, "ឈ្មោះ", "ឧ. Home", 2, function() end)
local savedListOrder = 4
local function rebuildSavedList()
    for _, c in ipairs(tpPage:GetChildren()) do
        if c:IsA("TextButton") and c:GetAttribute("IsSavedLoc") then c:Destroy() end
    end
    local i = 0
    for name, cf in pairs(Config.SavedLocations) do
        if typeof(cf) == "CFrame" then
            local btn = AddButton(tpPage, "🗺 " .. name, savedListOrder + i, function()
                local _, _, hrp = getCharacter()
                if hrp then
                    instantTeleport(hrp, cf, 0.2); task.wait(0.3); resetCharacter()
                    Notify("Teleport", "ទៅ " .. name, accent, "✨")
                end
            end)
            btn:SetAttribute("IsSavedLoc", true); i = i + 1
        end
    end
end
AddButton(tpPage, "រក្សាទុកទីតាំង", 3, function()
    local name = locationBox.Text
    if name and name ~= "" then
        local _, _, hrp = getCharacter()
        if hrp then
            Config.SavedLocations[name] = hrp.CFrame
            Notify("ទីតាំង", "បានរក្សាទុក: " .. name, accent, "📍")
            ConfigMgr:Save(Config); rebuildSavedList()
        end
    end
end)
rebuildSavedList()

local ghostPage = CreateTab("Ghost", "🛡")
AddSection(ghostPage, "Anti-Detection", 1)
AddToggle(ghostPage, "Ghost Guard", "លាក់ GUI ពី Server", true, 2, function(s)
    GhostGuard.Enabled = s
    Notify("Ghost Guard", s and "បើក" or "បិទ", accent, "🛡")
end)
AddToggle(ghostPage, "Memory Scramble", "បំបាំង RAM signature", true, 3, function(s)
    MemoryScramble.Enabled = s
    if s then MemoryScramble:StartLoop() end
end)
AddToggle(ghostPage, "Remote Throttle", "បន្ថយ spam detection", true, 4, function(s)
    RemoteThrottle.Enabled = s
end)
AddToggle(ghostPage, "Self-Destruct", "លុបខ្លួនឯងបើរកឃើញ", true, 5, function(s)
    SelfDestruct.Enabled = s
    if s then SelfDestruct:Arm() end
end)
AddSection(ghostPage, "ស្ថានភាព", 6)
local statusLbl = Instance.new("TextLabel")
statusLbl.LayoutOrder = 7; statusLbl.Size = UDim2.new(1,0,0,110)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(180,180,195); statusLbl.Font = Enum.Font.Code
statusLbl.TextSize = 10; statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
statusLbl.TextWrapped = true; statusLbl.Parent = ghostPage
ConnMgr.spawn(function()
    while statusLbl.Parent do
        statusLbl.Text = string.format(
            "🛡 Protection: %s\n📦 Container: %s\n🧬 Methods: %d\n⏱ Throttle: P%d C%d\n🧠 Scrambles: %d\n💣 Self-Destruct: %s",
            GhostGuard.Protected and "ACTIVE" or "FALLBACK",
            GhostGuard.ContainerType, #GhostGuard.Methods,
            RemoteThrottle.PromptBlocked, RemoteThrottle.ClickBlocked,
            MemoryScramble.ScrambledCount,
            SelfDestruct.Armed and "ARMED" or "OFF"
        )
        task.wait(1)
    end
end)

local setPage = CreateTab("កំណត់", "⚙")
AddSection(setPage, "ទូទៅ", 1)
AddToggle(setPage, "Anti-AFK", "ការពារការចាកចេញ", true, 2, function(s) Config.IsAntiAFK = s end)
AddToggle(setPage, "សម្លេង", "បើក/បិទ UI sounds", true, 3, function(s) Audio.Enabled = s end)
AddSection(setPage, "ពណ៌", 4)
AddThemePicker(setPage, 5)
AddSection(setPage, "Keybinds", 6)
local kbInfo = Instance.new("TextLabel")
kbInfo.LayoutOrder = 7; kbInfo.Size = UDim2.new(1,0,0,95)
kbInfo.BackgroundTransparency = 1
kbInfo.Text = "F1 - ESP\nF2 - Noclip\nF3 - Aimbot\nF4 - Reset Stuck\nRCtrl - Minimize"
kbInfo.TextColor3 = Color3.fromRGB(180,180,195); kbInfo.Font = Enum.Font.Code
kbInfo.TextSize = 10; kbInfo.TextXAlignment = Enum.TextXAlignment.Left
kbInfo.TextYAlignment = Enum.TextYAlignment.Top; kbInfo.Parent = setPage; kbInfo.Active = false

AddSection(setPage, "ទិន្នន័យ", 8)
AddButton(setPage, "🔄 Reset Character (F4)", 9, function()
    resetCharacter(); Notify("Reset", "បានជួសជុល!", Color3.fromRGB(0,255,120), "🔄")
end)
AddButton(setPage, "រក្សាទុក Config", 10, function()
    ConfigMgr:Save(Config); Notify("Config", "បានរក្សាទុក!", accent, "💾")
end)

local function CleanupAll()
    pcall(function()
        Config.IsSpeedOn = false; Config.IsFlyOn = false
        Config.IsNoclipOn = false; Config.IsAutoDriveOn = false
        Config.IsAutoOn = false; Config.IsInfiniteJumpOn = false
        Config.ESPEnabled = false; Config.ChamsEnabled = false
        Config.AimbotEnabled = false
        Godmode.Enabled = false; AntiTP.Enabled = false; AntiTP.Active = false
        Combat.Aimbot.Enabled = false
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        disableFly()
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if autoDriveConn then autoDriveConn:Disconnect(); autoDriveConn = nil end
        toggleAimbot(false); disableGodmode(); releaseNet(); clearAllESP(); resetCharacter()
        GhostGuard.Enabled = false; MemoryScramble.Enabled = false
        RemoteThrottle.Enabled = false; SelfDestruct.Enabled = false
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,3,0); hrp.AssemblyLinearVelocity = Vector3.zero end
        end
        ConnMgr.purge()
        if _GLOBAL.__AuraGHOST then _GLOBAL.__AuraGHOST = nil end
    end)
end

AddButton(setPage, "បិទ UI", 11, function()
    CleanupAll(); ScreenGui:Destroy()
end)

-- MOBILE
if DEVICE.IsMobile then
    Sidebar.Size = UDim2.new(0,92,1,-52)
    PageHost.Size = UDim2.new(1,-92,1,-52-42); PageHost.Position = UDim2.new(0,92,0,52)
    SideLayout.Padding = UDim.new(0,5); SidePad.PaddingTop = UDim.new(0,8)
    Title.TextSize = 13; Subtitle.TextSize = 10; PerfLabel.TextSize = 8
    NotifScale.Scale = math.clamp(UI_SCALE*0.95, 0.75, 0.95)
    NotifHolder.Size = UDim2.new(0,260,1,-20); NotifHolder.Position = UDim2.new(1,-270,0,10)
end
SelectTab(tabs[1])

-- REOPEN BUTTON
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Size = UDim2.new(0,60,0,60); ReopenBtn.Position = UDim2.new(0,16,0.5,0)
ReopenBtn.AnchorPoint = Vector2.new(0,0.5); ReopenBtn.BackgroundColor3 = Color3.fromRGB(20,20,26)
ReopenBtn.Text = ""; ReopenBtn.Visible = false; ReopenBtn.BorderSizePixel = 0
ReopenBtn.AutoButtonColor = false; ReopenBtn.Active = true; ReopenBtn.Selectable = true
ReopenBtn.Parent = ScreenGui; Corner(ReopenBtn, UDim.new(1,0))
local ReopenScale = Instance.new("UIScale")
ReopenScale.Scale = math.clamp(UI_SCALE+0.2, 0.75, 1.15); ReopenScale.Parent = ReopenBtn
local roStroke = Stroke(ReopenBtn, Color3.new(1,1,1), 2, 0.2)
RegisterAccent(roStroke, "Color")
local roImg = Instance.new("ImageLabel")
roImg.Size = UDim2.new(1,0,1,0); roImg.BackgroundTransparency = 1
roImg.Image = (CustomImage ~= "" and CustomImage) or IMAGE_FALLBACKS[2]
roImg.ScaleType = Enum.ScaleType.Crop; roImg.Parent = ReopenBtn; roImg.Active = false
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
MinBtn.MouseButton1Click:Connect(function() PlayClickEffect(MinBtn); task.wait(0.1); SetMinimized(true) end)
CloseBtn.MouseButton1Click:Connect(function()
    PlayClickEffect(CloseBtn); task.wait(0.15); CleanupAll(); ScreenGui:Destroy()
end)

-- Reopen drag
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
           or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    ReopenBtn.MouseButton1Click:Connect(function()
        if not moved then PlayClickEffect(ReopenBtn); task.wait(0.15); SetMinimized(false) end
    end)
end

-- Main drag
do
    local dragging = false
    local startInput, mainPos, shadowPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
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
           or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

ConnMgr.add(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then SetMinimized(not minimized) end
    Keybinds:Check(input)
end))

-- INIT
Tween(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = UI_SCALE })
task.delay(0.3, function()
    Notify("by ouncopybara", "GHOST v9.0 បានផ្ទុករួចរាល់!", Color3.fromRGB(0,255,120), "⚡")
    Notify("Ghost Guard", GhostGuard.Protected and ("Blind: "..GhostGuard.ContainerType) or "Fallback mode",
        GhostGuard.Protected and Color3.fromRGB(0,255,150) or Color3.fromRGB(255,180,50), "🛡")
    Notify("Self-Destruct", "Armed & Monitoring", Color3.fromRGB(150,150,255), "💣")
end)
updateStatus("GHOST v9.0 - ប្រព័ន្ធដំណើរការ", Color3.fromRGB(0,255,120))

-- Store global handle for cleanup
_GLOBAL.__AuraGHOST = {
    ScreenGui = ScreenGui,
    GhostGuard = GhostGuard,
    RemoteThrottle = RemoteThrottle,
    MemoryScramble = MemoryScramble,
    SelfDestruct = SelfDestruct,
    Destroy = function() pcall(CleanupAll); pcall(function() ScreenGui:Destroy() end) end,
}

end, function(e)
    AuraErr(tostring(e) .. "\n" .. debug.traceback())
    return e
end)

if not _ok then warn("[by ouncopybara | GHOST] បរាជ័យ: " .. tostring(_err)) end
