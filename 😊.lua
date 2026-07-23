local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ស្វែងរក Remote ដែលមានឈ្មោះ Sheckles
local function findRemote()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("sheckel") then
            return obj
        end
    end
    return nil
end

local remote = findRemote()

-- បង្កើត GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ShecklesGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.5, -110, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
frame.Draggable = true
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "💰 Sheckles Hack"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1, 215/255, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,0,30)
status.BackgroundTransparency = 1
status.Text = remote and "Remote រកឃើញ" or "រកមិនឃើញ Remote"
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 10

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 100, 0, 30)
input.Position = UDim2.new(0, 10, 0, 60)
input.BackgroundColor3 = Color3.fromRGB(60,60,60)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 13
input.PlaceholderText = "ចំនួន"
input.Text = "1000"
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 5)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 80, 0, 30)
btn.Position = UDim2.new(0, 120, 0, 60)
btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
btn.Text = "ADD"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    if not remote then
        status.Text = "រកមិនឃើញ Remote!"
        return
    end
    local amount = tonumber(input.Text)
    if not amount or amount <= 0 then
        status.Text = "បញ្ចូលលេខ"
        return
    end
    -- សាកបាញ់ Remote តាមរបៀបផ្សេងៗ
    local ok = pcall(function() remote:FireServer(amount) end)
    if not ok then
        ok = pcall(function() remote:FireServer(Players.LocalPlayer, amount) end)
    end
    if not ok then
        ok = pcall(function() remote:FireServer("Sheckles", amount) end)
    end
    if ok then
        status.Text = "✅ បានបន្ថែម " .. amount
    else
        status.Text = "❌ បរាជ័យ សូមពិនិត្យឈ្មោះ Remote"
    end
end)

-- ប៊ូតុងបិទ
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 22, 0, 22)
close.Position = UDim2.new(1, -26, 0, 2)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 10
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function() gui:Destroy() end)