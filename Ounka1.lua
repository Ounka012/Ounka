-- =========================================================================
-- [ 🌟 VIP FAST STEAL (AGGRESSIVE MODE) - BY OUNCOPYBARA 🌟 ]
-- =========================================================================

local success, err = pcall(function()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 240) 
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 18) -- ពណ៌ខ្មៅរាងក្រម៉ៅជាងមុន
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2.5
UIStroke.Color = Color3.fromRGB(255, 50, 100) -- ពណ៌ក្រហមឆ្អៅ VIP

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
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 20, 30)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0); TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1; TitleText.Text = "⚡ VIP FAST STEAL"
TitleText.TextColor3 = Color3.fromRGB(255, 150, 180)
TitleText.Font = Enum.Font.GothamBlack; TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
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
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local btnSetBase = createButton(55, "📍 កំណត់ទីតាំង Base", Color3.fromRGB(255, 105, 180))
local btnGoToBase = createButton(105, "🚀 ហោះទៅ Base", Color3.fromRGB(138, 43, 226))
local btnFastSteal = createButton(155, "⚡ លួចពងលឿន VIP: OFF", Color3.fromRGB(60, 30, 45))

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -30, 0, 30); StatusLabel.Position = UDim2.new(0, 15, 1, -35)
StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "សូមកំណត់ទីតាំង Base ជាមុន"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255); StatusLabel.Font = Enum.Font.GothamBold; StatusLabel.TextSize = 12

local function updateStatus(text, color)
    StatusLabel.Text = text; StatusLabel.TextColor3 = color or Color3.fromRGB(255, 182, 193)
end

-- [ ប្រព័ន្ធទម្លាក់ពងចូល Base ]
local function handleSteal()
    if not FastStealOn or not BaseCFrame or isProcessing then return end
    local hrp = getCharacter()
    if not hrp then return end
    
    isProcessing = true
    local OriginalPos = hrp.CFrame
    
    task.spawn(function()
        instantTeleport(BaseCFrame) -- ហោះទៅ Base ភ្លាមៗ
        task.wait(0.05) -- ចាំឲ្យពងធ្លាក់បន្តិច (អាចកែទៅ 0.1 បើនៅតែអត់ទម្លាក់)
        instantTeleport(OriginalPos) -- ត្រឡប់មកវិញភ្លាមៗ
        task.wait(0.1) -- សម្រាកកុំឲ្យគាំង
        isProcessing = false
    end)
end

-- [ ប្រព័ន្ធស្កេន និងបង្ខំអោយពងទាំងអស់ចុចបានលឿន (AGGRESSIVE LOOP) ]
task.spawn(function()
    while task.wait(0.5) do -- រាល់កន្លះវិនាទី វាស្កេនរកពងថ្មីៗរហូត
        if FastStealOn then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        -- បង្ខំឲ្យលឿន ទម្លុះជញ្ជាំង និងងាយចុច
                        v.HoldDuration = 0
                        v.RequiresLineOfSight = false
                        if v.MaxActivationDistance < 15 then
                            v.MaxActivationDistance = 15 -- បង្កើនប្រវែងដៃអោយចុចដល់
                        end
                        
                        -- ការពារកុំឲ្យចងភ្ជាប់រហូតពេក នាំឲ្យគាំង
                        if not v:GetAttribute("VIPStealHooked") then
                            v:SetAttribute("VIPStealHooked", true)
                            v.Triggered:Connect(function(plr) 
                                if plr == LocalPlayer then handleSteal() end 
                            end)
                        end
                    elseif v:IsA("ClickDetector") then
                        if not v:GetAttribute("VIPStealHooked") then
                            v:SetAttribute("VIPStealHooked", true)
                            v.MouseClick:Connect(function(plr) 
                                if plr == LocalPlayer then handleSteal() end 
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

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
        btnFastSteal.Text = "⚡ លួចពងលឿន VIP: ON"
        btnFastSteal.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        updateStatus("✅ បើកមុខងារយកពងលឿនVIP!", Color3.fromRGB(100, 255, 100))
    else
        btnFastSteal.Text = "⚡ លួចពងលឿន VIP: OFF"
        btnFastSteal.BackgroundColor3 = Color3.fromRGB(60, 30, 45)
        updateStatus("🛑 បានបិទមុខងារយកពងលឿន", Color3.fromRGB(255, 182, 193))
    end
end)

print("✅ VIP FAST STEAL LOADED SUCESSFULLY!")
end)

if not success then warn("❌ Error: " .. tostring(err)) end