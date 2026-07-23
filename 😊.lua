--========================================================
-- SHECKLES INSTANT HACK (HIGH-LEVEL, FULL FEATURES)
-- មុខងារ៖ បន្ថែម Sheckles ភ្លាមៗ + Auto-Farm វត្ថុ Sheckles
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg" -- រូបភាព (អាចប្តូរ)
local FILE_NAME = "sheckles_bg.jpg"

--============== ការកំណត់ ==============
local Settings = {
    HomePosition = Vector3.new(0, 10, 0),  -- កែតាមទីតាំងផ្ទះអ្នក
    AutoFarmEnabled = false,
    FarmDistance = 50,                     -- ចម្ងាយស្វែងរកវត្ថុ Sheckles
    FarmInterval = 0.5,                    -- ចន្លោះពេល Farm ម្ដងៗ
    RemoteNameOverride = "",               -- ទុកទទេ ដើម្បីស្វ័យប្រវត្តិ
}

--============== អថេរ ==============
local totalShecklesAdded = 0
local remoteEvent = nil
local autoFarmConnection = nil

--============== មុខងារស្វែងរក Remote សម្រាប់ Sheckles ==============
local function findShecklesRemote()
    local keywords = {"sheckel", "sheckles", "money", "cash", "coin", "currency", "reward"}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    return obj
                end
            end
        end
    end
    return nil
end

--============== រកវត្ថុ Sheckles នៅផែនទី (សម្រាប់ Auto-Farm) ==============
local function findShecklesObjects()
    local objects = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("sheckel") then
            table.insert(objects, obj)
        elseif obj:IsA("Model") and obj.Name:lower():find("sheckel") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then table.insert(objects, part) end
        end
    end
    return objects
end

--============== មុខងារផ្លាស់ទី ==============
local function tpTo(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos)
    end
end

--============== GUI (High-Level) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("ShecklesHack") then
        CoreGui:FindFirstChild("ShecklesHack"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "ShecklesHack"
    gui.IgnoreGuiInset = true

    -- ប៊ូតុងតូចបិទ/បើក GUI
    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Draggable = true
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    -- ផ្ទាំងមេ
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 420, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    -- រូបភាពផ្ទៃខាងក្រោយ
    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.3
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    -- ចំណងជើង
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "💰 SHECKLES HACK VIP"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)

    -- ប៊ូតុងបិទ
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    -- ប្រអប់ស្ថានភាព
    local statusLabel = Instance.new("TextLabel", mainFrame)
    statusLabel.Size = UDim2.new(1, -40, 0, 25)
    statusLabel.Position = UDim2.new(0, 20, 0, 55)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "ស្ថានភាព៖ កំពុងចាប់ផ្ដើម..."
    statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12

    -- ប្រអប់បញ្ចូលចំនួន
    local amountLabel = Instance.new("TextLabel", mainFrame)
    amountLabel.Size = UDim2.new(0, 120, 0, 20)
    amountLabel.Position = UDim2.new(0, 20, 0, 90)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Text = "ចំនួន Sheckles:"
    amountLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    amountLabel.Font = Enum.Font.Gotham
    amountLabel.TextSize = 12

    local amountInput = Instance.new("TextBox", mainFrame)
    amountInput.Size = UDim2.new(0, 150, 0, 30)
    amountInput.Position = UDim2.new(0, 150, 0, 85)
    amountInput.BackgroundColor3 = Color3.fromRGB(50,50,55)
    amountInput.TextColor3 = Color3.new(1,1,1)
    amountInput.Font = Enum.Font.Gotham
    amountInput.TextSize = 14
    amountInput.PlaceholderText = "1000"
    amountInput.Text = "1000"
    Instance.new("UICorner", amountInput).CornerRadius = UDim.new(0, 6)

    -- ប៊ូតុងបន្ថែម Sheckles
    local addBtn = Instance.new("TextButton", mainFrame)
    addBtn.Size = UDim2.new(1, -40, 0, 40)
    addBtn.Position = UDim2.new(0, 20, 0, 130)
    addBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    addBtn.Text = "💸 បន្ថែម Sheckles ភ្លាមៗ"
    addBtn.TextColor3 = Color3.new(0,0,0)
    addBtn.Font = Enum.Font.GothamBold
    addBtn.TextSize = 14
    Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 10)

    -- ប៊ូតុង Auto-Farm
    local autoBtn = Instance.new("TextButton", mainFrame)
    autoBtn.Size = UDim2.new(1, -40, 0, 40)
    autoBtn.Position = UDim2.new(0, 20, 0, 180)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Farm Sheckles"
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 14
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 10)

    -- ប៊ូតុងកំណត់ផ្ទះ
    local homeBtn = Instance.new("TextButton", mainFrame)
    homeBtn.Size = UDim2.new(1, -40, 0, 35)
    homeBtn.Position = UDim2.new(0, 20, 0, 230)
    homeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    homeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះ (ឈរនៅផ្ទះសិន)"
    homeBtn.TextColor3 = Color3.new(1,1,1)
    homeBtn.Font = Enum.Font.GothamBold
    homeBtn.TextSize = 12
    Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0, 8)

    -- ប្រអប់កែឈ្មោះ Remote
    local remoteLabel = Instance.new("TextLabel", mainFrame)
    remoteLabel.Size = UDim2.new(0, 120, 0, 20)
    remoteLabel.Position = UDim2.new(0, 20, 0, 275)
    remoteLabel.BackgroundTransparency = 1
    remoteLabel.Text = "ឈ្មោះ Remote:"
    remoteLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    remoteLabel.Font = Enum.Font.Gotham
    remoteLabel.TextSize = 11

    local remoteInput = Instance.new("TextBox", mainFrame)
    remoteInput.Size = UDim2.new(0, 150, 0, 25)
    remoteInput.Position = UDim2.new(0, 150, 0, 273)
    remoteInput.BackgroundColor3 = Color3.fromRGB(50,50,55)
    remoteInput.TextColor3 = Color3.new(1,1,1)
    remoteInput.Font = Enum.Font.Gotham
    remoteInput.TextSize = 12
    remoteInput.PlaceholderText = "ShecklesGive"
    remoteInput.Text = Settings.RemoteNameOverride or (remoteEvent and remoteEvent.Name or "")
    Instance.new("UICorner", remoteInput).CornerRadius = UDim.new(0, 5)

    -- ប្រអប់បង្ហាញសរុប
    local totalLabel = Instance.new("TextLabel", mainFrame)
    totalLabel.Size = UDim2.new(1, -40, 0, 20)
    totalLabel.Position = UDim2.new(0, 20, 0, 310)
    totalLabel.BackgroundTransparency = 1
    totalLabel.Text = "សរុបបានបន្ថែម: 0 Sheckles"
    totalLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    totalLabel.Font = Enum.Font.GothamBold
    totalLabel.TextSize = 12

    -- ចលនាពណ៌ RGB
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.03) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            mainStroke.Color = Color3.fromHSV(hue, 1, 1)
            toggleStroke.Color = Color3.fromHSV((hue+0.3)%1, 1, 1)
            task.wait(0.04)
        end
    end)

    --============== មុខងារ ==============
    local function updateRemote()
        local customName = remoteInput.Text
        if customName ~= "" then
            remoteEvent = ReplicatedStorage:FindFirstChild(customName)
            if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                statusLabel.Text = "✅ បានភ្ជាប់ទៅ Remote: " .. remoteEvent.Name
                return true
            else
                statusLabel.Text = "❌ រកមិនឃើញ Remote ឈ្មោះ " .. customName
            end
        else
            remoteEvent = findShecklesRemote()
            if remoteEvent then
                remoteInput.Text = remoteEvent.Name
                statusLabel.Text = "✅ បានរកឃើញ Remote ស្វ័យប្រវត្តិ: " .. remoteEvent.Name
                return true
            else
                statusLabel.Text = "❌ រកមិនឃើញ Remote សូមបញ្ចូលឈ្មោះដោយដៃ"
            end
        end
        return false
    end

    -- ព្រឹត្តិការណ៍
    addBtn.MouseButton1Click:Connect(function()
        if not updateRemote() then return end
        local amount = tonumber(amountInput.Text)
        if not amount or amount <= 0 then
            statusLabel.Text = "❌ សូមបញ្ចូលចំនួនត្រឹមត្រូវ"
            return
        end

        -- ព្យាយាមបាញ់ Remote
        local success = false
        -- វិធីទី ១៖ បាញ់ជាមួយចំនួន
        pcall(function()
            remoteEvent:FireServer(amount)
            success = true
        end)
        if not success then
            -- វិធីទី ២៖ បាញ់ជាមួយ player + amount
            pcall(function()
                remoteEvent:FireServer(LocalPlayer, amount)
                success = true
            end)
        end
        if not success then
            -- វិធីទី ៣៖ បាញ់ជាមួយ string + amount
            pcall(function()
                remoteEvent:FireServer("Sheckles", amount)
                success = true
            end)
        end

        if success then
            totalShecklesAdded = totalShecklesAdded + amount
            totalLabel.Text = "សរុបបានបន្ថែម: " .. totalShecklesAdded .. " Sheckles"
            statusLabel.Text = "✅ បានបន្ថែម " .. amount .. " Sheckles"
        else
            statusLabel.Text = "❌ បរាជ័យ សូមពិនិត្យ Remote ឬប្រើ RemoteSpy"
        end
    end)

    autoBtn.MouseButton1Click:Connect(function()
        Settings.AutoFarmEnabled = not Settings.AutoFarmEnabled
        if Settings.AutoFarmEnabled then
            autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            autoBtn.Text = "⏹ បញ្ឈប់ Auto-Farm"
            statusLabel.Text = "🔄 កំពុង Auto-Farm..."
            -- ចាប់ផ្ដើម Auto-Farm
            autoFarmConnection = RunService.Stepped:Connect(function()
                if not Settings.AutoFarmEnabled then return end
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local objects = findShecklesObjects()
                for _, obj in ipairs(objects) do
                    if (obj.Position - root.Position).Magnitude <= Settings.FarmDistance then
                        tpTo(obj.Position + Vector3.new(0, 2, 0))
                        -- ប្រសិនបើវត្ថុបាត់ (អ្នកបានប្រមូល) បញ្ឈប់
                        task.wait(0.1)
                    end
                end
            end)
        else
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Farm Sheckles"
            statusLabel.Text = "⏹ បានបញ្ឈប់ Auto-Farm"
            tpTo(Settings.HomePosition) -- ត្រឡប់មកផ្ទះ
        end
    end)

    homeBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Settings.HomePosition = root.Position
            statusLabel.Text = "✅ ផ្ទះថ្មីបានកំណត់"
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        if autoFarmConnection then autoFarmConnection:Disconnect() end
        gui:Destroy()
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- អូស GUI
    local function makeDraggable(obj)
        local dragging, startPos, objPos
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; startPos = input.Position; objPos = obj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startPos
                obj.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
            end
        end)
        obj.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    makeDraggable(mainFrame)

    -- ចាប់ផ្ដើមដំបូង
    updateRemote()
end

--============== ទាញយករូបភាព និងចាប់ផ្ដើម ==============
local function loadImageAndStart()
    local ok, response = pcall(function() return request({Url=IMAGE_URL, Method="GET"}) end)
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        createGUI(getcustomasset(FILE_NAME))
    else
        createGUI("") -- បើគ្មានរូប នៅតែបង្កើត GUI បាន
    end
end

loadImageAndStart()