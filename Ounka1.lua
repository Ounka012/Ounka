--[[
    🌲⚡ AUTO TP — Fixed Version
]]

local Players         = game:GetService("Players")
local Workspace       = game:GetService("Workspace")
local UserInputService= game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ═══ ការកំណត់ ═══
local Targets = {
    {Name = "Trunk", Distance = 29},
    {Name = "Tree",  Distance = 29},
}
local Delay        = 0.15       -- បង្កើនបន្តិច
local AutoEnabled  = false
local HomePosition = nil
local LastTPTime   = 0          -- Cooldown

-- ═══ Helpers ═══
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ⭐ កំណត់ Home ឱ្យត្រូវ — រង់ចាំ Character
local function SetHome(force)
    local hrp = getHRP()
    if hrp then
        HomePosition = hrp.CFrame
        print("[TP] ✅ Home:", math.floor(hrp.Position.X), math.floor(hrp.Position.Y), math.floor(hrp.Position.Z))
        return true
    end
    if force then
        print("[TP] ⏳ រង់ចាំ Character...")
        task.spawn(function()
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1)
            SetHome(true)
        end)
    end
    return false
end

-- ═══ 🔍 រក Target ═══
local function findTarget()
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, t in ipairs(Targets) do
                if obj.Name == t.Name then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist <= t.Distance and dist < bestDist then
                        best = obj; bestDist = dist
                    end
                end
            end
        end
    end
    return best, bestDist
end

-- ═══ ⚡ TP ═══
local function tpAndReturn(target)
    local hrp = getHRP()
    if not hrp or not target or not target.Parent then return end
    if not HomePosition then
        print("[TP] ⚠ គ្មាន Home — កំណត់ស្វ័យប្រវត្តិ")
        SetHome()
        if not HomePosition then return end
    end

    -- Save ก่อน TP
    local backCF = HomePosition

    print("[TP] ⚡ TP ទៅ:", target.Name)

    -- 1. TP ទៅ Target (Instant)
    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    task.wait(Delay)

    -- 2. ចុចយក
    pcall(function()
        for _, prompt in ipairs(target:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end
        if firetouchinterest then
            firetouchinterest(hrp, target, 0)
            task.wait(0.03)
            firetouchinterest(hrp, target, 1)
        end
        for _, cd in ipairs(target:GetDescendants()) do
            if cd:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(cd)
            end
        end
    end)

    task.wait(Delay)

    -- 3. TP ត្រឡប់មក Home (Instant)
    print("[TP] 🏠 TP ត្រឡប់មក Home")
    hrp.CFrame = backCF
end

-- ═══ AUTO LOOP ═══
task.spawn(function()
    while task.wait(0.25) do
        if AutoEnabled then
            -- Cooldown 0.5s រវាង TP
            if tick() - LastTPTime > 0.5 then
                local target = findTarget()
                if target then
                    LastTPTime = tick()
                    pcall(tpAndReturn, target)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🎨 GUI — ប៊ូតុង ON/OFF
-- ═══════════════════════════════════════════════════════════
if PlayerGui:FindFirstChild("TP_ONOFF") then
    PlayerGui.TP_ONOFF:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TP_ONOFF"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- ⭐ ប៊ូតុងធំ (ដាក់ត្រង់កណ្ដាលឆ្វេង)
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 100, 0, 100)
Btn.Position = UDim2.new(0, 20, 0.5, -50)
Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Btn.Text = "OFF"
Btn.TextColor3 = Color3.new(1,1,1)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 26
Btn.AutoButtonColor = false
Btn.Active = true
Btn.Parent = ScreenGui
Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 4
stroke.Parent = Btn

-- ⭐ ប៊ូតុង Set Home តូច (ក្រោម)
local SetHomeBtn = Instance.new("TextButton")
SetHomeBtn.Size = UDim2.new(0, 100, 0, 40)
SetHomeBtn.Position = UDim2.new(0, 20, 0.5, 60)
SetHomeBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
SetHomeBtn.Text = "📍 SET HOME"
SetHomeBtn.TextColor3 = Color3.new(1,1,1)
SetHomeBtn.Font = Enum.Font.GothamBold
SetHomeBtn.TextSize = 12
SetHomeBtn.AutoButtonColor = false
SetHomeBtn.Parent = ScreenGui
Instance.new("UICorner", SetHomeBtn).CornerRadius = UDim.new(0, 8)

-- ═══ អូសបាន ═══
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end
makeDraggable(Btn)
makeDraggable(SetHomeBtn)

-- ═══ ON/OFF ═══
Btn.MouseButton1Click:Connect(function()
    AutoEnabled = not AutoEnabled
    if AutoEnabled then
        if not HomePosition then SetHome() end
        Btn.Text = "ON"
        Btn.BackgroundColor3 = Color3.fromRGB(50, 200, 90)
        stroke.Color = Color3.fromRGB(200, 255, 200)
        print("[TP] ⚡ ON")
    else
        Btn.Text = "OFF"
        Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        print("[TP] 🔴 OFF")
    end
end)

-- ═══ Set Home ═══
SetHomeBtn.MouseButton1Click:Connect(function()
    if SetHome() then
        SetHomeBtn.Text = "✅ SAVED"
        task.wait(1)
        SetHomeBtn.Text = "📍 SET HOME"
    end
end)

-- ═══ ចាប់ផ្ដើម ═══
if LocalPlayer.Character then
    SetHome()
else
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        SetHome()
    end)
end

print("[TP] 🌲⚡ Ready — ចុច OFF ដើម្បីបើក")