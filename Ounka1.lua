--[[
    ╔══════════════════════════════════════════════════════════╗
    ║  ADVANCED EGG STEAL FRAMEWORK v3.0                       ║
    ║  Multi-Vector Bypass System                              ║
    ║  Educational Purpose Only                                ║
    ╚══════════════════════════════════════════════════════════╝
--]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- [ CONFIGURATION ]
-- ═══════════════════════════════════════════════════════════
local CFG = {
    -- Core
    BaseCFrame          = nil,
    AutoMode            = false,
    
    -- Timing (កែឲ្យត្រូវនឹង game)
    PromptHoldBegin     = 0.0,    -- ពេលចាប់ផ្ដើម hold
    PromptHoldEnd       = 0.01,   -- ពេលបញ្ចប់ hold
    ReturnDelay         = 0.15,   -- ពេលនៅ Base
    
    -- Bypass Switches
    UseNetworkHijack    = true,   -- ប្រើ SetNetworkOwner
    UseVelocityBoost    = false,  -- ប្រើ physics thay teleport
    UseLagSwitch        = false,  -- ប្រើ lag (គ្រោះថ្នាក់)
    UsePromptSniper     = true,   -- FireServer ពីចម្ងាយ
    
    -- Detection Avoidance
    JitterRange         = 0.5,    -- Random ចម្ងាយបន្តិច
    MaxTeleportsPerSec  = 4,      -- Rate limit
}

-- ═══════════════════════════════════════════════════════════
-- [ UTILITY LAYER ]
-- ═══════════════════════════════════════════════════════════
local Util = {}

function Util.getChar()
    local char = LP.Character
    if not char then return nil, nil end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

function Util.getHRP()
    local hrp = Util.getChar()
    return hrp
end

function Util.zeroVelocity(hrp)
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

function Util.jitterCFrame(cf)
    -- បន្ថែម random offset តូច ដើម្បីកុំឲ្យ pattern ដូចគ្នា
    local j = CFG.JitterRange
    local offset = Vector3.new(
        (math.random() - 0.5) * j,
        0,
        (math.random() - 0.5) * j
    )
    return cf + offset
end

-- ═══════════════════════════════════════════════════════════
-- [ MODULE 1 : NETWORK OWNERSHIP HIJACK ]
-- ដណ្តើម network ownership → server មិនកែតម្រូវ position
-- ═══════════════════════════════════════════════════════════
local NetworkHijack = {}

function NetworkHijack.claim()
    if not CFG.UseNetworkHijack then return false end
    local hrp = Util.getHRP()
    if not hrp then return false end
    
    local ok = pcall(function()
        hrp:SetNetworkOwner(LP)
    end)
    return ok
end

function NetworkHijack.release()
    local hrp = Util.getHRP()
    if not hrp then return end
    pcall(function()
        hrp:SetNetworkOwner(nil)  -- ត្រឡប់ទៅ server
    end)
end

-- ═══════════════════════════════════════════════════════════
-- [ MODULE 2 : INSTANT TELEPORT (ជាមួយ anti-detect) ]
-- ═══════════════════════════════════════════════════════════
local Teleport = {}

function Teleport.instant(targetCFrame)
    local hrp = Util.getHRP()
    if not hrp then return end
    
    pcall(function()
        Util.zeroVelocity(hrp)
        hrp.CFrame = Util.jitterCFrame(targetCFrame)
        Util.zeroVelocity(hrp)
    end)
end

function Teleport.velocityBoost(targetPosition)
    -- ជំនួស teleport ដោយ physics velocity
    -- server ឃើញជា "ហោះលឿន" មិនមែន "warp"
    local hrp = Util.getHRP()
    if not hrp then return end
    
    pcall(function()
        local delta = targetPosition - hrp.Position
        local dist  = delta.Magnitude
        if dist < 1 then return end
        
        -- ល្បឿនគ្រប់គ្រាន់ក្នុង 1 frame (60 FPS)
        local speed = dist * 60
        -- Cap ដើម្បីកុំឲ្យលើស threshold
        speed = math.min(speed, 500)
        
        hrp.AssemblyLinearVelocity = delta.Unit * speed
    end)
end

-- ═══════════════════════════════════════════════════════════
-- [ MODULE 3 : PROMPT SNIPER ]
-- FireServer ដោយផ្ទាល់ ដោយមិនទៅដល់ទីតាំង
-- ═══════════════════════════════════════════════════════════
local PromptSniper = {}

function PromptSniper.fire(prompt)
    -- ប្រើ InputHoldBegin/End ដែល engine handle ជំនួស
    pcall(function()
        if prompt.HoldDuration > 0 then
            prompt:InputHoldBegin()
            task.wait(CFG.PromptHoldEnd)
            prompt:InputHoldEnd()
        else
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end)
end

function PromptSniper.fireAllEggPrompts()
    local fired = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and PromptSniper.isEggPrompt(v) then
            PromptSniper.fire(v)
            fired += 1
        end
    end
    return fired
end

function PromptSniper.isEggPrompt(prompt)
    local name = prompt.Name:lower()
    local parentName = prompt.Parent and prompt.Parent.Name:lower() or ""
    return name:find("egg") 
        or name:find("collect") 
        or parentName:find("egg")
        or name:find("hatch")
end

-- ═══════════════════════════════════════════════════════════
-- [ MODULE 4 : REMOTE SPY (ស្វែងរក remote event) ]
-- ═══════════════════════════════════════════════════════════
local RemoteSpy = {}

function RemoteSpy.scanRemotes()
    local remotes = {}
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("egg") or n:find("collect") 
               or n:find("hatch") or n:find("steal") then
                table.insert(remotes, v)
            end
        end
    end
    return remotes
end

function RemoteSpy.tryFire(remote, ...)
    if not remote then return end
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- [ MODULE 5 : RATE LIMITER ]
-- ═══════════════════════════════════════════════════════════
local RateLimiter = {
    timestamps = {},
}

function RateLimiter.canProceed()
    local now = tick()
    -- លុប timestamp ចាស់ជាង 1 វិនាទី
    local newList = {}
    for _, t in ipairs(RateLimiter.timestamps) do
        if now - t < 1 then table.insert(newList, t) end
    end
    RateLimiter.timestamps = newList
    
    if #RateLimiter.timestamps >= CFG.MaxTeleportsPerSec then
        return false
    end
    table.insert(RateLimiter.timestamps, now)
    return true
end

-- ═══════════════════════════════════════════════════════════
-- [ ORCHESTRATOR : 5-VECTOR STEAL SEQUENCE ]
-- ═══════════════════════════════════════════════════════════
local Orchestrator = {}
local isBusy = false

function Orchestrator.executeSteal(prompt)
    if isBusy then return end
    if not CFG.BaseCFrame then return end
    if not RateLimiter.canProceed() then return end
    
    isBusy = true
    
    task.spawn(function()
        local hrp = Util.getHRP()
        if not hrp then isBusy = false; return end
        
        -- ចាប់យកទីតាំងបច្ចុប្បន្ន
        local originalCF = hrp.CFrame
        
        -- ── VECTOR 1: ដណ្តើម Network Ownership ──
        NetworkHijack.claim()
        
        -- ── VECTOR 2: Fire Prompt ពីចម្ងាយ (លឿនបំផុត) ──
        if CFG.UsePromptSniper and prompt then
            PromptSniper.fire(prompt)
        end
        
        -- ── VECTOR 3: Teleport ទៅ Base ──
        Teleport.instant(CFG.BaseCFrame)
        
        -- ── VECTOR 4: Velocity Boost (ស្រេចចិត្ត) ──
        if CFG.UseVelocityBoost then
            Teleport.velocityBoost(CFG.BaseCFrame.Position)
        end
        
        -- ចាំពេលខ្លីឲ្យពងធ្លាក់
        task.wait(CFG.ReturnDelay)
        
        -- ── VECTOR 5: ត្រឡប់មកវិញ ──
        Teleport.instant(originalCF)
        
        -- Restore
        NetworkHijack.release()
        isBusy = false
    end)
end

-- ═══════════════════════════════════════════════════════════
-- [ HOOK LAYER ]
-- ═══════════════════════════════════════════════════════════
local Hooks = {}
local hookedSet = setmetatable({}, {__mode = "k"})

function Hooks.attach(prompt)
    if hookedSet[prompt] then return end
    hookedSet[prompt] = true
    
    pcall(function()
        prompt.Triggered:Connect(function(plr)
            if plr == LP and CFG.AutoMode then
                Orchestrator.executeSteal(prompt)
            end
        end)
    end)
end

function Hooks.scanAndAttach()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and PromptSniper.isEggPrompt(v) then
            Hooks.attach(v)
        end
        if v:IsA("ClickDetector") then
            if not hookedSet[v] then
                hookedSet[v] = true
                pcall(function()
                    v.MouseClick:Connect(function(plr)
                        if plr == LP and CFG.AutoMode then
                            Orchestrator.executeSteal()
                        end
                    end)
                end)
            end
        end
    end
end

-- Watcher: scan រាល់ពេលមាន object ថ្មី
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        if PromptSniper.isEggPrompt(obj) then
            Hooks.attach(obj)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ UI ]
-- ═══════════════════════════════════════════════════════════
local function getGUIParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    ok, hui = pcall(function() return CoreGui end)
    if ok and hui then return hui end
    return LP:WaitForChild("PlayerGui")
end

pcall(function()
    for _, g in pairs(getGUIParent():GetChildren()) do
        if g.Name:find("AdvEggSteal") then g:Destroy() end
    end
end)

local GUI = Instance.new("ScreenGui")
GUI.Name = "AdvEggSteal_v3"
GUI.Parent = getGUIParent()
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 360, 0, 380)
Main.Position = UDim2.new(0.5, -180, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(180, 100, 255)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
Title.BorderSizePixel = 0
Title.Text = "⚡ ADVANCED STEAL v3.0"
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 14)

-- Drag
local dragging, dragStart, startPos
Title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement 
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                   startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Module Toggle Factory
local function makeToggle(y, label, getFn, setFn, defaultColor)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(1, -30, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, y)
    btn.BackgroundColor3 = defaultColor or Color3.fromRGB(40, 25, 55)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local state = Instance.new("TextLabel", btn)
    state.Size = UDim2.new(0, 60, 1, 0)
    state.Position = UDim2.new(1, -65, 0, 0)
    state.BackgroundTransparency = 1
    state.Text = getFn() and "ON" or "OFF"
    state.TextColor3 = getFn() 
        and Color3.fromRGB(100, 255, 150) 
        or Color3.fromRGB(255, 100, 100)
    state.Font = Enum.Font.GothamBlack
    state.TextSize = 11
    state.TextXAlignment = Enum.TextXAlignment.Right
    
    btn.Activated:Connect(function()
        setFn(not getFn())
        local on = getFn()
        state.Text = on and "ON" or "OFF"
        state.TextColor3 = on 
            and Color3.fromRGB(100, 255, 150) 
            or Color3.fromRGB(255, 100, 100)
        btn.BackgroundColor3 = on 
            and Color3.fromRGB(80, 40, 130) 
            or Color3.fromRGB(40, 25, 55)
    end)
    
    return btn, state
end

-- Info Panel
local infoPanel = Instance.new("Frame", Main)
infoPanel.Size = UDim2.new(1, -30, 0, 60)
infoPanel.Position = UDim2.new(0, 15, 0, 55)
infoPanel.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
infoPanel.BorderSizePixel = 0
Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 8)

local infoLabel = Instance.new("TextLabel", infoPanel)
infoLabel.Size = UDim2.new(1, -20, 1, 0)
infoLabel.Position = UDim2.new(0, 10, 0, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "📍 Base: មិនបានកំណត់"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Buttons
local function makeBtn(y, text, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(1, -30, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, y)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local btnSetBase = makeBtn(125, "📍 កំណត់ Base", Color3.fromRGB(120, 60, 200))
local btnAuto    = makeBtn(170, "▶ ចាប់ផ្ដើម AUTO", Color3.fromRGB(200, 50, 130))

-- Module toggles
makeToggle(218, "🕸 Network Hijack", 
    function() return CFG.UseNetworkHijack end,
    function(v) CFG.UseNetworkHijack = v end)

makeToggle(260, "🎯 Prompt Sniper", 
    function() return CFG.UsePromptSniper end,
    function(v) CFG.UsePromptSniper = v end)

makeToggle(302, "🚀 Velocity Boost", 
    function() return CFG.UseVelocityBoost end,
    function(v) CFG.UseVelocityBoost = v end)

-- Status Bar
local status = Instance.new("TextLabel", Main)
status.Size = UDim2.new(1, -30, 0, 25)
status.Position = UDim2.new(0, 15, 1, -30)
status.BackgroundTransparency = 1
status.Text = "ស្រាប់..."
status.TextColor3 = Color3.fromRGB(180, 150, 220)
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left

local function setStatus(text, color)
    status.Text = text
    status.TextColor3 = color or Color3.fromRGB(180, 150, 220)
end

-- ═══════════════════════════════════════════════════════════
-- [ BUTTON LOGIC ]
-- ═══════════════════════════════════════════════════════════
btnSetBase.Activated:Connect(function()
    local hrp = Util.getHRP()
    if hrp then
        CFG.BaseCFrame = hrp.CFrame
        infoLabel.Text = string.format(
            "📍 Base: %.1f, %.1f, %.1f\n🎯 Targets: %d prompts",
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z,
            #PromptSniper.scanRemotes() -- បង្ហាញ remotes ជំនួស
        )
        setStatus("✅ បានកំណត់ Base!", Color3.fromRGB(100, 255, 150))
    end
end)

btnAuto.Activated:Connect(function()
    if not CFG.BaseCFrame then
        setStatus("❌ កំណត់ Base មុន!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    CFG.AutoMode = not CFG.AutoMode
    if CFG.AutoMode then
        btnAuto.Text = "⏸ បញ្ឈប់ AUTO"
        btnAuto.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
        setStatus("✅ AUTO កំពុងដំណើរការ...", Color3.fromRGB(100, 255, 150))
        
        -- ចាប់ផ្ដើម scan loop
        task.spawn(function()
            while CFG.AutoMode and GUI.Parent do
                pcall(Hooks.scanAndAttach)
                task.wait(0.5)
            end
        end)
    else
        btnAuto.Text = "▶ ចាប់ផ្ដើម AUTO"
        btnAuto.BackgroundColor3 = Color3.fromRGB(200, 50, 130)
        setStatus("⏸ បានបញ្ឈប់", Color3.fromRGB(255, 150, 150))
    end
end)

-- Toggle key
UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- ═══════════════════════════════════════════════════════════
-- [ BOOT ]
-- ═══════════════════════════════════════════════════════════
pcall(Hooks.scanAndAttach)

print("╔══════════════════════════════════════╗")
print("║  ADVANCED STEAL v3.0 LOADED          ║")
print("║  Modules: NetworkHijack + Sniper +   ║")
print("║           VelocityBoost              ║")
print("║  Press [RightShift] to toggle UI     ║")
print("╚══════════════════════════════════════╝")