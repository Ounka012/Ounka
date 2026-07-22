--========================================================
-- GROW A GARDEN: FULL COMPLETE MASS STEALER
-- កូដពេញលេញ - ដំណើរការបានពិត
-- ទៅជិតផ្លែឈើ → ចុចជាប់ → លួចបានច្រើនផ្លែ
--========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--========================================================
-- CONFIGURATION (ការកំណត់)
--========================================================

local Config = {
    StealOffset = Vector3.new(0, 2.5, 0),      -- គម្លាតពីផ្លែឈើ (ទៅជិត)
    HoldDuration = 0.6,                          -- រយៈពេលចុចជាប់ (វិនាទី)
    BetweenSteals = 0.2,                         -- រង់ចាំរវាងផ្លែ (វិនាទី)
    AutoStealDelay = 3,                          -- វិនាទីរវាង Auto-Steal រាល់ដង
    SearchRadius = 1000,                         -- ការវាស់វែងស្វែងរក
    TweenSpeed = 350,                            -- ល្បឿនហោះ (studs/second)
    ESP = true,                                  -- បើក ESP
    ESPColor = Color3.fromRGB(255, 50, 50),      -- ពណ៌ ESP
}

--========================================================
-- STATE (ស្ថានភាព)
--========================================================

local State = {
    IsRunning = false,
    IsAutoStealing = false,
    TotalStolen = 0,
    CurrentPlants = {},
    ESPObjects = {},
    LastStolen = {},
    GUI = nil,
}

--========================================================
-- UTILITY FUNCTIONS (មុខងារជំនួយ)
--========================================================

local function Log(msg, type)
    local icon = type == "error" and "❌" or type == "success" and "✅" or type == "warn" and "⚠️" or "ℹ️"
    print(string.format("%s [GardenStealer] %s", icon, msg))
end

local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    return Character, HumanoidRootPart
end

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Tween ទៅរកទីតាំង (លឿន និង រលូន)
local function TweenTo(position, speed)
    local char, root = GetCharacter()
    if not root then return false end
    
    local distance = GetDistance(root.Position, position)
    if distance < 2 then return true end
    
    local duration = distance / (speed or Config.TweenSpeed)
    if duration > 3 then duration = 3 end -- កំណត់អតិបរមា 3 វិនាទី
    
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(position)
    })
    
    tween:Play()
    tween.Completed:Wait()
    return true
end

--========================================================
-- ESP SYSTEM (ប្រព័ន្ធ ESP)
--========================================================

local function CreateESP(obj, color, name)
    if not obj or not obj.Parent then return end
    
    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    
    -- លុប ESP ចាស់
    if State.ESPObjects[obj] then
        pcall(function()
            State.ESPObjects[obj].Highlight:Destroy()
            State.ESPObjects[obj].Billboard:Destroy()
        end)
    end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "StealESP"
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.1
    highlight.Parent = part
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔴 " .. (name or "Plant")
    label.TextColor3 = color
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextSize = 10
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = billboard
    
    State.ESPObjects[obj] = {
        Highlight = highlight,
        Billboard = billboard,
        DistanceLabel = distLabel,
        Object = obj
    }
    
    -- លុបពេលវត្ថុត្រូវបានលុប
    obj.AncestryChanged:Connect(function()
        if not obj:IsDescendantOf(Workspace) then
            if State.ESPObjects[obj] then
                pcall(function()
                    State.ESPObjects[obj].Highlight:Destroy()
                    State.ESPObjects[obj].Billboard:Destroy()
                end)
                State.ESPObjects[obj] = nil
            end
        end
    end)
end

local function ClearESP()
    for obj, data in pairs(State.ESPObjects) do
        pcall(function()
            data.Highlight:Destroy()
            data.Billboard:Destroy()
        end)
    end
    State.ESPObjects = {}
end

local function UpdateESPDistances()
    local char, root = GetCharacter()
    if not root then return end
    
    for obj, data in pairs(State.ESPObjects) do
        if data.DistanceLabel and data.Object and data.Object.Parent then
            local part = data.Object:IsA("BasePart") and data.Object or data.Object:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = GetDistance(root.Position, part.Position)
                data.DistanceLabel.Text = math.floor(dist) .. "m"
            end
        end
    end
end

--========================================================
-- PLANT FINDER (រកផ្លែឈើ)
--========================================================

local function FindStealablePlants()
    local plants = {}
    local myName = LocalPlayer.Name
    local myId = tostring(LocalPlayer.UserId)
    local checked = {}
    
    -- រកនៅក្នុង Workspace ទាំងមូល
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not checked[obj] then
            checked[obj] = true
            
            local owner = nil
            
            -- វិធី 1: Attribute
            local attr = obj:GetAttribute("Owner") or obj:GetAttribute("owner") or obj:GetAttribute("Player") or obj:GetAttribute("player")
            if attr then owner = tostring(attr) end
            
            -- វិធី 2: StringValue / ObjectValue
            if not owner then
                local val = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner") or obj:FindFirstChild("Player")
                if val then
                    if val:IsA("StringValue") then owner = val.Value
                    elseif val:IsA("ObjectValue") and val.Value then owner = val.Value.Name end
                end
            end
            
            -- វិធី 3: Plot Name
            if not owner and obj.Parent then
                local pName = obj.Parent.Name
                if pName and pName ~= "Workspace" and pName ~= "Plots" and pName ~= "Gardens" then
                    -- ពិនិត្យថាតើឈ្មោះ Plot ជាឈ្មោះ Player ឬអត់
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr.Name == pName or tostring(plr.UserId) == pName then
                            owner = pName
                            break
                        end
                    end
                end
            end
            
            -- វិធី 4: Plot Folder របស់អ្នកដទៃ
            if not owner then
                local plot = obj:FindFirstAncestorOfClass("Folder") or obj:FindFirstAncestorOfClass("Model")
                if plot then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plot.Name == plr.Name or plot.Name == tostring(plr.UserId) then
                            if plr ~= LocalPlayer then
                                owner = plot.Name
                            end
                            break
                        end
                    end
                end
            end
            
            -- បើជារបស់អ្នកដទៃ
            if owner and owner ~= myName and owner ~= myId then
                -- រក ProximityPrompt ដែលអាចលួចបាន
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        local action = (child.ActionText or ""):lower()
                        local objText = (child.ObjectText or ""):lower()
                        local cName = child.Name:lower()
                        
                        -- ពិនិត្យថាតើជា Steal ឬអត់
                        if action:find("steal") or action:find("harvest") or action:find("collect") or action:find("grab") or
                           objText:find("steal") or objText:find("harvest") or
                           cName:find("steal") or cName:find("harvest") then
                            
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                table.insert(plants, {
                                    Model = obj,
                                    Part = part,
                                    Prompt = child,
                                    Owner = owner,
                                    Name = obj.Name,
                                    Position = part.Position
                                })
                                
                                -- ESP
                                if Config.ESP then
                                    CreateESP(obj, Config.ESPColor, obj.Name)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- តម្រៀបតាមចម្ងាយ (ជិតបំផុតមុន)
    table.sort(plants, function(a, b)
        local char, root = GetCharacter()
        if not root then return false end
        return GetDistance(root.Position, a.Position) < GetDistance(root.Position, b.Position)
    end)
    
    return plants
end

--========================================================
-- STEAL FUNCTION (លួចផ្លែឈើ - ពិតៗ)
--========================================================

local function StealPlant(plant, statusLabel)
    local char, root = GetCharacter()
    if not root then 
        Log("គ្មានតួអង្គ", "error")
        return false 
    end
    
    -- 1. ទៅជិតផ្លែឈើ (ពិតៗ - មិនមែនចុះក្រោមដី)
    local targetPos = plant.Position + Config.StealOffset
    local dist = GetDistance(root.Position, targetPos)
    
    if dist > 5 then
        if statusLabel then
            statusLabel.Text = "🚀 ទៅរក: " .. plant.Name .. "\nចម្ងាយ: " .. math.floor(dist) .. "m"
        end
        TweenTo(targetPos, Config.TweenSpeed)
    end
    
    task.wait(0.15)
    
    -- 2. បើក Prompt ឲ្យដំណើរការបាន
    local prompt = plant.Prompt
    if not prompt or not prompt.Parent then 
        Log("Prompt បាត់", "warn")
        return false 
    end
    
    -- រក្សាទុករចនាសម្ព័ន្ធដើម
    local origHold = prompt.HoldDuration
    local origDist = prompt.MaxActivationDistance
    local origLOS = prompt.RequiresLineOfSight
    local origEnabled = prompt.Enabled
    
    -- កំណត់ឲ្យចុចបាន
    prompt.MaxActivationDistance = 50
    prompt.RequiresLineOfSight = false
    prompt.Enabled = true
    
    local holdTime = origHold > 0 and origHold or Config.HoldDuration
    
    if statusLabel then
        statusLabel.Text = "🖐 កំពុងចុចជាប់: " .. plant.Name .. "\nរយៈពេល: " .. string.format("%.1f", holdTime) .. "s"
    end
    
    -- 3. វិធីលួច (ចុចជាប់ - Hold)
    local stolen = false
    
    -- វិធី 1: InputHoldBegin/End (ពិតប្រាកដបំផុត)
    pcall(function()
        prompt:InputHoldBegin()
    end)
    
    task.wait(holdTime + 0.1)
    
    pcall(function()
        prompt:InputHoldEnd()
        stolen = true
    end)
    
    -- វិធី 2: fireproximityprompt (បើមាន)
    if not stolen and fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt, holdTime + 0.1)
            stolen = true
        end)
    end
    
    -- វិធី 3: Trigger
    if not stolen then
        pcall(function()
            prompt:Trigger()
            stolen = true
        end)
    end
    
    -- សងរចនាសម្ព័ន្ធដើម (ក្រោយ 1 វិនាទី)
    task.delay(1, function()
        pcall(function()
            prompt.MaxActivationDistance = origDist
            prompt.RequiresLineOfSight = origLOS
            prompt.HoldDuration = origHold
            if not origEnabled then prompt.Enabled = false end
        end)
    end)
    
    if stolen then
        State.TotalStolen = State.TotalStolen + 1
        table.insert(State.LastStolen, plant.Name)
        if #State.LastStolen > 5 then table.remove(State.LastStolen, 1) end
        Log("✅ លួចបាន: " .. plant.Name .. " ពី " .. plant.Owner, "success")
    else
        Log("❌ លួចមិនបាន: " .. plant.Name, "error")
    end
    
    return stolen
end

--========================================================
-- MASS STEAL (លួចច្រើនផ្លែ)
--========================================================

local function MassSteal(statusLabel)
    local char, root = GetCharacter()
    if not root then 
        if statusLabel then statusLabel.Text = "❌ គ្មានតួអង្គ" end
        return 0 
    end
    
    if statusLabel then statusLabel.Text = "🔍 កំពុងស្វែងរកផ្លែឈើ..." end
    
    -- លុប ESP ចាស់
    ClearESP()
    task.wait(0.1)
    
    local plants = FindStealablePlants()
    
    if #plants == 0 then
        if statusLabel then statusLabel.Text = "❌ រកមិនឃើញផ្លែឈើដែលលួចបាន\n(អាចមិនមានផ្លែឈើឬគេលួចអស់ហើយ)" end
        return 0
    end
    
    if statusLabel then 
        statusLabel.Text = "🎯 រកឃើញ " .. #plants .. " ផ្លែ!\nកំពុងលួច..." 
    end
    
    local stolen = 0
    for i, plant in ipairs(plants) do
        if not plant.Model.Parent then continue end
        
        local ok, err = pcall(function()
            return StealPlant(plant, statusLabel)
        end)
        
        if ok then stolen = stolen + 1 end
        
        if statusLabel then
            statusLabel.Text = "⚡ " .. i .. "/" .. #plants .. " | លួចបាន: " .. stolen .. "\nសរុបទាំងអស់: " .. State.TotalStolen
        end
        
        task.wait(Config.BetweenSteals)
    end
    
    -- ត្រលប់ទៅកន្លែងដើម
    if statusLabel then
        statusLabel.Text = "✅ លួចបាន " .. stolen .. "/" .. #plants .. " ផ្លែ!\nសរុបទាំងអស់: " .. State.TotalStolen
    end
    
    return stolen
end

--========================================================
-- AUTO STEAL LOOP
--========================================================

local function StartAuto(statusLabel, btn)
    if State.IsAutoStealing then return end
    State.IsAutoStealing = true
    
    if btn then
        btn.Text = "⏹ បញ្ឈប់ Auto Steal"
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    task.spawn(function()
        while State.IsAutoStealing do
            if not LocalPlayer.Character then
                task.wait(1)
                continue
            end
            
            MassSteal(statusLabel)
            task.wait(Config.AutoStealDelay)
        end
        
        if btn then
            btn.Text = "🔄 Auto Steal"
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        end
        if statusLabel then statusLabel.Text = "⏹ Auto Steal បានបញ្ឈប់" end
    end)
end

local function StopAuto()
    State.IsAutoStealing = false
end

--========================================================
-- GUI CREATION (បង្កើត GUI)
--========================================================

local function CreateGUI()
    if CoreGui:FindFirstChild("GardenCompleteStealer") then
        CoreGui:FindFirstChild("GardenCompleteStealer"):Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "GardenCompleteStealer"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    
    -- Toggle Button (ប៊ូតុងបង្ហាញ/លាក់)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 45, 0, 45)
    toggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggleBtn.Text = "🌾"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 22
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Visible = false
    toggleBtn.Parent = gui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.5, 0)
    toggleCorner.Parent = toggleBtn
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(0, 255, 100)
    toggleStroke.Thickness = 2
    toggleStroke.Parent = toggleBtn
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainFrame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = mainFrame
    
    -- Top Drag Handle
    local topDrag = Instance.new("Frame")
    topDrag.Size = UDim2.new(1, 0, 0, 30)
    topDrag.BackgroundTransparency = 1
    topDrag.Active = true
    topDrag.Parent = mainFrame
    
    local dragInd = Instance.new("TextLabel")
    dragInd.Size = UDim2.new(0, 50, 0, 18)
    dragInd.Position = UDim2.new(0.5, -25, 0, 2)
    dragInd.BackgroundTransparency = 1
    dragInd.Text = "━━━"
    dragInd.TextColor3 = Color3.fromRGB(80, 80, 100)
    dragInd.TextSize = 12
    dragInd.Font = Enum.Font.Gotham
    dragInd.Parent = topDrag
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.Position = UDim2.new(0, 0, 0, 18)
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLine = Instance.new("Frame")
    titleLine.Size = UDim2.new(1, 0, 0, 2)
    titleLine.Position = UDim2.new(0, 0, 1, -2)
    titleLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    titleLine.BorderSizePixel = 0
    titleLine.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 200, 0, 22)
    titleText.Position = UDim2.new(0, 12, 0.5, -11)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🌾 GARDEN STEALER"
    titleText.TextColor3 = Color3.fromRGB(0, 255, 100)
    titleText.TextSize = 15
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Minimize
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 26, 0, 26)
    minBtn.Position = UDim2.new(1, -58, 0.5, -13)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = titleBar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    
    -- Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -13)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    -- Bottom Drag
    local bottomDrag = Instance.new("Frame")
    bottomDrag.Size = UDim2.new(1, 0, 0, 25)
    bottomDrag.Position = UDim2.new(0, 0, 1, -25)
    bottomDrag.BackgroundTransparency = 1
    bottomDrag.Active = true
    bottomDrag.Parent = mainFrame
    
    local bottomInd = Instance.new("TextLabel")
    bottomInd.Size = UDim2.new(0, 50, 0, 18)
    bottomInd.Position = UDim2.new(0.5, -25, 0, 2)
    bottomInd.BackgroundTransparency = 1
    bottomInd.Text = "━━━"
    bottomInd.TextColor3 = Color3.fromRGB(80, 80, 100)
    bottomInd.TextSize = 12
    bottomInd.Font = Enum.Font.Gotham
    bottomInd.Parent = bottomDrag
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 0, 310)
    content.Position = UDim2.new(0, 8, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Status Card
    local statusCard = Instance.new("Frame")
    statusCard.Size = UDim2.new(1, 0, 0, 60)
    statusCard.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    statusCard.BorderSizePixel = 0
    statusCard.Parent = content
    Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 10)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -16, 1, -10)
    statusLabel.Position = UDim2.new(0, 8, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "រង់ចាំ... ចុច 'MASS STEAL' ដើម្បីលួចផ្លែឈើ"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextWrapped = true
    statusLabel.Parent = statusCard
    
    -- Stats Row
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, 0, 0, 35)
    statsFrame.Position = UDim2.new(0, 0, 0, 68)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = content
    
    local totalLabel = Instance.new("TextLabel")
    totalLabel.Size = UDim2.new(0.48, 0, 1, 0)
    totalLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    totalLabel.Text = "សរុប: 0"
    totalLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    totalLabel.TextSize = 13
    totalLabel.Font = Enum.Font.GothamBold
    totalLabel.Parent = statsFrame
    Instance.new("UICorner", totalLabel).CornerRadius = UDim.new(0, 8)
    
    local plantsLabel = Instance.new("TextLabel")
    plantsLabel.Size = UDim2.new(0.48, 0, 1, 0)
    plantsLabel.Position = UDim2.new(0.52, 0, 0, 0)
    plantsLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    plantsLabel.Text = "ផ្លែ: 0"
    plantsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    plantsLabel.TextSize = 13
    plantsLabel.Font = Enum.Font.GothamBold
    plantsLabel.Parent = statsFrame
    Instance.new("UICorner", plantsLabel).CornerRadius = UDim.new(0, 8)
    
    -- Buttons
    local stealBtn = Instance.new("TextButton")
    stealBtn.Size = UDim2.new(1, 0, 0, 38)
    stealBtn.Position = UDim2.new(0, 0, 0, 112)
    stealBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    stealBtn.Text = "⚡ MASS STEAL (លួចច្រើនផ្លែ)"
    stealBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    stealBtn.TextSize = 13
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.Parent = content
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)
    
    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, 0, 0, 38)
    autoBtn.Position = UDim2.new(0, 0, 0, 156)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    autoBtn.Text = "🔄 Auto Steal"
    autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoBtn.TextSize = 13
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.Parent = content
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 10)
    
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(1, 0, 0, 32)
    espBtn.Position = UDim2.new(0, 0, 0, 200)
    espBtn.BackgroundColor3 = Config.ESP and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 50, 60)
    espBtn.Text = Config.ESP and "👁 ESP: ON" or "👁 ESP: OFF"
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.TextSize = 12
    espBtn.Font = Enum.Font.GothamBold
    espBtn.Parent = content
    Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)
    
    -- Sliders
    local function CreateSlider(name, min, max, default, callback, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 42)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
        frame.BorderSizePixel = 0
        frame.Parent = content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 120, 0, 16)
        label.Position = UDim2.new(0, 8, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 10
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 40, 0, 16)
        valLabel.Position = UDim2.new(1, -48, 0, 3)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        valLabel.TextSize = 10
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = frame
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -16, 0, 5)
        bar.Position = UDim2.new(0, 8, 0, 24)
        bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        bar.BorderSizePixel = 0
        bar.Parent = frame
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = bar
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)
        
        local dragging = false
        local function Update(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -6, 0.5, -6)
            valLabel.Text = tostring(val)
            if callback then callback(val) end
            return val
        end
        
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    
    CreateSlider("ល្បឿនហោះ", 100, 500, Config.TweenSpeed, function(v) Config.TweenSpeed = v end, 238)
    CreateSlider("រយៈពេលចុច", 1, 10, math.floor(Config.HoldDuration * 10), function(v) Config.HoldDuration = v / 10 end, 284)
    
    -- Events
    stealBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local count = MassSteal(statusLabel)
            totalLabel.Text = "សរុប: " .. State.TotalStolen
            plantsLabel.Text = "ផ្លែ: " .. count
        end)
    end)
    
    autoBtn.MouseButton1Click:Connect(function()
        if State.IsAutoStealing then
            StopAuto()
            autoBtn.Text = "🔄 Auto Steal"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        else
            StartAuto(statusLabel, autoBtn)
        end
    end)
    
    espBtn.MouseButton1Click:Connect(function()
        Config.ESP = not Config.ESP
        espBtn.BackgroundColor3 = Config.ESP and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 50, 60)
        espBtn.Text = Config.ESP and "👁 ESP: ON" or "👁 ESP: OFF"
        if not Config.ESP then ClearESP() end
    end)
    
    -- Minimize
    local isMinimized = false
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 340, 0, 35) or UDim2.new(0, 340, 0, 400)
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
        minBtn.Text = isMinimized and "+" or "−"
        content.Visible = not isMinimized
        topDrag.Visible = not isMinimized
        bottomDrag.Visible = not isMinimized
    end)
    
    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        StopAuto()
        ClearESP()
        toggleBtn.Visible = true
        mainFrame.Visible = false
    end)
    
    -- Toggle
    toggleBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Drag System
    local isDragging = false
    local dragStart, frameStart
    
    local function StartDrag(input)
        isDragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
        dragInd.TextColor3 = Color3.fromRGB(0, 255, 100)
        bottomInd.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
    
    topDrag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            StartDrag(input)
        end
    end)
    
    bottomDrag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            StartDrag(input)
        end
    end)
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            StartDrag(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            dragInd.TextColor3 = Color3.fromRGB(80, 80, 100)
            bottomInd.TextColor3 = Color3.fromRGB(80, 80, 100)
        end
    end)
    
    -- Drag Toggle Button
    local tDragging = false
    local tStart, tPos
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = true
            tStart = input.Position
            tPos = toggleBtn.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tStart
            toggleBtn.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset + delta.X, tPos.Y.Scale, tPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = false
        end
    end)
    
    -- Update Loop
    RunService.RenderStepped:Connect(function()
        totalLabel.Text = "សរុប: " .. State.TotalStolen
        if Config.ESP then
            UpdateESPDistances()
        end
    end)
    
    State.GUI = gui
    Log("GUI បានបង្កើតរួចរាល់!", "success")
end

--========================================================
-- INITIALIZE (ចាប់ផ្ដើម)
--========================================================

CreateGUI()

Log("✅ GROW A GARDEN - COMPLETE STEALER បានផ្ទុក!", "success")
Log("📋 លក្ខណៈ:", "success")
Log("   • ទៅជិតផ្លែឈើពិតៗ (Tween លឿន)", "success")
Log("   • ចុចជាប់ (Hold) ត្រឹមត្រូវតាមពេលវេលា", "success")
Log("   • Mass Steal - លួចច្រើនផ្លែជាប់ៗគ្នា", "success")
Log("   • Auto Steal - លួចដោយស្វ័យប្រវត្តិ", "success")
Log("   • ESP - មើលឃើញផ្លែឈើអ្នកដទៃ", "success")
Log("   • GUI ចុចអូសបាន (ខាងលើ + ខាងក្រោម)", "success")
