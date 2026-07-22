-- Blade Ball VIP Script - Auto Parry, ESP, Dodge, Anti-Ban
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- អថេរ VIP
local Settings = {
    Enabled = false,
    ParryDistance = 25,       -- ចម្ងាយចុច (studs)
    ClickInterval = 0.3,      -- ចន្លោះពេលចុច (វិនាទី)
    DodgeEnabled = false,
    DodgeDistance = 12,       -- ចម្ងាយគេច (បើជិតជាងនេះ)
    ESP = false,
    ESPColor = Color3.fromRGB(255, 255, 0),
    RandomizeDelay = true,    -- Anti-Ban
    ToggleKey = Enum.KeyCode.F
}

-- GUI ចម្បង
local function createVIPGUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "BladeBall_VIP"

    -- Main Frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 350, 0, 280)
    main.Position = UDim2.new(0.5, -175, 0.5, -140)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    main.BorderSizePixel = 0
    main.Draggable = true
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Thickness = 2

    -- Title
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ Blade Ball VIP"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.new(1,1,1)

    -- Close Button
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

    -- Toggle Button (On/Off)
    local toggleBtn = Instance.new("TextButton", main)
    toggleBtn.Size = UDim2.new(0, 120, 0, 40)
    toggleBtn.Position = UDim2.new(0, 20, 0, 60)
    toggleBtn.Text = "OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

    local statusLabel = Instance.new("TextLabel", main)
    statusLabel.Size = UDim2.new(0, 150, 0, 30)
    statusLabel.Position = UDim2.new(0, 160, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "របៀប៖ បិទ"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextColor3 = Color3.new(1,1,1)

    toggleBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        toggleBtn.Text = Settings.Enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
        statusLabel.Text = Settings.Enabled and "របៀប៖ បើក" or "របៀប៖ បិទ"
    end)

    -- Sliders & Toggles with labels
    local yOff = 120
    local function addSlider(name, min, max, default, callback)
        local label = Instance.new("TextLabel", main)
        label.Size = UDim2.new(0, 150, 0, 20)
        label.Position = UDim2.new(0, 20, 0, yOff)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. default
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextColor3 = Color3.new(0.9,0.9,0.9)

        local sliderFrame = Instance.new("Frame", main)
        sliderFrame.Size = UDim2.new(0, 140, 0, 10)
        sliderFrame.Position = UDim2.new(0, 20, 0, yOff+25)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
        Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0,5)

        local fill = Instance.new("Frame", sliderFrame)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0,180,255)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,5)

        local knob = Instance.new("TextButton", sliderFrame)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new((default-min)/(max-min), -9, 0.5, -9)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.Text = ""
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,9)

        -- Slider logic
        local dragging = false
        knob.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                local value = min + (relX / sliderFrame.AbsoluteSize.X) * (max - min)
                value = math.floor(value * 10) / 10 -- round
                fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                knob.Position = UDim2.new((value-min)/(max-min), -9, 0.5, -9)
                label.Text = name .. ": " .. value
                callback(value)
            end
        end)

        yOff = yOff + 45
    end

    addSlider("Parry Distance", 10, 50, Settings.ParryDistance, function(v) Settings.ParryDistance = v end)
    addSlider("Click Interval", 0.1, 1.0, Settings.ClickInterval, function(v) Settings.ClickInterval = v end)
    addSlider("Dodge Distance", 5, 30, Settings.DodgeDistance, function(v) Settings.DodgeDistance = v end)

    -- Toggle buttons for ESP, Dodge
    local function addToggle(name, posY, default, callback)
        local label = Instance.new("TextLabel", main)
        label.Size = UDim2.new(0, 150, 0, 20)
        label.Position = UDim2.new(0, 20, 0, posY)
        label.BackgroundTransparency = 1
        label.Text = name
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextColor3 = Color3.new(0.9,0.9,0.9)

        local btn = Instance.new("TextButton", main)
        btn.Size = UDim2.new(0, 60, 0, 22)
        btn.Position = UDim2.new(0, 180, 0, posY)
        btn.Text = default and "ON" or "OFF"
        btn.BackgroundColor3 = default and Color3.fromRGB(0,180,0) or Color3.fromRGB(120,120,120)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            local newState = not callback()
            btn.Text = newState and "ON" or "OFF"
            btn.BackgroundColor3 = newState and Color3.fromRGB(0,180,0) or Color3.fromRGB(120,120,120)
        end)
        return btn
    end

    addToggle("ESP Ball", yOff, Settings.ESP, function() Settings.ESP = not Settings.ESP return Settings.ESP end)
    yOff = yOff + 30
    addToggle("Auto Dodge", yOff, Settings.DodgeEnabled, function() Settings.DodgeEnabled = not Settings.DodgeEnabled return Settings.DodgeEnabled end)

    -- Start the RGB effect on title
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.01) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.03)
        end
    end)
end

-- រកបាល់
local function findBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("blade")) then
            return obj
        end
    end
    return nil
end

-- ចុចកណ្ដុរឆ្វេង
local function clickMouse()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.03)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- ESP highlight
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

-- បិទ ESP ចំពោះបាល់ដែលលែងត្រូវការ
local function cleanupESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "VIP_Highlight" then
            obj:Destroy()
        end
    end
end

-- ចលនាគេច (ធម្មតាដើរថយក្រោយ)
local function dodge(ball)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local dir = (root.Position - ball.Position).Unit
    -- រុញថយក្រោយបន្តិច
    root.CFrame = root.CFrame * CFrame.new(dir * 5)  -- move back 5 studs
end

-- Main loop
createVIPGUI()

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

            -- Dodge if enabled and ball too close
            if Settings.DodgeEnabled and dist <= Settings.DodgeDistance then
                dodge(ball)
            end

            -- Auto Parry
            if dist <= Settings.ParryDistance then
                clickMouse()
                local delay = Settings.ClickInterval
                if Settings.RandomizeDelay then
                    delay = delay * (0.8 + math.random() * 0.4) -- ±20% random
                end
                task.wait(delay)
            end
        else
            cleanupESP()
        end
    end
end)

-- Key toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.ToggleKey then
        Settings.Enabled = not Settings.Enabled
        -- update GUI button if still exists
        local gui = CoreGui:FindFirstChild("BladeBall_VIP")
        if gui then
            local toggleBtn = gui:FindFirstChild("Frame"):FindFirstChild("TextButton")
            if toggleBtn then
                toggleBtn.Text = Settings.Enabled and "ON" or "OFF"
                toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
            end
        end
    end
end)