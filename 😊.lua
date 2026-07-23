--========================================================
-- BLOX FRUITS: SIMPLE LEVEL HACK (AUTO-SCAN)
--========================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local levelValue = nil
local levelRemote = nil

-- ស្វែងរក Value (Number/Int) ដែលទាក់ទងនឹង Level
local function scanForValue()
    local keywords = {"level", "lvl", "xp", "exp", "rank"}
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

-- ស្វែងរក Remote (Event/Function) សម្រាប់ Level
local function scanForRemote()
    local keywords = {"level", "lvl", "add", "setlevel", "addexp", "give", "upgrade", "rank"}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage")}
    for _, service in ipairs(services) do
        for _, obj in pairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then return obj end
                end
            end
        end
    end
    return nil
end

-- ស្កេនដំបូង
levelValue = scanForValue()
levelRemote = scanForRemote()

-- GUI សាមញ្ញបំផុត
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "BloxFruitsLevel"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.5, -65)
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
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,25)
status.Position = UDim2.new(0,10,0,28)
status.BackgroundTransparency = 1
status.Text = (levelValue and "Value: "..levelValue.Name) or (levelRemote and "Remote: "..levelRemote.Name) or "រកមិនឃើញ"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 80, 0, 28)
input.Position = UDim2.new(0, 10, 0, 60)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "Level"
input.Text = "1000"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 90, 0, 28)
addBtn.Position = UDim2.new(0, 100, 0, 60)
addBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
addBtn.Text = "កំណត់ Level"
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

    -- វិធី១: កែ Value ផ្ទាល់ (អាច Fake)
    if levelValue then
        pcall(function()
            levelValue.Value = targetLevel
            status.Text = "✅ បានកំណត់ Level "..targetLevel.." (Value)"
        end)
        return
    end

    -- វិធី២: បាញ់ Remote
    if levelRemote then
        local success = false
        if levelRemote:IsA("RemoteEvent") then
            -- សាកជាមួយ targetLevel និង Player
            success = pcall(function() levelRemote:FireServer(targetLevel) end)
            if not success then
                success = pcall(function() levelRemote:FireServer(LocalPlayer, targetLevel) end)
            end
            if not success then
                success = pcall(function() levelRemote:FireServer({Level = targetLevel}) end)
            end
        elseif levelRemote:IsA("RemoteFunction") then
            success = pcall(function() levelRemote:InvokeServer(targetLevel) end)
            if not success then
                success = pcall(function() levelRemote:InvokeServer(LocalPlayer, targetLevel) end)
            end
        end
        if success then
            status.Text = "✅ បាញ់ Remote កំណត់ Level "..targetLevel
        else
            status.Text = "❌ បរាជ័យ ពិនិត្យ Remote ដោយ RemoteSpy"
        end
        return
    end

    status.Text = "❌ គ្មាន Value/Remote សាកស្កេនឡើងវិញ"
end)

-- ប៊ូតុងស្កេនឡើងវិញ
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 80, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 95)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 10
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    levelValue = scanForValue()
    levelRemote = scanForRemote()
    if levelValue then
        status.Text = "✅ រកឃើញ Value: "..levelValue.Name
    elseif levelRemote then
        status.Text = "✅ រកឃើញ Remote: "..levelRemote.Name
    else
        status.Text = "❌ មិនឃើញ (ប្រើ RemoteSpy ពេល Level ឡើង)"
    end
end)

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