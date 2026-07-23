local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- កំណត់ទីតាំង Sheckles Value ដែលបងបានរកឃើញ (ប្តូរឈ្មោះឲ្យត្រូវ)
local shecklesValue = player:WaitForChild("leaderstats"):FindFirstChild("Sheckles") -- ឧទាហរណ៍

if not shecklesValue then
    -- បើមិននៅក្នុង leaderstats សូមរកដោយខ្លួនឯង
    for _, v in pairs(player:GetDescendants()) do
        if v:IsA("NumberValue") and v.Name:lower():find("sheckel") then
            shecklesValue = v
            break
        end
    end
end

if not shecklesValue then
    print("❌ រកមិនឃើញ Sheckles Value")
    return
end

local lastValue = shecklesValue.Value
local detectedRemotes = {}

-- ត្រួតពិនិត្យការផ្លាស់ប្ដូរ Value
shecklesValue.Changed:Connect(function(newValue)
    if newValue > lastValue then
        print("✅ Sheckles កើនឡើងពី " .. lastValue .. " ទៅ " .. newValue)
        -- ស្វែងរក Remote ដែលបានបាញ់នៅពេលនេះ (ប្រើវិធីសាមញ្ញ)
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and not detectedRemotes[remote] then
                -- យើងមិនអាចដឹងថាមួយណាពិតប្រាកដ ប៉ុន្តែសាកបាញ់វាដើម្បីមើល
                print("កំពុងសាក Remote: " .. remote.Name)
                pcall(function()
                    remote:FireServer(newValue - lastValue) -- បាញ់ចំនួនដែលកើន
                    -- រង់ចាំមើលថាតើ Value ផ្លាស់ប្ដូរម្ដងទៀតឬអត់
                end)
            end
        end
    end
    lastValue = newValue
end)

print("🔔 កំពុងស្ដាប់ការផ្លាស់ប្ដូរ Sheckles...")