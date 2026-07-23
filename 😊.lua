-- Grow a Garden 2: Auto-Steal + Auto-Buy Dragon's Breath
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local HOME_POS = Vector3.new(0, 10, 0)
local HOLD_TIME = 0.6

-- ស្ថានភាព
local stealRunning = false
local buyRunning = false
local totalStolen = 0
local shopRemote = nil

-- ឈ្មោះ Dragon's Breath ដែលអាចមាន
local ITEM_NAMES = {
    "Dragon's Breath", "Dragon's Breath Seed", "DragonBreath",
    "Dragon Breath", "Dragon Seed", "DragonFruit Seed"
}

--========== រកដំណាំអ្នកដទៃ (Steal) ==========
local function findPlants()
    local plants = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local owner = obj:GetAttribute("Owner") or obj:GetAttribute("owner")
            if not owner then
                local v = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner")
                if v and v:IsA("StringValue") then owner = v.Value end
                if v and v:IsA("ObjectValue") and v.Value then owner = v.Value.Name end
            end
            if owner and owner ~= LocalPlayer.Name then
                for _, p in pairs(obj:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and (p.ActionText:lower():find("steal") or p.Name:lower():find("steal")) then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part then table.insert(plants, {Model=obj, Part=part, Prompt=p}) end
                        break
                    end
                end
            end
        end
    end
    return plants
end

-- លួចមួយដើម
local function steal(plant)
    local prompt = plant.Prompt
    if not prompt.Parent then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = plant.Part.CFrame * CFrame.new(0,4,0)
    task.wait(0.1)
    prompt.MaxActivationDistance = 100
    prompt.RequiresLineOfSight = false
    local hold = prompt.HoldDuration > 0 and prompt.HoldDuration or HOLD_TIME
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(hold + 0.1)
    pcall(function() prompt:InputHoldEnd() end)
    totalStolen = totalStolen + 1
end

--========== ទិញ Dragon's Breath ==========
local function tryBuy(remote, itemName)
    if not remote then return false end
    local success = false
    local argsList = {
        {itemName}, {itemName, 1}, {LocalPlayer, itemName, 1},
        {itemName, LocalPlayer}, {{Item = itemName, Quantity = 1}},
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

-- ស្វែងរក Remote ហាង
local function autoFindShopRemote()
    local keywords = {"buy", "purchase", "shop", "seed", "store"}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then return obj end
                    end
                end
            end
        end)
    end
    return nil
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "AllInOne"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 260)
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
title.Text = "🐉 Dragon Breath Auto"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "ចុច លួចដើម្បីបាន Sheckles\nបន្ទាប់មកចុច ទិញ Dragon"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

-- ប៊ូតុង Auto‑Steal
local stealBtn = Instance.new("TextButton", frame)
stealBtn.Size = UDim2.new(0, 120, 0, 40)
stealBtn.Position = UDim2.new(0, 10, 0, 105)
stealBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
stealBtn.Text = "លួច Sheckles"
stealBtn.TextColor3 = Color3.new(1,1,1)
stealBtn.Font = Enum.Font.GothamBold
stealBtn.TextSize = 12
Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0,8)

stealBtn.MouseButton1Click:Connect(function()
    stealRunning = not stealRunning
    if stealRunning then
        stealBtn.Text = "កំពុងលួច..."
        stealBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
        status.Text = "កំពុងលួចផ្លែឈើគេ..."
        task.spawn(function()
            while stealRunning do
                local plants = findPlants()
                if #plants > 0 then
                    for _, plant in ipairs(plants) do
                        if not stealRunning then break end
                        steal(plant)
                        status.Text = "លួច: " .. totalStolen .. " ដើម"
                        task.wait(0.3)
                    end
                    pcall(function()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(HOME_POS)
                    end)
                else
                    status.Text = "រកមិនឃើញដំណាំ"
                end
                task.wait(2)
            end
            stealBtn.Text = "លួច Sheckles"
            stealBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
            status.Text = "បានបញ្ឈប់ការលួច | សរុប " .. totalStolen .. " ដើម"
        end)
    else
        stealRunning = false
    end
end)

-- ប៊ូតុង Auto‑Buy
local buyBtn = Instance.new("TextButton", frame)
buyBtn.Size = UDim2.new(0, 120, 0, 40)
buyBtn.Position = UDim2.new(0, 140, 0, 105)
buyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
buyBtn.Text = "ទិញ Dragon"
buyBtn.TextColor3 = Color3.new(1,1,1)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 12
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0,8)

buyBtn.MouseButton1Click:Connect(function()
    if not shopRemote then
        status.Text = "កំពុងរក Remote ហាង..."
        shopRemote = autoFindShopRemote()
        if not shopRemote then
            status.Text = "❌ រកមិនឃើញ Remote ហាង\nសូមប្រើប៊ូតុង Learn ឬមើល Remotes"
            return
        end
        status.Text = "✅ បានរកឃើញ Remote: " .. shopRemote.Name
    end

    status.Text = "កំពុងទិញ Dragon..."
    for _, itemName in ipairs(ITEM_NAMES) do
        if tryBuy(shopRemote, itemName) then
            status.Text = "✅ ទិញបាន: " .. itemName .. "\nសូមពិនិត្យ Inventory"
            return
        end
        task.wait(0.1)
    end
    status.Text = "❌ មិនអាចទិញបាន។\nត្រូវប្រាកដថាមាន Sheckles គ្រប់"
end)

-- ប៊ូតុង Learn (រៀន Remote ដោយទិញដោយដៃម្ដង)
local learnBtn = Instance.new("TextButton", frame)
learnBtn.Size = UDim2.new(0, 120, 0, 30)
learnBtn.Position = UDim2.new(0, 10, 0, 160)
learnBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
learnBtn.Text = "Learn (ទិញដោយដៃ)"
learnBtn.TextColor3 = Color3.new(1,1,1)
learnBtn.Font = Enum.Font.Gotham
learnBtn.TextSize = 11
Instance.new("UICorner", learnBtn).CornerRadius = UDim.new(0,6)

learnBtn.MouseButton1Click:Connect(function()
    status.Text = "សូមចូលហាង ហើយទិញគ្រាប់ពូជណាមួយដោយដៃ\n(ឧ. គ្រាប់ពូជថោក) បន្ទាប់មករង់ចាំ 5 វិនាទី..."
    task.delay(5, function()
        shopRemote = autoFindShopRemote()
        if shopRemote then
            status.Text = "✅ បានរៀន Remote: " .. shopRemote.Name
        else
            status.Text = "❌ នៅតែមិនឃើញ Remote"
        end
    end)
end)

-- ប៊ូតុងបង្ហាញ Remotes ទាំងអស់
local listBtn = Instance.new("TextButton", frame)
listBtn.Size = UDim2.new(0, 120, 0, 30)
listBtn.Position = UDim2.new(0, 140, 0, 160)
listBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
listBtn.Text = "បង្ហាញ Remotes"
listBtn.TextColor3 = Color3.new(1,1,1)
listBtn.Font = Enum.Font.Gotham
listBtn.TextSize = 11
Instance.new("UICorner", listBtn).CornerRadius = UDim.new(0,6)
listBtn.MouseButton1Click:Connect(function()
    local list = "Remotes:\n"
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    list = list .. obj.Name .. "\n"
                end
            end
        end)
    end
    status.Text = list
end)

-- Set Home
local homeBtn = Instance.new("TextButton", frame)
homeBtn.Size = UDim2.new(0, 120, 0, 30)
homeBtn.Position = UDim2.new(0, 10, 0, 200)
homeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
homeBtn.Text = "📍 Set Home"
homeBtn.TextColor3 = Color3.new(1,1,1)
homeBtn.Font = Enum.Font.Gotham
homeBtn.TextSize = 11
Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0,6)
homeBtn.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then HOME_POS = root.Position; status.Text = "ផ្ទះបានកំណត់" end
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
closeBtn.MouseButton1Click:Connect(function()
    stealRunning = false
    buyRunning = false
    gui:Destroy()
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
