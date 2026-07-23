local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local shecklesValue = nil
local shecklesRemote = nil
local collectEnabled = false

-- ផ្នែកស្វែងរក Value/Remote
local function deepSearch()
    -- 1. ស្វែងរក NumberValue/IntValue ដែលមានឈ្មោះ Sheckles
    local function findValue()
        for _, obj in pairs(player:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                if obj.Name:lower():match("sheckel") or obj.Name:lower():match("money") or obj.Name:lower():match("cash") then
                    return obj
                end
            end
        end
        for _, obj in pairs(player:GetChildren()) do
            if obj:IsA("Folder") or obj:IsA("Configuration") then
                for _, v in pairs(obj:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        if v.Name:lower():match("sheckel") or v.Name:lower():match("money") then return v end
                    end
                end
            end
        end
        return nil
    end

    -- 2. ស្វែងរក RemoteEvent ដែលប្រហែលជាបន្ថែម Sheckles
    local function findRemote()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:match("sheckel") or name:match("money") or name:match("cash") or name:match("add") then
                    return obj
                end
            end
        end
        return nil
    end

    shecklesValue = findValue()
    shecklesRemote = findRemote()
end

deepSearch()

-- ប្រអប់ GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesFinder"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 180)
frame.Position = UDim2.new(0.5, -140, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "💵 Sheckles Hack"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,40)
status.Position = UDim2.new(0,10,0,35)
status.BackgroundTransparency = 1
status.Text = shecklesValue and "Value រកឃើញ: "..shecklesValue.Name or (shecklesRemote and "Remote រកឃើញ: "..shecklesRemote.Name or "រកមិនឃើញ Value ឬ Remote")
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 90, 0, 28)
input.Position = UDim2.new(0, 10, 0, 85)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "500"
input.Text = "500"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

-- ប៊ូតុងបន្ថែម (ប្រើ Value បើមាន បើអត់ប្រើ Remote)
local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 100, 0, 28)
addBtn.Position = UDim2.new(0, 115, 0, 85)
addBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
addBtn.Text = "Add Sheckles"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 11
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,5)

addBtn.MouseButton1Click:Connect(function()
    local amt = tonumber(input.Text)
    if not amt then return end

    if shecklesValue then
        pcall(function() shecklesValue.Value = shecklesValue.Value + amt end)
        status.Text = "✅ បានបន្ថែម "..amt.." Sheckles (Value)"
    elseif shecklesRemote then
        pcall(function() shecklesRemote:FireServer(amt) end)
        pcall(function() shecklesRemote:FireServer(player, amt) end)
        status.Text = "✅ បាញ់ Remote ជាមួយ "..amt
    else
        status.Text = "❌ គ្មាន Value/Remote សាកដំណើរការ Auto-Collect វិញ"
    end
end)

-- ប៊ូតុង Auto-Collect វត្ថុ Sheckles (សម្រាប់ពេលគ្មាន Value/Remote)
local collectBtn = Instance.new("TextButton", frame)
collectBtn.Size = UDim2.new(0, 120, 0, 28)
collectBtn.Position = UDim2.new(0, 10, 0, 125)
collectBtn.BackgroundColor3 = Color3.fromRGB(0,120,200)
collectBtn.Text = "Auto-Collect Objects"
collectBtn.TextColor3 = Color3.new(1,1,1)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 11
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0,5)

collectBtn.MouseButton1Click:Connect(function()
    collectEnabled = not collectEnabled
    if collectEnabled then
        collectBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        collectBtn.Text = "Stop Collect"
        status.Text = "កំពុងប្រមូល Sheckles នៅលើផែនទី..."
        task.spawn(function()
            while collectEnabled do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:lower():match("sheckel") then
                            if (obj.Position - root.Position).Magnitude <= 30 then
                                root.CFrame = obj.CFrame * CFrame.new(0,2,0)
                                task.wait(0.05)
                            end
                        end
                    end
                end
                task.wait(0.3)
            end
            collectBtn.BackgroundColor3 = Color3.fromRGB(0,120,200)
            collectBtn.Text = "Auto-Collect Objects"
        end)
    else
        collectBtn.BackgroundColor3 = Color3.fromRGB(0,120,200)
        collectBtn.Text = "Auto-Collect Objects"
        status.Text = "បានបញ្ឈប់"
    end
end)

-- បិទ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,22,0,22)
closeBtn.Position = UDim2.new(1,-26,0,3)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()
    collectEnabled = false
    gui:Destroy()
end)