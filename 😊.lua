local Players = game:GetService("Players")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local function setShecklesDirect(amount)
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local val = stats:FindFirstChild("Sheckles") or stats:FindFirstChild("Money") or stats:FindFirstChildWhichIsA("NumberValue")
        if val then
            val.Value = val.Value + amount
            return true
        end
    end
    return false
end

-- GUI តូច
local gui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,100)
frame.Position = UDim2.new(0.5,-100,0.5,-50)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Sheckles Adder"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0,80,0,25)
input.Position = UDim2.new(0,10,0,35)
input.BackgroundColor3 = Color3.fromRGB(60,60,60)
input.TextColor3 = Color3.new(1,1,1)
input.PlaceholderText = "amount"
input.Text = "1000"

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0,70,0,25)
btn.Position = UDim2.new(0,110,0,35)
btn.BackgroundColor3 = Color3.fromRGB(0,170,0)
btn.Text = "Add"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.MouseButton1Click:Connect(function()
    local amt = tonumber(input.Text)
    if not amt then return end
    if setShecklesDirect(amt) then
        title.Text = "✅ Added "..amt
    else
        title.Text = "❌ Could not set Sheckles directly"
    end
end)