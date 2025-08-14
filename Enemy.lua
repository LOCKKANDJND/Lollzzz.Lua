-- Create the ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MatrixHubGui"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Title Label
local Title = Instance.new("TextLabel")
Title.Text = "MatrixHub"
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = MainFrame

-- Tab Buttons Frame
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0.1, 0)
TabButtonsFrame.Position = UDim2.new(0, 0, 0.1, 0)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local Tabs = {"Visual", "Aimbot", "Misc", "Whitelist", "Teleport"}
local TabButtons = {}
local currentTab = nil

local function createTabButton(name, index)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(1/ #Tabs, 0, 1, 0)
    btn.Position = UDim2.new((index - 1)/ #Tabs, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Parent = TabButtonsFrame
    
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
        -- Change button colors
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    return btn
end

for i, name in ipairs(Tabs) do
    table.insert(TabButtons, createTabButton(name, i))
end

-- Content Frames for each tab
local TabsContent = {}
local function createTabContent(name)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0.9, -0.1)
    frame.Position = UDim2.new(0, 0, 0.1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    frame.Visible = false
    TabsContent[name] = frame
    return frame
end

for _, tabName in ipairs(Tabs) do
    createTabContent(tabName)
end

-- Function to switch tabs
local function switchTab(name)
    for tab, frame in pairs(TabsContent) do
        frame.Visible = (tab == name)
    end
    currentTab = name
end

-- Initialize first tab
switchTab("Visual")

-- Helper function to create toggles and sliders
local function createToggle(parent, label, default)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, 0)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.Font = Enum.Font.SourceSans
    labelText.TextSize = 16
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.3, -10, 0.6, 0)
    toggleButton.Position = UDim2.new(0.7, 5, 0.2, 0)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local state = default
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        -- You can connect this state to your scripts
        print(label .. " toggled to " .. tostring(state))
    end)
    return {
        Frame = toggleFrame,
        Button = toggleButton,
        State = function() return state end
    }
end

local function createSlider(parent, label, min, max, default)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -20, 0, 50)
    sliderContainer.Position = UDim2.new(0, 10, 0, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.Font = Enum.Font.SourceSans
    labelText.TextSize = 16
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = sliderContainer
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.55, 0, 0.3, 0)
    slider.Position = UDim2.new(0.45, 0, 0.35, 0)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.Parent = sliderContainer
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.Parent = slider
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0.02, 0, 1, 0)
    thumb.Position = UDim2.new((default - min) / (max - min) - 0.01, 0, 0, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = fill
    
    local valueText = Instance.new("TextLabel")
    valueText.Text = tostring(default)
    valueText.Size = UDim2.new(0.15, 0, 1, 0)
    valueText.Position = UDim2.new(0.75, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueText.Font = Enum.Font.SourceSans
    valueText.TextSize = 14
    valueText.Parent = sliderContainer
    
    local dragging = false
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absoluteX = input.Position.X
            local sliderStart = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            local relativeX = math.clamp(absoluteX - sliderStart, 0, sliderWidth)
            local percent = relativeX / sliderWidth
            local newValue = math.floor(min + percent * (max - min))
            thumb.Position = UDim2.new(percent - 0.01, 0, 0, 0)
            valueText.Text = tostring(newValue)
            -- Connect this value to your scripts
            print(label .. ": " .. newValue)
        end
    end)
    
    -- Function to get current value
    local function getValue()
        local absPos = thumb.AbsolutePosition.X
        local sliderStart = slider.AbsolutePosition.X
        local sliderWidth = slider.AbsoluteSize.X
        local relativeX = math.clamp(absPos - sliderStart, 0, sliderWidth)
        local percent = relativeX / sliderWidth
        local value = math.floor(min + percent * (max - min))
        return value
    end
    
    return {
        Frame = sliderContainer,
        GetValue = getValue
    }
end

-- Example of populating the "Visual" tab
local visualTab = TabsContent["Visual"]

-- ESP Box Toggle
createToggle(visualTab, "ESP Box", false)

-- ESP Type Slider
createSlider(visualTab, "ESP Type", 1, 3, 2)

-- ESP Filled Toggle
createToggle(visualTab, "ESP Filled", false)

-- ESP Distance Slider
createSlider(visualTab, "ESP Distance", 0, 100, 50)

-- ESP Name Toggle
createToggle(visualTab, "ESP Name", false)

-- ESP Health Toggle
createToggle(visualTab, "ESP Health", false)

-- ESP SnapLine Toggle
createToggle(visualTab, "ESP SnapLine", false)

-- Limit Distance Toggle
createToggle(visualTab, "Limit Distance", false)

-- You can similarly populate other tabs...

-- OPTIONAL: Make GUI draggable for better mobile experience
local dragging = false
local dragInput, dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
