local RemoteName = "REPLACE_ME" -- ឧ. "AddSheckles"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local remote = ReplicatedStorage:FindFirstChild(RemoteName)
if not remote then
    -- សាករកក្នុងកន្លែងផ្សេង (Workspace, etc.)
    remote = game:GetService("Workspace"):FindFirstChild(RemoteName)
end

local gui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,100)
frame.Position = UDim2.new(0.5,-100,0.5,-50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.Draggable = true
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = remote and "Found: "..RemoteName or "Remote not found"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0,80,0,25)
input.Position = UDim2.new(0,10,0,35)
input.BackgroundColor3 = Color3.fromRGB(60,60,60)
input.TextColor3 = Color3.new(1,1,1)
input.Text = "1000"

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0,70,0,25)
btn.Position = UDim2.new(0,110,0,35)
btn.BackgroundColor3 = Color3.fromRGB(0,170,0)
btn.Text = "Add"
btn.TextColor3 = Color3.new(1,1,1)
btn.MouseButton1Click:Connect(function()
    if not remote then return end
    local amt = tonumber(input.Text) or 0
    if remote:IsA("RemoteEvent") then
        remote:FireServer(amt)
    elseif remote:IsA("RemoteFunction") then
        remote:InvokeServer(amt)
    end
end)