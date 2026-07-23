-- Sheckles Instant Adder (Configurable Amount)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- បញ្ជីឈ្មោះ Remote ដែលអាចមាន (អ្នកអាចបន្ថែមបាន)
local possibleRemotes = {
    "GiveSheckles",
    "AddMoney",
    "AddSheckles",
    "GrantCurrency",
    "AddCash",
    "Reward",
    "GiveMoney",
    "Sheckles",
}

-- ស្វែងរក Remote ដែលមាន
local function findRemote()
    for _, name in ipairs(possibleRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote and remote:IsA("RemoteEvent") then
            return remote
        end
    end
    -- រកក្នុងកូនទាំងអស់
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("sheckel") or obj.Name:lower():find("money") or obj.Name:lower():find("cash")) then
            return obj
        end
    end
    return nil
end

local activeRemote = findRemote()

-- បង្កើត GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "InstantSheckles"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
frame.Draggable = true
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "💰 Instant Sheckles"
title.TextColor3 = Color3.fromRGB(255,215,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Position = UDim2.new(0,0,0,5)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-30,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,40)
status.BackgroundTransparency = 1
status.Text = activeRemote and "✅ បានរកឃើញ Remote" or "❌ រកមិនឃើញ Remote"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11

-- ប្រអប់បញ្ចូលចំនួន
local amountLabel = Instance.new("TextLabel", frame)
amountLabel.Size = UDim2.new(0,100,0,20)
amountLabel.Position = UDim2.new(0,10,0,80)
amountLabel.BackgroundTransparency = 1
amountLabel.Text = "ចំនួន Sheckles:"
amountLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
amountLabel.Font = Enum.Font.Gotham
amountLabel.TextSize = 11

local amountBox = Instance.new("TextBox", frame)
amountBox.Size = UDim2.new(0,120,0,30)
amountBox.Position = UDim2.new(0,120,0,75)
amountBox.BackgroundColor3 = Color3.fromRGB(50,50,55)
amountBox.TextColor3 = Color3.new(1,1,1)
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 14
amountBox.PlaceholderText = "1000"
amountBox.Text = "1000"
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0,6)

-- ប្រអប់បញ្ចូលឈ្មោះ Remote (ដើម្បីកែដោយខ្លួនឯង)
local remoteLabel = Instance.new("TextLabel", frame)
remoteLabel.Size = UDim2.new(0,100,0,20)
remoteLabel.Position = UDim2.new(0,10,0,115)
remoteLabel.BackgroundTransparency = 1
remoteLabel.Text = "ឈ្មោះ Remote:"
remoteLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
remoteLabel.Font = Enum.Font.Gotham
remoteLabel.TextSize = 11

local remoteBox = Instance.new("TextBox", frame)
remoteBox.Size = UDim2.new(0,120,0,30)
remoteBox.Position = UDim2.new(0,120,0,110)
remoteBox.BackgroundColor3 = Color3.fromRGB(50,50,55)
remoteBox.TextColor3 = Color3.new(1,1,1)
remoteBox.Font = Enum.Font.Gotham
remoteBox.TextSize = 14
remoteBox.PlaceholderText = "GiveSheckles"
remoteBox.Text = activeRemote and activeRemote.Name or ""
Instance.new("UICorner", remoteBox).CornerRadius = UDim.new(0,6)

-- ប៊ូតុង Add
local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 120, 0, 35)
addBtn.Position = UDim2.new(0.5, -60, 0, 150)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
addBtn.Text = "💸 ADD SHEKLES"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 13
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,8)

addBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if not amount or amount <= 0 then
        status.Text = "❌ សូមបញ្ចូលចំនួនត្រឹមត្រូវ"
        return
    end

    -- កំណត់ Remote ពីប្រអប់
    local remoteName = remoteBox.Text
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    if not remote then
        -- សាកស្វែងរកដោយស្វ័យប្រវត្តិម្ដងទៀត
        remote = findRemote()
        if not remote then
            status.Text = "❌ រកមិនឃើញ Remote សូមបញ្ចូលឈ្មោះឲ្យត្រឹមត្រូវ"
            return
        end
    end

    -- បាញ់ Remote ជាមួយចំនួន
    remote:FireServer(amount)
    status.Text = "✅ បានបន្ថែម "..amount.." Sheckles!"
end)

-- ប៊ូតុង Refresh Remote
local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.new(0, 80, 0, 25)
refreshBtn.Position = UDim2.new(0.5, -40, 0, 190) -- នៅខាងក្រោម (អាចលុបចោល)
refreshBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
refreshBtn.Text = "🔄 Refresh"
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 10
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,6)
refreshBtn.MouseButton1Click:Connect(function()
    activeRemote = findRemote()
    if activeRemote then
        remoteBox.Text = activeRemote.Name
        status.Text = "✅ បានរកឃើញ Remote"
    else
        status.Text = "❌ នៅតែរកមិនឃើញ"
    end
end)