-- Blade Ball VIP (Stealth Edition - Anti-Detect)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ការកំណត់ (កែបាន)
local Settings = {
    Enabled = false,
    ParryDistance = 20,
    ClickInterval = 0.25,
    RandomizeDelay = true,
    ToggleKey = Enum.KeyCode.F,
    UseRemote = false,  -- បើ true នឹងព្យាយាមរក Remote Parry (ត្រូវកែឈ្មោះ Remote ដោយខ្លួនឯង)
    RemoteName = "Parry" -- ឈ្មោះ RemoteEvent (បើ UseRemote = true)
}

-- មុខងាររកបាល់
local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("blade")) then
            return obj
        end
    end
    return nil
end

-- ចុចឆ្វេង (Mouse Event)
local function clickMouse()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- បើ UseRemote=true នឹងបាញ់ Remote ផ្ទាល់
local function fireRemote()
    local remote = Workspace:FindFirstChild(Settings.RemoteName) or 
                   ReplicatedStorage:FindFirstChild(Settings.RemoteName)
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
        return true
    end
    return false
end

-- បង្កើត GUI លាក់មិនឲ្យចាប់បាន (នៅក្នុង PlayerGui)
local function createStealthGUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "Inventory"  -- ក្លែងថាជា GUI ធម្មតា
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    -- ប៊ូតុងតូចមួយដើម្បីបង្ហាញស្ថានភាព (អាចលាក់បានដោយចុចសង្កត់ 2 វិនាទី)
    local statusBtn = Instance.new("TextButton", gui)
    statusBtn.Size = UDim2.new(0, 70, 0, 25)
    statusBtn.Position = UDim2.new(0, 10, 0, 10)
    statusBtn.BackgroundTransparency = 0.7
    statusBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    statusBtn.Text = "PAR: OFF"
    statusBtn.TextColor3 = Color3.new(1,1,1)
    statusBtn.Font = Enum.Font.Gotham
    statusBtn.TextSize = 10
    statusBtn.BorderSizePixel = 0
    Instance.new("UICorner", statusBtn).CornerRadius = UDim.new(0,6)

    -- បិទ GUI ពេលសង្កត់យូរ (ដើម្បីកុំឲ្យ Admin ឃើញ)
    local holdTime = 0
    statusBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdTime = tick()
        end
    end)
    statusBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and tick() - holdTime > 2 then
            statusBtn.Visible = false
        end
    end)

    return gui, statusBtn
end

-- ប្រព័ន្ធ Anti-Ban (ពន្យារពេលចៃដន្យ)
local function getRandomDelay()
    local delay = Settings.ClickInterval
    if Settings.RandomizeDelay then
        delay = delay * (0.7 + math.random() * 0.6) -- ±30%
    end
    return delay
end

-- Main Loop
local gui, statusBtn = createStealthGUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.ToggleKey then
        Settings.Enabled = not Settings.Enabled
        if statusBtn then
            statusBtn.Text = Settings.Enabled and "PAR: ON" or "PAR: OFF"
            statusBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(0,0,0)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if not Settings.Enabled then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local ball = findBall()
        if ball and (ball.Position - root.Position).Magnitude <= Settings.ParryDistance then
            if Settings.UseRemote then
                fireRemote()
            else
                clickMouse()
            end
            task.wait(getRandomDelay())
        end
    end
end)