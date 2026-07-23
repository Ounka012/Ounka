--========================================================
-- EVADE: BUBBLE HACK (SET AMOUNT + AUTO-COLLECT)
--========================================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ទីតាំងផ្ទះ (Set Home)
local HOME_POSITION = Vector3.new(0, 10, 0)

-- អថេរស្កេន (សម្រាប់ Value/Remote)
local bubbleValue = nil
local bubbleRemote = nil

-- រក Bubble ជាវត្ថុ (BasePart/Model) – ដូចស្ក្រីប Evade មុន
local function findBubbleParts()
    local parts = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("bubble") then
            table.insert(parts, obj)
        elseif obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part and (obj.Name:lower():find("bubble") or obj.Name:lower():find("token")) then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

-- ស្កេនរក Value (Number/Int) ដែលមានឈ្មោះ "bubble"
local function scanForValue()
    local keywords = {"bubble", "bubbles", "token", "coin", "point"}
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

-- ស្កេនរក Remote (Event/Function) សម្រាប់ Bubble
local function scanForRemote()
    local keywords = {"bubble", "bubbles", "token", "add", "give", "collect", "reward"}
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

-- ធ្វើការស្កេនដំបូង
bubbleValue = scanForValue()
bubbleRemote = scanForRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "EvadeBubbleHack"
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
title.Text = "🫧 Bubble Hack (Set Amount)"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(100,200,255)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.new(0,10,0,32)
status.BackgroundTransparency = 1
status.Text = "កំពុងវិភាគ..."
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

-- បង្ហាញស្ថានភាព
if bubbleValue then
    status.Text = "✅ រកឃើញ Bubble Value: " .. bubbleValue:GetFullName()
elseif bubbleRemote then
    status.Text = "✅ រកឃើញ Bubble Remote: " .. bubbleRemote.Name
else
    status.Text = "❌ រកមិនឃើញ Value/Remote (ប្រើប្រមូលដោយប៉ះ)"
end

-- ប្រអប់បញ្ចូលចំនួន Bubble
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 70, 0, 28)
input.Position = UDim2.new(0, 10, 0, 75)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "10"
input.Text = "10"
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

    -- បើមាន Value កែដោយផ្ទាល់
    if bubbleValue then
        pcall(function()
            bubbleValue.Value = bubbleValue.Value + amount
            status.Text = "✅ បន្ថែម "..amount.." Bubble (Value)"
        end)
        return
    end

    -- បើមាន Remote សាកបាញ់
    if bubbleRemote then
        local success = false
        if bubbleRemote:IsA("RemoteEvent") then
            success = pcall(function() bubbleRemote:FireServer(amount) end)
            if not success then
                success = pcall(function() bubbleRemote:FireServer(LocalPlayer, amount) end)
            end
        elseif bubbleRemote:IsA("RemoteFunction") then
            success = pcall(function() bubbleRemote:InvokeServer(amount) end)
        end
        if success then
            status.Text = "✅ បាញ់ Remote ជាមួយ "..amount.." (មើលលទ្ធផល)"
        else
            status.Text = "❌ បាញ់ Remote បរាជ័យ"
        end
        return
    end

    -- បើគ្មាន Value/Remote ទេ ប្រមូលតាមចំនួនពីវត្ថុ
    status.Text = "គ្មាន Value/Remote កំពុងប្រមូល "..amount.." Bubble..."
    local parts = findBubbleParts()
    local collected = 0
    for _, part in ipairs(parts) do
        if collected >= amount then break end
        if part.Parent then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = part.CFrame * CFrame.new(0, 2.5, 0)  -- TP ទៅប៉ះ
                task.wait(0.1)
                collected = collected + 1
            end
        end
    end
    -- ត្រឡប់មកផ្ទះ
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(HOME_POSITION) end
    status.Text = "✅ ប្រមូលបាន "..collected.." Bubble"
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
    bubbleValue = scanForValue()
    bubbleRemote = scanForRemote()
    if bubbleValue then
        status.Text = "✅ រកឃើញ Bubble Value: " .. bubbleValue:GetFullName()
    elseif bubbleRemote then
        status.Text = "✅ រកឃើញ Bubble Remote: " .. bubbleRemote.Name
    else
        status.Text = "❌ មិនឃើញ (សាកប្រើប្រមូលដោយប៉ះ)"
    end
end)

-- ប៊ូតុង Auto-Collect (សម្រាប់ប្រមូលឥតដែនកំណត់)
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, -20, 0, 35)
autoBtn.Position = UDim2.new(0, 10, 0, 115)
autoBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
autoBtn.Text = "🔄 បើក Auto-Collect"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

local autoEnabled = false
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        autoBtn.Text = "⏹ បញ្ឈប់"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        status.Text = "កំពុងប្រមូលដោយស្វ័យប្រវត្តិ..."
        task.spawn(function()
            while autoEnabled do
                local parts = findBubbleParts()
                if #parts > 0 then
                    for _, part in ipairs(parts) do
                        if not autoEnabled then break end
                        if part.Parent then
                            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.CFrame = part.CFrame * CFrame.new(0, 2.5, 0)
                                task.wait(0.1)
                            end
                        end
                    end
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.CFrame = CFrame.new(HOME_POSITION) end
                    status.Text = "✅ ជុំថ្មី – ប្រមូលបាន " .. #parts .. " Bubble"
                else
                    status.Text = "រកមិនឃើញ Bubble រង់ចាំ..."
                end
                task.wait(3)
            end
            autoBtn.Text = "🔄 បើក Auto-Collect"
            autoBtn.BackgroundColor3 = Color3.fromRGB(200,120,0)
            status.Text = "បានបញ្ឈប់"
        end)
    else
        autoEnabled = false
    end
end)

-- ប៊ូតុង Set Home
local homeBtn = Instance.new("TextButton", frame)
homeBtn.Size = UDim2.new(0, 100, 0, 28)
homeBtn.Position = UDim2.new(0, 10, 0, 160)
homeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
homeBtn.Text = "📍 Set Home"
homeBtn.TextColor3 = Color3.new(1,1,1)
homeBtn.Font = Enum.Font.GothamBold
homeBtn.TextSize = 11
Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0,6)
homeBtn.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        HOME_POSITION = root.Position
        status.Text = "✅ ផ្ទះបានកំណត់"
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
    autoEnabled = false
    gui:Destroy()
end)