-- MatrixHub Full GUI Script for Roblox Da Strike
-- Educational purposes only. Cheating risks bans. Use at your own risk.
-- Requires an exploit supporting Drawing API (e.g., Synapse, Krnl).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configurable states based on GUI
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local TELEPORT_ENABLED = false  -- For Teleport tab

local ESP_BOX = false
local ESP_BOX_COLOR = Color3.fromRGB(255, 0, 0)  -- Red
local ESP_TYPE = "2D"  -- Fixed as 2D
local ESP_FILLED = false
local ESP_DISTANCE = false
local ESP_DISTANCE_COLOR = Color3.fromRGB(255, 255, 255)  -- White
local ESP_NAME = false
local ESP_NAME_COLOR = Color3.fromRGB(0, 255, 0)  -- Green
local ESP_HEALTH = false
local ESP_HEALTH_COLOR = Color3.fromRGB(0, 0, 255)  -- Blue
local ESP_SNAPLINE = false
local ESP_SNAPLINE_COLOR = Color3.fromRGB(255, 182, 193)  -- Pink
local LIMIT_DISTANCE = 1000
local LIMIT_ENABLED = false
local TEAM_CHECK = false
local NPC_CHECK = false  -- If game has NPCs, but probably not
local HEALTH_CHECK = false

-- Whitelist table (usernames not to target)
local WHITELIST = {}

-- Drawing objects table
local ESP_DRAWINGS = {}

-- Create GUI mimicking the image
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "MatrixHub"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
Title.Text = "MatrixHub"
Title.TextColor3 = Color3.fromRGB(0, 191, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = MainFrame

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, 0, 0, 30)
Tabs.Position = UDim2.new(0, 0, 0, 30)
Tabs.BackgroundTransparency = 1
Tabs.Parent = MainFrame

local TabLabels = {"Visual", "Aimbot", "Misc", "Whitelist", "Teleport"}
local TabContents = {}
local CurrentTab = nil

local function ShowTab(tabName)
    if CurrentTab then CurrentTab.Visible = false end
    CurrentTab = TabContents[tabName]
    if CurrentTab then CurrentTab.Visible = true end
end

for i, tab in ipairs(TabLabels) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1/#TabLabels, 0, 1, 0)
    Button.Position = UDim2.new((i-1)/#TabLabels, 0, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Button.Text = tab
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Parent = Tabs
    Button.MouseButton1Click:Connect(function() ShowTab(tab) end)
end

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Visual Tab
local VisualContent = Instance.new("Frame")
VisualContent.Size = UDim2.new(1, 0, 1, 0)
VisualContent.BackgroundTransparency = 1
VisualContent.Parent = ContentFrame
TabContents["Visual"] = VisualContent
ShowTab("Visual")  -- Default tab

local LeftColumn = Instance.new("Frame")
LeftColumn.Size = UDim2.new(0.5, 0, 1, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = VisualContent

local RightColumn = Instance.new("Frame")
RightColumn.Size = UDim2.new(0.5, 0, 1, 0)
RightColumn.Position = UDim2.new(0.5, 0, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = VisualContent

local function CreateToggle(parent, name, varName, color, yPos, isColorToggle)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent

    local ColorIndicator = Instance.new("Frame")
    ColorIndicator.Size = UDim2.new(0, 20, 0, 20)
    ColorIndicator.Position = UDim2.new(0, 0, 0.5, -10)
    ColorIndicator.BackgroundColor3 = color or Color3.fromRGB(128, 128, 128)
    ColorIndicator.BorderSizePixel = 0
    ColorIndicator.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.Position = UDim2.new(0, 25, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 50, 0, 20)
    Toggle.Position = UDim2.new(1, -60, 0.5, -10)
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Toggle.Text = _G[varName] and "ON" or "OFF"
    Toggle.TextColor3 = _G[varName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Toggle.Parent = ToggleFrame

    Toggle.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        Toggle.Text = _G[varName] and "ON" or "OFF"
        Toggle.TextColor3 = _G[varName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    return ToggleFrame
end

-- Left Column Toggles
CreateToggle(LeftColumn, "ESP Box", "ESP_BOX", ESP_BOX_COLOR, 0)
local EspTypeLabel = Instance.new("TextLabel")
EspTypeLabel.Size = UDim2.new(1, -20, 0, 30)
EspTypeLabel.Position = UDim2.new(0, 10, 0, 40)
EspTypeLabel.BackgroundTransparency = 1
EspTypeLabel.Text = "ESP Type: 2D"
EspTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
EspTypeLabel.Parent = LeftColumn

CreateToggle(LeftColumn, "ESP Filled", "ESP_FILLED", Color3.fromRGB(128, 128, 128), 80)
CreateToggle(LeftColumn, "ESP Distance", "ESP_DISTANCE", ESP_DISTANCE_COLOR, 120)
CreateToggle(LeftColumn, "ESP Name", "ESP_NAME", ESP_NAME_COLOR, 160)
CreateToggle(LeftColumn, "ESP Health", "ESP_HEALTH", ESP_HEALTH_COLOR, 200)
CreateToggle(LeftColumn, "ESP Snapline", "ESP_SNAPLINE", ESP_SNAPLINE_COLOR, 240)
CreateToggle(LeftColumn, "Limit Distance", "LIMIT_ENABLED", Color3.fromRGB(128, 128, 128), 280)

-- Right Column Toggles
CreateToggle(RightColumn, "Team Check", "TEAM_CHECK", Color3.fromRGB(128, 128, 128), 0)
CreateToggle(RightColumn, "NPC Check", "NPC_CHECK", Color3.fromRGB(128, 128, 128), 40)
CreateToggle(RightColumn, "Health Check", "HEALTH_CHECK", Color3.fromRGB(128, 128, 128), 80)

-- Aimbot Tab
local AimbotContent = Instance.new("Frame")
AimbotContent.Size = UDim2.new(1, 0, 1, 0)
AimbotContent.BackgroundTransparency = 1
AimbotContent.Parent = ContentFrame
AimbotContent.Visible = false
TabContents["Aimbot"] = AimbotContent

CreateToggle(AimbotContent, "Aimbot Enabled", "AIMBOT_ENABLED", nil, 0)

-- Misc Tab (Placeholder)
local MiscContent = Instance.new("Frame")
MiscContent.Size = UDim2.new(1, 0, 1, 0)
MiscContent.BackgroundTransparency = 1
MiscContent.Parent = ContentFrame
MiscContent.Visible = false
TabContents["Misc"] = MiscContent

local MiscLabel = Instance.new("TextLabel")
MiscLabel.Size = UDim2.new(1, 0, 1, 0)
MiscLabel.Text = "Misc Features (Implement as needed)"
MiscLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MiscLabel.Parent = MiscContent

-- Whitelist Tab
local WhitelistContent = Instance.new("Frame")
WhitelistContent.Size = UDim2.new(1, 0, 1, 0)
WhitelistContent.BackgroundTransparency = 1
WhitelistContent.Parent = ContentFrame
WhitelistContent.Visible = false
TabContents["Whitelist"] = WhitelistContent

local WhitelistInput = Instance.new("TextBox")
WhitelistInput.Size = UDim2.new(1, -20, 0, 30)
WhitelistInput.Position = UDim2.new(0, 10, 0, 10)
WhitelistInput.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
WhitelistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WhitelistInput.PlaceholderText = "Enter username to whitelist"
WhitelistInput.Parent = WhitelistContent

local AddButton = Instance.new("TextButton")
AddButton.Size = UDim2.new(0, 100, 0, 30)
AddButton.Position = UDim2.new(0, 10, 0, 50)
AddButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
AddButton.Text = "Add to Whitelist"
AddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddButton.Parent = WhitelistContent

AddButton.MouseButton1Click:Connect(function()
    local user = WhitelistInput.Text
    if user ~= "" then
        table.insert(WHITELIST, user)
        WhitelistInput.Text = ""
        print("Added to whitelist: " .. user)
    end
end)

-- Teleport Tab
local TeleportContent = Instance.new("Frame")
TeleportContent.Size = UDim2.new(1, 0, 1, 0)
TeleportContent.BackgroundTransparency = 1
TeleportContent.Parent = ContentFrame
TeleportContent.Visible = false
TabContents["Teleport"] = TeleportContent

CreateToggle(TeleportContent, "Teleport Enabled", "TELEPORT_ENABLED", nil, 0)

local TeleportInfo = Instance.new("TextLabel")
TeleportInfo.Size = UDim2.new(1, 0, 0, 30)
TeleportInfo.Position = UDim2.new(0, 0, 0, 40)
TeleportInfo.Text = "Press T to teleport to nearest player"
TeleportInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportInfo.Parent = TeleportContent

-- ESP Function
local function IsWhitelisted(player)
    return table.find(WHITELIST, player.Name) ~= nil
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local drawings = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        snapline = Drawing.new("Line")
    }
    
    drawings.box.Thickness = 1
    drawings.box.Color = ESP_BOX_COLOR
    drawings.box.Filled = ESP_FILLED
    drawings.box.Visible = false
    
    drawings.name.Size = 13
    drawings.name.Color = ESP_NAME_COLOR
    drawings.name.Visible = false
    drawings.name.Outline = true
    
    drawings.health.Size = 13
    drawings.health.Color = ESP_HEALTH_COLOR
    drawings.health.Visible = false
    drawings.health.Outline = true
    
    drawings.distance.Size = 13
    drawings.distance.Color = ESP_DISTANCE_COLOR
    drawings.distance.Visible = false
    drawings.distance.Outline = true
    
    drawings.snapline.Thickness = 1
    drawings.snapline.Color = ESP_SNAPLINE_COLOR
    drawings.snapline.Visible = false
    
    ESP_DRAWINGS[player] = drawings
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if not ESP_ENABLED or not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            return
        end
        
        local humanoid = char.Humanoid
        if HEALTH_CHECK and humanoid.Health <= 0 then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            return
        end
        
        if TEAM_CHECK and player.Team == LocalPlayer.Team then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            return
        end
        
        if IsWhitelisted(player) then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            return
        end
        
        -- NPC Check: Assume players only, skip if NPC_CHECK off and is NPC (but no NPCs likely)
        
        local root = char.HumanoidRootPart
        local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        
        if LIMIT_ENABLED and distance > LIMIT_DISTANCE then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            return
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
        if not onScreen then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            return
        end
        
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight / 2
        
        drawings.box.Visible = ESP_BOX
        if ESP_BOX then
            drawings.box.Size = Vector2.new(boxWidth, boxHeight)
            drawings.box.Position = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
            drawings.box.Filled = ESP_FILLED
        end
        
        drawings.name.Visible = ESP_NAME
        if ESP_NAME then
            drawings.name.Text = player.Name
            drawings.name.Position = Vector2.new(headPos.X, headPos.Y - 20)
        end
        
        drawings.health.Visible = ESP_HEALTH
        if ESP_HEALTH then
            drawings.health.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
            drawings.health.Position = Vector2.new(headPos.X, headPos.Y + boxHeight)
        end
        
        drawings.distance.Visible = ESP_DISTANCE
        if ESP_DISTANCE then
            drawings.distance.Text = math.floor(distance) .. "m"
            drawings.distance.Position = Vector2.new(headPos.X, headPos.Y + boxHeight + 15)
        end
        
        drawings.snapline.Visible = ESP_SNAPLINE
        if ESP_SNAPLINE then
            drawings.snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.snapline.To = Vector2.new(headPos.X, headPos.Y)
        end
    end)
    
    local function cleanup()
        connection:Disconnect()
        for _, d in pairs(drawings) do d:Remove() end
        ESP_DRAWINGS[player] = nil
    end
    
    player.CharacterRemoving:Connect(cleanup)
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

-- Aimbot (Camlock to nearest non-whitelisted)
local function GetClosestPlayer()
    local closest = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and not IsWhitelisted(player) then
            if TEAM_CHECK and player.Team == LocalPlayer.Team then continue end
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = player.Character.Head
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Teleport on 'T' if enabled
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.T and TELEPORT_ENABLED then
        local target = GetClosestPlayer()
        if target then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Parent.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)

-- Toggle ESP globally with 'E' (optional, since GUI has toggles)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ESP_ENABLED = not ESP_ENABLED
        print("ESP Toggled:", ESP_ENABLED)
    end
end)
