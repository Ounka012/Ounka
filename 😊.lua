-- Grow a Garden 2: Ultimate Dragon Breath Farmer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ការកំណត់
local HOME_POS = Vector3.new(0, 10, 0)   -- ចុច Set Home ដើម្បីកំណត់
local TARGET_SHECKLES = 250             -- ទិញនៅពេល Sheckles ដល់ចំនួននេះ
local HOLD_TIME = 0.6

local shopRemote = nil
local running = false
local totalStolen = 0

-- ទទួលចំនួន Sheckles ពី leaderstats (រកឈ្មោះផ្សេងៗ)
local function getSheckles()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        for _, v in pairs(stats:GetChildren()) do
            if (v:IsA("NumberValue") or v:IsA("IntValue")) and v.Name:lower():find("sheck") then
                return v.Value
            end
        end
    end
    return 0
end

-- រកដំណាំអ្នកដទៃ (មានប្រអប់ Steal)
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

-- រក Remote ហាងដោយស្វ័យប្រវត្តិ
local function findShopRemote()
    local keywords = {"buy", "purchase", "shop", "seed", "store", "acquire", "order"}
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

-- ទិញ Dragon's Breath ដោយប្រើ Remote
local function buyDragon(remote)
    if not remote then return false end
    local items = {"Dragon's Breath", "Dragon's Breath Seed", "DragonBreath", "Dragon Breath", "Dragon Seed", "DragonFruit Seed"}
    for _, item in ipairs(items) do
        local ok = false
        if remote:IsA("RemoteEvent") then
            ok = pcall(function() remote:FireServer(item, 1) end)
            if not ok then ok = pcall(function() remote:FireServer(LocalPlayer, item, 1) end) end
        elseif remote:IsA("RemoteFunction") then
            ok = pcall(function() remote:InvokeServer(item, 1) end)
        end
        if ok then return true end
    end
    return false
end

-- ស្កេន Backdoor (Give/Add Item)
local function backdoorScan()
    local items = {"Dragon's Breath", "DragonBreath", "Dragon Seed", "Dragon's Breath Seed"}
    local keywords = {"give", "add", "grant", "item", "backdoor", "admin", "reward", "giveitem", "additem"}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage"), game:GetService("ServerScriptService")}
    for _, service in ipairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then
                            print("Backdoor attempt: " .. obj.Name)
                            for _, item in ipairs(items) do
                                if obj:IsA("RemoteEvent") then
                                    pcall(function() obj:FireServer(item, 1) end)
                                    pcall(function() obj:FireServer(LocalPlayer, item, 1) end)
                                elseif obj:IsA("RemoteFunction") then
                                    pcall(function() obj:InvokeServer(item, 1) end)
                                end
                            end
                            return true
                        end
                    end
                end
            end
        end)
    end
    return false
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "UltimateFarm"
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
title.Text = "🐉 Dragon Breath Ultimate"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 55)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "Sheckles: " .. getSheckles() .. "\nចុច Start"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true

local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(0, 120, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 100)
startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
startBtn.Text = "Start"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 13
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,8)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(0, 120, 0, 40)
stopBtn.Position = UDim2.new(0, 140, 0, 100)
stopBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
stopBtn.Text = "Stop"
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 13
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,8)

local backdoorBtn = Instance.new("TextButton", frame)
backdoorBtn.Size = UDim2.new(0, 120, 0, 30)
backdoorBtn.Position = UDim2.new(0, 10, 0, 150)
backdoorBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
backdoorBtn.Text = "សាក Backdoor"
backdoorBtn.TextColor3 = Color3.new(1,1,1)
backdoorBtn.Font = Enum.Font.GothamBold
backdoorBtn.TextSize = 11
Instance.new("UICorner", backdoorBtn).CornerRadius = UDim.new(0,6)

local homeBtn = Instance.new("TextButton", frame)
homeBtn.Size = UDim2.new(0, 120, 0, 30)
homeBtn.Position = UDim2.new(0, 140, 0, 150)
homeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
homeBtn.Text = "Set Home"
homeBtn.TextColor3 = Color3.new(1,1,1)
homeBtn.Font = Enum.Font.Gotham
homeBtn.TextSize = 11
Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0,6)

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

-- Events
startBtn.MouseButton1Click:Connect(function()
    running = true
    shopRemote = findShopRemote()
    status.Text = "Sheckles: " .. getSheckles() .. "\nចាប់ផ្ដើម..."
    if shopRemote then
        status.Text = status.Text .. "\nរកឃើញហាង: " .. shopRemote.Name
    else
        status.Text = status.Text .. "\nរកមិនឃើញហាង នឹងសាក Backdoor ពេល Sheckles គ្រប់"
    end

    task.spawn(function()
        while running do
            local sheckles = getSheckles()
            status.Text = string.format("Sheckles: %d / %d\nកំពុងដំណើរការ...", sheckles, TARGET_SHECKLES)

            if sheckles >= TARGET_SHECKLES then
                status.Text = "Sheckles គ្រប់! កំពុងព្យាយាមទិញ..."
                if shopRemote then
                    local bought = buyDragon(shopRemote)
                    if bought then
                        status.Text = "✅ ទិញ Dragon បាន!\nSheckles: " .. getSheckles()
                        running = false  -- ឈប់បន្ទាប់ពីជោគជ័យ
                        break
                    else
                        status.Text = "❌ ទិញមិនបាន សាក Backdoor..."
                        backdoorScan()
                        status.Text = "បានសាក Backdoor រួច\nSheckles: " .. getSheckles()
                        running = false
                        break
                    end
                else
                    status.Text = "គ្មានហាង កំពុងសាក Backdoor..."
                    backdoorScan()
                    status.Text = "បានសាក Backdoor\nSheckles: " .. getSheckles()
                    running = false
                    break
                end
            end

            -- បើ Sheckles មិនគ្រប់ លួច
            local plants = findPlants()
            if #plants > 0 then
                for _, plant in ipairs(plants) do
                    if not running or getSheckles() >= TARGET_SHECKLES then break end
                    steal(plant)
                    task.wait(0.3)
                end
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(HOME_POS)
                end)
            else
                status.Text = "Sheckles: " .. sheckles .. "\nរកមិនឃើញដំណាំ"
            end
            task.wait(2)
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
    status.Text = "បានបញ្ឈប់\nSheckles: " .. getSheckles()
end)

backdoorBtn.MouseButton1Click:Connect(function()
    status.Text = "កំពុងសាក Backdoor..."
    local found = backdoorScan()
    if found then
        status.Text = "បានព្យាយាម Backdoor\nពិនិត្យ Inventory"
    else
        status.Text = "រកមិនឃើញ Backdoor"
    end
end)

homeBtn.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        HOME_POS = root.Position
        status.Text = "ផ្ទះបានកំណត់"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

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
