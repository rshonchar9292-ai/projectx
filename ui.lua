--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX UI — Animated Edition                              ║
--// ║  Smooth animations • Full English • Modern design             ║
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
    AccentDark = Color3.fromRGB(90, 110, 220),
    Success    = Color3.fromRGB(85, 220, 130),
    Danger     = Color3.fromRGB(240, 80, 95),
    Murderer   = Color3.fromRGB(255, 60, 60),
    Sheriff    = Color3.fromRGB(60, 150, 255),
    Innocent   = Color3.fromRGB(80, 220, 120),
    Text       = Color3.fromRGB(240, 240, 248),
    TextDim    = Color3.fromRGB(140, 140, 160),
    Stroke     = Color3.fromRGB(55, 55, 75),
    Shadow     = Color3.fromRGB(0, 0, 0),
}

--// ============================================================
--//  ANIMATION PRESETS
--// ============================================================
local Ease = {
    Smooth    = TweenInfo.new(0.22, Enum.EasingStyle.Quad,    Enum.EasingDirection.Out),
    Fast      = TweenInfo.new(0.14, Enum.EasingStyle.Quad,    Enum.EasingDirection.Out),
    Bounce    = TweenInfo.new(0.30, Enum.EasingStyle.Back,    Enum.EasingDirection.Out),
    Elastic   = TweenInfo.new(0.35, Enum.EasingStyle.Quint,   Enum.EasingDirection.Out),
    Slow      = TweenInfo.new(0.40, Enum.EasingStyle.Quart,   Enum.EasingDirection.Out),
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
--//  TOGGLE
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

        tw(Track, Ease.Smooth, {
            BackgroundColor3 = state and Theme.Success or Color3.fromRGB(58, 58, 74),
        })
        tw(Dot, Ease.Bounce, {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        })
        tw(Btn, Ease.Fast, {
            BackgroundColor3 = state and Color3.fromRGB(48, 60, 80) or Theme.Element,
        })

        callback(state)
    end)

    Btn.MouseEnter:Connect(function()
        if not state then tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.ElementHov }) end
    end)
    Btn.MouseLeave:Connect(function()
        if not state then tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.Element }) end
    end)
    return Btn
end

--// ============================================================
--//  SLIDER
--// ============================================================
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

    local FillGrad = gradient(Fill, Theme.Accent, Color3.fromRGB(180, 200, 255), 0)

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
            tw(Frame, Ease.Fast, { BackgroundColor3 = Theme.ElementHov })
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            tw(Knob, Ease.Smooth, { Size = UDim2.new(0, 12, 0, 12) })
            tw(Frame, Ease.Fast, { BackgroundColor3 = Theme.Element })
        end
    end)

    Frame.MouseEnter:Connect(function()
        if not dragging then tw(Frame, Ease.Fast, { BackgroundColor3 = Theme.ElementHov }) end
    end)
    Frame.MouseLeave:Connect(function()
        if not dragging then tw(Frame, Ease.Fast, { BackgroundColor3 = Theme.Element }) end
    end)
    return Frame
end

--// ============================================================
--//  SECTION
--// ============================================================
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
    LineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    LineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    LineGrad.Parent = Line

    return Lbl
end

--// ============================================================
--//  ACTION BUTTON
--// ============================================================
local function createActionButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -16, 0, 48)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    corner(Btn, 10)

    local grad = gradient(Btn, color, Color3.fromRGB(
        math.min(255, color.R * 255 + 60),
        math.min(255, color.G * 255 + 60),
        math.min(255, color.B * 255 + 60)
    ), 45)

    Btn.MouseEnter:Connect(function()
        tw(Btn, Ease.Smooth, { Size = UDim2.new(1, -16, 0, 52) })
    end)
    Btn.MouseLeave:Connect(function()
        tw(Btn, Ease.Smooth, { Size = UDim2.new(1, -16, 0, 48) })
    end)
    Btn.MouseButton1Click:Connect(function()
        createRipple(Btn, Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y)
        Btn.TextSize = 12
        task.wait(0.1)
        Btn.TextSize = 14
        callback()
    end)
    return Btn
end

--// ============================================================
--//  PLAYER ROW
--// ============================================================
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

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 34, 0, 34)
    avatar.Position = UDim2.new(0, 12, 0.5, -17)
    avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxassetid://0"
    avatar.Parent = row
    corner(avatar, 999)

    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and thumb and avatar.Parent then avatar.Image = thumb end
    end)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -100, 0, 18)
    nameLbl.Position = UDim2.new(0, 54, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.Name
    nameLbl.TextColor3 = Theme.Text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = row

    local roleLbl = Instance.new("TextLabel")
    roleLbl.Size = UDim2.new(1, -100, 0, 14)
    roleLbl.Position = UDim2.new(0, 54, 0, 24)
    roleLbl.BackgroundTransparency = 1
    roleLbl.Text = role
    roleLbl.TextColor3 = roleColor
    roleLbl.Font = Enum.Font.GothamBold
    roleLbl.TextSize = 11
    roleLbl.TextXAlignment = Enum.TextXAlignment.Left
    roleLbl.Parent = row

    local flingIcon = Instance.new("TextLabel")
    flingIcon.Size = UDim2.new(0, 30, 1, 0)
    flingIcon.Position = UDim2.new(1, -38, 0, 0)
    flingIcon.BackgroundTransparency = 1
    flingIcon.Text = "💥"
    flingIcon.TextSize = 16
    flingIcon.Parent = row

    row.MouseEnter:Connect(function()
        tw(row, Ease.Fast, { BackgroundColor3 = Theme.ElementHov })
        tw(stripe, Ease.Fast, { Size = UDim2.new(0, 4, 0.7, 0) })
    end)
    row.MouseLeave:Connect(function()
        tw(row, Ease.Fast, { BackgroundColor3 = Theme.Element })
        tw(stripe, Ease.Fast, { Size = UDim2.new(0, 3, 0.6, 0) })
    end)
    row.MouseButton1Click:Connect(function()
        createRipple(row, Mouse.X - row.AbsolutePosition.X, Mouse.Y - row.AbsolutePosition.Y)
        callback(plr)
    end)
    return row
end

--// ============================================================
--//  UI:init
--// ============================================================
function UI:init(Features)
    -- ScreenGui
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

    local FloatGrad = gradient(FloatingBtn, Theme.Accent, Color3.fromRGB(180, 120, 255), 45)

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

    FloatingBtn.MouseEnter:Connect(function()
        tw(FloatingBtn, Ease.Bounce, { Size = UDim2.new(0, 62, 0, 62) })
    end)
    FloatingBtn.MouseLeave:Connect(function()
        tw(FloatingBtn, Ease.Smooth, { Size = UDim2.new(0, 56, 0, 56) })
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

    local MainGrad = gradient(Main, Color3.fromRGB(28, 28, 40), Color3.fromRGB(14, 14, 20), 135)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 46)
    Header.BackgroundColor3 = Theme.Panel
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Parent = Main
    corner(Header, 16)

    local HeaderMask = Instance.new("Frame")
    HeaderMask.Size = UDim2.new(1, 0, 0, 14)
    HeaderMask.Position = UDim2.new(0, 0, 1, -14)
    HeaderMask.BackgroundColor3 = Theme.Panel
    HeaderMask.BackgroundTransparency = 0.3
    HeaderMask.BorderSizePixel = 0
    HeaderMask.Parent = Header

    local Logo = Instance.new("Frame")
    Logo.Size = UDim2.new(0, 26, 0, 26)
    Logo.Position = UDim2.new(0, 16, 0.5, -13)
    Logo.BackgroundColor3 = Theme.Accent
    Logo.BorderSizePixel = 0
    Logo.Parent = Header
    corner(Logo, 8)

    local LogoGrad = gradient(Logo, Theme.Accent, Color3.fromRGB(180, 120, 255), 45)

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "X"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 14
    LogoText.Parent = Logo

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

    local VersionLbl = Instance.new("TextLabel")
    VersionLbl.Size = UDim2.new(0, 60, 1, 0)
    VersionLbl.Position = UDim2.new(1, -100, 0, 0)
    VersionLbl.BackgroundTransparency = 1
    VersionLbl.Text = "v1.0"
    VersionLbl.TextColor3 = Theme.TextDim
    VersionLbl.Font = Enum.Font.Gotham
    VersionLbl.TextSize = 11
    VersionLbl.TextXAlignment = Enum.TextXAlignment.Right
    VersionLbl.Parent = Header

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

    CloseBtn.MouseEnter:Connect(function()
        tw(CloseBtn, Ease.Fast, { BackgroundColor3 = Theme.Danger })
    end)
    CloseBtn.MouseLeave:Connect(function()
        tw(CloseBtn, Ease.Fast, { BackgroundColor3 = Theme.Element })
    end)

    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 155, 1, -60)
    TabBar.Position = UDim2.new(0, 10, 0, 54)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabBar

    -- Content
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

    -- Tabs System
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

        Tabs[name] = { Button = Btn, Page = Page, Indicator = Indicator, Label = Label, Emoji = Emoji }

        local function activate()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                tw(t.Button, Ease.Fast, { BackgroundColor3 = Theme.Panel })
                tw(t.Indicator, Ease.Fast, { BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0.4, 0) })
                tw(t.Label, Ease.Fast, { TextColor3 = Theme.Text })
                tw(t.Emoji, Ease.Fast, { TextColor3 = Theme.Text })
            end
            Page.Visible = true
            Page.Position = UDim2.new(0, 20, 0, 0)
            tw(Page, Ease.Elastic, { Position = UDim2.new(0, 0, 0, 0) })
            tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.PanelLight })
            tw(Indicator, Ease.Elastic, {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 3, 0.7, 0),
                Position = UDim2.new(0, 0, 0.15, 0),
            })
            tw(Label, Ease.Fast, { TextColor3 = Theme.Accent })
            tw(Emoji, Ease.Fast, { TextColor3 = Theme.Accent })
            ActiveTab = name
        end

        Btn.MouseButton1Click:Connect(function()
            createRipple(Btn, Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y)
            activate()
        end)

        Btn.MouseEnter:Connect(function()
            if ActiveTab ~= name then
                tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.PanelLight })
                tw(Label, Ease.Fast, { TextColor3 = Theme.Text })
            end
        end)
        Btn.MouseLeave:Connect(function()
            if ActiveTab ~= name then
                tw(Btn, Ease.Fast, { BackgroundColor3 = Theme.Panel })
                tw(Label, Ease.Fast, { TextColor3 = Theme.Text })
            end
        end)

        return Page
    end

    -- 3 Tabs
    local MovePage  = createTab("Movement", "M")
    local FlingPage = createTab("Fling", "F")
    local AnimPage  = createTab("Animation", "A")

    -- ==================================================
    -- MOVEMENT TAB
    -- ==================================================
    createSection(MovePage, "Speed")

    createToggle(MovePage, "Enable Speed", false, function(v)
        if Features.Movement then Features.Movement:setSpeed(v) end
    end)
    createSlider(MovePage, "Speed Value", 16, 200, 32, function(v)
        if Features.Movement and Features.Movement.setSpeedValue then
            Features.Movement:setSpeedValue(v)
        end
    end)

    createSection(MovePage, "Fly")

    createToggle(MovePage, "Enable Fly", false, function(v)
        if Features.Movement then Features.Movement:setFly(v) end
    end)
    createSlider(MovePage, "Fly Speed", 10, 200, 60, function(v)
        if Features.Movement and Features.Movement.setFlySpeed then
            Features.Movement:setFlySpeed(v)
        end
    end)

    createSection(MovePage, "Noclip")

    createToggle(MovePage, "Enable Noclip", false, function(v)
        if Features.Movement then Features.Movement:setNoclip(v) end
    end)

    -- ==================================================
    -- FLING TAB
    -- ==================================================
    createSection(FlingPage, "Quick Actions")

    createActionButton(FlingPage, "FLING SHERIFF", Theme.Sheriff, function()
        if Features.Fling then Features.Fling:flingSheriff() end
    end)
    createActionButton(FlingPage, "FLING MURDER", Theme.Murderer, function()
        if Features.Fling then Features.Fling:flingMurderer() end
    end)

    createSection(FlingPage, "Players — Click to Fling")

    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(1, -16, 0, 320)
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
    playerListScroll.ScrollBarImageColor3 = Theme.Accent
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    playerListScroll.Parent = playerListFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
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
        while task.wait(3) do
            pcall(refreshPlayerList)
        end
    end)

    -- ==================================================
    -- ANIMATION TAB
    -- ==================================================
    createSection(AnimPage, "R15 Animation Sets")

    local animInfoFrame = Instance.new("Frame")
    animInfoFrame.Size = UDim2.new(1, -16, 0, 42)
    animInfoFrame.BackgroundColor3 = Theme.Element
    animInfoFrame.BorderSizePixel = 0
    animInfoFrame.Parent = AnimPage
    corner(animInfoFrame, 10)

    local animInfoText = Instance.new("TextLabel")
    animInfoText.Size = UDim2.new(1, -20, 1, 0)
    animInfoText.Position = UDim2.new(0, 10, 0, 0)
    animInfoText.BackgroundTransparency = 1
    animInfoText.Text = "Works only on R15 characters. Click to apply."
    animInfoText.TextColor3 = Theme.TextDim
    animInfoText.Font = Enum.Font.Gotham
    animInfoText.TextSize = 11
    animInfoText.TextXAlignment = Enum.TextXAlignment.Left
    animInfoText.TextYAlignment = Enum.TextYAlignment.Center
    animInfoText.Parent = animInfoFrame

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
    animScroll.BorderSizePixel = 0
    animScroll.ScrollBarThickness = 3
    animScroll.ScrollBarImageColor3 = Theme.Accent
    animScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    animScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    animScroll.Parent = animListFrame

    local animListLayout = Instance.new("UIListLayout")
    animListLayout.Padding = UDim.new(0, 4)
    animListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    animListLayout.Parent = animScroll

    local animButtons = {}
    local activeAnimName = nil

    local function setActiveAnim(name)
        for animName, btn in pairs(animButtons) do
            if animName == name then
                tw(btn, Ease.Fast, { BackgroundColor3 = Theme.Accent })
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tw(btn, Ease.Fast, { BackgroundColor3 = Theme.Element })
                btn.TextColor3 = Theme.Text
            end
        end
        activeAnimName = name
    end

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

            btn.MouseEnter:Connect(function()
                if activeAnimName ~= name then
                    tw(btn, Ease.Fast, { BackgroundColor3 = Theme.ElementHov })
                end
            end)
            btn.MouseLeave:Connect(function()
                if activeAnimName ~= name then
                    tw(btn, Ease.Fast, { BackgroundColor3 = Theme.Element })
                end
            end)
            btn.MouseButton1Click:Connect(function()
                createRipple(btn, Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y)
                if Features.Animation then
                    Features.Animation:playAnimationSet(name)
                    setActiveAnim(name)
                end
            end)

            animButtons[name] = btn
        end
    end

    createSection(AnimPage, "Controls")

    createActionButton(AnimPage, "RESET ANIMATIONS", Theme.Danger, function()
        if Features.Animation then
            Features.Animation:reset()
            for _, btn in pairs(animButtons) do
                tw(btn, Ease.Fast, { BackgroundColor3 = Theme.Element })
                btn.TextColor3 = Theme.Text
            end
            activeAnimName = nil
        end
    end)

    -- Activate first tab
    Tabs["Movement"].Page.Visible = true
    ActiveTab = "Movement"
    Tabs["Movement"].Button.BackgroundColor3 = Theme.PanelLight
    Tabs["Movement"].Indicator.BackgroundTransparency = 0
    Tabs["Movement"].Indicator.Size = UDim2.new(0, 3, 0.7, 0)
    Tabs["Movement"].Indicator.Position = UDim2.new(0, 0, 0.15, 0)
    Tabs["Movement"].Label.TextColor3 = Theme.Accent
    Tabs["Movement"].Emoji.TextColor3 = Theme.Accent

    -- Open / Close animations
    local isOpen = false
    local opening = false

    local function openPanel()
        if isOpen or opening then return end
        opening = true
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        tw(Main, Ease.Enter, { Size = UDim2.new(0, 560, 0, 500) })
        tw(FloatingBtn, Ease.Smooth, { BackgroundTransparency = 0.6 })
        task.delay(0.32, function() isOpen = true; opening = false end)
    end

    local function closePanel()
        if not isOpen then return end
        isOpen = false
        local t = tw(Main, Ease.Exit, { Size = UDim2.new(0, 0, 0, 0) })
        t.Completed:Connect(function() Main.Visible = false end)
        tw(FloatingBtn, Ease.Smooth, { BackgroundTransparency = 0 })
    end

    FloatingBtn.MouseButton1Click:Connect(function()
        if isOpen then closePanel() else openPanel() end
    end)

    CloseBtn.MouseButton1Click:Connect(closePanel)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F4 then
            if isOpen then closePanel() else openPanel() end
        end
    end)

    -- Drag Float
    local draggingFloat, dragFloatStart, floatStartPos
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFloat = true
            dragFloatStart = input.Position
            floatStartPos = FloatingBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingFloat and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragFloatStart
            FloatingBtn.Position = UDim2.new(
                floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFloat = false end
    end)

    -- Drag Main
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
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
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
