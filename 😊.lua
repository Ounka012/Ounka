-- Dragon's Breath Auto Buyer (Brute Force)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ឈ្មោះ Dragon's Breath ដែលអាចមាន (ពង្រីក)
local ITEM_NAMES = {
    "Dragon's Breath", "Dragon's Breath Seed", "DragonBreath", "Dragon Breath",
    "Dragon Seed", "DragonFruit Seed", "dragonbreath", "DragonBreath Seed",
    "Dragon Fruit", "Dragonfruit", "Dragon_Fruit"
}

-- ប្រមូលគ្រប់ RemoteEvent/RemoteFunction
local function getAllRemotes()
    local remotes = {}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage"), game:GetService("ServerScriptService")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotes, obj)
                end
            end
        end)
    end
    return remotes
end

-- សាកបាញ់ Remote ជាមួយ Argument ច្រើនគំរូ
local function tryPurchase(remote, itemName)
    if not remote then return false end
    local success = false
    -- ទម្រង់ Argument ជាច្រើន
    local argsList = {
        {itemName},
        {itemName, 1},
        {LocalPlayer, itemName, 1},
        {itemName, LocalPlayer},
        {{Item = itemName, Quantity = 1}},
        {{itemName, 1}},
        {itemName, 1, LocalPlayer},
        {1, itemName},
        {LocalPlayer, itemName},
        {itemName, LocalPlayer, 1},
    }
    for _, args in ipairs(argsList) do
        if remote:IsA("RemoteEvent") then
            success = pcall(function() remote:FireServer(unpack(args)) end)
        elseif remote:IsA("RemoteFunction") then
            success = pcall(function() remote:InvokeServer(unpack(args)) end)
        end
        if success then return true end
    end
    return false
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "DragonBuyer"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.35, 0)
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
title.Text = "🐉 Dragon Breath Buyer"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 45)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "ត្រៀមរួចរាល់"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

local buyBtn = Instance.new("TextButton", frame)
buyBtn.Size = UDim2.new(0, 160, 0, 40)
buyBtn.Position = UDim2.new(0.5, -80, 0, 90)
buyBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
buyBtn.Text = "ទិញ Dragon Breath ឥឡូវ"
buyBtn.TextColor3 = Color3.new(1,1,1)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 13
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0,8)

buyBtn.MouseButton1Click:Connect(function()
    status.Text = "កំពុងស្វែងរក Remote និងសាកទិញ..."
    local remotes = getAllRemotes()
    if #remotes == 0 then
        status.Text = "❌ គ្មាន Remote នៅក្នុង Server!"
        return
    end

    local tried = 0
    for _, remote in ipairs(remotes) do
        for _, itemName in ipairs(ITEM_NAMES) do
            tried = tried + 1
            status.Text = string.format("សាក %d/%d\nRemote: %s\nទំនិញ: %s", tried, #remotes * #ITEM_NAMES, remote.Name, itemName)
            if tryPurchase(remote, itemName) then
                status.Text = "✅ ទិញបានហើយ!\n" .. itemName .. "\nតាមរយៈ " .. remote.Name
                return
            end
            task.wait(0.03) -- កុំឲ្យបាញ់ញឹកពេក
        end
    end
    status.Text = "❌ បរាជ័យ។ សូមប្រើ RemoteSpy ដើម្បីរកឈ្មោះ Remote ពិត។"
end)

-- ប៊ូតុងបង្ហាញ Remotes
local listBtn = Instance.new("TextButton", frame)
listBtn.Size = UDim2.new(0, 120, 0, 25)
listBtn.Position = UDim2.new(0, 10, 0, 140)
listBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
listBtn.Text = "បង្ហាញ Remotes"
listBtn.TextColor3 = Color3.new(1,1,1)
listBtn.Font = Enum.Font.Gotham
listBtn.TextSize = 11
Instance.new("UICorner", listBtn).CornerRadius = UDim.new(0,5)
listBtn.MouseButton1Click:Connect(function()
    local remotes = getAllRemotes()
    local list = "Remotes:\n"
    for _, r in ipairs(remotes) do
        list = list .. r.Name .. " (" .. r.ClassName .. ")\n"
    end
    status.Text = list
end)

-- បិទ
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
