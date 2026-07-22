--========================================================
-- GROW A GARDEN: REAL WORKING MASS STEALER
-- ដំណើរការបានពិត - ចុចឲ្យជាប់ (Hold) ត្រឹមត្រូវ
--========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--============== ការកំណត់ ==============
local Config = {
    StealOffset = Vector3.new(0, 3, 0),    -- ទៅជិតផ្លែឈើ (មិនមែនចុះក្រោមដី)
    HoldDuration = 0.5,                      -- រយៈពេលចុចជាប់ (វិនាទី)
    BetweenSteals = 0.3,                     -- រង់ចាំរវាងផ្លែ
    AutoStealDelay = 2,                      -- វិនាទីរវាង Auto-Steal
    SearchRadius = 500,                      -- ការវាស់វែងស្វែងរក
}

local State = {
    IsRunning = false,
    IsAutoStealing = false,
    TotalStolen = 0,
    CurrentPlants = {},
}

--============== មុខងារជំនួយ ==============
local function Log(msg)
    print("[🌾 Stealer] " .. msg)
end

local function GetChar()
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    return Character, HumanoidRootPart
end

local function TweenTo(pos, speed)
    local char, root = GetChar()
    if not root then return false end
    
    local distance = (root.Position - pos).Magnitude
    local time = distance / (speed or 200)
    
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(pos)
    })
    tween:Play()
    tween.Completed:Wait()
    return true
end

--============== រកផ្លែឈើដែលលួចបាន ==============
local function FindStealablePlants()
    local plants = {}
    local myName = LocalPlayer.Name
    local myId = tostring(LocalPlayer.UserId)
    
    -- រកនៅគ្រប់ទីកន្លែង
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent then
            -- ពិនិត្យម្ចាស់
            local owner = nil
            
            -- វិធី 1: Attribute
            local attr = obj:GetAttribute("Owner") or obj:GetAttribute("owner") or obj:GetAttribute("Player")
            if attr then owner = tostring(attr) end
            
            -- វិធី 2: StringValue
            if not owner then
                local val = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner") or obj:FindFirstChild("Player")
                if val and val:IsA("StringValue") then owner = val.Value end
                if val and val:IsA("ObjectValue") and val.Value then owner = val.Value.Name end
            end
            
            -- វិធី 3: ឈ្មោះ Plot
            if not owner and obj.Parent then
                local plotName = obj.Parent.Name
                if plotName and plotName ~= myName and plotName ~= "Workspace" then
                    -- បើ Plot មិនមែនរបស់យើង
                    owner = plotName
                end
            end
            
            -- បើជារបស់អ្នកដទៃ
            if owner and owner ~= myName and owner ~= myId then
                -- រក ProximityPrompt ដែលមាន "Steal"
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        local txt = (child.ActionText .. " " .. child.ObjectText):lower()
                        local name = child.Name:lower()
                        
                        if txt:find("steal") or txt:find("harvest") or txt:find("collect") or 
                           name:find("steal") or name:find("harvest") then
                            
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                table.insert(plants, {
                                    Model = obj,
                                    Part = part,
                                    Prompt = child,
                                    Owner = owner,
                                    Name = obj.Name,
                                    Pos = part.Position
                                })
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

--============== លួចផ្លែឈើ (ពិតៗ) ==============
local function StealPlant(plant)
    local char, root = GetChar()
    if not root then return false end
    
    -- 1. ទៅជិតផ្លែឈើ (ពិតៗ)
    local targetPos = plant.Pos + Config.StealOffset
    TweenTo(targetPos, 300)
    
    -- 2. រង់ចាំឲ្យទៅដល់
    task.wait(0.1)
    
    -- 3. បើក Prompt ឲ្យដំណើរការបាន
    local prompt = plant.Prompt
    if not prompt or not prompt.Parent then return false end
    
    -- កំណត់ឲ្យចុចបាន
    local originalHold = prompt.HoldDuration
    local originalDist = prompt.MaxActivationDistance
    local originalLOS = prompt.RequiresLineOfSight
    
    prompt.MaxActivationDistance = 50
    prompt.RequiresLineOfSight = false
    
    -- 4. ចុចឲ្យជាប់ (Hold) ត្រឹមត្រូវ
    local holdTime = originalHold > 0 and originalHold or Config.HoldDuration
    
    -- វិធីទី 1: fireproximityprompt (ភ្លាម)
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt, holdTime + 0.1)
        end)
    end
    
    -- វិធីទី 2: InputHoldBegin/End (ពិតប្រាកដ)
    task.wait(0.05)
    pcall(function()
        prompt:InputHoldBegin()
    end)
    
    task.wait(holdTime + 0.1)
    
    pcall(function()
        prompt:InputHoldEnd()
    end)
    
    -- វិធីទី 3: Trigger (បើមាន)
    task.wait(0.05)
    pcall(function()
        prompt:Trigger()
    end)
    
    -- សងរចនាសម្ព័ន្ធដើម
    task.delay(1, function()
        pcall(function()
            prompt.MaxActivationDistance = originalDist
            prompt.RequiresLineOfSight = originalLOS
        end)
    end)
    
    State.TotalStolen = State.TotalStolen + 1
    Log("✅ លួច: " .. plant.Name .. " ពី " .. plant.Owner)
    
    return true
end

--============== MASS STEAL ==============
local function MassSteal(statusLabel)
    local char, root = GetChar()
    if not root then 
        if statusLabel then statusLabel.Text = "❌ គ្មានតួអង្គ" end
        return 0 
    end
    
    if statusLabel then statusLabel.Text = "🔍 កំពុងស្វែងរកផ្លែឈើ..." end
    local plants = FindStealablePlants()
    
    if #plants == 0 then
        if statusLabel then statusLabel.Text = "❌ រកមិនឃើញផ្លែឈើដែលលួចបាន" end
        return 0
    end
    
    if statusLabel then 
        statusLabel.Text = "🎯 បានរកឃើញ " .. #plants .. " ផ្លែ! កំពុងលួច..." 
    end
    
    local stolen = 0
    for i, plant in ipairs(plants) do
        if not plant.Model.Parent then continue end
        
        if statusLabel then
            statusLabel.Text = "⚡ លួច " .. i .. "/" .. #plants .. ": " .. plant.Name .. "\nសរុប: " .. State.TotalStolen
        end
        
        local ok = pcall(function()
            return StealPlant(plant)
        end)
        
        if ok then stolen = stolen + 1 end
        task.wait(Config.BetweenSteals)
    end
    
    if statusLabel then
        statusLabel.Text = "✅ លួចបាន " .. stolen .. "/" .. #plants .. " ផ្លែ!\nសរុបទាំងអស់: " .. State.TotalStolen
    end
    
    return stolen
end

--============== AUTO STEAL LOOP ==============
local function StartAuto(statusLabel, btn)
    if State.IsAutoStealing then return end
    State.IsAutoStealing = true
    
    if btn then
        btn.Text = "⏹ បញ្ឈប់ Auto"
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    task.spawn(function()
        while State.IsAutoStealing do
            MassSteal(statusLabel)
            task.wait(Config.AutoStealDelay)
        end
        
        if btn then
            btn.Text = "🔄 Auto Steal"
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        end
    end)
end

local function StopAuto()
    State.IsAutoStealing = false
end

--============== GUI ==============
local function CreateGUI()
    if CoreGui:FindFirstChild("GardenRealStealer") then
        CoreGui:FindFirstChild("GardenRealStealer"):Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "GardenRealStealer"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 280)
    frame.Position = UDim2.new(0.5, -160, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49,49,450,450)
    shadow.ZIndex = -1
    shadow.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "🌾 REAL MASS STEALER"
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Drag handle
    local drag = Instance.new("Frame")
    drag.Size = UDim2.new(1, 0, 0, 40)
    drag.BackgroundTransparency = 1
    drag.Active = true
    drag.Parent = frame
    
    local dragInd = Instance.new("TextLabel")
    dragInd.Size = UDim2.new(0, 50, 0, 20)
    dragInd.Position = UDim2.new(0.5, -25, 0, 0)
    dragInd.BackgroundTransparency = 1
    dragInd.Text = "━━━"
    dragInd.TextColor3 = Color3.fromRGB(100, 100, 120)
    dragInd.Parent = drag
    
    -- Close
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -35, 0, 8)
    close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.Parent = frame
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 45)
    status.BackgroundTransparency = 1
    status.Text = "រង់ចាំ... ចុច 'MASS STEAL' ដើម្បីលួច"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextWrapped = true
    status.Parent = frame
    
    -- Steal Button
    local stealBtn = Instance.new("TextButton")
    stealBtn.Size = UDim2.new(1, -20, 0, 40)
    stealBtn.Position = UDim2.new(0, 10, 0, 105)
    stealBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    stealBtn.Text = "⚡ MASS STEAL (លួចច្រើនផ្លែ)"
    stealBtn.TextColor3 = Color3.new(0,0,0)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 13
    stealBtn.Parent = frame
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)
    
    -- Auto Button
    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, -20, 0, 40)
    autoBtn.Position = UDim2.new(0, 10, 0, 155)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    autoBtn.Text = "🔄 Auto Steal"
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 13
    autoBtn.Parent = frame
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 10)
    
    -- Stats
    local stats = Instance.new("TextLabel")
    stats.Size = UDim2.new(1, -20, 0, 30)
    stats.Position = UDim2.new(0, 10, 0, 205)
    stats.BackgroundTransparency = 1
    stats.Text = "សរុបបានលួច: 0 ផ្លែ"
    stats.TextColor3 = Color3.fromRGB(255, 215, 0)
    stats.TextSize = 14
    stats.Font = Enum.Font.GothamBold
    stats.Parent = frame
    
    -- Info
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 40)
    info.Position = UDim2.new(0, 10, 0, 235)
    info.BackgroundTransparency = 1
    info.Text = "💡 វិធី: ទៅជិតផ្លែ → ចុចជាប់ → លួច"
    info.TextColor3 = Color3.fromRGB(180, 180, 180)
    info.TextSize = 10
    info.Font = Enum.Font.Gotham
    info.TextWrapped = true
    info.Parent = frame
    
    -- Events
    stealBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            MassSteal(status)
            stats.Text = "សរុបបានលួច: " .. State.TotalStolen .. " ផ្លែ"
        end)
    end)
    
    autoBtn.MouseButton1Click:Connect(function()
        if State.IsAutoStealing then
            StopAuto()
            autoBtn.Text = "🔄 Auto Steal"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            status.Text = "⏹ បានបញ្ឈប់ Auto"
        else
            StartAuto(status, autoBtn)
        end
    end)
    
    close.MouseButton1Click:Connect(function()
        StopAuto()
        gui:Destroy()
    end)
    
    -- Drag
    local dragging = false
    local startPos, framePos
    
    drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            framePos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Update stats
    RunService.RenderStepped:Connect(function()
        stats.Text = "សរុបបានលួច: " .. State.TotalStolen .. " ផ្លែ"
    end)
end

--============== ចាប់ផ្ដើម ==============
CreateGUI()

Log("✅ Real Mass Stealer បានផ្ទុក!")
Log("🎮 វិធីដំណើរការ:")
Log("   1. ទៅជិតផ្លែឈើ (Tween លឿន)")
Log("   2. ចុចជាប់ (Hold) ត្រឹមត្រូវតាមពេលវេលា")
Log("   3. លួចច្រើនផ្លែជាប់ៗគ្នា")
Log("   4. Auto-Steal ដោយស្វ័យប្រវត្តិ")
