--========================================================
-- SHECKLES HACK: Auto-Scan + Remote Listener + Auto-Steal
--========================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local shecklesValue = nil
local shecklesRemote = nil
local lastValue = 0
local listenerConnection = nil
local autoStealEnabled = false

--========== រក Value ==========
local function scanForValue()
    local keywords = {"sheckel", "sheckles", "money", "cash", "coin", "credit"}
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

--========== រក Remote ==========
local function scanForRemote()
    local keywords = {"sheckel", "sheckles", "money", "cash", "add", "give", "reward", "currency", "coin", "pay"}
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

--========== លួចដំណាំ (សម្រាប់ Sheckles ពិត) ==========
local function findStealablePlants()
    local plants = {}
    local myName = LocalPlayer.Name
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent then
            local owner = obj:GetAttribute("Owner") or obj:GetAttribute("owner")
            if not owner then
                local v = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner")
                if v and v:IsA("StringValue") then owner = v.Value end
                if v and v:IsA("ObjectValue") and v.Value then owner = v.Value.Name end
            end
            if owner and owner ~= myName then
                for _, p in pairs(obj:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and (p.ActionText:lower():find("steal") or p.Name:lower():find("steal")) then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            table.insert(plants, {Model=obj, Part=part, Prompt=p})
                        end
                        break
                    end
                end
            end
        end
    end
    return plants
end

local function stealOne(plant)
    local prompt = plant.Prompt
    if not prompt.Parent then return false end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = CFrame.new(plant.Part.Position + Vector3.new(0,4,0))
    task.wait(0.15)
    prompt.MaxActivationDistance = 100
    prompt.RequiresLineOfSight = false
    local hold = prompt.HoldDuration > 0 and prompt.HoldDuration or 0.6
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(hold + 0.1)
    pcall(function() prompt:InputHoldEnd() end)
    return true
end

--========== GUI ==========
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesPro"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "💰 SHECKLES PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,35)
status.Position = UDim2.new(0,10,0,32)
status.BackgroundTransparency = 1
status.Text = "កំពុងវិភាគ..."
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

-- ប្រអប់បញ្ចូលចំនួន
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 70, 0, 28)
input.Position = UDim2.new(0, 10, 0, 75)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "500"
input.Text = "500"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

-- ប៊ូតុងបន្ថែម (Add)
local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 80, 0, 28)
addBtn.Position = UDim2.new(0, 90, 0, 75)
addBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
addBtn.Text = "បន្ថែម"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,5)

addBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(input.Text)
    if not amount or amount <= 0 then
        status.Text = "បញ្ចូលចំនួនត្រឹមត្រូវ"
        return
    end

    -- ប្រសិនបើរកឃើញ Value សាកកែ (អាច Fake)
    if shecklesValue then
        pcall(function()
            shecklesValue.Value = shecklesValue.Value + amount
            status.Text = "✅ បន្ថែម "..amount.." (អាចមិនចាយបាន)"
        end)
    end

    -- ប្រសិនបើរកឃើញ Remote សាកបាញ់
    if shecklesRemote then
        local success = false
        if shecklesRemote:IsA("RemoteEvent") then
            success = pcall(function() shecklesRemote:FireServer(amount) end)
            if not success then
                success = pcall(function() shecklesRemote:FireServer(LocalPlayer, amount) end)
            end
        elseif shecklesRemote:IsA("RemoteFunction") then
            success = pcall(function() shecklesRemote:InvokeServer(amount) end)
        end
        if success then
            status.Text = "✅ បាញ់ Remote ជាមួយ "..amount .. " - រង់ចាំមើលលទ្ធផល"
        else
            status.Text = "❌ បាញ់ Remote បរាជ័យ"
        end
    end

    if not shecklesValue and not shecklesRemote then
        status.Text = "❌ មិនឃើញ Value/Remote - សាក Auto-Steal វិញ"
    end
end)

-- ប៊ូតុងស្កេនឡើងវិញ
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 80, 0, 28)
scanBtn.Position = UDim2.new(0, 180, 0, 75)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    shecklesValue = scanForValue()
    shecklesRemote = scanForRemote()
    if shecklesValue then
        status.Text = "✅ រកឃើញ Value: " .. shecklesValue:GetFullName()
    elseif shecklesRemote then
        status.Text = "✅ រកឃើញ Remote: " .. shecklesRemote.Name
    else
        status.Text = "❌ មិនឃើញ (សាកលេងឲ្យ Sheckles ផ្លាស់ប្ដូរសិន)"
    end
end)

-- ប៊ូតុង Auto-Steal (ស្រេចចិត្ត)
local stealBtn = Instance.new("TextButton", frame)
stealBtn.Size = UDim2.new(1, -20, 0, 35)
stealBtn.Position = UDim2.new(0, 10, 0, 115)
stealBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
stealBtn.Text = "🔄 បើក Auto-Steal (Sheckles ពិត)"
stealBtn.TextColor3 = Color3.new(1,1,1)
stealBtn.Font = Enum.Font.GothamBold
stealBtn.TextSize = 12
Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0,8)

stealBtn.MouseButton1Click:Connect(function()
    autoStealEnabled = not autoStealEnabled
    if autoStealEnabled then
        stealBtn.Text = "⏹ បញ្ឈប់ Auto-Steal"
        stealBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        status.Text = "កំពុងលួច..."
        task.spawn(function()
            while autoStealEnabled do
                local plants = findStealablePlants()
                if #plants > 0 then
                    for _, plant in ipairs(plants) do
                        if not autoStealEnabled then break end
                        stealOne(plant)
                        task.wait(0.3)
                    end
                else
                    status.Text = "រកមិនឃើញដំណាំ រង់ចាំ..."
                end
                task.wait(2)
            end
            stealBtn.Text = "🔄 បើក Auto-Steal"
            stealBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
            status.Text = "បានបញ្ឈប់"
        end)
    else
        autoStealEnabled = false
    end
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
    autoStealEnabled = false
    gui:Destroy()
end)

-- ធ្វើការស្កេនដំបូង
shecklesValue = scanForValue()
shecklesRemote = scanForRemote()
if shecklesValue then
    status.Text = "✅ រកឃើញ Value: " .. shecklesValue:GetFullName()
elseif shecklesRemote then
    status.Text = "✅ រកឃើញ Remote: " .. shecklesRemote.Name
else
    status.Text = "❌ មិនឃើញ Value/Remote - សាកប្រើ Auto-Steal ពីក្រោម"
end