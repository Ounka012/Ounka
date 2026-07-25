local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui") 
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--=============================================
-- 1. ទាញយករូបភាពព្រះច័ន្ទពីលីងរបស់អ្នក
--=============================================
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg_custom_hub.jpg"
local finalImage = ""

local success, response = pcall(function() 
    return request({Url=IMAGE_URL, Method="GET"}) 
end)

if success and response and response.StatusCode == 200 then
    writefile(FILE_NAME, response.Body)
    finalImage = getcustomasset(FILE_NAME)
end

--=============================================
-- 2. ការកំណត់ GUI ដើមរបស់អ្នក
--=============================================
if CoreGui:FindFirstChild("CustomCombatGUI") then
    CoreGui:FindFirstChild("CustomCombatGUI"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomCombatGUI"
screenGui.ResetOnSpawn = false 
screenGui.Parent = CoreGui 

-- Main Frame (ផ្ទាំងធំបន្តិចដើម្បីដាក់ប៊ូតុង ៣)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 200) 
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- Background Image (រូបព្រះច័ន្ទ)
local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = finalImage 
bgImage.ScaleType = Enum.ScaleType.Stretch
bgImage.ImageTransparency = 0.4 
bgImage.ZIndex = 0
bgImage.Parent = mainFrame

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(0, 12)
imgCorner.Parent = bgImage

-- Title (ចំណងជើង)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "COMBAT HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.ZIndex = 1
titleLabel.Parent = mainFrame

--=============================================
-- 3. បង្កើតប៊ូតុង និង អថេរសម្រាប់កំណត់មុខងារ
--=============================================
local settings = {
    KillAura = false,
    KillNPCs = false,
    KillMobs = false
}

-- មុខងារជំនួយសម្រាប់បង្កើតប៊ូតុង
local function createToggleButton(name, yPos, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- ពណ៌ក្រហម (OFF)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 1
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        if settings[settingKey] then
            btn.Text = name .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- ពណ៌បៃតង (ON)
        else
            btn.Text = name .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- ពណ៌ក្រហម (OFF)
        end
    end)
end

-- បង្កើតប៊ូតុងទាំង ៣
createToggleButton("Kill Aura", 45, "KillAura")
createToggleButton("Kill NPCs", 90, "KillNPCs")
createToggleButton("Kill Mobs", 135, "KillMobs")

--=============================================
-- 4. ដំណើរការមុខងារ (Logic Loops)
--=============================================
local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

RunService.Heartbeat:Connect(function()
    local root = getRootPart()
    if not root then return end

    -- 1. Kill Aura (សម្រាប់ Player)
    if settings.KillAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local eHum = plr.Character:FindFirstChild("Humanoid")
                local eRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                
                if eHum and eRoot and eHum.Health > 0 then
                    if (root.Position - eRoot.Position).Magnitude <= 30 then
                        pcall(function() eHum:TakeDamage(30) end)
                    end
                end
            end
        end
    end

    -- 2. Kill Aura (សម្រាប់ NPCs ទូទៅក្នុង Workspace)
    if settings.KillNPCs then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                local eHum = obj:FindFirstChild("Humanoid")
                local eRoot = obj:FindFirstChild("HumanoidRootPart")
                
                if eHum and eRoot and eHum.Health > 0 then
                    if (root.Position - eRoot.Position).Magnitude <= 30 then
                        pcall(function() 
                            eHum.Health = math.max(0, eHum.Health - 30) 
                        end)
                    end
                end
            end
        end
    end

    -- 3. Kill Mobs (សម្រាប់វាយ Mob ក្នុង Folder "Mobs" តាមរយៈ Remote)
    if settings.KillMobs then
        local folder = Workspace:FindFirstChild("Mobs")
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local mRoot = mob:FindFirstChild("HumanoidRootPart")
                local mHum = mob:FindFirstChild("Humanoid")
                
                if mRoot and mHum and mHum.Health > 0 then
                    if (root.Position - mRoot.Position).Magnitude < 25 then
                        pcall(function()
                            if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Attack") then
                                ReplicatedStorage.Events.Attack:FireServer(mHum)
                            end
                        end)
                    end
                end
            end
        end
    end
end)
