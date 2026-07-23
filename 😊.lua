-- Auto-Scan for Sheckles Value or Remote
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local shecklesValue = nil
local shecklesRemote = nil

-- មុខងារស្កេនរក Value (Number/Int) ដែលមានឈ្មោះពាក់ព័ន្ធ
local function scanForValue()
    local keywords = {"sheckel", "sheckles", "money", "cash", "coin", "credit"}
    local player = LocalPlayer
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    return obj
                end
            end
        end
    end
    -- ពិនិត្យក្នុង leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, obj in pairs(leaderstats:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- មុខងារស្កេនរក Remote (Event/Function) ដែលអាចបន្ថែម Sheckles
local function scanForRemote()
    local keywords = {"sheckel", "sheckles", "money", "cash", "add", "give", "reward", "currency", "coin", "pay"}
    local services = {ReplicatedStorage, Workspace, game:GetService("Players"), game:GetService("ServerStorage")}
    for _, service in ipairs(services) do
        for _, obj in pairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- ធ្វើការស្កេន
shecklesValue = scanForValue()
shecklesRemote = scanForRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesAutoScan"
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
title.Text = "Sheckles Hack (Auto-Scan)"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 30)
status.BackgroundTransparency = 1
status.Text = "កំពុងវិភាគ..."
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

-- បង្ហាញស្ថានភាព
if shecklesValue then
    status.Text = "✅ រកឃើញ Value: " .. shecklesValue:GetFullName()
elseif shecklesRemote then
    status.Text = "✅ រកឃើញ Remote: " .. shecklesRemote.Name
else
    status.Text = "❌ រកមិនឃើញ Value ឬ Remote"
end

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 80, 0, 28)
input.Position = UDim2.new(0, 10, 0, 70)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "1000"
input.Text = "1000"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 100, 0, 28)
addBtn.Position = UDim2.new(0, 100, 0, 70)
addBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
addBtn.Text = "បន្ថែម"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,5)

addBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(input.Text)
    if not amount or amount <= 0 then
        status.Text = "បញ្ចូលចំនួនឲ្យត្រឹមត្រូវ"
        return
    end
    if shecklesValue then
        pcall(function()
            shecklesValue.Value = shecklesValue.Value + amount
            status.Text = "✅ បន្ថែម "..amount.." (តម្លៃ)"
        end)
    elseif shecklesRemote then
        local success = false
        -- សាក FireServer/InvokeServer ច្រើនបែប
        if shecklesRemote:IsA("RemoteEvent") then
            success = pcall(function() shecklesRemote:FireServer(amount) end)
            if not success then
                success = pcall(function() shecklesRemote:FireServer(LocalPlayer, amount) end)
            end
            if not success then
                success = pcall(function() shecklesRemote:FireServer({Amount = amount}) end)
            end
        elseif shecklesRemote:IsA("RemoteFunction") then
            success = pcall(function() shecklesRemote:InvokeServer(amount) end)
            if not success then
                success = pcall(function() shecklesRemote:InvokeServer(LocalPlayer, amount) end)
            end
        end
        if success then
            status.Text = "✅ បាញ់ Remote ជាមួយ "..amount
        else
            status.Text = "❌ បរាជ័យ សាកមើលឈ្មោះ Remote"
        end
    else
        status.Text = "❌ គ្មាន Value ឬ Remote"
    end
end)

-- ប៊ូតុងស្កេនឡើងវិញ
local rescanBtn = Instance.new("TextButton", frame)
rescanBtn.Size = UDim2.new(0, 100, 0, 25)
rescanBtn.Position = UDim2.new(0, 10, 0, 110)
rescanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
rescanBtn.Text = "ស្កេនឡើងវិញ"
rescanBtn.TextColor3 = Color3.new(1,1,1)
rescanBtn.Font = Enum.Font.GothamBold
rescanBtn.TextSize = 11
Instance.new("UICorner", rescanBtn).CornerRadius = UDim.new(0,5)
rescanBtn.MouseButton1Click:Connect(function()
    shecklesValue = scanForValue()
    shecklesRemote = scanForRemote()
    if shecklesValue then
        status.Text = "✅ រកឃើញ Value: " .. shecklesValue:GetFullName()
    elseif shecklesRemote then
        status.Text = "✅ រកឃើញ Remote: " .. shecklesRemote.Name
    else
        status.Text = "❌ មិនឃើញ (សាកលេងឲ្យឃើញ Sheckles ផ្លាស់ប្ដូរសិន)"
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