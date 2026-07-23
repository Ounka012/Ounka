--========================================================
-- BLOX FRUITS: LEVEL ADDER (AUTO-SCAN REMOTE/VALUE)
--========================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local levelValue = nil
local levelRemote = nil

-- ស្វែងរក NumberValue/IntValue ដែលទាក់ទងនឹង Level
local function scanForValue()
    local keywords = {"level", "lvl", "xp", "exp", "rank", "power", "bounty"}  -- បន្ថែម bounty ព្រោះ Blox Fruits
    local player = LocalPlayer
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then return obj end
            end
        end
    end
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, obj in pairs(leaderstats:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then return obj end
                end
            end
        end
    end
    return nil
end

-- ស្វែងរក RemoteEvent/RemoteFunction សម្រាប់ Level/XP
local function scanForRemote()
    local keywords = {
        "level", "lvl", "addxp", "addexp", "gainxp", "setlevel", "levelup",
        "givexp", "give", "reward", "questreward", "addlevel", "bounty", "exp"
    }
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage"), game:GetService("ServerScriptService")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then return obj end
                    end
                end
            end
        end)
    end
    return nil
end

-- ស្កេនដំបូង
levelValue = scanForValue()
levelRemote = scanForRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "BloxFruitLevel"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 150)
frame.Position = UDim2.new(0.5, -140, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "🍈 Level Hack"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 30)
status.BackgroundTransparency = 1
status.Text = "កំពុងវិភាគ..."
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

-- បង្ហាញស្ថានភាពដំបូង
if levelValue then
    status.Text = "✅ រកឃើញ Value: " .. levelValue:GetFullName()
elseif levelRemote then
    status.Text = "✅ រកឃើញ Remote: " .. levelRemote.Name
else
    status.Text = "❌ រកមិនឃើញ – សូមប្រើ RemoteSpy ពេល Level ឡើង"
end

-- ប្រអប់បញ្ចូល Level
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 80, 0, 28)
input.Position = UDim2.new(0, 10, 0, 70)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "Level"
input.Text = "2000"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

-- ប៊ូតុងបន្ថែម
local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 100, 0, 28)
addBtn.Position = UDim2.new(0, 100, 0, 70)
addBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
addBtn.Text = "បន្ថែម Level"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 11
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,5)

addBtn.MouseButton1Click:Connect(function()
    local targetLevel = tonumber(input.Text)
    if not targetLevel or targetLevel <= 0 then
        status.Text = "បញ្ចូល Level ត្រឹមត្រូវ"
        return
    end

    -- វិធីទី 1៖ កែ Value ផ្ទាល់ (អាចជា Visual)
    if levelValue then
        pcall(function()
            -- បើចង់បូកបន្ថែម ត្រូវដឹង Level បច្ចុប្បន្ន
            local current = levelValue.Value
            levelValue.Value = current + targetLevel   -- បូកបន្ថែម ឬកែជាកំណត់
            status.Text = "✅ បានបូក Level "..targetLevel.." (Value)"
        end)
        return
    end

    -- វិធីទី 2៖ បាញ់ Remote
    if levelRemote then
        local success = false
        local methods = {
            {targetLevel},
            {LocalPlayer, targetLevel},
            {LocalPlayer, targetLevel, "XP"},
            {{Level = targetLevel}},
            {{Amount = targetLevel}}
        }
        for _, args in ipairs(methods) do
            if levelRemote:IsA("RemoteEvent") then
                success = pcall(function() levelRemote:FireServer(unpack(args)) end)
            elseif levelRemote:IsA("RemoteFunction") then
                success = pcall(function() levelRemote:InvokeServer(unpack(args)) end)
            end
            if success then break end
        end

        if success then
            status.Text = "✅ បាញ់ Remote បង្កើន Level "..targetLevel
        else
            status.Text = "❌ បាញ់ Remote បរាជ័យ"
        end
        return
    end

    status.Text = "❌ គ្មាន Value/Remote – សាកស្កេនឡើងវិញ"
end)

-- ប៊ូតុងស្កេនឡើងវិញ
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 100, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 110)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    levelValue = scanForValue()
    levelRemote = scanForRemote()
    if levelValue then
        status.Text = "✅ រកឃើញ Value: " .. levelValue:GetFullName()
    elseif levelRemote then
        status.Text = "✅ រកឃើញ Remote: " .. levelRemote.Name
    else
        status.Text = "❌ មិនឃើញ – ប្រើ RemoteSpy ពេលទទួល XP/Level"
    end
end)

-- បិទ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,22,0,22)
closeBtn.Position = UDim2.new(1,-26,0,2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)