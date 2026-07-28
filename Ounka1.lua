--========================================================
-- 💎 VIP MODERN UI TEMPLATE | Draggable Toggle & Main GUI
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ⚙️ CONFIGURATION
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "vip_bg.jpg"
local THEME_COLOR = Color3.fromRGB(0, 180, 255)

-- 🎨 ANIMATION SETTINGS
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local HOVER_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- 🛠️ HELPER: Draggable Function សម្រាប់ Main Frame
local function makeDraggable(guiObject)
    local dragging, startPos, objPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startPos = input.Position; objPos = guiObject.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            guiObject.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- 🛠️ HELPER: Draggable ពិសេសសម្រាប់ Toggle Button (ដើម្បីកុំឱ្យច្រឡំរវាង Click និង Drag)
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
            if delta.Magnitude > 5 then -- ប្រសិនបើរំកិលលើសពី 5 pixels ទើបចាត់ទុកថា Drag
                hasMoved = true
            end
            button.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not hasMoved then
                onClickCallback() -- បើអត់បានអូសទេ គឺវាធ្វើការជា Click បើក/បិទ GUI
            end
            dragging = false
        end
    end)
end

-- 🎨 HELPER: Hover Effect
local function addHoverEffect(button, originalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, HOVER_TWEEN, {BackgroundColor3 = originalColor:Lerp(Color3.new(1,1,1), 0.2)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, HOVER_TWEEN, {BackgroundColor3 = originalColor}):Play()
    end)
end

-- 🏗️ MAIN BUILDER
local function createVIPGUI(imageAsset)
    if CoreGui:FindFirstChild("VIP_GUI") then CoreGui:FindFirstChild("VIP_GUI"):Destroy() end

    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "VIP_GUI"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999

    -- 🔘 TOGGLE BUTTON (Floating Orb)
    local toggleBtn = Instance.new("ImageButton", screenGui)
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    toggleBtn.BackgroundTransparency = 0.1
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleBtn.Image = imageAsset or "rbxassetid://7733960981"
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = THEME_COLOR
    tStroke.Thickness = 2
    
    -- ✨ RGB Glow for Toggle
    task.spawn(function()
        local h = 0
        while toggleBtn.Parent do
            h = (h + 0.01) % 1
            tStroke.Color = Color3.fromHSV(h, 0.8, 1)
            task.wait(0.05)
        end
    end)

    -- 🪟 MAIN WINDOW (Glassmorphism)
    local mainFrame = Instance.new("CanvasGroup", screenGui)
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 450, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.GroupTransparency = 1
    mainFrame.Visible = false
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(255, 255, 255)
    mainStroke.Transparency = 0.9
    mainStroke.Thickness = 1

    -- 🖼️ Background Image
    local bgImage = Instance.new("ImageLabel", mainFrame)
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = imageAsset or ""
    bgImage.ImageTransparency = 0.7
    bgImage.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)
    
    local overlay = Instance.new("Frame", mainFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 12)

    -- 📝 HEADER SECTION
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ VIP CONTROL PANEL"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ❌ Close Button
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    addHoverEffect(closeBtn, Color3.fromRGB(255, 60, 60))

    -- 🎛️ CONTENT AREA
    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, -40, 1, -60)
    content.Position = UDim2.new(0, 20, 0, 55)
    content.BackgroundTransparency = 1
    
    local listLayout = Instance.new("UIListLayout", content)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 10)

    -- 🔘 VIP ACTION BUTTON
    local actionBtn = Instance.new("TextButton", content)
    actionBtn.Size = UDim2.new(1, 0, 0, 45)
    actionBtn.BackgroundColor3 = THEME_COLOR
    actionBtn.Text = "🚀 បើកមុខងារពិសេស"
    actionBtn.TextColor3 = Color3.new(1, 1, 1)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 14
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 8)
    addHoverEffect(actionBtn, THEME_COLOR)

    -- 📊 STATUS CARD
    local statusCard = Instance.new("Frame", content)
    statusCard.Size = UDim2.new(1, 0, 0, 60)
    statusCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statusCard.BackgroundTransparency = 0.95
    Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel", statusCard)
    statusLabel.Size = UDim2.new(1, -20, 1, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 ស្ថានភាព៖ រង់ចាំបញ្ជា..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- 🎬 OPEN/CLOSE ANIMATION LOGIC
    local isOpen = false
    local function toggleMenu()
        isOpen = not isOpen
        mainFrame.Visible = true
        
        if isOpen then
            TweenService:Create(mainFrame, TWEEN_INFO, {GroupTransparency = 0, Position = UDim2.new(0.5, -225, 0.5, -140)}):Play()
            TweenService:Create(toggleBtn, TWEEN_INFO, {Rotation = 180}):Play()
        else
            local closeTween = TweenService:Create(mainFrame, TWEEN_INFO, {GroupTransparency = 1, Position = UDim2.new(0.5, -225, 0.5, -100)})
            closeTween:Play()
            TweenService:Create(toggleBtn, TWEEN_INFO, {Rotation = 0}):Play()
            closeTween.Completed:Wait()
            mainFrame.Visible = false
        end
    end

    -- 🔗 CONNECTIONS & DRAGGABLE SETTINGS
    makeToggleDraggable(toggleBtn, toggleMenu) -- ដាក់ Drag លើ Toggle Button
    makeDraggable(mainFrame) -- ដាក់ Drag លើ Main Window

    closeBtn.MouseButton1Click:Connect(function() 
        if isOpen then toggleMenu() end 
    end)

    local isActive = false
    actionBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            TweenService:Create(actionBtn, HOVER_TWEEN, {BackgroundColor3 = Color3.fromRGB(40, 200, 40)}):Play()
            actionBtn.Text = "⏹️ បិទមុខងារ"
            statusLabel.Text = "✅ ស្ថានភាព៖ កំពុងដំណើរការ"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            TweenService:Create(actionBtn, HOVER_TWEEN, {BackgroundColor3 = THEME_COLOR}):Play()
            actionBtn.Text = "🚀 បើកមុខងារពិសេស"
            statusLabel.Text = "💡 ស្ថានភាព៖ រង់ចាំបញ្ជា..."
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- 📥 ASSET LOADER
task.spawn(function()
    local asset = ""
    local ok, response = pcall(function() 
        return request({Url = IMAGE_URL, Method = "GET"}) 
    end)
    
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        asset = getcustomasset(FILE_NAME)
    end
    
    createVIPGUI(asset)
end)
