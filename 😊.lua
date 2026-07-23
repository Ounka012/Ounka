-- Blox Fruits Auto-Farm (Real Level Up)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local runService = game:GetService("RunService")

local autoFarmEnabled = false
local target = nil

-- រកសត្រូវដែលនៅជិតបំផុត
local function findNearestEnemy(range)
    local nearest = nil
    local shortestDist = range or 100
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
            if enemyRoot and obj ~= char then
                local dist = (root.Position - enemyRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- ធ្វើការវាយ
local function attackEnemy(enemy)
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return end
    -- ផ្លាស់ទីទៅសត្រូវ
    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 3)
    task.wait(0.1)
    -- ប្រើ M1 (ចុចឆ្វេង)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- GUI តូចបើក/បិទ
local gui = Instance.new("ScreenGui", game.CoreGui)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 35)
toggleBtn.Position = UDim2.new(0.5, -60, 0.8, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.Text = "Auto Farm: OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    toggleBtn.Text = autoFarmEnabled and "Auto Farm: ON" or "Auto Farm: OFF"
    toggleBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(200,0,0)
end)

-- Main Loop
task.spawn(function()
    while task.wait() do
        if not autoFarmEnabled then continue end
        if not target or target:FindFirstChild("Humanoid").Health <= 0 then
            target = findNearestEnemy(80)
        end
        if target then
            pcall(function() attackEnemy(target) end)
        end
    end
end)