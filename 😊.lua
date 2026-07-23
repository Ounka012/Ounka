--========================================================
-- SHECKLES EASY HACK (Auto-Steal for Real Sheckles)
--========================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- កំណត់
local HOME_POSITION = Root.Position
local HOLD_DURATION = 0.6
local AUTO_INTERVAL = 2
local isAutoStealing = false

-- រកដំណាំដែលអាចលួច (មានប៊ូតុង "Steal")
local function findStealable()
    local plants = {}
    local myName = LocalPlayer.Name
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent then
            local owner = obj:GetAttribute("Owner") or obj:GetAttribute("owner")
            if not owner then
                local v = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner")
                if v and v:IsA("StringValue") then owner = v.Value end
                if v and v:IsA("ObjectValue") and v.Value then owner = v.Value.Name end
            end
            if owner and owner ~= myName then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and (p.ActionText:lower():find("steal") or p.Name:lower():find("steal")) then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part then table.insert(plants, {Model=obj, Part=part, Prompt=p, Name=obj.Name}) end
                        break
                    end
                end
            end
        end
    end
    return plants
end

-- លួចមួយដើម
local function stealOne(plant)
    local prompt = plant.Prompt
    if not prompt.Parent then return false end
    Root.CFrame = CFrame.new(plant.Part.Position + Vector3.new(0,4,0))
    task.wait(0.1)
    prompt.MaxActivationDistance = 100
    prompt.RequiresLineOfSight = false
    local hold = prompt.HoldDuration > 0 and prompt.HoldDuration or HOLD_DURATION
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(hold + 0.1)
    pcall(function() prompt:InputHoldEnd() end)
    return true
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesEasy"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 150)
frame.Position = UDim2.new(0.5, -140, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "💰 Sheckles Easy"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,30)
status.BackgroundTransparency = 1
status.Text = "ចុចខាងក្រោមដើម្បីចាប់ផ្ដើម"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1,-20,0,40)
autoBtn.Position = UDim2.new(0,10,0,70)
autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Steal (Sheckles ពិត)"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

autoBtn.MouseButton1Click:Connect(function()
    isAutoStealing = not isAutoStealing
    if isAutoStealing then
        autoBtn.Text = "⏹ បញ្ឈប់"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        status.Text = "កំពុងលួច..."
        task.spawn(function()
            while isAutoStealing do
                local plants = findStealable()
                if #plants > 0 then
                    for i, plant in ipairs(plants) do
                        if not isAutoStealing then break end
                        status.Text = "លួច " .. i .. "/" .. #plants .. ": " .. plant.Name
                        stealOne(plant)
                        task.wait(0.3)
                    end
                else
                    status.Text = "រកមិនឃើញដំណាំ រង់ចាំ..."
                end
                Root.CFrame = CFrame.new(HOME_POSITION)
                task.wait(AUTO_INTERVAL)
            end
            autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Steal"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
            status.Text = "បានបញ្ឈប់"
        end)
    else
        isAutoStealing = false
    end
end)

local homeBtn = Instance.new("TextButton", frame)
homeBtn.Size = UDim2.new(1,-20,0,30)
homeBtn.Position = UDim2.new(0,10,0,115)
homeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
homeBtn.Text = "📍 Set Home (ឈរនៅផ្ទះសិន)"
homeBtn.TextColor3 = Color3.new(1,1,1)
homeBtn.Font = Enum.Font.GothamBold
homeBtn.TextSize = 11
Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0,6)
homeBtn.MouseButton1Click:Connect(function()
    if Root then HOME_POSITION = Root.Position end
    status.Text = "ផ្ទះបានកំណត់"
end)

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
    isAutoStealing = false
    gui:Destroy()
end)