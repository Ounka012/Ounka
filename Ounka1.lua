-- =====================================================================
-- [ ouncopybara UI - Advanced Pro: Fly + Auto Egg + Sort (700K+ & 1000m+) ]
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- កំណត់ Parent GUI 
-- ============================================================
local function getParent()
    if gethui then 
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    if get_hidden_gui then
        local ok, hg = pcall(get_hidden_gui)
        if ok and hg then return hg end
    end
    local cg = game:GetService("CoreGui")
    local ok = pcall(function() local t = Instance.new("Folder"); t.Parent = cg; t:Destroy() end)
    if ok then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local parentGui = getParent()
pcall(function()
    for _, gui in pairs(parentGui:GetChildren()) do
        if gui.Name == "RoxnameFlyUI" then gui:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoxnameFlyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

local glowingTexts = {}

-- ============================================================
-- អនុគមន៍ជំនួយ (Draggable)
-- ============================================================
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true
            dragStart = input.Position
            startPos = frame.Position 
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
end

-- =====================================================================
-- 1. FLOATING BUTTONS & MAIN WINDOWS
-- =====================================================================
local OpenFrame = Instance.new("Frame")
OpenFrame.Size = UDim2.new(0, 45, 0, 45)
OpenFrame.Position = UDim2.new(0, 20, 0.5, -45)
OpenFrame.BackgroundColor3 = Color3.fromRGB(45, 20, 35)
OpenFrame.Visible = false
OpenFrame.Parent = ScreenGui
Instance.new("UICorner", OpenFrame).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenFrame).Color = Color3.fromRGB(255, 105, 180)
makeDraggable(OpenFrame)

local OpenBtn = Instance.new("TextButton", OpenFrame)
OpenBtn.Size = UDim2.new(1, 0, 1, 0)
OpenBtn.BackgroundTransparency = 1
OpenBtn.Text = "✈️"
OpenBtn.TextSize = 20

local EggOpenFrame = Instance.new("Frame")
EggOpenFrame.Size = UDim2.new(0, 45, 0, 45)
EggOpenFrame.Position = UDim2.new(0, 20, 0.5, 15)
EggOpenFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
EggOpenFrame.Visible = false
EggOpenFrame.Parent = ScreenGui
Instance.new("UICorner", EggOpenFrame).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", EggOpenFrame).Color = Color3.fromRGB(255, 20, 147)
makeDraggable(EggOpenFrame)

local EggOpenBtnFloat = Instance.new("TextButton", EggOpenFrame)
EggOpenBtnFloat.Size = UDim2.new(1, 0, 1, 0)
EggOpenBtnFloat.BackgroundTransparency = 1
EggOpenBtnFloat.Text = "🍀"
EggOpenBtnFloat.TextSize = 20

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 490) 
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -245)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 105, 180)
makeDraggable(MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -70, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "ouncopybara | Fly UI (Pro)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
table.insert(glowingTexts, Title)

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -62, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local EggWindow = Instance.new("Frame")
EggWindow.Size = UDim2.new(0, 310, 0, 420)
EggWindow.Position = UDim2.new(0.5, 160, 0.5, -210)
EggWindow.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
EggWindow.Visible = false
EggWindow.Parent = ScreenGui
Instance.new("UICorner", EggWindow).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", EggWindow).Color = Color3.fromRGB(255, 20, 147)
makeDraggable(EggWindow)

local EggTitle = Instance.new("TextLabel", EggWindow)
EggTitle.Size = UDim2.new(1, -70, 0, 30)
EggTitle.Position = UDim2.new(0, 15, 0, 5)
EggTitle.BackgroundTransparency = 1
EggTitle.Text = "🍀 បញ្ជីពង (Luck & KG ធំលើគេ)"
EggTitle.Font = Enum.Font.GothamBold
EggTitle.TextSize = 12
EggTitle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(glowingTexts, EggTitle)

local EggMinBtn = Instance.new("TextButton", EggWindow)
EggMinBtn.Size = UDim2.new(0, 24, 0, 24)
EggMinBtn.Position = UDim2.new(1, -62, 0, 8)
EggMinBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
EggMinBtn.Text = "_"
EggMinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", EggMinBtn).CornerRadius = UDim.new(0, 6)

local EggCloseBtn = Instance.new("TextButton", EggWindow)
EggCloseBtn.Size = UDim2.new(0, 24, 0, 24)
EggCloseBtn.Position = UDim2.new(1, -32, 0, 8)
EggCloseBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147)
EggCloseBtn.Text = "✕"
EggCloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", EggCloseBtn).CornerRadius = UDim.new(0, 6)

local EggInfoBar = Instance.new("TextLabel", EggWindow)
EggInfoBar.Size = UDim2.new(1, -30, 0, 20)
EggInfoBar.Position = UDim2.new(0, 15, 0, 38)
EggInfoBar.BackgroundTransparency = 1
EggInfoBar.Text = "ស្វែងរកពង 🍀700K+ និង >1000m..."
EggInfoBar.Font = Enum.Font.Gotham
EggInfoBar.TextSize = 10
EggInfoBar.TextXAlignment = Enum.TextXAlignment.Left
table.insert(glowingTexts, EggInfoBar)

local EggListScroll = Instance.new("ScrollingFrame", EggWindow)
EggListScroll.Size = UDim2.new(1, -30, 1, -75)
EggListScroll.Position = UDim2.new(0, 15, 0, 62)
EggListScroll.BackgroundColor3 = Color3.fromRGB(25, 10, 20)
EggListScroll.BorderSizePixel = 0
EggListScroll.ScrollBarThickness = 4
Instance.new("UICorner", EggListScroll).CornerRadius = UDim.new(0, 6)

-- តម្រៀបតាមឈ្មោះ (Name) ព្រោះ LayoutOrder អត់អាចដាក់លេខធំៗដល់ Billion បានទេ
local UIListLayout = Instance.new("UIListLayout", EggListScroll)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
    EggListScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10) 
end)

-- =====================================================================
-- 2. កំណត់តម្លៃ UI ចម្បង
-- =====================================================================
local function createSettings(yPos, labelText, defaultVal)
    local Label = Instance.new("TextLabel", MainFrame)
    Label.Size = UDim2.new(0, 240, 0, 15)
    Label.Position = UDim2.new(0, 20, 0, yPos)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(glowingTexts, Label)

    local Box = Instance.new("TextBox", MainFrame)
    Box.Size = UDim2.new(0, 140, 0, 30)
    Box.Position = UDim2.new(0, 70, 0, yPos + 18)
    Box.BackgroundColor3 = Color3.fromRGB(55, 20, 40)
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 14
    Box.Text = tostring(defaultVal)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Box).Color = Color3.fromRGB(255, 105, 180)
    return Box
end

local SpeedBox = createSettings(40, "ល្បឿនហោះទូទៅ (Fly Speed):", 100)
local currentSpeedValue = 100
SpeedBox.FocusLost:Connect(function() currentSpeedValue = tonumber(SpeedBox.Text) or 100; SpeedBox.Text = tostring(currentSpeedValue) end)

local FlyBtn = Instance.new("TextButton", MainFrame)
FlyBtn.Size = UDim2.new(0, 240, 0, 38)
FlyBtn.Position = UDim2.new(0, 20, 0, 210)
FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
FlyBtn.Text = "ចាប់ផ្ដើមហោះ (FLY ON)"
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 13
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 6)

local NoclipBtn = Instance.new("TextButton", MainFrame)
NoclipBtn.Size = UDim2.new(0, 240, 0, 38)
NoclipBtn.Position = UDim2.new(0, 20, 0, 253)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147)
NoclipBtn.Text = "ឆ្លុះជញ្ជាំង (NOCLIP OFF)"
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.TextSize = 13
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 6)

local OpenEggListBtn = Instance.new("TextButton", MainFrame)
OpenEggListBtn.Size = UDim2.new(0, 240, 0, 38)
OpenEggListBtn.Position = UDim2.new(0, 20, 0, 296)
OpenEggListBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
OpenEggListBtn.Text = "🍀 បើកបញ្ជីពង (OPEN EGG LIST)"
OpenEggListBtn.Font = Enum.Font.GothamBold
OpenEggListBtn.TextSize = 13
Instance.new("UICorner", OpenEggListBtn).CornerRadius = UDim.new(0, 6)

local EggStatusLabel = Instance.new("TextLabel", MainFrame)
EggStatusLabel.Size = UDim2.new(0, 240, 0, 60)
EggStatusLabel.Position = UDim2.new(0, 20, 0, 360)
EggStatusLabel.BackgroundTransparency = 1
EggStatusLabel.Text = "ស្ថានភាព: រង់ចាំបញ្ជា..."
EggStatusLabel.Font = Enum.Font.Gotham
EggStatusLabel.TextSize = 11
EggStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- =====================================================================
-- 3. Fly & Noclip Logic 
-- =====================================================================
local isFlying, isNoclip = false, false
local flyLoop, noclipLoop, bodyVelocity, bodyGyro

local function stopFly()
    isFlying = false
    FlyBtn.Text = "ចាប់ផ្ដើមហោះ (FLY ON)"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    if flyLoop then flyLoop:Disconnect(); flyLoop = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.PlatformStand = false 
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    isFlying = true
    FlyBtn.Text = "បញ្ឈប់ហោះ (FLY OFF)"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(199, 21, 133)
    hum.PlatformStand = true
    
    bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 3000

    flyLoop = RunService.RenderStepped:Connect(function()
        if not isFlying or hum.Health <= 0 then stopFly(); return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = Camera.CFrame.LookVector * (moveDir.Z * -currentSpeedValue) + Camera.CFrame.RightVector * (moveDir.X * currentSpeedValue)
        else 
            bodyVelocity.Velocity = Vector3.new(0, 0, 0) 
        end
        bodyGyro.CFrame = Camera.CFrame
    end)
end
FlyBtn.Activated:Connect(function() if isFlying then stopFly() else startFly() end end)

local function toggleNoclip()
    isNoclip = not isNoclip
    if isNoclip then
        NoclipBtn.Text = "កំពុងឆ្លុះជញ្ជាំង (NOCLIP ON)"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(199, 21, 133)
        noclipLoop = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then 
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end 
                end 
            end
        end)
    else 
        NoclipBtn.Text = "ឆ្លុះជញ្ជាំង (NOCLIP OFF)"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147)
        if noclipLoop then noclipLoop:Disconnect(); noclipLoop = nil end
    end
end
NoclipBtn.Activated:Connect(function() toggleNoclip() end)

-- =====================================================================
-- 4. Advanced Egg Scanner (LUCK 700K+ & KG Sort & 1000m+ Filter)
-- =====================================================================
local isEggList = false
local espObjects = {}
local espLoopConn, espScanThread, espAddedConn

local function setStatus(text) EggStatusLabel.Text = "ស្ថានភាព: " .. text end

-- អនុគមន៍បំលែងលុយសម្រាប់បង្ហាញ
local function formatNumber(n)
    if n >= 1e12 then return string.format("%.2fT", n/1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(n) end
end

-- អនុគមន៍ទាញយក Luck និង KG ពីក្នុងពង
local function getEggStats(eggModel)
    local maxLuck = 0
    local maxKg = 0
    
    local function processString(s)
        if not s then return end
        s = string.upper(string.gsub(s, ",", ""))
        
        -- ទាញយកទម្ងន់ KG
        local kMatch = string.match(s, "([%d%.]+)%s*KG")
        if kMatch then maxKg = math.max(maxKg, tonumber(kMatch) or 0) end
        
        -- ទាញយកសំណាង (Luck) ដោយកាត់ពាក្យ KG ចោល
        local sNoKg = string.gsub(s, "[%d%.]+%s*KG", "")
        local numStr, suffix = string.match(sNoKg, "([%d%.]+)([KMBT])")
        if numStr then
            local num = tonumber(numStr)
            if num then
                if suffix == "K" then num = num * 1e3
                elseif suffix == "M" then num = num * 1e6
                elseif suffix == "B" then num = num * 1e9
                elseif suffix == "T" then num = num * 1e12 end
                maxLuck = math.max(maxLuck, num)
            end
        else
            local plainNum = string.match(sNoKg, "(%d+)")
            if plainNum then
                maxLuck = math.max(maxLuck, tonumber(plainNum) or 0)
            end
        end
    end

    processString(eggModel.Name)
    for _, child in pairs(eggModel:GetDescendants()) do
        if child:IsA("StringValue") then processString(child.Value)
        elseif child:IsA("IntValue") or child:IsA("NumberValue") then
            if string.find(string.upper(child.Name), "KG") then
                maxKg = math.max(maxKg, child.Value)
            else
                maxLuck = math.max(maxLuck, child.Value)
            end
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            processString(child.Text)
        end
    end
    return maxLuck, maxKg
end

local function processEgg(v)
    if not isEggList then return end
    if string.find(string.lower(v.Name), "egg") and (v:IsA("BasePart") or v:IsA("Model")) then 
        task.spawn(function()
            local part = v:IsA("BasePart") and v or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if part then
                local eggLuck, eggKg = getEggStats(v)
                
                -- Filter: បើសិន Luck តិចជាង 700K មិនបង្ហាញទេ
                if eggLuck < 700000 then return end 
                
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 45)
                btn.BackgroundColor3 = Color3.fromRGB(55, 20, 40)
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 9
                btn.TextColor3 = Color3.new(1,1,1)
                btn.TextXAlignment = Enum.TextXAlignment.Right
                btn.Visible = false
                
                -- បច្ចេកទេសតម្រៀបឆ្លាតវៃ: (Luck ធំលើគេ, បើស្មើគ្នា យក KG ធំលើគេ)
                local invLuck = 1000000000000000 - eggLuck
                local invKg = 1000000 - (eggKg * 100)
                if invLuck < 0 then invLuck = 0 end
                if invKg < 0 then invKg = 0 end
                local randomId = math.random(100000, 999999)
                btn.Name = string.format("%016.0f_%010.0f_%s", invLuck, invKg, tostring(randomId))

                local padding = Instance.new("UIPadding", btn)
                padding.PaddingRight = UDim.new(0, 10)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                btn.Parent = EggListScroll

                -- 3D Preview
                local viewport = Instance.new("ViewportFrame", btn)
                viewport.Size = UDim2.new(0, 38, 0, 38)
                viewport.Position = UDim2.new(0, 4, 0.5, -19)
                viewport.BackgroundTransparency = 1
                viewport.Ambient = Color3.fromRGB(200, 200, 200)

                local cloneObj = v:IsA("Model") and v or part
                pcall(function()
                    local oldArch = cloneObj.Archivable
                    cloneObj.Archivable = true
                    local clone = cloneObj:Clone()
                    cloneObj.Archivable = oldArch
                    
                    if clone then
                        for _, c in pairs(clone:GetDescendants()) do 
                            if c:IsA("Script") or c:IsA("ParticleEmitter") then c:Destroy() end 
                        end
                        local wm = Instance.new("WorldModel", viewport)
                        clone.Parent = wm
                        
                        local size = clone:IsA("Model") and clone:GetExtentsSize() or clone.Size
                        if clone:IsA("Model") then clone:PivotTo(CFrame.new(Vector3.zero)) else clone.CFrame = CFrame.new(Vector3.zero) end
                        
                        local cam = Instance.new("Camera")
                        cam.FieldOfView = 70
                        local maxDim = math.max(size.X, size.Y, size.Z)
                        cam.CFrame = CFrame.new(Vector3.new(0, 0, maxDim * 1.5), Vector3.zero)
                        viewport.CurrentCamera = cam
                        cam.Parent = viewport
                    end
                end)
                
                btn.Activated:Connect(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        btn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
                        local originalCFrame = hrp.CFrame 
                        
                        setStatus("កំពុងហោះទៅយកពង...")
                        hrp.CFrame = part.CFrame
                        task.wait(0.3)
                        
                        local targetModel = v:IsA("Model") and v or part.Parent
                        local function fireInteract(obj)
                            if obj:IsA("ProximityPrompt") then
                                pcall(function() fireproximityprompt(obj, 1, true) end)
                                pcall(function() fireproximityprompt(obj) end)
                            elseif obj:IsA("ClickDetector") then
                                pcall(function() fireclickdetector(obj) end)
                            end
                        end
                        for _, obj in pairs(targetModel:GetDescendants()) do fireInteract(obj) end
                        for _, obj in pairs(part:GetDescendants()) do fireInteract(obj) end
                        
                        setStatus("បានយកពងរួចរាល់!")
                        task.wait(0.5)
                        
                        hrp.CFrame = originalCFrame
                        setStatus("ត្រឡប់មកកន្លែងដើមវិញ!")
                        task.wait(0.5)
                        btn.BackgroundColor3 = Color3.fromRGB(55, 20, 40)
                        setStatus("រង់ចាំបញ្ជា...")
                    end
                end)
                
                table.insert(espObjects, { label = btn, part = part, instance = v, luckValue = formatNumber(eggLuck), kgValue = eggKg })
            end
        end)
    end
end

local function startEggScan()
    if isEggList then return end
    isEggList = true
    setStatus("កំពុងស្កេនរកពង 🍀700K+...")
    
    espScanThread = task.spawn(function()
        for i, v in ipairs(Workspace:GetDescendants()) do
            if not isEggList then break end
            processEgg(v)
            if i % 300 == 0 then task.wait() end 
        end
        if isEggList then setStatus("ស្កេនរួចរាល់ និងកំពុងរង់ចាំពងថ្មីៗ...") end
    end)

    espAddedConn = Workspace.DescendantAdded:Connect(function(descendant)
        processEgg(descendant)
    end)

    espLoopConn = RunService.RenderStepped:Connect(function()
        local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
        local count = 0
        for i = #espObjects, 1, -1 do
            local obj = espObjects[i]
            if obj.part and obj.part.Parent then
                if pos then
                    local dist = math.floor((obj.part.Position - pos).Magnitude)
                    
                    -- =========================================================
                    -- ⚠️ លក្ខខណ្ឌចម្ងាយ: បើចម្ងាយ >= 1000m ទើបបង្ហាញក្នុងបញ្ជី
                    -- =========================================================
                    if dist >= 1000 then
                        obj.label.Visible = true
                        obj.label.Text = obj.instance.Name .. " | 🍀" .. obj.luckValue .. " | ⚖️" .. obj.kgValue .. "KG | " .. dist .. "m"
                        count = count + 1
                    else
                        obj.label.Visible = false -- លាក់ពងណាដែលនៅជិតជាង 1000m
                    end
                end
            else
                if obj.label then obj.label:Destroy() end
                table.remove(espObjects, i)
            end
        end
        EggInfoBar.Text = "បង្ហាញតែពង >1000m និង 🍀700K+ | សរុប " .. count .. " ពង"
    end)
end

local function stopEggScan()
    isEggList = false
    setStatus("រង់ចាំបញ្ជា...")
    if espLoopConn then espLoopConn:Disconnect(); espLoopConn = nil end
    if espAddedConn then espAddedConn:Disconnect(); espAddedConn = nil end
    if espScanThread then pcall(task.cancel, espScanThread); espScanThread = nil end
    for _, obj in pairs(espObjects) do if obj.label then obj.label:Destroy() end end
    espObjects = {}
    EggInfoBar.Text = "បង្ហាញតែពង >1000m និង 🍀700K+ | (បិទ)"
end

OpenEggListBtn.Activated:Connect(function()
    if not EggWindow.Visible then
        EggWindow.Visible = true
        EggOpenFrame.Visible = false
        OpenEggListBtn.Text = "🍀 បិទបញ្ជីពង (CLOSE EGG LIST)"
        OpenEggListBtn.BackgroundColor3 = Color3.fromRGB(199, 21, 133)
        if not isEggList then startEggScan() end
    else
        EggWindow.Visible = false
        OpenEggListBtn.Text = "🍀 បើកបញ្ជីពង (OPEN EGG LIST)"
        OpenEggListBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    end
end)

-- UI Toggle Logic
MinBtn.Activated:Connect(function() MainFrame.Visible = false; OpenFrame.Visible = true end)
OpenBtn.Activated:Connect(function() MainFrame.Visible = true; OpenFrame.Visible = false end)
EggMinBtn.Activated:Connect(function() EggWindow.Visible = false; EggOpenFrame.Visible = true end)
EggOpenBtnFloat.Activated:Connect(function() EggWindow.Visible = true; EggOpenFrame.Visible = false end)
EggCloseBtn.Activated:Connect(function()
    EggWindow.Visible = false
    EggOpenFrame.Visible = false
    OpenEggListBtn.Text = "🍀 បើកបញ្ជីពង (OPEN EGG LIST)"
    OpenEggListBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
end)

RunService.RenderStepped:Connect(function()
    local hue = (tick() % 3) / 3 
    local color = Color3.fromHSV(hue, 0.7, 1) 
    for _, textObject in pairs(glowingTexts) do
        if textObject and textObject.Parent then textObject.TextColor3 = color end
    end
end)

CloseBtn.Activated:Connect(function() 
    stopFly()
    if isNoclip then toggleNoclip() end
    stopEggScan()
    ScreenGui:Destroy()
end)
