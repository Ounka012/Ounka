-- ═══════════════════════════════════════════════
-- OUNCOPYBARA PINK - SIMPLE EDITION
-- Delta Tested
-- ═══════════════════════════════════════════════

print(">>> START <<<")

-- 1) SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

print(">>> Services OK")

-- 2) GUI PARENT - ប្រើ PlayerGui ដែល Delta គាំទ្រ 100%
local playerGui = LP:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("PlayerGui not found!")
    return
end

print(">>> PlayerGui OK")

-- 3) CREATE GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OuncopybaraSimple"
gui.Parent = playerGui
gui.ResetOnSpawn = false

print(">>> ScreenGui OK")

-- 4) FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.5, -150, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2.5
stroke.Color = Color3.fromRGB(255, 105, 180)
stroke.Parent = frame

print(">>> Frame OK")

-- 5) TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
title.BorderSizePixel = 0
title.Text = "  🌟 OUNCOPYBARA PINK"
title.TextColor3 = Color3.fromRGB(255, 182, 193)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 10)
tCorner.Parent = title

-- 6) HIDE BUTTON
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 30, 0, 30)
hideBtn.Position = UDim2.new(1, -74, 0, 6)
hideBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 140)
hideBtn.Text = "–"
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 18
hideBtn.Parent = title

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 6)
hCorner.Parent = hideBtn

-- 7) CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = title

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 6)
cCorner.Parent = closeBtn

print(">>> Title + Buttons OK")

-- 8) DRAG
local dragging, dragStart, startPos
title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement 
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 9) BUTTONS
local function makeBtn(y, txt, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -30, 0, 45)
    b.Position = UDim2.new(0, 15, 0, y)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b
    return b
end

local btnBase = makeBtn(55, "📍 កំណត់ Base", Color3.fromRGB(255, 105, 180))
local btnGo = makeBtn(108, "🚀 ហោះទៅ Base", Color3.fromRGB(138, 43, 226))
local btnAuto = makeBtn(161, "⚡ AUTO: OFF", Color3.fromRGB(60, 30, 45))
local btnTest = makeBtn(214, "🧪 Test TP", Color3.fromRGB(80, 80, 120))

print(">>> Buttons OK")

-- 10) STATUS
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 20)
status.Position = UDim2.new(0, 15, 1, -24)
status.BackgroundTransparency = 1
status.Text = "សូមកំណត់ Base"
status.TextColor3 = Color3.fromRGB(255, 220, 235)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

-- 11) FLOAT BUTTON
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 55, 0, 55)
floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
floatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
floatBtn.Text = "🌟"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 22
floatBtn.Visible = false
floatBtn.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(1, 0)
fCorner.Parent = floatBtn

local fStroke = Instance.new("UIStroke")
fStroke.Thickness = 2.5
fStroke.Color = Color3.fromRGB(255, 200, 220)
fStroke.Parent = floatBtn

-- 12) DRAG FLOAT
local fdrag, fdragStart, fstartPos, fmoved
floatBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        fdrag = true
        fdragStart = inp.Position
        fstartPos = floatBtn.Position
        fmoved = false
    end
end)
UIS.InputChanged:Connect(function(inp)
    if fdrag and (inp.UserInputType == Enum.UserInputType.MouseMovement 
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - fdragStart
        if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then fmoved = true end
        floatBtn.Position = UDim2.new(
            fstartPos.X.Scale, fstartPos.X.Offset + d.X,
            fstartPos.Y.Scale, fstartPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        fdrag = false
    end
end)

-- 13) HIDE/SHOW
hideBtn.Activated:Connect(function()
    frame.Visible = false
    floatBtn.Visible = true
end)

floatBtn.Activated:Connect(function()
    if not fmoved then
        floatBtn.Visible = false
        frame.Visible = true
    end
end)

closeBtn.Activated:Connect(function()
    gui:Destroy()
end)

-- 14) TP FUNCTION
local BaseCFrame = nil
local Auto = false
local Busy = false

local function doTP(cf)
    if not cf then return false end
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local ok = pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        hrp.CFrame = cf
    end)
    return ok
end

local function setStatus(t, c)
    status.Text = t
    status.TextColor3 = c or Color3.fromRGB(255, 220, 235)
    print("[STATUS]", t)
end

-- 15) BASE BUTTON
btnBase.Activated:Connect(function()
    print(">>> Clicked Set Base")
    local char = LP.Character
    if not char then 
        setStatus("❌ No character", Color3.fromRGB(255,100,100))
        return 
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        BaseCFrame = hrp.CFrame
        setStatus(string.format("✅ Base saved: %.0f,%.0f,%.0f", 
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z),
            Color3.fromRGB(100,255,150))
    else
        setStatus("❌ No HRP", Color3.fromRGB(255,100,100))
    end
end)

-- 16) GO BASE BUTTON
btnGo.Activated:Connect(function()
    print(">>> Clicked Go Base")
    if not BaseCFrame then
        setStatus("❌ Set Base first!", Color3.fromRGB(255,100,100))
        return
    end
    local ok = doTP(BaseCFrame)
    if ok then
        setStatus("🚀 Teleported!", Color3.fromRGB(200,150,255))
    else
        setStatus("❌ TP failed", Color3.fromRGB(255,100,100))
    end
end)

-- 17) TEST BUTTON
btnTest.Activated:Connect(function()
    print(">>> Clicked Test")
    if not BaseCFrame then
        setStatus("❌ Set Base first!", Color3.fromRGB(255,100,100))
        return
    end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local orig = hrp.CFrame
    setStatus("🧪 Testing...", Color3.fromRGB(200,200,100))
    doTP(BaseCFrame)
    task.wait(0.5)
    doTP(orig)
    setStatus("✅ Test done", Color3.fromRGB(100,255,150))
end)

-- 18) AUTO BUTTON + HOOKS
local hooked = {}

local function hookPrompt(p)
    if hooked[p] then return end
    hooked[p] = true
    p.Triggered:Connect(function(plr)
        if plr == LP and Auto and BaseCFrame and not Busy then
            Busy = true
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local orig = hrp.CFrame
                    task.spawn(function()
                        doTP(BaseCFrame)
                        task.wait(0.15)
                        doTP(orig)
                        task.wait(0.05)
                        Busy = false
                    end)
                end
            end
        end
    end)
end

local function hookClick(c)
    if hooked[c] then return end
    hooked[c] = true
    c.MouseClick:Connect(function(plr)
        if plr == LP and Auto and BaseCFrame and not Busy then
            -- same as prompt
        end
    end)
end

local function scanAll()
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
    print(">>> Scanned:", n)
    return n
end

workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then hookPrompt(o) end
    if o:IsA("ClickDetector") then hookClick(o) end
end)

btnAuto.Activated:Connect(function()
    print(">>> Clicked Auto")
    if not BaseCFrame then
        setStatus("❌ Set Base first!", Color3.fromRGB(255,100,100))
        return
    end
    Auto = not Auto
    if Auto then
        btnAuto.Text = "⚡ AUTO: ON"
        btnAuto.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        setStatus("✅ AUTO ON", Color3.fromRGB(100,255,150))
        task.spawn(function()
            while Auto and gui.Parent do
                pcall(scanAll)
                task.wait(2)
            end
        end)
    else
        btnAuto.Text = "⚡ AUTO: OFF"
        btnAuto.BackgroundColor3 = Color3.fromRGB(60, 30, 45)
        setStatus("⏸ AUTO OFF", Color3.fromRGB(255,182,193))
    end
end)

-- 19) KEYBOARD TOGGLE
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        if frame.Visible then
            frame.Visible = false
            floatBtn.Visible = true
        else
            floatBtn.Visible = false
            frame.Visible = true
        end
    end
end)

-- 20) INITIAL SCAN
task.spawn(function()
    task.wait(1)
    pcall(scanAll)
end)

print("═════════════════════════════════════")
print(">>> ✅ LOADED SUCCESSFULLY <<<")
print("═════════════════════════════════════")
setStatus("✅ Loaded! ចុច 📍 Set Base", Color3.fromRGB(100,255,150))