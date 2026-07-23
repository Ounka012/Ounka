local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ស្វែងរក RemoteEvent ដែលអាចជា Sheckles (ពិនិត្យឈ្មោះឲ្យបានច្រើន)
local function autoFindRemote()
    local keywords = {
        "sheckel", "sheckles", "money", "cash", "coin", "currency",
        "reward", "give", "addmoney", "addsheckles", "shekel"
    }
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    return obj
                end
            end
        end
    end
    return nil
end

local remote = autoFindRemote()

-- បង្កើត GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "AutoSheckles"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 140)
frame.Position = UDim2.new(0.5, -115, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
frame.Draggable = true
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "💰 Sheckles Adder (Auto)"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(255,215,0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -10, 0, 20)
status.Position = UDim2.new(0, 5, 0, 28)
status.BackgroundTransparency = 1
status.Text = remote and ("✅ រកឃើញ: " .. remote.Name) or "❌ រកមិនឃើញ Remote"
status.TextColor3 = remote and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 100, 0, 28)
input.Position = UDim2.new(0, 10, 0, 58)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "ចំនួន"
input.Text = "1000"
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 5)

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 90, 0, 28)
addBtn.Position = UDim2.new(0, 120, 0, 58)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
addBtn.Text = "បន្ថែម"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 5)

addBtn.MouseButton1Click:Connect(function()
    if not remote then
        status.Text = "❌ រកមិនឃើញ Remote! សូមប្រាប់ខ្ញុំពីឈ្មោះ Remote ដែលបានឃើញក្នុង RemoteSpy"
        return
    end
    local amount = tonumber(input.Text)
    if not amount or amount <= 0 then
        status.Text = "❌ បញ្ចូលចំនួនត្រឹមត្រូវ"
        return
    end

    -- សាកបាញ់តាមវិធីផ្សេងៗ
    local success = false
    success = pcall(function() remote:FireServer(amount) end)
    if not success then
        success = pcall(function() remote:FireServer(Players.LocalPlayer, amount) end)
    end
    if not success then
        success = pcall(function() remote:FireServer("Sheckles", amount) end)
    end

    if success then
        status.Text = "✅ បានបន្ថែម " .. amount .. " Sheckles"
    else
        status.Text = "❌ បរាជ័យ។ សូមពិនិត្យឈ្មោះ Remote ឬប្រើ RemoteSpy"
    end
end)

-- បិទ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0, 2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)