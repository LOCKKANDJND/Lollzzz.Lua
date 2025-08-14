--!strict
-- MatrixHub-Style UI (All Tabs, Toggles, Sliders, Dropdowns)
-- Drop in StarterPlayerScripts. Pure Instance.new. No external libs.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

-- ===== Utility =====
local function Make(className, props, children)
    local inst = Instance.new(className)
    if props then
        for k,v in pairs(props) do inst[k] = v end
    end
    if children then
        for _,child in ipairs(children) do child.Parent = inst end
    end
    return inst
end

local function uiCorner(radius) return Make("UICorner",{CornerRadius=UDim.new(0,radius)}) end
local function uiStroke(thickness,color,trans) return Make("UIStroke",{Thickness=thickness or 1,Color=color or Color3.fromRGB(255,255,255),Transparency=trans or 0.3}) end
local function uiPadding(l,t,r,b) return Make("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingTop=UDim.new(0,t or 0),PaddingRight=UDim.new(0,r or 0),PaddingBottom=UDim.new(0,b or 0)}) end
local function newLabel(text,size) return Make("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=text,TextSize=size or 14,TextColor3=Color3.fromRGB(220,230,240),TextXAlignment=Enum.TextXAlignment.Left}) end

local function makeDraggable(handle: Frame, dragTarget: Frame)
    local dragging=false; local dragStart; local startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=dragTarget.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            dragTarget.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
end

-- ===== Theme =====
local Theme={
    Bg=Color3.fromRGB(25,31,38),
    Panel=Color3.fromRGB(34,41,51),
    Panel2=Color3.fromRGB(42,50,62),
    Accent=Color3.fromRGB(52,152,219),
    Accent2=Color3.fromRGB(0,180,255),
    TextDim=Color3.fromRGB(180,190,200),
    On=Color3.fromRGB(65,180,90),
    Off=Color3.fromRGB(70,76,86)
}

-- ===== Controls =====
local function Toggle(parent,labelText,default,callback)
    local row=Make("Frame",{BackgroundColor3=Theme.Panel,Size=UDim2.new(1,0,0,40)},{uiCorner(12),uiStroke(1,Color3.fromRGB(255,255,255),0.8),uiPadding(12,8,12,8)})
    row.Parent=parent
    local label=newLabel(labelText,14); label.Size=UDim2.new(1,-80,1,0); label.Parent=row
    local knob=Make("TextButton",{Size=UDim2.new(0,52,0,24),Position=UDim2.new(1,-60,0.5,-12),BackgroundColor3=default and Theme.On or Theme.Off,Text="",AutoButtonColor=false},{uiCorner(12)})
    knob.Parent=row
    local dot=Make("Frame",{Size=UDim2.new(0,18,0,18),Position=default and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(245,247,250)},{uiCorner(9)})
    dot.Parent=knob
    local state=default
    local function set(v)
        state=v
        knob.BackgroundColor3=v and Theme.On or Theme.Off
        dot.Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        if callback then task.spawn(function() callback(v) end) end
    end
    knob.MouseButton1Click:Connect(function() set(not state) end)
    return {Set=set,Get=function() return state end,Instance=row}
end

local function Slider(parent,labelText,min,max,default,callback)
    local row=Make("Frame",{BackgroundColor3=Theme.Panel,Size=UDim2.new(1,0,0,50)},{uiCorner(12),uiStroke(1,Color3.fromRGB(255,255,255),0.8),uiPadding(12,8,12,8)})
    row.Parent=parent
    local label=newLabel(labelText,14); label.Size=UDim2.new(1,0,0,16); label.Parent=row
    local bar=Make("Frame",{BackgroundColor3=Theme.Panel2,Size=UDim2.new(1,-80,0,8),Position=UDim2.new(0,0,0,26)},{uiCorner(6)}); bar.Parent=row
    local fill=Make("Frame",{BackgroundColor3=Theme.Accent,Size=UDim2.new((default-min)/(max-min),0,1,0)},{uiCorner(6)}); fill.Parent=bar
    local valueLbl=newLabel(tostring(default),14); valueLbl.TextXAlignment=Enum.TextXAlignment.Right; valueLbl.Size=UDim2.new(0,70,0,20); valueLbl.Position=UDim2.new(1,-70,0,22); valueLbl.Parent=row
    local val=default; local dragging=false
    local function set(n)
        n=math.clamp(n,min,max)
        val=n
        local alpha=(n-min)/(max-min)
        fill.Size=UDim2.new(alpha,0,1,0)
        valueLbl.Text=tostring(math.floor(n+0.5))
        if callback then task.spawn(function() callback(val) end) end
    end
    bar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local rel=(input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
            set(min+rel*(max-min))
        end
    end)
    set(default)
    return {Set=set,Get=function() return val end,Instance=row}
end

local function Dropdown(parent,labelText,options,defaultIndex,callback)
    local row=Make("Frame",{BackgroundColor3=Theme.Panel,Size=UDim2.new(1,0,0,40)},{uiCorner(12),uiStroke(1,Color3.fromRGB(255,255,255),0.8),uiPadding(12,8,12,8)})
    row.Parent=parent
    local label=newLabel(labelText,14); label.Size=UDim2.new(1,-120,1,0); label.Parent=row
    local btn=Make("TextButton",{Size=UDim2.new(0,100,1,-8),Position=UDim2.new(1,-100,0,4),BackgroundColor3=Theme.Panel2,TextColor3=Color3.fromRGB(230,235,240),Font=Enum.Font.Gotham,TextSize=14,AutoButtonColor=true,Text=""},{uiCorner(10)})
    btn.Parent=row
    local choiceLbl=newLabel("",14); choiceLbl.TextXAlignment=Enum.TextXAlignment.Center; choiceLbl.Size=UDim2.new(1,0,1,0); choiceLbl.Parent=btn
    local menu=Make("Frame",{Visible=false,BackgroundColor3=Theme.Panel2,Size=UDim2.new(0,140,0,(#options*28)+8),Position=UDim2.new(1,-140,1,6)},{uiCorner(10),uiStroke(1,Color3.fromRGB(255,255,255),0.8),uiPadding(6,6,6,6)}); menu.Parent=row
    local list=Make("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0, -- Continue Dropdown
Spacing=UDim.new(0,4)}); list.Parent=menu

local selected = options[defaultIndex] or options[1]
choiceLbl.Text = selected

for _,opt in ipairs(options) do
    local btnOption = Make("TextButton", {
        Size=UDim2.new(1,0,0,24),
        BackgroundColor3=Theme.Panel,
        AutoButtonColor=true,
        Font=Enum.Font.Gotham,
        TextSize=14,
        TextColor3=Color3.fromRGB(230,235,240),
        Text=opt
    }, {uiCorner(6)})
    btnOption.Parent = menu
    btnOption.MouseButton1Click:Connect(function()
        selected = opt
        choiceLbl.Text = opt
        menu.Visible = false
        if callback then task.spawn(function() callback(opt) end) end
    end)
end

btn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

return {Set=function(opt)
    if table.find(options,opt) then
        selected = opt
        choiceLbl.Text = opt
    end
end,
Get=function() return selected end,
Instance=row}-- Main Window
local screenGui = Make("ScreenGui",{Parent=plr:WaitForChild("PlayerGui"),IgnoreGuiInset=true,ResetOnSpawn=false})
local mainFrame = Make("Frame",{Size=UDim2.new(0,480,0,340),Position=UDim2.new(0.5,-240,0.5,-170),BackgroundColor3=Theme.Bg},{uiCorner(16),uiStroke(2,Theme.Accent)})
mainFrame.Parent = screenGui

-- Header
local header = Make("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Theme.Panel},{uiCorner(16)})
header.Parent = mainFrame
local headerLabel = newLabel("MatrixHub UI",18)
headerLabel.Size = UDim2.new(1,0,1,0)
headerLabel.TextXAlignment = Enum.TextXAlignment.Center
headerLabel.Parent = header

makeDraggable(header, mainFrame)

-- Tabs Container
local tabsFrame = Make("Frame",{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,36),BackgroundColor3=Theme.Panel2},{uiCorner(16)})
tabsFrame.Parent = mainFrame

-- Pages
local pages = Make("Folder"); pages.Parent = mainFrame

local function CreateTab(name)
    local btn = Make("TextButton",{Text=name,BackgroundColor3=Theme.Panel2,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(230,235,240),TextSize=14,Size=UDim2.new(0,100,1,0),AutoButtonColor=true},{uiCorner(12)})
    btn.Parent = tabsFrame

    local page = Make("Frame",{Size=UDim2.new(1,0,1,-72),Position=UDim2.new(0,0,0,72),BackgroundColor3=Theme.Panel,Visible=false},{uiCorner(12)})
    page.Parent = pages

    btn.MouseButton1Click:Connect(function()
        for _,p in ipairs(pages:GetChildren()) do p.Visible=false end
        page.Visible=true
    end)

    return page
end

-- Example Tabs
local tab1 = CreateTab("Combat")
local tab2 = CreateTab("Visuals")
local tab3 = CreateTab("Misc")

-- Example Controls
Toggle(tab1,"Silent Aim",false,function(val) print("Silent Aim:",val) end)
Slider(tab1,"FOV",70,180,90,function(val) print("FOV:",val) end)
Dropdown(tab2,"ESP Mode",{"Boxes","Tracers","Skeleton"},1,function(opt) print("ESP:",opt) end)
