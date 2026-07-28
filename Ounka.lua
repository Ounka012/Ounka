--[[
    Ouncopybara Hub - Single Button Ultimate UI
    មុខងារ: 
    - Click 1: បើក/បិទ មេនុឺ
    - Double Click: លាក់/បង្ហាញ ប៊ូតុងទាំងស្រុង (Hide Mode)
    - Drag: អូសបានគ្រប់កន្លែង
--]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme Colors
local Theme = {
    Bg = Color3.fromRGB(18, 18, 24),
    Topbar = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 245),
    Border = Color3.fromRGB(45, 45, 55)
}

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OuncopybaraGUI_Single"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if gethui then pcall(function() screenGui.Parent = gethui() end) end
if not screenGui.Parent then screenGui.Parent = CoreGui end

-- ==================== STATE MANAGEMENT ====================
local isMenuOpen = false      -- មេនុឺកំពុងបើក ឬបិទ
local isFullyHidden = false   -- លាក់ទាំងស្រុង (Hidden Mode)
local lastClickTime = 0       -- សម្រាប់គណនា Double Click

-- ==================== FLOATING TOGGLE BUTTON ====================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Theme.Bg
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screenGui

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Theme.Accent
btnStroke.Thickness = 2

local btnIcon = Instance.new("ImageLabel", toggleBtn)
btnIcon.Size = UDim2.new(0, 28, 0, 28)
btnIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
btnIcon.BackgroundTransparency = 1
btnIcon.Image = "rbxassetid://10747384494" -- Icon Capybara
btnIcon.ImageColor3 = Theme.Accent

-- Hover Effect
toggleBtn.MouseEnter:Connect(function()
    if not isFullyHidden then
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Thickness = 3}):Play()
    end
end)
toggleBtn.MouseLeave:Connect(function()
    if not isFullyHidden then
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Thickness = 2}):Play()
    end
end)

-- ==================== MAIN FRAME ====================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 420)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
mainFrame.BackgroundColor3 = Theme.Bg
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", mainFrame).Color = Theme.Border

-- Shadow
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = -1

-- Topbar
local topbar = Instance.new("Frame", mainFrame)
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 45)
topbar.BackgroundColor3 = Theme.Topbar
topbar.BorderSizePixel = 0
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 14)

local fixCorner = Instance.new("Frame", topbar)
fixCorner.Size = UDim2.new(1, 0, 0, 14)
fixCorner.Position = UDim2.new(0, 0, 1, -14)
fixCorner.BackgroundColor3 = Theme.Topbar
fixCorner.BorderSizePixel = 0

-- Title
local title = Instance.new("TextLabel", topbar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Ouncopybara Hub"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Theme.Text

-- Close Button
local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Content Placeholder
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 55)
contentFrame.BackgroundTransparency = 1

-- ==================== FUNCTIONS ====================

-- 1. Toggle Menu Open/Close
local function toggleMenu()
    if isFullyHidden then return end
    
    isMenuOpen = not isMenuOpen
    
    if isMenuOpen then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        topbar.BackgroundTransparency = 1
        title.TextTransparency = 1
        closeBtn.BackgroundTransparency = 1
        
        TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, 420), BackgroundTransparency = 0
        }):Play()
        TweenService:Create(topbar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0.1), {TextTransparency = 0}):Play()
        TweenService:Create(closeBtn, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0.1), {BackgroundTransparency = 0}):Play()
    else
        local tw = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1
        })
        tw:Play()
        TweenService:Create(topbar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        tw.Completed:Wait()
        if not isMenuOpen then mainFrame.Visible = false end
    end
end

-- 2. Toggle Full Hide/Show (លាក់/បង្ហាញ ទាំងអស់)
local function toggleFullVisibility()
    isFullyHidden = not isFullyHidden
    
    if isFullyHidden then
        -- លាក់ទាំងស្រុង
        if isMenuOpen then toggleMenu() end -- បិទមេនុឺជាមុនសិន
        task.wait(0.25)
        
        -- Animation លាក់ប៊ូតុង
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            BackgroundTransparency = 1, 
            Position = UDim2.new(0, -60, 0.5, -25)
        }):Play()
        TweenService:Create(btnIcon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
    else
        -- បង្ហាញមកវិញ
        toggleBtn.Position = UDim2.new(0, -60, 0.5, -25)
        toggleBtn.BackgroundTransparency = 1
        
        TweenService:Create(toggleBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0, 
            Position = UDim2.new(0, 20, 0.5, -25)
        }):Play()
        TweenService:Create(btnIcon, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0.1), {ImageTransparency = 0}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0.1), {Transparency = 0}):Play()
    end
end

-- ==================== EVENT BINDINGS ====================

-- Logic សម្រាប់ Click និង Double Click
toggleBtn.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastClickTime < 0.3 then
        -- Double Click Detected -> Hide/Show All
        toggleFullVisibility()
    else
        -- Single Click -> Open/Close Menu
        toggleMenu()
    end
    lastClickTime = currentTime
end)

closeBtn.MouseButton1Click:Connect(toggleMenu)

-- ==================== DRAG SYSTEM (Universal) ====================
local dragging, dragInput, dragStart, startPos

local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = mainFrame.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
    end)
end

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)

topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)