--[[
    ╔══════════════════════════════════════════╗
    ║  STEAL v8 — 10 SLOTS + HIDE/SHOW         ║
    ║  Click slot: Save if empty / Go if saved ║
    ╚══════════════════════════════════════════╝
--]]

print("[v8] Loading...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- ═══════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════
local Config = {
    Slots = {},         -- 10 slots (nil = empty, CFrame = saved)
    ActiveSlot = 1,     -- ដែល AUTO ប្រើ
    Auto = false,
    Delay = 0.15,
    Busy = false,
}

-- Init 10 empty slots
for i = 1, 10 do
    Config.Slots[i] = nil
end

-- ═══════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════
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

-- ═══════════════════════════════════════
-- STEAL LOGIC
-- ═══════════════════════════════════════
local function steal()
    if Config.Busy or not Config.Auto then return end
    local targetCF = Config.Slots[Config.ActiveSlot]
    if not targetCF then return end
    Config.Busy = true
    
    task.spawn(function()
        local hrp = getHRP()
        if not hrp then Config.Busy = false; return end
        
        local orig = hrp.CFrame
        
        pcall(function() hrp:SetNetworkOwner(LP) end)
        teleport(targetCF)
        task.wait(Config.Delay)
        teleport(orig)
        pcall(function() hrp:SetNetworkOwner(nil) end)
        
        Config.Busy = false
    end)
end

-- ═══════════════════════════════════════
-- HOOKS
-- ═══════════════════════════════════════
local hooked = {}

local function hookPrompt(p)
    if hooked[p] then return end
    hooked[p] = true
    pcall(function()
        p.Triggered:Connect(function(plr)
            if plr == LP and Config.Auto then
                print("[v8] Prompt fired!")
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
    print("[v8] Scanned", n, "prompts")
    return n
end

workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then hookPrompt(o) end
    if o:IsA("ClickDetector") then hookClick(o) end
end)

-- ═══════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════
print("[v8] Creating GUI...")

local guiParent = game:GetService("CoreGui")

pcall(function()
    for _, g in pairs(guiParent:GetChildren()) do
        if g.Name == "Steal_v8" then g:Destroy() end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Steal_v8"
gui.Parent = guiParent
gui.ResetOnSpawn = false

-- ════════ MAIN FRAME ════════
local FRAME_W, FRAME_H = 360, 500

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
frame.Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
frame.BackgroundColor3 = Color3.fromRGB(18, 12, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(180, 80, 255)

-- ════════ TITLE BAR ════════
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
title.BorderSizePixel = 0
title.Text = "  ⚡ STEAL v8 — 10 SLOTS"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Minimize
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 30, 0, 30)
btnMin.Position = UDim2.new(1, -74, 0, 6)
btnMin.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
btnMin.Text = "–"
btnMin.TextColor3 = Color3.new(1, 1, 1)
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 20
btnMin.Parent = title
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

-- Close
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

-- ════════ INFO LABEL ════════
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -30, 0, 25)
infoLabel.Position = UDim2.new(0, 15, 0, 45)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "👆 ចុច slot ទទេ = Save | slot មាន = Go"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = frame

-- ════════ SLOT AREA ════════
-- 2 columns × 5 rows
local slotButtons = {}
local slotLabels = {}
local slotClearBtns = {}

local function updateSlotUI(idx)
    local btn = slotButtons[idx]
    local lbl = slotLabels[idx]
    if not btn or not lbl then return end
    
    local cf = Config.Slots[idx]
    if cf then
        lbl.Text = string.format("%d • %.0f, %.0f, %.0f", 
            idx, cf.Position.X, cf.Position.Y, cf.Position.Z)
        btn.BackgroundColor3 = Color3.fromRGB(60, 130, 80)
    else
        lbl.Text = idx .. " • EMPTY"
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    end
    
    -- Highlight active slot
    if idx == Config.ActiveSlot then
        btn.BackgroundColor3 = cf 
            and Color3.fromRGB(100, 200, 130) 
            or Color3.fromRGB(80, 50, 130)
    end
end

local function createSlot(idx, x, y)
    -- Main slot button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 42)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = idx .. " • EMPTY"
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    -- Clear button (small X)
    local cls = Instance.new("TextButton")
    cls.Size = UDim2.new(0, 22, 0, 22)
    cls.Position = UDim2.new(1, -26, 0.5, -11)
    cls.BackgroundColor3 = Color3.fromRGB(255, 80, 100)
    cls.Text = "×"
    cls.TextColor3 = Color3.new(1, 1, 1)
    cls.Font = Enum.Font.GothamBold
    cls.TextSize = 14
    cls.Parent = btn
    Instance.new("UICorner", cls).CornerRadius = UDim.new(0, 4)
    
    slotButtons[idx] = btn
    slotLabels[idx] = lbl
    slotClearBtns[idx] = cls
    
    -- ═══ CLICK SLOT ═══
    btn.Activated:Connect(function()
        local hrp = getHRP()
        if not hrp then return end
        
        if Config.Slots[idx] then
            -- Teleport to slot
            teleport(Config.Slots[idx])
            Config.ActiveSlot = idx
            print("[v8] Teleport to slot", idx)
        else
            -- Save current position
            Config.Slots[idx] = hrp.CFrame
            Config.ActiveSlot = idx
            print("[v8] Saved slot", idx)
        end
        
        -- Update all slots (highlight active)
        for i = 1, 10 do updateSlotUI(i) end
    end)
    
    -- ═══ CLEAR SLOT ═══
    cls.Activated:Connect(function()
        Config.Slots[idx] = nil
        print("[v8] Cleared slot", idx)
        updateSlotUI(idx)
    end)
    
    return btn
end

-- Create 10 slots in grid
local startY = 78
local rowH = 46
local col1X = 15
local col2X = 185

for i = 1, 5 do
    createSlot(i, col1X, startY + (i - 1) * rowH)
end
for i = 6, 10 do
    createSlot(i, col2X, startY + (i - 6) * rowH)
end

-- ════════ BOTTOM CONTROLS ════════
local controlsY = startY + 5 * rowH + 10

-- Active slot display
local activeLabel = Instance.new("TextLabel")
activeLabel.Size = UDim2.new(1, -30, 0, 22)
activeLabel.Position = UDim2.new(0, 15, 0, controlsY)
activeLabel.BackgroundTransparency = 1
activeLabel.Text = "🎯 AUTO target: Slot 1"
activeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
activeLabel.Font = Enum.Font.GothamBold
activeLabel.TextSize = 11
activeLabel.TextXAlignment = Enum.TextXAlignment.Left
activeLabel.Parent = frame

-- Auto button
local btnAuto = Instance.new("TextButton")
btnAuto.Size = UDim2.new(0, 165, 0, 42)
btnAuto.Position = UDim2.new(0, 15, 0, controlsY + 28)
btnAuto.BackgroundColor3 = Color3.fromRGB(200, 50, 130)
btnAuto.BorderSizePixel = 0
btnAuto.Text = "▶ AUTO: OFF"
btnAuto.TextColor3 = Color3.new(1, 1, 1)
btnAuto.Font = Enum.Font.GothamBold
btnAuto.TextSize = 12
btnAuto.Parent = frame
Instance.new("UICorner", btnAuto).CornerRadius = UDim.new(0, 8)

-- Test button
local btnTest = Instance.new("TextButton")
btnTest.Size = UDim2.new(0, 165, 0, 42)
btnTest.Position = UDim2.new(0, 185, 0, controlsY + 28)
btnTest.BackgroundColor3 = Color3.fromRGB(50, 130, 200)
btnTest.BorderSizePixel = 0
btnTest.Text = "🧪 Test Active"
btnTest.TextColor3 = Color3.new(1, 1, 1)
btnTest.Font = Enum.Font.GothamBold
btnTest.TextSize = 12
btnTest.Parent = frame
Instance.new("UICorner", btnTest).CornerRadius = UDim.new(0, 8)

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 40)
status.Position = UDim2.new(0, 15, 1, -45)
status.BackgroundTransparency = 1
status.Text = "ស្រាប់... ចុច slot ដើម្បី save"
status.TextColor3 = Color3.fromRGB(180, 180, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = frame

local function setStatus(t, c)
    status.Text = t
    status.TextColor3 = c or Color3.fromRGB(180, 180, 200)
    print("[v8]", t)
end

-- ════════ FLOATING REOPEN BUTTON ════════
local floatBtn = Instance.new("TextButton")
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

-- ════════ HIDE / SHOW ════════
local function hideUI()
    frame.Visible = false
    floatBtn.Visible = true
    task.spawn(function()
        floatBtn.Size = UDim2.new(0, 0, 0, 0)
        for i = 0, 1, 0.1 do
            floatBtn.Size = UDim2.new(0, 60 * i, 0, 60 * i)
            task.wait(0.02)
        end
        floatBtn.Size = UDim2.new(0, 60, 0, 60)
    end)
end

local function showUI()
    floatBtn.Visible = false
    frame.Visible = true
    task.spawn(function()
        frame.Size = UDim2.new(0, 0, 0, 0)
        for i = 0, 1, 0.1 do
            frame.Size = UDim2.new(0, FRAME_W * i, 0, FRAME_H * i)
            task.wait(0.02)
        end
        frame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
    end)
end

btnMin.Activated:Connect(hideUI)

floatBtn.Activated:Connect(function()
    if not fmoved then showUI() end
end)

btnClose.Activated:Connect(function()
    Config.Auto = false
    gui:Destroy()
    print("[v8] GUI closed")
end)

-- ════════ BUTTON EVENTS ════════
btnAuto.Activated:Connect(function()
    local hasSlot = false
    for i = 1, 10 do
        if Config.Slots[i] then hasSlot = true; break end
    end
    
    if not hasSlot then
        setStatus("❌ Save slot មុន", Color3.fromRGB(255, 100, 100))
        return
    end
    
    Config.Auto = not Config.Auto
    
    if Config.Auto then
        if not Config.Slots[Config.ActiveSlot] then
            -- Find first filled slot
            for i = 1, 10 do
                if Config.Slots[i] then
                    Config.ActiveSlot = i
                    break
                end
            end
        end
        btnAuto.Text = "⏸ AUTO: ON"
        btnAuto.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
        activeLabel.Text = "🎯 AUTO target: Slot " .. Config.ActiveSlot
        setStatus("✅ AUTO ដំណើរការ (Slot " .. Config.ActiveSlot .. ")", 
            Color3.fromRGB(100, 255, 150))
        
        task.spawn(function()
            while Config.Auto and gui.Parent do
                pcall(scanWorld)
                task.wait(2)
            end
        end)
    else
        btnAuto.Text = "▶ AUTO: OFF"
        btnAuto.BackgroundColor3 = Color3.fromRGB(200, 50, 130)
        setStatus("⏸ បានបញ្ឈប់", Color3.fromRGB(255, 150, 150))
    end
end)

btnTest.Activated:Connect(function()
    local cf = Config.Slots[Config.ActiveSlot]
    if not cf then
        setStatus("❌ Slot " .. Config.ActiveSlot .. " ទទេ", 
            Color3.fromRGB(255, 100, 100))
        return
    end
    local hrp = getHRP()
    if hrp then
        local orig = hrp.CFrame
        teleport(cf)
        task.wait(0.5)
        teleport(orig)
        setStatus("✅ Test Slot " .. Config.ActiveSlot, 
            Color3.fromRGB(100, 255, 150))
    end
end)

-- ════════ KEYBOARD ════════
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        if frame.Visible then hideUI() else showUI() end
    end
end)

-- ════════ INIT ════════
for i = 1, 10 do updateSlotUI(i) end

task.spawn(function()
    task.wait(0.5)
    pcall(scanWorld)
end)

print("═══════════════════════════════════════")
print("[v8] ✅ LOADED — 10 SLOTS")
print("[v8] ចុច slot ទទេ = Save")
print("[v8] ចុច slot មាន = Teleport")
print("[v8] ចុច [×] = Clear slot")
print("[v8] ចុច [–] = លាក់ UI")
print("[v8] ចុច [⚡] = បើកវិញ")
print("═══════════════════════════════════════")

setStatus("✅ Loaded! ចុច slot ដើម្បី save", Color3.fromRGB(100, 255, 150))