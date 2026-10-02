--[[
    ═══════════════════════════════════════════════════════════
      🌲⚡ AUTO TP — មានប៊ូតុង ON/OFF លើអេក្រង់
    ═══════════════════════════════════════════════════════════
]]

local Players         = game:GetService("Players")
local Workspace       = game:GetService("Workspace")
local UserInputService= game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ═══ ការកំណត់ ═══
local Targets = {
    {Name = "Trunk", Distance = 29},
    {Name = "Tree",  Distance = 29},
}
local Delay        = 0.1
local AutoEnabled  = false
local HomePosition = nil

-- ═══ Helpers ═══
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

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
    return best
end

local function SetHome()
    local hrp = getHRP()
    if hrp then HomePosition = hrp.CFrame end
end

local function tpAndReturn(target)
    local hrp = getHRP()
    if not hrp or not target or not target.Parent then return end
    local backCF = HomePosition or hrp.CFrame
    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    task.wait(Delay)
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
    end)
    task.wait(Delay)
    hrp.CFrame = backCF
end

-- ═══ ⚡ AUTO LOOP ═══
task.spawn(function()
    while task.wait(0.2) do
        if AutoEnabled then
            local target = findTarget()
            if target then
                pcall(tpAndReturn, target)
                task.wait(0.3)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🎨 GUI — ប៊ូតុង ON/OFF លើអេក្រង់
-- ═══════════════════════════════════════════════════════════
if CoreGui:FindFirstChild("TP_ONOFF") then CoreGui.TP_ONOFF:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TP_ONOFF"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- ═══ ប៊ូតុង ON/OFF ធំ ═══
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 90, 0, 90)
Btn.Position = UDim2.new(0, 20, 0.5, -45)
Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)  -- ក្រហម = OFF
Btn.Text = "OFF"
Btn.TextColor3 = Color3.new(1,1,1)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 22
Btn.AutoButtonColor = false
Btn.Active = true
Btn.Parent = ScreenGui
Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 3
stroke.Parent = Btn

-- ═══ ធ្វើឱ្យអូសបាន ═══
local dragging, dragStart, startPos
Btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Btn.Position
    end
end)
Btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                 startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ═══ ចុចបើក/បិទ ═══
Btn.MouseButton1Click:Connect(function()
    AutoEnabled = not AutoEnabled
    if AutoEnabled then
        Btn.Text = "ON"
        Btn.BackgroundColor3 = Color3.fromRGB(50, 200, 90)  -- បៃតង = ON
        stroke.Color = Color3.fromRGB(200, 255, 200)
        print("[TP] ⚡ ON")
    else
        Btn.Text = "OFF"
        Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        print("[TP] 🔴 OFF")
    end
end)

-- ═══ ចាប់ផ្ដើម ═══
SetHome()
print("[TP] 🌲⚡ Ready — ចុចប៊ូតុង ON/OFF លើអេក្រង់")