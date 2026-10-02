-- =========================================================================
-- [ 🌟 SIMPLE TELEPORT + FAST STEAL - BY OUNCOPYBARA 🌟 ]
-- =========================================================================

local success, err = pcall(function()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- [ រកកន្លែងដាក់ GUI សុវត្ថិភាព ]
local function getGUIParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    ok, hui = pcall(function() return game:GetService("CoreGui") end)
    if ok and hui then return hui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GUIParent = getGUIParent()
pcall(function()
    for _, gui in pairs(GUIParent:GetChildren()) do
        if string.find(gui.Name, "SimpleTeleportGUI") then gui:Destroy() end
    end
end)

local BaseCFrame = nil
local FastStealOn = false
local isProcessing = false

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function instantTeleport(targetCFrame)
    local hrp = getCharacter()
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    hrp.CFrame = targetCFrame
end

-- [ បង្កើត GUI ]
local ScreenGui = Instance.new("ScreenGui", GUIParent)
ScreenGui.Name = "SimpleTeleportGUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- បន្ថែមកម្ពស់ GUI ដើម្បីដាក់ប៊ូតុងទី ៣
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 240) 
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 105, 180)

-- Dragging Logic
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
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

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0); TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1; TitleText.Text = "TELEPORT & FAST STEAL"
TitleText.TextColor3 = Color3.fromRGB(255, 182, 193)
TitleText.Font = Enum.Font.GothamBlack; TitleText.TextSize = 12
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.Activated:Connect(function() ScreenGui:Destroy() end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then 
        MainFrame.Visible = not MainFrame.Visible 
    end
end)

-- [ ប៊ូតុងបញ្ជា ]
local function createButton(yPos, text, bgColor)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -30, 0, 40); btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = bgColor; btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local btnSetBase = createButton(55, "📍 កំណត់ទីតាំង (Set Base)", Color3.fromRGB(255, 105, 180))
local btnGoToBase = createButton(105, "🚀 ហោះទៅទីតាំងវិញ", Color3.fromRGB(138, 43, 226))
local btnFastSteal = createButton(155, "⚡ ចុចយកពងលឿន: OFF", Color3.fromRGB(60, 30, 45))

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -30, 0, 30); StatusLabel.Position = UDim2.new(0, 15, 1, -35)
StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "សូមកំណត់ទីតាំងជាមុនសិន"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255); StatusLabel.Font = Enum.Font.GothamBold; StatusLabel.TextSize = 12

local function updateStatus(text, color)
    StatusLabel.Text = text; StatusLabel.TextColor3 = color or Color3.fromRGB(255, 182, 193)
end

-- [ សកម្មភាពប៊ូតុង ]
btnSetBase.Activated:Connect(function()
    local hrp = getCharacter()
    if hrp then
        BaseCFrame = hrp.CFrame
        updateStatus("✅ បានរក្សាទុកទីតាំង!", Color3.fromRGB(100, 255, 100))
    end
end)

btnGoToBase.Activated:Connect(function()
    if not BaseCFrame then
        updateStatus("❌ សូមកំណត់ទីតាំងសិន!", Color3.fromRGB(255, 50, 100))
        return
    end
    instantTeleport(BaseCFrame)
    updateStatus("🚀 បានហោះមកដល់!", Color3.fromRGB(200, 150, 255))
end)

btnFastSteal.Activated:Connect(function()
    if not BaseCFrame then
        updateStatus("❌ សូមកំណត់ទីតាំងសិន!", Color3.fromRGB(255, 50, 100))
        return
    end
    
    FastStealOn = not FastStealOn
    if FastStealOn then
        btnFastSteal.Text = "⚡ ចុចយកពងលឿន: ON"
        btnFastSteal.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        updateStatus("✅ បើកមុខងារយកពងលឿន!", Color3.fromRGB(100, 255, 100))
        
        -- កំណត់ឱ្យការចុចពង (ProximityPrompt) លឿនភ្លាមៗ (HoldDuration = 0)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    else
        btnFastSteal.Text = "⚡ ចុចយកពងលឿន: OFF"
        btnFastSteal.BackgroundColor3 = Color3.fromRGB(60, 30, 45)
        updateStatus("🛑 បានបិទមុខងារយកពងលឿន", Color3.fromRGB(255, 182, 193))
    end
end)

-- [ ប្រព័ន្ធដំណើរការការចុចយកពង ]
local function handleSteal()
    if not FastStealOn or not BaseCFrame or isProcessing then return end
    local hrp = getCharacter()
    if not hrp then return end
    
    isProcessing = true
    local OriginalPos = hrp.CFrame
    
    task.spawn(function()
        instantTeleport(BaseCFrame) -- ហោះទៅ Base ភ្លាមៗ
        task.wait(0.05) -- រង់ចាំបន្តិចឲ្យពងធ្លាក់
        instantTeleport(OriginalPos) -- ហោះត្រឡប់មកវិញភ្លាមៗ
        task.wait(0.1)
        isProcessing = false
    end)
end

local function hookInteractions(v)
    pcall(function()
        if v:IsA("ProximityPrompt") then
            if FastStealOn then v.HoldDuration = 0 end
            v.Triggered:Connect(function(plr) if plr == LocalPlayer then handleSteal() end end)
        elseif v:IsA("ClickDetector") then
            v.MouseClick:Connect(function(plr) if plr == LocalPlayer then handleSteal() end end)
        end
    end)
end

for _, v in pairs(workspace:GetDescendants()) do hookInteractions(v) end
workspace.DescendantAdded:Connect(hookInteractions)

print("✅ Teleport & Fast Steal loaded!")
end)

if not success then warn("❌ Error: " .. tostring(err)) end