
-- Grow a Garden 2: Free Seed Shop (Buy without Sheckles)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

local shopRemote = nil
local itemToBuy = "Dragon's Breath"  -- ឈ្មោះគ្រាប់ពូជ (កែបាន)

-- ស្វែងរក Remote ដែលប្រើសម្រាប់ទិញឥវ៉ាន់
local function scanForShopRemote()
    local keywords = {"buy", "purchase", "shop", "acquire", "getitem", "additem", "seed", "store"}
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

-- ស្កេនដំបូង
shopRemote = scanForShopRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "FreeShop"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.35, 0)
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
title.Text = "🛒 Free Seed Shop"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,33)
status.BackgroundTransparency = 1
status.Text = shopRemote and "✅ រកឃើញ Remote: "..shopRemote.Name or "❌ រកមិនឃើញ Remote"
status.TextColor3 = shopRemote and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

-- ប្រអប់ដាក់ឈ្មោះគ្រាប់ពូជ
local itemLabel = Instance.new("TextLabel", frame)
itemLabel.Size = UDim2.new(0, 60, 0, 20)
itemLabel.Position = UDim2.new(0, 10, 0, 70)
itemLabel.BackgroundTransparency = 1
itemLabel.Text = "គ្រាប់ពូជ:"
itemLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
itemLabel.Font = Enum.Font.Gotham
itemLabel.TextSize = 10

local itemInput = Instance.new("TextBox", frame)
itemInput.Size = UDim2.new(0, 140, 0, 24)
itemInput.Position = UDim2.new(0, 75, 0, 68)
itemInput.BackgroundColor3 = Color3.fromRGB(50,50,55)
itemInput.TextColor3 = Color3.new(1,1,1)
itemInput.Font = Enum.Font.Gotham
itemInput.TextSize = 12
itemInput.Text = "Dragon's Breath"
Instance.new("UICorner", itemInput).CornerRadius = UDim.new(0,4)

itemInput.FocusLost:Connect(function()
    itemToBuy = itemInput.Text
    status.Text = "កំណត់ទិញ: " .. itemToBuy
end)

-- ប៊ូតុងទិញ
local buyBtn = Instance.new("TextButton", frame)
buyBtn.Size = UDim2.new(0, 120, 0, 35)
buyBtn.Position = UDim2.new(0, 10, 0, 100)
buyBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
buyBtn.Text = "ទិញឥតលុយ"
buyBtn.TextColor3 = Color3.new(1,1,1)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 12
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0,8)

buyBtn.MouseButton1Click:Connect(function()
    if not shopRemote then
        status.Text = "❌ គ្មាន Remote សាកស្កេនឡើងវិញ"
        return
    end
    -- ព្យាយាមបាញ់ Remote តាមវិធីផ្សេងៗ
    local success = false
    local item = itemInput.Text
    -- សាកបាញ់ជាមួយឈ្មោះគ្រាប់ពូជ និងចំនួន 1
    if shopRemote:IsA("RemoteEvent") then
        success = pcall(function() shopRemote:FireServer(item, 1) end)
        if not success then
            success = pcall(function() shopRemote:FireServer(LocalPlayer, item, 1) end)
        end
        if not success then
            success = pcall(function() shopRemote:FireServer({Item = item, Quantity = 1}) end)
        end
    elseif shopRemote:IsA("RemoteFunction") then
        success = pcall(function() shopRemote:InvokeServer(item, 1) end)
        if not success then
            success = pcall(function() shopRemote:InvokeServer(LocalPlayer, item, 1) end)
        end
    end
    if success then
        status.Text = "✅ បានទិញ " .. item
    else
        status.Text = "❌ បរាជ័យ សាកឈ្មោះ Remote ផ្សេង"
    end
end)

-- ប៊ូតុងស្កេនថ្មី
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 100, 0, 25)
scanBtn.Position = UDim2.new(0, 140, 0, 105)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    shopRemote = scanForShopRemote()
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