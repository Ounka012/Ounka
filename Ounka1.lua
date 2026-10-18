-- ============================================================
--   👻 GHOST MODE v13.0 | ULTIMATE PREMIUM EDITION
--   by ouncopybara
--   ✅ TELEPORT GRAB 100% (គ្រប់ទីកន្លែង ភ្លាមៗ គ្មានខាត)
--   ✅ Force Grab (Touch + Prompt + ClickDetector)
--   ✅ Escape 100m + Orbit Patrol
--   ✅ Server Spawn Explorer (Auto Detect)
--   ✅ Noclip 100% (ធ្លុះជញ្ជាំង)
--   ✅ Anti-AFK
--   ✅ No Sound • No Fog/Lightning/Float
--   👀 Eye Blink + Glow Pulse (ALWAYS ON)
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.4)

-- ═══════════════════════════════════════════════════════════════
--   GLOBAL CONFIG
-- ═══════════════════════════════════════════════════════════════
local DISABLE_SOUNDS     = true
local DISABLE_ANIMATIONS = true

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local Camera = workspace.CurrentCamera
if not Camera then
    repeat task.wait(0.1) until workspace.CurrentCamera
    Camera = workspace.CurrentCamera
end

local GUIParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    for _, g in ipairs(GUIParent:GetChildren()) do
        if g.Name == "GhostUI" then g:Destroy() end
    end
end)

-- ═══════════════════════════════════════════════════════════════
--   DEVICE & PERF
-- ═══════════════════════════════════════════════════════════════
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

local Perf = { fps=60, memory=0, frames=0, lastCheck=tick(), ping=0 }
RunService.RenderStepped:Connect(function()
    Perf.frames += 1
    local now = tick()
    if now - Perf.lastCheck >= 1 then
        Perf.fps = Perf.frames; Perf.frames = 0; Perf.lastCheck = now
        pcall(function() Perf.memory = math.floor(collectgarbage("count") or 0) end)
        pcall(function() Perf.ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
--   CONN MGR + SIGNAL
-- ═══════════════════════════════════════════════════════════════
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
--   PREMIUM IMAGE SYSTEM
-- ═══════════════════════════════════════════════════════════════
local CustomImage = ""
local ImageReady = Signal.new()
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local IMAGE_FALLBACKS = {
    "rbxassetid://13110332857",
    "rbxassetid://14257626628",
    "rbxassetid://6031075931",
}

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
    if cached then CustomImage = cached; ImageReady:Fire(CustomImage); return CustomImage end
    local ok, data = pcall(function() return game:HttpGet(IMAGE_URL, true) end)
    if ok and data and #data > 5000 then
        local b = data:sub(1,1)
        if b == "\255" or b == "\137" then
            pcall(writefile, fname, data)
            local url = tryGetCustomAsset(fname)
            if url then CustomImage = url; ImageReady:Fire(CustomImage); return CustomImage end
        end
    end
    CustomImage = IMAGE_FALLBACKS[1]
    ImageReady:Fire(CustomImage)
    return CustomImage
end

local function registerImage(label)
    if not label then return end
    if CustomImage ~= "" then pcall(function() label.Image = CustomImage end) end
    ImageReady:Connect(function(url) pcall(function() if label.Parent then label.Image = url end end) end)
end
loadImageSync()

-- ═══════════════════════════════════════════════════════════════
--   HELPERS
-- ═══════════════════════════════════════════════════════════════
local function Corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0,10); c.Parent = p; return c end
local function Stroke(p, color, thick, transp)
    local s = Instance.new("UIStroke"); s.Color = color or Color3.new(1,1,1); s.Thickness = thick or 1
    s.Transparency = transp or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end
local function Tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end
local INFO_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_SPRING = TweenInfo.new(0.4,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ═══════════════════════════════════════════════════════════════
--   PALETTE & CONFIG
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
    IsAntiAFK = true,
    Theme = "Halloween",
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
    ToggleKey = Enum.KeyCode.RightControl
}

-- ═══════════════════════════════════════════════════════════════
--   ANTI-AFK
-- ═══════════════════════════════════════════════════════════════
ConnMgr.add(LocalPlayer.Idled:Connect(function()
    if Config.IsAntiAFK then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController(); vu:ClickButton2(Vector2.new())
        end)
    end
end))

-- ═══════════════════════════════════════════════════════════════
--   THEME SYSTEM
-- ═══════════════════════════════════════════════════════════════
local accent = Config.Themes[Config.Theme].Accent
local accentRegistry, gradientRegistry, switchRegistry = {}, {}, {}
local StrokeGrad
local function RegisterAccent(o,p) table.insert(accentRegistry,{obj=o,prop=p}) end
local function RegisterGradient(g) table.insert(gradientRegistry,g) end

local function ApplyTheme(name)
    local t = Config.Themes[name]; if not t then return end
    Config.Theme = name; accent = t.Accent
    for _, e in ipairs(accentRegistry) do pcall(function() e.obj[e.prop] = accent end) end
    local dark = accent:Lerp(Color3.new(0,0,0),0.35)
    local seq = ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, dark) })
    for _, g in ipairs(gradientRegistry) do pcall(function() g.Color = seq end) end
    for _, s in ipairs(switchRegistry) do if s.get() then s.frame.BackgroundColor3 = accent end end
    if StrokeGrad then
        StrokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, accent),
        })
    end
end

-- ═══════════════════════════════════════════════════════════════
--   SCREEN GUI
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostUI"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = GUIParent

local Vignette = Instance.new("Frame", ScreenGui)
Vignette.Size = UDim2.new(1,0,1,0); Vignette.BackgroundColor3 = Color3.new(0,0,0)
Vignette.BackgroundTransparency = 0.78; Vignette.BorderSizePixel = 0; Vignette.ZIndex = 0
local VigGrad = Instance.new("UIGradient", Vignette)
VigGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.85),
    NumberSequenceKeypoint.new(0.6, 0.85), NumberSequenceKeypoint.new(1, 0)
}); VigGrad.Rotation = 90

local FogHolder = Instance.new("Frame", ScreenGui)
FogHolder.Size = UDim2.new(1,0,1,0); FogHolder.BackgroundTransparency = 1; FogHolder.ZIndex = 2
for i = 1, 6 do
    local fog = Instance.new("ImageLabel", FogHolder)
    fog.Size = UDim2.new(0, math.random(200, 340), 0, math.random(90, 150))
    fog.Position = UDim2.new(math.random(), 0, math.random(), 0)
    fog.BackgroundTransparency = 1; fog.Image = "rbxassetid://5028857084"
    fog.ImageColor3 = (i % 2 == 0) and PALETTE.Witch or PALETTE.Pumpkin
    fog.ImageTransparency = 0.88; fog.ScaleType = Enum.ScaleType.Slice
    fog.SliceCenter = Rect.new(24,24,276,276); fog.ZIndex = 2
end

-- ═══════════════════════════════════════════════════════════════
--   NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════
local NotifHolder = Instance.new("Frame", ScreenGui)
NotifHolder.Size = UDim2.new(0, 280, 1, -20); NotifHolder.Position = UDim2.new(1, -290, 0, 10)
NotifHolder.BackgroundTransparency = 1; NotifHolder.ZIndex = 200
local NotifScale = Instance.new("UIScale", NotifHolder); NotifScale.Scale = 0.9

local notifQueue, activeNotifs, MAX_NOTIFS = {}, 0, 5
local function renderNotif(data)
    if not data then return end
    activeNotifs += 1
    local col = (typeof(data.color) == "Color3") and data.color or accent
    local n = Instance.new("Frame", NotifHolder)
    n.Size = UDim2.new(1,0,0,72); n.Position = UDim2.new(1,20,0,(activeNotifs-1)*80)
    n.BackgroundColor3 = PALETTE.Night; n.BackgroundTransparency = 0.08; n.BorderSizePixel = 0
    n.ZIndex = 201; Corner(n, UDim.new(0,12)); Stroke(n, col, 1.2, 0.4)
    local bar = Instance.new("Frame", n)
    bar.Size = UDim2.new(0,3,1,-16); bar.Position = UDim2.new(0,6,0,8)
    bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; Corner(bar, UDim.new(1,0))
    local iconLbl = Instance.new("TextLabel", n)
    iconLbl.Size = UDim2.new(0,28,0,28); iconLbl.Position = UDim2.new(0,18,0.5,-14)
    iconLbl.BackgroundColor3 = col; iconLbl.BackgroundTransparency = 0.7
    iconLbl.Text = data.icon or "👻"; iconLbl.TextColor3 = col
    iconLbl.Font = Enum.Font.GothamBold; iconLbl.TextSize = 16; iconLbl.ZIndex = 202
    Corner(iconLbl, UDim.new(1,0))
    local ttl = Instance.new("TextLabel", n)
    ttl.Size = UDim2.new(1,-70,0,18); ttl.Position = UDim2.new(0,54,0,12)
    ttl.BackgroundTransparency = 1; ttl.Text = data.title or ""
    ttl.TextColor3 = col; ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 12
    ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 202
    local msgLbl = Instance.new("TextLabel", n)
    msgLbl.Size = UDim2.new(1,-70,0,30); msgLbl.Position = UDim2.new(0,54,0,32)
    msgLbl.BackgroundTransparency = 1; msgLbl.Text = data.msg or ""
    msgLbl.TextColor3 = PALETTE.GhostWhite; msgLbl.Font = Enum.Font.Gotham; msgLbl.TextSize = 10
    msgLbl.TextWrapped = true; msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top; msgLbl.ZIndex = 202
    local prog = Instance.new("Frame", n)
    prog.Size = UDim2.new(1,-18,0,2); prog.Position = UDim2.new(0,12,1,-7)
    prog.BackgroundColor3 = col; prog.BackgroundTransparency = 0.4; prog.BorderSizePixel = 0
    prog.ZIndex = 202; Corner(prog, UDim.new(1,0))
    Tween(n, INFO_SPRING, { Position = UDim2.new(0,0,0,n.Position.Y.Offset) })
    Tween(prog, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,0,2) })
    task.delay(3.7, function()
        pcall(function()
            Tween(n, INFO_FAST, { Position=UDim2.new(1,20,0,n.Position.Y.Offset), BackgroundTransparency=1 })
            task.wait(0.2); n:Destroy(); activeNotifs -= 1
            local i = 0
            for _, c in ipairs(NotifHolder:GetChildren()) do
                if c:IsA("Frame") then Tween(c, INFO_FAST, { Position = UDim2.new(0,0,0,i*80) }); i += 1 end
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
--   UI SCALE + GHOST FRAME
-- ═══════════════════════════════════════════════════════════════
local BASE_W, BASE_H = 440, 620
local function calcScale()
    refreshViewport()
    local vp = DEVICE.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return 0.85 end
    local maxW, maxH
    if DEVICE.IsMobile then maxW=0.95; maxH=0.9
    elseif DEVICE.IsTablet then maxW=0.75; maxH=0.88
    else maxW=0.45; maxH=0.92 end
    return math.clamp(math.min((vp.X*maxW)/BASE_W, (vp.Y*maxH)/BASE_H), 0.65, 1.20)
end
local UI_SCALE = calcScale()

local GhostAura = Instance.new("ImageLabel", ScreenGui)
GhostAura.Size = UDim2.new(0, BASE_W+140, 0, BASE_H+140)
GhostAura.Position = UDim2.new(0.5, 0, 0.5, 0); GhostAura.AnchorPoint = Vector2.new(0.5, 0.5)
GhostAura.BackgroundTransparency = 1; GhostAura.Image = "rbxassetid://5028857084"
GhostAura.ImageColor3 = PALETTE.Witch; GhostAura.ImageTransparency = 0.35
GhostAura.ScaleType = Enum.ScaleType.Slice; GhostAura.SliceCenter = Rect.new(24,24,276,276)
GhostAura.ZIndex = 1
local AuraScale = Instance.new("UIScale", GhostAura); AuraScale.Scale = UI_SCALE

local Ghost = Instance.new("Frame", ScreenGui)
Ghost.Size = UDim2.new(0, BASE_W, 0, BASE_H); Ghost.Position = UDim2.new(0.5, 0, 0.5, 0)
Ghost.AnchorPoint = Vector2.new(0.5, 0.5); Ghost.BackgroundColor3 = PALETTE.Night
Ghost.BackgroundTransparency = 0.02; Ghost.BorderSizePixel = 0; Ghost.Active = true
Ghost.ZIndex = 5; Corner(Ghost, UDim.new(0, 110))
local MainScale = Instance.new("UIScale", Ghost); MainScale.Scale = UI_SCALE
local GhostGrad = Instance.new("UIGradient", Ghost)
GhostGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PALETTE.NightLight),
    ColorSequenceKeypoint.new(0.35, PALETTE.Night),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,4,14))
}); GhostGrad.Rotation = 90
local GhostStroke = Stroke(Ghost, PALETTE.Witch, 2.5, 0.15)
StrokeGrad = Instance.new("UIGradient", GhostStroke)
StrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PALETTE.Witch), ColorSequenceKeypoint.new(0.3, PALETTE.Pumpkin),
    ColorSequenceKeypoint.new(0.5, PALETTE.GhostWhite), ColorSequenceKeypoint.new(0.7, PALETTE.Witch),
    ColorSequenceKeypoint.new(1, PALETTE.Pumpkin)
})

local GhostBgImg = Instance.new("ImageLabel", Ghost)
GhostBgImg.Size = UDim2.new(1,0,1,0); GhostBgImg.BackgroundTransparency = 1
GhostBgImg.Image = CustomImage ~= "" and CustomImage or IMAGE_FALLBACKS[1]
GhostBgImg.ImageTransparency = 0.92; GhostBgImg.ScaleType = Enum.ScaleType.Crop
GhostBgImg.ZIndex = 3; Corner(GhostBgImg, UDim.new(0, 110)); registerImage(GhostBgImg)

local WaveHolder = Instance.new("Frame", Ghost)
WaveHolder.Size = UDim2.new(1,0,0,50); WaveHolder.Position = UDim2.new(0,0,1,-25)
WaveHolder.BackgroundTransparency = 1; WaveHolder.ZIndex = 4
for i = 0, 2 do
    local wave = Instance.new("Frame", WaveHolder)
    wave.Size = UDim2.new(0.34, 0, 0, 50); wave.Position = UDim2.new(i * 0.33, 0, 0, 0)
    wave.BackgroundColor3 = PALETTE.Night; wave.BackgroundTransparency = 0.02
    wave.BorderSizePixel = 0; wave.ZIndex = 4; Corner(wave, UDim.new(1, 0))
end

local FaceHolder = Instance.new("Frame", Ghost)
FaceHolder.Size = UDim2.new(1, 0, 0, 100); FaceHolder.Position = UDim2.new(0, 0, 0, 14)
FaceHolder.BackgroundTransparency = 1; FaceHolder.ZIndex = 6

local EyeL = Instance.new("Frame", FaceHolder)
EyeL.Size = UDim2.new(0, 30, 0, 38); EyeL.Position = UDim2.new(0.5, -78, 0, 26)
EyeL.BackgroundColor3 = PALETTE.EyeGlow; EyeL.BorderSizePixel = 0; EyeL.ZIndex = 7
Corner(EyeL, UDim.new(1, 0))

local EyeLGlow = Instance.new("ImageLabel", EyeL)
EyeLGlow.Size = UDim2.new(1, 70, 1, 70); EyeLGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
EyeLGlow.AnchorPoint = Vector2.new(0.5, 0.5); EyeLGlow.BackgroundTransparency = 1
EyeLGlow.Image = "rbxassetid://5028857084"; EyeLGlow.ImageColor3 = PALETTE.EyeGlow
EyeLGlow.ImageTransparency = 0.25; EyeLGlow.ScaleType = Enum.ScaleType.Slice
EyeLGlow.SliceCenter = Rect.new(24,24,276,276); EyeLGlow.ZIndex = 6

local EyeR = EyeL:Clone()
EyeR.Position = UDim2.new(0.5, 48, 0, 26); EyeR.Parent = FaceHolder

local Mouth = Instance.new("Frame", FaceHolder)
Mouth.Size = UDim2.new(0, 70, 0, 28); Mouth.Position = UDim2.new(0.5, -35, 0, 74)
Mouth.BackgroundColor3 = PALETTE.Night; Mouth.BorderSizePixel = 0; Mouth.ZIndex = 7
Corner(Mouth, UDim.new(0, 14))
local MouthStroke = Stroke(Mouth, PALETTE.EyeGlow, 2, 0.3)

local TitleBadge = Instance.new("TextLabel", Ghost)
TitleBadge.Size = UDim2.new(0, 300, 0, 36); TitleBadge.Position = UDim2.new(0.5, -150, 0, 122)
TitleBadge.BackgroundColor3 = PALETTE.WitchDeep; TitleBadge.BackgroundTransparency = 0.25
TitleBadge.Text = "👻  GHOST MODE  👻"; TitleBadge.TextColor3 = PALETTE.GhostWhite
TitleBadge.Font = Enum.Font.GothamBlack; TitleBadge.TextSize = 16; TitleBadge.BorderSizePixel = 0
TitleBadge.ZIndex = 7; Corner(TitleBadge, UDim.new(1, 0)); Stroke(TitleBadge, PALETTE.Pumpkin, 1.5, 0.25)

local Subtitle = Instance.new("TextLabel", Ghost)
Subtitle.Size = UDim2.new(0, 340, 0, 16); Subtitle.Position = UDim2.new(0.5, -170, 0, 162)
Subtitle.BackgroundTransparency = 1; Subtitle.Text = "by ouncopybara  •  " .. Config.Themes[Config.Theme].Name
Subtitle.TextColor3 = PALETTE.Pumpkin; Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextSize = 10; Subtitle.ZIndex = 7; Subtitle.TextStrokeTransparency = 0.4

local PerfLabel = Instance.new("TextLabel", Ghost)
PerfLabel.Size = UDim2.new(0, 200, 0, 14); PerfLabel.Position = UDim2.new(0.5, -100, 0, 180)
PerfLabel.BackgroundTransparency = 1; PerfLabel.Font = Enum.Font.Code; PerfLabel.TextSize = 9
PerfLabel.TextColor3 = Color3.fromRGB(150,140,180); PerfLabel.ZIndex = 7
ConnMgr.spawn(function()
    while PerfLabel.Parent do
        PerfLabel.Text = string.format("FPS:%d  MEM:%d  PING:%d", Perf.fps, Perf.memory, Perf.ping)
        task.wait(1)
    end
end)

local function GhostButton(text, xOff, color)
    local b = Instance.new("TextButton", Ghost)
    b.Size = UDim2.new(0, 34, 0, 34); b.Position = UDim2.new(1, xOff, 0, 20)
    b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = PALETTE.GhostWhite
    b.Font = Enum.Font.GothamBlack; b.TextSize = 15; b.BorderSizePixel = 0
    b.AutoButtonColor = false; b.ZIndex = 20; Corner(b, UDim.new(1, 0))
    local st = Stroke(b, PALETTE.GhostWhite, 1.2, 0.4)
    b.MouseEnter:Connect(function() Tween(b, INFO_FAST, { Size = UDim2.new(0, 38, 0, 38) }); Tween(st, INFO_FAST, { Color = PALETTE.Pumpkin }) end)
    b.MouseLeave:Connect(function() Tween(b, INFO_FAST, { Size = UDim2.new(0, 34, 0, 34) }); Tween(st, INFO_FAST, { Color = PALETTE.GhostWhite }) end)
    return b
end
local CloseBtn = GhostButton("✕", -46, PALETTE.Blood)
local MinBtn   = GhostButton("–", -88, PALETTE.WitchDeep)

-- ═══════════════════════════════════════════════════════════════
--   👀 EYE ANIMATIONS — ALWAYS ON
-- ═══════════════════════════════════════════════════════════════
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

-- Orbs (static)
local orbHolder = Instance.new("Frame", Ghost)
orbHolder.Size = UDim2.new(1, 0, 1, 0); orbHolder.BackgroundTransparency = 1; orbHolder.ZIndex = 3
for i = 1, 5 do
    local orb = Instance.new("Frame", orbHolder)
    orb.Size = UDim2.new(0, 9, 0, 9)
    orb.BackgroundColor3 = (i % 2 == 0) and PALETTE.Pumpkin or PALETTE.Witch
    orb.BorderSizePixel = 0; orb.ZIndex = 3; Corner(orb, UDim.new(1, 0))
    local glow = Instance.new("ImageLabel", orb)
    glow.Size = UDim2.new(1, 50, 1, 50); glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5); glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"; glow.ImageColor3 = orb.BackgroundColor3
    glow.ImageTransparency = 0.4; glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24,24,276,276); glow.ZIndex = 2
    local angle = (i / 5) * math.pi * 2
    orb.Position = UDim2.new(0.5, math.cos(angle) * 260, 0.5, math.sin(angle) * 195)
end

-- ═══════════════════════════════════════════════════════════════
--   CONTENT + SIDEBAR
-- ═══════════════════════════════════════════════════════════════
local Content = Instance.new("Frame", Ghost)
Content.Size = UDim2.new(1, -44, 1, -240); Content.Position = UDim2.new(0, 22, 0, 200)
Content.BackgroundColor3 = PALETTE.Night; Content.BackgroundTransparency = 0.4
Content.BorderSizePixel = 0; Content.ClipsDescendants = true; Content.ZIndex = 6
Corner(Content, UDim.new(0, 22)); Stroke(Content, PALETTE.Witch, 1, 0.55)

local Sidebar = Instance.new("Frame", Content)
Sidebar.Size = UDim2.new(0, 84, 1, -20); Sidebar.Position = UDim2.new(0, 8, 0, 10)
Sidebar.BackgroundTransparency = 1; Sidebar.ZIndex = 7
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 6); SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 4)

local PageHost = Instance.new("Frame", Content)
PageHost.Size = UDim2.new(1, -92, 1, -8); PageHost.Position = UDim2.new(0, 92, 0, 4)
PageHost.BackgroundTransparency = 1; PageHost.ZIndex = 7

local StatusBar = Instance.new("Frame", Ghost)
StatusBar.Size = UDim2.new(1, -80, 0, 30)
StatusBar.Position = UDim2.new(0.5, -((BASE_W-80)/2), 1, -78)
StatusBar.BackgroundColor3 = PALETTE.WitchDeep; StatusBar.BackgroundTransparency = 0.4
StatusBar.BorderSizePixel = 0; StatusBar.ZIndex = 6; Corner(StatusBar, UDim.new(1, 0))
Stroke(StatusBar, PALETTE.Pumpkin, 1, 0.4)
local StatusDot = Instance.new("Frame", StatusBar)
StatusDot.Size = UDim2.new(0, 8, 0, 8); StatusDot.Position = UDim2.new(0, 14, 0.5, -4)
StatusDot.BackgroundColor3 = PALETTE.Pumpkin; StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 7; Corner(StatusDot, UDim.new(1, 0))
local StatusText = Instance.new("TextLabel", StatusBar)
StatusText.Size = UDim2.new(1, -34, 1, 0); StatusText.Position = UDim2.new(0, 30, 0, 0)
StatusText.BackgroundTransparency = 1; StatusText.Text = "System Ready"
StatusText.TextColor3 = PALETTE.GhostWhite; StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 11; StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextTruncate = Enum.TextTruncate.AtEnd; StatusText.ZIndex = 7

local function updateStatus(txt, col)
    StatusText.Text = txt
    if col and typeof(col) == "Color3" then StatusDot.BackgroundColor3 = col end
end

local function PlayClickEffect(btn)
    pcall(function()
        local r = Instance.new("Frame", btn)
        r.Size = UDim2.new(0,0,0,0); r.Position = UDim2.new(0.5,0,0.5,0)
        r.AnchorPoint = Vector2.new(0.5,0.5); r.BackgroundColor3 = PALETTE.GhostWhite
        r.BackgroundTransparency = 0.4; r.BorderSizePixel = 0; r.ZIndex = 30
        Corner(r, UDim.new(1,0))
        Tween(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,500,0,500), BackgroundTransparency = 1
        })
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
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1,-8,0,44); btn.BackgroundColor3 = accent
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false; btn.ClipsDescendants = true
    btn.LayoutOrder = #tabs + 1; btn.ZIndex = 8; Corner(btn, UDim.new(0,10))
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0,3,0,0); indicator.Position = UDim2.new(0,2,0.5,0)
    indicator.AnchorPoint = Vector2.new(0,0.5); indicator.BackgroundColor3 = PALETTE.Pumpkin
    indicator.BorderSizePixel = 0; indicator.ZIndex = 9; Corner(indicator, UDim.new(1,0))
    local ic = Instance.new("TextLabel", btn)
    ic.Size = UDim2.new(1,0,0,18); ic.Position = UDim2.new(0,0,0,6)
    ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 14; ic.ZIndex = 9
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1,0,0,14); lbl.Position = UDim2.new(0,0,0,24)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10; lbl.TextColor3 = Color3.fromRGB(140,140,150); lbl.ZIndex = 9
    local page = Instance.new("ScrollingFrame", PageHost)
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.Visible = false; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = PALETTE.Pumpkin
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollingDirection = Enum.ScrollingDirection.Y; page.ScrollBarImageTransparency = 0.5
    page.ZIndex = 8
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0,8); pl.SortOrder = Enum.SortOrder.LayoutOrder
    local pp = Instance.new("UIPadding", page)
    pp.PaddingRight = UDim.new(0,10); pp.PaddingBottom = UDim.new(0,10)
    local tab = { Button=btn, Indicator=indicator, Label=lbl, Page=page, Active=false }
    table.insert(tabs, tab)
    btn.MouseEnter:Connect(function() if not tab.Active then Tween(btn, INFO_FAST, { BackgroundTransparency = 0.93 }) end end)
    btn.MouseLeave:Connect(function() if not tab.Active then Tween(btn, INFO_FAST, { BackgroundTransparency = 1 }) end end)
    btn.MouseButton1Click:Connect(function() SelectTab(tab); PlayClickEffect(btn) end)
    return page
end

local function AddSection(page, text, order)
    local l = Instance.new("TextLabel", page)
    l.LayoutOrder = order; l.Size = UDim2.new(1,4,0,20); l.BackgroundTransparency = 1
    l.Text = "🎃 " .. string.upper(text); l.TextColor3 = PALETTE.Pumpkin
    l.Font = Enum.Font.GothamBlack; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 8
    l.TextStrokeTransparency = 0.4
end

local function AddToggle(page, title, desc, default, order, callback)
    local row = Instance.new("TextButton", page)
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0, desc and 52 or 44)
    row.BackgroundColor3 = PALETTE.NightLight; row.BackgroundTransparency = 0.35
    row.Text = ""; row.BorderSizePixel = 0; row.AutoButtonColor = false
    row.ClipsDescendants = true; row.ZIndex = 8; Corner(row, UDim.new(0,12))
    Stroke(row, PALETTE.Witch, 1, 0.6)
    local ttl = Instance.new("TextLabel", row)
    ttl.Size = UDim2.new(1,-70,0,16)
    ttl.Position = desc and UDim2.new(0,12,0,9) or UDim2.new(0,12,0.5,-8)
    ttl.BackgroundTransparency = 1; ttl.Text = title
    ttl.TextColor3 = PALETTE.GhostWhite; ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.TextTruncate = Enum.TextTruncate.AtEnd; ttl.ZIndex = 9
    if desc then
        local d = Instance.new("TextLabel", row)
        d.Size = UDim2.new(1,-70,0,13); d.Position = UDim2.new(0,12,0,26)
        d.BackgroundTransparency = 1; d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,140,180); d.Font = Enum.Font.Gotham
        d.TextSize = 9; d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextTruncate = Enum.TextTruncate.AtEnd; d.ZIndex = 9
    end
    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.new(0,40,0,22); sw.Position = UDim2.new(1,-52,0.5,-11)
    sw.BackgroundColor3 = Color3.fromRGB(40,35,55); sw.BorderSizePixel = 0
    sw.ZIndex = 9; Corner(sw, UDim.new(1,0)); Stroke(sw, PALETTE.Witch, 1, 0.4)
    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = PALETTE.GhostWhite; knob.BorderSizePixel = 0
    knob.ZIndex = 10; Corner(knob, UDim.new(1,0))
    local isOn = default and true or false
    local function refresh()
        if isOn then
            sw.BackgroundColor3 = PALETTE.Pumpkin
            Tween(knob, INFO_SPRING, { Position = UDim2.new(1,-19,0.5,-8) })
            Tween(row, INFO_FAST, { BackgroundTransparency = 0.1 })
        else
            sw.BackgroundColor3 = Color3.fromRGB(40,35,55)
            Tween(knob, INFO_SPRING, { Position = UDim2.new(0,3,0.5,-8) })
            Tween(row, INFO_FAST, { BackgroundTransparency = 0.35 })
        end
    end
    if isOn then sw.BackgroundColor3 = PALETTE.Pumpkin; knob.Position = UDim2.new(1,-19,0.5,-8); row.BackgroundTransparency = 0.1 end
    table.insert(switchRegistry, { frame = sw, get = function() return isOn end })
    row.MouseButton1Click:Connect(function()
        isOn = not isOn; refresh(); PlayClickEffect(sw)
        if callback then pcall(callback, isOn) end
    end)
    row.MouseEnter:Connect(function() if not isOn then Tween(row, INFO_FAST, { BackgroundTransparency = 0.2 }) end end)
    row.MouseLeave:Connect(function() if not isOn then Tween(row, INFO_FAST, { BackgroundTransparency = 0.35 }) end end)
end

local function AddButton(page, title, order, callback)
    local b = Instance.new("TextButton", page)
    b.LayoutOrder = order; b.Size = UDim2.new(1,0,0,42); b.BackgroundColor3 = PALETTE.WitchDeep
    b.Text = title; b.TextColor3 = PALETTE.GhostWhite; b.Font = Enum.Font.GothamBlack
    b.TextSize = 12; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.ClipsDescendants = true; b.ZIndex = 8; Corner(b, UDim.new(0,12))
    local grad = Instance.new("UIGradient", b)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.Witch), ColorSequenceKeypoint.new(0.5, PALETTE.WitchDeep),
        ColorSequenceKeypoint.new(1, PALETTE.PumpkinDeep)
    }); grad.Rotation = 30
    Stroke(b, PALETTE.Pumpkin, 1.5, 0.3)
    local scale = Instance.new("UIScale", b)
    b.MouseEnter:Connect(function() Tween(scale, INFO_FAST, { Scale = 1.03 }) end)
    b.MouseLeave:Connect(function() Tween(scale, INFO_FAST, { Scale = 1 }) end)
    b.MouseButton1Down:Connect(function() Tween(scale, INFO_FAST, { Scale = 0.96 }); PlayClickEffect(b) end)
    b.MouseButton1Up:Connect(function() Tween(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.03 }) end)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
    return b
end

local function AddTextInput(page, placeholder, default, order, callback)
    local row = Instance.new("Frame", page)
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,38)
    row.BackgroundColor3 = PALETTE.NightLight; row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0; row.ZIndex = 8; Corner(row, UDim.new(0,10))
    Stroke(row, PALETTE.Witch, 1, 0.6)
    local tb = Instance.new("TextBox", row)
    tb.Size = UDim2.new(1,-20,1,0); tb.Position = UDim2.new(0,10,0,0)
    tb.BackgroundTransparency = 1; tb.Text = default or ""
    tb.PlaceholderText = placeholder or ""
    tb.PlaceholderColor3 = Color3.fromRGB(150,140,180)
    tb.TextColor3 = PALETTE.GhostWhite; tb.Font = Enum.Font.Gotham
    tb.TextSize = 11; tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ClearTextOnFocus = false; tb.ZIndex = 9
    tb:GetPropertyChangedSignal("Text"):Connect(function()
        if callback then pcall(callback, tb.Text) end
    end)
    return tb
end

local function AddThemePicker(page, order)
    local row = Instance.new("Frame", page)
    row.LayoutOrder = order; row.Size = UDim2.new(1,0,0,52)
    row.BackgroundColor3 = PALETTE.NightLight; row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0; row.ZIndex = 8; Corner(row, UDim.new(0,12))
    Stroke(row, PALETTE.Witch, 1, 0.6)
    local names = { "Halloween","Pink","Purple","Blue","Green","Gold","Red","Cyan" }
    for i, name in ipairs(names) do
        local dot = Instance.new("TextButton", row)
        dot.Size = UDim2.new(0,26,0,26); dot.Position = UDim2.new(0, 12 + (i-1)*32, 0.5, -13)
        dot.BackgroundColor3 = Config.Themes[name].Accent; dot.Text = ""
        dot.BorderSizePixel = 0; dot.AutoButtonColor = false
        dot.ClipsDescendants = true; dot.ZIndex = 9; Corner(dot, UDim.new(1,0))
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
--   MENU PAGE
-- ═══════════════════════════════════════════════════════════════
local mainPage = CreateTab("Menu", "👻")
AddSection(mainPage, "General Features", 1)
AddToggle(mainPage, "Anti AFK", "ការពារហ្គេមទាត់ចេញពេលទុកចោលយូរ", true, 2, function(s) Config.IsAntiAFK = s end)
AddSection(mainPage, "Theme Picker", 4)
AddThemePicker(mainPage, 5)
AddSection(mainPage, "System", 6)
AddButton(mainPage, "Close UI", 7, function()
    ConnMgr.purge(); ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════
--   🌸 SERVER SPAWN EXPLORER + NOCLIP + TELEPORT GRAB + ORBIT FARM
-- ═══════════════════════════════════════════════════════════════
local EXP = {
    MAX_RENDER = 60, SPAWN_LIFETIME = 30, MOVE_THRESHOLD = 0.5,
    DROP_RADIUS = 12, DROP_MEMORY = 5, ARRIVE_DIST = 3,
}

local FarmConfig = {
    EscapeHeight = 100,
    EscapeSpeed  = 500,
    NextDelay    = 0.05,
    OrbitRadius  = 300,
    OrbitSpeed   = 150,
    OrbitHeight  = 100,
    OrbitMinTime = 0.1,
    MaxGrabTries = 3,
}

local Explorer = {
    autoFly = false, speed = 60, objects = {}, spawned = {},
    playerDrops = {}, isFlying = false, flightConn = nil,
    flightVel = nil, target = nil, searchText = "", running = true,
    noclipConn = nil,
}
local Farming = { active = false, grabbed = 0 }
local Orbit = { active = false, angle = 0, bv = nil, conn = nil, startTime = 0, center = Vector3.new(0, 100, 0) }

-- Noclip
local function startNoclip()
    if Explorer.noclipConn then Explorer.noclipConn:Disconnect() end
    Explorer.noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip(restore)
    if Explorer.noclipConn then
        Explorer.noclipConn:Disconnect()
        Explorer.noclipConn = nil
    end
    if restore then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsA("Accessory") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Filters
local function exIsPlayerHeld(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char and obj:IsDescendantOf(char) then return true end
        local bp = p:FindFirstChildOfClass("Backpack")
        if bp and obj:IsDescendantOf(bp) then return true end
    end
    return false
end

local function exHasHumanoid(obj)
    local cur = obj
    while cur and cur ~= workspace do
        if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") then return true end
        cur = cur.Parent
    end
    return false
end

local function exIsToolPart(obj)
    local cur = obj
    while cur and cur ~= workspace do
        if cur:IsA("Tool") then return true end
        cur = cur.Parent
    end
    return false
end

local function exIsAccessoryPart(obj)
    local cur = obj
    while cur and cur ~= workspace do
        if cur:IsA("Accessory") or cur:IsA("Accoutrement") then return true end
        cur = cur.Parent
    end
    return false
end

local function exIsNearAnyPlayer(part, radius)
    if not part:IsA("BasePart") then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and (part.Position - hrp.Position).Magnitude <= radius then return true end
    end
    return false
end

local function exMarkDrop(part) Explorer.playerDrops[part] = os.clock() end
local function exIsPlayerDrop(part)
    local t = Explorer.playerDrops[part]
    if not t then return false end
    if os.clock() - t > EXP.DROP_MEMORY then
        Explorer.playerDrops[part] = nil
        return false
    end
    return true
end

local function exIsServerSpawn(obj)
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return false end
    if exIsPlayerHeld(obj) then return false end
    if exHasHumanoid(obj) then return false end
    if exIsToolPart(obj) then return false end
    if exIsAccessoryPart(obj) then return false end
    if exIsPlayerDrop(obj) then return false end
    if exIsNearAnyPlayer(obj, EXP.DROP_RADIUS) then return false end
    return true
end

local function exIsMoving(obj)
    if not obj:IsA("BasePart") or obj.Anchored then return false end
    return obj.AssemblyLinearVelocity.Magnitude > EXP.MOVE_THRESHOLD
        or obj.AssemblyAngularVelocity.Magnitude > 0.1
end

-- Core
local function exGetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function exGetPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

-- Manual flight (BodyVelocity)
local function exStopFlight(silent)
    if Explorer.flightConn then Explorer.flightConn:Disconnect(); Explorer.flightConn = nil end
    if Explorer.flightVel then Explorer.flightVel:Destroy(); Explorer.flightVel = nil end
    Explorer.target = nil; Explorer.isFlying = false
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    stopNoclip(not Farming.active and not Orbit.active)
    if not silent then pcall(function() updateStatus("Flight stopped", PALETTE.Blood) end) end
end

local function exFlyTo(object, onArrive)
    if not object or not object:IsDescendantOf(workspace) then return end
    local part = exGetPart(object)
    if not part then return end
    local root = exGetRoot()
    if not root then return end
    exStopFlight(true)
    root = exGetRoot(); if not root then return end
    Explorer.target = object; Explorer.isFlying = true

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    startNoclip()

    Explorer.flightVel = Instance.new("BodyVelocity")
    Explorer.flightVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    Explorer.flightVel.P = 8000
    Explorer.flightVel.Velocity = Vector3.zero
    Explorer.flightVel.Parent = root
    pcall(function() updateStatus("Flying: " .. object.Name, PALETTE.Toxic) end)

    local speed = math.clamp(Explorer.speed, 5, 300)
    Explorer.flightConn = RunService.Heartbeat:Connect(function()
        if not Explorer.target or not Explorer.target:IsDescendantOf(workspace)
            or not root.Parent or not part.Parent then
            exStopFlight(); return
        end
        local ok, closest = pcall(function() return part:GetClosestPointOnSurface(root.Position) end)
        local point = ok and closest or part.Position
        local offset = point - root.Position
        local distance = offset.Magnitude
        if distance <= EXP.ARRIVE_DIST then
            if Explorer.flightVel then Explorer.flightVel.Velocity = Vector3.zero end
            exStopFlight(true)
            pcall(function() updateStatus("Arrived: " .. object.Name, PALETTE.Toxic) end)
            if onArrive then task.spawn(onArrive) end
            return
        end
        local targetSpeed = math.min(speed, distance * 3)
        Explorer.flightVel.Velocity = offset.Unit * targetSpeed
    end)
end

-- Render / Rebuild
local explorerPage, explorerSectionLabel = nil, nil

local function exClearRows()
    if not explorerPage then return end
    for _, child in ipairs(explorerPage:GetChildren()) do
        if child.Name == "ExplorerRow" then child:Destroy() end
    end
end

local function exRenderRows()
    exClearRows()
    if not explorerPage then return end
    local q = Explorer.searchText:lower()
    local shown, total = 0, 0
    for _, obj in ipairs(Explorer.objects) do
        if obj.Parent and obj:IsDescendantOf(workspace) and obj.Name:lower():find(q, 1, true) then
            total += 1
            if shown < EXP.MAX_RENDER then
                shown += 1
                local row = Instance.new("TextButton", explorerPage)
                row.Name = "ExplorerRow"; row.LayoutOrder = 100 + shown
                row.Size = UDim2.new(1,0,0,44)
                row.BackgroundColor3 = PALETTE.NightLight; row.BackgroundTransparency = 0.35
                row.Text = ""; row.BorderSizePixel = 0; row.AutoButtonColor = false
                row.ClipsDescendants = true; row.ZIndex = 8
                Corner(row, UDim.new(0,10)); Stroke(row, accent, 1, 0.6)
                local dot = Instance.new("Frame", row)
                dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(0,8,0.5,-3)
                dot.BackgroundColor3 = accent; dot.BorderSizePixel = 0; dot.ZIndex = 9
                Corner(dot, UDim.new(1,0))
                local tag = exIsMoving(obj) and "🏃 MOVING" or "🆕 NEW"
                local ttl = Instance.new("TextLabel", row)
                ttl.Size = UDim2.new(1,-24,0,18); ttl.Position = UDim2.new(0,20,0,5)
                ttl.BackgroundTransparency = 1; ttl.Text = obj.Name
                ttl.TextColor3 = PALETTE.GhostWhite; ttl.Font = Enum.Font.GothamBold
                ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left
                ttl.TextTruncate = Enum.TextTruncate.AtEnd; ttl.ZIndex = 9
                local sub = Instance.new("TextLabel", row)
                sub.Size = UDim2.new(1,-24,0,14); sub.Position = UDim2.new(0,20,0,24)
                sub.BackgroundTransparency = 1; sub.Text = obj.ClassName .. " • " .. tag
                sub.TextColor3 = Color3.fromRGB(150,140,180); sub.Font = Enum.Font.Gotham
                sub.TextSize = 9; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 9
                row.MouseEnter:Connect(function() Tween(row, INFO_FAST, { BackgroundTransparency = 0.15 }) end)
                row.MouseLeave:Connect(function() Tween(row, INFO_FAST, { BackgroundTransparency = 0.35 }) end)
                row.MouseButton1Click:Connect(function() exFlyTo(obj) end)
            end
        end
    end
    if explorerSectionLabel then
        explorerSectionLabel.Text = string.format("🌸 DETECTED OBJECTS (%d)", total)
    end
    if not Explorer.isFlying and not Farming.active then
        pcall(function() updateStatus(string.format("%d objects detected", total), PALETTE.Witch) end)
    end
end

local function exRebuild(force)
    if not Explorer.running then return end
    local newList = {}
    local now = os.clock()
    for obj, t in pairs(Explorer.spawned) do
        local valid = obj.Parent and obj:IsDescendantOf(workspace) and exIsServerSpawn(obj)
        if not valid then
            Explorer.spawned[obj] = nil
        else
            local age = now - t
            local moving = exIsMoving(obj)
            if age <= EXP.SPAWN_LIFETIME or moving then
                table.insert(newList, obj)
            else
                Explorer.spawned[obj] = nil
            end
        end
    end
    for part, t in pairs(Explorer.playerDrops) do
        if (now - t) > EXP.DROP_MEMORY or not part.Parent then Explorer.playerDrops[part] = nil end
    end
    local changed = force or (#newList ~= #Explorer.objects)
    if not changed then
        for i = 1, #newList do
            if newList[i] ~= Explorer.objects[i] then changed = true; break end
        end
    end
    Explorer.objects = newList
    if changed then task.spawn(exRenderRows) end
end

local function exInitialScan()
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored and exIsServerSpawn(d) then
            if d.AssemblyLinearVelocity.Magnitude > EXP.MOVE_THRESHOLD
                or d.AssemblyAngularVelocity.Magnitude > 0.1 then
                Explorer.spawned[d] = os.clock()
            end
        end
    end
end

local function exScanAll()
    exStopFlight(true)
    Explorer.objects = {}
    exInitialScan()
    exRebuild(true)
    Notify("Scanner", "Rescan complete", PALETTE.Witch, "🔄")
end

-- ═══════════════════════════════════════════════════════════════
--   🎯 TELEPORT GRAB — 100% យកបានគ្រប់ទីកន្លែង
-- ═══════════════════════════════════════════════════════════════

local function exForceGrab(root, part, obj)
    -- 1. Force touch on/off
    pcall(function() firetouchinterest(root, part, 0) end)
    task.wait(0.03)
    pcall(function() firetouchinterest(root, part, 1) end)

    -- 2. Fire ProximityPrompt / ClickDetector ក្នុង object + parent
    local function firePrompts(container)
        if not container then return end
        for _, d in ipairs(container:GetChildren()) do
            if d:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(d) end)
            elseif d:IsA("ClickDetector") then
                pcall(function() fireclickdetector(d) end)
            end
        end
    end
    firePrompts(obj)
    firePrompts(obj.Parent)
    firePrompts(part)

    -- 3. Descendant prompts
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(d) end)
        elseif d:IsA("ClickDetector") then
            pcall(function() fireclickdetector(d) end)
        end
    end
end

local function exTeleportGrab(object, onDone)
    if not object or not object.Parent or not object:IsDescendantOf(workspace) then
        if onDone then task.spawn(onDone) end
        return false
    end

    local part = exGetPart(object)
    if not part then
        if onDone then task.spawn(onDone) end
        return false
    end

    local root = exGetRoot()
    if not root then
        if onDone then task.spawn(onDone) end
        return false
    end

    startNoclip()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    pcall(function() updateStatus("🎯 Grab: " .. object.Name, PALETTE.Toxic) end)

    local grabbed = false
    for try = 1, FarmConfig.MaxGrabTries do
        if not object.Parent or not object:IsDescendantOf(workspace) then
            grabbed = true
            break
        end

        local curPart = exGetPart(object)
        if not curPart then grabbed = true; break end

        -- Teleport ទៅលើវត្ថុ
        pcall(function()
            root.CFrame = CFrame.new(curPart.Position + Vector3.new(0, 2, 0))
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
        task.wait(0.02)

        exForceGrab(root, curPart, object)
        task.wait(0.04)

        -- បើនៅមាន → teleport ចូលវត្ថុផ្ទាល់
        if object.Parent and object:IsDescendantOf(workspace) then
            pcall(function()
                root.CFrame = CFrame.new(curPart.Position)
            end)
            task.wait(0.03)
            exForceGrab(root, curPart, object)
            task.wait(0.03)
        end

        -- ពិនិត្យថាវត្ថុអស់ឬនៅ
        if not object.Parent or not object:IsDescendantOf(workspace) then
            grabbed = true
            break
        end
        task.wait(0.02)
    end

    if grabbed then
        Farming.grabbed += 1
        pcall(function() updateStatus("✓ Grabbed: " .. tostring(object.Name), PALETTE.Toxic) end)
    else
        pcall(function() updateStatus("✗ Missed: " .. tostring(object.Name), PALETTE.Blood) end)
    end

    if onDone then task.spawn(onDone) end
    return grabbed
end

-- ⬆️ Escape up 100m
local function exEscapeUp(onDone)
    local root = exGetRoot()
    if not root then
        if onDone then task.spawn(onDone) end
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    startNoclip()

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FarmEscapeVelocity"
    bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    bv.P = 50000
    bv.Velocity = Vector3.new(0, FarmConfig.EscapeSpeed, 0)
    bv.Parent = root

    pcall(function() updateStatus("⬆ Escaping 100m...", PALETTE.Pumpkin) end)

    local duration = FarmConfig.EscapeHeight / FarmConfig.EscapeSpeed
    task.delay(duration, function()
        if bv and bv.Parent then bv:Destroy() end
        if onDone then task.spawn(onDone) end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--   ORBIT PATROL
-- ═══════════════════════════════════════════════════════════════

local function exComputeOrbitCenter()
    local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawn then
        return Vector3.new(spawn.Position.X, FarmConfig.OrbitHeight, spawn.Position.Z)
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        return Vector3.new(hrp.Position.X, FarmConfig.OrbitHeight, hrp.Position.Z)
    end
    return Vector3.new(0, FarmConfig.OrbitHeight, 0)
end

local function exHasValidTarget()
    for obj, _ in pairs(Explorer.spawned) do
        if obj.Parent and obj:IsDescendantOf(workspace) and exIsServerSpawn(obj) then
            return true
        end
    end
    return false
end

local function exStopOrbit()
    Orbit.active = false
    if Orbit.conn then Orbit.conn:Disconnect(); Orbit.conn = nil end
    if Orbit.bv then Orbit.bv:Destroy(); Orbit.bv = nil end
end

local exFarmNextTarget -- forward declare

local function exStartOrbit()
    if Orbit.active then return end
    Orbit.active = true
    Orbit.angle = math.random() * math.pi * 2
    Orbit.center = exComputeOrbitCenter()
    Orbit.startTime = os.clock()

    local root = exGetRoot()
    if not root then
        exStopOrbit()
        if Farming.active then task.wait(0.2); exFarmNextTarget() end
        return
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    startNoclip()

    -- Warp ទៅ orbit ភ្លាម
    local startPos = Orbit.center + Vector3.new(
        math.cos(Orbit.angle) * FarmConfig.OrbitRadius,
        0,
        math.sin(Orbit.angle) * FarmConfig.OrbitRadius
    )
    pcall(function()
        root.CFrame = CFrame.new(startPos)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    Orbit.bv = Instance.new("BodyVelocity")
    Orbit.bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    Orbit.bv.P = 50000
    Orbit.bv.Velocity = Vector3.zero
    Orbit.bv.Parent = root

    pcall(function() updateStatus("🔄 Orbit patrol...", PALETTE.Witch) end)

    Orbit.conn = RunService.Heartbeat:Connect(function(dt)
        if not Orbit.active or not Farming.active then
            exStopOrbit(); return
        end
        local root = exGetRoot()
        if not root or not Orbit.bv then return end

        Orbit.angle = Orbit.angle + (FarmConfig.OrbitSpeed / FarmConfig.OrbitRadius) * dt

        local targetPos = Orbit.center + Vector3.new(
            math.cos(Orbit.angle) * FarmConfig.OrbitRadius,
            0,
            math.sin(Orbit.angle) * FarmConfig.OrbitRadius
        )

        local delta = targetPos - root.Position
        local dist = delta.Magnitude

        if dist > 3 then
            Orbit.bv.Velocity = delta.Unit * math.min(FarmConfig.OrbitSpeed * 8, dist * 8)
        else
            local tangent = Vector3.new(-math.sin(Orbit.angle), 0, math.cos(Orbit.angle))
            Orbit.bv.Velocity = tangent * FarmConfig.OrbitSpeed
        end

        -- Instant grab on new spawn
        local elapsed = os.clock() - Orbit.startTime
        if elapsed >= FarmConfig.OrbitMinTime and exHasValidTarget() then
            exStopOrbit()
            exFarmNextTarget()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--   FARM LOOP
-- ═══════════════════════════════════════════════════════════════

exFarmNextTarget = function()
    if not Farming.active then return end
    local root = exGetRoot()
    if not root then
        task.wait(0.15)
        if Farming.active then exFarmNextTarget() end
        return
    end

    -- រកវត្ថុជិតបំផុត
    local best, bestDist = nil, math.huge
    for obj, _ in pairs(Explorer.spawned) do
        if obj.Parent and obj:IsDescendantOf(workspace) and exIsServerSpawn(obj) then
            local part = exGetPart(obj)
            if part then
                local d = (part.Position - root.Position).Magnitude
                if d < bestDist then bestDist = d; best = obj end
            end
        end
    end

    if not best then
        exStartOrbit()
        return
    end

    -- Teleport grab → escape → next
    exTeleportGrab(best, function()
        if not Farming.active then return end
        task.wait(0.03)
        if not Farming.active then return end
        exEscapeUp(function()
            task.wait(FarmConfig.NextDelay)
            if Farming.active then exFarmNextTarget() end
        end)
    end)
end

local function exStartFarming()
    if Farming.active then return end
    Farming.active = true
    Farming.grabbed = 0
    Explorer.autoFly = false
    startNoclip()
    Notify("Loop Farm", "🎯 Teleport → Escape → Orbit ∞", PALETTE.Toxic, "🔁")
    exFarmNextTarget()
end

local function exStopFarming()
    if not Farming.active then return end
    Farming.active = false
    exStopOrbit()
    exStopFlight(true)
    stopNoclip(true)
    Notify("Loop Farm", "⏹ Stopped (" .. tostring(Farming.grabbed) .. " grabs)", PALETTE.Blood, "🛑")
end

-- ═══════════════════════════════════════════════════════════════
--   SPAWN TAB UI
-- ═══════════════════════════════════════════════════════════════
local spawnPage = CreateTab("Spawn", "🌸")
explorerPage = spawnPage

AddSection(spawnPage, "Flight Control", 1)
AddToggle(spawnPage, "Auto Fly", "ហោះទៅវត្ថុ server ថ្មីស្វ័យប្រវត្តិ", false, 2, function(s)
    Explorer.autoFly = s
    if s then Notify("Auto Fly", "Enabled", PALETTE.Toxic, "🚀") end
end)

local speedRow = Instance.new("Frame", spawnPage)
speedRow.LayoutOrder = 3; speedRow.Size = UDim2.new(1,0,0,44)
speedRow.BackgroundColor3 = PALETTE.NightLight; speedRow.BackgroundTransparency = 0.35
speedRow.BorderSizePixel = 0; speedRow.ZIndex = 8
Corner(speedRow, UDim.new(0,12)); Stroke(speedRow, PALETTE.Witch, 1, 0.6)
local speedLbl = Instance.new("TextLabel", speedRow)
speedLbl.Size = UDim2.new(1,-120,0,16); speedLbl.Position = UDim2.new(0,12,0,6)
speedLbl.BackgroundTransparency = 1; speedLbl.Text = "Manual Flight Speed"
speedLbl.TextColor3 = PALETTE.GhostWhite; speedLbl.Font = Enum.Font.GothamBold
speedLbl.TextSize = 11; speedLbl.TextXAlignment = Enum.TextXAlignment.Left; speedLbl.ZIndex = 9
local speedSub = Instance.new("TextLabel", speedRow)
speedSub.Size = UDim2.new(1,-120,0,13); speedSub.Position = UDim2.new(0,12,0,24)
speedSub.BackgroundTransparency = 1; speedSub.Text = "5 - 300 studs/sec"
speedSub.TextColor3 = Color3.fromRGB(150,140,180); speedSub.Font = Enum.Font.Gotham
speedSub.TextSize = 9; speedSub.TextXAlignment = Enum.TextXAlignment.Left; speedSub.ZIndex = 9
local speedBox = Instance.new("TextBox", speedRow)
speedBox.Size = UDim2.new(0,80,0,28); speedBox.Position = UDim2.new(1,-92,0.5,-14)
speedBox.BackgroundColor3 = PALETTE.Night; speedBox.Text = "60"
speedBox.TextColor3 = PALETTE.GhostWhite; speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 12; speedBox.BorderSizePixel = 0; speedBox.ClearTextOnFocus = false
speedBox.ZIndex = 9; Corner(speedBox, UDim.new(0,8)); Stroke(speedBox, accent, 1, 0.5)
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then Explorer.speed = math.clamp(n, 5, 300) end
    speedBox.Text = tostring(Explorer.speed)
end)

AddSection(spawnPage, "Manual Control", 4)
AddButton(spawnPage, "🔄  Rescan Now", 5, function() exScanAll() end)
AddButton(spawnPage, "🛑  Stop Everything", 6, function()
    if Farming.active then exStopFarming() end
    exStopFlight()
end)
AddTextInput(spawnPage, "Search spawned items...", "", 7, function(txt)
    Explorer.searchText = txt
    task.spawn(exRenderRows)
end)

AddSection(spawnPage, "Orbit Farm (Auto)", 9)
AddToggle(spawnPage, "🔁 Teleport Grab Farm",
    "Teleport → Grab → Escape 100m → Orbit ∞",
    false, 10, function(s)
        if s then exStartFarming() else exStopFarming() end
    end)

local farmInfo = Instance.new("TextLabel", spawnPage)
farmInfo.LayoutOrder = 11; farmInfo.Size = UDim2.new(1,4,0,56)
farmInfo.BackgroundTransparency = 1
farmInfo.Text = string.format(
    "💥 Teleport Grab (100%%)\n⬆ Escape: %d studs\n🔄 Orbit: r=%d @ %d/s",
    FarmConfig.EscapeHeight, FarmConfig.OrbitRadius, FarmConfig.OrbitSpeed)
farmInfo.TextColor3 = Color3.fromRGB(150,140,180); farmInfo.Font = Enum.Font.Code
farmInfo.TextSize = 9; farmInfo.TextXAlignment = Enum.TextXAlignment.Left
farmInfo.TextYAlignment = Enum.TextYAlignment.Top; farmInfo.ZIndex = 8

local countLbl = Instance.new("TextLabel", spawnPage)
countLbl.LayoutOrder = 20; countLbl.Size = UDim2.new(1,4,0,20)
countLbl.BackgroundTransparency = 1; countLbl.Text = "🌸 DETECTED OBJECTS (0)"
countLbl.TextColor3 = PALETTE.Pumpkin; countLbl.Font = Enum.Font.GothamBlack
countLbl.TextSize = 10; countLbl.TextXAlignment = Enum.TextXAlignment.Left
countLbl.ZIndex = 8; countLbl.TextStrokeTransparency = 0.4
explorerSectionLabel = countLbl

-- Hooks
ConnMgr.add(workspace.DescendantAdded:Connect(function(obj)
    if not exIsServerSpawn(obj) then return end
    local tracked = nil
    if obj:IsA("BasePart") then
        Explorer.spawned[obj] = os.clock(); tracked = obj
    elseif obj:IsA("Model") then
        for _, p in ipairs(obj:GetDescendants()) do
            if p:IsA("BasePart") and exIsServerSpawn(p) then
                Explorer.spawned[p] = os.clock()
                if not tracked then tracked = p end
            end
        end
    end
    if tracked and Explorer.autoFly and not Explorer.isFlying and not Farming.active then
        exFlyTo(tracked)
    end
end))

local function exWatchChar(char)
    ConnMgr.add(char.DescendantRemoving:Connect(function(desc)
        if desc:IsA("Tool") or desc:IsA("BasePart") then
            exMarkDrop(desc)
            if desc:IsA("Tool") then
                local h = desc:FindFirstChild("Handle")
                if h then exMarkDrop(h) end
            end
        end
    end))
end
local function exWatchBP(bp)
    ConnMgr.add(bp.DescendantRemoving:Connect(function(desc)
        if desc:IsA("Tool") then
            exMarkDrop(desc)
            local h = desc:FindFirstChild("Handle")
            if h then exMarkDrop(h) end
        end
    end))
end
local function exWatchPlayer(p)
    if p.Character then exWatchChar(p.Character) end
    ConnMgr.add(p.CharacterAdded:Connect(exWatchChar))
    local bp = p:FindFirstChildOfClass("Backpack")
    if bp then exWatchBP(bp) end
    ConnMgr.add(p.ChildAdded:Connect(function(c)
        if c:IsA("Backpack") then exWatchBP(c) end
    end))
end
for _, p in ipairs(Players:GetPlayers()) do exWatchPlayer(p) end
ConnMgr.add(Players.PlayerAdded:Connect(exWatchPlayer))

ConnMgr.add(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Farming.active then exStopFarming() end
    exStopFlight(true)
end))

ConnMgr.spawn(function()
    while Explorer.running and ScreenGui.Parent do
        task.wait(1)
        if Explorer.running then exRebuild(false) end
    end
end)

task.spawn(function()
    task.wait(0.6)
    if Explorer.running then exScanAll() end
end)

-- ═══════════════════════════════════════════════════════════════
--   MOBILE + SELECT TAB
-- ═══════════════════════════════════════════════════════════════
if DEVICE.IsMobile then
    Sidebar.Size = UDim2.new(0,76,1,-20)
    PageHost.Size = UDim2.new(1,-84,1,-8); PageHost.Position = UDim2.new(0,84,0,4)
    SideLayout.Padding = UDim.new(0,5)
    NotifScale.Scale = math.clamp(UI_SCALE*0.95, 0.7, 0.9)
    NotifHolder.Size = UDim2.new(0,240,1,-20)
    NotifHolder.Position = UDim2.new(1,-250,0,10)
end
SelectTab(tabs[1])

-- ═══════════════════════════════════════════════════════════════
--   REOPEN BUTTON
-- ═══════════════════════════════════════════════════════════════
local ReopenBtn = Instance.new("TextButton", ScreenGui)
ReopenBtn.Size = UDim2.new(0,60,0,60); ReopenBtn.Position = UDim2.new(0,16,0.5,0)
ReopenBtn.AnchorPoint = Vector2.new(0,0.5); ReopenBtn.BackgroundColor3 = PALETTE.Night
ReopenBtn.Text = "👻"; ReopenBtn.Visible = false; ReopenBtn.TextColor3 = PALETTE.Pumpkin
ReopenBtn.Font = Enum.Font.GothamBlack; ReopenBtn.TextSize = 28
ReopenBtn.BorderSizePixel = 0; ReopenBtn.AutoButtonColor = false; ReopenBtn.ZIndex = 100
Corner(ReopenBtn, UDim.new(1,0))
local ReopenScale = Instance.new("UIScale", ReopenBtn)
ReopenScale.Scale = math.clamp(UI_SCALE+0.2, 0.75, 1.15)
Stroke(ReopenBtn, PALETTE.Pumpkin, 2, 0.2)
local roImg = Instance.new("ImageLabel", ReopenBtn)
roImg.Size = UDim2.new(1,0,1,0); roImg.BackgroundTransparency = 1
roImg.Image = CustomImage ~= "" and CustomImage or IMAGE_FALLBACKS[2]
roImg.ImageTransparency = 0.5; roImg.ScaleType = Enum.ScaleType.Crop
roImg.ZIndex = 99; Corner(roImg, UDim.new(1,0)); registerImage(roImg)

local minimized = false
local function SetMinimized(state)
    minimized = state
    if state then
        ReopenBtn.Visible = true; ReopenBtn.Size = UDim2.new(0,0,0,0)
        Tween(ReopenBtn, INFO_SPRING, { Size = UDim2.new(0,60,0,60) })
        Tween(MainScale, INFO_FAST, { Scale = UI_SCALE * 0.85 })
        Ghost.Visible = false; GhostAura.Visible = false
        FogHolder.Visible = false; Vignette.Visible = false
    else
        Ghost.Visible = true; GhostAura.Visible = true
        FogHolder.Visible = true; Vignette.Visible = true
        Tween(MainScale, INFO_SPRING, { Scale = UI_SCALE }); ReopenBtn.Visible = false
    end
end

MinBtn.MouseButton1Click:Connect(function()
    PlayClickEffect(MinBtn); task.wait(0.1); SetMinimized(true)
end)
CloseBtn.MouseButton1Click:Connect(function()
    PlayClickEffect(CloseBtn); task.wait(0.15)
    Explorer.running = false
    if Farming.active then exStopFarming() end
    exStopFlight(true)
    ConnMgr.purge(); ScreenGui:Destroy()
end)

do
    local dragging, moved = false, false
    local startInput, startPos
    ReopenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            startInput = input.Position; startPos = ReopenBtn.Position
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
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
            Ghost.Position = newPos
            GhostAura.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end))
    ConnMgr.add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

ConnMgr.add(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then SetMinimized(not minimized) end
end))

-- ═══════════════════════════════════════════════════════════════
--   INIT
-- ═══════════════════════════════════════════════════════════════
Tween(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = UI_SCALE })
task.delay(0.3, function()
    Notify("👻 v13.0 ULTIMATE", "Teleport Grab 100% Ready!", PALETTE.Toxic, "👻")
    Notify("Explorer", "Server spawn scanner active", PALETTE.Witch, "🌸")
    Notify("Farm", "Teleport → Escape → Orbit ∞", PALETTE.Pumpkin, "🔁")
end)

print("[GhostUI v13.0] ULTIMATE — Teleport Grab 100% | Noclip | Orbit Farm | Explorer")
