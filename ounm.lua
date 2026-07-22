--========================================================
-- GROW A GARDEN 2: CROP STEALER + RETURN HOME (IMAGE GUI)
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"  -- អាចប្តូររូបបាន
local FILE_NAME = "bg_garden.jpg"

--============== ទីតាំងផ្ទះ ==============
local HOME_POSITION = Vector3.new(0, 10, 0)  -- កែតាមផ្ទះអ្នក

--============== ស្វែងរក Remote ==============
local function findRemote(keyword)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find(keyword) then
            return v
        end
    end
    return nil
end

local harvestRemote = findRemote("harvest") or findRemote("collect") or findRemote("pick")
if not harvestRemote then
    warn("មិនឃើញ Remote សម្រាប់ប្រមូលផល។ ពិនិត្យឈ្មោះ Remote ដោយដៃ។")
end

--============== ជំនួយ ==============
local function makeDraggable(guiObject)
    local dragging, startPos, objPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startPos = input.Position; objPos = guiObject.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            guiObject.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ហោះទៅទីតាំង (រលូន)
local function flyTo(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local startPos = root.Position
    local distance = (startPos - targetPos).Magnitude
    if distance < 3 then return end

    local steps = math.ceil(distance / 10) + 2
    for t = 0, 1, 1 / steps do
        root.CFrame = CFrame.new(startPos:Lerp(targetPos, t))
        task.wait(0.02)
    end
    root.CFrame = CFrame.new(targetPos)
end

-- រកដំណាំអ្នកដទៃ
local function getOthersPlants()
    local plants = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("plant") then
            local owner = obj:GetAttribute("Owner")
            if not owner then
                local ownVal = obj:FindFirstChild("Owner")
                if ownVal and ownVal:IsA("StringValue") then owner = ownVal.Value end
            end
            if owner and owner ~= LocalPlayer.Name then
                table.insert(plants, obj)
            end
        end
    end
    return plants
end

-- លួចដំណាំមួយ
local function stealPlant(plantModel)
    if not harvestRemote then return false end
    local primaryPart = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return false end

    flyTo(primaryPart.Position + Vector3.new(0, 5, 0))
    harvestRemote:FireServer(plantModel)  -- អាចត្រូវកែ argument
    task.wait(0.4)
    return true
end

--============== GUI (មានរូបភាព) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("GardenStealer") then
        CoreGui:FindFirstChild("GardenStealer"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "GardenStealer"
    gui.IgnoreGuiInset = true

    -- ប៊ូតុងតូចបិទ/បើក GUI (មានរូបភាព)
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
    mainFrame.Size = UDim2.new(0, 420, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    -- ផ្ទៃខាងក្រោយជារូបភាព
    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.3
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "🌜 GARDEN CROP STEALER"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextColor3 = Color3.new(1,1,1)

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    local stealBtn = Instance.new("TextButton", mainFrame)
    stealBtn.Size = UDim2.new(1, -40, 0, 45)
    stealBtn.Position = UDim2.new(0, 20, 0, 70)
    stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    stealBtn.Text = "🚜 លួចដំណាំទាំងអស់ហើយមកផ្ទះ"
    stealBtn.TextColor3 = Color3.new(1,1,1)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 13
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)

    local setHomeBtn = Instance.new("TextButton", mainFrame)
    setHomeBtn.Size = UDim2.new(1, -40, 0, 35)
    setHomeBtn.Position = UDim2.new(0, 20, 0, 130)
    setHomeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    setHomeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះ (ឈរនៅផ្ទះសិន)"
    setHomeBtn.TextColor3 = Color3.new(1,1,1)
    setHomeBtn.Font = Enum.Font.GothamBold
    setHomeBtn.TextSize = 12
    Instance.new("UICorner", setHomeBtn).CornerRadius = UDim.new(0, 8)

    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 60)
    hintLabel.Position = UDim2.new(0, 20, 0, 180)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ចុចប៊ូតុងដើម្បីចាប់ផ្ដើមលួច"
    hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12
    hintLabel.TextWrapped = true

    -- ចលនាពណ៌ដូចដើម
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
    stealBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            hintLabel.Text = "គ្មានតួអង្គ"
            return
        end
        hintLabel.Text = "កំពុងស្វែងរកដំណាំគេ..."
        task.wait(0.1)
        local plants = getOthersPlants()
        if #plants == 0 then
            hintLabel.Text = "គ្មានដំណាំអ្នកដទៃ"
            return
        end

        for i, plant in ipairs(plants) do
            hintLabel.Text = "លួច " .. plant.Name .. " (" .. i .. "/" .. #plants .. ")"
            local success = stealPlant(plant)
            if success then
                -- ត្រឡប់មកផ្ទះ
                flyTo(HOME_POSITION)
                hintLabel.Text = "✅ លួចរួច មកផ្ទះ"
            else
                hintLabel.Text = "❌ បរាជ័យលើ " .. plant.Name
            end
            task.wait(0.3)
        end
        hintLabel.Text = "🏁 បញ្ចប់! នៅផ្ទះ"
    end)

    setHomeBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            HOME_POSITION = root.Position
            hintLabel.Text = "ផ្ទះថ្មីកំណត់ហើយ: " .. tostring(HOME_POSITION)
        else
            hintLabel.Text = "រក HumanoidRootPart មិនឃើញ"
        end
    end)

    closeBtn.MouseButton1Down:Connect(function() gui:Destroy() end)
    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    makeDraggable(mainFrame)
end

--============== ទាញយករូបភាព ==============
local function loadImageAndStart()
    local ok, response = pcall(function() return request({Url=IMAGE_URL, Method="GET"}) end)
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        createGUI(getcustomasset(FILE_NAME))
    else
        createGUI("")
    end
end

loadImageAndStart()