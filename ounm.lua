--========================================================
-- GROW A GARDEN 2: AUTO TP STEALER (-100m) - FULL AUTO
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
    mainFrame.Size = UDim2.new(0, 380, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = "🌜 AUTO GARDEN STEALER (-100m)"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
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

    -- ប៊ូតុង Auto Loop
    local autoBtn = Instance.new("TextButton", mainFrame)
    autoBtn.Size = UDim2.new(1, -40, 0, 40)
    autoBtn.Position = UDim2.new(0, 20, 0, 55)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    autoBtn.Text = "🔄 បើក Auto លួច (បិទ/បើក)"
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 13
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 8)

    local setHomeBtn = Instance.new("TextButton", mainFrame)
    setHomeBtn.Size = UDim2.new(1, -40, 0, 35)
    setHomeBtn.Position = UDim2.new(0, 20, 0, 105)
    setHomeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    setHomeBtn.Text = "📍 កំណត់ទីតាំងផ្ទះបច្ចុប្បន្ន"
    setHomeBtn.TextColor3 = Color3.new(1,1,1)
    setHomeBtn.Font = Enum.Font.GothamBold
    setHomeBtn.TextSize = 12
    Instance.new("UICorner", setHomeBtn).CornerRadius = UDim.new(0, 8)

    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 100)
    hintLabel.Position = UDim2.new(0, 20, 0, 150)
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

    --============== មុខងារ Auto Loop ==============
    local isAutoRunning = false

    autoBtn.MouseButton1Down:Connect(function()
        isAutoRunning = not isAutoRunning
        if isAutoRunning then
            autoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            autoBtn.Text = "⏹️ បិទ Auto លួច"
            hintLabel.Text = "ស្ថានភាព: 🚀 Auto កំពុងដំណើរការ..."
            
            task.spawn(function()
                while isAutoRunning do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local plants = getEnemyPlants()
                        if #plants > 0 then
                            for i, plantData in ipairs(plants) do
                                if not isAutoRunning then break end
                                if plantData.model.Parent and plantData.prompt.Parent then
                                    hintLabel.Text = "⚡ Auto លួចពីក្រោមដី... (" .. i .. "/" .. #plants .. ")"
                                    stealCrop(plantData)
                                    task.wait(0.2)
                                end
                            end
                            hintLabel.Text = "✅ លួចរួច! កំពុងត្រលប់មកផ្ទះ..."
                            tpTo(HOME_POSITION)
                            task.wait(1) -- រង់ចាំ ១ វិនាទីសិន ទើបស្កេនម្ដងទៀត
                        else
                            hintLabel.Text = "🔍 មិនមានផ្លែឈើទេ កំពុងរង់ចាំដំណាំធំ..."
                        end
                    end
                    task.wait(2) -- ឆែករកផ្លែឈើថ្មីរៀងរាល់ ២ វិនាទី
                end
            end)
        else
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            autoBtn.Text = "🔄 បើក Auto លួច (បិទ/បើក)"
            hintLabel.Text = "ស្ថានភាព: បានបញ្ឈប់ Auto!"
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
        isAutoRunning = false
        gui:Destroy()
    end)

    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    makeDraggable(mainFrame)
end

createGUI()
