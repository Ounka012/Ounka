--[[
    ╔══════════════════════════════════════════╗
    ║  STEAL GUI v7 — មានប៊ូតុងលាក់/បើក      ║
    ╚══════════════════════════════════════════╝
--]]

print("[v7] Loading...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Config = {
    Base = nil,
    Auto = false,
    Delay = 0.15,
    Busy = false,
}

-- ═══ HELPERS ═══
local function getHRP()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function teleport(cf)
    local hrp = getHRP()
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
end

-- ═══ STEAL LOGIC ═══
local function steal()
    if Config.Busy or not Config.Base or not Config.Auto then return end
    Config.Busy = true
    
    task.spawn(function()
        local hrp = getHRP()
        if not hrp then Config.Busy = false; return end
        
        local orig = hrp.CFrame
        
        pcall(function() hrp:SetNetworkOwner(LP) end)
        teleport(Config.Base)
        task.wait(Config.Delay)
        teleport(orig)
        pcall(function() hrp:SetNetworkOwner(nil) end)
        
        Config.Busy = false
    end)
end

-- ═══ HOOKS ═══
local hooked = {}

local function hookPrompt(p)
    if hooked[p] then return end
    hooked[p] = true
    pcall(function()
        p.Triggered:Connect(function(plr)
            if plr == LP and Config.Auto then
                print("[v7] Prompt fired!")
                steal()
            end
        end)
    end)
end

local function hookClick(c)
    if hooked[c] then return end
    hooked[c] = true
    pcall(function()
        c.MouseClick:Connect(function(plr)
            if plr == LP and Config.Auto then
                steal()
            end
        end)
    end)
end

local function scanWorld()
    local n = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            hookPrompt(v)
            n = n + 1
        elseif v:IsA("ClickDetector") then
            hookClick(v)
            n = n + 1
        end
    end
    print("[v7] Scanned", n, "prompts")
    return n
end

workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then hookPrompt(o) end
    if o:IsA("ClickDetector") then hookClick(o) end
end)

-- ═══ GUI ═══
print("[v7] Creating GUI...")

local guiParent = game:GetService("CoreGui")

pcall(function()
    for _, g in pairs(guiParent:GetChildren()) do
        if g.Name == "Steal_v7" then g:Destroy() end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Steal_v7"
gui.Parent = guiParent
gui.ResetOnSpawn = false

-- ════════ MAIN FRAME ════════
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 340)
frame.Position = UDim2.new(0.5, -160, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(18, 12, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(180, 80, 255)

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
title.BorderSizePixel = 0
title.Text = "  ⚡ STEAL v7"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- ════════ BUTTON លាក់ (–) ════════
local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 30, 0, 30)
btnMinimize.Position = UDim2.new(1, -74, 0, 6)
btnMinimize.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
btnMinimize.Text = "–"
btnMinimize.TextColor3 = Color3.new(1, 1, 1)
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.TextSize = 20
btnMinimize.Parent = title
Instance.new("UICorner", btnMinimize).CornerRadius = UDim.new(0, 6)

-- ════════ BUTTON បិទ (X) ════════
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -38, 0, 6)
btnClose.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
btnClose.Text = "X"
btnClose.TextColor3 = Color3.new(1, 1, 1)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 14
btnClose.Parent = title
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)

-- ════════ FLOATING REOPEN BUTTON (ពេលលាក់) ════════
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "FloatBtn"
floatBtn.Size = UDim2.new(0, 60, 0, 60)
floatBtn.Position = UDim2.new(0, 20, 0.5, -30)
floatBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
floatBtn.Text = "⚡"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Font = Enum.Font.GothamBlack
floatBtn.TextSize = 24
floatBtn.Visible = false
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Thickness = 3
floatStroke.Color = Color3.fromRGB(255, 200, 255)

-- ════════ DRAG MAIN FRAME ════════
local dragging, dragStart, startPos
title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or 
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or 
                     inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or 
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ════════ DRAG FLOAT BUTTON ════════
local fdrag, fdragStart, fstartPos, fmoved
floatBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or 
       inp.UserInputType == Enum.UserInputType.Touch then
        fdrag = true
        fdragStart = inp.Position
        fstartPos = floatBtn.Position
        fmoved = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if fdrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or 
                  inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - fdragStart
        if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then
            fmoved = true
        end
        floatBtn.Position = UDim2.new(
            fstartPos.X.Scale, fstartPos.X.Offset + d.X,
            fstartPos.Y.Scale, fstartPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or 
       inp.UserInputType == Enum.UserInputType.Touch then
        fdrag = false
    end
end)

-- ════════ HIDE / SHOW LOGIC ════════
local function hideUI()
    frame.Visible = false
    floatBtn.Visible = true
    -- Animation
    floatBtn.Size = UDim2.new(0, 0, 0, 0)
    task.spawn(function()
        for i = 0, 1, 0.1 do
            floatBtn.Size = UDim2.new(0, 60 * i, 0, 60 * i)
            task.wait(0.02)
        end
        floatBtn.Size = UDim2.new(0, 60, 0, 60)
    end)
    print("[v7] UI hidden")
end

local function showUI()
    floatBtn.Visible = false
    frame.Visible = true
    frame.Size = UDim2.new(0, 0, 0, 0)
    task.spawn(function()
        for i = 0, 1, 0.1 do
            frame.Size = UDim2.new(0, 320 * i, 0, 340 * i)
            task.wait(0.02)
        end
        frame.Size = UDim2.new(0, 320, 0, 340)
    end)
    print("[v7] UI shown")
end

btnMinimize.Activated:Connect(hideUI)

floatBtn.Activated:Connect(function()
    if not fmoved then
        showUI()
    end
end)

btnClose.Activated:Connect(function()
    Config.Auto = false
    gui:Destroy()
    print("[v7] GUI closed")
end)

-- ════════ BUTTONS ════════
local function mkBtn(y, text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -30, 0, 45)
    b.Position = UDim2.new(0, 15, 0, y)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnBase = mkBtn(55, "📍 កំណត់ Base", Color3.fromRGB(120, 60, 200))
local btnTest = mkBtn(110, "🧪 សាកល្បង", Color3.fromRGB(50, 130, 200))
local btnAuto = mkBtn(165, "▶ ចាប់ផ្ដើម AUTO", Color3.fromRGB(200, 50, 130))
local btnScan = mkBtn(220, "🔍 Scan", Color3.fromRGB(80, 80, 100))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 50)
status.Position = UDim2.new(0, 15, 1, -60)
status.BackgroundTransparency = 1
status.Text = "សូមកំណត់ Base មុន"
status.TextColor3 = Color3.fromRGB(180, 180, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = frame

local function setStatus(t, c)
    status.Text = t
    status.TextColor3 = c or Color3.fromRGB(180, 180, 200)
    print("[v7]", t)
end

-- ════════ BUTTON EVENTS ════════
btnBase.Activated:Connect(function()
    print("[v7] Set Base clicked")
    local hrp = getHRP()
    if hrp then
        Config.Base = hrp.CFrame
        setStatus(string.format("✅ Base: %.0f, %.0f, %.0f",
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z),
            Color3.fromRGB(100, 255, 150))
    else
        setStatus("❌ Character មិនទាន់ load", Color3.fromRGB(255, 100, 100))
    end
end)

btnTest.Activated:Connect(function()
    print("[v7] Test clicked")
    if not Config.Base then
        setStatus("❌ កំណត់ Base មុន", Color3.fromRGB(255, 100, 100))
        return
    end
    local hrp = getHRP()
    if hrp then
        local orig = hrp.CFrame
        teleport(Config.Base)
        task.wait(0.5)
        teleport(orig)
        setStatus("✅ Test ជោគជ័យ", Color3.fromRGB(100, 255, 150))
    end
end)

btnScan.Activated:Connect(function()
    print("[v7] Scan clicked")
    local n = scanWorld()
    setStatus("✅ ឃើញ " .. n .. " prompts", Color3.fromRGB(150, 200, 255))
end)

btnAuto.Activated:Connect(function()
    print("[v7] Auto clicked")
    if not Config.Base then
        setStatus("❌ កំណត់ Base មុន", Color3.fromRGB(255, 100, 100))
        return
    end
    
    Config.Auto = not Config.Auto
    
    if Config.Auto then
        btnAuto.Text = "⏸ បញ្ឈប់ AUTO"
        btnAuto.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
        setStatus("✅ AUTO ដំណើរការ", Color3.fromRGB(100, 255, 150))
        
        task.spawn(function()
            while Config.Auto and gui.Parent do
                pcall(scanWorld)
                task.wait(2)
            end
        end)
    else
        btnAuto.Text = "▶ ចាប់ផ្ដើម AUTO"
        btnAuto.BackgroundColor3 = Color3.fromRGB(200, 50, 130)
        setStatus("⏸ បានបញ្ឈប់", Color3.fromRGB(255, 150, 150))
    end
end)

-- ════════ KEYBOARD TOGGLE ════════
-- RightShift = លាក់/បើក UI
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        if frame.Visible then
            hideUI()
        else
            showUI()
        end
    end
end)

-- ════════ INIT ════════
task.spawn(function()
    task.wait(0.5)
    pcall(scanWorld)
end)

print("═══════════════════════════════")
print("[v7] ✅ LOADED")
print("[v7] ចុច [–] ដើម្បីលាក់")
print("[v7] ចុច [⚡] ដើម្បីបើកវិញ")
print("[v7] ចុច [RightShift] toggle")
print("═══════════════════════════════")

setStatus("✅ Loaded! ចុច [–] ដើម្បីលាក់", Color3.fromRGB(100, 255, 150))