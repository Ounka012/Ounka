--========================================================
-- SHECKLES REMOTE DETECTOR (Listener + Auto-Fire Test)
--========================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local shecklesValue = nil
local detectedRemotes = {}    -- ចំណាំ Remotes ដែលបានសាកហើយ កុំឲ្យបាញ់ដដែលៗគ្មានប្រយោជន៍
local lastValue = 0

-- មុខងារស្វែងរក Sheckles Value
local function findShecklesValue()
    -- វិធី ១: ក្នុង leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if (v:IsA("NumberValue") or v:IsA("IntValue")) and v.Name:lower():find("sheckel") then
                return v
            end
        end
    end
    -- វិធី ២: គ្រប់កូនក្នុង Player
    for _, v in pairs(player:GetDescendants()) do
        if (v:IsA("NumberValue") or v:IsA("IntValue")) and v.Name:lower():find("sheckel") then
            return v
        end
    end
    return nil
end

-- មុខងាររក RemoteEvent ទាំងអស់ (ពី ReplicatedStorage, Workspace)
local function getAllRemotes()
    local remotes = {}
    local services = {ReplicatedStorage, Workspace, game:GetService("ServerStorage")}
    for _, service in ipairs(services) do
        for _, obj in pairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

-- បង្កើត GUI
local function createGUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "ShecklesListener"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 140)
    frame.Position = UDim2.new(0.5, -150, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    frame.BorderSizePixel = 0
    frame.Draggable = true
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,25)
    title.BackgroundTransparency = 1
    title.Text = "🔔 Sheckles Listener"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255,215,0)

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1,-20,0,50)
    status.Position = UDim2.new(0,10,0,28)
    status.BackgroundTransparency = 1
    status.Text = "ស្ថានភាព៖ រក Value..."
    status.TextColor3 = Color3.new(1,1,1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextWrapped = true

    local startBtn = Instance.new("TextButton", frame)
    startBtn.Size = UDim2.new(0, 120, 0, 30)
    startBtn.Position = UDim2.new(0, 15, 0, 90)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    startBtn.Text = "ចាប់ផ្ដើមស្ដាប់"
    startBtn.TextColor3 = Color3.new(1,1,1)
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 11
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

    local stopBtn = Instance.new("TextButton", frame)
    stopBtn.Size = UDim2.new(0, 100, 0, 30)
    stopBtn.Position = UDim2.new(0, 150, 0, 90)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    stopBtn.Text = "បញ្ឈប់"
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 11
    Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)

    local connection = nil

    startBtn.MouseButton1Click:Connect(function()
        if connection then return end -- បើកំពុងដំណើរការហើយ មិនធ្វើអ្វី
        shecklesValue = findShecklesValue()
        if not shecklesValue then
            status.Text = "❌ រកមិនឃើញ Sheckles Value"
            return
        end
        lastValue = shecklesValue.Value
        status.Text = "✅ បានរកឃើញ Value\nកំពុងស្ដាប់ការប្រែប្រួល..."
        connection = shecklesValue.Changed:Connect(function(newValue)
            if newValue > lastValue then
                local diff = newValue - lastValue
                print("🔔 Sheckles កើនឡើង " .. diff .. " (ពី " .. lastValue .. " ទៅ " .. newValue .. ")")
                status.Text = "លុយឡើង " .. diff .. "!\nកំពុងរក Remote..."
                local allRemotes = getAllRemotes()
                for _, remote in ipairs(allRemotes) do
                    if not detectedRemotes[remote] then
                        detectedRemotes[remote] = true
                        print("សាកបាញ់ Remote: " .. remote.Name)
                        pcall(function()
                            remote:FireServer(diff)
                            -- ក៏អាចសាកជាមួយ player, diff
                            remote:FireServer(player, diff)
                        end)
                    end
                end
                lastValue = newValue
            else
                lastValue = newValue
            end
        end)
    end)

    stopBtn.MouseButton1Click:Connect(function()
        if connection then
            connection:Disconnect()
            connection = nil
            status.Text = "⏹ បានបញ្ឈប់ការស្ដាប់"
        end
    end)

    -- បិទ GUI
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0,22,0,22)
    closeBtn.Position = UDim2.new(1,-26,0,2)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 10
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function()
        if connection then connection:Disconnect() end
        gui:Destroy()
    end)
end

createGUI()
print("✅ Sheckles Listener GUI បានផ្ទុក")