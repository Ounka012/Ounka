-- ============================================================
--   👻 GHOST MODE v10.2 | EGG FARM ONLY (NO TP + FULL VISUALS)
--   by ouncopybara | Halloween Ghost Theme
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.4)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local SoundService      = game:GetService("SoundService")
local HttpService       = game:GetService("HttpService")

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

-- ═══════════════════════════════════════════════════════════════
--   GUIParent
-- ═══════════════════════════════════════════════════════════════
local GUIParent
do
    local ok1, h = pcall(function() return gethui() end)
    if ok1 and h then GUIParent = h
    else
        local ok2, c = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and c then GUIParent = c
        else GUIParent = safeWait(LocalPlayer, "PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui") end
    end
    if not GUIParent then GUIParent = safeWait(LocalPlayer, "PlayerGui", 10) end
end

pcall(function()
    for _, g in ipairs(GUIParent:GetChildren()) do
        if g.Name == "GhostUI" or g.Name == "by_ouncopybara_ADV" then g:Destroy() end
    end
end)

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

-- ═══════════════════════════════════════════════════════════════
--   PERF & CONN MGR & SIGNAL
-- ═══════════════════════════════════════════════════════════════
local Perf = { fps=60, memory=0, frames=0, lastCheck=tick(), ping=0 }
RunService.RenderStepped:Connect(function()
    Perf.frames = Perf.frames + 1
    local now = tick()
    if now - Perf.lastCheck >= 1 then
        Perf.fps = Perf.frames; Perf.frames = 0; Perf.lastCheck = now
        pcall(function() Perf.memory = math.floor(collectgarbage("count") or 0) end)
        pcall(function() Perf.ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    end
end)

local ConnMgr = { list={}, threads={} }
function ConnMgr.add(c) if c then table.insert(ConnMgr.list, c) end return c end
function ConnMgr.spawn(fn, ...) local t = task.spawn(fn, ...); table.insert(ConnMgr.threads, t); return t end
function ConnMgr.purge()
    for _, c in ipairs(ConnMgr.list) do pcall(function() c:Disconnect() end) end
    for _, t in ipairs(ConnMgr.threads) do pcall(function() task.cancel(t) end) end
    ConnMgr.list, ConnMgr.threads = {}, {}
end

local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({h={}}, Signal) end
function Signal:Connect(fn)
    table.insert(self.h, fn)
    return { Disconnect = function()
        local i = table.find(self.h, fn); if i then table.remove(self.h, i) end
    end }
end
function Signal:Fire(...) for _, fn in ipairs(self.h) do task.spawn(fn, ...) end end

-- ═══════════════════════════════════════════════════════════════
--   WORKSPACE CACHE
-- ═══════════════════════════════════════════════════════════════
local WSCache = {
    prompts = setmetatable({}, { __mode = "k" }),
    clicks  = setmetatable({}, { __mode = "k" }),
    signal  = Signal.new(),
}
local function WSCache_index(obj)
    pcall(function()
        if obj:IsA("ProximityPrompt") then
            WSCache.prompts[obj] = true; WSCache.signal:Fire(obj, "prompt")
        elseif obj:IsA("ClickDetector") then
            WSCache.clicks[obj] = true; WSCache.signal:Fire(obj, "click")
        end
    end)
end
local function WSCache_unindex(obj)
    WSCache.prompts[obj] = nil; WSCache.clicks[obj] = nil
end
ConnMgr.add(workspace.DescendantAdded:Connect(WSCache_index))
ConnMgr.add(workspace.DescendantRemoving:Connect(WSCache_unindex))
ConnMgr.spawn(function()
    for _, v in ipairs(workspace:GetDescendants()) do WSCache_index(v) end
end)

-- ═══════════════════════════════════════════════════════════════
--   PREMIUM IMAGE SYSTEM 
-- ═══════════════════════════════════════════════════════════════
local CustomImage  = ""
local ImageReady   = Signal.new()
local ImageObjects = {}
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local IMAGE_FALLBACKS = {
    "rbxassetid://13110332857",
    "rbxassetid://14257626628",
    "rbxassetid://12821066523",
    "rbxassetid://6031075931",
    "rbxasset://textures/ui/GuiImagePlaceholder.png",
}

local function httpGetRaw(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url=url, Method="GET"})
        if ok and res and res.Body then return res.Body end
    end
    if request then
        local ok, res = pcall(request, {Url=url, Method="GET"})
        if ok and res and res.Body then return res.Body end
    end
    if http_request then
        local ok, res = pcall(http_request, {Url=url, Method="GET"})
        if ok and res and res.Body then return res.Body end
    end
    local ok, data = pcall(function() return game:HttpGet(url, true) end)
    if ok and data then return data end
    return nil
end

local function tryGetCustomAsset(fname)
    if not (isfile and getcustomasset) then return nil end
    local ok, exists = pcall(isfile, fname)
    if not ok or not exists then return nil end
    local ok2, a = pcall(getcustomasset, fname)
    if ok2 and type(a) == "string" and a ~= "" then return a end
    return nil
end

local function loadImageSync()
    if not (writefile and isfile and getcustomasset) then
        CustomImage = IMAGE_FALLBACKS[1]
        ImageReady:Fire(CustomImage)
        return CustomImage
    end
    local fname = "aura_icon_adv.jpg"
    local cached = tryGetCustomAsset(fname)
    if cached then
        CustomImage = cached
        ImageReady:Fire(CustomImage)
        return CustomImage
    end
    local data = httpGetRaw(IMAGE_URL)
    if data and type(data) == "string" and #data > 5000 then
        local b = data:sub(1,1)
        if b == "\255" or b == "\137" then
            pcall(writefile, fname, data)
            local url = tryGetCustomAsset(fname)
            if url then
                CustomImage = url
                ImageReady:Fire(CustomImage)
                return CustomImage
            end
        end
    end
    CustomImage = IMAGE_FALLBACKS[1]
    ImageReady:Fire(CustomImage)
    return CustomImage
end

local function registerImage(label)
    if not label then return end
    table.insert(ImageObjects, label)
    if CustomImage ~= "" then pcall(function() label.Image = CustomImage end) end
    ImageReady:Connect(function(url)
        pcall(function() if label.Parent then label.Image = url end end)
    end)
end

loadImageSync()

-- ═══════════════════════════════════════════════════════════════
--   AUDIO
-- ═══════════════════════════════════════════════════════════════
local Audio = {
    Enabled = true,
    Sounds = {
        click  = "rbxassetid://6034521064",
        toggle = "rbxassetid://6895079853",
        open   = "rbxassetid://1842923308",
        close  = "rbxassetid://1842923308",
        thunder= "rbxassetid://131237241",
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
        task.delay(2, function() pcall(function() s:Destroy() end) end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
--   CONFIG MGR
-- ═══════════════════════════════════════════════════════════════
local ConfigMgr = { File = "aura_ghost_farm.json", Data = {} }
function ConfigMgr:Save(data)
    pcall(function()
        if not writefile then return end
        local d = data or self.Data
        local s = {}
        for k, v in pairs(d) do
            if k ~= "Themes" then
                local tv = type(v)
                if tv == "string" or tv == "number" or tv == "boolean" then s[k] = v end
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

-- ═══════════════════════════════════════════════════════════════
--   HELPERS
-- ═══════════════════════════════════════════════════════════════
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0,10); c.Parent = p; return c
end
local function Stroke(p, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1,1,1)
    s.Thickness = thick or 1
    s.Transparency = transp or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end
local function Tween(o, i, p)
    local t = TweenService:Create(o, i, p); t:Play(); return t
end
local INFO_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_SPRING = TweenInfo.new(0.4,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ═══════════════════════════════════════════════════════════════
--   GHOST PALETTE & CONFIG
-- ═══════════════════════════════════════════════════════════════
local PALETTE = {
    GhostWhite   = Color3.fromRGB(240,245,255),
    Pumpkin      = Color3.fromRGB(255,110,30),
    PumpkinDeep  = Color3.fromRGB(220,80,15),
    Witch        = Color3.fromRGB(160,60,240),
    WitchDeep    = Color3.fromRGB(90,20,150),
    Blood        = Color3.fromRGB(200,25,25),
    Toxic        = Color3.fromRGB(140,255,80),
    Night        = Color3.fromRGB(10,8,20),
    NightLight   = Color3.fromRGB(24,18,42),
    EyeGlow      = Color3.fromRGB(255,200,60),
    EyeGlowRed   = Color3.fromRGB(255,60,60),
}

local Config = {
    IsAutoOn=false, HoldDelay=0.2, MaxDistance=20,
    IsAntiAFK=true, Theme="Halloween",
    Themes = {
        Halloween = { Accent = Color3.fromRGB(255,132,35), Name="Ghost" },
        Pink      = { Accent = Color3.fromRGB(255,105,180), Name="Pink" },
        Purple    = { Accent = Color3.fromRGB(170,0,255),   Name="Purple" },
        Blue      = { Accent = Color3.fromRGB(0,170,255),   Name="Blue" },
        Green     = { Accent = Color3.fromRGB(0,255,150),   Name="Green" },
        Gold      = { Accent = Color3.fromRGB(255,200,0),   Name="Gold" },
        Red       = { Accent = Color3.fromRGB(255,50,50),   Name="Red" },
        Cyan      = { Accent = Color3.fromRGB(0,255,255),   Name="Cyan" },
    },
    ToggleKey = Enum.KeyCode.RightControl,
}

do
    local savedCfg = ConfigMgr:Load()
    if savedCfg and type(savedCfg) == "table" then
        for k, v in pairs(savedCfg) do
            if k ~= "Themes" then
                if Config[k] ~= nil and type(Config[k]) == type(v) then Config[k] = v end
            end
        end
    end
    Config.IsAutoOn=false
    if type(Config.Theme) ~= "string" or not Config.Themes[Config.Theme] then
        Config.Theme = "Halloween"
    end
end

-- ═══════════════════════════════════════════════════════════════
--   CHARACTER OBSERVER
-- ═══════════════════════════════════════════════════════════════
local CharObs = { character=nil, humanoid=nil, root=nil, changed=Signal.new() }
local function bindCharacter(char)
    CharObs.character = char
    CharObs.humanoid = safeWait(char, "Humanoid", 5)
    CharObs.root = safeWait(char, "HumanoidRootPart", 5)
    CharObs.changed:Fire(char, CharObs.humanoid, CharObs.root)
end
if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
ConnMgr.add(LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.5); bindCharacter(c) end))
local function getCharacter() return CharObs.character, CharObs.humanoid, CharObs.root end

-- ═══════════════════════════════════════════════════════════════
--   THEME
-- ═══════════════════════════════════════════════════════════════
local accent = Config.Themes[Config.Theme].Accent
local accentRegistry, gradientRegistry, switchRegistry = {}, {}, {}
local StrokeGrad

local function ApplyTheme(name)
    local t = Config.Themes[name]; if not t then return end
    Config.Theme = name
    if typeof(t.Accent) ~= "Color3" then t.Accent = PALETTE.Pumpkin end
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

-- ═══════════════════════════════════════════════════════════════
--   SCREEN GUI & FULL VISUALS
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Enabled = true
ScreenGui.Parent = GUIParent

local BASE_W, BASE_H = 440, 620
local function calcScale()
    refreshViewport()
    local vp = DEVICE.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return 0.85 end
    local maxW, maxH
    if DEVICE.IsMobile then maxW=0.95; maxH=0.9
    elseif DEVICE.IsTablet then maxW=0.75; maxH=0.88
    else maxW=0.45; maxH=0.92 end
    local sw = (vp.X*maxW)/BASE_W
    local sh = (vp.Y*maxH)/BASE_H
    return math.clamp(math.min(sw, sh), 0.65, 1.20)
end
local UI_SCALE = calcScale()

-- VIGNETTE
local Vignette = Instance.new("Frame")
Vignette.Size = UDim2.new(1,0,1,0)
Vignette.BackgroundColor3 = Color3.new(0,0,0)
Vignette.BackgroundTransparency = 0.78
Vignette.BorderSizePixel = 0
Vignette.ZIndex = 0
Vignette.Parent = ScreenGui
local VigGrad = Instance.new("UIGradient")
VigGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.85),
    NumberSequenceKeypoint.new(0.6, 0.85), NumberSequenceKeypoint.new(1, 0),
})
VigGrad.Rotation = 90
VigGrad.Parent = Vignette

-- LIGHTNING
local Lightning = Instance.new("Frame")
Lightning.Size = UDim2.new(1,0,1,0)
Lightning.BackgroundColor3 = PALETTE.Witch
Lightning.BackgroundTransparency = 1
Lightning.BorderSizePixel = 0
Lightning.ZIndex = 500
Lightning.Parent = ScreenGui

-- FOG
local FogHolder = Instance.new("Frame")
FogHolder.Size = UDim2.new(1,0,1,0)
FogHolder.BackgroundTransparency = 1
FogHolder.ZIndex = 2
FogHolder.Parent = ScreenGui

local fogList = {}
for i = 1, 6 do
    local fog = Instance.new("ImageLabel")
    fog.Size = UDim2.new(0, math.random(200, 340), 0, math.random(90, 150))
    fog.Position = UDim2.new(math.random(), 0, math.random(), 0)
    fog.BackgroundTransparency = 1
    fog.Image = "rbxassetid://5028857084"
    fog.ImageColor3 = (i % 2 == 0) and PALETTE.Witch or PALETTE.Pumpkin
    fog.ImageTransparency = 0.88
    fog.ScaleType = Enum.ScaleType.Slice
    fog.SliceCenter = Rect.new(24,24,276,276)
    fog.ZIndex = 2
    fog.Parent = FogHolder
    table.insert(fogList, { obj=fog, speed=math.random(5,15)/150, seed=math.random()*100 })
end

ConnMgr.spawn(function()
    while FogHolder.Parent do
        local dt = RunService.RenderStepped:Wait()
        for _, f in ipairs(fogList) do
            local newX = f.obj.Position.X.Scale + f.speed * dt
            if newX > 1.2 then newX = -0.2 end
            local newY = f.obj.Position.Y.Scale + math.sin(tick() + f.seed) * 0.0005
            f.obj.Position = UDim2.new(newX, 0, newY, 0)
        end
    end
end)

-- GHOST AURA
local GhostAura = Instance.new("ImageLabel")
GhostAura.Size = UDim2.new(0, BASE_W+140, 0, BASE_H+140)
GhostAura.Position = UDim2.new(0.5, 0, 0.5, 0)
GhostAura.AnchorPoint = Vector2.new(0.5, 0.5)
GhostAura.BackgroundTransparency = 1
GhostAura.Image = "rbxassetid://5028857084"
GhostAura.ImageColor3 = PALETTE.Witch
GhostAura.ImageTransparency = 0.35
GhostAura.ScaleType = Enum.ScaleType.Slice
GhostAura.SliceCenter = Rect.new(24,24,276,276)
GhostAura.ZIndex = 1
GhostAura.Parent = ScreenGui
local AuraScale = Instance.new("UIScale"); AuraScale.Scale = UI_SCALE; AuraScale.Parent = GhostAura

-- MAIN GHOST
local Ghost = Instance.new("Frame")
Ghost.Size = UDim2.new(0, BASE_W, 0, BASE_H)
Ghost.Position = UDim2.new(0.5, 0, 0.5, 0)
Ghost.AnchorPoint = Vector2.new(0.5, 0.5)
Ghost.BackgroundColor3 = PALETTE.Night
Ghost.BackgroundTransparency = 0.02
Ghost.BorderSizePixel = 0
Ghost.Active = true
Ghost.ZIndex = 5
Ghost.Parent = ScreenGui
Corner(Ghost, UDim.new(0, 110))

local MainScale = Instance.new("UIScale"); MainScale.Scale = UI_SCALE; MainScale.Parent = Ghost

local GhostGrad = Instance.new("UIGradient")
GhostGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    PALETTE.NightLight),
    ColorSequenceKeypoint.new(0.35, PALETTE.Night),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(6,4,14)),
})
GhostGrad.Rotation = 90; GhostGrad.Parent = Ghost

local GhostStroke = Stroke(Ghost, PALETTE.Witch, 2.5, 0.15)
StrokeGrad = Instance.new("UIGradient")
StrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   PALETTE.Witch),
    ColorSequenceKeypoint.new(0.3, PALETTE.Pumpkin),
    ColorSequenceKeypoint.new(0.5, PALETTE.GhostWhite),
    ColorSequenceKeypoint.new(0.7, PALETTE.Witch),
    ColorSequenceKeypoint.new(1,   PALETTE.Pumpkin),
})
StrokeGrad.Parent = StrokeGrad
ConnMgr.spawn(function()
    while Ghost.Parent do
        StrokeGrad.Rotation = 0
        Tween(StrokeGrad, TweenInfo.new(6, Enum.EasingStyle.Linear), { Rotation = 360 })
        task.wait(6)
    end
end)

local GhostBgImg = Instance.new("ImageLabel")
GhostBgImg.Size = UDim2.new(1,0,1,0); GhostBgImg.BackgroundTransparency = 1
GhostBgImg.Image = CustomImage ~= "" and CustomImage or IMAGE_FALLBACKS[1]
GhostBgImg.ImageTransparency = 0.92; GhostBgImg.ScaleType = Enum.ScaleType.Crop
GhostBgImg.ZIndex = 3; GhostBgImg.Parent = Ghost
Corner(GhostBgImg, UDim.new(0, 110)); registerImage(GhostBgImg)

-- WAVY BOTTOM
local WaveHolder = Instance.new("Frame")
WaveHolder.Size = UDim2.new(1,0,0,50); WaveHolder.Position = UDim2.new(0,0,1,-25)
WaveHolder.BackgroundTransparency = 1; WaveHolder.ZIndex = 4; WaveHolder.Parent = Ghost
for i = 0, 2 do
    local wave = Instance.new("Frame")
    wave.Size = UDim2.new(0.34, 0, 0, 50); wave.Position = UDim2.new(i * 0.33, 0, 0, 0)
    wave.BackgroundColor3 = PALETTE.Night; wave.BackgroundTransparency = 0.02
    wave.BorderSizePixel = 0; wave.ZIndex = 4; wave.Parent = WaveHolder
    Corner(wave, UDim.new(1, 0))
end

-- FACE
local FaceHolder = Instance.new("Frame")
FaceHolder.Size = UDim2.new(1, 0, 0, 100); FaceHolder.Position = UDim2.new(0, 0, 0, 14)
FaceHolder.BackgroundTransparency = 1; FaceHolder.ZIndex = 6; FaceHolder.Parent = Ghost

local EyeL = Instance.new("Frame")
EyeL.Size = UDim2.new(0, 30, 0, 38); EyeL.Position = UDim2.new(0.5, -78, 0, 26)
EyeL.BackgroundColor3 = PALETTE.EyeGlow; EyeL.BorderSizePixel = 0; EyeL.ZIndex = 7; EyeL.Parent = FaceHolder
Corner(EyeL, UDim.new(1, 0))
local EyeLGlow = Instance.new("ImageLabel")
EyeLGlow.Size = UDim2.new(1, 70, 1, 70); EyeLGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
EyeLGlow.AnchorPoint = Vector2.new(0.5, 0.5); EyeLGlow.BackgroundTransparency = 1
EyeLGlow.Image = "rbxassetid://5028857084"; EyeLGlow.ImageColor3 = PALETTE.EyeGlow
EyeLGlow.ImageTransparency = 0.25; EyeLGlow.ScaleType = Enum.ScaleType.Slice
EyeLGlow.SliceCenter = Rect.new(24,24,276,276); EyeLGlow.ZIndex = 6; EyeLGlow.Parent = EyeL

local EyeR = EyeL:Clone(); EyeR.Position = UDim2.new(0.5, 48, 0, 26); EyeR.Parent = FaceHolder

local Mouth = Instance.new("Frame")
Mouth.Size = UDim2.new(0, 70, 0, 28); Mouth.Position = UDim2.new(0.5, -35, 0, 74)
Mouth.BackgroundColor3 = PALETTE.Night; Mouth.BorderSizePixel = 0; Mouth.ZIndex = 7; Mouth.Parent = FaceHolder
Corner(Mouth, UDim.new(0, 14))
local MouthStroke = Stroke(Mouth, PALETTE.EyeGlow, 2, 0.3)

-- TITLE
local TitleBadge = Instance.new("TextLabel")
TitleBadge.Size = UDim2.new(0, 300, 0, 36); TitleBadge.Position = UDim2.new(0.5, -150, 0, 122)
TitleBadge.BackgroundColor3 = PALETTE.WitchDeep; TitleBadge.BackgroundTransparency = 0.25
TitleBadge.Text = "👻  EGG FARM AUTO  👻"
TitleBadge.TextColor3 = PALETTE.GhostWhite; TitleBadge.Font = Enum.Font.GothamBlack
TitleBadge.TextSize = 16; TitleBadge.BorderSizePixel = 0; TitleBadge.ZIndex = 7; TitleBadge.Parent = Ghost
Corner(TitleBadge, UDim.new(1, 0)); Stroke(TitleBadge, PALETTE.Pumpkin, 1.5, 0.25)

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 340, 0, 16); Subtitle.Position = UDim2.new(0.5, -170, 0, 162)
Subtitle.BackgroundTransparency = 1; Subtitle.Text = "by ouncopybara  •  " .. Config.Themes[Config.Theme].Name
Subtitle.TextColor3 = PALETTE.Pumpkin; Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextSize = 10; Subtitle.ZIndex = 7; Subtitle.Parent = Ghost; Subtitle.TextStrokeTransparency = 0.4

local PerfLabel = Instance.new("TextLabel")
PerfLabel.Size = UDim2.new(0, 200, 0, 14); PerfLabel.Position = UDim2.new(0.5, -100, 0, 180)
PerfLabel.BackgroundTransparency = 1; PerfLabel.Font = Enum.Font.Code; PerfLabel.TextSize = 9
PerfLabel.TextColor3 = Color3.fromRGB(150,140,180); PerfLabel.ZIndex = 7; PerfLabel.Parent = Ghost
ConnMgr.spawn(function()
    while PerfLabel.Parent do
        PerfLabel.Text = string.format("FPS:%d  MEM:%d  PING:%d", Perf.fps, Perf.memory, Perf.ping)
        task.wait(1)
    end
end)

-- WINDOW BUTTONS
local function GhostButton(text, xOff, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 34, 0, 34); b.Position = UDim2.new(1, xOff, 0, 20)
    b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = PALETTE.GhostWhite
    b.Font = Enum.Font.GothamBlack; b.TextSize = 15; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.ZIndex = 20; b.Parent = Ghost; Corner(b, UDim.new(1, 0))
    local st = Stroke(b, PALETTE.GhostWhite, 1.2, 0.4)
    b.MouseEnter:Connect(function() Tween(b, INFO_FAST, { Size = UDim2.new(0, 38, 0, 38) }); Tween(st, INFO_FAST, { Color = PALETTE.Pumpkin }) end)
    b.MouseLeave:Connect(function() Tween(b, INFO_FAST, { Size = UDim2.new(0, 34, 0, 34) }); Tween(st, INFO_FAST, { Color = PALETTE.GhostWhite }) end)
    return b
end
local CloseBtn = GhostButton("✕", -46, PALETTE.Blood)
local MinBtn   = GhostButton("–", -88, PALETTE.WitchDeep)

-- ANIMATIONS
ConnMgr.spawn(function()
    while Ghost.Parent do
        local t = tick()
        local dx = math.sin(t * 1.4) * 3
        local dy = math.sin(t * 1.8 + 0.5) * 8
        Ghost.Position = UDim2.new(0.5, dx, 0.5, dy)
        GhostAura.Position = UDim2.new(0.5, dx, 0.5, dy)
        RunService.RenderStepped:Wait()
    end
end)

ConnMgr.spawn(function()
    while Ghost.Parent do
        task.wait(math.random(30, 60) / 10)
        Tween(EyeL, TweenInfo.new(0.05), { Size = UDim2.new(0, 30, 0, 3) })
        Tween(EyeR, TweenInfo.new(0.05), { Size = UDim2.new(0, 30, 0, 3) })
        task.wait(0.1)
        Tween(EyeL, TweenInfo.new(0.15), { Size = UDim2.new(0, 30, 0, 38) })
        Tween(EyeR, TweenInfo.new(0.15), { Size = UDim2.new(0, 30, 0, 38) })
    end
end)

ConnMgr.spawn(function()
    while Ghost.Parent do
        Tween(EyeL, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundColor3 = PALETTE.EyeGlowRed })
        Tween(EyeR, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundColor3 = PALETTE.EyeGlowRed })
        task.wait(6)
    end
end)

ConnMgr.spawn(function()
    while Ghost.Parent do
        MouthStroke.Transparency = 0.2
        Tween(MouthStroke, TweenInfo.new(0.7), { Transparency = 0.85 })
        task.wait(0.8)
        Tween(MouthStroke, TweenInfo.new(0.7), { Transparency = 0.2 })
        task.wait(0.8)
    end
end)

ConnMgr.spawn(function()
    while Ghost.Parent do
        task.wait(math.random(10, 25))
        Lightning.BackgroundTransparency = 0.85
        Tween(Lightning, TweenInfo.new(0.08), { BackgroundTransparency = 1 })
        Audio:Play("thunder", 0.12)
        task.wait(0.15)
        Lightning.BackgroundTransparency = 0.9
        Tween(Lightning, TweenInfo.new(0.06), { BackgroundTransparency = 1 })
    end
end)

-- ORBS
local orbHolder = Instance.new("Frame")
orbHolder.Size = UDim2.new(1, 0, 1, 0); orbHolder.BackgroundTransparency = 1; orbHolder.ZIndex = 3; orbHolder.Parent = Ghost
for i = 1, 5 do
    local orb = Instance.new("Frame")
    orb.Size = UDim2.new(0, 9, 0, 9); orb.BackgroundColor3 = (i % 2 == 0) and PALETTE.Pumpkin or PALETTE.Witch
    orb.BorderSizePixel = 0; orb.ZIndex = 3; orb.Parent = orbHolder; Corner(orb, UDim.new(1, 0))
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 50, 1, 50); glow.Position = UDim2.new(0.5, 0, 0.5, 0); glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1; glow.Image = "rbxassetid://5028857084"; glow.ImageColor3 = orb.BackgroundColor3
    glow.ImageTransparency = 0.4; glow.ScaleType = Enum.ScaleType.Slice; glow.SliceCenter = Rect.new(24,24,276,276); glow.ZIndex = 2; glow.Parent = orb
    ConnMgr.spawn(function()
        local angle = (i / 5) * math.pi * 2
        while Ghost.Parent do
            local dt = RunService.RenderStepped:Wait()
            angle = angle + dt * 0.7
            local r = 260
            local cx = math.cos(angle) * r
            local cy = math.sin(angle) * (r * 0.75)
            orb.Position = UDim2.new(0.5, cx, 0.5, cy)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--   NOTIFICATIONS 
-- ═══════════════════════════════════════════════════════════════
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 280, 1, -20); NotifHolder.Position = UDim2.new(1, -290, 0, 10)
NotifHolder.BackgroundTransparency = 1; NotifHolder.ZIndex = 200; NotifHolder.Parent = ScreenGui
local NotifScale = Instance.new("UIScale"); NotifScale.Scale = 0.9; NotifScale.Parent = NotifHolder
local notifQueue, activeNotifs, MAX_NOTIFS = {}, 0, 5

local function renderNotif(data)
    if not data then return end
    activeNotifs = activeNotifs + 1
    local col = (typeof(data.color) == "Color3") and data.color or accent
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1,0,0,72); n.Position = UDim2.new(1,20,0,(activeNotifs-1)*80)
    n.BackgroundColor3 = PALETTE.Night; n.BackgroundTransparency = 0.08
    n.BorderSizePixel = 0; n.ZIndex = 201; n.Parent = NotifHolder
    Corner(n, UDim.new(0,12)); Stroke(n, col, 1.2, 0.4)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,-16); bar.Position = UDim2.new(0,6,0,8)
    bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; bar.Parent = n; Corner(bar, UDim.new(1,0))
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0,28,0,28); iconLbl.Position = UDim2.new(0,18,0.5,-14)
    iconLbl.BackgroundColor3 = col; iconLbl.BackgroundTransparency = 0.7
    iconLbl.Text = data.icon or "👻"; iconLbl.TextColor3 = col
    iconLbl.Font = Enum.Font.GothamBold; iconLbl.TextSize = 16; iconLbl.ZIndex = 202; iconLbl.Parent = n; Corner(iconLbl, UDim.new(1,0))
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,18); ttl.Position = UDim2.new(0,54,0,12)
    ttl.BackgroundTransparency = 1; ttl.Text = data.title or ""; ttl.TextColor3 = col
    ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 12; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 202; ttl.Parent = n
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1,-70,0,30); msgLbl.Position = UDim2.new(0,54,0,32)
    msgLbl.BackgroundTransparency = 1; msgLbl.Text = data.msg or ""; msgLbl.TextColor3 = PALETTE.GhostWhite
    msgLbl.Font = Enum.Font.Gotham; msgLbl.TextSize = 10; msgLbl.TextWrapped = true; msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top; msgLbl.ZIndex = 202; msgLbl.Parent = n
    local prog = Instance.new("Frame")
    prog.Size = UDim2.new(1,-18,0,2); prog.Position = UDim2.new(0,12,1,-7)
    prog.BackgroundColor3 = col; prog.BackgroundTransparency = 0.4; prog.BorderSizePixel = 0; prog.ZIndex = 202; prog.Parent = n; Corner(prog, UDim.new(1,0))
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
    if activeNotifs >= MAX_NOTIFS then table.insert(notifQueue, data) else renderNotif(data) end
end

-- ═══════════════════════════════════════════════════════════════
--   AUTO FARM SYSTEM (NO TP)
-- ═══════════════════════════════════════════════════════════════
local updateStatus = function() end

local function triggerPromptsAndClicks()
    pcall(function()
        local _, _, hrp = getCharacter(); if not hrp then return end
        local pos = hrp.Position
        for prompt in pairs(WSCache.prompts) do
            if prompt.Parent and prompt.Enabled then
                local part = prompt.Parent
                if part:IsA("BasePart") then
                    local d = (pos - part.Position).Magnitude
                    if d <= (Config.MaxDistance or 20) then
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
                    if d <= (Config.MaxDistance or 20) then
                        pcall(fireclickdetector, cd)
                    end
                end
            end
        end
    end)
end

ConnMgr.spawn(function()
    while task.wait(0.2) do
        if Config.IsAutoOn then
            triggerPromptsAndClicks()
        end
    end
end)

ConnMgr.add(LocalPlayer.Idled:Connect(function()
    if Config.IsAntiAFK then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController(); vu:ClickButton2(Vector2.new())
        end)
    end
end))

-- ═══════════════════════════════════════════════════════════════
--   UI TABS & COMPONENTS
-- ═══════════════════════════════════════════════════════════════
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -44, 1, -240); Content.Position = UDim2.new(0, 22, 0, 200)
Content.BackgroundColor3 = PALETTE.Night; Content.BackgroundTransparency = 0.4
Content.BorderSizePixel = 0; Content.ClipsDescendants = true; Content.ZIndex = 6; Content.Parent = Ghost
Corner(Content, UDim.new(0, 22)); Stroke(Content, PALETTE.Witch, 1, 0.55)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 84, 1, -20); Sidebar.Position = UDim2.new(0, 8, 0, 10)
Sidebar.BackgroundTransparency = 1; Sidebar.ZIndex = 7; Sidebar.Parent = Content
local SideLayout = Instance.new("UIListLayout"); SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Parent = Sidebar
local SidePad = Instance.new("UIPadding"); SidePad.PaddingTop = UDim.new(0, 4); SidePad.Parent = Sidebar

local PageHost = Instance.new("Frame")
PageHost.Size = UDim2.new(1, -92, 1, -8); PageHost.Position = UDim2.new(0, 92, 0, 4)
PageHost.BackgroundTransparency = 1; PageHost.ZIndex = 7; PageHost.Parent = Content

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -80, 0, 30); StatusBar.Position = UDim2.new(0.5, -((BASE_W-80)/2), 1, -78)
StatusBar.BackgroundColor3 = PALETTE.WitchDeep; StatusBar.BackgroundTransparency = 0.4
StatusBar.BorderSizePixel = 0; StatusBar.ZIndex = 6; StatusBar.Parent = Ghost
Corner(StatusBar, UDim.new(1, 0)); Stroke(StatusBar, PALETTE.Pumpkin, 1, 0.4)
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8); StatusDot.Position = UDim2.new(0, 14, 0.5, -4)
StatusDot.BackgroundColor3 = PALETTE.Pumpkin; StatusDot.BorderSizePixel = 0; StatusDot.ZIndex = 7; StatusDot.Parent = StatusBar; Corner(StatusDot, UDim.new(1, 0))
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -34, 1, 0); StatusText.Position = UDim2.new(0, 30, 0, 0)
StatusText.BackgroundTransparency = 1; StatusText.Text = "System ready"; StatusText.TextColor3 = PALETTE.GhostWhite
StatusText.Font = Enum.Font.GothamBold; StatusText.TextSize = 11; StatusText.TextXAlignment = Enum.TextXAlignment.Left; StatusText.TextTruncate = Enum.TextTruncate.AtEnd; StatusText.ZIndex = 7; StatusText.Parent = StatusBar

updateStatus = function(txt, col)
    StatusText.Text = txt
    if col and typeof(col) == "Color3" then StatusDot.BackgroundColor3 = col end
end

local function PlayClickEffect(btn)
    pcall(function()
        local r = Instance.new("Frame")
        r.Size = UDim2.new(0,0,0,0); r.Position = UDim2.new(0.5,0,0.5,0); r.AnchorPoint = Vector2.new(0.5,0.5)
        r.BackgroundColor3 = PALETTE.GhostWhite; r.BackgroundTransparency = 0.4; r.BorderSizePixel = 0; r.ZIndex = 30; r.Parent = btn
        Corner(r, UDim.new(1,0))
        Tween(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0,500,0,500), BackgroundTransparency = 1 })
        task.delay(0.55, function() pcall(function() r:Destroy() end) end)
    end)
end

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
    tab.Label.TextColor3 = PALETTE.GhostWhite
end

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-8,0,44); btn.BackgroundColor3 = accent; btn.BackgroundTransparency = 1
    btn.Text = ""; btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.ClipsDescendants = true
    btn.LayoutOrder = #tabs + 1; btn.ZIndex = 8; btn.Parent = Sidebar; Corner(btn, UDim.new(0,10))
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0,3,0,0); indicator.Position = UDim2.new(0,2,0.5,0); indicator.AnchorPoint = Vector2.new(0,0.5)
    indicator.BackgroundColor3 = PALETTE.Pumpkin; indicator.BorderSizePixel = 0; indicator.ZIndex = 9; indicator.Parent = btn; Corner(indicator, UDim.new(1,0))
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(1,0,0,18); ic.Position = UDim2.new(0,0,0,6)
    ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 14; ic.ZIndex = 9; ic.Parent = btn
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,14); lbl.Position = UDim2.new(0,0,0,24)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
    lbl.TextColor3 = Color3.fromRGB(140,140,150); lbl.ZIndex = 9; lbl.Parent = btn
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.Visible = false
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = PALETTE.Pumpkin; page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0,0,0,0); page.ScrollingDirection = Enum.ScrollingDirection.Y; page.ScrollBarImageTransparency = 0.5
    page.ZIndex = 8; page.Parent = PageHost
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0,8); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = page
    local pp = Instance.new("UIPadding"); pp.PaddingRight = UDim.new(0,10); pp.PaddingBottom = UDim.new(0,10); pp.Parent = page

    local tab = { Button=btn, Indicator=indicator, Label=lbl, Page=page, Active=false }
    table.insert(tabs, tab)
    btn.MouseEnter:Connect(function() if not tab.Active then Tween(btn, INFO_FAST, { BackgroundTransparency = 0.93 }) end end)
    btn.MouseLeave:Connect(function() if not tab.Active then Tween(btn, INFO_FAST, { BackgroundTransparency = 1 }) end end)
    btn.MouseButton1Click:Connect(function() SelectTab(tab); Audio:Play("click", 0.15); PlayClickEffect(btn) end)
    return page
end

local function AddSection(page, text, order)
    local l = Instance.new("TextLabel"); l.LayoutOrder = order; l.Size = UDim2.new(1,4,0,20)
    l.BackgroundTransparency = 1; l.Text = "🎃 " .. string.upper(text); l.TextColor3 = PALETTE.Pumpkin; l.Font = Enum.Font.GothamBlack; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 8; l.Parent = page; l.TextStrokeTransparency = 0.4
end

local function AddToggle(page, title, desc, default, order, callback)
    local row = Instance.new("TextButton")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0, desc and 52 or 44)
    row.BackgroundColor3 = PALETTE.NightLight; row.BackgroundTransparency = 0.35; row.Text = ""; row.BorderSizePixel = 0
    row.AutoButtonColor = false; row.ClipsDescendants = true; row.ZIndex = 8; row.Parent = page; Corner(row, UDim.new(0,12)); Stroke(row, PALETTE.Witch, 1, 0.6)
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,16); ttl.Position = desc and UDim2.new(0,12,0,9) or UDim2.new(0,12,0.5,-8)
    ttl.BackgroundTransparency = 1; ttl.Text = title; ttl.TextColor3 = PALETTE.GhostWhite; ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.TextTruncate = Enum.TextTruncate.AtEnd; ttl.ZIndex = 9; ttl.Parent = row
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,-70,0,13); d.Position = UDim2.new(0,12,0,26); d.BackgroundTransparency = 1; d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,140,180); d.Font = Enum.Font.Gotham; d.TextSize = 9; d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextTruncate = Enum.TextTruncate.AtEnd; d.ZIndex = 9; d.Parent = row
    end
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,22); sw.Position = UDim2.new(1,-52,0.5,-11); sw.BackgroundColor3 = Color3.fromRGB(40,35,55)
    sw.BorderSizePixel = 0; sw.ZIndex = 9; sw.Parent = row; Corner(sw, UDim.new(1,0)); Stroke(sw, PALETTE.Witch, 1, 0.4)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,3,0.5,-8); knob.BackgroundColor3 = PALETTE.GhostWhite
    knob.BorderSizePixel = 0; knob.ZIndex = 10; knob.Parent = sw; Corner(knob, UDim.new(1,0))

    local isOn = default and true or false
    local function refresh()
        if isOn then
            sw.BackgroundColor3 = PALETTE.Pumpkin; Tween(knob, INFO_SPRING, { Position = UDim2.new(1,-19,0.5,-8) }); Tween(row, INFO_FAST, { BackgroundTransparency = 0.1 })
        else
            sw.BackgroundColor3 = Color3.fromRGB(40,35,55); Tween(knob, INFO_SPRING, { Position = UDim2.new(0,3,0.5,-8) }); Tween(row, INFO_FAST, { BackgroundTransparency = 0.35 })
        end
    end
    if isOn then refresh() end
    table.insert(switchRegistry, { frame = sw, get = function() return isOn end })

    row.MouseButton1Click:Connect(function()
        isOn = not isOn; refresh(); Audio:Play("toggle", 0.2); PlayClickEffect(sw)
        if callback then pcall(callback, isOn) end
    end)
    return { Set = function(v) isOn = v and true or false; refresh() end }
end

local function AddSlider(page, title, min, max, default, decimals, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,56); row.BackgroundColor3 = PALETTE.NightLight
    row.BackgroundTransparency = 0.35; row.BorderSizePixel = 0; row.ZIndex = 8; row.Parent = page
    Corner(row, UDim.new(0,12)); Stroke(row, PALETTE.Witch, 1, 0.6)
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-70,0,16); ttl.Position = UDim2.new(0,12,0,9); ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = PALETTE.GhostWhite; ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 9; ttl.Parent = row
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0,50,0,16); valLbl.Position = UDim2.new(1,-58,0,9); valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default)
    valLbl.TextColor3 = PALETTE.Pumpkin; valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 11; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 9; valLbl.Parent = row
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-24,0,6); bar.Position = UDim2.new(0,12,1,-18); bar.BackgroundColor3 = Color3.fromRGB(35,30,50); bar.BorderSizePixel = 0; bar.ZIndex = 9; bar.Parent = row; Corner(bar, UDim.new(1,0))
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = PALETTE.Pumpkin; fill.BorderSizePixel = 0; fill.ZIndex = 10; fill.Parent = bar; Corner(fill, UDim.new(1,0))
    local fg = Instance.new("UIGradient")
    fg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PALETTE.Witch), ColorSequenceKeypoint.new(1, PALETTE.Pumpkin)}); fg.Parent = fill
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0,20,0,20); knob.Position = UDim2.new((default-min)/(max-min),-10,0.5,-10)
    knob.BackgroundColor3 = PALETTE.GhostWhite; knob.Text = ""; knob.BorderSizePixel = 0; knob.AutoButtonColor = false; knob.ZIndex = 11; knob.Parent = bar; Corner(knob, UDim.new(1,0)); Stroke(knob, PALETTE.Pumpkin, 2)

    local dragging = false; local mult = 10 ^ (decimals or 0)
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max-min)*rel) * mult + 0.5) / mult
        fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,-10,0.5,-10); valLbl.Text = tostring(val)
        if callback then pcall(callback, val) end
    end
    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input) end end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end))
    ConnMgr.add(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
end

local function AddButton(page, title, order, callback)
    local b = Instance.new("TextButton")
    b.LayoutOrder = order; b.Size = UDim2.new(1,0,0,42); b.BackgroundColor3 = PALETTE.WitchDeep; b.Text = title; b.TextColor3 = PALETTE.GhostWhite
    b.Font = Enum.Font.GothamBlack; b.TextSize = 12; b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ClipsDescendants = true; b.ZIndex = 8; b.Parent = page; Corner(b, UDim.new(0,12))
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PALETTE.Witch), ColorSequenceKeypoint.new(0.5, PALETTE.WitchDeep), ColorSequenceKeypoint.new(1, PALETTE.PumpkinDeep)})
    grad.Rotation = 30; grad.Parent = b; Stroke(b, PALETTE.Pumpkin, 1.5, 0.3)
    local scale = Instance.new("UIScale"); scale.Parent = b
    b.MouseEnter:Connect(function() Tween(scale, INFO_FAST, { Scale = 1.03 }) end)
    b.MouseLeave:Connect(function() Tween(scale, INFO_FAST, { Scale = 1 }) end)
    b.MouseButton1Down:Connect(function() Tween(scale, INFO_FAST, { Scale = 0.96 }); PlayClickEffect(b) end)
    b.MouseButton1Up:Connect(function() Tween(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.03 }) end)
    b.MouseButton1Click:Connect(function() Audio:Play("click", 0.2); pcall(callback) end)
    return b
end

local function AddThemePicker(page, order)
    local row = Instance.new("Frame")
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,52); row.BackgroundColor3 = PALETTE.NightLight
    row.BackgroundTransparency = 0.35; row.BorderSizePixel = 0; row.ZIndex = 8; row.Parent = page; Corner(row, UDim.new(0,12)); Stroke(row, PALETTE.Witch, 1, 0.6)
    local names = { "Halloween","Pink","Purple","Blue","Green","Gold","Red","Cyan" }
    for i, name in ipairs(names) do
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.new(0,26,0,26); dot.Position = UDim2.new(0, 12 + (i-1)*32, 0.5, -13)
        dot.BackgroundColor3 = Config.Themes[name].Accent; dot.Text = ""; dot.BorderSizePixel = 0; dot.AutoButtonColor = false; dot.ClipsDescendants = true; dot.ZIndex = 9; dot.Parent = row; Corner(dot, UDim.new(1,0))
        local st = Stroke(dot, PALETTE.GhostWhite, 2, 0.7)
        if name == Config.Theme then st.Transparency = 0 end
        dot.MouseButton1Click:Connect(function()
            ApplyTheme(name); PlayClickEffect(dot)
            Subtitle.Text = "by ouncopybara  •  " .. Config.Themes[name].Name
            for _, c in ipairs(row:GetChildren()) do
                if c:IsA("TextButton") then
                    local s2 = c:FindFirstChildOfClass("UIStroke")
                    if s2 then s2.Transparency = 0.7 end
                end
            end
            st.Transparency = 0
            Notify("Theme", "Changed to " .. Config.Themes[name].Name, Config.Themes[name].Accent, "🎨")
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
--   PAGES (AUTO FARM & SETTINGS ONLY)
-- ═══════════════════════════════════════════════════════════════
local farmPage = CreateTab("Farm", "🎃")
AddSection(farmPage, "Egg Auto Farm", 1)
AddToggle(farmPage, "Auto Collect Eggs", "Auto trigger prompts/clicks", false, 2, function(s)
    Config.IsAutoOn = s
    updateStatus(s and "Auto Farm: ON" or "Auto Farm: OFF", s and PALETTE.Toxic or PALETTE.Pumpkin)
end)
AddSlider(farmPage, "Max Distance", 5, 50, 20, 0, 3, function(v) Config.MaxDistance = v end)

local setPage = CreateTab("Set", "⚙️")
AddSection(setPage, "General", 1)
AddToggle(setPage, "Anti AFK", "Prevent idle kick", true, 2, function(s) Config.IsAntiAFK = s end)
AddToggle(setPage, "Sound", "UI sounds on/off", true, 3, function(s) Audio.Enabled = s end)
AddSection(setPage, "Theme", 4)
AddThemePicker(setPage, 5)
AddSection(setPage, "Data", 6)

local kbInfo = Instance.new("TextLabel")
kbInfo.LayoutOrder = 7; kbInfo.Size = UDim2.new(1,0,0,25); kbInfo.BackgroundTransparency = 1
kbInfo.Text = "RCtrl - Minimize UI"; kbInfo.TextColor3 = PALETTE.GhostWhite; kbInfo.Font = Enum.Font.Code; kbInfo.TextSize = 10; kbInfo.TextXAlignment = Enum.TextXAlignment.Left; kbInfo.TextYAlignment = Enum.TextYAlignment.Top; kbInfo.ZIndex = 8; kbInfo.Parent = setPage

AddButton(setPage, "Save Config", 8, function()
    ConfigMgr:Save(Config)
    Notify("Config", "Saved!", PALETTE.Pumpkin, "💾")
end)

local function CleanupAll()
    pcall(function()
        Config.IsAutoOn = false
        ConnMgr.purge()
    end)
end

AddButton(setPage, "Close UI", 9, function()
    Audio:Play("close", 0.3)
    CleanupAll(); ScreenGui:Destroy()
end)

if DEVICE.IsMobile then
    Sidebar.Size = UDim2.new(0,76,1,-20); PageHost.Size = UDim2.new(1,-84,1,-8); PageHost.Position = UDim2.new(0,84,0,4)
    SideLayout.Padding = UDim.new(0,5); SidePad.PaddingTop = UDim.new(0,4); NotifScale.Scale = math.clamp(UI_SCALE*0.95, 0.7, 0.9)
    NotifHolder.Size = UDim2.new(0,240,1,-20); NotifHolder.Position = UDim2.new(1,-250,0,10)
end

SelectTab(tabs[1])

-- ═══════════════════════════════════════════════════════════════
--   REOPEN BUTTON & DRAG
-- ═══════════════════════════════════════════════════════════════
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Size = UDim2.new(0,60,0,60); ReopenBtn.Position = UDim2.new(0,16,0.5,0); ReopenBtn.AnchorPoint = Vector2.new(0,0.5)
ReopenBtn.BackgroundColor3 = PALETTE.Night; ReopenBtn.Text = "👻"; ReopenBtn.Visible = false
ReopenBtn.TextColor3 = PALETTE.Pumpkin; ReopenBtn.Font = Enum.Font.GothamBlack; ReopenBtn.TextSize = 28; ReopenBtn.BorderSizePixel = 0; ReopenBtn.AutoButtonColor = false; ReopenBtn.ZIndex = 100; ReopenBtn.Parent = ScreenGui; Corner(ReopenBtn, UDim.new(1,0))
local ReopenScale = Instance.new("UIScale"); ReopenScale.Scale = math.clamp(UI_SCALE+0.2, 0.75, 1.15); ReopenScale.Parent = ReopenBtn

local roStroke = Stroke(ReopenBtn, PALETTE.Pumpkin, 2, 0.2)
local roImg = Instance.new("ImageLabel")
roImg.Size = UDim2.new(1,0,1,0); roImg.BackgroundTransparency = 1; roImg.Image = CustomImage ~= "" and CustomImage or IMAGE_FALLBACKS[2]
roImg.ImageTransparency = 0.5; roImg.ScaleType = Enum.ScaleType.Crop; roImg.ZIndex = 99; roImg.Parent = ReopenBtn; Corner(roImg, UDim.new(1,0)); registerImage(roImg)

local minimized = false
local function SetMinimized(state)
    minimized = state
    if state then
        ReopenBtn.Visible = true; ReopenBtn.Size = UDim2.new(0,0,0,0)
        Tween(ReopenBtn, INFO_SPRING, { Size = UDim2.new(0,60,0,60) })
        Tween(MainScale, INFO_FAST, { Scale = UI_SCALE * 0.85 })
        Ghost.Visible = false; GhostAura.Visible = false; Vignette.Visible = false; FogHolder.Visible = false; Lightning.Visible = false
    else
        Ghost.Visible = true; GhostAura.Visible = true; Vignette.Visible = true; FogHolder.Visible = true; Lightning.Visible = true
        Tween(MainScale, INFO_SPRING, { Scale = UI_SCALE })
        ReopenBtn.Visible = false
    end
end

MinBtn.MouseButton1Click:Connect(function() PlayClickEffect(MinBtn); task.wait(0.1); SetMinimized(true) end)
CloseBtn.MouseButton1Click:Connect(function() PlayClickEffect(CloseBtn); task.wait(0.15); Audio:Play("close", 0.3); CleanupAll(); ScreenGui:Destroy() end)

do
    local dragging, moved = false, false
    local startInput, startPos
    ReopenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false; startInput = input.Position; startPos = ReopenBtn.Position
        end
    end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
            ReopenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end))
    ReopenBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    ReopenBtn.MouseButton1Click:Connect(function()
        if not moved then PlayClickEffect(ReopenBtn); task.wait(0.15); SetMinimized(false) end
    end)
end

do
    local dragging = false
    local startInput, ghostStart
    local function overButton()
        local mp = UserInputService:GetMouseLocation()
        for _, b in ipairs({CloseBtn, MinBtn}) do
            local ap, as = b.AbsolutePosition, b.AbsoluteSize
            if mp.X >= ap.X and mp.X <= ap.X+as.X and mp.Y >= ap.Y and mp.Y <= ap.Y+as.Y then return true end
        end
        return false
    end
    Ghost.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if overButton() then return end
            dragging = true; startInput = input.Position; ghostStart = Ghost.Position
        end
    end)
    ConnMgr.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            local newPos = UDim2.new(ghostStart.X.Scale, ghostStart.X.Offset+d.X, ghostStart.Y.Scale, ghostStart.Y.Offset+d.Y)
            Ghost.Position = newPos; GhostAura.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end))
    ConnMgr.add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end)

ConnMgr.add(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then SetMinimized(not minimized) end
end))

-- ═══════════════════════════════════════════════════════════════
--   INIT
-- ═══════════════════════════════════════════════════════════════
Audio:Play("open", 0.25)
Tween(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = UI_SCALE })
task.delay(0.3, function()
    Notify("by ouncopybara", "EGG FARM ONLY loaded!", PALETTE.Toxic, "👻")
end)
updateStatus("👻 Farm ready", PALETTE.Toxic)
print("[GhostUI] Egg Farm Only Edition loaded")
