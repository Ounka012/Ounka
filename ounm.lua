--========================================================
-- GROW A GARDEN 2: INSTANT TP STEALER + GUI (WITH IMAGE)
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg" -- រូបភាព (អាចប្ដូរបាន)
local FILE_NAME = "bg_garden_stealer.jpg"

--============== ទីតាំងផ្ទះ ==============
local HOME_POSITION = Vector3.new(0, 10, 0) -- កែតាមកូអរដោនេផ្ទះអ្នក

--============== មុខងារអូស GUI ==============
local function makeDraggable(guiObject)
    local dragging, startPos, objPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            objPos = guiObject.Position
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

--============== TP ភ្លាមៗ ==============
local function tpTo(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(targetPos)
    end
end

--============== រកដំណាំអ្នកដទៃ (មានម្ចាស់ និងមាន Prompt "Steal") ==============
local function getEnemyPlants()
    local plants = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            -- ឆែកម្ចាស់តាម Attribute / ObjectValue
            local owner = nil
            local attrOwner = obj:GetAttribute("Owner")
            if attrOwner then
                owner = tostring(attrOwner)
            else
                local ownVal = obj:FindFirstChild("Owner")
                if ownVal and ownVal:IsA("StringValue") then
                    owner = ownVal.Value
                elseif ownVal and ownVal:IsA("ObjectValue") and ownVal.Value then
                    owner = ownVal.Value.Name
                end
            end

            -- បើមានម្ចាស់ផ្សេង
            if owner and owner ~= LocalPlayer.Name and owner ~= tostring(LocalPlayer.UserId) then
                -- រក ProximityPrompt ដែលមានពាក្យ "steal"
                local hasSteal = false
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        local action = child.ActionText:lower()
                        local pname = child.Name:lower()
                        if action:find("steal") or pname:find("steal") then
                            hasSteal = true
                            break
                        end
                    end
                end
                if hasSteal then
                    local prim = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if prim then
                        table.insert(plants, {model = obj, part = prim, owner = owner})
                    end
                end
            end
        end
    end
    return plants
end

--============== លួចដំណាំ (ចុច Prompt "Steal") ==============
local function stealCrop(plantData)
    local model = plantData.model
    local primaryPart = plantData.part

    -- រក Prompt Steal ក្នុង Model
    local stealPrompt = nil
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local action = child.ActionText:lower()
            local pname = child.Name:lower()
            if action:find("steal") or pname:find("steal") then
                stealPrompt = child
                break
            end
        end
    end
    if not stealPrompt then return false end

    -- TP ទៅពីលើដំណាំ (5 studs) ដើម្បីឲ្យ Prompt ធ្វើការ
    tpTo(primaryPart.Position + Vector3.new(0, 5, 0))
    task.wait(0.2)

    -- បើ Prompt មិនទាន់ដំណើរការ សាកបើក
    if not stealPrompt.Enabled then
        stealPrompt.Enabled = true
        task.wait(0.2)
    end

    -- ចាប់សង្កត់រយៈពេល 1.3 វិនាទី (អាចកែ)
    stealPrompt:InputHoldBegin()
    task.wait(1.3)
    stealPrompt:InputHoldEnd()
    return true
end

--============== GUI (មានរូប និងចលនាពណ៌) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("GardenStealer") then
        CoreGui:FindFirstChild("GardenStealer"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "GardenStealer"
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

    -- ប៊ូតុងលួច
    local stealBtn = Instance.new("TextButton", mainFrame)
    stealBtn.Size = UDim2.new(1, -40, 0, 45)
    stealBtn.Position = UDim2.new(0, 20, 0, 70)
    stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    stealBtn.Text = "⚡ លួចផ្លែឈើទាំងអស់ហើយមកផ្ទះ"
    stealBtn.TextColor3 = Color3.new(1,1,1)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 13
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)

    -- ប៊ូតុងកំណត់ផ្ទះ
    local setHomeBtn = Instance.new("TextButton", mainFrame)
    setHomeBtn.Size = UDim2.new(1, -40, 0, 35)
    setHomeBtn.Position = UDim2.new(0, 20, 0, 130)
    setHomeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    setHomeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះ (ឈរនៅផ្ទះសិន)"
    setHomeBtn.TextColor3 = Color3.new(1,1,1)
    setHomeBtn.Font = Enum.Font.GothamBold
    setHomeBtn.TextSize = 12
    Instance.new("UICorner", setHomeBtn).CornerRadius = UDim.new(0, 8)

    -- ប្រអប់បង្ហាញស្ថានភាព
    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 60)
    hintLabel.Position = UDim2.new(0, 20, 0, 180)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ចុចប៊ូតុងដើម្បីចាប់ផ្ដើមលួច"
    hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12
    hintLabel.TextWrapped = true

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

    --============== ព្រឹត្តិការណ៍ ==============
    stealBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            hintLabel.Text = "គ្មានតួអង្គ សូមចាប់កំណើតឡើងវិញ"
            return
        end

        hintLabel.Text = "🔍 កំពុងស្វែងរកផ្លែឈើអ្នកដទៃ..."
        task.wait(0.2)
        local plants = getEnemyPlants()

        if #plants == 0 then
            hintLabel.Text = "❌ រកមិនឃើញផ្លែឈើដែលអាចលួចទេ"
            return
        end

        for i, plantData in ipairs(plants) do
            hintLabel.Text = "លួច " .. plantData.model.Name .. " (" .. i .. "/" .. #plants .. ")"
            local success = stealCrop(plantData)
            if success then
                tpTo(HOME_POSITION)
                hintLabel.Text = "✅ លួចរួច មកផ្ទះ"
            else
                hintLabel.Text = "⚠️ បរាជ័យលើ " .. plantData.model.Name .. " (រកមិនឃើញ Steal Prompt)"
            end
            task.wait(0.3)
        end
        hintLabel.Text = "🏁 បញ្ចប់! ត្រឡប់មកផ្ទះហើយ"
    end)

    setHomeBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            HOME_POSITION = root.Position
            hintLabel.Text = "✅ ផ្ទះថ្មីកំណត់: " .. math.floor(HOME_POSITION.X) .. ", " .. math.floor(HOME_POSITION.Y) .. ", " .. math.floor(HOME_POSITION.Z)
        else
            hintLabel.Text = "រក HumanoidRootPart មិនឃើញ"
        end
    end)

    closeBtn.MouseButton1Down:Connect(function()
        gui:Destroy()
    end)

    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    makeDraggable(mainFrame)
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