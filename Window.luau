-- deps
local tabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/hikage-the-cat/Cloud9GUI/refs/heads/main/Themes.luau",true))()
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
local Cloud9Lib = {}

function Cloud9Lib:CreateWindow(Options)
    Options = Options or {}
    local title = Options.Title or "Cloud9 Window"
    local theme = Options.theme or FrostedThemes.DarkGlass
    local size = Options.Size or UDim2.new(0, 400, 0, 300)
    local position = Options.Position or UDim2.new(0, 100, 0, 100)
    local originalSize = size
    local isOpen = true
    local keybind = Options.Keybind or Enum.KeyCode.K 
    local killKeybind = Options.KillKeybind or Enum.KeyCode.Delete

    -- min size so window cant get 2 small
    local minWidth = 200
    local minHeight = 100

    local ui = Instance.new("ScreenGui")
        ui.Name = "Cloud9_" .. title
        ui.ResetOnSpawn = false
        ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = size
        frame.Position = position
        frame.BackgroundColor3 = theme.Background
        frame.BackgroundTransparency = theme.Transparency or 0
        frame.Parent = ui
        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = theme.CornerRadius or UDim.new(0, 10)
        uicorner.Parent = frame
        local outline = Instance.new("UIStroke")
            outline.Name = "Outline"
            outline.Color = theme.StrokeColor or Color3.fromRGB(0, 0, 0)
            outline.Transparency = theme.StrokeTrans or 0
            outline.Thickness = theme.StrokeThickness or 2
            outline.Parent = frame

        local topbar = Instance.new("Frame")
            topbar.Name = "TopBar"
            topbar.Size = UDim2.new(1, 0, 0, 30)
            topbar.BackgroundColor3 = theme.SecondaryBg or Color3.fromRGB(255, 255, 255)
            topbar.BackgroundTransparency = 0
            topbar.Parent = frame
            local uicorner2 = Instance.new("UICorner")
            uicorner2.CornerRadius = theme.CornerRadius or UDim.new(0, 5)
            uicorner2.Parent = topbar
            local nobtmcorners = Instance.new("Frame")
                nobtmcorners.Name = "NoBtmCorners"
                nobtmcorners.Size = UDim2.new(1, 0, 0, 15)
                nobtmcorners.Position = UDim2.new(0, 0, 0, 15)
                nobtmcorners.BackgroundColor3 = theme.SecondaryBg or Color3.fromRGB(255, 255, 255)
                nobtmcorners.BackgroundTransparency = 0
                nobtmcorners.BorderSizePixel = 0
                nobtmcorners.Parent = topbar

        local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "Title"
            titleLabel.Size = UDim2.new(1, -60, 1, 0)
            titleLabel.Position = UDim2.new(0, 36, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = theme.TextPrimary or Color3.fromRGB(150, 150, 150)
            titleLabel.Font = theme.Font or Enum.Font.Gotham
            titleLabel.TextSize = theme.TitleFontSize or 15
            titleLabel.Parent = topbar


        local icon = Instance.new("ImageLabel")
        icon.Parent = topbar
        icon.Rotation = -15
        icon.ImageColor3 = theme.Accent or Color3.fromRGB(0, 0, 0)
        icon.Image = "rbxassetid://11422151506"
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 0, 0.5, -14)
        icon.AnchorPoint = Vector2.new(0, 0)
        icon.Size = UDim2.fromOffset(28, 28)

        -- dragging
        local dragging = false
        local dragOffset = Vector2.new(0, 0)

        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local framePos = frame.AbsolutePosition
                local inputPos = input.Position
                dragOffset = Vector2.new(inputPos.X - framePos.X, inputPos.Y - framePos.Y)
            end
        end)

        topbar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        uis.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                frame.Position = UDim2.fromOffset(
                    input.Position.X - dragOffset.X,
                    input.Position.Y - dragOffset.Y
                )
            end
        end)

        -- resize handle
        local resizeHandle = Instance.new("TextButton")
            resizeHandle.Name = "ResizeHandle"
            resizeHandle.Size = UDim2.fromOffset(16, 16)
            resizeHandle.Position = UDim2.new(1, -16, 1, -16)
            resizeHandle.BackgroundColor3 = theme.SecondaryBg or Color3.fromRGB(200, 200, 200)
            resizeHandle.BackgroundTransparency = 1
            resizeHandle.Text = ""
            resizeHandle.AutoButtonColor = false
            resizeHandle.ZIndex = 10
            resizeHandle.Parent = frame

        -- resize logic
        local resizing = false
        local resizeStart = Vector2.new(0, 0)
        local sizeAtResizeStart = Vector2.new(0, 0)

        resizeHandle.InputBegan:Connect(function(input)
            if not isOpen then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = Vector2.new(input.Position.X, input.Position.Y)
                sizeAtResizeStart = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
            end
        end)

        resizeHandle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
                originalSize = frame.Size
            end
        end)

        uis.InputChanged:Connect(function(input)
            if not resizing then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = Vector2.new(
                    input.Position.X - resizeStart.X,
                    input.Position.Y - resizeStart.Y
                )
                local newW = math.max(minWidth, sizeAtResizeStart.X + delta.X)
                local newH = math.max(minHeight, sizeAtResizeStart.Y + delta.Y)
                frame.Size = UDim2.fromOffset(newW, newH)
            end
        end)
                -- open/close with keybind
        uis.InputBegan:Connect(function(input)
            if input.KeyCode == killKeybind then
                ui:Destroy()
                return
            end
            if input.KeyCode == keybind then
                if isOpen then
                    local tween = ts:Create(frame, tweenInfo, {
                        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30)
                    })
                    tween:Play()
                    tween.Completed:Connect(function()
                        nobtmcorners.Visible = false
                        titleLabel.Visible = false
                        resizeHandle.ZIndex = -10
                        resizeHandle.Active = false
                        ts:Create(frame, tweenInfo, {
                            Size = UDim2.new(0, 30, 0, 30)
                        }):Play()
                    end)
                else
                    ts:Create(frame, tweenInfo, {
                        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30)
                    }):Play()
                    task.wait(0.3)
                    nobtmcorners.Visible = true
                    titleLabel.Visible = true
                    resizeHandle.ZIndex = 10
                    resizeHandle.Active = true
                    ts:Create(frame, tweenInfo, {Size = originalSize}):Play()
                end
                isOpen = not isOpen
            end
        end)
-- Tab system
local tabSystem = Tabs.new(frame, theme)

local Window = {}

function Window:AddTab(name)
    return tabSystem:AddTab(name)
end

return Window

end

-- create window
Cloud9Lib:CreateWindow({
    Title = "Cloud9...",
    theme = FrostedThemes.LightGlass,
    Size = UDim2.new(0, 500, 0, 400),
    Position = UDim2.new(0, 150, 0, 150)
})
