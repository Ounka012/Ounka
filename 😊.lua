--========================================================
-- SHECKLES HACK - FULL AUTO DETECT & ADD
--========================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

--========== ការកំណត់ ==========
local Settings = {
    Home = Root.Position,                  -- កំណត់ផ្ទះពេល Run (អាចចុច Set Home)
    Amount = 1000,                         -- ចំនួន Sheckles ដើម្បីបន្ថែម
    AutoFarm = false,
    AutoFarmRadius = 30,                   -- ចម្ងាយស្វែងរកវត្ថុ Sheckles
    RemoteFound = nil,                     -- នឹងត្រូវបានកំណត់ដោយស្វ័យប្រវត្តិ
}

--========== ស្វែងរក Remote សម្រាប់ Sheckles ==========
local function findRemote()
    -- ពាក្យគន្លឹះដែលអាចទាក់ទងនឹង Sheckles
    local keywords = {
        "sheckel", "sheckles", "shekel", "money", "cash", "coin",
        "currency", "reward", "give", "addmoney", "addcash", "addcoin",
        "earn", "collect", "credit", "point", "token"
    }
    -- ស្វែងរកក្នុង ReplicatedStorage ទាំងមូល
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    return obj
                end
            end
        end
    end
    -- ប្រសិនបើរកមិនឃើញ សាករកក្នុងកន្លែងផ្សេង
    for _, service in ipairs({Workspace, game:GetService("Players")}) do
        for _, obj in ipairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then return obj end
                end
            end
        end
    end
    return nil
end

Settings.RemoteFound = findRemote()

--========== មុខងារជំនួយ ==========
local function tp(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos)
    end
end

local function addSheckles(amount)
    local remote = Settings.RemoteFound
    if not remote then return false, "Remote not found" end

    -- សាកបាញ់តាមវិធីផ្សេងៗ
    local methods = {
        function() remote:FireServer(amount) end,
        function() remote:FireServer(LocalPlayer, amount) end,
        function() remote:FireServer("Sheckles", amount) end,
        function() remote:FireServer({Amount = amount}) end,
        function() remote:FireServer(LocalPlayer.UserId, amount) end,
    }
    local errors = {}
    for i, method in ipairs(methods) do
        local success, err = pcall(method)
        if success then
            return true, nil
        else
            table.insert(errors, err)
        end
    end
    return false, table.concat(errors, "; ")
end

local function findShecklesObjects()
    local objects = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("sheckel") then
            table.insert(objects, obj)
        elseif obj:IsA("Model") and obj.Name:lower():find("sheckel") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then table.insert(objects, part) end
        end
    end
    return objects
end

--========== GUI (ស្អាត មាន RGB) ==========
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesHack"
gui.IgnoreGuiInset = true

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 260)
main.Position = UDim2.new(0.5, -180, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 2

-- Drag
main.Draggable = true
main.Active = true

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "💰 SHECKLES HACK"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,215,0)

-- Close
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Status
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,45)
status.BackgroundTransparency = 1
status.Text = Settings.RemoteFound and "✅ រកឃើញ Remote: "..Settings.RemoteFound.Name or "❌ រកមិនឃើញ Remote"
status.TextColor3 = Settings.RemoteFound and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
status.Font = Enum.Font.Gotham
status.TextSize = 11

-- Amount Label
local amtLabel = Instance.new("TextLabel", main)
amtLabel.Size = UDim2.new(0,100,0,20)
amtLabel.Position = UDim2.new(0,10,0,75)
amtLabel.BackgroundTransparency = 1
amtLabel.Text = "ចំនួន:"
amtLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
amtLabel.Font = Enum.Font.Gotham
amtLabel.TextSize = 12

-- Amount Input
local amtInput = Instance.new("TextBox", main)
amtInput.Size = UDim2.new(0,120,0,28)
amtInput.Position = UDim2.new(0,120,0,71)
amtInput.BackgroundColor3 = Color3.fromRGB(50,50,55)
amtInput.TextColor3 = Color3.new(1,1,1)
amtInput.Font = Enum.Font.Gotham
amtInput.TextSize = 14
amtInput.PlaceholderText = "1000"
amtInput.Text = tostring(Settings.Amount)
Instance.new("UICorner", amtInput).CornerRadius = UDim.new(0,5)

-- Add Button
local addBtn = Instance.new("TextButton", main)
addBtn.Size = UDim2.new(0,130,0,35)
addBtn.Position = UDim2.new(0,10,0,110)
addBtn.BackgroundColor3 = Color3.fromRGB(255,215,0)
addBtn.Text = "💸 បន្ថែម Sheckles"
addBtn.TextColor3 = Color3.new(0,0,0)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 13
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,8)

addBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(amtInput.Text)
    if not amount or amount <= 0 then
        status.Text = "❌ បញ្ចូលចំនួនត្រឹមត្រូវ"
        return
    end
    if not Settings.RemoteFound then
        status.Text = "❌ គ្មាន Remote សាកប្រើ RemoteSpy មើល"
        return
    end
    status.Text = "⏳ កំពុងដំណើរការ..."
    local ok, err = addSheckles(amount)
    if ok then
        status.Text = "✅ បានបន្ថែម "..amount.." Sheckles"
    else
        status.Text = "❌ បរាជ័យ។ សូមពិនិត្យ Remote"
        warn("Add Sheckles Error: " .. (err or "unknown"))
    end
end)

-- Auto Farm Toggle
local autoBtn = Instance.new("TextButton", main)
autoBtn.Size = UDim2.new(0,130,0,35)
autoBtn.Position = UDim2.new(0,150,0,110)
autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
autoBtn.Text = "🔄 Auto Farm"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

autoBtn.MouseButton1Click:Connect(function()
    Settings.AutoFarm = not Settings.AutoFarm
    if Settings.AutoFarm then
        autoBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        autoBtn.Text = "⏹ បញ្ឈប់ Farm"
        status.Text = "🔄 កំពុង Auto-Farm..."
        -- ចាប់ផ្ដើម loop
        task.spawn(function()
            while Settings.AutoFarm do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local objs = findShecklesObjects()
                    for _, obj in ipairs(objs) do
                        if not Settings.AutoFarm then break end
                        if (obj.Position - root.Position).Magnitude <= Settings.AutoFarmRadius then
                            tp(obj.Position + Vector3.new(0,2,0))
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.5)
            end
            autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
            autoBtn.Text = "🔄 Auto Farm"
            tp(Settings.Home) -- ត្រឡប់មកផ្ទះ
        end)
    else
        autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
        autoBtn.Text = "🔄 Auto Farm"
        status.Text = "⏹ បានបញ្ឈប់ Farm"
    end
end)

-- Set Home Button
local homeBtn = Instance.new("TextButton", main)
homeBtn.Size = UDim2.new(0,130,0,28)
homeBtn.Position = UDim2.new(0,150,0,155)
homeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
homeBtn.Text = "📍 Set Home"
homeBtn.TextColor3 = Color3.new(1,1,1)
homeBtn.Font = Enum.Font.GothamBold
homeBtn.TextSize = 12
Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0,8)
homeBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        Settings.Home = root.Position
        status.Text = "✅ ផ្ទះបានកំណត់"
    end
end)

-- TP Home Button
local tpHomeBtn = Instance.new("TextButton", main)
tpHomeBtn.Size = UDim2.new(0,130,0,28)
tpHomeBtn.Position = UDim2.new(0,10,0,155)
tpHomeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
tpHomeBtn.Text = "🏠 TP មកផ្ទះ"
tpHomeBtn.TextColor3 = Color3.new(1,1,1)
tpHomeBtn.Font = Enum.Font.GothamBold
tpHomeBtn.TextSize = 12
Instance.new("UICorner", tpHomeBtn).CornerRadius = UDim.new(0,8)
tpHomeBtn.MouseButton1Click:Connect(function() tp(Settings.Home) end)

-- ពាក្យណែនាំ
local hint = Instance.new("TextLabel", main)
hint.Size = UDim2.new(1,-20,0,30)
hint.Position = UDim2.new(0,10,0,195)
hint.BackgroundTransparency = 1
hint.Text = "បើរកមិនឃើញ Remote សូមប្រើ RemoteSpy រកឈ្មោះ Remote ដែលបាញ់ពេលទទួល Sheckles"
hint.TextColor3 = Color3.fromRGB(180,180,180)
hint.Font = Enum.Font.Gotham
hint.TextSize = 9
hint.TextWrapped = true

-- RGB effect
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        mainStroke.Color = Color3.fromHSV((hue+0.3)%1, 1, 1)
        task.wait(0.03)
    end
end)