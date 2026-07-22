--========================================================
-- GROW A GARDEN 2: FAST TP STEALER (-100m) - MOBILE SAFE
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--============== ទីតាំងផ្ទះ ==============
local HOME_POSITION = Vector3.new(0, 10, 0)

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
        root.Velocity = Vector3.new(0, 0, 0) 
    end
end

--============== រកដំណាំអ្នកដទៃ ==============
local function getEnemyPlants()
    local plants = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
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

            if owner and owner ~= LocalPlayer.Name and owner ~= tostring(LocalPlayer.UserId) then
                local stealPrompt = nil
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        local action = child.ActionText:lower()
                        local pname = child.Name:lower()
                        if action:find("steal") or pname:find("steal") then
                            stealPrompt = child
                            break
                        end
                    end
                end
                
                local prim = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if stealPrompt and prim then
                    table.insert(plants, {model = obj, part = prim, prompt = stealPrompt})
                end
            end
        end
    end
    return plants
end

--============== លួចដំណាំ (ដកចម្ងាយ ១០០ម៉ែត្រចុះក្រោម) ==============
local function stealCrop(plantData)
    local primaryPart = plantData.part
    local stealPrompt = plantData.prompt

    -- ដក ១០០ ម៉ែត្រតាមអ័ក្ស Y ហោះចុះក្រោមដី
    tpTo(primaryPart.Position - Vector3.new(0, 100, 0))
    task.wait(0.2) 

    if stealPrompt then
        stealPrompt.RequiresLineOfSight = false
        stealPrompt.MaxActivationDistance = math.huge

        if not stealPrompt.Enabled then
            stealPrompt.Enabled = true
            task.wait(0.1)
        end

        if fireproximityprompt then
            fireproximityprompt(stealPrompt, 1)
            fireproximityprompt(stealPrompt, 0)
        else
            stealPrompt.HoldDuration = 0
            stealPrompt:InputHoldBegin()
            task.wait(0.1)
            stealPrompt:InputHoldEnd()
        end
    end
    
    return true
end

--============== បង្កើត GUI ==============
local function createGUI()
    if CoreGui:FindFirstChild("GardenStealer") then
        CoreGui:FindFirstChild("GardenStealer"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "GardenStealer"
    gui.IgnoreGuiInset = true

    -- ប៊ូតុង Toggle ពណ៌ខៀវ
    local toggleBtn = Instance.new("TextButton", gui)
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    toggleBtn.Text = "OPEN"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Draggable = true
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 380, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "🌜 GARDEN STEALER (-100m)"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 15
    title.TextColor3 = Color3.new(1,1,1)

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

    local stealBtn = Instance.new("TextButton", mainFrame)
    stealBtn.Size = UDim2.new(1, -40, 0, 45)
    stealBtn.Position = UDim2.new(0, 20, 0, 60)
    stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    stealBtn.Text = "⚡ លួចផ្លែឈើទាំងអស់ (ពីក្រោមដី)"
    stealBtn.TextColor3 = Color3.new(1,1,1)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 13
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)

    local setHomeBtn = Instance.new("TextButton", mainFrame)
    setHomeBtn.Size = UDim2.new(1, -40, 0, 35)
    setHomeBtn.Position = UDim2.new(0, 20, 0, 120)
    setHomeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    setHomeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះបច្ចុប្បន្ន"
    setHomeBtn.TextColor3 = Color3.new(1,1,1)
    setHomeBtn.Font = Enum.Font.GothamBold
    setHomeBtn.TextSize = 12
    Instance.new("UICorner", setHomeBtn).CornerRadius = UDim.new(0, 8)

    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 60)
    hintLabel.Position = UDim2.new(0, 20, 0, 170)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ស្ថានភាព: រង់ចាំការបញ្ជា..."
    hintLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12
    hintLabel.TextWrapped = true

    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.03) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    --============== ព្រឹត្តិការណ៍ ==============
    stealBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            hintLabel.Text = "❌ គ្មានតួអង្គ សូមចាប់កំណើតឡើងវិញ"
            return
        end

        hintLabel.Text = "🔍 កំពុងស្វែងរកផ្លែឈើ..."
        task.wait(0.2)
        local plants = getEnemyPlants()

        if #plants == 0 then
            hintLabel.Text = "❌ រកមិនឃើញផ្លែឈើដែលអាចលួចទេ"
            return
        end

        for i, plantData in ipairs(plants) do
            if not plantData.model.Parent or not plantData.prompt.Parent then continue end
            hintLabel.Text = "⚡ កំពុងលួចពីក្រោមដី... (" .. i .. "/" .. #plants .. ")"
            stealCrop(plantData)
            task.wait(0.25)
        end
        
        hintLabel.Text = "✅ លួចបានសម្រេច! កំពុងត្រលប់មកផ្ទះ..."
        task.wait(0.5)
        tpTo(HOME_POSITION)
        hintLabel.Text = "🏁 បញ្ចប់ការលួច! ត្រឡប់មកផ្ទះដោយសុវត្ថិភាព។"
    end)

    setHomeBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            HOME_POSITION = root.Position
            hintLabel.Text = "✅ បានកំណត់ទីតាំងផ្ទះថ្មីរួចរាល់!"
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

createGUI()
