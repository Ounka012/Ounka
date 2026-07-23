--========================================================
-- GROW A GARDEN 2: REAL SHECKLES STEALER (WORKING)
--========================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

--============== ការកំណត់ ==============
local HOME_POSITION = Root.Position   -- ចុច Set Home ដើម្បីកំណត់
local HOLD_DURATION = 0.6            -- រយៈពេលសង្កត់ Steal (វិនាទី)
local BETWEEN_STEALS = 0.3           -- ចន្លោះពេលរវាងដើម
local AUTO_INTERVAL = 2              -- វិនាទីរវាងជុំ Auto

local State = {
    AutoRunning = false,
    TotalStolen = 0
}

--============== រកដំណាំដែលអាចលួចបាន ==============
local function findStealablePlants()
    local plants = {}
    local myName = LocalPlayer.Name
    local myId = tostring(LocalPlayer.UserId)

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent then
            -- ពិនិត្យម្ចាស់
            local owner = nil
            local attr = obj:GetAttribute("Owner") or obj:GetAttribute("owner")
            if attr then owner = tostring(attr) end

            if not owner then
                local val = obj:FindFirstChild("Owner") or obj:FindFirstChild("owner")
                if val and val:IsA("StringValue") then owner = val.Value end
                if val and val:IsA("ObjectValue") and val.Value then owner = val.Value.Name end
            end

            if owner and owner ~= myName and owner ~= myId then
                -- រក ProximityPrompt ដែលមានពាក្យ "Steal"
                for _, prompt in pairs(obj:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local action = prompt.ActionText:lower()
                        local pname = prompt.Name:lower()
                        if action:find("steal") or pname:find("steal") then
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                table.insert(plants, {
                                    Model = obj,
                                    Part = part,
                                    Prompt = prompt,
                                    Name = obj.Name
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

--============== លួចដំណាំមួយ ==============
local function stealPlant(plant)
    local prompt = plant.Prompt
    if not prompt or not prompt.Parent then return false end

    -- TP ទៅជិត (ពីលើបន្តិច)
    Root.CFrame = CFrame.new(plant.Part.Position + Vector3.new(0, 4, 0))
    task.wait(0.15)

    -- បើកឲ្យ Prompt អាចដំណើរការបានក្នុងរង្វង់
    local oldMax = prompt.MaxActivationDistance
    local oldLOS = prompt.RequiresLineOfSight
    prompt.MaxActivationDistance = 100
    prompt.RequiresLineOfSight = false

    -- សង្កត់ Steal
    local holdTime = prompt.HoldDuration > 0 and prompt.HoldDuration or HOLD_DURATION
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(holdTime + 0.1)
    pcall(function() prompt:InputHoldEnd() end)

    -- ស្ដារឡើងវិញ
    task.delay(1, function()
        pcall(function()
            prompt.MaxActivationDistance = oldMax
            prompt.RequiresLineOfSight = oldLOS
        end)
    end)

    State.TotalStolen = State.TotalStolen + 1
    return true
end

--============== លួចទាំងអស់ ==============
local function massSteal(statusLabel)
    local plants = findStealablePlants()
    if #plants == 0 then
        if statusLabel then statusLabel.Text = "❌ រកមិនឃើញដំណាំដែលអាចលួច" end
        return
    end

    for i, plant in ipairs(plants) do
        if statusLabel then
            statusLabel.Text = "លួច " .. i .. "/" .. #plants .. ": " .. plant.Name
        end
        if plant.Model.Parent then
            stealPlant(plant)
        end
        task.wait(BETWEEN_STEALS)
    end

    -- ត្រឡប់មកផ្ទះ
    Root.CFrame = CFrame.new(HOME_POSITION)
    if statusLabel then
        statusLabel.Text = "✅ លួចរួច! សរុប: " .. State.TotalStolen .. " ដើម"
    end
end

--============== GUI ==============
local function createGUI()
    if CoreGui:FindFirstChild("ShecklesStealer") then
        CoreGui:FindFirstChild("ShecklesStealer"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "ShecklesStealer"
    gui.IgnoreGuiInset = true

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundTransparency = 1
    title.Text = "💰 REAL SHECKLES STEALER"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255,215,0)

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1,-20,0,35)
    status.Position = UDim2.new(0,10,0,35)
    status.BackgroundTransparency = 1
    status.Text = "ត្រៀមរួចរាល់"
    status.TextColor3 = Color3.new(1,1,1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextWrapped = true

    -- ប៊ូតុង Mass Steal
    local stealBtn = Instance.new("TextButton", frame)
    stealBtn.Size = UDim2.new(1,-20,0,35)
    stealBtn.Position = UDim2.new(0,10,0,75)
    stealBtn.BackgroundColor3 = Color3.fromRGB(255,140,0)
    stealBtn.Text = "⚡ លួចទាំងអស់ (Mass Steal)"
    stealBtn.TextColor3 = Color3.new(0,0,0)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 12
    Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0,8)
    stealBtn.MouseButton1Click:Connect(function()
        massSteal(status)
    end)

    -- ប៊ូតុង Auto-Steal
    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(1,-20,0,35)
    autoBtn.Position = UDim2.new(0,10,0,120)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
    autoBtn.Text = "🔄 បើក Auto-Steal"
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 12
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

    autoBtn.MouseButton1Click:Connect(function()
        State.AutoRunning = not State.AutoRunning
        if State.AutoRunning then
            autoBtn.Text = "⏹ បញ្ឈប់ Auto"
            autoBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
            status.Text = "ដំណើរការស្វ័យប្រវត្តិ..."
            task.spawn(function()
                while State.AutoRunning do
                    massSteal(status)
                    task.wait(AUTO_INTERVAL)
                end
                autoBtn.Text = "🔄 បើក Auto-Steal"
                autoBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
                status.Text = "បានបញ្ឈប់"
            end)
        else
            State.AutoRunning = false
        end
    end)

    -- ប៊ូតុង Set Home
    local homeBtn = Instance.new("TextButton", frame)
    homeBtn.Size = UDim2.new(1,-20,0,30)
    homeBtn.Position = UDim2.new(0,10,0,165)
    homeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    homeBtn.Text = "📍 កំណត់ផ្ទះ (Set Home)"
    homeBtn.TextColor3 = Color3.new(1,1,1)
    homeBtn.Font = Enum.Font.GothamBold
    homeBtn.TextSize = 11
    Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0,8)
    homeBtn.MouseButton1Click:Connect(function()
        if Character and Root then
            HOME_POSITION = Root.Position
            status.Text = "✅ ផ្ទះបានកំណត់"
        end
    end)

    -- បិទ
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0,25,0,25)
    closeBtn.Position = UDim2.new(1,-30,0,5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function()
        State.AutoRunning = false
        gui:Destroy()
    end)
end

createGUI()