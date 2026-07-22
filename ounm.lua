local ws = workspace
local plr = game.Players.LocaPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char.HumanoidRootPart

local height = 80
local redius = 20
local angle = 0

local function getBubblees()
    local bubbles()
    for _, odj in ws:GetDescendants() do
        if odj.Name:lower():find("bubble") and odj:IsA("Model") then
             local part = odj.PrimaryPart or odj:FindFirstChildWhichIsA("BasePart")
                    table.insert(bubbles, part)
                end
            end
        end
         return bubbles

local function fly(pos)
    local startPos = root.Position
    local distance = (startPos - pos).Magnitude
    if distance < 3 then return end
    local steps = math.ceil(distance / 10 + 2)

     for t = 0, 1, 1 / steps do
          root.Cframe = Cfe.new(startPot:Lerp(pot, t))
          taks.wait(0.02)
          end
          root.Cfame = Cfame.new(pot)
     end






