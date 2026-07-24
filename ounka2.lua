local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui") 
local ContentProvider = game:GetService("ContentProvider")

local plr = Players.LocalPlayer

--============ ការកំណត់ GUI និងរូបភាព ============
local IMAGE_URL = "rbxassetid://13583271707" 

if CoreGui:FindFirstChild("BubbleFinderGUI") then
    CoreGui:FindFirstChild("BubbleFinderGUI"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BubbleFinderGUI"
screenGui.ResetOnSpawn = false 
screenGui.Parent = CoreGui 

-- Main Frame (ផ្ទាំងធំ)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- Background Image (រូបភាពខាងក្រោយ)
local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = IMAGE_URL
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
titleLabel.Text = "BUBBLE FINDER"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.ZIndex = 1
titleLabel.Parent = mainFrame

-- Toggle Button (ប៊ូតុងបិទ/បើក)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
toggleBtn.Text = "STATUS: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.ZIndex = 1
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

--============ 2. អថេរគ្រប់គ្រងស្ថានភាព ============
local isRunning = false

--============ 3. មុខងារផ្លាស់ប្តូរ ON/OFF ============
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "STATUS: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
    else
        toggleBtn.Text = "STATUS: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
    end
end)

--============ 4. កូដដើមរបស់អ្នក (Logic) ============
local function getBubbles()
    local bubbles = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("bubble") and obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(bubbles, part)
            end
        end
    end
    return bubbles
end

local function fly(root, pos)
    if not root then return end
    local startPos = root.Position
    local distance = (startPos - pos).Magnitude
    if distance < 3 then return end

    local steps = math.ceil(distance / 10 + 2)
    for t = 0, 1, 1 / steps do
        if not isRunning or not root.Parent then break end
        root.CFrame = CFrame.new(startPos:Lerp(pos, t))
        task.wait(0.02)
    end
    if isRunning and root.Parent then
        root.CFrame = CFrame.new(pos)
    end
end

-- មុខងាររកដីនៅខាងក្រោម Bubble
local function getGroundPosition(char, startPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    -- បាញ់រលកចុះក្រោម 500 ម៉ែត្រ ដើម្បីរកដី
    local raycastResult = Workspace:Raycast(startPos, Vector3.new(0, -500, 0), raycastParams)
    
    if raycastResult then
        return raycastResult.Position
    else
        -- បើរករអត់ឃើញដីទេ យកកម្ពស់ទាបជាង Bubble បន្តិចសិន
        return startPos - Vector3.new(0, 30, 0)
    end
end

--============ 5. Main Loop ============
task.spawn(function()
    local height = 80
    local radius = 20
    local angle = 0

    while true do
        task.wait(0.1)

        if isRunning then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root then
                local x = math.cos(math.rad(angle)) * radius
                local z = math.sin(math.rad(angle)) * radius
                local targetCirclePos = Vector3.new(x, height, z)
                
                fly(root, targetCirclePos)

                local bubbles = getBubbles()
                for _, b in ipairs(bubbles) do
                    if not isRunning or not root.Parent then break end
                    
                    if b and b.Parent and (b.Position - root.Position).Magnitude <= 50 then
                        
                        -- ទី១៖ រកទីតាំងដីនៅក្រោម Bubble រួចហោះទៅឈប់នៅទីនោះសិន
                        local groundPos = getGroundPosition(char, b.Position)
                        fly(root, groundPos + Vector3.new(0, 3, 0)) -- ហោះទៅដី (បូក 3 studs កុំឲ្យកប់ដី)
                        
                        -- រង់ចាំនៅលើដីសិន (អ្នកអាចដូរលេខ 1.5 នេះទៅតាមការចង់បាន ឧទាហរណ៍ 1 វិនាទី ឬ 2 វិនាទី)
                        task.wait(1.5) 
                        
                        if not isRunning or not root.Parent or not b.Parent then break end
                        
                        -- ទី២៖ បន្ទាប់ពីរង់ចាំចប់ ហោះឡើងទៅសុី Bubble តែម្តង
                        fly(root, b.Position + Vector3.new(0, 2.5, 0))
                        
                        repeat
                            if not isRunning or not root.Parent or not b.Parent then break end
                            root.CFrame = b.CFrame * CFrame.new(0, 2.5, 0)
                            task.wait(0.05)
                        until not b.Parent or not isRunning or not root.Parent
                    end
                end

                angle = (angle + 25) % 360
                radius = radius + 15
                if radius > 150 then
                    radius = 20
                end
            end
        end
    end
end)

pcall(function()
    ContentProvider:PreloadAsync({Instance.new("ImageLabel", {Image = IMAGE_URL})})
end)