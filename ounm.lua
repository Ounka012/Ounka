--========================================================
-- GROW A GARDEN: FULL WORKING MASS STEALER
-- ពេញលេញ + រូបភាព + ដំណើរការបានពិត
--========================================================

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg" 
local FILE_NAME = "bg_garden_stealer.jpg"

--============== ការកំណត់ ==============
local HOME_POSITION = Vector3.new(0, 10, 0)
local STEAL_OFFSET = Vector3.new(0, 4, 0)  -- ទៅជិតផ្លែឈើ (មិនមែនចុះក្រោមដី)
local HOLD_DURATION = 0.6                       -- រយៈពេលចុចជាប់
local BETWEEN_STEALS = 0.2                    -- រង់ចាំរវាងផ្លែ
local AUTO_INTERVAL = 3                         -- វិនាទីរវាង Auto-Steal

local State = {
    IsAutoStealing = false,
    TotalStolen = 0,
    LastStolen = {},
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

--============== Tween ទៅជិតផ្លែឈើ ==============
local function tweenTo(targetPos, speed)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local distance = (root.Position - targetPos).Magnitude
    local time = distance / (speed or 250)
    
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos)
    })
    tween:Play()
    tween.Completed:Wait()
    return true
end

--============== រកផ្លែឈើអ្នកដទៃ (រហ័ស) ==============
local function getEnemyPlants()
    local plants = {}
    local myName = LocalPlayer.Name
    local myId = tostring(LocalPlayer.UserId)
    
    -- រកតែក្នុង Plot ឬ Zone ដែលមានដំណាំ (លឿនជាង)
    local searchTargets = {}
    
    for _, folderName in ipairs({"Plots", "Gardens", "Farms", "Stands", "PlayerPlots", "Islands", "Zones"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            table.insert(searchTargets, folder)
        end
    end
    
    -- បើរកមិនឃើញ Folder អាចរកនៅ Workspace
    if #searchTargets == 0 then
        table.insert(searchTargets, Workspace)
    end
    
    for _, target in ipairs(searchTargets) do
        for _, obj in pairs(target:GetDescendants()) do
            if obj:IsA("Model") and obj.Parent then
                -- ពិនិត្យម្ចាស់ (ច្រើនវិធី)
                local owner = nil
                
                -- វិធី 1: Attribute
                local attr = obj:GetAttribute("Owner") or obj:GetAttribute("owner") or obj:GetAttribute("Player") or obj:GetAttribute("player")
                if attr then owner = tostring(attr) end
                
                -- វិធី 2: StringValue / ObjectValue
                if not owner then
                    local ownVal = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner")
                    if ownVal and ownVal:IsA("StringValue") then
                        owner = ownVal.Value
                    elseif ownVal and ownVal:IsA("ObjectValue") and ownVal.Value then
                        owner = ownVal.Value.Name
                    end
                end
                
                -- វិធី 3: Plot Name
                if not owner and obj.Parent then
                    local pName = obj.Parent.Name
                    if pName ~= "Workspace" and pName ~= "Plots" and pName ~= "Gardens" then
                        -- បើឈ្មោះ Plot មិនមែនរបស់យើង
                        if pName ~= myName and pName ~= myId then
                            owner = pName
                        end
                    end
                end
                
                -- បើជារបស់អ្នកដទៃ
                if owner and owner ~= myName and owner ~= myId then
                    -- រក ProximityPrompt ដែលមាន "Steal" ឬ "Harvest"
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("ProximityPrompt") then
                            local action = (child.ActionText or ""):lower()
                            local objText = (child.ObjectText or ""):lower()
                            local pName = child.Name:lower()
                            
                            if action:find("steal") or action:find("harvest") or action:find("collect") or 
                               objText:find("steal") or objText:find("harvest") or
                               pName:find("steal") or pName:find("harvest") or pName:find("collect") then
                                
                                local prim = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if prim then
                                    table.insert(plants, {
                                        model = obj,
                                        part = prim,
                                        prompt = child,
                                        owner = owner,
                                        name = obj.Name
                                    })
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return plants
end

--============== លួចផ្លែឈើ (ពិតៗ - ចុចជាប់) ==============
local function stealCrop(plantData, hintLabel)
    local prompt = plantData.prompt
    local part = plantData.part
    
    if not prompt or not prompt.Parent then return false end
    if not part or not part.Parent then return false end
    
    -- 1. ទៅជិតផ្លែឈើ (ពិតៗ)
    local targetPos = part.Position + STEAL_OFFSET
    tweenTo(targetPos, 300)
    task.wait(0.1)
    
    -- 2. បើក Prompt ឲ្យដំណើរការបាន
    local originalHold = prompt.HoldDuration
    local originalDist = prompt.MaxActivationDistance
    local originalLOS = prompt.RequiresLineOfSight
    local originalEnabled = prompt.Enabled
    
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        prompt.Enabled = true
    end)
    
    task.wait(0.05)
    
    -- 3. ចុចជាប់ (Hold) ត្រឹមត្រូវ
    local holdTime = originalHold > 0 and originalHold or HOLD_DURATION
    
    -- វិធីទី 1: fireproximityprompt
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt, holdTime + 0.2)
        end)
    end
    
    task.wait(0.05)
    
    -- វិធីទី 2: InputHoldBegin/End (ពិតប្រាកដបំផុត)
    pcall(function()
        prompt:InputHoldBegin()
    end)
    
    task.wait(holdTime + 0.1)
    
    pcall(function()
        prompt:InputHoldEnd()
    end)
    
    task.wait(0.05)
    
    -- វិធីទី 3: Trigger
    pcall(function()
        prompt:Trigger()
    end)
    
    -- សងរចនាសម្ព័ន្ធដើម
    task.delay(2, function()
        pcall(function()
            prompt.MaxActivationDistance = originalDist
            prompt.RequiresLineOfSight = originalLOS
        end)
    end)
    
    State.TotalStolen = State.TotalStolen + 1
    table.insert(State.LastStolen, plantData.name)
    if #State.LastStolen > 5 then table.remove(State.LastStolen, 1) end
    
    if hintLabel then
        hintLabel.Text = "⚡ លួច: " .. plantData.name .. " (" .. State.TotalStolen .. " ផ្លែ)"
    end
    
    return true
end

--============== MASS STEAL - លួចច្រើនផ្លែជាប់ៗគ្នា ==============
local function massSteal(hintLabel)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        if hintLabel then hintLabel.Text = "❌ គ្មានតួអង្គ" end
        return 0
    end

    if hintLabel then hintLabel.Text = "🔍 កំពុងស្វែងរកផ្លែឈើអ្នកដទៃ..." end
    task.wait(0.2)
    
    local plants = getEnemyPlants()

    if #plants == 0 then
        if hintLabel then hintLabel.Text = "❌ រកមិនឃើញផ្លែឈើដែលអាចលួច" end
        return 0
    end

    local stolenCount = 0
    for i, plantData in ipairs(plants) do
        if not plantData.model.Parent or not plantData.prompt.Parent then continue end
        
        if hintLabel then
            hintLabel.Text = "⚡ កំពុងលួច... (" .. i .. "/" .. #plants .. ")\nសរុប: " .. State.TotalStolen .. " ផ្លែ"
        end
        
        local ok = pcall(function()
            return stealCrop(plantData, hintLabel)
        end)
        
        if ok then stolenCount = stolenCount + 1 end
        task.wait(BETWEEN_STEALS)
    end
    
    -- ត្រលប់មកផ្ទះ
    task.wait(0.3)
    tweenTo(HOME_POSITION, 200)
    
    if hintLabel then
        hintLabel.Text = "✅ លួចបាន " .. stolenCount .. "/" .. #plants .. " ផ្លែ!\n🏠 ត្រឡប់មកផ្ទះ"
    end
    
    return stolenCount
end

--============== AUTO STEAL LOOP ==============
local function startAutoSteal(hintLabel, autoBtn)
    if State.IsAutoStealing then return end
    State.IsAutoStealing = true
    
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
            task.wait(AUTO_INTERVAL)
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

--============== GUI (ពេញលេញ + រូបភាព) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("GardenMassStealer") then
        CoreGui:FindFirstChild("GardenMassStealer"):Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GardenMassStealer"
    gui.Parent = CoreGui
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Toggle Button (ខាងក្រៅ)
    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Parent = gui
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = gui
    mainFrame.Size = UDim2.new(0, 440, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

    -- Background Image
    local bg = Instance.new("ImageLabel")
    bg.Parent = mainFrame
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.25
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    -- Title
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "🌾 GARDEN MASS STEALER (REAL)"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextColor3 = Color3.new(1,1,1)

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = mainFrame
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    -- Steal Once Button
    local stealBtn = Instance.new("TextButton")
    stealBtn.Parent = mainFrame
    stealBtn.Size = UDim2.new(1, -40, 0, 45)
    stealBtn.Position = UDim2.new(0, 20, 0, 60)
    stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    stealBtn.Text = "⚡ លួចផ្លែឈើទាំងអស់ (MASS)"
    stealBtn.TextColor3 = Color3.new(1,1,1)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 13
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)

    -- Auto Steal Button
    local autoBtn = Instance.new("TextButton")
    autoBtn.Parent = mainFrame
    autoBtn.Size = UDim2.new(1, -40, 0, 40)
    autoBtn.Position = UDim2.new(0, 20, 0, 115)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    autoBtn.Text = "🔄 ចាប់ផ្ដើម Auto-Steal"
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 13
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 10)

    -- Set Home Button
    local setHomeBtn = Instance.new("TextButton")
    setHomeBtn.Parent = mainFrame
    setHomeBtn.Size = UDim2.new(1, -40, 0, 35)
    setHomeBtn.Position = UDim2.new(0, 20, 0, 165)
    setHomeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    setHomeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះបច្ចុប្បន្ន"
    setHomeBtn.TextColor3 = Color3.new(1,1,1)
    setHomeBtn.Font = Enum.Font.GothamBold
    setHomeBtn.TextSize = 12
    Instance.new("UICorner", setHomeBtn).CornerRadius = UDim.new(0, 8)

    -- Status Label
    local hintLabel = Instance.new("TextLabel")
    hintLabel.Parent = mainFrame
    hintLabel.Size = UDim2.new(1, -40, 0, 80)
    hintLabel.Position = UDim2.new(0, 20, 0, 215)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ស្ថានភាព: រង់ចាំការបញ្ជា...\n💡 វិធី: ទៅជិតផ្លែ → ចុចជាប់ → លួចបាន"
    hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12
    hintLabel.TextWrapped = true

    -- Stats Label
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Parent = mainFrame
    statsLabel.Size = UDim2.new(1, -40, 0, 20)
    statsLabel.Position = UDim2.new(0, 20, 0, 295)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "សរុបបានលួច: 0 ផ្លែ"
    statsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextSize = 12

    -- Rainbow Title
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.03) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    -- Update Stats
    task.spawn(function()
        while gui.Parent do
            statsLabel.Text = "សរុបបានលួច: " .. State.TotalStolen .. " ផ្លែ"
            task.wait(0.5)
        end
    end)

    --============== ព្រឹត្តិការណ៍ ==============
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
            hintLabel.Text = "✅ បានកំណត់ទីតាំងផ្ទះថ្មីរួចរាល់!"
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

--============== ទាញយករូបភាព និងចាប់ផ្ដើម ==============
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

print("✅ Garden Mass Stealer បានផ្ទុក!")
print("🌾 លក្ខណៈ:")
print("   • ទៅជិតផ្លែឈើ (មិនមែនចុះក្រោមដី)")
print("   • ចុចជាប់ (Hold) ត្រឹមត្រូវ")
print("   • លួចច្រើនផ្លែជាប់ៗគ្នា")
print("   • Auto-Steal ដោយស្វ័យប្រវត្តិ")
