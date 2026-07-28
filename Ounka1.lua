--========================================================
-- 🎮 Mobile Combat UI (តាមរូបភាព) + OHK Toggle
-- ដាក់ក្នុង Window GUI ដែលមានប៊ូតុងបើក/បិទ
--========================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local ParentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local TWEEN_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- 🛠️ បង្កើតប៊ូតុងរាងមូល (ដូចក្នុងរូប)
local function createRoundButton(parent, x, y, text, bgColor, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 65, 0, 65)
    btn.Position = UDim2.new(x, 0, y, 0)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = bgColor
    btn.BackgroundTransparency = 0.15
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 11
    btn.Parent = parent
    
    -- ធ្វើឲ្យមូល និងបន្ថែមគែម
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(20, 20, 20)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    return btn
end

-- 🏗️ បង្កើត GUI
local function buildMobileUI()
    if ParentGui:FindFirstChild("Mobile_UI_Window") then
        ParentGui.Mobile_UI_Window:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Mobile_UI_Window"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = ParentGui

    -- 🔘 Toggle Button (សម្រាប់បើក/បិទ Window)
    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleBtn.Image = "rbxassetid://7733960981"
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Parent = screenGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    -- 🪟 Main Window (ដាក់ប៊ូតុងទាំងអស់នៅទីនេះ)
    local mainFrame = Instance.new("CanvasGroup")
    mainFrame.Size = UDim2.new(0, 550, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.GroupTransparency = 1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 2
    mainStroke.Color = Color3.fromRGB(0, 180, 255)

    -- 🖼️ Background Overlay (ធ្វើឲ្យទន់ភ្លន់)
    local overlay = Instance.new("Frame", mainFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    overlay.BackgroundTransparency = 0.4
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 14)

    -- 🔝 Top Bar សម្រាប់អូសទាញ និងចំណងជើង
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ COMBAT CONTROLS"
    title.TextColor3 = Color3.fromRGB(0, 180, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    -- ⚙️ ឡូជីខលអូសទាញ
    local dragging, startPos, objPos = false, nil, nil
    topBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startPos = inp.Position; objPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            mainFrame.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + (inp.Position.X - startPos.X), objPos.Y.Scale, objPos.Y.Offset + (inp.Position.Y - startPos.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- =========================================================
    -- 🎯 ដាក់ប៊ូតុងតាមរូបភាព (ដាក់ទីតាំងក្នុង Window)
    -- =========================================================
    -- D-Pad (ព្រួញចលនា)
    local dPad = createRoundButton(mainFrame, 0.12, 0.75, "⬆\n⬇", Color3.fromRGB(30, 30, 30), UDim2.new(0, 80, 0, 80))
    
    -- LIGHT (ពណ៌ទឹកក្រូច) - នៅពីលើ D-Pad បន្តិច
    local lightBtn = createRoundButton(mainFrame, 0.12, 0.55, "LIGHT", Color3.fromRGB(255, 150, 50))
    
    -- HEAVY (ពណ៌ក្រហម)
    local heavyBtn = createRoundButton(mainFrame, 0.26, 0.75, "HEAVY", Color3.fromRGB(255, 50, 50))
    
    -- BLOCK (ពណ៌ស/ប្រផេះ)
    local blockBtn = createRoundButton(mainFrame, 0.26, 0.90, "BLOCK", Color3.fromRGB(220, 220, 220))
    
    -- DODGE (ពណ៌ស្វាយ)
    local dodgeBtn = createRoundButton(mainFrame, 0.40, 0.65, "DODGE", Color3.fromRGB(162, 0, 255))
    
    -- EQUIP (ពណ៌បៃតង)
    local equipBtn = createRoundButton(mainFrame, 0.70, 0.65, "EQUIP", Color3.fromRGB(0, 200, 0))
    
    -- RUN (ពណ៌ស/ប្រផេះ)
    local runBtn = createRoundButton(mainFrame, 0.70, 0.85, "RUN", Color3.fromRGB(220, 220, 220))

    -- 💀 OHK Toggle Button (វាយមួយងាប់) - ដាក់នៅចន្លោះកណ្តាលខាងលើ
    local ohkBtn = createRoundButton(mainFrame, 0.55, 0.40, "OHK\nOFF", Color3.fromRGB(255, 50, 50), UDim2.new(0, 65, 0, 65))

    -- =========================================================
    -- 🎯 ឡូជីខល OHK បើក/បិទ និងសម្លាប់
    -- =========================================================
    local ohkEnabled = false
    ohkBtn.MouseButton1Click:Connect(function()
        ohkEnabled = not ohkEnabled
        if ohkEnabled then
            TweenService:Create(ohkBtn, TWEEN_SMOOTH, {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
            ohkBtn.Text = "OHK\nON"
        else
            TweenService:Create(ohkBtn, TWEEN_SMOOTH, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
            ohkBtn.Text = "OHK\nOFF"
        end
    end)

    -- ពេលចុចកណ្ដុរ បើ OHK បើក សម្លាប់អ្នកលេង
    local mouse = LocalPlayer:GetMouse()
    UserInputService.InputBegan:Connect(function(input, gP)
        if gP then return end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ohkEnabled then
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent ~= LocalPlayer.Character then
                target.Parent.Humanoid.Health = 0
            end
        end
    end)

    -- 🎬 Animation បើក/បិទ Window
    local isOpen = false
    local function toggleWindow()
        isOpen = not isOpen
        mainFrame.Visible = true
        if isOpen then
            TweenService:Create(mainFrame, TWEEN_SMOOTH, {GroupTransparency = 0}):Play()
            TweenService:Create(toggleBtn, TWEEN_SMOOTH, {Rotation = 180}):Play()
        else
            local anim = TweenService:Create(mainFrame, TWEEN_SMOOTH, {GroupTransparency = 1})
            anim:Play()
            TweenService:Create(toggleBtn, TWEEN_SMOOTH, {Rotation = 0}):Play()
            anim.Completed:Wait()
            mainFrame.Visible = false
        end
    end

    toggleBtn.MouseButton1Click:Connect(toggleWindow)
    closeBtn.MouseButton1Click:Connect(toggleWindow)
end

-- ដំណើរការ
buildMobileUI()