--========================================================
-- 🎮 MOBILE-STYLE COMBAT UI (ដូចរូបភាព) + OHK Toggle
--========================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local ParentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- ⚙️ CONFIG
local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- 🛠️ HELPER: ធ្វើឲ្យបន្ទះអាចអូសបាន (អនុវត្តលើបន្ទះទាំងមូល)
local function makeDraggable(targetFrame)
    local dragging, startPos, objPos
    targetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            objPos = targetFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            targetFrame.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- 🛠️ HELPER: បង្កើតប៊ូតុងរាងមូលតាមរចនាប័ទ្មរូបភាព
local function createRoundButton(parent, pos, text, bgColor, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 70, 0, 70)
    btn.Position = pos
    btn.AnchorPoint = Vector2.new(0.5, 0.5) -- ធ្វើឲ្យចំណុចកណ្តាលស្របនឹងទីតាំង
    btn.BackgroundColor3 = bgColor
    btn.BackgroundTransparency = 0.15 -- តម្លាភាពបន្តិចដូចរូបភាព
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 12
    btn.Parent = parent
    
    -- ធ្វើឲ្យមូល
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)
    
    -- បន្ថែមគែម (ដូចរូបភាព)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.new(0, 0, 0) -- គែមខ្មៅ
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    return btn
end

-- 🏗️ បង្កើត UI
local function buildMobileUI()
    if ParentGui:FindFirstChild("Mobile_Combat_UI") then
        ParentGui.Mobile_Combat_UI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Mobile_Combat_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = ParentGui

    -- បន្ទះផ្ទុកប៊ូតុង (ថ្លា និងអាចអូសបាន)
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(1, 0, 1, 0)
    mainContainer.Position = UDim2.new(0, 0, 0, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = screenGui

    -- អនុញ្ញាតឲ្យអូសបន្ទះទាំងមូលដោយចុចលើផ្ទៃខាងក្រោយ
    local dragHandle = Instance.new("Frame")
    dragHandle.Size = UDim2.new(1, 0, 1, 0)
    dragHandle.BackgroundTransparency = 1
    dragHandle.Parent = mainContainer
    makeDraggable(dragHandle)

    -- 🟠 ប៊ូតុង LIGHT (ពណ៌ទឹកក្រូច)
    local lightBtn = createRoundButton(mainContainer, UDim2.new(0.15, 0, 0.65, 0), "LIGHT", Color3.fromRGB(255, 150, 50))
    
    -- 🔴 ប៊ូតុង HEAVY (ពណ៌ក្រហម)
    local heavyBtn = createRoundButton(mainContainer, UDim2.new(0.25, 0, 0.78, 0), "HEAVY", Color3.fromRGB(255, 50, 50))
    
    -- 🟣 ប៊ូតុង DODGE (ពណ៌ស្វាយ)
    local dodgeBtn = createRoundButton(mainContainer, UDim2.new(0.25, 0, 0.52, 0), "DODGE", Color3.fromRGB(162, 0, 255))
    
    -- 🟢 ប៊ូតុង EQUIP (ពណ៌បៃតង)
    local equipBtn = createRoundButton(mainContainer, UDim2.new(0.65, 0, 0.58, 0), "EQUIP", Color3.fromRGB(0, 255, 0))
    
    -- ⚪ ប៊ូតុង RUN (ពណ៌ប្រផេះ)
    local runBtn = createRoundButton(mainContainer, UDim2.new(0.78, 0, 0.70, 0), "RUN", Color3.fromRGB(200, 200, 200))
    
    -- ⚪ ប៊ូតុង BLOCK (ពណ៌ប្រផេះ)
    local blockBtn = createRoundButton(mainContainer, UDim2.new(0.38, 0, 0.85, 0), "BLOCK", Color3.fromRGB(200, 200, 200))

    -- D-PAD (ព្រួញចលនា បង្កើតជារូបភាពរង្វង់ខ្មៅ)
    local dpad = Instance.new("ImageButton")
    dpad.Size = UDim2.new(0, 90, 0, 90)
    dpad.Position = UDim2.new(0.08, 0, 0.78, 0)
    dpad.AnchorPoint = Vector2.new(0.5, 0.5)
    dpad.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dpad.Image = "rbxassetid://6435805724" -- រូបព្រួញខ្មៅ
    dpad.ScaleType = Enum.ScaleType.Fit
    dpad.Parent = mainContainer
    local dpadCorner = Instance.new("UICorner", dpad)
    dpadCorner.CornerRadius = UDim.new(1, 0)
    local dpadStroke = Instance.new("UIStroke", dpad)
    dpadStroke.Color = Color3.new(0, 0, 0)
    dpadStroke.Thickness = 3

    -- ==========================================
    -- 💀 បន្ថែមប៊ូតុង OHK (វាយមួយងាប់) ដែលមានកុងតាក់បើក/បិទ
    -- ==========================================
    local ohkBtn = createRoundButton(mainContainer, UDim2.new(0.50, 0, 0.48, 0), "OHK", Color3.fromRGB(255, 50, 50)) -- ក្រហមដើម
    
    local ohkEnabled = false
    ohkBtn.MouseButton1Click:Connect(function()
        ohkEnabled = not ohkEnabled
        if ohkEnabled then
            TweenService:Create(ohkBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play() -- ពណ៌បៃតង (បើក)
            ohkBtn.Text = "OHK\nON"
        else
            TweenService:Create(ohkBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play() -- ពណ៌ក្រហម (បិទ)
            ohkBtn.Text = "OHK\nOFF"
        end
    end)

    -- 🎯 ឡូជីខល OHK (ចុចកណ្ដុរសម្លាប់អ្នកលេង)
    local mouse = LocalPlayer:GetMouse()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ohkEnabled then
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent ~= LocalPlayer.Character then
                target.Parent.Humanoid.Health = 0
            end
        end
    end)
end

-- 🚀 ដំណើរការ UI
buildMobileUI()