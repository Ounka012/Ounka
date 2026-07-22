local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- ផ្ទះរបស់អ្នក (TP មកទីនេះវិញ)
local HOME = Vector3.new(0, 10, 0) -- ប្ដូរដោយឈរនៅផ្ទះរួច print(root.Position)

-- រកដំណាំអ្នកដទៃ (មាន Owner)
local function getEnemyPlants()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            -- ពិនិត្យម្ចាស់តាមរយៈ Attribute "Owner" (ថ្មី)
            local owner = obj:GetAttribute("Owner")
            if not owner then
                -- រក ObjectValue ឈ្មោះ "Owner"
                local ownVal = obj:FindFirstChild("Owner")
                if ownVal and ownVal:IsA("StringValue") then
                    owner = ownVal.Value
                elseif ownVal and ownVal:IsA("ObjectValue") and ownVal.Value then
                    owner = ownVal.Value.Name
                end
            end
            -- ប្រសិនបើមានម្ចាស់ ហើយមិនមែនជាយើង
            if owner and owner ~= player.Name and owner ~= tostring(player.UserId) then
                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    table.insert(found, {model = obj, primaryPart = primaryPart, owner = owner})
                end
            end
        end
    end
    return found
end

-- លួចដំណាំមួយ (រក Prompts ណាដែលមានអក្សរ "steal")
local function stealPlant(plantData)
    local model = plantData.model
    local primaryPart = plantData.primaryPart
    local stealPrompt = nil

    -- ស្កេនកូនទាំងអស់របស់ Model ដើម្បីរក ProximityPrompt
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local action = child.ActionText:lower()
            local nameLower = child.Name:lower()
            if action:find("steal") or nameLower:find("steal") then
                stealPrompt = child
                break
            end
        end
    end

    if not stealPrompt then
        warn("❌ មិនឃើញ Prompt 'Steal' នៅក្នុង " .. model.Name)
        return false
    end

    -- TP ទៅពីលើដំណាំ (5 studs ពីលើ ដើម្បីក្នុងរង្វង់)
    root.CFrame = CFrame.new(primaryPart.Position + Vector3.new(0, 5, 0))
    task.wait(0.1)

    -- បើ Prompt មិនទាន់ដំណើរការ បើកវា
    if not stealPrompt.Enabled then
        stealPrompt.Enabled = true
        task.wait(0.2)
    end

    -- ចាប់ផ្ដើមសង្កត់ (1.5 វិនាទីសម្រាប់ភាពយឺត អាចកែបាន)
    stealPrompt:InputHoldBegin()
    task.wait(1.5)
    stealPrompt:InputHoldEnd()
    return true
end

-- ស្ក្រីបសំខាន់
print("🎯 កំពុងស្វែងរកដំណាំអ្នកដទៃ...")
local enemyPlants = getEnemyPlants()
print("✅ រកឃើញ " .. #enemyPlants .. " ដំណាំ")

if #enemyPlants == 0 then
    print("⚠️ គ្មានដំណាំគេទេ សូមពិនិត្យថាមានដំណាំដែលអាចលួចបាន")
end

for i, plantData in ipairs(enemyPlants) do
    print("🔍 កំពុងលួច " .. plantData.model.Name .. " (ម្ចាស់: " .. plantData.owner .. ")")
    local success = stealPlant(plantData)
    if success then
        print("✅ លួចបានហើយ!")
    else
        print("❌ បរាជ័យ")
    end
    -- មកផ្ទះវិញ
    root.CFrame = CFrame.new(HOME)
    task.wait(0.3)
end
print("🏁 ចប់!")