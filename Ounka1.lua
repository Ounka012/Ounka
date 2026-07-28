--[[
    VIP Ultimate UI Template - Glassmorphism Edition
    មុខងារ: Draggable, Hide/Show (Double Click), Smooth Animation, RGB Glow
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "vip_bg.jpg"

-- Helper: Smooth Tween
local function tween(obj, info, props)
    return TweenService:Create(obj, TweenInfo.new(info[1] or 0.3, info[2] or Enum.EasingStyle.Quad, info[3] or Enum.EasingDirection.Out), props)
end

-- Helper: Advanced Draggable
local function makeDraggable(guiObject)
    local dragging, dragInput, startPos, startObjPos
    
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            startObjPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startPos
            guiObject.Position = UDim2.new(
                startObjPos.X.Scale, 
                startObjPos.X.Offset + delta.X, 
                startObjPos.Y.Scale, 
                startObjPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("VIP_Ultimate_GUI") then CoreGui:FindFirstChild("VIP_Ultimate_GUI"):Destroy() end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "VIP_Ultimate_GUI"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100

    -- ==================== TOGGLE BUTTON (Floating) ====================
    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 60, 0, 60)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Active = true -- សំខាន់សម្រាប់ Hidden Mode
    
    local btnCorner = Instance.new("UICorner", toggleBtn)
    btnCorner.CornerRadius = UDim.new(1, 0)
    
    local btnStroke = Instance.new("UIStroke", toggleBtn)
    btnStroke.Thickness = 2
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Transparency = 0.5

    -- Shadow for Button
    local btnShadow = Instance.new("ImageLabel", toggleBtn)
    btnShadow.Size = UDim2.new(1, 20, 1, 20)
    btnShadow.Position = UDim2.new(0, -10, 0, -10)
    btnShadow.BackgroundTransparency = 1
    btnShadow.Image = "rbxassetid://1316045217"
    btnShadow.ImageTransparency = 0.5
    btnShadow.ScaleType = Enum.ScaleType.Slice
    btnShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    btnShadow.ZIndex = -1

    -- ==================== MAIN FRAME ====================
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.1 -- Glass effect base
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false -- Start hidden
    mainFrame.ClipsDescendants = true
    
    local frameCorner = Instance.new("UICorner", mainFrame)
    frameCorner.CornerRadius = UDim.new(0, 20)
    
    local frameStroke = Instance.new("UIStroke", mainFrame)
    frameStroke.Thickness = 1.5
    frameStroke.Color = Color3.fromRGB(255, 255, 255)
    frameStroke.Transparency = 0.8

    -- Background Image with Blur Effect simulation
    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ImageTransparency = 0.4
    bg.ZIndex = 0
    
    -- Glass Overlay (White tint)
    local glassOverlay = Instance.new("Frame", mainFrame)
    glassOverlay.Size = UDim2.new(1, 0, 1, 0)
    glassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glassOverlay.BackgroundTransparency = 0.85
    glassOverlay.ZIndex = 1
    Instance.new("UICorner", glassOverlay).CornerRadius = UDim.new(0, 20)

    -- Topbar (For Dragging)
    local topbar = Instance.new("Frame", mainFrame)
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 50)
    topbar.BackgroundTransparency = 1
    topbar.ZIndex = 5
    
    -- Title
    local title = Instance.new("TextLabel", topbar)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ VIP CONTROL PANEL"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6

    -- Close Button
    local closeBtn = Instance.new("TextButton", topbar)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 6
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    -- Content Area
    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Size = UDim2.new(1, -40, 1, -70)
    contentArea.Position = UDim2.new(0, 20, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 5

    -- Action Button (Modern Style)
    local actionBtn = Instance.new("TextButton", contentArea)
    actionBtn.Size = UDim2.new(1, 0, 0, 50)
    actionBtn.Position = UDim2.new(0, 0, 0, 20)
    actionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    actionBtn.BackgroundTransparency = 0.1
    actionBtn.Text = "START SCRIPT"
    actionBtn.TextColor3 = Color3.new(1, 1, 1)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 14
    actionBtn.AutoButtonColor = false
    actionBtn.ZIndex = 6
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 12)
    
    local actionStroke = Instance.new("UIStroke", actionBtn)
    actionStroke.Color = Color3.fromRGB(255, 255, 255)
    actionStroke.Transparency = 0.7

    -- Status Label
    local hintLabel = Instance.new("TextLabel", contentArea)
    hintLabel.Size = UDim2.new(1, 0, 0, 30)
    hintLabel.Position = UDim2.new(0, 0, 0, 80)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "Status: Ready to Launch"
    hintLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12
    hintLabel.ZIndex = 6

    -- ==================== LOGIC & ANIMATIONS ====================
    
    local isMenuOpen = false
    local isFullyHidden = false
    local lastClickTime = 0

    -- Toggle Menu Function
    local function toggleMenu()
        if isFullyHidden then return end
        
        isMenuOpen = not isMenuOpen
        
        if isMenuOpen then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            
            tween(mainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
                Size = UDim2.new(0, 450, 0, 250),
                BackgroundTransparency = 0.1
            }):Play()
        else
            local tw = tween(mainFrame, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not isMenuOpen then mainFrame.Visible = false end
            end)
        end
    end

    -- Toggle Full Hide Function
    local function toggleFullVisibility()
        isFullyHidden = not isFullyHidden
        
        if isFullyHidden then
            if isMenuOpen then toggleMenu() end
            task.wait(0.3)
            
            -- Hide Button Animation (Slide to edge but keep clickable)
            tween(toggleBtn, {0.3}, {
                Position = UDim2.new(0, -30, 0.5, -30),
                BackgroundTransparency = 1
            }):Play()
            tween(btnStroke, {0.2}, {Transparency = 1}):Play()
            tween(btnShadow, {0.2}, {ImageTransparency = 1}):Play()
        else
            -- Show Button Animation
            toggleBtn.Position = UDim2.new(0, -30, 0.5, -30)
            toggleBtn.BackgroundTransparency = 1
            
            tween(toggleBtn, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
                Position = UDim2.new(0, 20, 0.5, -30),
                BackgroundTransparency = 0.2
            }):Play()
            tween(btnStroke, {0.2}, {Transparency = 0.5}):Play()
            tween(btnShadow, {0.2}, {ImageTransparency = 0.5}):Play()
        end
    end

    -- Event Listeners
    toggleBtn.MouseButton1Click:Connect(function()
        local currentTime = tick()
        if currentTime - lastClickTime < 0.3 then
            toggleFullVisibility() -- Double Click
        else
            toggleMenu() -- Single Click
        end
        lastClickTime = currentTime
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tween(mainFrame, {0.2}, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.2)
        gui:Destroy()
    end)

    -- Action Button Logic
    local isActive = false
    actionBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            actionBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            actionBtn.Text = "STOPPING..."
            hintLabel.Text = "Status: Active ✅"
            hintLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            actionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            actionBtn.Text = "START SCRIPT"
            hintLabel.Text = "Status: Ready to Launch"
            hintLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)

    -- Hover Effects
    actionBtn.MouseEnter:Connect(function()
        tween(actionBtn, {0.2}, {BackgroundTransparency = 0}):Play()
    end)
    actionBtn.MouseLeave:Connect(function()
        tween(actionBtn, {0.2}, {BackgroundTransparency = 0.1}):Play()
    end)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    end)

    -- Make Draggable
    makeDraggable(topbar)

    -- RGB Glow Effect Loop
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.02) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            
            btnStroke.Color = color
            frameStroke.Color = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
            
            task.wait(0.05)
        end
    end)
end

-- Download and Initialize
local function init()
    local ok, response = pcall(function() 
        return request({Url = IMAGE_URL, Method = "GET"}) 
    end)
    
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        createGUI(getcustomasset(FILE_NAME))
    else
        warn("Failed to load image, using default.")
        createGUI("")
    end
end

init()