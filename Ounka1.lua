--[[
    ╔═══════════════════════════════════════════╗
    ║  DELTA FREE — BULLETPROOF STEAL v6.0      ║
    ║  No blocked functions                     ║
    ╚═══════════════════════════════════════════╝
--]]

-- STEP 1: Test basic print
print("╔════════════════════════════════════╗")
print("║ STEP 1: Script loading...          ║")
print("╚════════════════════════════════════╝")

-- STEP 2: Services (all safe)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

print("STEP 2: Services loaded ✓")

-- STEP 3: LocalPlayer
local LP = Players.LocalPlayer
print("STEP 3: Player =", LP.Name, "✓")

-- STEP 4: Config
local Config = {
    Base = nil,
    Auto = false,
    Delay = 0.15,
    Busy = false,
}
print("STEP 4: Config ready ✓")

-- STEP 5: Helper functions
local function getHRP()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function teleport(cf)
    local hrp = getHRP()
    if not hrp then return false end
    local ok = pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
    return ok
end
print("STEP 5: Helpers ready ✓")

-- STEP 6: Steal logic
local function steal()
    if Config.Busy or not Config.Base or not Config.Auto then return end
    Config.Busy = true
    
    task.spawn(function()
        local hrp = getHRP()
        if not hrp then 
            Config.Busy = false
            return 
        end
        
        local orig = hrp.CFrame
        
        -- SetNetworkOwner (safe on Delta)
        pcall(function()
            hrp:SetNetworkOwner(LP)
        end)
        
        teleport(Config.Base)
        task.wait(Config.Delay)
        teleport(orig)
        
        pcall(function()
            hrp:SetNetworkOwner(nil)
        end)
        
        Config.Busy = false
    end)
end
print("STEP 6: Steal logic ready ✓")

-- STEP 7: Hook prompts (Delta-safe: Triggered only)
local hooked = {}

local function hookPrompt(p)
    if hooked[p] then return end
    hooked[p] = true
    pcall(function()
        p.Triggered:Connect(function(plr)
            if plr == LP and Config.Auto then
                print("[STEAL] Prompt fired!")
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
                print("[STEAL] Click fired!")
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
    print("[STEAL] Scanned", n, "prompts")
    return n
end

workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then hookPrompt(o) end
    if o:IsA("ClickDetector") then hookClick(o) end
end)
print("STEP 7: Hooks ready ✓")

-- STEP 8: GUI (ONLY CoreGui — no gethui)
print("STEP 8: Creating GUI...")

local guiParent = game:GetService("CoreGui")

-- Cleanup
pcall(function()
    for _, g in pairs(guiParent:GetChildren()) do
        if g.Name == "DeltaSteal_v6" then 
            g:Destroy() 
        end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaSteal_v6"
gui.Parent = guiParent
gui.ResetOnSpawn = false
print("  → ScreenGui created ✓")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 340)
frame.Position = UDim2.new(0.5, -160, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(18, 12, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
print("  → Frame created ✓")

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(180, 80, 255)
stroke.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
title.BorderSizePixel = 0
title.Text = "⚡ DELTA STEAL v6"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Drag
local dragging = false
local dragStart = nil
local startPos = nil

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
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = b
    return b
end

local btnBase = mkBtn(55, "📍 កំណត់ Base", Color3.fromRGB(120, 60, 200))
local btnTest = mkBtn(110, "🧪 សាកល្បងទៅ Base", Color3.fromRGB(50, 130, 200))
local btnAuto = mkBtn(165, "▶ ចាប់ផ្ដើម AUTO", Color3.fromRGB(200, 50, 130))
local btnScan = mkBtn(220, "🔍 Scan", Color3.fromRGB(80, 80, 100))

-- Status
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
    print("[STEAL] Status:", t)
end

print("  → GUI created fully ✓")

-- STEP 9: Button events
btnBase.Activated:Connect(function()
    print("[STEAL] Button: Set Base clicked")
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
    print("[STEAL] Button: Test clicked")
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
    else
        setStatus("❌ រកមិនឃើញ HRP", Color3.fromRGB(255, 100, 100))
    end
end)

btnScan.Activated:Connect(function()
    print("[STEAL] Button: Scan clicked")
    local n = scanWorld()
    setStatus("✅ ឃើញ " .. n .. " prompts", Color3.fromRGB(150, 200, 255))
end)

btnAuto.Activated:Connect(function()
    print("[STEAL] Button: Auto clicked")
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

print("STEP 9: Buttons connected ✓")

-- STEP 10: Toggle key
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

-- STEP 11: Initial scan
task.spawn(function()
    task.wait(0.5)
    pcall(scanWorld)
end)

print("╔════════════════════════════════════╗")
print("║ ✅ v6 LOADED SUCCESSFULLY          ║")
print("║ Press RightShift to toggle         ║")
print("╚════════════════════════════════════╝")
setStatus("✅ Script loaded!", Color3.fromRGB(100, 255, 150))