-- Smart Auto-Farm for Blox Fruits (Continuous)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local autoFarm = false
local currentTarget = nil
local farmRange = 100 -- ចម្ងាយស្វែងរក (studs)

-- រកសត្រូវដែលនៅជិត និងមានជីវិត
local function findNewTarget()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local nearest = nil
    local shortest = farmRange
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChild("Humanoid")
            local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and enemyRoot then
                local dist = (root.Position - enemyRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- វាយសត្រូវ (M1)
local function attackTarget(target)
    local enemyRoot = target:FindFirstChild("HumanoidRootPart")
    local hum = target:FindFirstChild("Humanoid")
    if not enemyRoot or not hum or hum.Health <= 0 then return false end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    -- ផ្លាស់ទីទៅជិត (Teleport ថ្នមៗ)
    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 3)
    task.wait(0.05)
    -- ចុចឆ្វេង (M1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    return true
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "SmartFarm"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 90)
frame.Position = UDim2.new(0.5, -110, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,20)
title.BackgroundTransparency = 1
title.Text = "Smart Auto-Farm"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1,1,1)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-10,0,18)
status.Position = UDim2.new(0,5,0,22)
status.BackgroundTransparency = 1
status.Text = "រង់ចាំ..."
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Font = Enum.Font.Gotham
status.TextSize = 11

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 100, 0, 30)
btn.Position = UDim2.new(0.5, -50, 0, 50)
btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
btn.Text = "OFF"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    btn.Text = autoFarm and "ON" or "OFF"
    btn.BackgroundColor3 = autoFarm and Color3.fromRGB(0,180,0) or Color3.fromRGB(200,0,0)
    if not autoFarm then
        currentTarget = nil
        status.Text = "បានបញ្ឈប់"
    end
end)

-- Main Loop
task.spawn(function()
    while task.wait() do
        if not autoFarm then continue end

        -- បើគ្មានគោលដៅ ឬគោលដៅងាប់ រកថ្មី
        if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
            currentTarget = findNewTarget()
            if currentTarget then
                status.Text = "កំពុងវាយ: " .. currentTarget.Name
            else
                status.Text = "រកមិនឃើញសត្រូវ"
            end
        end

        -- វាយប្រសិនបើមានគោលដៅ
        if currentTarget then
            local success = pcall(function() attackTarget(currentTarget) end)
            if not success then
                currentTarget = nil
            end
        end

        task.wait(0.1) -- ពន្យាបន្តិចកុំឲ្យ CPU ឡើងខ្លាំង
    end
end)