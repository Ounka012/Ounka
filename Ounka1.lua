--========================================================
-- 💎 VIP PRO MODERN UI TEMPLATE (Roblox Studio Standard)
--========================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ⚙️ CONFIGURATION
local THEME_ACCENT = Color3.fromRGB(0, 170, 255)
local BG_COLOR = Color3.fromRGB(20, 20, 25)
local CARD_COLOR = Color3.fromRGB(30, 30, 38)
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)

local TWEEN_FAST = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- 🛠️ HELPER: DRAGGABLE SYSTEM
local function makeDraggable(topBar, mainFrame)
    local dragging, startPos, objPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            objPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            mainFrame.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    guiObjectInputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- 🛠️ HELPER: DRAGGABLE TOGGLE BUTTON
local function makeToggleDraggable(button, onClickCallback)
    local dragging = false
    local startPos, objPos
    local hasMoved = false

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            startPos = input.Position
            objPos = button.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            if delta.Magnitude > 5 then
                hasMoved = true
            end
            button.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not hasMoved then
                onClickCallback()
            end
            dragging = false
        end
    end)
end

-- 🏗️ BUILD VIP INTERFACE
local function buildVIPStudioUI()
    if PlayerGui:FindFirstChild("VIP_Pro_UI") then
        PlayerGui.VIP_Pro_UI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VIP_Pro_UI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    -- 🔘 FLOATING TOGGLE BUTTON
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "OpenToggle"
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 25, 0.5, -25)
    toggleBtn.BackgroundColor3 = BG_COLOR
    toggleBtn.Text = "💎"
    toggleBtn.TextSize = 22
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = screenGui

    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Color = THEME_ACCENT
    toggleStroke.Thickness = 2

    -- 🪟 MAIN CONTAINER (MAIN WINDOW)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 520, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
    mainFrame.BackgroundColor3 = BG_COLOR
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(50, 50, 65)
    mainStroke.Thickness = 1.5

    -- 🔝 TOP HEADER BAR
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "👑 VIP PRO CONTROL PANEL"
    titleLabel.TextColor3 = THEME_ACCENT
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    -- 📑 TAB NAVIGATION SIDEBAR
    local sideBar = Instance.new("Frame")
    sideBar.Name = "SideBar"
    sideBar.Size = UDim2.new(0, 130, 1, -45)
    sideBar.Position = UDim2.new(0, 0, 0, 45)
    sideBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    sideBar.BorderSizePixel = 0
    sideBar.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout", sideBar)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPadding = Instance.new("UIPadding", sideBar)
    tabPadding.PaddingTop = UDim.new(0, 12)

    -- 📦 CONTENT CONTAINER
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -140, 1, -55)
    contentArea.Position = UDim2.new(0, 135, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- 🔄 TAB CONTROLLER SYSTEM
    local tabs = {}
    local currentTab = nil

    local function createTab(tabName, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.88, 0, 0, 36)
        tabBtn.BackgroundColor3 = CARD_COLOR
        tabBtn.Text = icon .. " " .. tabName
        tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.Parent = sideBar
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = THEME_ACCENT
        tabContent.Visible = false
        tabContent.Parent = contentArea

        local contentLayout = Instance.new("UIListLayout", tabContent)
        contentLayout.Padding = UDim.new(0, 10)

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                TweenService:Create(t.Button, TWEEN_FAST, {BackgroundColor3 = CARD_COLOR, TextColor3 = Color3.fromRGB(160, 160, 180)}):Play()
                t.Content.Visible = false
            end
            TweenService:Create(tabBtn, TWEEN_FAST, {BackgroundColor3 = THEME_ACCENT, TextColor3 = Color3.new(1, 1, 1)}):Play()
            tabContent.Visible = true
        end)

        local tabObj = {Button = tabBtn, Content = tabContent}
        table.insert(tabs, tabObj)
        return tabContent
    end

    -- 📄 CREATE TABS
    local homeTab = createTab("Home", "🏠")
    local settingsTab = createTab("Settings", "⚙️")
    local infoTab = createTab("Info", "ℹ️")

    -- 🧩 UI COMPONENTS CREATOR

    -- 1. BUTTON COMPONENT
    local function addActionButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = CARD_COLOR
        btn.Text = text
        btn.TextColor3 = TEXT_COLOR
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(50, 50, 65)

        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = THEME_ACCENT}):Play()
            task.wait(0.15)
            TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = CARD_COLOR}):Play()
            if callback then callback() end
        end)
    end

    -- 2. TOGGLE SWITCH COMPONENT
    local function addToggle(parent, text, defaultState, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 42)
        frame.BackgroundColor3 = CARD_COLOR
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = TEXT_COLOR
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local switchBg = Instance.new("TextButton")
        switchBg.Size = UDim2.new(0, 42, 0, 22)
        switchBg.Position = UDim2.new(1, -50, 0.5, -11)
        switchBg.BackgroundColor3 = defaultState and THEME_ACCENT or Color3.fromRGB(50, 50, 60)
        switchBg.Text = ""
        switchBg.Parent = frame
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = defaultState
        switchBg.MouseButton1Click:Connect(function()
            state = not state
            local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local targetColor = state and THEME_ACCENT or Color3.fromRGB(50, 50, 60)

            TweenService:Create(knob, TWEEN_FAST, {Position = targetPos}):Play()
            TweenService:Create(switchBg, TWEEN_FAST, {BackgroundColor3 = targetColor}):Play()

            if callback then callback(state) end
        end)
    end

    -- 3. SLIDER COMPONENT
    local function addSlider(parent, text, minVal, maxVal, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.BackgroundColor3 = CARD_COLOR
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 20)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. ": " .. tostring(defaultVal)
        lbl.TextColor3 = TEXT_COLOR
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, 32)
        track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        track.Parent = frame
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        local initialPercent = (defaultVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(initialPercent, 0, 1, 0)
        fill.BackgroundColor3 = THEME_ACCENT
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local sliding = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(minVal + (maxVal - minVal) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            lbl.Text = text .. ": " .. tostring(val)
            if callback then callback(val) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                updateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
    end

    -- 🌟 POPULATE TAB CONTENTS
    -- Home Tab
    addActionButton(homeTab, "🚀 បើកដំណើរការ Feature A", function()
        print("Feature A Executed!")
    end)

    addToggle(homeTab, "✨ បើក Effect ពន្លឺ VIP", false, function(active)
        print("VIP Effect:", active)
    end)

    addSlider(homeTab, "⚡ Speed Scale", 1, 100, 16, function(val)
        print("Speed set to:", val)
    end)

    -- Settings Tab
    addToggle(settingsTab, "🔔 Notification Sound", true, function(active)
        print("Sound:", active)
    end)

    addActionButton(settingsTab, "🔄 Reset UI Position", function()
        mainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
    end)

    -- Info Tab
    local infoLbl = Instance.new("TextLabel")
    infoLbl.Size = UDim2.new(1, -10, 0, 80)
    infoLbl.BackgroundColor3 = CARD_COLOR
    infoLbl.Text = "💎 VIP Modern UI Version 3.0\n\n- Smooth Animations\n- Customizable Layout\n- Standard Roblox Studio Safe"
    infoLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    infoLbl.Font = Enum.Font.GothamMedium
    infoLbl.TextSize = 11
    infoLbl.Parent = infoTab
    Instance.new("UICorner", infoLbl).CornerRadius = UDim.new(0, 8)

    -- 🎬 ANIMATION LOGIC (OPEN / CLOSE)
    local isOpen = false
    local function toggleWindow()
        isOpen = not isOpen
        if isOpen then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 520, 0, 0)
            TweenService:Create(mainFrame, TWEEN_SMOOTH, {Size = UDim2.new(0, 520, 0, 320)}):Play()
        else
            local anim = TweenService:Create(mainFrame, TWEEN_SMOOTH, {Size = UDim2.new(0, 520, 0, 0)})
            anim:Play()
            anim.Completed:Wait()
            mainFrame.Visible = false
        end
    end

    -- Default Select First Tab
    tabs[1].Button.BackgroundColor3 = THEME_ACCENT
    tabs[1].Button.TextColor3 = Color3.new(1, 1, 1)
    tabs[1].Content.Visible = true

    -- Bind Events & Dragging
    makeToggleDraggable(toggleBtn, toggleWindow)
    makeDraggable(topBar, mainFrame)
    closeBtn.MouseButton1Click:Connect(toggleWindow)
end

-- Run Setup
buildVIPStudioUI()