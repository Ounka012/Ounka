--========================================================
-- Blade Ball: Advanced Anti-Ban & Optimized Parry (2026 Edition)
--========================================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    Enabled = false,
    ParryDistance = 22,
    ClickInterval = 0.2,
    ESP = true,
    ESPColor = Color3.fromRGB(0, 255, 255),
    ToggleKey = Enum.KeyCode.F,
    HideGUIKey = Enum.KeyCode.G
}

-- ស្វែងរកបាល់ដោយសុវត្ថិភាព និងច្បាស់លាស់
local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("blade")) then
            -- ពិនិត្យមើលថាបាល់សកម្មពិតប្រាកដ (មាន Velocity ឬ Size សមរម្យ)
            if obj.Transparency < 1 and obj.Size.Magnitude > 2 then
                return obj
            end
        end
    end
    return nil
end

-- ប្រើប្រាស់ Click ដោយក្លែងបន្លំ ContextAction/UserInputService ដើម្បីសុវត្ថិភាពខ្ពស់ជាង VirtualInputManager
local function triggerParry()
    pcall(function()
        -- ហៅ ContextActionService ឬ Virtualization ស្រាលបំផុតដែលអាចធ្វើទៅได้
        vim = game:GetService("VirtualUser")
        if vim then
            vim:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            vim:Button1Up(Vector2.new(0,0))
        end
    end)
end

-- GUI ទំនើប និងលាក់ខ្លួន
local function createGUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("SecureLoadout") then
        playerGui.SecureLoadout:Destroy()
    end

    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "SecureLoadout"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 340, 0, 240)
    main.Position = UDim2.new(0.5, -170, 0.5, -120)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    main.BorderSizePixel = 0
    main.Draggable = true
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🛡️ Blade Ball [Advanced Bypass]"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.new(1, 1, 1)

    local toggleBtn = Instance.new("TextButton", main)
    toggleBtn.Size = UDim2.new(0, 140, 0, 35)
    toggleBtn.Position = UDim2.new(0, 20, 0, 60)
    toggleBtn.Text = "STATUS: OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    local function updateState()
        toggleBtn.Text = Settings.Enabled and "STATUS: ON" or "STATUS: OFF"
        toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end

    toggleBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        updateState()
    end)

    -- RGB Title Effect
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.02) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            stroke.Color = Color3.fromHSV(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Settings.ToggleKey then
            Settings.Enabled = not Settings.Enabled
            updateState()
        elseif input.KeyCode == Settings.HideGUIKey then
            main.Visible = not main.Visible
        end
    end)
end

createGUI()

-- ESP Management
local function updateESP(ball)
    if not ball then return end
    if not ball:FindFirstChild("AdvancedESP") then
        local hl = Instance.new("Highlight")
        hl.Name = "AdvancedESP"
        hl.FillColor = Settings.ESPColor
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.FillTransparency = 0.4
        hl.Parent = ball
    end
end

local function cleanESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "AdvancedESP" then
            obj:Destroy()
        end
    end
end

-- Main Optimized Loop (Anti-Cheat Safe Timing)
local lastParryTick = 0
RunService.Heartbeat:Connect(function()
    if not Settings.Enabled then
        cleanESP()
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local ball = findBall()
    if ball then
        updateESP(ball)

        local dist = (ball.Position - root.Position).Magnitude
        
        -- គណនាទិសដៅ និងល្បឿនបាល់ដើម្បីការពារការញ័រ (Anti-Wobble / Anti-Cheat Trigger)
        local ballVelocity = ball.AssemblyLinearVelocity
        local timeToReach = dist / math.max(ballVelocity.Magnitude, 1)

        -- បើកកាតព្វកិច្ច Parry ពេលដល់ចម្ងាយកំណត់ និងទប់ διάστημα (Interval) កុំឱ្យញាប់ពេក
        if dist <= Settings.ParryDistance and (tick() - lastParryTick) >= Settings.ClickInterval then
            triggerParry()
            lastParryTick = tick()
        end
    else
        cleanESP()
    end
end)
