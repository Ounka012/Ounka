local ws = workspace
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char.HumanoidRootPart

local height = 80
local radius = 20
local angle = 0

-- រក Bubble (Model ណាដែលមានឈ្មោះ "bubble" ហើយយក BasePart)
local function getBubbles()
    local bubbles = {}
    for _, obj in ws:GetDescendants() do
        if obj.Name:lower():find("bubble") and obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(bubbles, part)
            end
        end
    end
    return bubbles
end

-- ហោះទៅកាន់ទីតាំង (រលូន)
local function fly(pos)
    local startPos = root.Position
    local distance = (startPos - pos).Magnitude
    if distance < 3 then return end

    local steps = math.ceil(distance / 10 + 2)
    for t = 0, 1, 1 / steps do
        root.CFrame = CFrame.new(startPos:Lerp(pos, t))
        task.wait(0.02)
    end
    root.CFrame = CFrame.new(pos)
end

-- Main loop
while task.wait(0.1) do
    -- គណនាទីតាំងវង់ (កណ្តាលផែនទី 0,0 បើមិនត្រូវ កែទីនេះ)
    local x = math.cos(math.rad(angle)) * radius
    local z = math.sin(math.rad(angle)) * radius
    fly(Vector3.new(x, height, z))

    -- ស្វែងរក Bubble ក្នុងរង្វង់ 50 studs
    for _, b in getBubbles() do
        if (b.Position - root.Position).Magnitude <= 50 then
            fly(b.Position + Vector3.new(0, height / 2, 0))
            -- តោងជាប់រហូតដល់ Bubble បាត់
            repeat
                root.CFrame = b.CFrame * CFrame.new(0, 2.5, 0)
                task.wait(0.05)
            until not b.Parent
        end
    end

    angle = (angle + 25) % 360
    radius = radius + 15
    if radius > 150 then
        radius = 20
    end
end