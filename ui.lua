--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX UI — Animated Edition (Final)                      ║
--// ╚══════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local UI = {}

--// ============================================================
--//  THEME
--// ============================================================
local Theme = {
    Bg         = Color3.fromRGB(13, 13, 18),
    Panel      = Color3.fromRGB(20, 20, 28),
    PanelLight = Color3.fromRGB(28, 28, 38),
    Element    = Color3.fromRGB(35, 35, 46),
    ElementHov = Color3.fromRGB(45, 45, 58),
    Accent     = Color3.fromRGB(130, 150, 255),
    Success    = Color3.fromRGB(85, 220, 130),
    Danger     = Color3.fromRGB(240, 80, 95),
    Text       = Color3.fromRGB(240, 240, 248),
    TextDim    = Color3.fromRGB(140, 140, 160),
    Stroke     = Color3.fromRGB(55, 55, 75),
}

local Ease = {
    Smooth    = TweenInfo.new(0.22, Enum.EasingStyle.Quad,    Enum.EasingDirection.Out),
    Fast      = TweenInfo.new(0.14, Enum.EasingStyle.Quad,    Enum.EasingDirection.Out),
    Bounce    = TweenInfo.new(0.30, Enum.EasingStyle.Back,    Enum.EasingDirection.Out),
    Elastic   = TweenInfo.new(0.35, Enum.EasingStyle.Quint,   Enum.EasingDirection.Out),
    Enter     = TweenInfo.new(0.32, Enum.EasingStyle.Back,    Enum.EasingDirection.Out),
    Exit      = TweenInfo.new(0.20, Enum.EasingStyle.Quad,    Enum.EasingDirection.In),
}

--// ============================================================
--//  HELPERS
--// ============================================================
local function tw(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(color1, color2)
    g.Rotation = rotation or 45
    g.Parent = parent
    return g
end

local function createRipple(parent, x, y)
    local r = Instance.new("Frame")
    r.AnchorPoint = Vector2.new(0.5, 0.5)
    r.Size = UDim2.new(0, 0, 0, 0)
    r.Position = UDim2.new(0, x, 0, y)
    r.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    r.BackgroundTransparency = 0.7
    r.BorderSizePixel = 0
    r.ZIndex = 10
    r.Parent = parent
    corner(r, 999)
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    local t = tw(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    })
    t.Completed:Connect(function() r:Destroy() end)
end

--// ============================================================
--//  UI COMPONENTS
--// ============================================================
local function createToggle(parent, text, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -16, 0, 38)
    Btn.BackgroundColor3 = Theme.Element
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    corner(Btn, 9)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 40, 0, 22)
    Track.Position = UDim2.new(1, -54, 0.5, -11)
    Track.BackgroundColor3 = default and Theme.Success or Color3.fromRGB(58, 58, 74)
    Track.BorderSizePixel = 0
    Track.Parent = Btn
    corner(Track, 999)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Track
    corner(Dot, 999)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        createRipple(Btn, Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y)
        state = not state
        tw(Track, Ease.Smooth, { BackgroundColor3 = state and Theme.Success or Color3.fromRGB(58, 58, 74) })
        tw(Dot, Ease.Bounce, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
        tw(Btn, Ease.Fast, { BackgroundColor3 = state and Color3.fromRGB(48, 60, 80) or Theme.Element })
        callback(state)
    end)

    Btn.MouseEnter:Connect(function() if not state then tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.ElementHov }) end end)
    Btn.MouseLeave:Connect(function() if not state then tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.Element }) end end)
    return Btn
end

local function createSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 56)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    corner(Frame, 9)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 0, 18)
    Label.Position = UDim2.new(0, 14, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLbl = Instance.new("TextLabel")
    ValueLbl.Size = UDim2.new(0, 80, 0, 18)
    ValueLbl.Position = UDim2.new(1, -94, 0, 6)
    ValueLbl.BackgroundTransparency = 1
    ValueLbl.Text = tostring(default)
    ValueLbl.TextColor3 = Theme.Accent
    ValueLbl.Font = Enum.Font.GothamBold
    ValueLbl.TextSize = 12
    ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValueLbl.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 6)
    Bar.Position = UDim2.new(0, 14, 0, 36)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 66)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame
    corner(Bar, 999)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    corner(Fill, 999)

    local Knob = Instance.new("Frame")
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Bar
    corner(Knob, 999)
    stroke(Knob, Theme.Accent, 2, 0)

    local dragging = false
    local function update(input)
        local alpha = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * alpha + 0.5)
        Fill.Size = UDim2.new(alpha, 0, 1, 0)
        Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        ValueLbl.Text = tostring(value)
        callback(value)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
            tw(Knob, Ease.Bounce, { Size = UDim2.new(0, 16, 0, 16) })
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            tw(Knob, Ease.Smooth, { Size = UDim2.new(0, 12, 0, 12) })
        end
    end)
    return Frame
end

local function createSection(parent, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -16, 0, 24)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "  " .. text:upper()
    Lbl.TextColor3 = Theme.TextDim
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 10
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = parent

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -20, 0, 1)
    Line.Position = UDim2.new(0, 10, 0, 22)
    Line.BackgroundColor3 = Theme.Stroke
    Line.BorderSizePixel = 0
    Line.Parent = Lbl

    local LineGrad = Instance.new("UIGradient")
    LineGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })
    LineGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
    LineGrad.Parent = Line
    return Lbl
end

local function createPlayerRow(parent, plr, role, roleColor, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -8, 0, 48)
    row.BackgroundColor3 = Theme.Element
    row.Text = ""
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Parent = parent
    corner(row, 10)

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 3, 0.6, 0)
    stripe.Position = UDim2.new(0, 0, 0.2, 0)
    stripe.BackgroundColor3 = roleColor
    stripe.BorderSizePixel = 0
    stripe.Parent = row
    corner(stripe, 999)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -100, 0, 18)
    nameLbl.Position = UDim2.new(0, 14, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.Name
    nameLbl.TextColor3 = Theme.Text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row

    local roleLbl = Instance.new("TextLabel")
    roleLbl.Size = UDim2.new(1, -100, 0, 14)
    roleLbl.Position = UDim2.new(0, 14, 0, 24)
    roleLbl.BackgroundTransparency = 1
    roleLbl.Text = role
    roleLbl.TextColor3 = roleColor
    roleLbl.Font = Enum.Font.GothamBold
    roleLbl.TextSize = 11
    roleLbl.TextXAlignment = Enum.TextXAlignment.Left
    roleLbl.Parent = row

    row.MouseEnter:Connect(function() tw(row, Ease.Fast, { BackgroundColor3 = Theme.ElementHov }) end)
    row.MouseLeave:Connect(function() tw(row, Ease.Fast, { BackgroundColor3 = Theme.Element }) end)
    row.MouseButton1Click:Connect(function()
        createRipple(row, Mouse.X - row.AbsolutePosition.X, Mouse.Y - row.AbsolutePosition.Y)
        callback(plr)
    end)
    return row
end

--// ============================================================
--//  MAIN UI INIT
--// ============================================================
function UI:init(Features)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ProjectXUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Floating Button
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 56, 0, 56)
    FloatingBtn.Position = UDim2.new(0, 30, 0.5, -28)
    FloatingBtn.BackgroundColor3 = Theme.Accent
    FloatingBtn.Text = ""
    FloatingBtn.BorderSizePixel = 0
    FloatingBtn.AutoButtonColor = false
    FloatingBtn.Parent = ScreenGui
    corner(FloatingBtn, 999)
    stroke(FloatingBtn, Color3.fromRGB(255, 255, 255), 2, 0.6)
    gradient(FloatingBtn, Theme.Accent, Color3.fromRGB(180, 120, 255), 45)

    local FloatIcon = Instance.new("TextLabel")
    FloatIcon.Size = UDim2.new(1, 0, 1, 0)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Text = "X"
    FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatIcon.TextSize = 26
    FloatIcon.Font = Enum.Font.GothamBold
    FloatIcon.Parent = FloatingBtn

    task.spawn(function()
        while FloatingBtn.Parent do
            tw(FloatIcon, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextSize = 28 })
            task.wait(1.5)
            tw(FloatIcon, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextSize = 24 })
            task.wait(1.5)
        end
    end)

    -- Main Window
    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = Theme.Bg
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Active = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    corner(Main, 16)
    stroke(Main, Theme.Stroke, 1.5, 0.3)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 46)
    Header.BackgroundColor3 = Theme.Panel
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Parent = Main
    corner(Header, 16)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 52, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ProjectX"
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
    CloseBtn.BackgroundColor3 = Theme.Element
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.BorderSizePixel = 0
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Header
    corner(CloseBtn, 8)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 155, 1, -60)
    TabBar.Position = UDim2.new(0, 10, 0, 54)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabBar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -183, 1, -60)
    Content.Position = UDim2.new(0, 173, 0, 54)
    Content.BackgroundColor3 = Theme.Panel
    Content.BorderSizePixel = 0
    Content.Parent = Main
    corner(Content, 12)

    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingTop = UDim.new(0, 8)
    ContentPad.PaddingLeft = UDim.new(0, 8)
    ContentPad.PaddingRight = UDim.new(0, 8)
    ContentPad.PaddingBottom = UDim.new(0, 8)
    ContentPad.Parent = Content

    local Tabs = {}
    local ActiveTab = nil

    local function createTab(name, letter)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.BackgroundColor3 = Theme.Panel
        Btn.Text = ""
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = false
        Btn.Parent = TabBar
        corner(Btn, 10)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0.4, 0)
        Indicator.Position = UDim2.new(0, 0, 0.3, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.BackgroundTransparency = 1
        Indicator.Parent = Btn
        corner(Indicator, 999)

        local Emoji = Instance.new("TextLabel")
        Emoji.Size = UDim2.new(0, 24, 1, 0)
        Emoji.Position = UDim2.new(0, 14, 0, 0)
        Emoji.BackgroundTransparency = 1
        Emoji.Text = letter
        Emoji.TextColor3 = Theme.Text
        Emoji.TextSize = 15
        Emoji.TextXAlignment = Enum.TextXAlignment.Left
        Emoji.Parent = Btn

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -46, 1, 0)
        Label.Position = UDim2.new(0, 42, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Theme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.ScrollBarImageTransparency = 0.4
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 6)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Page

        Tabs[name] = { Button = Btn, Page = Page, Indicator = Indicator, Label = Label }

        local function activate()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                tw(t.Button, Ease.Fast, { BackgroundColor3 = Theme.Panel })
                tw(t.Indicator, Ease.Fast, { BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0.4, 0) })
                tw(t.Label, Ease.Fast, { TextColor3 = Theme.Text })
            end
            Page.Visible = true
            tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.PanelLight })
            tw(Indicator, Ease.Elastic, { BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0.7, 0) })
            tw(Label, Ease.Fast, { TextColor3 = Theme.Accent })
            ActiveTab = name
        end

        Btn.MouseButton1Click:Connect(function()
            createRipple(Btn, Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y)
            activate()
        end)

        return Page
    end

    -- Вкладки
    local MovePage  = createTab("Movement", "M")
    local FlingPage = createTab("Fling", "F")
    local AnimPage  = createTab("Animation", "A")
    local EmotePage = createTab("Emotes", "E")

    -- ==================================================
    -- 1. MOVEMENT TAB
    -- ==================================================
    createSection(MovePage, "Speed")
    createToggle(MovePage, "Enable Speed", false, function(v)
        if Features.Movement then Features.Movement:setSpeed(v) end
    end)
    createSlider(MovePage, "Speed Value", 16, 200, 32, function(v)
        if Features.Movement and Features.Movement.setSpeedValue then Features.Movement:setSpeedValue(v) end
    end)

    createSection(MovePage, "Fly")
    createToggle(MovePage, "Enable Fly", false, function(v)
        if Features.Movement then Features.Movement:setFly(v) end
    end)
    createSlider(MovePage, "Fly Speed", 10, 200, 60, function(v)
        if Features.Movement and Features.Movement.setFlySpeed then Features.Movement:setFlySpeed(v) end
    end)

    createSection(MovePage, "Noclip")
    createToggle(MovePage, "Enable Noclip", false, function(v)
        if Features.Movement then Features.Movement:setNoclip(v) end
    end)

    createSection(MovePage, "Shahed & Rocket")
    createToggle(MovePage, "Enable Shahed (Key: G)", false, function(v)
        if Features.Shahed and Features.Shahed.setEnabled then Features.Shahed:setEnabled(v) end
    end)
    createToggle(MovePage, "Enable Rocket (Key: H)", false, function(v)
        if Features.Rocket and Features.Rocket.setEnabled then Features.Rocket:setEnabled(v) end
    end)

    -- ==================================================
    -- 2. FLING TAB
    -- ==================================================
    createSection(FlingPage, "Players — Click to Fling")
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(1, -16, 0, 380)
    playerListFrame.BackgroundColor3 = Theme.Element
    playerListFrame.BorderSizePixel = 0
    playerListFrame.Parent = FlingPage
    corner(playerListFrame, 10)

    local playerListScroll = Instance.new("ScrollingFrame")
    playerListScroll.Size = UDim2.new(1, -8, 1, -8)
    playerListScroll.Position = UDim2.new(0, 4, 0, 4)
    playerListScroll.BackgroundTransparency = 1
    playerListScroll.BorderSizePixel = 0
    playerListScroll.ScrollBarThickness = 3
    playerListScroll.Parent = playerListFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = playerListScroll

    local function refreshPlayerList()
        for _, child in ipairs(playerListScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        if not Features.Fling or not Features.Fling.getPlayersWithRoles then return end
        local list = Features.Fling:getPlayersWithRoles()
        for _, data in ipairs(list) do
            createPlayerRow(playerListScroll, data.player, data.role, data.color, function(plr)
                if Features.Fling then Features.Fling:flingPlayer(plr) end
            end)
        end
    end

    task.spawn(function()
        task.wait(1)
        pcall(refreshPlayerList)
        while task.wait(3) do pcall(refreshPlayerList) end
    end)

    -- ==================================================
    -- 3. ANIMATION TAB
    -- ==================================================
    createSection(AnimPage, "R15 Animation Sets")
    local animListFrame = Instance.new("Frame")
    animListFrame.Size = UDim2.new(1, -16, 0, 400)
    animListFrame.BackgroundColor3 = Theme.Element
    animListFrame.BorderSizePixel = 0
    animListFrame.Parent = AnimPage
    corner(animListFrame, 10)

    local animScroll = Instance.new("ScrollingFrame")
    animScroll.Size = UDim2.new(1, -8, 1, -8)
    animScroll.Position = UDim2.new(0, 4, 0, 4)
    animScroll.BackgroundTransparency = 1
    animScroll.ScrollBarThickness = 3
    animScroll.Parent = animListFrame

    local animListLayout = Instance.new("UIListLayout")
    animListLayout.Padding = UDim.new(0, 4)
    animListLayout.Parent = animScroll

    if Features.Animation and Features.Animation.getAnimationList then
        local list = Features.Animation:getAnimationList()
        for _, name in ipairs(list) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 34)
            btn.BackgroundColor3 = Theme.Element
            btn.Text = name
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Parent = animScroll
            corner(btn, 7)

            btn.MouseButton1Click:Connect(function()
                if Features.Animation then Features.Animation:playAnimationSet(name) end
            end)
        end
    end

    -- ==================================================
    -- 4. EMOTES TAB (З пошуком та картинками)
    -- ==================================================
    createSection(EmotePage, "Settings")
    createToggle(EmotePage, "Freeze Emote (Walk with emote)", false, function(v)
        if Features.Emotes and Features.Emotes.setFreeze then
            Features.Emotes:setFreeze(v)
        end
    end)

    createSection(EmotePage, "Search & Play")
    
    -- Пошуковий рядок
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -16, 0, 40)
    searchFrame.BackgroundColor3 = Theme.Element
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = EmotePage
    corner(searchFrame, 10)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 1, 0)
    searchBox.Position = UDim2.new(0, 10, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Пошук емоції (напр. dance, wave...)"
    searchBox.Text = ""
    searchBox.TextColor3 = Theme.Text
    searchBox.PlaceholderColor3 = Theme.TextDim
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame

    -- Список емоцій
    local emoteListFrame = Instance.new("Frame")
    emoteListFrame.Size = UDim2.new(1, -16, 0, 350)
    emoteListFrame.BackgroundColor3 = Theme.Element
    emoteListFrame.BorderSizePixel = 0
    emoteListFrame.Parent = EmotePage
    corner(emoteListFrame, 10)

    local emoteScroll = Instance.new("ScrollingFrame")
    emoteScroll.Size = UDim2.new(1, -8, 1, -8)
    emoteScroll.Position = UDim2.new(0, 4, 0, 4)
    emoteScroll.BackgroundTransparency = 1
    emoteScroll.ScrollBarThickness = 3
    emoteScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    emoteScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    emoteScroll.Parent = emoteListFrame

    local emoteLayout = Instance.new("UIListLayout")
    emoteLayout.Padding = UDim.new(0, 4)
    emoteLayout.Parent = emoteScroll

    local function refreshEmoteList(query)
        for _, child in ipairs(emoteScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        if not Features.Emotes or not Features.Emotes.searchEmotes then return end
        local results = Features.Emotes:searchEmotes(query)

        for _, emote in ipairs(results) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 48)
            btn.BackgroundColor3 = Theme.Element
            btn.Text = ""
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Parent = emoteScroll
            corner(btn, 7)

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 36, 0, 36)
            img.Position = UDim2.new(0, 6, 0.5, -18)
            img.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            img.BorderSizePixel = 0
            img.Image = "rbxthumb://type=Asset&id=" .. emote.id .. "&w=150&h=150"
            img.Parent = btn
            corner(img, 6)

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, -50, 1, 0)
            text.Position = UDim2.new(0, 50, 0, 0)
            text.BackgroundTransparency = 1
            text.Text = emote.name
            text.TextColor3 = Theme.Text
            text.Font = Enum.Font.GothamMedium
            text.TextSize = 13
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.Parent = btn

            btn.MouseEnter:Connect(function() tw(btn, Ease.Fast, { BackgroundColor3 = Theme.ElementHov }) end)
            btn.MouseLeave:Connect(function() tw(btn, Ease.Fast, { BackgroundColor3 = Theme.Element }) end)
            
            btn.MouseButton1Click:Connect(function()
                createRipple(btn, Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y)
                if Features.Emotes and Features.Emotes.playEmote then
                    Features.Emotes:playEmote(emote.name, emote.id)
                end
            end)
        end
    end

    task.spawn(function()
        task.wait(0.5)
        refreshEmoteList("")
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshEmoteList(searchBox.Text)
    end)

    -- ==================================================
    -- Активація першої вкладки та логіка вікна
    -- ==================================================
    Tabs["Movement"].Page.Visible = true
    ActiveTab = "Movement"
    Tabs["Movement"].Button.BackgroundColor3 = Theme.PanelLight
    Tabs["Movement"].Indicator.BackgroundTransparency = 0
    Tabs["Movement"].Indicator.Size = UDim2.new(0, 3, 0.7, 0)
    Tabs["Movement"].Label.TextColor3 = Theme.Accent

    local isOpen = false
    local opening = false

    local function openPanel()
        if isOpen or opening then return end
        opening = true
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        tw(Main, Ease.Enter, { Size = UDim2.new(0, 560, 0, 500) })
        task.delay(0.32, function() isOpen = true; opening = false end)
    end

    local function closePanel()
        if not isOpen then return end
        isOpen = false
        local t = tw(Main, Ease.Exit, { Size = UDim2.new(0, 0, 0, 0) })
        t.Completed:Connect(function() Main.Visible = false end)
    end

    FloatingBtn.MouseButton1Click:Connect(function() if isOpen then closePanel() else openPanel() end end)
    CloseBtn.MouseButton1Click:Connect(closePanel)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F4 then
            if isOpen then closePanel() else openPanel() end
        end
    end)

    -- Перетягування вікна
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    task.wait(0.3)
    openPanel()

    self.Main = Main
    self.Tabs = Tabs
    self.ScreenGui = ScreenGui
    self.FloatingBtn = FloatingBtn
end

return UI
