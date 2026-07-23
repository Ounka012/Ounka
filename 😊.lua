-- ស្កេនរក Remote ដែលអាចជា Backdoor (Give/Add item)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function tryAllRemotes()
    local itemNames = {"Dragon's Breath", "DragonBreath", "Dragon Breath", "Dragon Seed"}
    local keywords = {"give", "add", "grant", "item", "backdoor", "admin", "reward", "inventory", "additem", "giveitem"}
    
    for _, service in ipairs({ReplicatedStorage, Workspace, game:GetService("ServerStorage")}) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    -- ពិនិត្យឈ្មោះ Remote ប្រសិនបើមានពាក្យគន្លឹះ
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then
                            print("សាក Remote ដែលគួរឲ្យសង្ស័យ: " .. obj.Name)
                            for _, item in ipairs(itemNames) do
                                -- សាកបាញ់ជាមួយទម្រង់ Argument ច្រើន
                                if obj:IsA("RemoteEvent") then
                                    pcall(function() obj:FireServer(item, 1) end)
                                    pcall(function() obj:FireServer(LocalPlayer, item, 1) end)
                                    pcall(function() obj:FireServer({Item=item, Amount=1}) end)
                                elseif obj:IsA("RemoteFunction") then
                                    pcall(function() obj:InvokeServer(item, 1) end)
                                    pcall(function() obj:InvokeServer(LocalPlayer, item, 1) end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

tryAllRemotes()
print("បានព្យាយាមគ្រប់ Remote ដែលអាចទាក់ទងនឹងការផ្តល់ឥវ៉ាន់")
