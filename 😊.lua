--========================================================
-- EVADE: BUBBLE ADDER (REMOTE FIRE, LIKE SHECKLES)
--========================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local bubbleRemote = nil

-- មុខងារស្កេនរក Remote ដែលប្រើសម្រាប់បន្ថែម Bubble
local function scanForRemote()
    local keywords = {"bubble", "token", "collect", "add", "give", "reward", "coin"}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage")}
    for _, service in ipairs(services) do
        for _, obj in pairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- ស្កេនដំបូង
bubbleRemote = scanForRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "EvadeBubbleAdder"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 150)
frame.Position = UDim2.new(0.5, -140, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "🫧 Bubble Adder (Remote)"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(100,200,255)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 30)
status.BackgroundTransparency = 1
status.Text = bubbleRemote and "✅ រកឃើញ Remote: "..bubbleRemote.Name or "❌ រកមិនឃើញ Remote"
status.TextColor3 = bubbleRemote and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0, 80, 0, 28)
input.Position = UDim2.new(0, 10, 0, 70)
input.BackgroundColor3 = Color3.fromRGB(50,50,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.PlaceholderText = "10"
input.Text = "10"
Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0, 100, 0, 28)
addBtn.Position = UDim2.new(0, 100, 0, 70)
addBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
addBtn.Text = "បន្ថែម"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,5)

addBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(input.Text)
    if not amount or amount <= 0 then
        status.Text = "បញ្ចូលចំនួនត្រឹមត្រូវ"
        return
    end
    if not bubbleRemote then
        status.Text = "គ្មាន Remote សូមស្កេនឡើងវិញ"
        return
    end

    -- បាញ់ Remote ជាមួយចំនួន
    local success = false
    if bubbleRemote:IsA("RemoteEvent") then
        -- សាកបាញ់ជាមួយ amount និង player
        success = pcall(function() bubbleRemote:FireServer(amount) end)
        if not success then
            success = pcall(function() bubbleRemote:FireServer(LocalPlayer, amount) end)
        end
        if not success then
            success = pcall(function() bubbleRemote:FireServer({Amount = amount}) end)
        end
    elseif bubbleRemote:IsA("RemoteFunction") then
        success = pcall(function() bubbleRemote:InvokeServer(amount) end)
        if not success then
            success = pcall(function() bubbleRemote:InvokeServer(LocalPlayer, amount) end)
        end
    end

    if success then
        status.Text = "✅ បាញ់ Remote ជាមួយ "..amount.." Bubble"
    else
        status.Text = "❌ បរាជ័យ សូមពិនិត្យ Remote ដោយ RemoteSpy"
    end
end)

-- ប៊ូតុងស្កេនឡើងវិញ
local scanBtn = Instance.new("TextButton", frame)
scanBtn.Size = UDim2.new(0, 100, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 110)
scanBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
scanBtn.Text = "ស្កេនថ្មី"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 11
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0,5)
scanBtn.MouseButton1Click:Connect(function()
    bubbleRemote = scanForRemote()
    if bubbleRemote then
        status.Text = "✅ រកឃើញ Remote: "..bubbleRemote.Name
    else
        status.Text = "❌ មិនឃើញ Remote – សាកប្រើ RemoteSpy ពេលប្រមូល Bubble ដោយដៃ"
    end
end)

-- បិទ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,22,0,22)
closeBtn.Position = UDim2.new(1,-26,0,2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)