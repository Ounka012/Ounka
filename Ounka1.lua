-- =====================================================================
-- [ Protected Script - ouncopybara UI ]
-- =====================================================================

local _0xKey = 37
local _0xVM = {
    "91948886910D8C8E818E8B910D9A0D819A81928384938383850D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D" ..
    "0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D"
}

local function _0xDec(_s)
    local _out = {}
    for _i = 1, #_s, 2 do
        local _b = tonumber(_s:sub(_i, _i + 1), 16)
        if _b then
            table.insert(_out, string.char((_b - _0xKey) % 256))
        end
    end
    return table.concat(_out)
end

-- Reconstruct original code execution
local function _0xExec()
    local getenv = getgenv or function() return _G end
    local env = getenv()

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "RoxnameFlyUI" then gui:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoxnameFlyUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    local glowingTexts = {}

    local OpenFrame = Instance.new("Frame")
    OpenFrame.Size = UDim2.new(0, 45, 0, 45)
    OpenFrame.Position = UDim2.new(0, 20, 0.5, -20)
    OpenFrame.BackgroundColor3 = Color3.fromRGB(45, 20, 35)
    OpenFrame.Visible = false
    OpenFrame.Parent = ScreenGui
    Instance.new("UICorner", OpenFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", OpenFrame).Color = Color3.fromRGB(255, 105, 180)
    Instance.new("UIStroke", OpenFrame).Thickness = 2

    local OpenBtn = Instance.new("TextButton", OpenFrame)
    OpenBtn.Size = UDim2.new(1, 0, 1, 0)
    OpenBtn.BackgroundTransparency = 1
    OpenBtn.Text = "✈️"
    OpenBtn.TextSize = 20

    local draggingOpen, dragStartOpen, startPosOpen
    OpenFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingOpen = true; dragStartOpen = input.Position; startPosOpen = OpenFrame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingOpen and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartOpen
            OpenFrame.Position = UDim2.new(startPosOpen.X.Scale, startPosOpen.X.Offset + delta.X, startPosOpen.Y.Scale, startPosOpen.Y.Offset + delta.Y)
        end
    end)
    OpenFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingOpen = false end
    end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 280, 0, 530) 
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -265)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke", MainFrame)
    mainStroke.Color = Color3.fromRGB(255, 105, 180); mainStroke.Thickness = 1.5

    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -70, 0, 30); Title.Position = UDim2.new(0, 15, 0, 5); Title.BackgroundTransparency = 1; Title.Text = "ouncopybara | Custom Fly UI"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(glowingTexts, Title)

    local MinBtn = Instance.new("TextButton", MainFrame)
    MinBtn.Size = UDim2.new(0, 24, 0, 24); MinBtn.Position = UDim2.new(1, -62, 0, 8); MinBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180); MinBtn.Text = "_"; MinBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.Position = UDim2.new(1, -32, 0, 8); CloseBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local currentSpeedValue = 100 
    local SpeedLabel = Instance.new("TextLabel", MainFrame)
    SpeedLabel.Size = UDim2.new(0, 240, 0, 15); SpeedLabel.Position = UDim2.new(0, 20, 0, 40); SpeedLabel.BackgroundTransparency = 1; SpeedLabel.Text = "ល្បឿនហោះទូទៅ (Fly Speed):"; SpeedLabel.Font = Enum.Font.Gotham; SpeedLabel.TextSize = 10; SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(glowingTexts, SpeedLabel)

    local MinusBtn = Instance.new("TextButton", MainFrame)
    MinusBtn.Size = UDim2.new(0, 35, 0, 30); MinusBtn.Position = UDim2.new(0, 20, 0, 58); MinusBtn.BackgroundColor3 = Color3.fromRGB(75, 30, 55); MinusBtn.Text = "-"; MinusBtn.Font = Enum.Font.GothamBold; MinusBtn.TextSize = 20; Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 8)
    table.insert(glowingTexts, MinusBtn)

    local SpeedBox = Instance.new("TextBox", MainFrame)
    SpeedBox.Size = UDim2.new(0, 140, 0, 30); SpeedBox.Position = UDim2.new(0, 70, 0, 58); SpeedBox.BackgroundColor3 = Color3.fromRGB(55, 20, 40); SpeedBox.Font = Enum.Font.GothamBold; SpeedBox.TextSize = 14; SpeedBox.Text = tostring(currentSpeedValue); Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", SpeedBox).Color = Color3.fromRGB(255, 105, 180)
    table.insert(glowingTexts, SpeedBox)

    local PlusBtn = Instance.new("TextButton", MainFrame)
    PlusBtn.Size = UDim2.new(0, 35, 0, 30); PlusBtn.Position = UDim2.new(0, 225, 0, 58); PlusBtn.BackgroundColor3 = Color3.fromRGB(75, 30, 55); PlusBtn.Text = "+"; PlusBtn.Font = Enum.Font.GothamBold; PlusBtn.TextSize = 18; Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 8)
    table.insert(glowingTexts, PlusBtn)

    local currentAscendHeight = 400
    local AscendLabel = Instance.new("TextLabel", MainFrame)
    AscendLabel.Size = UDim2.new(0, 240, 0, 15); AscendLabel.Position = UDim2.new(0, 20, 0, 95); AscendLabel.BackgroundTransparency = 1; AscendLabel.Text = "កម្ពស់ហោះឡើង (Ascend Height):"; AscendLabel.Font = Enum.Font.Gotham; AscendLabel.TextSize = 10; AscendLabel.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(glowingTexts, AscendLabel)

    local AscendMinus = Instance.new("TextButton", MainFrame)
    AscendMinus.Size = UDim2.new(0, 35, 0, 30); AscendMinus.Position = UDim2.new(0, 20, 0, 113); AscendMinus.BackgroundColor3 = Color3.fromRGB(75, 30, 55); AscendMinus.Text = "-"; AscendMinus.Font = Enum.Font.GothamBold; AscendMinus.TextSize = 20; Instance.new("UICorner", AscendMinus).CornerRadius = UDim.new(0, 8)
    table.insert(glowingTexts, AscendMinus)

    local AscendBox = Instance.new("TextBox", MainFrame)
    AscendBox.Size = UDim2.new(0, 140, 0, 30); AscendBox.Position = UDim2.new(0, 70, 0, 113); AscendBox.BackgroundColor3 = Color3.fromRGB(55, 20, 40); AscendBox.Font = Enum.Font.GothamBold; AscendBox.TextSize = 14; AscendBox.Text = tostring(currentAscendHeight); Instance.new("UICorner", AscendBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", AscendBox).Color = Color3.fromRGB(255, 105, 180)
    table.insert(glowingTexts, AscendBox)

    local AscendPlus = Instance.new("TextButton", MainFrame)
    AscendPlus.Size = UDim2.new(0, 35, 0, 30); AscendPlus.Position = UDim2.new(0, 225, 0, 113); AscendPlus.BackgroundColor3 = Color3.fromRGB(75, 30, 55); AscendPlus.Text = "+"; AscendPlus.Font = Enum.Font.GothamBold; AscendPlus.TextSize = 18; Instance.new("UICorner", AscendPlus).CornerRadius = UDim.new(0, 8)
    table.insert(glowingTexts, AscendPlus)

    local currentDescentSpeed = 25
    local DescentLabel = Instance.new("TextLabel", MainFrame)
    DescentLabel.Size = UDim2.new(0, 240, 0, 15); DescentLabel.Position = UDim2.new(0, 20, 0, 150); DescentLabel.BackgroundTransparency = 1; DescentLabel.Text = "ល្បឿនចុះយកពង (Descent Speed):"; DescentLabel.Font = Enum.Font.Gotham; DescentLabel.TextSize = 10; DescentLabel.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(glowingTexts, DescentLabel)

    local DescentMinus = Instance.new("TextButton", MainFrame)
    DescentMinus.Size = UDim2.new(0, 35, 0, 30); DescentMinus.Position = UDim2.new(0, 20, 0, 168); DescentMinus.BackgroundColor3 = Color3.fromRGB(75, 30, 55); DescentMinus.Text = "-"; DescentMinus.Font = Enum.Font.GothamBold; DescentMinus.TextSize = 20; Instance.new("UICorner", DescentMinus).CornerRadius = UDim.new(0, 8)
    table.insert(glowingTexts, DescentMinus)

    local DescentBox = Instance.new("TextBox", MainFrame)
    DescentBox.Size = UDim2.new(0, 140, 0, 30); DescentBox.Position = UDim2.new(0, 70, 0, 168); DescentBox.BackgroundColor3 = Color3.fromRGB(55, 20, 40); DescentBox.Font = Enum.Font.GothamBold; DescentBox.TextSize = 14; DescentBox.Text = tostring(currentDescentSpeed); Instance.new("UICorner", DescentBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", DescentBox).Color = Color3.fromRGB(255, 105, 180)
    table.insert(glowingTexts, DescentBox)

    local DescentPlus = Instance.new("TextButton", MainFrame)
    DescentPlus.Size = UDim2.new(0, 35, 0, 30); DescentPlus.Position = UDim2.new(0, 225, 0, 168); DescentPlus.BackgroundColor3 = Color3.fromRGB(75, 30, 55); DescentPlus.Text = "+"; DescentPlus.Font = Enum.Font.GothamBold; DescentPlus.TextSize = 18; Instance.new("UICorner", DescentPlus).CornerRadius = UDim.new(0, 8)
    table.insert(glowingTexts, DescentPlus)

    local FlyBtn = Instance.new("TextButton", MainFrame)
    FlyBtn.Size = UDim2.new(0, 240, 0, 38); FlyBtn.Position = UDim2.new(0, 20, 0, 210); FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180); FlyBtn.Text = "ចាប់ផ្ដើមហោះ (FLY ON)"; FlyBtn.Font = Enum.Font.GothamBold; FlyBtn.TextSize = 13; Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 6)
    table.insert(glowingTexts, FlyBtn)

    local NoclipBtn = Instance.new("TextButton", MainFrame)
    NoclipBtn.Size = UDim2.new(0, 240, 0, 38); NoclipBtn.Position = UDim2.new(0, 20, 0, 253); NoclipBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147); NoclipBtn.Text = "ឆ្លុះជញ្ជាំង (NOCLIP OFF)"; NoclipBtn.Font = Enum.Font.GothamBold; NoclipBtn.TextSize = 13; Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 6)
    table.insert(glowingTexts, NoclipBtn)

    local EggListBtn = Instance.new("TextButton", MainFrame)
    EggListBtn.Size = UDim2.new(0, 240, 0, 38); EggListBtn.Position = UDim2.new(0, 20, 0, 296); EggListBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147); EggListBtn.Text = "បង្ហាញបញ្ជីពង (EGG LIST OFF)"; EggListBtn.Font = Enum.Font.GothamBold; EggListBtn.TextSize = 13; Instance.new("UICorner", EggListBtn).CornerRadius = UDim.new(0, 6)
    table.insert(glowingTexts, EggListBtn)

    local InfoText = Instance.new("TextLabel", MainFrame)
    InfoText.Size = UDim2.new(0, 240, 0, 15); InfoText.Position = UDim2.new(0, 20, 0, 337); InfoText.BackgroundTransparency = 1; InfoText.Text = "Script by ouncopybara"; InfoText.Font = Enum.Font.Gotham; InfoText.TextSize = 9; InfoText.Visible = false
    table.insert(glowingTexts, InfoText)

    local EggListScroll = Instance.new("ScrollingFrame", MainFrame)
    EggListScroll.Size = UDim2.new(0, 240, 0, 150); EggListScroll.Position = UDim2.new(0, 20, 0, 355); EggListScroll.BackgroundColor3 = Color3.fromRGB(25, 10, 20); EggListScroll.BorderSizePixel = 0; EggListScroll.ScrollBarThickness = 4; Instance.new("UICorner", EggListScroll).CornerRadius = UDim.new(0, 6)

    local UIListLayout = Instance.new("UIListLayout", EggListScroll)
    UIListLayout.Padding = UDim.new(0, 5); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() EggListScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10) end)

    MinBtn.Activated:Connect(function() MainFrame.Visible = false; OpenFrame.Visible = true end)
    OpenBtn.Activated:Connect(function() MainFrame.Visible = true; OpenFrame.Visible = false end)

    RunService.RenderStepped:Connect(function()
        local hue = (tick() % 3) / 3 
        local color = Color3.fromHSV(hue, 0.7, 1) 
        for _, textObject in pairs(glowingTexts) do
            if textObject and textObject.Parent then textObject.TextColor3 = color end
        end
    end)

    local currentTrail = nil
    local function createTrail(parentPart)
        if currentTrail then currentTrail:Destroy() end
        local attachment0 = Instance.new("Attachment", parentPart)
        attachment0.Name = "TrailAttachment0"
        attachment0.Position = Vector3.new(0, 1, 0)
        
        local attachment1 = Instance.new("Attachment", parentPart)
        attachment1.Name = "TrailAttachment1"
        attachment1.Position = Vector3.new(0, -1, 0)

        local trail = Instance.new("Trail")
        trail.Name = "ouncopybaraTrail"
        trail.Attachment0 = attachment0
        trail.Attachment1 = attachment1
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 105, 180)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(50, 205, 50)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 69, 0))
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.2),
            NumberSequenceKeypoint.new(1, 1)
        })
        trail.Lifetime = 0.8
        trail.MinLength = 0.1
        trail.Parent = parentPart
        currentTrail = trail
    end

    local function removeTrail()
        if currentTrail then
            currentTrail:Destroy()
            currentTrail = nil
        end
    end

    local isFlying, isNoclip = false, false
    local flyLoop, noclipLoop, bodyVelocity, bodyGyro

    local function updateSpeedDisplay() SpeedBox.Text = tostring(currentSpeedValue) end
    MinusBtn.Activated:Connect(function() currentSpeedValue = math.max(10, currentSpeedValue - 10); updateSpeedDisplay() end)
    PlusBtn.Activated:Connect(function() currentSpeedValue = currentSpeedValue + 10; updateSpeedDisplay() end)
    SpeedBox.FocusLost:Connect(function() local val = tonumber(SpeedBox.Text); currentSpeedValue = val and math.max(10, val) or 100; updateSpeedDisplay() end)

    local function updateAscendDisplay() AscendBox.Text = tostring(currentAscendHeight) end
    AscendMinus.Activated:Connect(function() currentAscendHeight = math.max(50, currentAscendHeight - 50); updateAscendDisplay() end)
    AscendPlus.Activated:Connect(function() currentAscendHeight = currentAscendHeight + 50; updateAscendDisplay() end)
    AscendBox.FocusLost:Connect(function() local val = tonumber(AscendBox.Text); currentAscendHeight = val and math.max(50, val) or 400; updateAscendDisplay() end)

    local function updateDescentDisplay() DescentBox.Text = tostring(currentDescentSpeed) end
    DescentMinus.Activated:Connect(function() currentDescentSpeed = math.max(5, currentDescentSpeed - 5); updateDescentDisplay() end)
    DescentPlus.Activated:Connect(function() currentDescentSpeed = currentDescentSpeed + 5; updateDescentDisplay() end)
    DescentBox.FocusLost:Connect(function() local val = tonumber(DescentBox.Text); currentDescentSpeed = val and math.max(5, val) or 25; updateDescentDisplay() end)

    local function stopFly()
        isFlying = false; FlyBtn.Text = "ចាប់ផ្ដើមហោះ (FLY ON)"; FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
        if flyLoop then flyLoop:Disconnect() end; if bodyVelocity then bodyVelocity:Destroy() end; if bodyGyro then bodyGyro:Destroy() end
        removeTrail()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
    end

    local function startFly()
        local char = LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        isFlying = true; FlyBtn.Text = "បញ្ឈប់ហោះ (FLY OFF)"; FlyBtn.BackgroundColor3 = Color3.fromRGB(199, 21, 133); hum.PlatformStand = true
        bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart); bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart); bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bodyGyro.P = 3000; bodyGyro.CFrame = Camera.CFrame
        
        createTrail(char.HumanoidRootPart)

        flyLoop = RunService.RenderStepped:Connect(function()
            if not isFlying or not char or not hum or hum.Health <= 0 then stopFly(); return end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                bodyVelocity.Velocity = Camera.CFrame.LookVector * (moveDir.Z * -currentSpeedValue) + Camera.CFrame.RightVector * (moveDir.X * currentSpeedValue)
            else bodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            bodyGyro.CFrame = Camera.CFrame
        end)
    end
    FlyBtn.Activated:Connect(function() if isFlying then stopFly() else startFly() end end)

    local function toggleNoclip()
        isNoclip = not isNoclip
        if isNoclip then
            NoclipBtn.Text = "កំពុងឆ្លុះជញ្ជាំង (NOCLIP ON)"; NoclipBtn.BackgroundColor3 = Color3.fromRGB(199, 21, 133)
            noclipLoop = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end
            end)
        else NoclipBtn.Text = "ឆ្លុះជញ្ជាំង (NOCLIP OFF)"; NoclipBtn.BackgroundColor3 = Color3.fromRGB(219, 112, 147); if noclipLoop then noclipLoop:Disconnect() end end
    end
    NoclipBtn.Activated:Connect(function() toggleNoclip() end)

    local function triggerPrompt(prompt)
        if not prompt then return end
        local firePrompt = fireproximityprompt or env.fireproximityprompt
        if firePrompt then pcall(function() firePrompt(prompt, 1, true) end) else pcall(function() prompt:InputHoldBegin() end) end
    end
    local function triggerClick(clicker)
        if not clicker then return end
        local fireClick = fireclickdetector or env.fireclickdetector
        if fireClick then pcall(function() fireClick(clicker) end) end
    end

    local isEggList = false
    local espObjects = {}
    local espAddedConn, espLoopConn

    local function createListItem(instance)
        for _, obj in pairs(espObjects) do if obj.instance == instance then return end end
        
        local part = nil
        if instance:IsA("BasePart") then part = instance 
        elseif instance:IsA("Model") then part = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart") 
        end
        if not part then return end

        local kgScore = 0
        if instance:IsA("Model") then
            local _, size = instance:GetBoundingBox()
            kgScore = size.X * size.Y * size.Z
        elseif part then
            kgScore = part.Size.X * part.Size.Y * part.Size.Z
        end

        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, -10, 0, 45)
        itemBtn.BackgroundColor3 = Color3.fromRGB(55, 20, 40)
        itemBtn.Font = Enum.Font.GothamSemibold
        itemBtn.TextSize = 11
        itemBtn.TextXAlignment = Enum.TextXAlignment.Right
        itemBtn.Visible = false
        table.insert(glowingTexts, itemBtn) 
        
        local padding = Instance.new("UIPadding", itemBtn)
        padding.PaddingRight = UDim.new(0, 10)
        Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 6)
        itemBtn.Parent = EggListScroll

        task.spawn(function()
            local viewport = Instance.new("ViewportFrame", itemBtn)
            viewport.Size = UDim2.new(0, 38, 0, 38); viewport.Position = UDim2.new(0, 4, 0.5, -19); viewport.BackgroundTransparency = 1
            viewport.LightColor = Color3.fromRGB(255, 255, 255); viewport.Ambient = Color3.fromRGB(160, 160, 160)

            local targetToClone = instance:IsA("Model") and instance or part
            targetToClone.Archivable = true
            for _, desc in pairs(targetToClone:GetDescendants()) do desc.Archivable = true end

            local clone = targetToClone:Clone()
            if clone then
                for _, v in pairs(clone:GetDescendants()) do if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ParticleEmitter") or v:IsA("Sound") or v:IsA("Light") then v:Destroy() end end
                local worldModel = Instance.new("WorldModel", viewport)
                clone.Parent = worldModel

                local cf, size
                if clone:IsA("Model") then cf, size = clone:GetBoundingBox(); clone:PivotTo(CFrame.new(Vector3.zero))
                else cf, size = clone.CFrame, clone.Size; clone.CFrame = CFrame.new(Vector3.zero) end

                local maxDim = math.max(size.X, size.Y, size.Z)
                local vCam = Instance.new("Camera"); vCam.FieldOfView = 70
                local distance = (maxDim / 2) / math.tan(math.rad(vCam.FieldOfView) / 2)
                vCam.CFrame = CFrame.new(Vector3.new(0, 0, distance + (maxDim / 2)), Vector3.zero)
                viewport.CurrentCamera = vCam; vCam.Parent = viewport
            end
        end)

        local isProcessing = false
        itemBtn.Activated:Connect(function()
            if isProcessing then return end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char.HumanoidRootPart
                if not hum or not part or not part.Parent then return end

                isProcessing = true
                itemBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
                
                local originalPosition = hrp.CFrame
                hum.PlatformStand = true

                local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 3000

                createTrail(hrp)

                local reachedTarget = false
                local eggPos = part.Position
                local flyAltitude = math.max(originalPosition.Y + currentAscendHeight, eggPos.Y + currentAscendHeight)

                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not part or not part.Parent or not hrp then if connection then connection:Disconnect() end return end
                    
                    local currentPos = hrp.Position
                    local updatedEggPos = part.Position
                    
                    local horizDist = (Vector3.new(updatedEggPos.X, 0, updatedEggPos.Z) - Vector3.new(currentPos.X, 0, currentPos.Z)).Magnitude
                    local totalDist = (updatedEggPos - currentPos).Magnitude

                    local targetWaypoint
                    local lookAt
                    
                    if horizDist > 25 then
                        if currentPos.Y < flyAltitude - 15 then
                            targetWaypoint = Vector3.new(currentPos.X, flyAltitude, currentPos.Z)
                            bv.Velocity = Vector3.new(0, currentSpeedValue, 0)
                        else
                            targetWaypoint = Vector3.new(updatedEggPos.X, flyAltitude, updatedEggPos.Z)
                            bv.Velocity = (targetWaypoint - currentPos).Unit * currentSpeedValue
                        end
                        lookAt = Vector3.new(updatedEggPos.X, currentPos.Y, updatedEggPos.Z)
                    else
                        targetWaypoint = updatedEggPos
                        bv.Velocity = (targetWaypoint - currentPos).Unit * currentDescentSpeed
                        lookAt = updatedEggPos - Vector3.new(0, 2, 0)
                    end
                    
                    if (lookAt - currentPos).Magnitude > 1 then
                        bg.CFrame = CFrame.new(currentPos, lookAt)
                    end
                    
                    if totalDist <= 3.5 then
                        bv.Velocity = Vector3.new(0, 0, 0)
                        reachedTarget = true
                    end
                end)

                local flyTimeout = tick() + 40
                while not reachedTarget and part and part.Parent and tick() < flyTimeout do task.wait(0.1) end

                local targetPrompt = instance:FindFirstChildWhichIsA("ProximityPrompt", true) or part:FindFirstChildWhichIsA("ProximityPrompt", true)
                local cd = instance:FindFirstChildWhichIsA("ClickDetector", true) or part:FindFirstChildWhichIsA("ClickDetector", true)

                triggerPrompt(targetPrompt)
                local holdDuration = targetPrompt and (targetPrompt.HoldDuration + 1) or 3
                local collectTimeout = tick() + holdDuration
                while tick() < collectTimeout and part and part.Parent do triggerClick(cd); task.wait(0.2) end
                if targetPrompt and not (fireproximityprompt or env.fireproximityprompt) then pcall(function() targetPrompt:InputHoldEnd() end) end

                task.wait(0.5)
                if connection then connection:Disconnect() end
                bv:Destroy(); bg:Destroy()
                removeTrail()
                
                hrp.CFrame = originalPosition
                hum.PlatformStand = false
                itemBtn.BackgroundColor3 = Color3.fromRGB(55, 20, 40)
                isProcessing = false
            end
        end)
        table.insert(espObjects, { label = itemBtn, part = part, instance = instance, kg = kgScore })
    end

    EggListBtn.Activated:Connect(function()
        isEggList = not isEggList
        if isEggList then
            InfoText.Visible = true; InfoText.Text = "Script by ouncopybara"; EggListBtn.Text = "កំពុងស្កេនរកពង (EGG LIST ON)"; EggListBtn.BackgroundColor3 = Color3.fromRGB(199, 21, 133)
            task.spawn(function()
                for i, v in ipairs(Workspace:GetDescendants()) do
                    if not isEggList then break end
                    if string.find(string.lower(v.Name), "egg") then if v:IsA("BasePart") or v:IsA("Model") then createListItem(v) end end
                    if i % 300 == 0 then task.wait() end 
                end
            end)
            espAddedConn = Workspace.DescendantAdded:Connect(function(v)
                if string.find(string.lower(v.Name), "egg") and (v:IsA("BasePart") or v:IsA("Model")) then createListItem(v) end
            end)
            espLoopConn = RunService.RenderStepped:Connect(function()
                local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
                for i = #espObjects, 1, -1 do
                    local obj = espObjects[i]
                    if obj.part and obj.part.Parent and obj.instance and obj.instance.Parent then
                        if playerPos then
                            local dist = math.floor((obj.part.Position - playerPos).Magnitude)
                            
                            if dist >= 1000 then
                                obj.label.Visible = true
                                if obj.label.BackgroundColor3 ~= Color3.fromRGB(255, 20, 147) then
                                    obj.label.Text = obj.instance.Name .. " [" .. math.floor(obj.kg) .. " KG] [" .. dist .. "m]"
                                else
                                    obj.label.Text = "✈️ កំពុងហោះទៅយកពង..."
                                end
                                obj.label.LayoutOrder = -math.floor(obj.kg * 10)
                            else
                                obj.label.Visible = false
                            end
                        end
                    else
                        if obj.label then obj.label:Destroy() end
                        table.remove(espObjects, i)
                    end
                end
            end)
        else
            InfoText.Visible = false; EggListBtn.Text = "បង្ហាញបញ្ជីពង (EGG LIST OFF)"; EggListBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
            if espAddedConn then espAddedConn:Disconnect() end; if espLoopConn then espLoopConn:Disconnect() end
            for _, obj in pairs(espObjects) do if obj.label then obj.label:Destroy() end end; espObjects = {}
        end
    end)

    CloseBtn.Activated:Connect(function() stopFly(); removeTrail(); if isNoclip then toggleNoclip() end; if isEggList then if espAddedConn then espAddedConn:Disconnect() end; if espLoopConn then espLoopConn:Disconnect() end end; ScreenGui:Destroy() end)
    LocalPlayer.CharacterAdded:Connect(function() if isFlying then stopFly() end; removeTrail(); if isNoclip then toggleNoclip() end end)
end

_0xExec()
