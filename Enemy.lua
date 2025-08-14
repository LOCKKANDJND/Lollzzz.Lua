--!strict
-- MatrixHub-Style UI Template (no gameplay hacks)
-- Drop this in a LocalScript (e.g., StarterPlayerScripts). Pure Instance.new, no libraries.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer

-- ===== Utility =====
local function Make(className, props, children)
    local inst = Instance.new(className)
    if props then
        for k,v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _,child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function uiCorner(radius)
    return Make("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function uiStroke(thickness, color, trans)
    return Make("UIStroke", { Thickness = thickness or 1, Color = color or Color3.fromRGB(255,255,255), Transparency = trans or 0.3 })
end

local function uiPadding(l,t,r,b)
    return Make("UIPadding", { PaddingLeft = UDim.new(0,l or 0), PaddingTop = UDim.new(0,t or 0),
        PaddingRight = UDim.new(0,r or 0), PaddingBottom = UDim.new(0,b or 0) })
end

local function newLabel(text, size)
    return Make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextSize = size or 14,
        TextColor3 = Color3.fromRGB(220,230,240),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
end

-- Simple draggable behavior for a frame
local function makeDraggable(handle: Frame, dragTarget: Frame)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ===== Controls =====
local Theme = {
    Bg = Color3.fromRGB(25,31,38),
    Panel = Color3.fromRGB(34, 41, 51),
    Panel2 = Color3.fromRGB(42, 50, 62),
    Accent = Color3.fromRGB(52, 152, 219),
    Accent2 = Color3.fromRGB(0, 180, 255),
    TextDim = Color3.fromRGB(180,190,200),
    On = Color3.fromRGB(65, 180, 90),
    Off = Color3.fromRGB(70, 76, 86)
}

local function Toggle(parent: Instance, labelText: string, default: boolean, callback)
    local row = Make("Frame", { BackgroundColor3 = Theme.Panel, Size = UDim2.new(1,0,0,40) }, {
        uiCorner(12), uiStroke(1, Color3.fromRGB(255,255,255), 0.8), uiPadding(12,8,12,8)
    })
    row.Parent = parent

    local label = newLabel(labelText, 14)
    label.Size = UDim2.new(1,-80,1,0); label.Parent = row

    local knob = Make("TextButton", {
        Size = UDim2.new(0,52,0,24),
        Position = UDim2.new(1,-60,0.5,-12),
        BackgroundColor3 = default and Theme.On or Theme.Off,
        Text = "",
        AutoButtonColor = false
    }, { uiCorner(12) })
    knob.Parent = row

    local dot = Make("Frame", {
        Size = UDim2.new(0,18,0,18),
        Position = default and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
        BackgroundColor3 = Color3.fromRGB(245,247,250)
    }, { uiCorner(9) })
    dot.Parent = knob

    local state = default
    local function set(v)
        state = v
        knob.BackgroundColor3 = v and Theme.On or Theme.Off
        dot.Position = v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        if callback then
            task.spawn(function() callback(v) end)
        end
    end

    knob.MouseButton1Click:Connect(function() set(not state) end)
    return {
        Set = set,
        Get = function() return state end,
        Instance = row
    }
end

local function Slider(parent, labelText, min, max, default, callback)
    local row = Make("Frame", { BackgroundColor3 = Theme.Panel, Size = UDim2.new(1,0,0,50) }, {
        uiCorner(12), uiStroke(1, Color3.fromRGB(255,255,255), 0.8), uiPadding(12,8,12,8)
    })
    row.Parent = parent

    local label = newLabel(labelText, 14)
    label.Size = UDim2.new(1,0,0,16); label.Parent = row

    local bar = Make("Frame", { BackgroundColor3 = Theme.Panel2, Size = UDim2.new(1,-80,0,8), Position = UDim2.new(0,0,0,26) }, { uiCorner(6) })
    bar.Parent = row

    local fill = Make("Frame", { BackgroundColor3 = Theme.Accent, Size = UDim2.new((default-min)/(max-min),0,1,0) }, { uiCorner(6) })
    fill.Parent = bar

    local valueLbl = newLabel(tostring(default), 14)
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Size = UDim2.new(0,70,0,20)
    valueLbl.Position = UDim2.new(1,-70,0,22)
    valueLbl.Parent = row

    local val = default
    local dragging = false
    local function set(n)
        n = math.clamp(n, min, max)
        val = n
        local alpha = (n - min) / (max - min)
        fill.Size = UDim2.new(alpha,0,1,0)
        valueLbl.Text = tostring(math.floor(n + 0.5))
        if callback then task.spawn(function() callback(val) end) end
    end

    bar.InputBegan:Connect(function(input)
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
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            set(min + rel * (max - min))
        end
    end)

    set(default)
    return { Set = set, Get = function() return val end, Instance = row }
end

local function Dropdown(parent, labelText, options, defaultIndex, callback)
    local row = Make("Frame", { BackgroundColor3 = Theme.Panel, Size = UDim2.new(1,0,0,40) }, {
        uiCorner(12), uiStroke(1, Color3.fromRGB(255,255,255), 0.8), uiPadding(12,8,12,8)
    })
    row.Parent = parent

    local label = newLabel(labelText, 14); label.Size = UDim2.new(1,-120,1,0); label.Parent = row

    local btn = Make("TextButton", {
        Size = UDim2.new(0,100,1,-8),
        Position = UDim2.new(1,-100,0,4),
        BackgroundColor3 = Theme.Panel2,
        TextColor3 = Color3.fromRGB(230,235,240),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = true,
        Text = ""
    }, { uiCorner(10) })
    btn.Parent = row

    local choiceLbl = newLabel("", 14)
    choiceLbl.TextXAlignment = Enum.TextXAlignment.Center
    choiceLbl.Size = UDim2.new(1,0,1,0)
    choiceLbl.Parent = btn

    local menu = Make("Frame", { Visible = false, BackgroundColor3 = Theme.Panel2, Size = UDim2.new(0,140,0, (#options*28)+8), Position = UDim2.new(1,-140,1,6) }, {
        uiCorner(10), uiStroke(1, Color3.fromRGB(255,255,255), 0.8), uiPadding(6,6,6,6)
    })
    menu.Parent = row

    local list = Make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder })
    list.Parent = menu

    local index = math.clamp(defaultIndex or 1, 1, #options)
    local function set(i)
        index = i
        choiceLbl.Text = tostring(options[i])
        if callback then task.spawn(function() callback(options[i], i) end) end
    end

    for i,opt in ipairs(options) do
        local optBtn = Make("TextButton", {
            BackgroundColor3 = Theme.Panel,
            Size = UDim2.new(1,0,0,26),
            Text = tostring(opt),
            TextColor3 = Color3.fromRGB(230,235,240),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AutoButtonColor = true
        }, { uiCorner(8) })
        optBtn.Parent = menu
        optBtn.MouseButton1Click:Connect(function()
            set(i)
            menu.Visible = false
        end)
    end

    btn.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)

    set(index)
    return { SetIndex = set, GetIndex = function() return index end, Instance = row }
end

-- ===== Root UI =====
local gui = Make("ScreenGui", { Name = "MatrixUI_Template", ResetOnSpawn = false, IgnoreGuiInset = true })
gui.Parent = plr:WaitForChild("PlayerGui")

local window = Make("Frame", {
    Size = UDim2.new(0, 640, 0, 420),
    Position = UDim2.new(0.5, -320, 0.5, -210),
    BackgroundColor3 = Theme.Bg
}, { uiCorner(16), uiStroke(1.2, Color3.fromRGB(255,255,255), 0.85) })
window.Parent = gui

-- Top bar
local topbar = Make("Frame", {
    BackgroundColor3 = Theme.Bg,
    Size = UDim2.new(1, -16, 0, 54),
    Position = UDim2.new(0,8,0,8)
}, { uiCorner(12), uiPadding(16,10,16,10) })
topbar.Parent = window

local title = newLabel("MatrixHub", 20)
title.TextColor3 = Color3.fromRGB(160, 200, 255)
title.Parent = topbar

-- Tabs
local tabs = { "Visual", "Aimbot", "Misc", "Whitelist", "Teleport" }

local tabBar = Make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,0,58) })
tabBar.Parent = window

local tabList = Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder })
tabList.Parent = tabBar
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Left

local pages = {}

local content = Make("Frame", {
    BackgroundColor3 = Theme.Bg,
    Size = UDim2.new(1,-16,1,-100),
    Position = UDim2.new(0,8,0,96)
}, { uiCorner(12) })
content.Parent = window

local function newPage()
    local scroller = Make("ScrollingFrame", {
        BackgroundColor3 = Theme.Bg,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0,8,0,8),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, { uiPadding(8,8,8,8) })
    scroller.Parent = content

    local grid = Make("UIGridLayout", {
        CellPadding = UDim2.new(0,10,0,10),
        CellSize = UDim2.new(0.5, -10, 0, 50),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    grid.Parent = scroller

    return scroller
end

local function selectTab(name)
    for tabName, page in pairs(pages) do
        page.Visible = (tabName == name)
    end
    for _,btn in ipairs(tabBar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.TextColor3 = (btn.Name == name) and Color3.fromRGB(230,240,255) or Theme.TextDim
            btn.BackgroundColor3 = (btn.Name == name) and Theme.Panel2 or Color3.fromRGB(0,0,0)
        end
    end
end

for _,name in ipairs(tabs) do
    local tbtn = Make("TextButton", {
        Name = name,
        Size = UDim2.new(0,110,0,28),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        AutoButtonColor = true
    }, { uiCorner(10), uiStroke(1, Color3.fromRGB(255,255,255), 0.9) })
    tbtn.Parent = tabBar

    local page = newPage()
    page.Visible = false
    pages[name] = page

    tbtn.MouseButton1Click:Connect(function()
        selectTab(name)
    end)
end

-- Populate "Visual" like the screenshot
do
    local p = pages["Visual"]
    Toggle(p, "ESP Box", false, function(v) print("ESP Box:", v) end)
    Dropdown(p, "ESP Type", {"2D","3D"}, 1, function(choice) print("ESP Type:", choice) end)
    Toggle(p, "ESP Filled", false, function(v) print("ESP Filled:", v) end)
    Toggle(p, "ESP Distance", true, function(v) print("ESP Distance:", v) end)
    Toggle(p, "ESP Name", true, function(v) print("ESP Name:", v) end)
    Toggle(p, "ESP Health", true, function(v) print("ESP Health:", v) end)
    Toggle(p, "ESP SnapLine", false, function(v) print("ESP SnapLine:", v) end)
    Slider(p, "Limit Distance", 25, 1000, 300, function(v) print("Limit Distance:", math.floor(v)) end)

    -- Right column example options
    Toggle(p, "Team Check", false, function(v) print("Team Check:", v) end)
    Toggle(p, "NPC Check", false, function(v) print("NPC Check:", v) end)
    Toggle(p, "Health Check", false, function(v) print("Health Check:", v) end)
end

-- Populate other tabs with placeholders
do
    local p = pages["Aimbot"]
    Toggle(p, "Enabled", false, function(v) print("Aimbot Enabled:", v) end)
    Dropdown(p, "Aim Part", {"Head","Torso","HumanoidRootPart"}, 1, function(c) print("Aim Part:", c) end)
    Slider(p, "FOV", 10, 300, 120, function(v) print("FOV:", math.floor(v)) end)
    Toggle(p, "Team Check", true, function(v) print("AB TeamCheck:", v) end)
end

do
    local p = pages["Misc"]
    Toggle(p, "Show FPS Counter", true, function(v) print("FPS Counter:", v) end)
    Toggle(p, "No Post-Processing", false, function(v) print("No PP:", v) end)
    Dropdown(p, "Theme", {"Dark","Darker","Midnight"}, 1, function(c) print("Theme:", c) end)
end

do
    local p = pages["Whitelist"]
    Toggle(p, "Enable Whitelist", false, function(v) print("Whitelist:", v) end)
end

do
    local p = pages["Teleport"]
    Dropdown(p, "Location", {"Spawn","Shop","Center"}, 1, function(c) print("Teleport to:", c) end)
end

-- Default select first tab and enable dragging by topbar
selectTab("Visual")
makeDraggable(topbar, window)

-- Optional: toggle UI with RightShift (mobile users can add their own button)
local visible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        visible = not visible
        window.Visible = visible
    end
end)
