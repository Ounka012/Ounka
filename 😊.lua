-- Grow a Garden 2: Remote Finder & Buyer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- បង្ហាញឈ្មោះ Remote ទាំងអស់
print("========== ឈ្មោះ Remote ទាំងអស់ ==========")
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        print("RemoteEvent: " .. obj.Name .. " (Path: " .. obj:GetFullName() .. ")")
    elseif obj:IsA("RemoteFunction") then
        print("RemoteFunction: " .. obj.Name .. " (Path: " .. obj:GetFullName() .. ")")
    end
end
print("========== ប្រើឈ្មោះណាមួយដាក់ក្នុងអថេរ remoteName ខាងក្រោម ==========")

-- ដាក់ឈ្មោះ Remote ដែលអ្នកគិតថាជាហាង (ឧ. "BuyItem", "PurchaseSeed")
-- អ្នកអាចសាកឈ្មោះជាច្រើនដោយប្តូរតម្លៃនេះ
local remoteName = "BuyItem" -- ប្ដូរតាមអ្វីដែលអ្នកបានឃើញពី Console

local remote = ReplicatedStorage:FindFirstChild(remoteName)
if not remote then
    -- សាករកក្នុងកូនៗទាំងអស់ជាថ្មី
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == remoteName then
            remote = obj
            break
        end
    end
end

if not remote then
    print("❌ រកមិនឃើញ Remote ឈ្មោះ " .. remoteName)
    print("សូមជ្រើសរើសឈ្មោះពីបញ្ជីខាងលើ ហើយប្តូរ remoteName")
    return
end

-- ឈ្មោះគ្រាប់ពូជ Dragon's Breath (សាកទាំងនេះ)
local itemNames = {
    "Dragon's Breath",
    "Dragon's Breath Seed",
    "DragonBreath",
    "Dragon Breath",
    "Dragon Seed",
    "DragonFruit Seed",
}

-- ព្យាយាមទិញដោយបាញ់ Remote ជាមួយឈ្មោះនីមួយៗ
for _, itemName in ipairs(itemNames) do
    print("កំពុងសាកទិញ៖ " .. itemName)
    local success = false
    -- សាក Argument ច្រើនទម្រង់
    local argsList = {
        {itemName},
        {itemName, 1},
        {player, itemName, 1},
        {itemName, player},
        {{Item = itemName, Quantity = 1}},
    }
    for _, args in ipairs(argsList) do
        if remote:IsA("RemoteEvent") then
            success = pcall(function() remote:FireServer(unpack(args)) end)
        elseif remote:IsA("RemoteFunction") then
            success = pcall(function() remote:InvokeServer(unpack(args)) end)
        end
        if success then
            print("✅ ទិញបាន! ឈ្មោះគ្រាប់ពូជ៖ " .. itemName .. " ដោយប្រើ Remote " .. remoteName)
            return
        end
    end
    task.wait(0.2)
end

print("❌ គ្មានឈ្មោះណាត្រូវ សាកប្តូរ remoteName ឬពិនិត្យហាង")
