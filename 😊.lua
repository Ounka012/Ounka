-- Grow a Garden 2: Auto Buy Dragon's Breath from Seed Shop
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local shopRemote = nil
-- បញ្ជីឈ្មោះ Dragon's Breath ដែលអាចមានក្នុងហាង
local possibleNames = {
    "Dragon's Breath",
    "Dragon's Breath Seed",
    "DragonBreath",
    "Dragon Breath",
    "Dragon Seed",
    "DragonFruit Seed",
}

-- ស្វែងរក Remote របស់ហាង
local function findShopRemote()
    local keywords = {"buy", "purchase", "shop", "acquire", "getitem", "seed", "store", "requestpurchase"}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then return obj end
            end
        end
    end
    return nil
end

shopRemote = findShopRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "DragonBuyer"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 160)
frame.Position = UDim2.new(0.5, -160, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "🛒 Dragon's Breath Buyer"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,35)
status.Position = UDim2.new(0,10,0,33)
status.BackgroundTransparency = 1
status.Text = shopRemote and "✅ Remote: "..shopRemote.Name or "❌ រកមិនឃើញ Remote"
status.TextColor3 = shopRemote and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

-- ប៊ូតុងទិញ (Auto-Find Name)
local buyBtn = Instance.new("TextButton", frame)
buyBtn.Size = UDim2.new(0, 160, 0, 35)
buyBtn.Position = UDim2.new(0, 10, 0, 80)
buyBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
buyBtn.Text = "ទិញ Dragon ឥឡូវ"
buyBtn.TextColor3 = Color3.new(1,1,1)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 12
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0,8)

buyBtn.MouseButton1Click:Connect(function()
    if not shopRemote then
        status.Text = "❌ គ្មាន Remote ចុចស្កេនថ្មី"
        return
    end

    status.Text = "កំពុងរកឈ្មោះ..."
    for _, tryName in ipairs(possibleNames) do
        status.Text = "សាក: " .. tryName
        local success = false
        if shopRemote:IsA("RemoteEvent") then
            success = pcall(function() shopRemote:FireServer(tryName, 1) end)
            if not success then
                success = pcall(function() shopRemote:FireServer(LocalPlayer, tryName, 1) end)
            end
        elseif shopRemote:IsA("RemoteFunction") then
            success = pcall(function() shopRemote:InvokeServer(tryName, 1) end)
        end
        if success then
            status.Text = "✅ បានទិញ: " .. tryName
            return
        end
        task.wait(0.2)
    end
    status.Text = "❌ គ្មានឈ្មោះដែលត្រូវ ពិនិត្យក្នុងហាង"
end)

-- ស្កេនថ្មី
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 90, 0, 25)
scanBtn.Position = UDim2.new(0, 180, 0, 85)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    shopRemote = findShopRemote()
    if shopRemote then
        status.Text = "✅ រកឃើញ Remote: "..shopRemote.Name
    else
        status.Text = "❌ រកមិនឃើញ (ប្រើ RemoteSpy ពេលទិញធម្មតា)"
    end
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