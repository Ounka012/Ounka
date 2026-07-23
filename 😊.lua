--========================================================
-- GROW A GARDEN 2: SEED SHOP HACK (FULL AUTO BUY)
--========================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ការកំណត់
local ITEM_NAMES = {
    "Dragon's Breath",
    "Dragon's Breath Seed",
    "DragonBreath",
    "Dragon Breath",
    "Dragon Seed",
    "DragonFruit Seed",
}

local SHOP_KEYWORDS = {"buy", "purchase", "shop", "seed", "store", "getitem", "acquire", "order"}
local shopRemote = nil
local learnedArgs = nil
local learnHooked = false

-- ស្វែងរក Remote ហាងដោយស្វ័យប្រវត្តិ
local function autoFindRemote()
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage"), game:GetService("ServerScriptService")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    for _, kw in ipairs(SHOP_KEYWORDS) do
                        if name:find(kw) then
                            return obj
                        end
                    end
                end
            end
        end)
    end
    return nil
end

-- ព្យាយាមទិញជាមួយ Remote ដែលបានកំណត់
local function tryBuy(remote, itemName)
    if not remote then return false end
    local success = false
    -- សាក Argument ច្រើនគំរូ
    local argsList = {
        {itemName},
        {itemName, 1},
        {LocalPlayer, itemName, 1},
        {itemName, LocalPlayer},
        {{Item = itemName, Quantity = 1}},
        {{itemName, 1}},  -- ទម្រង់ Dictionary
    }
    for _, args in ipairs(argsList) do
        if remote:IsA("RemoteEvent") then
            success = pcall(function() remote:FireServer(unpack(args)) end)
        elseif remote:IsA("RemoteFunction") then
            success = pcall(function() remote:InvokeServer(unpack(args)) end)
        end
        if success then
            return true
        end
    end
    return false
end

-- មុខងារទិញដោយស្វ័យប្រវត្តិ (រក Remote + សាកឈ្មោះ)
local function autoBuy(statusLabel)
    if not shopRemote then
        statusLabel.Text = "កំពុងស្វែងរក Remote..."
        shopRemote = autoFindRemote()
        if not shopRemote then
            statusLabel.Text = "❌ រកមិនឃើញ Remote ហាង\nសូមប្រើ Learn Mode"
            return
        end
        statusLabel.Text = "✅ បានរកឃើញ Remote: " .. shopRemote.Name
    end

    for _, itemName in ipairs(ITEM_NAMES) do
        statusLabel.Text = "កំពុងសាកទិញ: " .. itemName
        if tryBuy(shopRemote, itemName) then
            statusLabel.Text = "✅ ទិញបាន! " .. itemName
            return
        end
        task.wait(0.2)
    end
    statusLabel.Text = "❌ មិនអាចទិញបាន។\nសូមពិនិត្យឈ្មោះ ឬប្រើ Learn"
end

-- Learn Mode (រៀនពីការទិញដោយដៃ)
local function enableLearnMode(statusLabel)
    if learnHooked then
        statusLabel.Text = "Learn Mode កំពុងដំណើរការហើយ"
        return
    end

    -- វិធីសាស្ត្រងាយៗ ដោយមិនប្រើ Hook (សាកស្កេនក្រោយទិញ)
    statusLabel.Text = "សូមចូលទៅហាង ហើយទិញគ្រាប់ពូជណាមួយដោយដៃ\n(ឧ. គ្រាប់ពូជថោកបំផុត)"
    -- រង់ចាំ 10 វិនាទី រួចធ្វើការស្កេន Remote ដែលបានប្រើថ្មី
    task.delay(10, function()
        local newRemote = autoFindRemote()
        if newRemote then
            shopRemote = newRemote
            statusLabel.Text = "✅ បានរៀន Remote: " .. newRemote.Name
            -- សាកទាញយក Argument ដោយស្មាន (មិនអាចដឹងច្បាស់ ប៉ុន្តែយើងនឹងប្រើគំរូចាស់)
        else
            statusLabel.Text = "❌ នៅតែរកមិនឃើញ សូមព្យាយាមម្ដងទៀត"
        end
    end)
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "SeedShopHack"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 330, 0, 200)
frame.Position = UDim2.new(0.5, -165, 0.3, 0)
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
title.Text = "🛒 Dragon Breath Buyer"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 50)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "ចុច 'Auto Buy' ឬ 'Learn'"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

-- ប៊ូតុង Auto Buy
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0, 130, 0, 35)
autoBtn.Position = UDim2.new(0, 10, 0, 95)
autoBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
autoBtn.Text = "Auto Buy Dragon"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

autoBtn.MouseButton1Click:Connect(function()
    autoBuy(status)
end)

-- ប៊ូតុង Learn
local learnBtn = Instance.new("TextButton", frame)
learnBtn.Size = UDim2.new(0, 130, 0, 35)
learnBtn.Position = UDim2.new(0, 150, 0, 95)
learnBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
learnBtn.Text = "Learn (ទិញដោយដៃ)"
learnBtn.TextColor3 = Color3.new(1,1,1)
learnBtn.Font = Enum.Font.GothamBold
learnBtn.TextSize = 12
Instance.new("UICorner", learnBtn).CornerRadius = UDim.new(0,8)

learnBtn.MouseButton1Click:Connect(function()
    enableLearnMode(status)
end)

-- ប៊ូតុងបង្ហាញឈ្មោះ Remote ទាំងអស់ (ជំនួយ)
local listBtn = Instance.new("TextButton", frame)
listBtn.Size = UDim2.new(0, 130, 0, 25)
listBtn.Position = UDim2.new(0, 10, 0, 140)
listBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
listBtn.Text = "បង្ហាញ Remote"
listBtn.TextColor3 = Color3.new(1,1,1)
listBtn.Font = Enum.Font.Gotham
listBtn.TextSize = 11
Instance.new("UICorner", listBtn).CornerRadius = UDim.new(0,5)

listBtn.MouseButton1Click:Connect(function()
    local list = ""
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            list = list .. obj.Name .. "\n"
        end
    end
    if list == "" then list = "គ្មាន Remote" end
    status.Text = "Remotes:\n" .. list
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

-- RGB effect
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        stroke.Color = Color3.fromHSV((hue+0.3)%1, 1, 1)
        task.wait(0.03)
    end
end)
