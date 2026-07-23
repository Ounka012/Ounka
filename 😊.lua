--========================================================
-- EVADE: BUBBLE AUTO-COLLECTOR (Sheckles-Style GUI)
--========================================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ទីតាំងផ្ទះ (កំណត់ពេលចុច Set Home)
local HOME_POSITION = Vector3.new(0, 10, 0)

-- មុខងាររក Bubble (ពីស្ក្រីប Evade ដែលបានកែ)
local function getValidTarget(obj)
    if not obj then return nil end
    local name = obj.Name:lower()
    
    -- មិនយកតួអង្គ
    local ancestor = obj:FindFirstAncestorOfClass("Model")
    if ancestor and ancestor:FindFirstChildOfClass("Humanoid") then
        return nil
    end

    local parent = obj.Parent
    local parentName = parent and parent.Name:lower() or ""
    local grandParent = parent and parent.Parent
    local grandParentName = grandParent and grandParent.Name:lower() or ""

    -- រកឈ្មោះ bubble ឬ token
    if name:find("bubble") or name:find("token") then
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then return part end
        end
    end

    if parent and (parentName:find("bubble") or parentName:find("token")) then
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
        if obj:IsA("Model") then
            local p = obj:FindFirstChildWhichIsA("BasePart")
            if p then return p end
        end
    end

    if grandParent and (grandParentName:find("bubble") or grandParentName:find("token")) then
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
    end

    if name == "handle" and parent and (parentName:find("bubble") or parentName:find("token")) then
        if obj:IsA("BasePart") then return obj end
    end

    return nil
end

local function scanForBubbles()
    local bubbles = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        local part = getValidTarget(obj)
        if part then
            table.insert(bubbles, part)
        end
    end
    return bubbles
end

-- ផ្លាស់ទីភ្លាមៗ (Teleport)
local function tpTo(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos)
    end
end

-- ប្រមូល Bubble (ប៉ះ)
local function collectBubble(bubblePart)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not bubblePart.Parent then return false end

    -- TP ទៅខាងលើ Bubble (ជិតល្មមនឹងប៉ះ)
    tpTo(bubblePart.Position + Vector3.new(0, 2.5, 0))
    -- រង់ចាំបន្តិចឲ្យហ្គេមចាប់ការប៉ះ
    task.wait(0.15)
    return true
end

-- GUI ដូច Sheckles Auto-Scan
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "EvadeBubbleCollector"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 190)
frame.Position = UDim2.new(0.5, -150, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "🫧 Bubble Auto-Collector"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(100, 200, 255)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "ត្រៀមរួចរាល់"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

-- បង្ហាញចំនួន Bubble ដែលរកឃើញ
local bubbleCount = 0
local function updateBubbleCount()
    local all = scanForBubbles()
    bubbleCount = #all
    return bubbleCount
end
updateBubbleCount()

-- ប៊ូតុង Collect All
local collectBtn = Instance.new("TextButton", frame)
collectBtn.Size = UDim2.new(0, 120, 0, 35)
collectBtn.Position = UDim2.new(0, 10, 0, 75)
collectBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
collectBtn.Text = "⚡ Collect All"
collectBtn.TextColor3 = Color3.new(1,1,1)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 12
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 8)

collectBtn.MouseButton1Click:Connect(function()
    local bubbles = scanForBubbles()
    status.Text = "កំពុងប្រមូល " .. #bubbles .. " Bubble..."
    for i, bubble in ipairs(bubbles) do
        if bubble.Parent then
            collectBubble(bubble)
            status.Text = "ប្រមូល " .. i .. "/" .. #bubbles
        end
        task.wait(0.1)
    end
    tpTo(HOME_POSITION)
    status.Text = "✅ ប្រមូលរួច ត្រឡប់មកផ្ទះ"
end)

-- ប៊ូតុង Auto-Collect
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0, 120, 0, 35)
autoBtn.Position = UDim2.new(0, 140, 0, 75)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
autoBtn.Text = "🔄 Auto Collect"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 8)

local autoEnabled = false
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        autoBtn.Text = "⏹ បញ្ឈប់"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        status.Text = "ដំណើរការស្វ័យប្រវត្តិ..."
        task.spawn(function()
            while autoEnabled do
                local bubbles = scanForBubbles()
                if #bubbles > 0 then
                    for _, bubble in ipairs(bubbles) do
                        if not autoEnabled then break end
                        if bubble.Parent then
                            collectBubble(bubble)
                        end
                        task.wait(0.15)
                    end
                    tpTo(HOME_POSITION)
                    status.Text = "✅ ជុំថ្មី – ប្រមូលបាន " .. #bubbles .. " Bubble"
                else
                    status.Text = "រកមិនឃើញ Bubble រង់ចាំ..."
                end
                task.wait(3) -- ពន្យារពេលមុនស្កេនម្ដងទៀត
            end
            autoBtn.Text = "🔄 Auto Collect"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
            status.Text = "បានបញ្ឈប់"
        end)
    else
        autoEnabled = false
    end
end)

-- ប៊ូតុង Set Home
local homeBtn = Instance.new("TextButton", frame)
homeBtn.Size = UDim2.new(0, 100, 0, 28)
homeBtn.Position = UDim2.new(0, 10, 0, 120)
homeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
homeBtn.Text = "📍 Set Home"
homeBtn.TextColor3 = Color3.new(1,1,1)
homeBtn.Font = Enum.Font.GothamBold
homeBtn.TextSize = 11
Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0, 6)
homeBtn.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        HOME_POSITION = root.Position
        status.Text = "✅ ផ្ទះបានកំណត់"
    end
end)

-- ប៊ូតុង Scan (បង្ហាញចំនួន Bubble)
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 100, 0, 28)
scanBtn.Position = UDim2.new(0, 120, 0, 120)
scanBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
scanBtn.Text = "🔍 Scan"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)
scanBtn.MouseButton1Click:Connect(function()
    local count = updateBubbleCount()
    status.Text = "រកឃើញ Bubble: " .. count .. " គ្រាប់"
end)

-- បិទ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-30,0,3)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()
    autoEnabled = false
    gui:Destroy()
end)

-- ការពារការបិទពេលចេញ
LocalPlayer.CharacterAdded:Connect(function()
    tpTo(HOME_POSITION)
end)