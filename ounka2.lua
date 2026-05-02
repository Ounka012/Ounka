-- ==================== GUI BUTTON (Mobile Optimized) ====================
local function createToggleButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MyScriptUI"
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 50)  -- ធំបន្តិចងាយប៉ះ
    btn.Position = UDim2.new(0, 10, 0, 10)
    btn.Text = "Kill Bosses: OFF"
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = gui

    -- អថេរចងចាំស្ថានភាព
    local kbEnabled = Settings.KillBosses

    -- ប្រើ Activated ជំនួស MouseButton1Click សម្រាប់ Touch
    btn.Activated:Connect(function()
        kbEnabled = not kbEnabled
        Settings.KillBosses = kbEnabled
        toggleKillBosses()
        if kbEnabled then
            btn.Text = "Kill Bosses: ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.Text = "Kill Bosses: OFF"
            btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end
