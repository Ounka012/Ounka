--========================================================
-- BLOX FRUITS: ONE-HIT KILL (WITH GUI, RGB, AUTO-SCAN)
--========================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local damageRemote = nil
local enabled = false
local totalKills = 0
local killRange = 80

-- ស្វែងរក RemoteEvent/RemoteFunction ដែលទាក់ទងនឹងការវាយ
local function scanForDamageRemote()
    local keywords = {"damage", "hit", "deal", "attack", "hurt", "slash", "punch"}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- ស្កេនដំបូង
damageRemote = scanForDamageRemote()

-- រកសត្រូវជិតបំផុត (មិនមែនអ្នកលេង)
local function findNearestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local nearest = nil
    local shortest = killRange
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChild("Humanoid")
            local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and enemyRoot and not Players:GetPlayerFromCharacter(obj) then
                local dist = (root.Position - enemyRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = {Model = obj, Root = enemyRoot, Humanoid = hum}
                end
            end
        end
    end
    return nearest
end

-- ព្យាយាមសម្លាប់សត្រូវ
local function oneHitKill(enemy)
    local hum = enemy.Humanoid
    local model = enemy.Model

    -- វិធី 1: កំណត់ Health = 0
    pcall(function()
        hum.Health = 0
    end)

    -- វិធី 2: បាញ់ Remote ជាមួយ Damage ខ្ពស់
    if damageRemote then
        if damageRemote:IsA("RemoteEvent") then
            pcall(function() damageRemote:FireServer(model, 999999) end)
            pcall(function() damageRemote:FireServer(999999) end)
        elseif damageRemote:IsA("RemoteFunction") then
            pcall(function() damageRemote:InvokeServer(model, 999999) end)
        end
    end

    -- វិធី 3: ចុច M1 ឲ្យ Server ដំណើរការ
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

    -- ប្រសិនបើសត្រូវងាប់ (Health ស្មើ 0)
    if hum.Health <= 0 then
        totalKills = totalKills + 1
        return true
    end
    return false
end

-- GUI (មាន RGB ដូចមុន)
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "OneHitKillGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", frame)
mainStroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "🍈 One-Hit Kill"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 100, 100)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = damageRemote and "✅ រកឃើញ Remote: "..damageRemote.Name or "⚠️ រកមិនឃើញ Remote"
status.TextColor3 = damageRemote and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,0)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

-- ប្រអប់បញ្ចូលចម្ងាយ
local rangeLabel = Instance.new("TextLabel", frame)
rangeLabel.Size = UDim2.new(0, 80, 0, 20)
rangeLabel.Position = UDim2.new(0, 10, 0, 75)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "ចម្ងាយ:"
rangeLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 11

local rangeInput = Instance.new("TextBox", frame)
rangeInput.Size = UDim2.new(0, 50, 0, 22)
rangeInput.Position = UDim2.new(0, 95, 0, 74)
rangeInput.BackgroundColor3 = Color3.fromRGB(50,50,55)
rangeInput.TextColor3 = Color3.new(1,1,1)
rangeInput.Font = Enum.Font.Gotham
rangeInput.TextSize = 12
rangeInput.PlaceholderText = "80"
rangeInput.Text = "80"
Instance.new("UICorner", rangeInput).CornerRadius = UDim.new(0,4)

-- ប៊ូតុងបើក/បិទ
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 100, 0, 35)
toggleBtn.Position = UDim2.new(0, 10, 0, 110)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

local killsLabel = Instance.new("TextLabel", frame)
killsLabel.Size = UDim2.new(0, 150, 0, 20)
killsLabel.Position = UDim2.new(0, 120, 0, 118)
killsLabel.BackgroundTransparency = 1
killsLabel.Text = "សម្លាប់៖ 0"
killsLabel.TextColor3 = Color3.fromRGB(255,255,255)
killsLabel.Font = Enum.Font.Gotham
killsLabel.TextSize = 11

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleBtn.Text = enabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(200,0,0)
    if not enabled then
        status.Text = "បានបិទ"
    else
        killRange = tonumber(rangeInput.Text) or 80
        status.Text = "កំពុងដំណើរការ..."
    end
end)

-- ប៊ូតុងស្កេនថ្មី
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 90, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 155)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    damageRemote = scanForDamageRemote()
    if damageRemote then
        status.Text = "✅ រកឃើញ Remote: "..damageRemote.Name
    else
        status.Text = "❌ នៅតែមិនឃើញ Remote"
    end
end)

-- ប៊ូតុង Kill All (ម្តង)
local killAllBtn = Instance.new("TextButton", frame)
killAllBtn.Size = UDim2.new(0, 90, 0, 25)
killAllBtn.Position = UDim2.new(0, 110, 0, 155)
killAllBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
killAllBtn.Text = "Kill All"
killAllBtn.TextColor3 = Color3.new(1,1,1)
killAllBtn.Font = Enum.Font.GothamBold
killAllBtn.TextSize = 11
Instance.new("UICorner", killAllBtn).CornerRadius = UDim.new(0,5)
killAllBtn.MouseButton1Click:Connect(function()
    status.Text = "កំពុងសម្លាប់ទាំងអស់..."
    local range = tonumber(rangeInput.Text) or 80
    local enemies = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum = obj:FindFirstChild("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root and not Players:GetPlayerFromCharacter(obj) then
                table.insert(enemies, {Model = obj, Root = root, Humanoid = hum})
            end
        end
    end
    local killed = 0
    for _, enemy in ipairs(enemies) do
        if enemy.Humanoid.Health > 0 then
            -- Teleport ទៅ
            local char = LocalPlayer.Character
            local playerRoot = char and char:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                playerRoot.CFrame = enemy.Root.CFrame * CFrame.new(0, 0, 4)
            end
            task.wait(0.05)
            oneHitKill(enemy)
            killed = killed + 1
        end
    end
    status.Text = "បានសម្លាប់ "..killed.." សត្រូវ"
end)

-- បិទ GUI
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
    enabled = false
    gui:Destroy()
end)

-- ចលនាពណ៌ RGB
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        mainStroke.Color = Color3.fromHSV((hue+0.3)%1, 1, 1)
        task.wait(0.03)
    end
end)

-- Main loop (Auto-Kill)
task.spawn(function()
    while task.wait() do
        if not enabled then continue end
        killRange = tonumber(rangeInput.Text) or 80
        local enemy = findNearestEnemy()
        if enemy then
            -- Teleport ទៅជិត
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = enemy.Root.CFrame * CFrame.new(0, 0, 4)
            end
            task.wait(0.05)
            local ok = oneHitKill(enemy)
            if ok then
                killsLabel.Text = "សម្លាប់៖ "..totalKills
            end
        end
        task.wait(0.2)
    end
end)