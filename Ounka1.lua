-- =========================================================================
-- [ 🌟 OUNCOPYBARA PINK NEON - FULL EDITION v10 🌟 ]
-- [ Delta Compatible | Robust TP | Hide/Show | Auto Steal ]
-- =========================================================================

local success, err = pcall(function()

-- ═══════════════════════════════════════════════════════════
-- [ SERVICES ]
-- ═══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

print("═══════════════════════════════════════")
print("🌟 OUNCOPYBARA PINK NEON v10 LOADING...")
print("═══════════════════════════════════════")

-- ═══════════════════════════════════════════════════════════
-- [ CONFIG ]
-- ═══════════════════════════════════════════════════════════
local Config = {
    BaseCFrame    = nil,
    FastStealOn   = false,
    isProcessing  = false,
    TeleportDelay = 0.15,
    ReturnWait    = 0.05,
}

-- ═══════════════════════════════════════════════════════════
-- [ HELPERS ]
-- ═══════════════════════════════════════════════════════════
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- ═══════════════════════════════════════════════════════════
-- [ ROBUST TELEPORT — 5 Methods Fallback ]
-- ═══════════════════════════════════════════════════════════
local function instantTeleport(targetCFrame)
    if not targetCFrame then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not hrp then return false end
    if hum and hum.Health <= 0 then return false end
    
    -- ── Method 1: CFrame + Zero Velocity (សំខាន់បំផុត)
    local ok1 = pcall(function()
        hrp.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
    
    if ok1 and hrp.Parent then
        return true
    end
    
    -- ── Method 2: Position only
    local ok2 = pcall(function()
        hrp.Position = targetCFrame.Position
    end)
    
    if ok2 and hrp.Parent then
        return true
    end
    
    -- ── Method 3: PivotTo
    local ok3 = pcall(function()
        char:PivotTo(targetCFrame)
    end)
    
    if ok3 then
        return true
    end
    
    -- ── Method 4: SetPrimaryPartCFrame (legacy)
    local ok4 = pcall(function()
        char:SetPrimaryPartCFrame(targetCFrame)
    end)
    
    if ok4 then
        return true
    end
    
    -- ── Method 5: MoveTo (slow but reliable)
    pcall(function()
        if hum then
            hum:MoveTo(targetCFrame.Position)
        end
    end)
    
    return false
end

-- ═══════════════════════════════════════════════════════════
-- [ STEAL LOGIC ]
-- ═══════════════════════════════════════════════════════════
local function handleSteal()
    if not Config.FastStealOn or not Config.BaseCFrame or Config.isProcessing then 
        return 
    end
    
    local hrp = getHRP()
    if not hrp then return end
    
    Config.isProcessing = true
    local OriginalCF = hrp.CFrame
    
    task.spawn(function()
        -- Try network ownership (best effort)
        pcall(function()
            hrp:SetNetworkOwner(LocalPlayer)
        end)
        
        -- Go to base
        instantTeleport(Config.BaseCFrame)
        task.wait(Config.TeleportDelay)
        
        -- Return
        instantTeleport(OriginalCF)
        
        -- Release ownership
        pcall(function()
            if hrp and hrp.Parent then
                hrp:SetNetworkOwner(nil)
            end
        end)
        
        task.wait(Config.ReturnWait)
        Config.isProcessing = false
    end)
end

-- ═══════════════════════════════════════════════════════════
-- [ HOOK PROMPTS ]
-- ═══════════════════════════════════════════════════════════
local hooked = {}

local function hookPrompt(p)
    if hooked[p] then return end
    hooked[p] = true
    pcall(function()
        p.Triggered:Connect(function(plr)
            if plr == LocalPlayer and Config.FastStealOn then
                handleSteal()
            end
        end)
    end)
end

local function hookClick(c)
    if hooked[c] then return end
    hooked[c] = true
    pcall(function()
        c.MouseClick:Connect(function(plr)
            if plr == LocalPlayer and Config.FastStealOn then
                handleSteal()
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
    return n
end

workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then hookPrompt(o) end
    if o:IsA("ClickDetector") then hookClick(o) end
end)

-- ═══════════════════════════════════════════════════════════
-- [ GUI PARENT ]
-- ═══════════════════════════════════════════════════════════
local function getGUIParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GUIParent = getGUIParent()

pcall(function()
    for _, gui in pairs(GUIParent:GetChildren()) do
        if gui.Name == "Ouncopybara_Pink_v10" then gui:Destroy() end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ SCREEN GUI ]
-- ═══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ouncopybara_Pink_v10"
ScreenGui.Parent = GUIParent
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ═══════════════════════════════════════════════════════════
-- [ MAIN FRAME ]
-- ═══════════════════════════════════════════════════════════
local FRAME_W, FRAME_H = 300, 280

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
MainFrame.Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
MainFrame.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2.5
UIStroke.Color = Color3.fromRGB(255, 105, 180)

-- ── Neon Glow Animation
task.spawn(function()
    while MainFrame and MainFrame.Parent do
        for i = 0, 1, 0.05 do
            if not MainFrame or not MainFrame.Parent then return end
            UIStroke.Color = Color3.fromRGB(255, 105, 180):Lerp(
                Color3.fromRGB(255, 200, 220), math.sin(i * math.pi))
            task.wait(0.03)
        end
        for i = 0, 1, 0.05 do
            if not MainFrame or not MainFrame.Parent then return end
            UIStroke.Color = Color3.fromRGB(255, 200, 220):Lerp(
                Color3.fromRGB(255, 105, 180), math.sin(i * math.pi))
            task.wait(0.03)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ TITLE BAR ]
-- ═══════════════════════════════════════════════════════════
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
TitleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -110, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🌟 OUNCOPYBARA PINK"
TitleText.TextColor3 = Color3.fromRGB(255, 182, 193)
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 12
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- ── Hide button (–)
local HideBtn = Instance.new("TextButton", TitleBar)
HideBtn.Name = "HideBtn"
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -74, 0, 6)
HideBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 140)
HideBtn.Text = "–"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
HideBtn.AutoButtonColor = true

local hideCorner = Instance.new("UICorner", HideBtn)
hideCorner.CornerRadius = UDim.new(0, 6)

-- ── Close button (X)
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14

local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- ═══════════════════════════════════════════════════════════
-- [ DRAG MAIN FRAME ]
-- ═══════════════════════════════════════════════════════════
local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging   = true
        dragStart  = inp.Position
        startPos   = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (
        inp.UserInputType == Enum.UserInputType.MouseMovement 
        or inp.UserInputType == Enum.UserInputType.Touch
    ) then
        local d = inp.Position - dragStart
        MainFrame.Position = UDim2.new(
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

-- ═══════════════════════════════════════════════════════════
-- [ BUTTONS ]
-- ═══════════════════════════════════════════════════════════
local function createButton(yPos, text, bgColor)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -30, 0, 45)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = bgColor
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 8)
    
    return btn
end

local btnSetBase   = createButton(55,  "📍 កំណត់ទីតាំង Base", Color3.fromRGB(255, 105, 180))
local btnGoToBase  = createButton(108, "🚀 ហោះទៅ Base",       Color3.fromRGB(138, 43, 226))
local btnFastSteal = createButton(161, "⚡ លួចពងលឿន VIP: OFF", Color3.fromRGB(60, 30, 45))
local btnTest      = createButton(214, "🧪 សាកល្បង TP",        Color3.fromRGB(80, 80, 120))

-- ═══════════════════════════════════════════════════════════
-- [ STATUS LABEL ]
-- ═══════════════════════════════════════════════════════════
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -30, 0, 20)
StatusLabel.Position = UDim2.new(0, 15, 1, -24)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "សូមកំណត់ទីតាំង Base ជាមុន"
StatusLabel.TextColor3 = Color3.fromRGB(255, 220, 235)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true

local function setStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(255, 220, 235)
    print("[STEAL]", text)
end

-- ═══════════════════════════════════════════════════════════
-- [ FLOATING REOPEN BUTTON ]
-- ═══════════════════════════════════════════════════════════
local floatBtn = Instance.new("TextButton", ScreenGui)
floatBtn.Name = "FloatBtn"
floatBtn.Size = UDim2.new(0, 55, 0, 55)
floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
floatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
floatBtn.Text = "🌟"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Font = Enum.Font.GothamBlack
floatBtn.TextSize = 22
floatBtn.Visible = false
floatBtn.AutoButtonColor = false

local floatCorner = Instance.new("UICorner", floatBtn)
floatCorner.CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Thickness = 2.5
floatStroke.Color = Color3.fromRGB(255, 200, 220)

-- ── Neon Glow on Float Button
task.spawn(function()
    while floatBtn and floatBtn.Parent do
        if floatBtn.Visible then
            for i = 0, 1, 0.1 do
                if not floatBtn or not floatBtn.Parent or not floatBtn.Visible then 
                    break 
                end
                floatStroke.Color = Color3.fromRGB(255, 105, 180):Lerp(
                    Color3.fromRGB(255, 200, 220), math.sin(i * math.pi))
                task.wait(0.03)
            end
            for i = 0, 1, 0.1 do
                if not floatBtn or not floatBtn.Parent or not floatBtn.Visible then 
                    break 
                end
                floatStroke.Color = Color3.fromRGB(255, 200, 220):Lerp(
                    Color3.fromRGB(255, 105, 180), math.sin(i * math.pi))
                task.wait(0.03)
            end
        else
            task.wait(0.1)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ DRAG FLOAT BUTTON ]
-- ═══════════════════════════════════════════════════════════
local fdrag, fdragStart, fstartPos, fmoved

floatBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        fdrag      = true
        fdragStart = inp.Position
        fstartPos  = floatBtn.Position
        fmoved     = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if fdrag and (
        inp.UserInputType == Enum.UserInputType.MouseMovement 
        or inp.UserInputType == Enum.UserInputType.Touch
    ) then
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
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        fdrag = false
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ HIDE / SHOW LOGIC ]
-- ═══════════════════════════════════════════════════════════
local function hideUI()
    MainFrame.Visible = false
    floatBtn.Visible = true
    task.spawn(function()
        floatBtn.Size = UDim2.new(0, 0, 0, 0)
        for i = 0, 1, 0.1 do
            if not floatBtn or not floatBtn.Parent then return end
            floatBtn.Size = UDim2.new(0, 55*i, 0, 55*i)
            task.wait(0.02)
        end
        if floatBtn then
            floatBtn.Size = UDim2.new(0, 55, 0, 55)
        end
    end)
end

local function showUI()
    floatBtn.Visible = false
    MainFrame.Visible = true
    task.spawn(function()
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        for i = 0, 1, 0.1 do
            if not MainFrame or not MainFrame.Parent then return end
            MainFrame.Size = UDim2.new(0, FRAME_W*i, 0, FRAME_H*i)
            task.wait(0.02)
        end
        if MainFrame then
            MainFrame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
        end
    end)
end

HideBtn.Activated:Connect(hideUI)

floatBtn.Activated:Connect(function()
    if not fmoved then
        showUI()
    end
end)

CloseBtn.Activated:Connect(function()
    Config.FastStealOn = false
    ScreenGui:Destroy()
    print("[STEAL] GUI closed")
end)

-- ═══════════════════════════════════════════════════════════
-- [ BUTTON EVENTS ]
-- ═══════════════════════════════════════════════════════════
btnSetBase.Activated:Connect(function()
    local hrp = getHRP()
    if hrp then
        Config.BaseCFrame = hrp.CFrame
        setStatus(string.format("✅ Base: %.0f, %.0f, %.0f",
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z),
            Color3.fromRGB(100, 255, 150))
    else
        setStatus("❌ Character មិនទាន់ load", Color3.fromRGB(255, 100, 100))
    end
end)

btnGoToBase.Activated:Connect(function()
    if not Config.BaseCFrame then
        setStatus("❌ សូមកំណត់ទីតាំងសិន!", Color3.fromRGB(255, 50, 100))
        return
    end
    local ok = instantTeleport(Config.BaseCFrame)
    if ok then
        setStatus("🚀 បានហោះមកដល់!", Color3.fromRGB(200, 150, 255))
    else
        setStatus("❌ TP បរាជ័យ — សាកម្ដងទៀត", Color3.fromRGB(255, 100, 100))
    end
end)

btnTest.Activated:Connect(function()
    if not Config.BaseCFrame then
        setStatus("❌ កំណត់ Base មុន", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local hrp = getHRP()
    if not hrp then 
        setStatus("❌ រកមិនឃើញ HRP", Color3.fromRGB(255, 100, 100))
        return 
    end
    
    setStatus("🧪 កំពុងសាក...", Color3.fromRGB(200, 200, 100))
    local orig = hrp.CFrame
    
    task.spawn(function()
        instantTeleport(Config.BaseCFrame)
        task.wait(0.5)
        instantTeleport(orig)
        setStatus("✅ Test ជោគជ័យ!", Color3.fromRGB(100, 255, 150))
    end)
end)

btnFastSteal.Activated:Connect(function()
    if not Config.BaseCFrame then
        setStatus("❌ សូមកំណត់ទីតាំងសិន!", Color3.fromRGB(255, 50, 100))
        return
    end

    Config.FastStealOn = not Config.FastStealOn
    
    if Config.FastStealOn then
        btnFastSteal.Text = "⚡ លួចពងលឿន VIP: ON"
        btnFastSteal.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        setStatus("✅ បើកមុខងារយកពងលឿន VIP!", Color3.fromRGB(100, 255, 150))

        -- Auto-scan loop
        task.spawn(function()
            while Config.FastStealOn and ScreenGui.Parent do
                pcall(scanWorld)
                task.wait(2)
            end
        end)
    else
        btnFastSteal.Text = "⚡ លួចពងលឿន VIP: OFF"
        btnFastSteal.BackgroundColor3 = Color3.fromRGB(60, 30, 45)
        setStatus("🛑 បានបិទមុខងារយកពងលឿន", Color3.fromRGB(255, 182, 193))
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ KEYBOARD TOGGLE ]
-- ═══════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        if MainFrame.Visible then
            hideUI()
        else
            showUI()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ CHARACTER RESPAWN HANDLER ]
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    print("[STEAL] Character respawned")
    task.wait(1)
    -- បន្ថែម hooks សម្រាប់ character ថ្មី
    pcall(scanWorld)
end)

-- ═══════════════════════════════════════════════════════════
-- [ INITIAL SCAN ]
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(0.5)
    local n = pcall(scanWorld)
    print("[STEAL] Initial scan done")
e