--[[
    ╔══════════════════════════════════════════╗
    ║  DELTA-OPTIMIZED EGG STEAL v5.0          ║
    ║  Tested on Delta Free & Premium         ║
    ╚══════════════════════════════════════════╝
--]]

print("═══════════════════════════════")
print("[DELTA STEAL] Loading...")

-- ═══ SERVICES ═══
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

print("[DELTA STEAL] Player:", LP.Name)

-- ═══ CONFIG ═══
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
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
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
        
        -- Network ownership
        pcall(function() hrp:SetNetworkOwner(LP) end)
        
        -- Go to Base
        teleport(Config.Base)
        task.wait(Config.Delay)
        
        -- Return
        teleport(orig)
        
        -- Release ownership
        pcall(function() hrp:SetNetworkOwner(nil) end)
        
        Config.Busy = false
    end)
end

-- ═══ HOOK PROMPTS (DELTA-COMPATIBLE) ═══
-- ចំណុចសំខាន់: Delta មិនអនុញ្ញាត InputHoldBegin 
-- ដូច្នេះយើងចាប់តែ Triggered event

local hooked = {}

local function hookPrompt(p)
    if hooked[p] then return end
    hooked[p] = true
    
    pcall(function()
        p.Triggered:Connect(function(plr)
            if plr == LP and Config.Auto then
                print("[DELTA STEAL] Triggered!")
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
    print("[DELTA STEAL] Scanned:", n)
    return n
end

-- Watch new objects
workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then hookPrompt(o) end
    if o:IsA("ClickDetector") then hookClick(o) end
end)

-- ═══ GUI (DELTA-SAFE) ═══
print("[DELTA STEAL] Creating GUI...")

-- Delta: ប្រើ CoreGui ផ្ទាល់ ព្រោះ gethui មិនដើរ
local function getParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local parent = getParent()

-- Cleanup old
pcall(function()
    for _, g in pairs(parent:GetChildren()) do
        if g.Name == "DeltaSteal_v5" then g:Destroy() end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaSteal_v5"
gui.Parent = parent
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 330, 0, 330)
frame.Position = UDim2.new(0.5, -165, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(18, 12, 24)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(180, 80, 255)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
title.BorderSizePixel = 0
title.Text = "⚡ DELTA STEAL v5"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Close btn
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = title
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.Activated:Connect(function()
    Config.Auto = false
    gui:Destroy()
end)

-- Drag
local dragging, dragStart, startPos
title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement 
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Button factory
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

local btnBase  = mkBtn(55, "📍 កំណត់ Base", Color3.fromRGB(120, 60, 200))
local btnTest  = mkBtn(110, "🧪 សាកល្បងទៅ Base", Color3.fromRGB(50, 130, 200))
local btnAuto  = mkBtn(165, "▶ ចាប់ផ្ដើម AUTO", Color3.fromRGB(200, 50, 130))
local btnScan  = mkBtn(220, "🔍 Scan Prompts", Color3.fromRGB(80, 80, 100))

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 40)
status.Position = UDim2.new(0, 15, 1, -50)
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
    print("[DELTA STEAL]", t)
end

-- ═══ BUTTON EVENTS ═══
btnBase.Activated:Connect(function()
    print("[DELTA STEAL] Set Base clicked")
    local hrp = getHRP()
    if hrp then
        Config.Base = hrp.CFrame
        setStatus(string.format("✅ Base: %.0f, %.0f, %.0f",
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z), 
            Color3.fromRGB(100, 255, 150))
    else
        setStatus("❌ Character មិនទាន់ load!", Color3.fromRGB(255, 100, 100))
    end
end)

btnTest.Activated:Connect(function()
    print("[DELTA STEAL] Test clicked")
    if not Config.Base then
        setStatus("❌ កំណត់ Base មុន!", Color3.fromRGB(255, 100, 100))
        return
    end
    local hrp = getHRP()
    if hrp then
        local orig = hrp.CFrame
        teleport(Config.Base)
        task.wait(0.5)
        teleport(orig)
        setStatus("✅ Test ជោគជ័យ!", Color3.fromRGB(100, 255, 150))
    else
        setStatus("❌ រកមិនឃើញ HRP!", Color3.fromRGB(255, 100, 100))
    end
end)

btnScan.Activated:Connect(function()
    print("[DELTA STEAL] Scan clicked")
    local n = scanWorld()
    setStatus("✅ ឃើញ " .. n .. " prompts", Color3.fromRGB(150, 200, 255))
end)

btnAuto.Activated:Connect(function()
    print("[DELTA STEAL] Auto clicked")
    if not Config.Base then
        setStatus("❌ កំណត់ Base មុន!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    Config.Auto = not Config.Auto
    
    if Config.Auto then
        btnAuto.Text = "⏸ បញ្ឈប់ AUTO"
        btnAuto.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
        setStatus("✅ AUTO កំពុងដំណើរការ", Color3.fromRGB(100, 255, 150))
        
        -- Auto scan loop
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

-- Toggle key (Delta supports)
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

-- ═══ INIT ═══
task.spawn(function()
    task.wait(0.5)
    pcall(scanWorld)
end)

print("[DELTA STEAL] ✅ LOADED SUCCESSFULLY")
setStatus("✅ Script loaded!", Color3.fromRGB(100, 255, 150))