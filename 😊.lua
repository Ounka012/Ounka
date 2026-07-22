-- Blade Ball VIP Undetectable (Stealth Edition)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--========= ការកំណត់ =========
local Settings = {
    Enabled = false,
    ParryDistance = 20,
    ClickInterval = 0.25,
    DodgeEnabled = false,
    DodgeDistance = 12,
    ESP = false,
    ESPColor = Color3.fromRGB(255, 255, 0),
    RandomizeDelay = true,
    ToggleKey = Enum.KeyCode.F,
    UseRemote = false,        -- ប្ដូរជា true បើស្គាល់ Remote
    RemoteName = "Parry",     -- ឈ្មោះ RemoteEvent សម្រាប់បាញ់ផ្ទាល់
    HideGUIKey = Enum.KeyCode.G  -- ចុច G ដើម្បីបិទ/បើក GUI
}

--========= មុខងារជំនួយ =========
local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("blade")) then
            return obj
        end
    end
    return nil
end

local function clickMouse()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function fireRemote()
    local remote = Workspace:FindFirstChild(Settings.RemoteName) or 
                   ReplicatedStorage:FindFirstChild(Settings.RemoteName)
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
        return true
    end
    return false
end

local function getRandomDelay()
    local delay = Settings.ClickInterval
    if Settings.RandomizeDelay then
        delay = delay * (0.7 + math.random() * 0.6)
    end
    return delay
end

--========= GUI (ស្ងាត់, ក្នុង PlayerGui) =========
local function createStealthGUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "Inventory"  -- ក្លែងឈ្មោះ
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    -- Main Frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 350, 0, 280)
    main.Position = UDim2.new(0.5, -175, 0.5, -140)
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.BorderSizePixel = 0
    main.Draggable = true
    main.Active = true
    main.Visible = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Thickness = 2

    -- Title
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ Blade Ball VIP"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)

    -- Close button
    local close = Instance.new("TextButton", main)
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-35,0,5)
    close.Text = "X"
    close.BackgroundColor3 = Color3.fromRGB(200,50,50)
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    Instance.new("UICorner", close).CornerRadius = UDim.new(0,8)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Toggle On/Off
    local toggleBtn = Instance.new("TextButton", main)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Position = UDim2.new(0, 20, 0, 55)
    toggleBtn.Text = "OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

    local statusLabel = Instance.new("TextLabel", main)
    statusLabel.Size = UDim2.new(0, 150, 0, 25)
    statusLabel.Position = UDim2.new(0, 160, 0, 60)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: OFF"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.new(1,1,1)

    -- Toggle function
    local function updateToggle()
        toggleBtn.Text = Settings.Enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
        statusLabel.Text = Settings.Enabled and "Status: ON" or "Status: OFF"
    end

    toggleBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        updateToggle()
    end)

    -- Sliders
    local yOff = 110
    local function addSlider(name, min, max, default, callback)
        local label = Instance.new("TextLabel", main)
        label.Size = UDim2.new(0, 140, 0, 18)
        label.Position = UDim2.new(0, 20, 0, yOff)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. default
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextColor3 = Color3.new(0.9,0.9,0.9)

        local sliderFrame = Instance.new("Frame", main)
        sliderFrame.Size = UDim2.new(0, 140, 0, 8)
        sliderFrame.Position = UDim2.new(0, 20, 0, yOff+20)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
        Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0,4)

        local fill = Instance.new("Frame", sliderFrame)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0,180,255)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

        local knob = Instance.new("TextButton", sliderFrame)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.Text = ""
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,8)

        local dragging = false
        knob.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                local value = min + (relX / sliderFrame.AbsoluteSize.X) * (max - min)
                value = math.floor(value * 10) / 10
                fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                knob.Position = UDim2.new((value-min)/(max-min), -8, 0.5, -8)
                label.Text = name .. ": " .. value
                callback(value)
            end
        end)

        yOff = yOff + 38
    end

    addSlider("Parry Distance", 10, 50, Settings.ParryDistance, function(v) Settings.ParryDistance = v end)
    addSlider("Click Interval", 0.1, 1.0, Settings.ClickInterval, function(v) Settings.ClickInterval = v end)
    addSlider("Dodge Distance", 5, 30, Settings.DodgeDistance, function(v) Settings.DodgeDistance = v end)

    -- Toggles ESP, Dodge
    local function addToggle(name, posY, default, callback)
        local label = Instance.new("TextLabel", main)
        label.Size = UDim2.new(0, 120, 0, 18)
        label.Position = UDim2.new(0, 20, 0, posY)
        label.BackgroundTransparency = 1
        label.Text = name
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextColor3 = Color3.new(0.9,0.9,0.9)

        local btn = Instance.new("TextButton", main)
        btn.Size = UDim2.new(0, 50, 0, 20)
        btn.Position = UDim2.new(0, 170, 0, posY)
        btn.Text = default and "ON" or "OFF"
        btn.BackgroundColor3 = default and Color3.fromRGB(0,180,0) or Color3.fromRGB(100,100,100)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

        btn.MouseButton1Click:Connect(function()
            local newState = not callback()
            btn.Text = newState and "ON" or "OFF"
            btn.BackgroundColor3 = newState and Color3.fromRGB(0,180,0) or Color3.fromRGB(100,100,100)
        end)
        return btn
    end

    addToggle("ESP Ball", yOff, Settings.ESP, function() Settings.ESP = not Settings.ESP return Settings.ESP end)
    yOff = yOff + 30
    addToggle("Auto Dodge", yOff, Settings.DodgeEnabled, function() Settings.DodgeEnabled = not Settings.DodgeEnabled return Settings.DodgeEnabled end)

    -- RGB effect on title
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.01) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            mainStroke.Color = Color3.fromHSV(hue, 1, 1)
            task.wait(0.03)
        end
    end)

    -- Hide/Show with G key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Settings.HideGUIKey then
            main.Visible = not main.Visible
        end
    end)

    return gui, toggleBtn, statusLabel
end

--========= ESP =========
local function updateESP(ball)
    if not ball then return end
    if not ball:FindFirstChild("VIP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "VIP_Highlight"
        highlight.FillColor = Settings.ESPColor
        highlight.OutlineColor = Color3.new(1,1,1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = ball
    end
end

local function cleanupESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "VIP_Highlight" then
            obj:Destroy()
        end
    end
end

--========= Dodge =========
local function dodge(ball)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local dir = (root.Position - ball.Position).Unit
    root.CFrame = root.CFrame * CFrame.new(dir * 8)  -- រុញថយក្រោយ 8 studs
end

--========= Main Loop =========
local gui, toggleBtn, statusLabel = createStealthGUI()

-- Toggle key F
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.ToggleKey then
        Settings.Enabled = not Settings.Enabled
        if toggleBtn then
            toggleBtn.Text = Settings.Enabled and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
            statusLabel.Text = Settings.Enabled and "Status: ON" or "Status: OFF"
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if not Settings.Enabled then
            cleanupESP()
            continue
        end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local ball = findBall()
        if ball then
            local dist = (ball.Position - root.Position).Magnitude

            -- ESP
            if Settings.ESP then
                updateESP(ball)
            else
                cleanupESP()
            end

            -- Dodge
            if Settings.DodgeEnabled and dist <= Settings.DodgeDistance then
                dodge(ball)
            end

            -- Parry
            if dist <= Settings.ParryDistance then
                if Settings.UseRemote then
                    fireRemote()
                else
                    clickMouse()
                end
                task.wait(getRandomDelay())
            end
        else
            cleanupESP()
        end
    end
end)