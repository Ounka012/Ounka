--========================================================
-- GROW A GARDEN 2: MASS STEALER + AUTO LOOP
-- ជួសជុល: លួចបានច្រើនផ្លែព្រមគ្នា ពីក្រោមដីតែម្ដង
--========================================================

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg" 
local FILE_NAME = "bg_garden_stealer.jpg"

--============== ការកំណត់ ==============
local HOME_POSITION = Vector3.new(0, 10, 0)
local UNDERGROUND_OFFSET = Vector3.new(0, 120, 0) -- ចុះក្រោម ១២០ម៉ែត្ល
local STEAL_COOLDOWN = 0.15 -- រង់ចាំរវាងផ្លែ (វិនាទី)
local AUTO_STEAL_INTERVAL = 3 -- វិនាទីរវាងរាល់ដង Auto-Steal

local State = {
    IsAutoStealing = false,
    TotalStolen = 0,
    LastStolenNames = {},
}

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
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

--============== រកផ្លែឈើអ្នកដទៃ (រហ័សជាង) ==============
local function getEnemyPlants()
    local plants = {}
    local myName = LocalPlayer.Name
    local myUserId = tostring(LocalPlayer.UserId)
    
    -- រកតែក្នុង Plot ឬ Zone ដែលមានដំណាំ
    local searchTargets = {Workspace}
    
    -- បើមាន Folder "Plots" ឬ "Gardens" រកតែទីនោះ
    for _, folderName in ipairs({"Plots", "Gardens", "Farms", "Stands", "PlayerPlots"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            table.insert(searchTargets, 1, folder) -- ដាក់ពីមុខ
        end
    end
    
    for _, target in ipairs(searchTargets) do
        for _, obj in pairs(target:GetDescendants()) do
            if obj:IsA("Model") and obj.Parent then
                -- ពិនិត្យម្ចាស់
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

                -- បើជារបស់អ្នកដទៃ
                if owner and owner ~= myName and owner ~= myUserId then
                    local stealPrompt = nil
                    local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    
                    -- រក ProximityPrompt ដែលមាន "steal"
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("ProximityPrompt") then
                            local action = child.ActionText:lower()
                            local objName = child.Name:lower()
                            local parentName = child.Parent and child.Parent.Name:lower() or ""
                            
                            if action:find("steal") or objName:find("steal") or parentName:find("steal") then
                                stealPrompt = child
                                break
                            end
                        end
                    end
                    
                    if stealPrompt and primaryPart then
                        table.insert(plants, {
                            model = obj,
                            part = primaryPart,
                            prompt = stealPrompt,
                            owner = owner,
                            name = obj.Name
                        })
                    end
                end
            end
        end
    end
    
    return plants
end

--============== លួចផ្លែឈើ (ពីចម្ងាយ) ==============
local function stealCrop(plantData, hintLabel)
    local stealPrompt = plantData.prompt
    
    if not stealPrompt or not stealPrompt.Parent then
        return false
    end
    
    -- Bypass ការកំណត់ចម្ងាយ
    pcall(function()
        stealPrompt.RequiresLineOfSight = false
        stealPrompt.MaxActivationDistance = 9999
        stealPrompt.HoldDuration = 0
        stealPrompt.Enabled = true
    end)
    
    task.wait(0.05)
    
    -- ប្រើវិធីទាំងអស់ដើម្បីលួច
    local success = false
    
    -- វិធី 1: fireproximityprompt
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(stealPrompt, 1)
            task.wait(0.05)
            fireproximityprompt(stealPrompt, 0)
            success = true
        end)
    end
    
    -- វិធី 2: InputHold
    if not success then
        pcall(function()
            stealPrompt:InputHoldBegin()
            task.wait(0.1)
            stealPrompt:InputHoldEnd()
            success = true
        end)
    end
    
    -- វិធី 3: Trigger
    if not success then
        pcall(function()
            stealPrompt:Trigger()
            success = true
        end)
    end
    
    if success then
        State.TotalStolen = State.TotalStolen + 1
        table.insert(State.LastStolenNames, plantData.name)
        if #State.LastStolenNames > 5 then
            table.remove(State.LastStolenNames, 1)
        end
        if hintLabel then
            hintLabel.Text = "⚡ លួច: " .. plantData.name .. " (" .. State.TotalStolen .. " ផ្លែ)"
        end
    end
    
    return success
end

--============== MASS STEAL - លួចច្រើនផ្លែព្រមគ្នា ==============
local function massSteal(hintLabel)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        if hintLabel then hintLabel.Text = "❌ គ្មានតួអង្គ" end
        return 0
    end

    -- 1. រកផ្លែឈើ
    if hintLabel then hintLabel.Text = "🔍 កំពុងស្វែងរក..." end
    local plants = getEnemyPlants()
    
    if #plants == 0 then
        if hintLabel then hintLabel.Text = "❌ រកមិនឃើញផ្លែឈើដែលអាចលួច" end
        return 0
    end
    
    -- 2. TP ចុះក្រោមដីតែម្ដង (កណ្ដាលផែនទី)
    local centerPos = root.Position - UNDERGROUND_OFFSET
    tpTo(centerPos)
    task.wait(0.3)
    
    -- 3. លួចទាំងអស់ពីទីតាំងនេះ
    local stolenCount = 0
    for i, plantData in ipairs(plants) do
        if not plantData.model.Parent then continue end
        if not plantData.prompt.Parent then continue end
        
        if hintLabel then
            hintLabel.Text = "⚡ កំពុងលួច... (" .. i .. "/" .. #plants .. ") | សរុប: " .. State.TotalStolen
        end
        
        if stealCrop(plantData, hintLabel) then
            stolenCount = stolenCount + 1
        end
        
        task.wait(STEAL_COOLDOWN)
    end
    
    -- 4. ត្រលប់មកផ្ទះ
    task.wait(0.2)
    tpTo(HOME_POSITION)
    
    if hintLabel then
        hintLabel.Text = "✅ លួចបាន " .. stolenCount .. "/" .. #plants .. " ផ្លែ! សរុប: " .. State.TotalStolen
    end
    
    return stolenCount
end

--============== AUTO STEAL LOOP ==============
local function startAutoSteal(hintLabel, autoBtn)
    if State.IsAutoStealing then return end
    State.IsAutoStealing = true
    State.TotalStolen = 0
    
    if autoBtn then
        autoBtn.Text = "⏹ បញ្ឈប់ Auto-Steal"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
    
    task.spawn(function()
        while State.IsAutoStealing do
            if not LocalPlayer.Character then
                task.wait(1)
                continue
            end
            
            massSteal(hintLabel)
            task.wait(AUTO_STEAL_INTERVAL)
        end
        
        if autoBtn then
            autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Steal"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        end
    end)
end

local function stopAutoSteal()
    State.IsAutoStealing = false
end

--============== GUI ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("GardenMassStealer") then
        CoreGui:FindFirstChild("GardenMassStealer"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "GardenMassStealer"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Toggle Button
    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)

    -- Main Frame
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 440, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.3
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    -- Title
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "🌜 MASS STEALER (Fixed)"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextColor3 = Color3.new(1,1,1)

    -- Close
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    -- Steal Once Button
    local stealBtn = Instance.new("TextButton", mainFrame)
    stealBtn.Size = UDim2.new(1, -40, 0, 40)
    stealBtn.Position = UDim2.new(0, 20, 0, 60)
    stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    stealBtn.Text = "⚡ លួចផ្លែឈើទាំងអស់ (ម្ដង)"
    stealBtn.TextColor3 = Color3.new(1,1,1)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 13
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)

    -- Auto Steal Button
    local autoBtn = Instance.new("TextButton", mainFrame)
    autoBtn.Size = UDim2.new(1, -40, 0, 40)
    autoBtn.Position = UDim2.new(0, 20, 0, 110)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Steal"
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 13
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 10)

    -- Set Home
    local setHomeBtn = Instance.new("TextButton", mainFrame)
    setHomeBtn.Size = UDim2.new(1, -40, 0, 35)
    setHomeBtn.Position = UDim2.new(0, 20, 0, 160)
    setHomeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    setHomeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះ"
    setHomeBtn.TextColor3 = Color3.new(1,1,1)
    setHomeBtn.Font = Enum.Font.GothamBold
    setHomeBtn.TextSize = 12
    Instance.new("UICorner", setHomeBtn).CornerRadius = UDim.new(0, 8)

    -- Status Label
    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 80)
    hintLabel.Position = UDim2.new(0, 20, 0, 205)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ស្ថានភាព: រង់ចាំការបញ្ជា...\nចុច 'លួចផ្លែឈើទាំងអស់' ដើម្បីលួចម្ដងច្រើនផ្លែ"
    hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12
    hintLabel.TextWrapped = true

    -- Rainbow Title
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.03) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    -- Events
    stealBtn.MouseButton1Down:Connect(function()
        task.spawn(function()
            massSteal(hintLabel)
        end)
    end)

    autoBtn.MouseButton1Down:Connect(function()
        if State.IsAutoStealing then
            stopAutoSteal()
            autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Steal"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            hintLabel.Text = "⏹ បានបញ្ឈប់ Auto-Steal"
        else
            startAutoSteal(hintLabel, autoBtn)
        end
    end)

    setHomeBtn.MouseButton1Down:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            HOME_POSITION = root.Position
            hintLabel.Text = "✅ បានកំណត់ទីតាំងផ្ទះថ្មី!"
        end
    end)

    closeBtn.MouseButton1Down:Connect(function()
        stopAutoSteal()
        gui:Destroy()
    end)

    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    makeDraggable(mainFrame)
end

--============== ចាប់ផ្ដើម ==============
local function loadImageAndStart()
    local ok, response = pcall(function() 
        return request({Url=IMAGE_URL, Method="GET"}) 
    end)
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        createGUI(getcustomasset(FILE_NAME))
    else
        createGUI("")
    end
end

loadImageAndStart()

print("✅ Mass Stealer បានផ្ទុក!")
print("🆕 លក្ខណៈថ្មី:")
print("   • TP ចុះក្រោមដីតែម្ដង ហើយលួចទាំងអស់")
print("   • Auto-Steal រក + លួចដោយស្វ័យប្រវត្តិ")
print("   • លួចបានច្រើនផ្លែព្រមគ្នា")
