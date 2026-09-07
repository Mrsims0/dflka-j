local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function GetSafeGuiParent(customParent)
    if customParent and typeof(customParent) == "Instance" and customParent.Parent then
        return customParent
    end
    if typeof(gethui) == "function" then
        local success, hui = pcall(gethui)
        if success and hui and typeof(hui) == "Instance" then
            return hui
        end
    end
    local coreOk, coreResult = pcall(function()
        local test = Instance.new("Folder")
        test.Name = "MemeSense_Test"
        test.Parent = CoreGui
        test:Destroy()
        return CoreGui
    end)
    if coreOk and coreResult then
        return coreResult
    end
    if LocalPlayer then
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then return pGui end
        local ok, res = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 3) end)
        if ok and res then return res end
    end
    return game:GetService("StarterGui")
end

local MemeSense = {
    Themes = {
        Default = {
            TopGradient = {
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 140, 40)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 45, 80)),
                ColorSequenceKeypoint.new(0.70, Color3.fromRGB(235, 30, 110)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(160, 40, 210)),
            },
            Accent = Color3.fromRGB(235, 45, 75),
            AccentHover = Color3.fromRGB(255, 60, 90),
            MainBackground = Color3.fromRGB(16, 16, 19),
            SidebarBackground = Color3.fromRGB(13, 13, 15),
            ContentBackground = Color3.fromRGB(16, 16, 19),
            CardBackground = Color3.fromRGB(20, 20, 24),
            ItemFill = Color3.fromRGB(24, 24, 29),
            ItemBorder = Color3.fromRGB(38, 38, 46),
            ItemBorderHover = Color3.fromRGB(55, 55, 66),
            TextPrimary = Color3.fromRGB(240, 240, 245),
            TextSecondary = Color3.fromRGB(135, 135, 148),
            TextMuted = Color3.fromRGB(90, 90, 102),
            TrackBackground = Color3.fromRGB(32, 32, 38),
            SliderFill = Color3.fromRGB(165, 165, 178),
            Divider = Color3.fromRGB(26, 26, 32),
        }
    },
    Icons = {
        ["combat"]       = "rbxassetid://10709791437",
        ["legit"]        = "rbxassetid://10723346959",
        ["aimbot"]       = "rbxassetid://10723346959",
        ["rage"]         = "rbxassetid://10734975692",
        ["weapon mods"]  = "rbxassetid://10709810948",
        ["weapon"]       = "rbxassetid://10709810948",
        ["legitbot"]     = "rbxassetid://10723346959",
        ["aimassist"]    = "rbxassetid://10709791437",
        ["players"]      = "rbxassetid://10747373176",
        ["chams"]        = "rbxassetid://10723415766",
        ["items"]        = "rbxassetid://10709810948",
        ["visuals"]      = "rbxassetid://10723345518",
        ["world"]        = "rbxassetid://10723424838",
        ["view"]         = "rbxassetid://10709752035",
        ["indicators"]   = "rbxassetid://10723374641",
        ["miscellaneous"]= "rbxassetid://10723424012",
        ["misc"]         = "rbxassetid://10723424012",
        ["inventory"]    = "rbxassetid://10709751939",
        ["configs"]      = "rbxassetid://10723387563",
        ["cloud"]        = "rbxassetid://10709752254",
        ["keyboard"]     = "rbxassetid://10723396114",
        ["chevron"]      = "rbxassetid://10709790948",
        ["check"]        = "rbxassetid://10709790644",
        ["close"]        = "rbxassetid://10747384394",
        ["search"]       = "rbxassetid://10709753444",
        ["gear"]         = "rbxassetid://10709751759"
    }
}

local function ColorToHex(color)
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("%02X%02X%02X", r, g, b)
end

function MemeSense:GetIcon(iconKey)
    if not iconKey or iconKey == "" then return "" end
    if string.find(iconKey, "rbxassetid://") or string.find(iconKey, "http") then
        return iconKey
    end
    local lower = string.lower(iconKey)
    if MemeSense.Icons[lower] then
        return MemeSense.Icons[lower]
    end
    return iconKey
end

local function Tween(obj, props, duration, style, dir)
    duration = duration or 0.15
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    tween:Play()
    return tween
end

local function CreateColumnController(columnsContainer, colTitle, columnsList, Theme, Window, OverlayLayer)
    colTitle = colTitle or ""
    local ColumnFrame = Instance.new("Frame")
    ColumnFrame.Name = "Column_" .. colTitle
    ColumnFrame.BackgroundTransparency = 1
    ColumnFrame.Parent = columnsContainer

    local function RefreshColumnSizes()
        local totalCols = #columnsList
        local spacing = 14
        for idx, col in ipairs(columnsList) do
            col.Frame.Size = UDim2.new(1 / totalCols, -((totalCols - 1) * spacing) / totalCols, 1, 0)
            col.Frame.Position = UDim2.new((idx - 1) * (1 / totalCols), (idx - 1) * (spacing / totalCols), 0, 0)
        end
    end

    local HeaderHeight = (colTitle ~= "") and 24 or 0
    if colTitle ~= "" then
        local HeaderLabel = Instance.new("TextLabel")
        HeaderLabel.Name = "Header"
        HeaderLabel.Size = UDim2.new(1, 0, 0, 22)
        HeaderLabel.Position = UDim2.new(0, 0, 0, 0)
        HeaderLabel.BackgroundTransparency = 1
        HeaderLabel.Text = colTitle
        HeaderLabel.Font = Enum.Font.GothamMedium
        HeaderLabel.TextSize = 12
        HeaderLabel.TextColor3 = Theme.TextSecondary
        HeaderLabel.TextXAlignment = Enum.TextXAlignment.Center
        HeaderLabel.Parent = ColumnFrame
    end

    local ElementScroll = Instance.new("ScrollingFrame")
    ElementScroll.Name = "Elements"
    ElementScroll.Size = UDim2.new(1, 0, 1, -HeaderHeight)
    ElementScroll.Position = UDim2.new(0, 0, 0, HeaderHeight)
    ElementScroll.BackgroundTransparency = 1
    ElementScroll.BorderSizePixel = 0
    ElementScroll.ScrollBarThickness = 2
    ElementScroll.ScrollBarImageColor3 = Theme.ItemBorderHover
    ElementScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ElementScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ElementScroll.Parent = ColumnFrame

    local ElementLayout = Instance.new("UIListLayout")
    ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ElementLayout.Padding = UDim.new(0, 5)
    ElementLayout.Parent = ElementScroll

    local Column = {
        Frame = ColumnFrame,
        Scroll = ElementScroll,
        Elements = {}
    }
    table.insert(columnsList, Column)
    RefreshColumnSizes()

    function Column:CreateSection(sectionTitle)
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Name = "Section_" .. sectionTitle
        SectionLabel.Size = UDim2.new(1, 0, 0, 26)
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Text = sectionTitle
        SectionLabel.Font = Enum.Font.GothamMedium
        SectionLabel.TextSize = 12
        SectionLabel.TextColor3 = Theme.TextSecondary
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Center
        SectionLabel.LayoutOrder = #Column.Elements + 1
        SectionLabel.Parent = ElementScroll
        table.insert(Column.Elements, SectionLabel)
        return SectionLabel
    end

    function Column:CreateToggle(toggleConfig)
        toggleConfig = toggleConfig or {}
        local Name = toggleConfig.Name or "Toggle"
        local State = toggleConfig.Default or false
        local Callback = toggleConfig.Callback or function() end

        local ToggleRow = Instance.new("Frame")
        ToggleRow.Name = "Toggle_" .. Name
        ToggleRow.Size = UDim2.new(1, -6, 0, 22)
        ToggleRow.BackgroundTransparency = 1
        ToggleRow.LayoutOrder = #Column.Elements + 1
        ToggleRow.Parent = ElementScroll

        local ClickArea = Instance.new("TextButton")
        ClickArea.Name = "ClickArea"
        ClickArea.Size = UDim2.new(1, -60, 1, 0)
        ClickArea.BackgroundTransparency = 1
        ClickArea.Text = ""
        ClickArea.Parent = ToggleRow

        local Box = Instance.new("Frame")
        Box.Name = "Box"
        Box.Size = UDim2.new(0, 13, 0, 13)
        Box.Position = UDim2.new(0, 2, 0.5, -6)
        Box.BackgroundColor3 = State and Theme.Accent or Theme.ItemFill
        Box.BorderSizePixel = 0
        Box.Parent = ClickArea

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 2)
        BoxCorner.Parent = Box

        local BoxStroke = Instance.new("UIStroke")
        BoxStroke.Color = State and Theme.Accent or Theme.ItemBorder
        BoxStroke.Thickness = 1
        BoxStroke.Parent = Box

        local CheckImg = Instance.new("ImageLabel")
        CheckImg.Name = "Check"
        CheckImg.Size = UDim2.new(1, -2, 1, -2)
        CheckImg.Position = UDim2.new(0, 1, 0, 1)
        CheckImg.BackgroundTransparency = 1
        CheckImg.Image = MemeSense.Icons.check
        CheckImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
        CheckImg.ImageTransparency = State and 0 or 1
        CheckImg.Parent = Box

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, -24, 1, 0)
        Label.Position = UDim2.new(0, 22, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextColor3 = State and Theme.TextPrimary or Theme.TextMuted
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ClickArea

        local GadgetContainer = Instance.new("Frame")
        GadgetContainer.Name = "Gadgets"
        GadgetContainer.Size = UDim2.new(0, 56, 1, 0)
        GadgetContainer.Position = UDim2.new(1, -56, 0, 0)
        GadgetContainer.BackgroundTransparency = 1
        GadgetContainer.Parent = ToggleRow

        local GadgetLayout = Instance.new("UIListLayout")
        GadgetLayout.FillDirection = Enum.FillDirection.Horizontal
        GadgetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        GadgetLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        GadgetLayout.SortOrder = Enum.SortOrder.LayoutOrder
        GadgetLayout.Padding = UDim.new(0, 4)
        GadgetLayout.Parent = GadgetContainer

        local function SetState(val)
            State = val
            if State then
                Tween(Box, {BackgroundColor3 = Theme.Accent}, 0.12)
                Tween(BoxStroke, {Color = Theme.Accent}, 0.12)
                CheckImg.ImageTransparency = 0
                Tween(Label, {TextColor3 = Theme.TextPrimary}, 0.12)
            else
                Tween(Box, {BackgroundColor3 = Theme.ItemFill}, 0.12)
                Tween(BoxStroke, {Color = Theme.ItemBorder}, 0.12)
                CheckImg.ImageTransparency = 1
                Tween(Label, {TextColor3 = Theme.TextMuted}, 0.12)
            end
            Callback(State)
        end

        ClickArea.MouseEnter:Connect(function()
            if not State then
                Tween(BoxStroke, {Color = Theme.ItemBorderHover}, 0.1)
                Tween(Label, {TextColor3 = Theme.TextSecondary}, 0.1)
            end
        end)
        ClickArea.MouseLeave:Connect(function()
            if not State then
                Tween(BoxStroke, {Color = Theme.ItemBorder}, 0.1)
                Tween(Label, {TextColor3 = Theme.TextMuted}, 0.1)
            end
        end)
        ClickArea.MouseButton1Click:Connect(function()
            SetState(not State)
        end)

        local ToggleObject = {
            Row = ToggleRow,
            Set = SetState,
            Get = function() return State end
        }

        function ToggleObject:AddKeybind(keybindConfig)
            keybindConfig = keybindConfig or {}
            local BindKey = keybindConfig.Default or Enum.KeyCode.Unknown
            local BindCallback = keybindConfig.Callback or function() end
            local Listening = false

            local BindButton = Instance.new("TextButton")
            BindButton.Name = "Keybind"
            BindButton.Size = UDim2.new(0, 20, 0, 16)
            BindButton.BackgroundColor3 = Theme.ItemFill
            BindButton.BorderSizePixel = 0
            BindButton.Text = ""
            BindButton.AutoButtonColor = false
            BindButton.LayoutOrder = 2
            BindButton.Parent = GadgetContainer

            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 3)
            BCorner.Parent = BindButton

            local BStroke = Instance.new("UIStroke")
            BStroke.Color = Theme.ItemBorder
            BStroke.Thickness = 1
            BStroke.Parent = BindButton

            local BIcon = Instance.new("ImageLabel")
            BIcon.Name = "Icon"
            BIcon.Size = UDim2.new(0, 11, 0, 11)
            BIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
            BIcon.BackgroundTransparency = 1
            BIcon.Image = MemeSense.Icons.keyboard
            BIcon.ImageColor3 = Theme.TextMuted
            BIcon.Parent = BindButton

            local BText = Instance.new("TextLabel")
            BText.Name = "Text"
            BText.Size = UDim2.new(1, 0, 1, 0)
            BText.BackgroundTransparency = 1
            BText.Font = Enum.Font.GothamMedium
            BText.TextSize = 10
            BText.TextColor3 = Theme.TextSecondary
            BText.Visible = false
            BText.Parent = BindButton

            local function FormatKey(k)
                if k == Enum.KeyCode.Unknown or not k then return "..." end
                if typeof(k) == "EnumItem" then
                    if k == Enum.UserInputType.MouseButton1 then return "M1" end
                    if k == Enum.UserInputType.MouseButton2 then return "M2" end
                    if k == Enum.UserInputType.MouseButton3 then return "M3" end
                    return string.upper(k.Name)
                end
                return tostring(k)
            end

            local function UpdateBindDisplay()
                if BindKey == Enum.KeyCode.Unknown or not BindKey then
                    BIcon.Visible = true
                    BText.Visible = false
                    BindButton.Size = UDim2.new(0, 20, 0, 16)
                else
                    BIcon.Visible = false
                    BText.Visible = true
                    BText.Text = FormatKey(BindKey)
                    local textLen = string.len(BText.Text)
                    BindButton.Size = UDim2.new(0, math.max(22, textLen * 7 + 8), 0, 16)
                end
            end
            UpdateBindDisplay()

            BindButton.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                BIcon.Visible = false
                BText.Visible = true
                BText.Text = "..."
                BText.TextColor3 = Theme.Accent
                BindButton.Size = UDim2.new(0, 24, 0, 16)

                local conn
                conn = UserInputService.InputBegan:Connect(function(input, processed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        conn:Disconnect()
                        Listening = false
                        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                            BindKey = Enum.KeyCode.Unknown
                        else
                            BindKey = input.KeyCode
                        end
                        BText.TextColor3 = Theme.TextSecondary
                        UpdateBindDisplay()
                        BindCallback(BindKey)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                        conn:Disconnect()
                        Listening = false
                        BindKey = input.UserInputType
                        BText.TextColor3 = Theme.TextSecondary
                        UpdateBindDisplay()
                        BindCallback(BindKey)
                    end
                end)
            end)

            return ToggleObject
        end

        function ToggleObject:AddColorPicker(cpConfig)
            cpConfig = cpConfig or {}
            local ColorVal = cpConfig.Default or Color3.fromRGB(139, 30, 63)
            local CPCallback = cpConfig.Callback or function() end

            local ColorBox = Instance.new("TextButton")
            ColorBox.Name = "ColorPickerInline"
            ColorBox.Size = UDim2.new(0, 14, 0, 14)
            ColorBox.BackgroundColor3 = ColorVal
            ColorBox.BorderSizePixel = 0
            ColorBox.Text = ""
            ColorBox.AutoButtonColor = false
            ColorBox.LayoutOrder = 1
            ColorBox.Parent = GadgetContainer

            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(0, 2)
            CCorner.Parent = ColorBox

            local CStroke = Instance.new("UIStroke")
            CStroke.Color = Theme.ItemBorder
            CStroke.Thickness = 1
            CStroke.Parent = ColorBox

            ColorBox.MouseButton1Click:Connect(function()
                Window:OpenColorPicker(ColorVal, function(newCol)
                    ColorVal = newCol
                    ColorBox.BackgroundColor3 = newCol
                    CPCallback(newCol)
                end, ColorBox)
            end)

            return ToggleObject
        end

        table.insert(Column.Elements, ToggleRow)
        return ToggleObject
    end

    function Column:CreateSlider(sliderConfig)
        sliderConfig = sliderConfig or {}
        local Name = sliderConfig.Name or "Slider"
        local Min = sliderConfig.Min or 0
        local Max = sliderConfig.Max or 100
        local Default = sliderConfig.Default or Min
        local Decimals = sliderConfig.Decimals or 0
        local Suffix = sliderConfig.Suffix or ""
        local Callback = sliderConfig.Callback or function() end

        local CurrentValue = math.clamp(Default, Min, Max)

        local SliderContainer = Instance.new("Frame")
        SliderContainer.Name = "Slider_" .. Name
        SliderContainer.Size = UDim2.new(1, -6, 0, 32)
        SliderContainer.BackgroundTransparency = 1
        SliderContainer.LayoutOrder = #Column.Elements + 1
        SliderContainer.Parent = ElementScroll

        local TextRow = Instance.new("Frame")
        TextRow.Name = "TextRow"
        TextRow.Size = UDim2.new(1, 0, 0, 16)
        TextRow.BackgroundTransparency = 1
        TextRow.Parent = SliderContainer

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextColor3 = Theme.TextPrimary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = TextRow

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Name = "Value"
        ValueLabel.Size = UDim2.new(0.35, 0, 1, 0)
        ValueLabel.Position = UDim2.new(0.65, 0, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamMedium
        ValueLabel.TextSize = 12
        ValueLabel.TextColor3 = Theme.TextPrimary
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = TextRow

        local TrackButton = Instance.new("TextButton")
        TrackButton.Name = "Track"
        TrackButton.Size = UDim2.new(1, 0, 0, 4)
        TrackButton.Position = UDim2.new(0, 0, 0, 22)
        TrackButton.BackgroundColor3 = Theme.TrackBackground
        TrackButton.BorderSizePixel = 0
        TrackButton.Text = ""
        TrackButton.AutoButtonColor = false
        TrackButton.Parent = SliderContainer

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 2)
        TrackCorner.Parent = TrackButton

        local Fill = Instance.new("Frame")
        Fill.Name = "Fill"
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.SliderFill
        Fill.BorderSizePixel = 0
        Fill.Parent = TrackButton

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 2)
        FillCorner.Parent = Fill

        local Thumb = Instance.new("Frame")
        Thumb.Name = "Thumb"
        Thumb.Size = UDim2.new(0, 6, 0, 6)
        Thumb.Position = UDim2.new(1, -3, 0.5, -3)
        Thumb.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        Thumb.BorderSizePixel = 0
        Thumb.Parent = Fill

        local ThumbCorner = Instance.new("UICorner")
        ThumbCorner.CornerRadius = UDim.new(0, 3)
        ThumbCorner.Parent = Thumb

        local function FormatVal(val)
            if Decimals > 0 then
                return string.format("%." .. tostring(Decimals) .. "f", val) .. Suffix
            else
                return tostring(math.floor(val + 0.5)) .. Suffix
            end
        end

        local function SetValue(val, ignoreCallback)
            local clamped = math.clamp(val, Min, Max)
            if Decimals > 0 then
                local factor = 10 ^ Decimals
                clamped = math.floor(clamped * factor + 0.5) / factor
            else
                clamped = math.floor(clamped + 0.5)
            end
            CurrentValue = clamped
            ValueLabel.Text = FormatVal(clamped)
            local percent = (Max > Min) and ((clamped - Min) / (Max - Min)) or 0
            Fill.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
            if not ignoreCallback then
                Callback(clamped)
            end
        end
        SetValue(CurrentValue, true)

        local Sliding = false
        local function UpdateFromMouse(inputX)
            local rel = (inputX - TrackButton.AbsolutePosition.X) / TrackButton.AbsoluteSize.X
            local newVal = Min + (Max - Min) * math.clamp(rel, 0, 1)
            SetValue(newVal)
        end

        TrackButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Sliding = true
                UpdateFromMouse(input.Position.X)
                Tween(Fill, {BackgroundColor3 = Theme.Accent}, 0.1)

                local conn1, conn2
                conn1 = UserInputService.InputChanged:Connect(function(changeInput)
                    if Sliding and (changeInput.UserInputType == Enum.UserInputType.MouseMovement or changeInput.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromMouse(changeInput.Position.X)
                    end
                end)
                conn2 = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        Sliding = false
                        Tween(Fill, {BackgroundColor3 = Theme.SliderFill}, 0.15)
                        conn1:Disconnect()
                        conn2:Disconnect()
                    end
                end)
            end
        end)

        local SliderObject = {
            Set = SetValue,
            Get = function() return CurrentValue end
        }

        table.insert(Column.Elements, SliderContainer)
        return SliderObject
    end

    function Column:CreateDropdown(dropConfig)
        dropConfig = dropConfig or {}
        local Name = dropConfig.Name or "Dropdown"
        local Options = dropConfig.Options or {}
        local Multi = dropConfig.Multi or false
        local Callback = dropConfig.Callback or function() end

        local Selected = nil
        if Multi then
            Selected = {}
            if type(dropConfig.Default) == "table" then
                for _, item in ipairs(dropConfig.Default) do
                    Selected[item] = true
                end
            end
        else
            Selected = dropConfig.Default or Options[1] or ""
        end

        local DropRow = Instance.new("Frame")
        DropRow.Name = "DropdownRow_" .. Name
        DropRow.Size = UDim2.new(1, -6, 0, 24)
        DropRow.BackgroundTransparency = 1
        DropRow.LayoutOrder = #Column.Elements + 1
        DropRow.Parent = ElementScroll

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, -110, 1, 0)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextColor3 = Theme.TextPrimary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = DropRow

        local DropButton = Instance.new("TextButton")
        DropButton.Name = "DropButton"
        DropButton.Size = UDim2.new(0, 105, 0, 22)
        DropButton.Position = UDim2.new(1, -105, 0.5, -11)
        DropButton.BackgroundColor3 = Theme.ItemFill
        DropButton.BorderSizePixel = 0
        DropButton.Text = ""
        DropButton.AutoButtonColor = false
        DropButton.Parent = DropRow

        local DCorner = Instance.new("UICorner")
        DCorner.CornerRadius = UDim.new(0, 3)
        DCorner.Parent = DropButton

        local DStroke = Instance.new("UIStroke")
        DStroke.Color = Theme.ItemBorder
        DStroke.Thickness = 1
        DStroke.Parent = DropButton

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Name = "Value"
        ValueLabel.Size = UDim2.new(1, -18, 1, 0)
        ValueLabel.Position = UDim2.new(0, 6, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamMedium
        ValueLabel.TextSize = 11
        ValueLabel.TextColor3 = Theme.TextPrimary
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
        ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        ValueLabel.Parent = DropButton

        local Chevron = Instance.new("ImageLabel")
        Chevron.Name = "Chevron"
        Chevron.Size = UDim2.new(0, 10, 0, 10)
        Chevron.Position = UDim2.new(1, -14, 0.5, -5)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = MemeSense.Icons.chevron
        Chevron.ImageColor3 = Theme.TextSecondary
        Chevron.Parent = DropButton

        local function GetDisplayText()
            if Multi then
                local list = {}
                for _, opt in ipairs(Options) do
                    if Selected[opt] then
                        table.insert(list, opt)
                    end
                end
                if #list == 0 then return "None" end
                return table.concat(list, ", ")
            else
                return tostring(Selected)
            end
        end

        local function UpdateDisplay()
            ValueLabel.Text = GetDisplayText()
        end
        UpdateDisplay()

        local IsDropdownOpen = false

        local function CloseDropdown()
            if not IsDropdownOpen then return end
            IsDropdownOpen = false
            Tween(Chevron, {Rotation = 0}, 0.15)
            Tween(DStroke, {Color = Theme.ItemBorder}, 0.15)
            Window:CloseActiveFloating()
        end

        local function OpenDropdownMenu()
            Window:CloseActiveFloating()
            IsDropdownOpen = true
            Tween(Chevron, {Rotation = 180}, 0.15)
            Tween(DStroke, {Color = Theme.Accent}, 0.15)

            local pos = DropButton.AbsolutePosition - Window.MainFrame.AbsolutePosition
            local size = DropButton.AbsoluteSize

            local FloatingFrame = Instance.new("Frame")
            FloatingFrame.Name = "DropdownFloating_" .. Name
            FloatingFrame.Size = UDim2.new(0, math.max(size.X, 115), 0, math.min(#Options * 22 + 6, 150))
            FloatingFrame.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y + 3)
            FloatingFrame.BackgroundColor3 = Theme.CardBackground
            FloatingFrame.BorderSizePixel = 0
            FloatingFrame.ZIndex = 850
            FloatingFrame.Parent = OverlayLayer

            local FCorner = Instance.new("UICorner")
            FCorner.CornerRadius = UDim.new(0, 3)
            FCorner.Parent = FloatingFrame

            local FStroke = Instance.new("UIStroke")
            FStroke.Color = Theme.ItemBorder
            FStroke.Thickness = 1
            FStroke.Parent = FloatingFrame

            local FScroll = Instance.new("ScrollingFrame")
            FScroll.Size = UDim2.new(1, -2, 1, -4)
            FScroll.Position = UDim2.new(0, 1, 0, 2)
            FScroll.BackgroundTransparency = 1
            FScroll.BorderSizePixel = 0
            FScroll.ScrollBarThickness = 2
            FScroll.ScrollBarImageColor3 = Theme.ItemBorderHover
            FScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            FScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            FScroll.ZIndex = 851
            FScroll.Parent = FloatingFrame

            local FLayout = Instance.new("UIListLayout")
            FLayout.SortOrder = Enum.SortOrder.LayoutOrder
            FLayout.Padding = UDim.new(0, 1)
            FLayout.Parent = FScroll

            for _, opt in ipairs(Options) do
                local OptButton = Instance.new("TextButton")
                OptButton.Size = UDim2.new(1, 0, 0, 20)
                OptButton.BackgroundTransparency = 1
                OptButton.Text = ""
                OptButton.AutoButtonColor = false
                OptButton.ZIndex = 852
                OptButton.Parent = FScroll

                local OptLabel = Instance.new("TextLabel")
                OptLabel.Size = UDim2.new(1, -12, 1, 0)
                OptLabel.Position = UDim2.new(0, 6, 0, 0)
                OptLabel.BackgroundTransparency = 1
                OptLabel.Text = tostring(opt)
                OptLabel.Font = Enum.Font.GothamMedium
                OptLabel.TextSize = 11
                local isSelected = Multi and Selected[opt] or (Selected == opt)
                OptLabel.TextColor3 = isSelected and Theme.Accent or Theme.TextSecondary
                OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                OptLabel.ZIndex = 853
                OptLabel.Parent = OptButton

                OptButton.MouseEnter:Connect(function()
                    Tween(OptLabel, {TextColor3 = Theme.TextPrimary}, 0.1)
                end)
                OptButton.MouseLeave:Connect(function()
                    local stillSelected = Multi and Selected[opt] or (Selected == opt)
                    if not stillSelected then
                        Tween(OptLabel, {TextColor3 = Theme.TextSecondary}, 0.1)
                    end
                end)

                OptButton.MouseButton1Click:Connect(function()
                    if Multi then
                        Selected[opt] = not Selected[opt]
                        isSelected = Selected[opt]
                        OptLabel.TextColor3 = isSelected and Theme.Accent or Theme.TextSecondary
                        UpdateDisplay()
                        Callback(Selected)
                    else
                        Selected = opt
                        UpdateDisplay()
                        Callback(Selected)
                        CloseDropdown()
                    end
                end)
            end

            Window:SetActiveFloating(FloatingFrame, DropButton, function()
                IsDropdownOpen = false
                Tween(Chevron, {Rotation = 0}, 0.15)
                Tween(DStroke, {Color = Theme.ItemBorder}, 0.15)
            end)
        end

        DropButton.MouseButton1Click:Connect(function()
            if IsDropdownOpen then
                CloseDropdown()
            else
                OpenDropdownMenu()
            end
        end)

        local DropObject = {
            Row = DropRow,
            Set = function(val)
                Selected = val
                UpdateDisplay()
                Callback(Selected)
            end,
            Get = function() return Selected end,
            SetVisible = function(self, isVis)
                if type(self) == "boolean" then isVis = self end
                DropRow.Visible = isVis
                if not isVis and IsDropdownOpen then
                    CloseDropdown()
                end
            end,
            Visible = function(self, isVis)
                if isVis == nil and type(self) == "boolean" then
                    isVis = self
                end
                if isVis ~= nil then
                    DropRow.Visible = isVis
                    if not isVis and IsDropdownOpen then
                        CloseDropdown()
                    end
                else
                    return DropRow.Visible
                end
            end
        }

        table.insert(Column.Elements, DropRow)
        return DropObject
    end

    function Column:CreateDualSelector(dualConfig)
        dualConfig = dualConfig or {}
        local Name = dualConfig.Name or "Selector"
        local Options = dualConfig.Options or {"Option 1", "Option 2"}
        local CurrentIdx = 1
        local Callback = dualConfig.Callback or function() end

        for idx, opt in ipairs(Options) do
            if opt == dualConfig.Default then
                CurrentIdx = idx
                break
            end
        end

        local Row = Instance.new("Frame")
        Row.Name = "DualRow_" .. Name
        Row.Size = UDim2.new(1, -6, 0, 22)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = #Column.Elements + 1
        Row.Parent = ElementScroll

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextColor3 = Theme.TextPrimary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row

        local Btn = Instance.new("TextButton")
        Btn.Name = "SelectorButton"
        Btn.Size = UDim2.new(0.5, 0, 1, 0)
        Btn.Position = UDim2.new(0.5, 0, 0, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = Options[CurrentIdx]
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 11
        Btn.TextColor3 = Theme.TextSecondary
        Btn.TextXAlignment = Enum.TextXAlignment.Right
        Btn.AutoButtonColor = false
        Btn.Parent = Row

        Btn.MouseEnter:Connect(function()
            Tween(Btn, {TextColor3 = Theme.TextPrimary}, 0.1)
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, {TextColor3 = Theme.TextSecondary}, 0.1)
        end)
        Btn.MouseButton1Click:Connect(function()
            CurrentIdx = CurrentIdx + 1
            if CurrentIdx > #Options then CurrentIdx = 1 end
            Btn.Text = Options[CurrentIdx]
            Callback(Options[CurrentIdx])
        end)

        table.insert(Column.Elements, Row)
        return {
            Set = function(val)
                Btn.Text = val
                Callback(val)
            end
        }
    end

    function Column:CreateButton(btnConfig)
        btnConfig = btnConfig or {}
        local Name = btnConfig.Name or "Button"
        local Callback = btnConfig.Callback or function() end

        local BtnFrame = Instance.new("TextButton")
        BtnFrame.Name = "Button_" .. Name
        BtnFrame.Size = UDim2.new(1, -6, 0, 24)
        BtnFrame.BackgroundColor3 = Theme.ItemFill
        BtnFrame.BorderSizePixel = 0
        BtnFrame.Text = ""
        BtnFrame.AutoButtonColor = false
        BtnFrame.LayoutOrder = #Column.Elements + 1
        BtnFrame.Parent = ElementScroll

        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 3)
        BCorner.Parent = BtnFrame

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = Theme.ItemBorder
        BStroke.Thickness = 1
        BStroke.Parent = BtnFrame

        local BLabel = Instance.new("TextLabel")
        BLabel.Size = UDim2.new(1, 0, 1, 0)
        BLabel.BackgroundTransparency = 1
        BLabel.Text = Name
        BLabel.Font = Enum.Font.GothamMedium
        BLabel.TextSize = 11
        BLabel.TextColor3 = Theme.TextPrimary
        BLabel.Parent = BtnFrame

        BtnFrame.MouseEnter:Connect(function()
            Tween(BtnFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}, 0.1)
            Tween(BStroke, {Color = Theme.ItemBorderHover}, 0.1)
        end)
        BtnFrame.MouseLeave:Connect(function()
            Tween(BtnFrame, {BackgroundColor3 = Theme.ItemFill}, 0.1)
            Tween(BStroke, {Color = Theme.ItemBorder}, 0.1)
        end)
        BtnFrame.MouseButton1Click:Connect(function()
            Tween(BtnFrame, {BackgroundColor3 = Theme.Accent}, 0.08)
            task.delay(0.12, function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.ItemFill}, 0.15)
            end)
            Callback()
        end)

        table.insert(Column.Elements, BtnFrame)
        return BtnFrame
    end

    function Column:CreateInput(inputConfig)
        inputConfig = inputConfig or {}
        local Name = inputConfig.Name or "Input"
        local Placeholder = inputConfig.Placeholder or "Type here..."
        local Default = inputConfig.Default or ""
        local Callback = inputConfig.Callback or function() end

        local InputRow = Instance.new("Frame")
        InputRow.Name = "InputRow_" .. Name
        InputRow.Size = UDim2.new(1, -6, 0, 24)
        InputRow.BackgroundTransparency = 1
        InputRow.LayoutOrder = #Column.Elements + 1
        InputRow.Parent = ElementScroll

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(0.45, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextColor3 = Theme.TextPrimary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = InputRow

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Name = "BoxFrame"
        BoxFrame.Size = UDim2.new(0.55, 0, 1, 0)
        BoxFrame.Position = UDim2.new(0.45, 0, 0, 0)
        BoxFrame.BackgroundColor3 = Theme.ItemFill
        BoxFrame.BorderSizePixel = 0
        BoxFrame.Parent = InputRow

        local ICorner = Instance.new("UICorner")
        ICorner.CornerRadius = UDim.new(0, 3)
        ICorner.Parent = BoxFrame

        local IStroke = Instance.new("UIStroke")
        IStroke.Color = Theme.ItemBorder
        IStroke.Thickness = 1
        IStroke.Parent = BoxFrame

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, -12, 1, 0)
        TextBox.Position = UDim2.new(0, 6, 0, 0)
        TextBox.BackgroundTransparency = 1
        TextBox.Text = Default
        TextBox.PlaceholderText = Placeholder
        TextBox.PlaceholderColor3 = Theme.TextMuted
        TextBox.Font = Enum.Font.GothamMedium
        TextBox.TextSize = 11
        TextBox.TextColor3 = Theme.TextPrimary
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = BoxFrame

        TextBox.Focused:Connect(function()
            Tween(IStroke, {Color = Theme.Accent}, 0.15)
        end)
        TextBox.FocusLost:Connect(function()
            Tween(IStroke, {Color = Theme.ItemBorder}, 0.15)
            Callback(TextBox.Text)
        end)

        table.insert(Column.Elements, InputRow)
        return {
            Get = function() return TextBox.Text end,
            Set = function(t) TextBox.Text = t Callback(t) end
        }
    end

    return Column
end

function MemeSense:CreateWindow(windowConfig)
    windowConfig = windowConfig or {}
    local Title = windowConfig.Title or "Meme"
    local SubTitle = windowConfig.SubTitle or "Sense"
    local Size = windowConfig.Size or UDim2.fromOffset(730, 490)
    local ToggleKey = windowConfig.ToggleKey or Enum.KeyCode.RightShift
    local Theme = MemeSense.Themes.Default

    local GuiParent = GetSafeGuiParent(windowConfig.Parent)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MemeSense_" .. tostring(math.random(10000, 99999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 9999
    ScreenGui.Parent = GuiParent

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Size
    MainFrame.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Theme.MainBackground
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 5)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.ItemBorder
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    local TopGradientBar = Instance.new("Frame")
    TopGradientBar.Name = "TopGradientBar"
    TopGradientBar.Size = UDim2.new(1, 0, 0, 2)
    TopGradientBar.Position = UDim2.new(0, 0, 0, 0)
    TopGradientBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopGradientBar.BorderSizePixel = 0
    TopGradientBar.ZIndex = 10
    TopGradientBar.Parent = MainFrame

    local TopBarGradient = Instance.new("UIGradient")
    TopBarGradient.Color = ColorSequence.new(Theme.TopGradient)
    TopBarGradient.Parent = TopGradientBar

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 5)
    TopBarCorner.Parent = TopGradientBar

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.Position = UDim2.new(0, 0, 0, 2)
    Header.BackgroundColor3 = Theme.MainBackground
    Header.BorderSizePixel = 0
    Header.ZIndex = 5
    Header.Parent = MainFrame

    local HeaderBottomLine = Instance.new("Frame")
    HeaderBottomLine.Name = "HeaderBottomLine"
    HeaderBottomLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderBottomLine.Position = UDim2.new(0, 0, 1, -1)
    HeaderBottomLine.BackgroundColor3 = Theme.Divider
    HeaderBottomLine.BorderSizePixel = 0
    HeaderBottomLine.Parent = Header

    local BrandContainer = Instance.new("Frame")
    BrandContainer.Name = "BrandContainer"
    BrandContainer.Size = UDim2.new(0, 140, 1, 0)
    BrandContainer.Position = UDim2.new(0, 14, 0, 0)
    BrandContainer.BackgroundTransparency = 1
    BrandContainer.Parent = Header

    local MemeText = Instance.new("TextLabel")
    MemeText.Name = "MemeText"
    MemeText.Size = UDim2.new(0, 48, 1, 0)
    MemeText.Position = UDim2.new(0, 0, 0, 0)
    MemeText.BackgroundTransparency = 1
    MemeText.Text = Title
    MemeText.Font = Enum.Font.GothamBold
    MemeText.TextSize = 16
    MemeText.TextColor3 = Theme.Accent
    MemeText.TextXAlignment = Enum.TextXAlignment.Left
    MemeText.Parent = BrandContainer

    local SenseText = Instance.new("TextLabel")
    SenseText.Name = "SenseText"
    SenseText.Size = UDim2.new(0, 70, 1, 0)
    SenseText.Position = UDim2.new(0, 48, 0, 0)
    SenseText.BackgroundTransparency = 1
    SenseText.Text = SubTitle
    SenseText.Font = Enum.Font.GothamBold
    SenseText.TextSize = 16
    SenseText.TextColor3 = Theme.TextPrimary
    SenseText.TextXAlignment = Enum.TextXAlignment.Left
    SenseText.Parent = BrandContainer

    local HeaderControls = Instance.new("Frame")
    HeaderControls.Name = "HeaderControls"
    HeaderControls.Size = UDim2.new(1, -160, 1, 0)
    HeaderControls.Position = UDim2.new(0, 150, 0, 0)
    HeaderControls.BackgroundTransparency = 1
    HeaderControls.Parent = Header

    local MasterSwitchFrame = Instance.new("TextButton")
    MasterSwitchFrame.Name = "MasterSwitch"
    MasterSwitchFrame.Size = UDim2.new(0, 115, 0, 24)
    MasterSwitchFrame.Position = UDim2.new(0, 10, 0.5, -12)
    MasterSwitchFrame.BackgroundTransparency = 1
    MasterSwitchFrame.Text = ""
    MasterSwitchFrame.Parent = HeaderControls

    local MasterBox = Instance.new("Frame")
    MasterBox.Name = "Box"
    MasterBox.Size = UDim2.new(0, 14, 0, 14)
    MasterBox.Position = UDim2.new(0, 0, 0.5, -7)
    MasterBox.BackgroundColor3 = Theme.Accent
    MasterBox.BorderSizePixel = 0
    MasterBox.Parent = MasterSwitchFrame

    local MasterBoxCorner = Instance.new("UICorner")
    MasterBoxCorner.CornerRadius = UDim.new(0, 3)
    MasterBoxCorner.Parent = MasterBox

    local MasterCheck = Instance.new("ImageLabel")
    MasterCheck.Name = "Check"
    MasterCheck.Size = UDim2.new(1, -2, 1, -2)
    MasterCheck.Position = UDim2.new(0, 1, 0, 1)
    MasterCheck.BackgroundTransparency = 1
    MasterCheck.Image = MemeSense.Icons.check
    MasterCheck.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MasterCheck.Parent = MasterBox

    local MasterLabel = Instance.new("TextLabel")
    MasterLabel.Name = "Label"
    MasterLabel.Size = UDim2.new(1, -20, 1, 0)
    MasterLabel.Position = UDim2.new(0, 20, 0, 0)
    MasterLabel.BackgroundTransparency = 1
    MasterLabel.Text = "Master switch"
    MasterLabel.Font = Enum.Font.GothamMedium
    MasterLabel.TextSize = 12
    MasterLabel.TextColor3 = Theme.TextPrimary
    MasterLabel.TextXAlignment = Enum.TextXAlignment.Left
    MasterLabel.Parent = MasterSwitchFrame

    local MasterState = windowConfig.MasterSwitch ~= nil and windowConfig.MasterSwitch or true
    local function UpdateMasterSwitch(state)
        MasterState = state
        if MasterState then
            MasterBox.BackgroundColor3 = Theme.Accent
            MasterCheck.ImageTransparency = 0
            MasterLabel.TextColor3 = Theme.TextPrimary
        else
            MasterBox.BackgroundColor3 = Theme.ItemFill
            MasterCheck.ImageTransparency = 1
            MasterLabel.TextColor3 = Theme.TextMuted
        end
        if windowConfig.MasterSwitchCallback then
            windowConfig.MasterSwitchCallback(MasterState)
        end
    end
    UpdateMasterSwitch(MasterState)

    MasterSwitchFrame.MouseButton1Click:Connect(function()
        UpdateMasterSwitch(not MasterState)
    end)

    local OverlayLayer = Instance.new("Frame")
    OverlayLayer.Name = "OverlayLayer"
    OverlayLayer.Size = UDim2.new(1, 0, 1, 0)
    OverlayLayer.Position = UDim2.new(0, 0, 0, 0)
    OverlayLayer.BackgroundTransparency = 1
    OverlayLayer.ZIndex = 800
    OverlayLayer.Parent = MainFrame

    local FloatingBackdrop = Instance.new("TextButton")
    FloatingBackdrop.Name = "FloatingBackdrop"
    FloatingBackdrop.Size = UDim2.new(1, 0, 1, 0)
    FloatingBackdrop.Position = UDim2.new(0, 0, 0, 0)
    FloatingBackdrop.BackgroundTransparency = 1
    FloatingBackdrop.Text = ""
    FloatingBackdrop.AutoButtonColor = false
    FloatingBackdrop.Visible = false
    FloatingBackdrop.ZIndex = 840
    FloatingBackdrop.Parent = OverlayLayer

    local WeaponSelectorConfig = windowConfig.WeaponSelector or {
        Options = {"All weapons", "Pistols", "Rifles", "Snipers", "SMGs", "Shotguns"},
        Default = "All weapons"
    }

    local WeaponDropdownButton = Instance.new("TextButton")
    WeaponDropdownButton.Name = "WeaponDropdown"
    WeaponDropdownButton.Size = UDim2.new(0, 120, 0, 24)
    WeaponDropdownButton.Position = UDim2.new(0, 135, 0.5, -12)
    WeaponDropdownButton.BackgroundColor3 = Theme.ItemFill
    WeaponDropdownButton.BorderSizePixel = 0
    WeaponDropdownButton.Text = ""
    WeaponDropdownButton.AutoButtonColor = false
    WeaponDropdownButton.Parent = HeaderControls

    local WCorner = Instance.new("UICorner")
    WCorner.CornerRadius = UDim.new(0, 3)
    WCorner.Parent = WeaponDropdownButton

    local WStroke = Instance.new("UIStroke")
    WStroke.Color = Theme.ItemBorder
    WStroke.Thickness = 1
    WStroke.Parent = WeaponDropdownButton

    local WLabel = Instance.new("TextLabel")
    WLabel.Name = "Label"
    WLabel.Size = UDim2.new(1, -22, 1, 0)
    WLabel.Position = UDim2.new(0, 8, 0, 0)
    WLabel.BackgroundTransparency = 1
    WLabel.Text = WeaponSelectorConfig.Default or "All weapons"
    WLabel.Font = Enum.Font.GothamMedium
    WLabel.TextSize = 11
    WLabel.TextColor3 = Theme.TextPrimary
    WLabel.TextXAlignment = Enum.TextXAlignment.Left
    WLabel.TextTruncate = Enum.TextTruncate.AtEnd
    WLabel.Parent = WeaponDropdownButton

    local WArrow = Instance.new("ImageLabel")
    WArrow.Name = "Arrow"
    WArrow.Size = UDim2.new(0, 12, 0, 12)
    WArrow.Position = UDim2.new(1, -16, 0.5, -6)
    WArrow.BackgroundTransparency = 1
    WArrow.Image = MemeSense.Icons.chevron
    WArrow.ImageColor3 = Theme.TextSecondary
    WArrow.Parent = WeaponDropdownButton

    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Size = UDim2.new(0, 70, 0, 24)
    SaveButton.Position = UDim2.new(1, -108, 0.5, -12)
    SaveButton.BackgroundColor3 = Theme.ItemFill
    SaveButton.BorderSizePixel = 0
    SaveButton.Text = ""
    SaveButton.AutoButtonColor = false
    SaveButton.Parent = HeaderControls

    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 4)
    SaveCorner.Parent = SaveButton

    local SaveStroke = Instance.new("UIStroke")
    SaveStroke.Color = Theme.ItemBorder
    SaveStroke.Thickness = 1
    SaveStroke.Parent = SaveButton

    local SaveIcon = Instance.new("ImageLabel")
    SaveIcon.Name = "Icon"
    SaveIcon.Size = UDim2.new(0, 12, 0, 12)
    SaveIcon.Position = UDim2.new(0, 8, 0.5, -6)
    SaveIcon.BackgroundTransparency = 1
    SaveIcon.Image = MemeSense.Icons.cloud
    SaveIcon.ImageColor3 = Theme.TextPrimary
    SaveIcon.Parent = SaveButton

    local SaveLabel = Instance.new("TextLabel")
    SaveLabel.Name = "Label"
    SaveLabel.Size = UDim2.new(1, -24, 1, 0)
    SaveLabel.Position = UDim2.new(0, 24, 0, 0)
    SaveLabel.BackgroundTransparency = 1
    SaveLabel.Text = "Save"
    SaveLabel.Font = Enum.Font.GothamMedium
    SaveLabel.TextSize = 11
    SaveLabel.TextColor3 = Theme.TextPrimary
    SaveLabel.TextXAlignment = Enum.TextXAlignment.Left
    SaveLabel.Parent = SaveButton

    SaveButton.MouseEnter:Connect(function()
        Tween(SaveButton, {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}, 0.1)
        Tween(SaveStroke, {Color = Theme.ItemBorderHover}, 0.1)
    end)
    SaveButton.MouseLeave:Connect(function()
        Tween(SaveButton, {BackgroundColor3 = Theme.ItemFill}, 0.1)
        Tween(SaveStroke, {Color = Theme.ItemBorder}, 0.1)
    end)
    SaveButton.MouseButton1Click:Connect(function()
        Tween(SaveButton, {BackgroundColor3 = Theme.Accent}, 0.08)
        task.delay(0.12, function()
            Tween(SaveButton, {BackgroundColor3 = Theme.ItemFill}, 0.15)
        end)
        if windowConfig.SaveCallback then
            windowConfig.SaveCallback()
        end
    end)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
    CloseButton.BackgroundColor3 = Theme.ItemFill
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = HeaderControls

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = Theme.ItemBorder
    CloseStroke.Thickness = 1
    CloseStroke.Parent = CloseButton

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Name = "Icon"
    CloseIcon.Size = UDim2.new(0, 11, 0, 11)
    CloseIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = MemeSense.Icons.close
    CloseIcon.ImageColor3 = Theme.TextSecondary
    CloseIcon.Parent = CloseButton

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 1, -44)
    Body.Position = UDim2.new(0, 0, 0, 44)
    Body.BackgroundTransparency = 1
    Body.Parent = MainFrame

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 138, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Theme.SidebarBackground
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Body

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 5)
    SidebarCorner.Parent = Sidebar

    local SidebarRightLine = Instance.new("Frame")
    SidebarRightLine.Name = "RightLine"
    SidebarRightLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarRightLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarRightLine.BackgroundColor3 = Theme.Divider
    SidebarRightLine.BorderSizePixel = 0
    SidebarRightLine.Parent = Sidebar

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(1, 0, 1, -10)
    TabScroll.Position = UDim2.new(0, 0, 0, 6)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 1)
    TabListLayout.Parent = TabScroll

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -138, 1, 0)
    ContentArea.Position = UDim2.new(0, 138, 0, 0)
    ContentArea.BackgroundColor3 = Theme.ContentBackground
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = Body

    local Window = {
        MainFrame = MainFrame,
        ScreenGui = ScreenGui,
        Tabs = {},
        ActiveTab = nil,
        Theme = Theme,
        OverlayLayer = OverlayLayer,
        CurrentActiveFloating = nil,
        CurrentActiveFloatingSource = nil,
        CurrentActiveFloatingCallback = nil
    }

    local function CloseActiveFloating()
        FloatingBackdrop.Visible = false
        if Window.CurrentActiveFloatingCallback then
            local cb = Window.CurrentActiveFloatingCallback
            Window.CurrentActiveFloatingCallback = nil
            pcall(cb)
        end
        if Window.CurrentActiveFloating then
            pcall(function() Window.CurrentActiveFloating:Destroy() end)
            Window.CurrentActiveFloating = nil
            Window.CurrentActiveFloatingSource = nil
        end
    end

    local function SetActiveFloating(floatingObj, sourceObj, closeCallback)
        CloseActiveFloating()
        FloatingBackdrop.Visible = true
        Window.CurrentActiveFloating = floatingObj
        Window.CurrentActiveFloatingSource = sourceObj
        Window.CurrentActiveFloatingCallback = closeCallback
    end

    FloatingBackdrop.MouseButton1Click:Connect(function()
        CloseActiveFloating()
    end)

    Window.CloseActiveFloating = CloseActiveFloating
    Window.SetActiveFloating = SetActiveFloating

    local IsHeaderDropOpen = false
    local function CloseHeaderDropdown()
        if not IsHeaderDropOpen then return end
        IsHeaderDropOpen = false
        Tween(WArrow, {Rotation = 0}, 0.15)
        Tween(WStroke, {Color = Theme.ItemBorder}, 0.15)
        Window:CloseActiveFloating()
    end

    local function OpenHeaderDropdown(options, currentVal, callback)
        CloseActiveFloating()
        IsHeaderDropOpen = true
        Tween(WArrow, {Rotation = 180}, 0.15)
        Tween(WStroke, {Color = Theme.Accent}, 0.15)

        local pos = WeaponDropdownButton.AbsolutePosition - MainFrame.AbsolutePosition
        local size = WeaponDropdownButton.AbsoluteSize

        local DropFrame = Instance.new("Frame")
        DropFrame.Name = "WeaponDropFloating"
        DropFrame.Size = UDim2.new(0, size.X, 0, math.min(#options * 24 + 6, 160))
        DropFrame.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y + 4)
        DropFrame.BackgroundColor3 = Theme.CardBackground
        DropFrame.BorderSizePixel = 0
        DropFrame.ZIndex = 850
        DropFrame.Parent = OverlayLayer

        local DCorner = Instance.new("UICorner")
        DCorner.CornerRadius = UDim.new(0, 4)
        DCorner.Parent = DropFrame

        local DStroke = Instance.new("UIStroke")
        DStroke.Color = Theme.ItemBorder
        DStroke.Thickness = 1
        DStroke.Parent = DropFrame

        local DScroll = Instance.new("ScrollingFrame")
        DScroll.Size = UDim2.new(1, -2, 1, -4)
        DScroll.Position = UDim2.new(0, 1, 0, 2)
        DScroll.BackgroundTransparency = 1
        DScroll.BorderSizePixel = 0
        DScroll.ScrollBarThickness = 2
        DScroll.ScrollBarImageColor3 = Theme.ItemBorderHover
        DScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        DScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        DScroll.ZIndex = 851
        DScroll.Parent = DropFrame

        local DLayout = Instance.new("UIListLayout")
        DLayout.SortOrder = Enum.SortOrder.LayoutOrder
        DLayout.Padding = UDim.new(0, 1)
        DLayout.Parent = DScroll

        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 22)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = ""
            OptBtn.AutoButtonColor = false
            OptBtn.ZIndex = 852
            OptBtn.Parent = DScroll

            local OptLbl = Instance.new("TextLabel")
            OptLbl.Size = UDim2.new(1, -12, 1, 0)
            OptLbl.Position = UDim2.new(0, 8, 0, 0)
            OptLbl.BackgroundTransparency = 1
            OptLbl.Text = tostring(opt)
            OptLbl.Font = Enum.Font.GothamMedium
            OptLbl.TextSize = 11
            OptLbl.TextColor3 = (opt == currentVal) and Theme.Accent or Theme.TextSecondary
            OptLbl.TextXAlignment = Enum.TextXAlignment.Left
            OptLbl.ZIndex = 853
            OptLbl.Parent = OptBtn

            OptBtn.MouseEnter:Connect(function()
                Tween(OptLbl, {TextColor3 = Theme.TextPrimary}, 0.1)
            end)
            OptBtn.MouseLeave:Connect(function()
                if opt ~= currentVal then
                    Tween(OptLbl, {TextColor3 = Theme.TextSecondary}, 0.1)
                end
            end)
            OptBtn.MouseButton1Click:Connect(function()
                currentVal = opt
                WLabel.Text = tostring(opt)
                if callback then callback(opt) end
                CloseHeaderDropdown()
            end)
        end

        SetActiveFloating(DropFrame, WeaponDropdownButton, function()
            IsHeaderDropOpen = false
            Tween(WArrow, {Rotation = 0}, 0.15)
            Tween(WStroke, {Color = Theme.ItemBorder}, 0.15)
        end)
    end

    WeaponDropdownButton.MouseButton1Click:Connect(function()
        if IsHeaderDropOpen then
            CloseHeaderDropdown()
        else
            OpenHeaderDropdown(WeaponSelectorConfig.Options, WLabel.Text, WeaponSelectorConfig.Callback)
        end
    end)

    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(42, 22, 28)}, 0.1)
        Tween(CloseStroke, {Color = Theme.Accent}, 0.1)
        Tween(CloseIcon, {ImageColor3 = Color3.fromRGB(255, 70, 90)}, 0.1)
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Theme.ItemFill}, 0.1)
        Tween(CloseStroke, {Color = Theme.ItemBorder}, 0.1)
        Tween(CloseIcon, {ImageColor3 = Theme.TextSecondary}, 0.1)
    end)

    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPos = nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + delta.Y
            )
        end
    end)

    local WindowOpen = true
    local function SetWindowVisible(visible)
        WindowOpen = visible
        if not ScreenGui.Parent or not ScreenGui:IsDescendantOf(game) then
            pcall(function()
                ScreenGui.Parent = GetSafeGuiParent(windowConfig.Parent)
            end)
        end
        ScreenGui.Enabled = true
        MainFrame.Visible = WindowOpen
        if not WindowOpen then
            CloseActiveFloating()
        end
    end

    local function ToggleWindow()
        SetWindowVisible(not WindowOpen)
    end

    CloseButton.MouseButton1Click:Connect(function()
        SetWindowVisible(false)
        Window:Notify({
            Title = "MemeSense Minimized",
            Content = "Press " .. tostring(ToggleKey.Name or "RightShift") .. " or INSERT to reopen menu.",
            Duration = 3
        })
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            if input.KeyCode == ToggleKey or input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
                ToggleWindow()
            end
        end
    end)

    ScreenGui.AncestryChanged:Connect(function(_, parent)
        if not parent and ScreenGui and not Unloaded then
            pcall(function()
                ScreenGui.Parent = GetSafeGuiParent(windowConfig.Parent)
            end)
        end
    end)

    Window.SetVisible = SetWindowVisible
    Window.Toggle = ToggleWindow
    Window.IsOpen = function() return WindowOpen end
    Window.SetToggleKey = function(self, newKey)
        if typeof(self) == "EnumItem" then
            newKey = self
        end
        ToggleKey = newKey
    end

    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Tab"
        local TabIcon = MemeSense:GetIcon(tabConfig.Icon or TabName)
        local LayoutOrder = #Window.Tabs + 1

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "_Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundTransparency = 1
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = LayoutOrder
        TabButton.Parent = TabScroll

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "Indicator"
        TabIndicator.Size = UDim2.new(0, 2, 1, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0, 0)
        TabIndicator.BackgroundColor3 = Theme.Accent
        TabIndicator.BorderSizePixel = 0
        TabIndicator.BackgroundTransparency = 1
        TabIndicator.Parent = TabButton

        local IconImage = Instance.new("ImageLabel")
        IconImage.Name = "Icon"
        IconImage.Size = UDim2.new(0, 15, 0, 15)
        IconImage.Position = UDim2.new(0, 12, 0.5, -7)
        IconImage.BackgroundTransparency = 1
        IconImage.Image = TabIcon
        IconImage.ImageColor3 = Theme.TextSecondary
        IconImage.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Size = UDim2.new(1, -36, 1, 0)
        TabLabel.Position = UDim2.new(0, 34, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabName
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 12
        TabLabel.TextColor3 = Theme.TextSecondary
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton

        local TabPage = Instance.new("Frame")
        TabPage.Name = TabName .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = ContentArea

        local ColumnsContainer = Instance.new("Frame")
        ColumnsContainer.Name = "ColumnsContainer"
        ColumnsContainer.Size = UDim2.new(1, -20, 1, -16)
        ColumnsContainer.Position = UDim2.new(0, 10, 0, 8)
        ColumnsContainer.BackgroundTransparency = 1
        ColumnsContainer.Parent = TabPage

        local Tab = {
            Name = TabName,
            Button = TabButton,
            Page = TabPage,
            Columns = {},
            SubTabs = {},
            ActiveSubTab = nil,
            SubTabBar = nil,
            ColumnsContainer = ColumnsContainer,
            Window = Window
        }

        function Tab:Select()
            CloseActiveFloating()
            for _, otherTab in ipairs(Window.Tabs) do
                otherTab.Page.Visible = false
                otherTab.Button.BackgroundTransparency = 1
                otherTab.Button.Indicator.BackgroundTransparency = 1
                Tween(otherTab.Button.Icon, {ImageColor3 = Theme.TextSecondary}, 0.15)
                Tween(otherTab.Button.Label, {TextColor3 = Theme.TextSecondary}, 0.15)
            end

            Tab.Page.Visible = true
            Tab.Button.BackgroundTransparency = 0
            Tab.Button.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
            Tab.Button.Indicator.BackgroundTransparency = 0
            Tween(Tab.Button.Icon, {ImageColor3 = Theme.Accent}, 0.15)
            Tween(Tab.Button.Label, {TextColor3 = Theme.TextPrimary}, 0.15)
            Window.ActiveTab = Tab

            if #Tab.SubTabs > 0 and not Tab.ActiveSubTab then
                Tab.SubTabs[1]:Select()
            end
        end

        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.1)
                Tween(TabLabel, {TextColor3 = Theme.TextPrimary}, 0.1)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.1)
                Tween(TabLabel, {TextColor3 = Theme.TextSecondary}, 0.1)
            end
        end)
        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Tab:Select()
        end

        function Tab:CreateColumn(colTitle)
            return CreateColumnController(ColumnsContainer, colTitle, Tab.Columns, Theme, Window, OverlayLayer)
        end

        function Tab:CreateSubTab(subTabConfig)
            local subName = type(subTabConfig) == "table" and (subTabConfig.Name or "SubTab") or tostring(subTabConfig or "SubTab")

            if not Tab.SubTabBar then
                local SubTabBar = Instance.new("Frame")
                SubTabBar.Name = "SubTabBar"
                SubTabBar.Size = UDim2.new(1, -20, 0, 26)
                SubTabBar.Position = UDim2.new(0, 10, 0, 6)
                SubTabBar.BackgroundTransparency = 1
                SubTabBar.Parent = TabPage
                Tab.SubTabBar = SubTabBar

                local SLayout = Instance.new("UIListLayout")
                SLayout.FillDirection = Enum.FillDirection.Horizontal
                SLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SLayout.Padding = UDim.new(0, 6)
                SLayout.Parent = SubTabBar

                ColumnsContainer.Visible = false
            end

            local SubTabButton = Instance.new("TextButton")
            SubTabButton.Name = "SubTab_" .. subName
            SubTabButton.Size = UDim2.new(0, math.max(80, string.len(subName) * 8 + 24), 0, 24)
            SubTabButton.BackgroundColor3 = Theme.ItemFill
            SubTabButton.BorderSizePixel = 0
            SubTabButton.Text = ""
            SubTabButton.AutoButtonColor = false
            SubTabButton.LayoutOrder = #Tab.SubTabs + 1
            SubTabButton.Parent = Tab.SubTabBar

            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 4)
            SCorner.Parent = SubTabButton

            local SStroke = Instance.new("UIStroke")
            SStroke.Color = Theme.ItemBorder
            SStroke.Thickness = 1
            SStroke.Parent = SubTabButton

            local SLabel = Instance.new("TextLabel")
            SLabel.Name = "Label"
            SLabel.Size = UDim2.new(1, 0, 1, 0)
            SLabel.BackgroundTransparency = 1
            SLabel.Text = subName
            SLabel.Font = Enum.Font.GothamMedium
            SLabel.TextSize = 11
            SLabel.TextColor3 = Theme.TextSecondary
            SLabel.Parent = SubTabButton

            local SubTabPage = Instance.new("Frame")
            SubTabPage.Name = "SubTabPage_" .. subName
            SubTabPage.Size = UDim2.new(1, 0, 1, -34)
            SubTabPage.Position = UDim2.new(0, 0, 0, 34)
            SubTabPage.BackgroundTransparency = 1
            SubTabPage.Visible = false
            SubTabPage.Parent = TabPage

            local SubColumnsContainer = Instance.new("Frame")
            SubColumnsContainer.Name = "ColumnsContainer"
            SubColumnsContainer.Size = UDim2.new(1, -20, 1, -6)
            SubColumnsContainer.Position = UDim2.new(0, 10, 0, 0)
            SubColumnsContainer.BackgroundTransparency = 1
            SubColumnsContainer.Parent = SubTabPage

            local SubTab = {
                Name = subName,
                Button = SubTabButton,
                Label = SLabel,
                Stroke = SStroke,
                Page = SubTabPage,
                ColumnsContainer = SubColumnsContainer,
                Columns = {},
                ParentTab = Tab
            }

            function SubTab:Select()
                CloseActiveFloating()
                for _, otherSub in ipairs(Tab.SubTabs) do
                    otherSub.Page.Visible = false
                    Tween(otherSub.Button, {BackgroundColor3 = Theme.ItemFill}, 0.15)
                    Tween(otherSub.Stroke, {Color = Theme.ItemBorder}, 0.15)
                    Tween(otherSub.Label, {TextColor3 = Theme.TextSecondary}, 0.15)
                end

                SubTab.Page.Visible = true
                Tween(SubTab.Button, {BackgroundColor3 = Color3.fromRGB(30, 30, 36)}, 0.15)
                Tween(SubTab.Stroke, {Color = Theme.Accent}, 0.15)
                Tween(SubTab.Label, {TextColor3 = Theme.TextPrimary}, 0.15)
                Tab.ActiveSubTab = SubTab
            end

            SubTabButton.MouseEnter:Connect(function()
                if Tab.ActiveSubTab ~= SubTab then
                    Tween(SubTabButton, {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}, 0.1)
                    Tween(SLabel, {TextColor3 = Theme.TextPrimary}, 0.1)
                end
            end)
            SubTabButton.MouseLeave:Connect(function()
                if Tab.ActiveSubTab ~= SubTab then
                    Tween(SubTabButton, {BackgroundColor3 = Theme.ItemFill}, 0.1)
                    Tween(SLabel, {TextColor3 = Theme.TextSecondary}, 0.1)
                end
            end)
            SubTabButton.MouseButton1Click:Connect(function()
                SubTab:Select()
            end)

            function SubTab:CreateColumn(colTitle)
                return CreateColumnController(SubColumnsContainer, colTitle, SubTab.Columns, Theme, Window, OverlayLayer)
            end

            table.insert(Tab.SubTabs, SubTab)
            if #Tab.SubTabs == 1 then
                SubTab:Select()
            end

            return SubTab
        end

        return Tab
    end

    function Window:OpenColorPicker(initialColor, callback, sourceBtn)
        CloseActiveFloating()
        local h, s, v = initialColor:ToHSV()

        local pos = sourceBtn and (sourceBtn.AbsolutePosition - MainFrame.AbsolutePosition) or Vector2.new(200, 150)
        local CPFrame = Instance.new("Frame")
        CPFrame.Name = "ColorPickerPopup"
        CPFrame.Size = UDim2.new(0, 160, 0, 160)
        CPFrame.Position = UDim2.new(0, math.clamp(pos.X - 140, 20, MainFrame.AbsoluteSize.X - 180), 0, math.clamp(pos.Y + 20, 20, MainFrame.AbsoluteSize.Y - 180))
        CPFrame.BackgroundColor3 = Theme.CardBackground
        CPFrame.BorderSizePixel = 0
        CPFrame.ZIndex = 850
        CPFrame.Parent = OverlayLayer

        local CPCorner = Instance.new("UICorner")
        CPCorner.CornerRadius = UDim.new(0, 4)
        CPCorner.Parent = CPFrame

        local CPStroke = Instance.new("UIStroke")
        CPStroke.Color = Theme.ItemBorder
        CPStroke.Thickness = 1
        CPStroke.Parent = CPFrame

        local TitleBar = Instance.new("TextLabel")
        TitleBar.Size = UDim2.new(1, -20, 0, 20)
        TitleBar.Position = UDim2.new(0, 8, 0, 4)
        TitleBar.BackgroundTransparency = 1
        TitleBar.Text = "Color Picker"
        TitleBar.Font = Enum.Font.GothamMedium
        TitleBar.TextSize = 11
        TitleBar.TextColor3 = Theme.TextSecondary
        TitleBar.TextXAlignment = Enum.TextXAlignment.Left
        TitleBar.ZIndex = 851
        TitleBar.Parent = CPFrame

        local SVBox = Instance.new("ImageButton")
        SVBox.Name = "SVBox"
        SVBox.Size = UDim2.new(0, 120, 0, 100)
        SVBox.Position = UDim2.new(0, 8, 0, 26)
        SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        SVBox.BorderSizePixel = 0
        SVBox.AutoButtonColor = false
        SVBox.ZIndex = 851
        SVBox.Parent = CPFrame

        local SVCorner = Instance.new("UICorner")
        SVCorner.CornerRadius = UDim.new(0, 2)
        SVCorner.Parent = SVBox

        local WhiteGrad = Instance.new("Frame")
        WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
        WhiteGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WhiteGrad.BorderSizePixel = 0
        WhiteGrad.ZIndex = 852
        WhiteGrad.Parent = SVBox

        local WhiteGradUIG = Instance.new("UIGradient")
        WhiteGradUIG.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        WhiteGradUIG.Parent = WhiteGrad

        local BlackGrad = Instance.new("Frame")
        BlackGrad.Size = UDim2.new(1, 0, 1, 0)
        BlackGrad.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BlackGrad.BorderSizePixel = 0
        BlackGrad.ZIndex = 853
        BlackGrad.Parent = SVBox

        local BlackGradUIG = Instance.new("UIGradient")
        BlackGradUIG.Rotation = 90
        BlackGradUIG.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        BlackGradUIG.Parent = BlackGrad

        local SVCursor = Instance.new("Frame")
        SVCursor.Size = UDim2.new(0, 6, 0, 6)
        SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
        SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SVCursor.BorderSizePixel = 0
        SVCursor.ZIndex = 855
        SVCursor.Parent = SVBox

        local SVCCorner = Instance.new("UICorner")
        SVCCorner.CornerRadius = UDim.new(1, 0)
        SVCCorner.Parent = SVCursor

        local HueBar = Instance.new("ImageButton")
        HueBar.Name = "HueBar"
        HueBar.Size = UDim2.new(0, 14, 0, 100)
        HueBar.Position = UDim2.new(1, -22, 0, 26)
        HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueBar.BorderSizePixel = 0
        HueBar.AutoButtonColor = false
        HueBar.ZIndex = 851
        HueBar.Parent = CPFrame

        local HueCorner = Instance.new("UICorner")
        HueCorner.CornerRadius = UDim.new(0, 2)
        HueCorner.Parent = HueBar

        local HueGrad = Instance.new("UIGradient")
        HueGrad.Rotation = 90
        HueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1))
        })
        HueGrad.Parent = HueBar

        local HueCursor = Instance.new("Frame")
        HueCursor.Size = UDim2.new(1, 2, 0, 3)
        HueCursor.Position = UDim2.new(0, -1, h, -1)
        HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueCursor.BorderSizePixel = 0
        HueCursor.ZIndex = 855
        HueCursor.Parent = HueBar

        local PreviewBox = Instance.new("Frame")
        PreviewBox.Size = UDim2.new(0, 20, 0, 18)
        PreviewBox.Position = UDim2.new(0, 8, 1, -24)
        PreviewBox.BackgroundColor3 = initialColor
        PreviewBox.BorderSizePixel = 0
        PreviewBox.ZIndex = 851
        PreviewBox.Parent = CPFrame

        local PCorner = Instance.new("UICorner")
        PCorner.CornerRadius = UDim.new(0, 2)
        PCorner.Parent = PreviewBox

        local HexLabel = Instance.new("TextLabel")
        HexLabel.Size = UDim2.new(1, -36, 0, 18)
        HexLabel.Position = UDim2.new(0, 34, 1, -24)
        HexLabel.BackgroundTransparency = 1
        HexLabel.Font = Enum.Font.GothamMedium
        HexLabel.TextSize = 10
        HexLabel.TextColor3 = Theme.TextPrimary
        HexLabel.TextXAlignment = Enum.TextXAlignment.Left
        HexLabel.Text = "#" .. ColorToHex(initialColor)
        HexLabel.ZIndex = 851
        HexLabel.Parent = CPFrame

        local function UpdateColor()
            local col = Color3.fromHSV(h, s, v)
            SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            PreviewBox.BackgroundColor3 = col
            HexLabel.Text = "#" .. ColorToHex(col)
            if callback then callback(col) end
        end

        local HueDrag = false
        HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                HueDrag = true
                local relY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                h = relY
                HueCursor.Position = UDim2.new(0, -1, h, -1)
                UpdateColor()
            end
        end)

        local SVDrag = false
        SVBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                SVDrag = true
                local relX = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                s = relX
                v = 1 - relY
                SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                UpdateColor()
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if HueDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                h = relY
                HueCursor.Position = UDim2.new(0, -1, h, -1)
                UpdateColor()
            elseif SVDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                s = relX
                v = 1 - relY
                SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                UpdateColor()
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                HueDrag = false
                SVDrag = false
            end
        end)

        SetActiveFloating(CPFrame, sourceBtn)
    end

    function Window:CreateWatermark(watermarkConfig)
        watermarkConfig = watermarkConfig or {}
        local Text = watermarkConfig.Text or "MemeSense | Drake | 60 fps | 15 ms"

        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Name = "MemeSenseWatermark"
        WatermarkFrame.Size = UDim2.new(0, 240, 0, 24)
        WatermarkFrame.Position = watermarkConfig.Position or UDim2.new(0, 15, 0, 15)
        WatermarkFrame.BackgroundColor3 = Theme.MainBackground
        WatermarkFrame.BorderSizePixel = 0
        WatermarkFrame.ZIndex = 900
        WatermarkFrame.Parent = ScreenGui

        local WCorner = Instance.new("UICorner")
        WCorner.CornerRadius = UDim.new(0, 4)
        WCorner.Parent = WatermarkFrame

        local WStroke = Instance.new("UIStroke")
        WStroke.Color = Theme.ItemBorder
        WStroke.Thickness = 1
        WStroke.Parent = WatermarkFrame

        local TopLine = Instance.new("Frame")
        TopLine.Size = UDim2.new(1, 0, 0, 2)
        TopLine.Position = UDim2.new(0, 0, 0, 0)
        TopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TopLine.BorderSizePixel = 0
        TopLine.Parent = WatermarkFrame

        local WGrad = Instance.new("UIGradient")
        WGrad.Color = ColorSequence.new(Theme.TopGradient)
        WGrad.Parent = TopLine

        local WLbl = Instance.new("TextLabel")
        WLbl.Size = UDim2.new(1, -16, 1, -2)
        WLbl.Position = UDim2.new(0, 8, 0, 2)
        WLbl.BackgroundTransparency = 1
        WLbl.Text = Text
        WLbl.Font = Enum.Font.GothamMedium
        WLbl.TextSize = 11
        WLbl.TextColor3 = Theme.TextPrimary
        WLbl.TextXAlignment = Enum.TextXAlignment.Center
        WLbl.Parent = WatermarkFrame

        local WatermarkObj = {
            Frame = WatermarkFrame,
            SetText = function(self, newText)
                WLbl.Text = newText
                local strLen = string.len(newText)
                WatermarkFrame.Size = UDim2.new(0, strLen * 7 + 24, 0, 24)
            end,
            Visible = function(self, visible)
                WatermarkFrame.Visible = visible
            end
        }
        WatermarkObj:SetText(Text)
        return WatermarkObj
    end

    function Window:Notify(notifyConfig)
        notifyConfig = notifyConfig or {}
        local TitleText = notifyConfig.Title or "MemeSense"
        local ContentText = notifyConfig.Content or "Notification"
        local Duration = notifyConfig.Duration or 3

        local ToastContainer = ScreenGui:FindFirstChild("MemeSenseToastContainer")
        if not ToastContainer then
            ToastContainer = Instance.new("Frame")
            ToastContainer.Name = "MemeSenseToastContainer"
            ToastContainer.Size = UDim2.new(0, 240, 1, -20)
            ToastContainer.Position = UDim2.new(1, -250, 0, 10)
            ToastContainer.BackgroundTransparency = 1
            ToastContainer.ZIndex = 950
            ToastContainer.Parent = ScreenGui

            local TLayout = Instance.new("UIListLayout")
            TLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            TLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            TLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TLayout.Padding = UDim.new(0, 6)
            TLayout.Parent = ToastContainer
        end

        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Size = UDim2.new(1, 0, 0, 50)
        Toast.BackgroundColor3 = Theme.MainBackground
        Toast.BorderSizePixel = 0
        Toast.ClipsDescendants = true
        Toast.Parent = ToastContainer

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 4)
        TCorner.Parent = Toast

        local TStroke = Instance.new("UIStroke")
        TStroke.Color = Theme.ItemBorder
        TStroke.Thickness = 1
        TStroke.Parent = Toast

        local TTopLine = Instance.new("Frame")
        TTopLine.Size = UDim2.new(1, 0, 0, 2)
        TTopLine.Position = UDim2.new(0, 0, 0, 0)
        TTopLine.BackgroundColor3 = Theme.Accent
        TTopLine.BorderSizePixel = 0
        TTopLine.Parent = Toast

        local TTitle = Instance.new("TextLabel")
        TTitle.Size = UDim2.new(1, -16, 0, 18)
        TTitle.Position = UDim2.new(0, 8, 0, 6)
        TTitle.BackgroundTransparency = 1
        TTitle.Text = TitleText
        TTitle.Font = Enum.Font.GothamBold
        TTitle.TextSize = 12
        TTitle.TextColor3 = Theme.Accent
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.Parent = Toast

        local TDesc = Instance.new("TextLabel")
        TDesc.Size = UDim2.new(1, -16, 0, 20)
        TDesc.Position = UDim2.new(0, 8, 0, 24)
        TDesc.BackgroundTransparency = 1
        TDesc.Text = ContentText
        TDesc.Font = Enum.Font.GothamMedium
        TDesc.TextSize = 11
        TDesc.TextColor3 = Theme.TextPrimary
        TDesc.TextXAlignment = Enum.TextXAlignment.Left
        TDesc.Parent = Toast

        task.delay(Duration, function()
            Tween(Toast, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.delay(0.2, function()
                Toast:Destroy()
            end)
        end)
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return MemeSense
