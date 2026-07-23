-- Blox Fruits Simple Auto-Farm (Real Level Up)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local autoFarm = false
local farmRange = 80  -- ចម្ងាយស្វែងរកសត្រូវ (studs)

-- រកសត្រូវជិតបំផុត
local function findNearestEnemy()
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
local function attack(enemy)
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- ផ្លាស់ទីទៅជិត
    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 3)
    task.wait(0.05)
    -- ចុចឆ្វេង
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- GUI តូច
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BloxFarm"

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 120, 0, 35)
btn.Position = UDim2.new(0.5, -60, 0.8, 0)
btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
btn.Text = "Auto Farm: OFF"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    btn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    btn.BackgroundColor3 = autoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Main Loop
task.spawn(function()
    while task.wait() do
        if not autoFarm then continue end
        local enemy = findNearestEnemy()
        if enemy then
            pcall(function() attack(enemy) end)
        end
        task.wait(0.1)
    end
end)