-- ================================================================
--  ✨ AUTO DASH GUI (Premium Glassmorphism) ✨
-- ================================================================
local DASH_CONFIG = {
    DASH_DISTANCE = 3.5,
    DASH_COOLDOWN = 0.05
}
-- ================================================================

-- Compatibility: បើ executor អត់មាន task library
if not task then
    task = {}
    task.spawn = function(func) coroutine.wrap(func)() end
    task.wait = function(...) return wait(...) end
    task.delay = function(t, func) coroutine.wrap(function() wait(t) func() end)() end
end

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====== លុប GUI ចាស់ ======
if CoreGui:FindFirstChild("DashOnlyGUI") then 
    CoreGui:FindFirstChild("DashOnlyGUI"):Destroy() 
end

-- ====== Utility Functions ======
local function tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- ====== បង្កើត GUI ======
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "DashOnlyGUI"
gui.IgnoreGuiInset = true

-- ====== Toggle Button (Floating Orb) ======
local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 25, 0.5, -30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
toggleBtn.Image = ""
toggleBtn.ScaleType = Enum.ScaleType.Crop

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Thickness = 2
toggleStroke.Color = Color3.fromRGB(100, 100, 255)
toggleStroke.Transparency = 0.3

local toggleGlow = Instance.new("ImageLabel", toggleBtn)
toggleGlow.Size = UDim2.new(1.4, 0, 1.4, 0)
toggleGlow.Position = UDim2.new(-0.2, 0, -0.2, 0)
toggleGlow.BackgroundTransparency = 1
toggleGlow.Image = "rbxassetid://5028857084"
toggleGlow.ImageColor3 = Color3.fromRGB(100, 100, 255)
toggleGlow.ImageTransparency = 0.8
toggleGlow.ZIndex = -1

-- ====== Main Frame ======
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 380, 0, 160) -- តូចជាងមុន ព្រោះមានតែមួយប៉ុណ្ណោះ
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.ClipsDescendants = true

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 20)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(100, 100, 255)
mainStroke.Transparency = 0.4

-- Shadow
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.Position = UDim2.new(0, -30, 0, -30)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ZIndex = -2

-- Background Gradient
local bgGradient = Instance.new("UIGradient", mainFrame)
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 35))
})
bgGradient.Rotation = 45

-- ====== Header ======
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundTransparency = 1
header.Position = UDim2.new(0, 0, 0, 0)

local headerLine = Instance.new("Frame", header)
headerLine.Size = UDim2.new(1, -40, 0, 1)
headerLine.Position = UDim2.new(0, 20, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
headerLine.BackgroundTransparency = 0.7

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦ AUTO DASH ✦"
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.new(0, 20, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PREMIUM EDITION"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 12)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 10)

-- ====== Content ======
local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, -40, 1, -75)
content.Position = UDim2.new(0, 20, 0, 60)
content.BackgroundTransparency = 1

-- ====== Auto Dash Toggle ======
local dashContainer = Instance.new("Frame", content)
dashContainer.Size = UDim2.new(1, 0, 0, 50)
dashContainer.Position = UDim2.new(0, 0, 0, 0)
dashContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
dashContainer.BackgroundTransparency = 0.3

local dashCorner = Instance.new("UICorner", dashContainer)
dashCorner.CornerRadius = UDim.new(0, 12)

local dashIcon = Instance.new("TextLabel", dashContainer)
dashIcon.Size = UDim2.new(0, 35, 0, 35)
dashIcon.Position = UDim2.new(0, 10, 0.5, -17)
dashIcon.BackgroundTransparency = 1
dashIcon.Text = "💨"
dashIcon.Font = Enum.Font.GothamBold
dashIcon.TextSize = 22

local dashLabel = Instance.new("TextLabel", dashContainer)
dashLabel.Size = UDim2.new(0, 120, 0, 20)
dashLabel.Position = UDim2.new(0, 50, 0, 8)
dashLabel.BackgroundTransparency = 1
dashLabel.Text = "AUTO DASH"
dashLabel.Font = Enum.Font.GothamBold
dashLabel.TextSize = 14
dashLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
dashLabel.TextXAlignment = Enum.TextXAlignment.Left

local dashDesc = Instance.new("TextLabel", dashContainer)
dashDesc.Size = UDim2.new(0, 120, 0, 16)
dashDesc.Position = UDim2.new(0, 50, 0, 28)
dashDesc.BackgroundTransparency = 1
dashDesc.Text = "Teleport dash forward"
dashDesc.Font = Enum.Font.Gotham
dashDesc.TextSize = 10
dashDesc.TextColor3 = Color3.fromRGB(150, 150, 180)
dashDesc.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Switch
local dashToggle = Instance.new("Frame", dashContainer)
dashToggle.Size = UDim2.new(0, 50, 0, 26)
dashToggle.Position = UDim2.new(1, -65, 0.5, -13)
dashToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

local dashToggleCorner = Instance.new("UICorner", dashToggle)
dashToggleCorner.CornerRadius = UDim.new(1, 0)

local dashKnob = Instance.new("Frame", dashToggle)
dashKnob.Size = UDim2.new(0, 22, 0, 22)
dashKnob.Position = UDim2.new(0, 2, 0.5, -11)
dashKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local dashKnobCorner = Instance.new("UICorner", dashKnob)
dashKnobCorner.CornerRadius = UDim.new(1, 0)

local dashBtn = Instance.new("TextButton", dashContainer)
dashBtn.Size = UDim2.new(1, 0, 1, 0)
dashBtn.BackgroundTransparency = 1
dashBtn.Text = ""

-- Status Bar
local statusBar = Instance.new("Frame", mainFrame)
statusBar.Size = UDim2.new(1, 0, 0, 30)
statusBar.Position = UDim2.new(0, 0, 1, -30)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
statusBar.BackgroundTransparency = 0.2

local statusText = Instance.new("TextLabel", statusBar)
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "● Ready | Press [F] to toggle"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 11
statusText.TextColor3 = Color3.fromRGB(120, 120, 150)
statusText.TextXAlignment = Enum.TextXAlignment.Left

-- ====== មុខងារ Toggle Animation ======
local function animateToggle(toggleFrame, knob, state, activeColor)
    if state then
        tween(toggleFrame, {BackgroundColor3 = activeColor}, 0.2)
        tween(knob, {Position = UDim2.new(0, 26, 0.5, -11)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        tween(toggleFrame, {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}, 0.2)
        tween(knob, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end

-- ====== [ Auto Dash Logic ] ======
local dashToggled = false

task.spawn(function()
    while gui.Parent do
        if dashToggled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.MoveDirection.Magnitude > 0 then
                        local dir = hum.MoveDirection
                        local dashMove = Vector3.new(dir.X, 0, dir.Z).Unit * DASH_CONFIG.DASH_DISTANCE
                        root.CFrame = root.CFrame + dashMove
                    end
                end
            end)
            task.wait(DASH_CONFIG.DASH_COOLDOWN)
        else
            task.wait(0.1)
        end
    end
end)

dashBtn.MouseButton1Down:Connect(function()
    dashToggled = not dashToggled
    animateToggle(dashToggle, dashKnob, dashToggled, Color3.fromRGB(0, 150, 255))
    
    if dashToggled then
        tween(dashContainer, {BackgroundColor3 = Color3.fromRGB(15, 35, 50)}, 0.3)
        tween(dashIcon, {TextColor3 = Color3.fromRGB(0, 200, 255)}, 0.3)
        statusText.Text = "● AUTO DASH: ON"
        statusText.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        tween(dashContainer, {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}, 0.3)
        tween(dashIcon, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
        statusText.Text = "● AUTO DASH: OFF"
        statusText.TextColor3 = Color3.fromRGB(120, 120, 150)
    end
end)

-- ====== បើក/បិទ GUI ======
toggleBtn.MouseButton1Down:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        tween(mainFrame, {Size = UDim2.new(0, 380, 0, 160)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

closeBtn.MouseButton1Down:Connect(function()
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    task.wait(0.2)
    dashToggled = false
    gui:Destroy()
end)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}, 0.15)
end)

-- ====== Keybind (F) ======
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            tween(mainFrame, {Size = UDim2.new(0, 380, 0, 160)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
end)

-- ====== Draggable ======
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
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleBtn)

-- ====== Rainbow Effect ======
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.015) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        title.TextColor3 = color
        mainStroke.Color = Color3.fromHSV(hue, 0.6, 0.8)
        toggleStroke.Color = Color3.fromHSV((hue+0.3)%1, 0.8, 1)
        headerLine.BackgroundColor3 = color
        toggleGlow.ImageColor3 = Color3.fromHSV((hue+0.3)%1, 0.8, 1)
        task.wait(0.05)
    end
end)

-- ====== Entrance Animation ======
mainFrame.Size = UDim2.new(0, 0, 0, 0)
tween(mainFrame, {Size = UDim2.new(0, 380, 0, 160)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("✨ Auto Dash GUI Loaded Successfully!")