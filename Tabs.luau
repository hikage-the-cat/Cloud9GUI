-- Tabs.luau
local ts = game:GetService("TweenService")
local tweeninf = TweenInfo.new(0.2, Enum.EasingStyle.Quad)

local Tabs = {}
Tabs.__index = Tabs

function Tabs.new(frame, theme)
    local self = setmetatable({}, Tabs)
    self.frame = frame
    self.theme = theme
    self.tabs = {}
    self.activeTab = nil

    -- Tab bar sits below the topbar (topbar is 30px tall)
    self.tabBar = Instance.new("Frame")
    self.tabBar.Name = "TabBar"
    self.tabBar.Size = UDim2.new(1, 0, 0, 28)
    self.tabBar.Position = UDim2.new(0, 0, 0, 30)
    self.tabBar.BackgroundColor3 = theme.SecondaryBg or Color3.fromRGB(30, 30, 30)
    self.tabBar.BackgroundTransparency = 0
    self.tabBar.BorderSizePixel = 0
    self.tabBar.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = self.tabBar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 4)
    padding.Parent = self.tabBar

    -- Content area below tab bar
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, 0, 1, -58) -- subtract topbar+tabbar
    self.contentArea.Position = UDim2.new(0, 0, 0, 58)
    self.contentArea.BackgroundTransparency = 1
    self.contentArea.BorderSizePixel = 0
    self.contentArea.Parent = frame

    return self
end

function Tabs:AddTab(name)
    local theme = self.theme
    local tabIndex = #self.tabs + 1

    -- Tab button
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. name
    btn.Size = UDim2.new(0, 80, 0, 20)
    btn.BackgroundColor3 = theme.Background or Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = 0.4
    btn.Text = name
    btn.TextColor3 = theme.TextPrimary or Color3.fromRGB(180, 180, 180)
    btn.Font = theme.Font or Enum.Font.Gotham
    btn.TextSize = 12
    btn.LayoutOrder = tabIndex
    btn.AutoButtonColor = false
    btn.Parent = self.tabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    -- Tab content frame
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_" .. name
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = false
    content.Parent = self.contentArea

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.Parent = content

    local tabData = {
        btn = btn,
        content = content,
        name = name,
    }
    table.insert(self.tabs, tabData)

    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)

    -- Auto-select first tab
    if #self.tabs == 1 then
        self:SwitchTab(name)
    end

    -- Return a simple API for adding elements to this tab
    return {
        AddLabel = function(_, text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = theme.TextPrimary or Color3.fromRGB(200, 200, 200)
            lbl.Font = theme.Font or Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.LayoutOrder = #content:GetChildren()
            lbl.Parent = content
        end,

        AddButton = function(_, text, callback)
            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(1, 0, 0, 28)
            btn2.BackgroundColor3 = theme.Accent or Color3.fromRGB(80, 120, 200)
            btn2.Text = text
            btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn2.Font = theme.Font or Enum.Font.Gotham
            btn2.TextSize = 13
            btn2.LayoutOrder = #content:GetChildren()
            btn2.Parent = content
            local c2 = Instance.new("UICorner")
            c2.CornerRadius = UDim.new(0, 5)
            c2.Parent = btn2
            btn2.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end,

        -- add more element types here (Toggle, Slider, etc.)
        _content = content,
    }
end

function Tabs:SwitchTab(name)
    local theme = self.theme
    for _, t in ipairs(self.tabs) do
        local isActive = t.name == name
        t.content.Visible = isActive
        ts:Create(t.btn, tweeninfo2, {
            BackgroundTransparency = isActive and 0 or 0.4,
            TextColor3 = isActive
                and (theme.Accent or Color3.fromRGB(255, 255, 255))
                or (theme.TextPrimary or Color3.fromRGB(180, 180, 180)),
        }):Play()
    end
    self.activeTab = name
end

return Tabs