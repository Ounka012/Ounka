-- SHECKLES INSTANT ADDER (Direct Value Set)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ស្វែងរកទីតាំងដែលរក្សាទុក Sheckles
local function findShecklesValue()
    -- ស្កេនក្នុង leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                if v.Name:lower():find("sheckel") then
                    return v
                end
            end
        end
    end

    -- ស្កេនក្នុង Player ផ្ទាល់
    for _, v in pairs(player:GetChildren()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            if v.Name:lower():find("sheckel") then
                return v
            end
        end
    end

    -- ស្កេនក្នុង PlayerGui (ពេលខ្លះដាក់នៅទីនោះ)
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, v in pairs(playerGui:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                if v.Name:lower():find("sheckel") then
                    return v
                end
            end
        end
    end

    return nil
end

local shecklesValue = findShecklesValue()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesAdder"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 120)
frame.Position = UDim2.new(0.5, -115, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(35,35,40)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "💰 Sheckles Adder"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,30)
status.BackgroundTransparency = 1
status.Text = shecklesValue and "✅ រកឃើញ Sheckles" or "❌ រកមិនឃើញ"
status.TextColor3 = shecklesValue and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
status.Font = Enum.Font.Gotham
status.TextSize = 10

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 90, 0, 28)
input.Position = UDim2.new(0, 10, 0, 58)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "1000"
input.Text = "1000"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 90, 0, 28)
addBtn.Position = UDim2.new(0, 115, 0, 58)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
addBtn.Text = "ADD"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,5)

addBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(input.Text)
    if not amount or amount <= 0 then
        status.Text = "❌ បញ្ចូលចំនួនត្រឹមត្រូវ"
        return
    end
    if not shecklesValue then
        status.Text = "❌ រកមិនឃើញ Sheckles"
        return
    end

    -- ព្យាយាមផ្លាស់ប្ដូរតម្លៃផ្ទាល់
    pcall(function()
        shecklesValue.Value = shecklesValue.Value + amount
        status.Text = "✅ បានបន្ថែម " .. amount
    end)
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
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)