-- [Lukezz Hubbb Mobile Edition by Exunys © CC0 1.0 Universal (2025)]
-- Adapted from https://github.com/Exunys/AirHub-V2/blob/main/src/Main.lua
-- Mobile-friendly version with no key system. For educational use only.

local game = game
local loadstring = loadstring or loadstring
local typeof = typeof
local select = select
local next = next
local pcall = pcall
local tablefind = table.find
local tablesort = table.sort
local mathfloor = math.floor
local stringgsub = string.gsub
local wait, delay, spawn = task.wait, task.delay, task.spawn
local osdate = os.date

-- Loading external dependencies (simplified for mobile)
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Roblox-Functions-Library/main/Library.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub-V2/main/src/UI%20Library.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Exunys-ESP/main/src/ESP.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
end)
if not success then warn("Failed to load dependencies: " .. err) return end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Initialize settings with mobile adjustments
local ESP = {
    DeveloperSettings = { Debug = false },
    Settings = {
        Enabled = false,
        LoadConfigOnLaunch = false,
        TeamCheck = false,
        VisibleCheck = true,
        DistanceCheck = true,
        MaxDistance = 500,
        RefreshRate = 0.1
    },
    Properties = {
        Box = { Enabled = false, Thickness = 1, Color = Color3.fromRGB(255, 0, 0), Filled = false },
        Name = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Font = 2 },
        HealthBar = { Enabled = false, Outline = true, Color = Color3.fromRGB(0, 255, 0) },
        Tracer = { Enabled = false, Position = "Bottom", Color = Color3.fromRGB(255, 255, 255), Thickness = 1 },
        Crosshair = { Enabled = false, CenterDot = { Enabled = false, Size = 3, Color = Color3.fromRGB(255, 255, 255) } }
    }
}

local Aimbot = {
    DeveloperSettings = { Debug = false },
    Settings = {
        Enabled = false,
        ThirdPerson = false,
        TriggerKey = Enum.KeyCode.Q,
        TeamCheck = false,
        WallCheck = true,
        VisibleCheck = true,
        DistanceCheck = true,
        MaxDistance = 500
    },
    FOVSettings = {
        Enabled = false,
        Radius = 100,
        Sides = 6,
        Transparency = 0.5,
        Color = Color3.fromRGB(255, 255, 255),
        Filled = false,
        Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    }
}

-- Mobile-friendly GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LukezzHubbbMobile"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0) -- Scalable for mobile
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 31, 38)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(34, 41, 51)
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Lukezz Hubbb Mobile"
Title.TextColor3 = Color3.fromRGB(52, 152, 219)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(70, 76, 86)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextSize = 20
CloseButton.Parent = TopBar
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -60)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 10
Content.CanvasSize = UDim2.new(0, 0, 2, 0)
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.Parent = Content

-- Mobile-friendly toggle function
local function CreateToggle(labelText: string, default: boolean, callback: (boolean) -> ())
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(34, 41, 51)
    ToggleFrame.Parent = Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(180, 190, 200)
    Label.TextSize = 18
    Label.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 60, 0, 30)
    ToggleButton.Position = UDim2.new(1, -70, 0.5, -15)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(65, 180, 90) or Color3.fromRGB(70, 76, 86)
    ToggleButton.Text = default and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(245, 247, 250)
    ToggleButton.TextSize = 16
    ToggleButton.Parent = ToggleFrame

    ToggleButton.MouseButton1Click:Connect(function()
        local newState = not (ToggleButton.Text == "ON")
        ToggleButton.Text = newState and "ON" or "OFF"
        ToggleButton.BackgroundColor3 = newState and Color3.fromRGB(65, 180, 90) or Color3.fromRGB(70, 76, 86)
        if callback then callback(newState) end
    end)
end

-- Mobile-friendly slider function
local function CreateSlider(labelText: string, min: number, max: number, default: number, callback: (number) -> ())
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(34, 41, 51)
    SliderFrame.Parent = Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(180, 190, 200)
    Label.TextSize = 18
    Label.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -40, 0, 10)
    Bar.Position = UDim2.new(0, 20, 0, 25)
    Bar.BackgroundColor3 = Color3.fromRGB(42, 50, 62)
    Bar.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    Fill.Parent = Bar

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -70, 0, 20)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(245, 247, 250)
    ValueLabel.TextSize = 16
    ValueLabel.Parent = SliderFrame

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
            local value = mathfloor(min + rel * (max - min))
            Fill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
            ValueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
end

-- Setup UI Tabs
local Tabs = {"ESP", "Aimbot", "Crosshair"}
local CurrentTab = "ESP"

local function SwitchTab(tabName)
    CurrentTab = tabName
    -- Simple tab switching (update UI logic here if using a library)
    print("Switched to tab:", tabName)
end

for _, tab in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1 / #Tabs, -10, 0, 40)
    TabButton.Position = UDim2.new((tablefind(Tabs, tab) - 1) / #Tabs, 10, 0, 10)
    TabButton.BackgroundColor3 = tab == CurrentTab and Color3.fromRGB(42, 50, 62) or Color3.fromRGB(34, 41, 51)
    TabButton.Text = tab
    TabButton.TextColor3 = Color3.fromRGB(180, 190, 200)
    TabButton.TextSize = 18
    TabButton.Parent = TopBar
    TabButton.MouseButton1Click:Connect(function() SwitchTab(tab) end)
end

-- ESP Controls
if CurrentTab == "ESP" then
    CreateToggle("Enabled", ESP.Settings.Enabled, function(v)
        ESP.Settings.Enabled = v
    end)
    CreateToggle("Box", ESP.Properties.Box.Enabled, function(v)
        ESP.Properties.Box.Enabled = v
    end)
    CreateToggle("Filled", ESP.Properties.Box.Filled, function(v)
        ESP.Properties.Box.Filled = v
    end)
    CreateToggle("Name", ESP.Properties.Name.Enabled, function(v)
        ESP.Properties.Name.Enabled = v
    end)
    CreateToggle("Health Bar", ESP.Properties.HealthBar.Enabled, function(v)
        ESP.Properties.HealthBar.Enabled = v
    end)
    CreateToggle("Tracer", ESP.Properties.Tracer.Enabled, function(v)
        ESP.Properties.Tracer.Enabled = v
    end)
    CreateSlider("Max Distance", 100, 1000, ESP.Settings.MaxDistance, function(v)
        ESP.Settings.MaxDistance = v
    end)
end

-- Aimbot Controls
if CurrentTab == "Aimbot" then
    CreateToggle("Enabled", Aimbot.Settings.Enabled, function(v)
        Aimbot.Settings.Enabled = v
    end)
    CreateToggle("Wall Check", Aimbot.Settings.WallCheck, function(v)
        Aimbot.Settings.WallCheck = v
    end)
    CreateSlider("FOV Radius", 50, 200, Aimbot.FOVSettings.Radius, function(v)
        Aimbot.FOVSettings.Radius = v
    end)
    CreateSlider("Max Distance", 100, 1000, Aimbot.Settings.MaxDistance, function(v)
        Aimbot.Settings.MaxDistance = v
    end)
end

-- Crosshair Controls
if CurrentTab == "Crosshair" then
    CreateToggle("Enabled", ESP.Properties.Crosshair.Enabled, function(v)
        ESP.Properties.Crosshair.Enabled = v
    end)
    CreateToggle("Center Dot", ESP.Properties.Crosshair.CenterDot.Enabled, function(v)
        ESP.Properties.Crosshair.CenterDot.Enabled = v
    end)
    CreateSlider("Dot Size", 1, 10, ESP.Properties.Crosshair.CenterDot.Size, function(v)
        ESP.Properties.Crosshair.CenterDot.Size = v
    end)
end

-- Core Functionality (Simplified for Mobile)
local function UpdateESP()
    if not ESP.Settings.Enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local distance = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if ESP.Settings.DistanceCheck and distance > ESP.Settings.MaxDistance then continue end
        -- Add drawing logic here (requires ESP library integration)
    end
end

local function UpdateAimbot()
    if not Aimbot.Settings.Enabled then return end
    local target = nil
    local minDist = Aimbot.FOVSettings.Radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
        if onScreen then
            local dist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
            if dist < minDist then
                minDist = dist
                target = char.Head
            end
        end
    end
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end

local function UpdateCrosshair()
    if ESP.Properties.Crosshair.Enabled then
        -- Add crosshair drawing logic here (requires ESP library)
    end
end

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateAimbot()
    UpdateCrosshair()
end)

-- Toggle UI with touch or key
local visible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.UserInputType == Enum.UserInputType.Touch then
        visible = not visible
        MainFrame.Visible = visible
    end
end)

-- Cleanup
getgenv().LukezzHubbbLoaded = true
getgenv().LukezzHubbbLoading = false
print("Lukezz Hubbb Mobile loaded successfully at " .. osdate("%I:%M %p %Z on %A, %B %d, %Y"))
