-- MatrixHub Full GUI Script for Roblox Da Strike
-- Educational purposes only. Cheating risks bans. Use at your own risk.
-- Designed to be mobile-friendly with larger elements and touch support.
-- Requires an exploit supporting Drawing API and UserInputService (e.g., Synapse for PC, Hydrogen/Delta for Mobile).
-- Tested conceptually for Da Strike (FFA gun game similar to Da Hood).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()  -- For PC; mobile uses touch

-- Configurable states
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local SILENT_AIM = false
local AIMBOT_FOV = 200  -- Pixels from center
local AIMBOT_SMOOTHNESS = 0.5  -- 0 = instant, 1 = no smooth
local TELEPORT_ENABLED = false
local SPEED_HACK_ENABLED = false
local SPEED_HACK_VALUE = 50  -- Walkspeed
local NOCLIP_ENABLED = false
local MACRO_ENABLED = false  -- For X macro in Da Strike

local ESP_BOX = false
local ESP_BOX_COLOR = Color3.fromRGB(255, 0, 0)
local ESP_TYPE = "2D"
local ESP_FILLED = false
local ESP_DISTANCE = false
local ESP_DISTANCE_COLOR = Color3.fromRGB(255, 255, 255)
local ESP_NAME = false
local ESP_NAME_COLOR = Color3.fromRGB(0, 255, 0)
local ESP_HEALTH = false
local ESP_HEALTH_COLOR = Color3.fromRGB(0, 0, 255)
local ESP_SNAPLINE = false
local ESP_SNAPLINE_COLOR = Color3.fromRGB(255, 182, 193)
local LIMIT_DISTANCE = 1000
local LIMIT_ENABLED = false
local TEAM_CHECK = false  -- Da Strike is FFA, but toggle for future
local NPC_CHECK = false
local HEALTH_CHECK = true

local WHITELIST = {}
local ESP_DRAWINGS = {}
local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Thickness = 1
FOV_CIRCLE.Color = Color3.fromRGB(255, 255, 255)
FOV_CIRCLE.Radius = AIMBOT_FOV
FOV_CIRCLE.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Make GUI mobile-friendly: Larger sizes, scalable
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "MatrixHub"
ScreenGui.IgnoreGuiInset = true  -- Full screen friendly

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)  -- Scalable for mobile
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true  -- Draggable on PC/mobile (touch drag works)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)  -- Larger for touch
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
Title.Text = "MatrixHub - Da Strike"
Title.TextColor3 = Color3.fromRGB(0, 191, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 28  -- Larger font
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextSize = 28
CloseButton.Parent = Title
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, 0, 0, 50)  -- Larger tabs
Tabs.Position = UDim2.new(0, 0, 0, 40)
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
    Button.TextSize = 20
    Button.Parent = Tabs
    Button.MouseButton1Click:Connect(function() ShowTab(tab) end)
end

local ContentFrame = Instance.new("ScrollingFrame")  -- Scrollable for mobile
ContentFrame.Size = UDim2.new(1, 0, 1, -90)
ContentFrame.Position = UDim2.new(0, 0, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 2, 0)  -- Auto expand
ContentFrame.ScrollBarThickness = 10  -- Thicker for touch
ContentFrame.Parent = MainFrame

-- Function to create toggles (larger for mobile)
local function CreateToggle(parent, name, varName, color, yPos)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)  -- Larger
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent

    local ColorIndicator = Instance.new("Frame")
    ColorIndicator.Size = UDim2.new(0, 30, 0, 30)
    ColorIndicator.Position = UDim2.new(0, 10, 0.5, -15)
    ColorIndicator.BackgroundColor3 = color or Color3.fromRGB(128, 128, 128)
    ColorIndicator.BorderSizePixel = 0
    ColorIndicator.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 50, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 20
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 60, 0, 30)
    Toggle.Position = UDim2.new(1, -70, 0.5, -15)
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Toggle.Text = _G[varName] and "ON" or "OFF"
    Toggle.TextColor3 = _G[varName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Toggle.TextSize = 18
    Toggle.Parent = ToggleFrame

    Toggle.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        Toggle.Text = _G[varName] and "ON" or "OFF"
        Toggle.TextColor3 = _G[varName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if varName == "AIMBOT_ENABLED" then
            FOV_CIRCLE.Visible = _G[varName]
        end
    end)

    return ToggleFrame
end

local function CreateSlider(parent, name, varName, min, max, yPos)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.Position = UDim2.new(0, 0, 0, yPos)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. _G[varName]
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 20
    Label.Parent = SliderFrame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.4, 0, 0.6, 0)
    Input.Position = UDim2.new(0.5, 0, 0.2, 0)
    Input.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.Text = tostring(_G[varName])
    Input.TextSize = 18
    Input.Parent = SliderFrame

    Input.FocusLost:Connect(function()
        local num = tonumber(Input.Text)
        if num then
            _G[varName] = math.clamp(num, min, max)
            Label.Text = name .. ": " .. _G[varName]
            Input.Text = tostring(_G[varName])
            if varName == "AIMBOT_FOV" then FOV_CIRCLE.Radius = _G[varName] end
        end
    end)

    return SliderFrame
end

-- Visual Tab
local VisualContent = Instance.new("Frame")
VisualContent.Size = UDim2.new(1, 0, 1, 0)
VisualContent.BackgroundTransparency = 1
VisualContent.Parent = ContentFrame
TabContents["Visual"] = VisualContent

local visualY = 0
CreateToggle(VisualContent, "ESP Enabled", "ESP_ENABLED", nil, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "ESP Box", "ESP_BOX", ESP_BOX_COLOR, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "ESP Filled", "ESP_FILLED", nil, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "ESP Distance", "ESP_DISTANCE", ESP_DISTANCE_COLOR, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "ESP Name", "ESP_NAME", ESP_NAME_COLOR, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "ESP Health", "ESP_HEALTH", ESP_HEALTH_COLOR, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "ESP Snapline", "ESP_SNAPLINE", ESP_SNAPLINE_COLOR, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "Limit Enabled", "LIMIT_ENABLED", nil, visualY) visualY = visualY + 50
CreateSlider(VisualContent, "Limit Distance", "LIMIT_DISTANCE", 100, 5000, visualY) visualY = visualY + 50
CreateToggle(VisualContent, "Health Check", "HEALTH_CHECK", nil, visualY) visualY = visualY + 50

-- Aimbot Tab
local AimbotContent = Instance.new("Frame")
AimbotContent.Size = UDim2.new(1, 0, 1, 0)
AimbotContent.BackgroundTransparency = 1
AimbotContent.Parent = ContentFrame
AimbotContent.Visible = false
TabContents["Aimbot"] = AimbotContent

local aimbotY = 0
CreateToggle(AimbotContent, "Aimbot Enabled", "AIMBOT_ENABLED", nil, aimbotY) aimbotY = aimbotY + 50
CreateToggle(AimbotContent, "Silent Aim", "SILENT_AIM", nil, aimbotY) aimbotY = aimbotY + 50
CreateSlider(AimbotContent, "FOV", "AIMBOT_FOV", 50, 500, aimbotY) aimbotY = aimbotY + 50
CreateSlider(AimbotContent, "Smoothness", "AIMBOT_SMOOTHNESS", 0, 1, aimbotY) aimbotY = aimbotY + 50

-- Misc Tab
local MiscContent = Instance.new("Frame")
MiscContent.Size = UDim2.new(1, 0, 1, 0)
MiscContent.BackgroundTransparency = 1
MiscContent.Parent = ContentFrame
MiscContent.Visible = false
TabContents["Misc"] = MiscContent

local miscY = 0
CreateToggle(MiscContent, "Speed Hack", "SPEED_HACK_ENABLED", nil, miscY) miscY = miscY + 50
CreateSlider(MiscContent, "Speed Value", "SPEED_HACK_VALUE", 16, 100, miscY) miscY = miscY + 50
CreateToggle(MiscContent, "Noclip", "NOCLIP_ENABLED", nil, miscY) miscY = miscY + 50
CreateToggle(MiscContent, "Macro (X Bind)", "MACRO_ENABLED", nil, miscY) miscY = miscY + 50

-- Whitelist Tab
local WhitelistContent = Instance.new("Frame")
WhitelistContent.Size = UDim2.new(1, 0, 1, 0)
WhitelistContent.BackgroundTransparency = 1
WhitelistContent.Parent = ContentFrame
WhitelistContent.Visible = false
TabContents["Whitelist"] = WhitelistContent

local WhitelistInput = Instance.new("TextBox")
WhitelistInput.Size = UDim2.new(1, -20, 0, 40)
WhitelistInput.Position = UDim2.new(0, 10, 0, 10)
WhitelistInput.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
WhitelistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WhitelistInput.PlaceholderText = "Enter username"
WhitelistInput.TextSize = 20
WhitelistInput.Parent = WhitelistContent

local AddButton = Instance.new("TextButton")
AddButton.Size = UDim2.new(1, -20, 0, 40)
AddButton.Position = UDim2.new(0, 10, 0, 60)
AddButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
AddButton.Text = "Add to Whitelist"
AddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddButton.TextSize = 20
AddButton.Parent = WhitelistContent

AddButton.MouseButton1Click:Connect(function()
    local user = WhitelistInput.Text
    if user ~= "" then
        table.insert(WHITELIST, user:lower())
        WhitelistInput.Text = ""
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
TeleportInfo.Size = UDim2.new(1, 0, 0, 40)
TeleportInfo.Position = UDim2.new(0, 0, 0, 50)
TeleportInfo.Text = "Press T to TP to nearest (PC) or tap screen (Mobile touch simulation)"
TeleportInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportInfo.TextSize = 20
TeleportInfo.Parent = TeleportContent

-- Core Functions
local function IsWhitelisted(player)
    return table.find(WHITELIST, player.Name:lower()) ~= nil
end

local function GetClosestPlayer(fov)
    local closest = nil
    local minDist = fov or math.huge
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

-- ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local drawings = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        snapline = Drawing.new("Line")
    }
    
    drawings.box.Thickness = 2
    drawings.box.Color = ESP_BOX_COLOR
    drawings.box.Filled = ESP_FILLED
    
    drawings.name.Size = 16  -- Larger for visibility
    drawings.name.Color = ESP_NAME_COLOR
    drawings.name.Outline = true
    
    drawings.health.Size = 16
    drawings.health.Color = ESP_HEALTH_COLOR
    drawings.health.Outline = true
    
    drawings.distance.Size = 16
    drawings.distance.Color = ESP_DISTANCE_COLOR
    drawings.distance.Outline = true
    
    drawings.snapline.Thickness = 2
    drawings.snapline.Color = ESP_SNAPLINE_COLOR
    
    ESP_DRAWINGS[player] = drawings
    
    local connection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if not ESP_ENABLED or not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end
        
        local humanoid = char.Humanoid
        if HEALTH_CHECK and humanoid.Health <= 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end
        
        if IsWhitelisted(player) then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end
        
        local root = char.HumanoidRootPart
        local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        
        if LIMIT_ENABLED and distance > LIMIT_DISTANCE then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
        if not onScreen then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end
        
        local topPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 1, 0))
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local boxHeight = (topPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.5
        
        if ESP_BOX then
            drawings.box.Size = Vector2.new(boxWidth, boxHeight)
            drawings.box.Position = Vector2.new(topPos.X - boxWidth / 2, topPos.Y)
            drawings.box.Visible = true
        else
            drawings.box.Visible = false
        end
        
        if ESP_NAME then
            drawings.name.Text = player.Name
            drawings.name.Position = Vector2.new(topPos.X, topPos.Y - 20)
            drawings.name.Visible = true
        else
            drawings.name.Visible = false
        end
        
        if ESP_HEALTH then
            drawings.health.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
            drawings.health.Position = Vector2.new(topPos.X, legPos.Y + 5)
            drawings.health.Visible = true
        else
            drawings.health.Visible = false
        end
        
        if ESP_DISTANCE then
            drawings.distance.Text = math.floor(distance) .. " studs"
            drawings.distance.Position = Vector2.new(topPos.X, legPos.Y + 20)
            drawings.distance.Visible = true
        else
            drawings.distance.Visible = false
        end
        
        if ESP_SNAPLINE then
            drawings.snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            drawings.snapline.To = Vector2.new(headPos.X, headPos.Y)
            drawings.snapline.Visible = true
        else
            drawings.snapline.Visible = false
        end
    end)
    
    player.CharacterRemoving:Connect(function()
        connection:Disconnect()
        for _, d in pairs(drawings) do d:Remove() end
        ESP_DRAWINGS[player] = nil
    end)
end

for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() CreateESP(player) end)
end)

-- Aimbot & Silent Aim
local oldCameraCFrame = Camera.CFrame
RunService.RenderStepped:Connect(function(delta)
    if AIMBOT_ENABLED then
        local target = GetClosestPlayer(AIMBOT_FOV)
        if target then
            if SILENT_AIM then
                -- Basic silent aim: Assume game uses raycast for shooting; hook if possible. For simplicity, predict velocity
                local velocity = target.Parent.HumanoidRootPart.Velocity
                local prediction = target.Position + velocity * (delta * 5)  -- Simple prediction
                -- To make silent, would need to hook mouse.hit, but in script, assume exploit allows
                -- For demo, set camera but not visibly if silent
                if not AIMBOT_ENABLED then return end  -- Wait, for silent, don't change camera
            else
                -- Camlock with smoothness
                local newCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1 - AIMBOT_SMOOTHNESS)
            end
        end
    end
    
    if SPEED_HACK_ENABLED and LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        LocalPlayer.Character.Humanoid.WalkSpeed = SPEED_HACK_VALUE
    end
    
    if NOCLIP_ENABLED then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    FOV_CIRCLE.Position = Vector2.new(Mouse.X, Mouse.Y + 36)  -- Follow mouse for PC; for mobile, center
end)

-- Silent Aim Hook (Basic, may need game-specific)
-- For Da Strike, assume shooting is local; this is placeholder
UserInputService.InputBegan:Connect(function(input)
    if AIMBOT_ENABLED and SILENT_AIM and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = GetClosestPlayer(AIMBOT_FOV)
        if target then
            -- Simulate hit; in real exploit, hook raycast
            -- For demo, print("Silent aim to " .. target.Parent.Name)
        end
    end
end)

-- Teleport
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if TELEPORT_ENABLED and input.KeyCode == Enum.KeyCode.T then
        local target = GetClosestPlayer()
        if target then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end)

-- Macro for X bind (Da Strike macro)
RunService.Heartbeat:Connect(function()
    if MACRO_ENABLED then
        -- Simulate macro; in Da Strike, X is macro bind
        -- For demo, fire event or something; assume game has remote
        -- Placeholder: print("Macro active")
    end
end)

-- Show GUI on load
ShowTab("Visual")
MainFrame.Visible = true

-- Toggle GUI with Insert (PC) or custom for mobile
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
