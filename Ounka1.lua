--[[
    ═══════════════════════════════════════════════════════════
      ⚡ MKRA TELEPORT GUI
    ═══════════════════════════════════════════════════════════
]]

local Players         = game:GetService("Players")
local Workspace       = game:GetService("Workspace")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════ SETTINGS ═══════════════
local Settings = {
    TeleportDelay   = 0.1,
    HomePosition    = nil,
    AutoCollect     = false,
    AutoReturn      = false,
    AutoSave        = true,
    Debug           = true,
}

-- ═══════════════ RUNTIME ═══════════════
local Runtime = {
    IsReturning = false,
}

local function log(...)
    if Settings.Debug then print("[TP]", ...) end
end

local function getChar() return LocalPlayer.Character end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function safeCall(fn, ...) local ok, e = pcall(fn, ...); return ok, e end

-- ═══════════════ SAVE/LOAD ═══════════════
local function cframeToTable(cf)
    if not cf then return nil end
    return {cf:GetComponents()}
end
local function tableToCFrame(t)
    if not t or #t < 12 then return nil end
    return CFrame.new(unpack(t))
end

local function saveConfig()
    if not (writefile and Settings.AutoSave) then return end
    safeCall(function()
        local data = {}
        for k,v in pairs(Settings) do
            if k ~= "HomePosition" then data[k] = v end
        end
        data.HomePosition = Settings.HomePosition
        writefile("MKRA_TP.json", game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function loadConfig()
    if not (isfile and readfile) then return end
    if not isfile("MKRA_TP.json") then return end
    safeCall(function()
        local data = game:GetService("HttpService"):JSONDecode(readfile("MKRA_TP.json"))
        for k,v in pairs(data) do
            if Settings[k] ~= nil then Settings[k] = v end
        end
    end)
end

loadConfig()

-- ═══════════════ 📍 Set Home ═══════════════
local function saveHome()
    local hrp = getHRP()
    if hrp then
        Settings.HomePosition = cframeToTable(hrp.CFrame)
        saveConfig()
        log("✅ Home saved")
        return true
    end
    log("❌ រកមិនឃើញ HRP")
    return false
end

-- ═══════════════ 🏠 Go Home ═══════════════
local function goHome()
    local hrp = getHRP()
    local cf = tableToCFrame(Settings.HomePosition)
    if hrp and cf then
        hrp.CFrame = cf
        log("✅ Teleported home")
        return true
    end
    return false
end

-- ═══════════════ 🥚 Find Egg ═══════════════
local function findEgg()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("steal") or n:find("ពង") 
               or n:find("crate") or n:find("gacha") then
                return obj
            end
        elseif obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local t = ((obj.ActionText or "") .. " " .. (obj.ObjectText or "")):lower()
                if t:find("egg") or t:find("steal") or t:find("hatch") then
                    return parent
                end
            end
        elseif obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("steal") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then return part end
            end
        end
    end
    return nil
end

-- ═══════════════ ⚡ Collect ═══════════════
local function collectEgg(eggPart)
    local hrp = getHRP()
    if not hrp or not eggPart or not eggPart.Parent then return false end

    local homeCF = tableToCFrame(Settings.HomePosition) or hrp.CFrame

    -- Teleport to egg
    safeCall(function()
        hrp.CFrame = CFrame.new(eggPart.Position + Vector3.new(0, 3, 0))
    end)
    task.wait(Settings.TeleportDelay)

    -- Click
    safeCall(function()
        for _, prompt in ipairs(eggPart:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end
        if firetouchinterest then
            firetouchinterest(hrp, eggPart, 0)
            task.wait(0.03)
            firetouchinterest(hrp, eggPart, 1)
        end
        for _, cd in ipairs(eggPart:GetDescendants()) do
            if cd:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(cd)
            end
        end
    end)

    task.wait(Settings.TeleportDelay)

    -- Teleport back
    safeCall(function()
        hrp.CFrame = homeCF
    end)

    return true
end

-- ═══════════════ ⚡ Auto Collect Loop ═══════════════
task.spawn(function()
    while task.wait(0.3) do
        if Settings.AutoCollect and not Runtime.IsReturning then
            local egg = findEgg()
            if egg then
                Runtime.IsReturning = true
                safeCall(collectEgg, egg)
                task.wait(0.2)
                Runtime.IsReturning = false
            end
        end
    end
end)

-- ═══════════════ ⚡ Auto Return ═══════════════
local function isHoldingEgg()
    local char = getChar()
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local n = child.Name:lower()
            if n:find("egg") or n:find("steal") then return true end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoReturn and Settings.HomePosition and not Runtime.IsReturning then
            if isHoldingEgg() then
                local hrp = getHRP()
                local cf = tableToCFrame(Settings.HomePosition)
                if hrp and cf then
                    hrp.CFrame = cf
                    log("⚡ Auto Return")
                end
                task.wait(0.5)
            end
        end
    end
end)

-- ═══════════════ DRAG HELPER ═══════════════
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ═══════════════ 🎨 GUI CREATION ═══════════════
local function createUI()
    if CoreGui:FindFirstChild("MKRA_TP_UI") then
        CoreGui.MKRA_TP_UI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MKRA_TP_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    -- Floating Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, -26)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(24,14,32)
    ToggleBtn.Text = "⚡"
    ToggleBtn.TextColor3 = Color3.fromRGB(255,200,100)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 28
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ScreenGui
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local ts = Instance.new("UIStroke")
    ts.Color = Color3.fromRGB(255,170,60); ts.Thickness = 2
    ts.Parent = ToggleBtn
    makeDraggable(ToggleBtn)

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 320, 0, 420)
    Main.Position = UDim2.new(0.5, -160, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(16,10,20)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Visible = false
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
    local ms = Instance.new("UIStroke")
    ms.Color = Color3.fromRGB(255,170,60); ms.Thickness = 1.5
    ms.Transparency = 0.4; ms.Parent = Main

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,20,40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

    local TitleTxt = Instance.new("TextLabel")
    TitleTxt.Size = UDim2.new(1, -90, 1, 0)
    TitleTxt.Position = UDim2.new(0, 16, 0, 0)
    TitleTxt.BackgroundTransparency = 1
    TitleTxt.Text = "⚡ TELEPORT HUB"
    TitleTxt.TextColor3 = Color3.fromRGB(255,200,100)
    TitleTxt.Font = Enum.Font.GothamBold
    TitleTxt.TextSize = 14
    TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
    TitleTxt.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,90)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    makeDraggable(Main, TitleBar)
    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -24, 1, -60)
    Content.Position = UDim2.new(0, 12, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(255,170,60)
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = Content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = Scroll

    -- Helpers
    local function addLabel(text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -6, 0, 22)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(255,200,140)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = Scroll
    end

    local function addButton(text, cb, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 38)
        btn.BackgroundColor3 = color or Color3.fromRGB(80,50,30)
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = Scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            local orig = btn.BackgroundColor3
            btn.BackgroundColor3 = Color3.fromRGB(255,220,100)
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = orig}):Play()
            cb()
        end)
    end

    local function addToggle(text, default, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 38)
        btn.BackgroundColor3 = default and Color3.fromRGB(255,140,30) or Color3.fromRGB(34,22,42)
        btn.Text = "  "..text.."  —  "..(default and "ON" or "OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = Scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = "  "..text.."  —  "..(state and "ON" or "OFF")
            TweenService:Create(btn, TweenInfo.new(0.2),
                {BackgroundColor3 = state and Color3.fromRGB(255,140,30) or Color3.fromRGB(34,22,42)}):Play()
            cb(state)
        end)
    end

    local function addTextBox(label, default, cb)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 38)
        frame.BackgroundColor3 = Color3.fromRGB(34,22,42)
        frame.Parent = Scroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.55, -10, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(255,200,140)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.4, 0, 0.7, 0)
        box.Position = UDim2.new(0.58, 0, 0.15, 0)
        box.BackgroundColor3 = Color3.fromRGB(18,10,22)
        box.TextColor3 = Color3.new(1,1,1)
        box.Text = tostring(default)
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.Parent = frame
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        box.FocusLost:Connect(function() cb(box.Text) end)
    end

    -- ═══════════ CONTENT ═══════════
    addLabel("📍  HOME POSITION")
    addButton("📍 កំណត់ទីតាំងកំណត់ (Set Home)", function()
        if saveHome() then
            ToggleBtn.Text = "⚡"
        end
    end, Color3.fromRGB(60,120,180))

    addButton("🏠 តេឡេផតទៅកន្លែងកំណត់ (Go Home)", function()
        goHome()
    end, Color3.fromRGB(60,140,90))

    addLabel("⚡  AUTO COLLECT")
    addToggle("⚡ Auto Egg Steal", Settings.AutoCollect, function(v)
        Settings.AutoCollect = v
        log("AutoCollect:", v)
    end)

    addToggle("🔄 Auto Return ពេលកាន់ពង", Settings.AutoReturn, function(v)
        Settings.AutoReturn = v
        log("AutoReturn:", v)
    end)

    addTextBox("Teleport Delay", Settings.TeleportDelay, function(v)
        Settings.TeleportDelay = tonumber(v) or 0.1
    end)

    addLabel("🎛️  TOOLS")
    addButton("⚡ យកពងម្ដង (Collect Once)", function()
        local egg = findEgg()
        if egg then
            safeCall(collectEgg, egg)
        end
    end, Color3.fromRGB(150,80,60))

    addButton("🔍 រកមើលពង (Find Egg)", function()
        local egg = findEgg()
        if egg then
            log("រកឃើញ:", egg.Name)
        else
            log("❌ រកមិនឃើញពង")
        end
    end, Color3.fromRGB(100,80,140))

    addToggle("🐛 Debug Log", Settings.Debug, function(v)
        Settings.Debug = v
    end)

    print("[MKRA] ⚡ Teleport GUI Ready")
    print("   ចុចរូប ⚡ ដើម្បីបើក UI")
end

createUI()