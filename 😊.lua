-- Grow a Garden 2: Auto Buy Dragon's Breath (Free Shop Hack)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local shopRemote = nil
local learnedArgs = nil  -- ចំណាំ Argument ពេលរៀន

-- បញ្ជីឈ្មោះ Dragon's Breath ដែលអាចមាន
local itemNames = {
    "Dragon's Breath",
    "Dragon's Breath Seed",
    "DragonBreath",
    "Dragon Breath",
    "Dragon Seed",
    "DragonFruit Seed",
    "dragonbreath",
}

-- ស្វែងរក Remote ហាង
local function scanForRemote()
    local keywords = {"buy", "purchase", "shop", "seed", "getitem", "acquire", "request", "store", "order"}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage"), game:GetService("ServerScriptService")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then return obj, nil end
                    end
                end
            end
        end)
    end
    return nil, "មិនឃើញ Remote"
end

-- ព្យាយាមទិញឥវ៉ាន់ (Fire remote)
local function tryBuy(itemName)
    if not shopRemote then return false end
    local ok = false
    -- សាក Argument ច្រើនគំរូ
    local argsList = {
        {itemName},
        {itemName, 1},
        {LocalPlayer, itemName, 1},
        {itemName, LocalPlayer},
        {{Item = itemName, Quantity = 1}},
    }
    for _, args in ipairs(argsList) do
        if shopRemote:IsA("RemoteEvent") then
            ok = pcall(function() shopRemote:FireServer(unpack(args)) end)
        elseif shopRemote:IsA("RemoteFunction") then
            ok = pcall(function() shopRemote:InvokeServer(unpack(args)) end)
        end
        if ok then return true end
    end
    return false
end

-- រៀន Remote ពីការទិញដោយដៃ (Hook FireServer)
local function learnMode(statusLabel)
    statusLabel.Text = "រៀន៖ សូមទិញអ្វីមួយដោយដៃនៅហាង..."
    local oldFire; oldFire = hookfunction(RemoteEvent.FireServer, function(self, ...)
        local args = {...}
        if self and self:IsA("RemoteEvent") then
            shopRemote = self
            learnedArgs = args
            statusLabel.Text = "✅ បានរៀន Remote: " .. self.Name
            print("Learned Remote:", self.Name, "Args:", args)
            -- ឈប់ hook
            hookfunction(RemoteEvent.FireServer, oldFire)
        end
        return oldFire(self, ...)
    end)
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "SeedShopHack"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 220)
frame.Position = UDim2.new(0.5, -170, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "🛒 Dragon Seed Buyer"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,40)
status.Position = UDim2.new(0,10,0,33)
status.BackgroundTransparency = 1
status.Text = "ចុច Auto Buy ឬ Learn មុន"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

-- ប៊ូតុង Auto Buy (សាកឈ្មោះទាំងអស់)
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0, 140, 0, 35)
autoBtn.Position = UDim2.new(0, 10, 0, 85)
autoBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
autoBtn.Text = "Auto Buy (រកឈ្មោះ)"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

autoBtn.MouseButton1Click:Connect(function()
    if not shopRemote then
        shopRemote, _ = scanForRemote()
        if not shopRemote then
            status.Text = "❌ រកមិនឃើញ Remote សូមប្រើ Learn មុន"
            return
        end
    end
    status.Text = "កំពុងសាកឈ្មោះ..."
    for _, name in ipairs(itemNames) do
        status.Text = "កំពុងសាក: " .. name
        if tryBuy(name) then
            status.Text = "✅ ទិញបាន: " .. name
            return
        end
        task.wait(0.2)
    end
    status.Text = "❌ គ្មានឈ្មោះណាត្រូវ សាកប្ដូរក្នុង itemNames"
end)

-- ប៊ូតុង Learn (ចាប់ Remote ពេលទិញដោយដៃ)
local learnBtn = Instance.new("TextButton", frame)
learnBtn.Size = UDim2.new(0, 140, 0, 35)
learnBtn.Position = UDim2.new(0, 160, 0, 85)
learnBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
learnBtn.Text = "Learn (ទិញដោយដៃម្ដង)"
learnBtn.TextColor3 = Color3.new(1,1,1)
learnBtn.Font = Enum.Font.GothamBold
learnBtn.TextSize = 12
Instance.new("UICorner", learnBtn).CornerRadius = UDim.new(0,8)

learnBtn.MouseButton1Click:Connect(function()
    learnMode(status)
end)

-- ប៊ូតុងស្កេនឡើងវិញ
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 100, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 135)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    shopRemote, _ = scanForRemote()
    if shopRemote then
        status.Text = "✅ បានរកឃើញ Remote: " .. shopRemote.Name
    else
        status.Text = "❌ មិនឃើញ Remote"
    end
end)

-- ប៊ូតុងបិទ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-30,0,2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- បង្ហាញថាតើបាន Remote ហើយឬនៅ
spawn(function()
    while gui.Parent do
        if shopRemote then
            status.Text = "✅ Remote: " .. shopRemote.Name .. " | ចុច Auto Buy"
        end
        wait(2)
    end
end)

-- RGB
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        stroke.Color = Color3.fromHSV((hue+0.3)%1, 1, 1)
        task.wait(0.03)
    end
end)