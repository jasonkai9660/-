local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 狀態變數
local camLockOn = false
local uiLocked = false
local target = nil

-- ESP 功能開關
local espEnabled = false
local boxEsp = true
local nameEsp = true
local healthEsp = true
local distEsp = true

-- Aimbot 設定
local aimbotFovEnabled = true
local aimbotFovSize = 150
local fovRgbEnabled = true
local aimbotMaxDist = 150 
local aimbotMaxDistLimit = 500
local aimbotMinDist = 0

-- Misc 設定 (飛天與穿牆)
local flyEnabled = false
local flySpeed = 5 -- 預設速度改回 5
local flySpeedLimit = 50 -- 上限保持 50
local noclipEnabled = false

-- ESP 距離設定
local maxDist = 150
local maxDistLimit = 500
local minDist = 0
local C_VIS = Color3.fromRGB(0, 255, 100)
local C_HID = Color3.fromRGB(255, 50, 50)
local customBoxColor = Color3.fromRGB(0, 170, 255) 

local function create(cls, parent, props)
	local inst = Instance.new(cls)
	for k, v in pairs(props or {}) do inst[k] = v end
	inst.Parent = parent
	return inst
end

-- 1. 建立主介面 UI
local sg = create("ScreenGui", PlayerGui, {Name = "ImGuiMenu", ResetOnSpawn = false, DisplayOrder = 999})

local fovGui = create("ScreenGui", PlayerGui, {Name = "AimbotFovGui", ResetOnSpawn = false, DisplayOrder = 998})
local fovCircleFrame = create("Frame", fovGui, {
	Size = UDim2.new(0, aimbotFovSize * 2, 0, aimbotFovSize * 2),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	BackgroundTransparency = 1,
	Visible = false
})
create("UIStroke", fovCircleFrame, {Thickness = 1.5, Color = Color3.fromRGB(255, 255, 255)})
create("UICorner", fovCircleFrame, {CornerRadius = UDim.new(1, 0)})

-- 左上角懸浮按鈕
local btn = create("TextButton", sg, {
	Size = UDim2.new(0, 90, 0, 32),
	Position = UDim2.new(0, 15, 0.4, 0),
	BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	Text = "選單",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SourceSansBold,
	Active = true
})
create("UICorner", btn, {CornerRadius = UDim.new(0, 4)})

local lockBtn = create("TextButton", btn, {
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.new(0, 0, 1, 3),
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	Text = "鎖定UI：關",
	TextColor3 = C_HID,
	TextSize = 10,
	Font = Enum.Font.SourceSansBold,
	Active = true
})
create("UICorner", lockBtn, {CornerRadius = UDim.new(0, 4)})

-- 主視窗
local frame = create("Frame", sg, {
	Size = UDim2.new(0, 480, 0, 380),
	Position = UDim2.new(0.5, -240, 0.5, -190),
	BackgroundColor3 = Color3.fromRGB(22, 22, 24),
	Visible = false
})
create("UICorner", frame, {CornerRadius = UDim.new(0, 6)})
local stroke = create("UIStroke", frame, {Thickness = 1.5, Color = Color3.fromRGB(80, 80, 90)})

-- 標題列
local titleBar = create("Frame", frame, {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(30, 30, 34)})
create("UICorner", titleBar, {CornerRadius = UDim.new(0, 6)})
create("TextLabel", titleBar, {Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "小杰OvO", TextColor3 = Color3.fromRGB(180, 180, 190), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
create("TextLabel", titleBar, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "aimbot進入局內再開", TextColor3 = Color3.fromRGB(255, 200, 50), TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Center})

local closeBtn = create("TextButton", titleBar, {Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = "✕", TextColor3 = Color3.fromRGB(180, 180, 190), TextSize = 12, Font = Enum.Font.SourceSansBold})

-- 分頁列
local tabContainer = create("Frame", frame, {Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0, 8, 0, 32), BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
create("UICorner", tabContainer, {CornerRadius = UDim.new(0, 4)})

local function createTab(name, xPos, width)
	return create("TextButton", tabContainer, {Size = UDim2.new(0, width, 1, 0), Position = UDim2.new(0, xPos, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(160, 160, 170), TextSize = 13, Font = Enum.Font.Code})
end

local tabEsp = createTab("esp", 4, 60)
local tabAim = createTab("aimbot", 68, 70)
local tabMisc = createTab("misc", 142, 60)

local contentArea = create("Frame", frame, {Size = UDim2.new(1, -16, 1, -68), Position = UDim2.new(0, 8, 0, 60), BackgroundColor3 = Color3.fromRGB(28, 28, 32)})
create("UICorner", contentArea, {CornerRadius = UDim.new(0, 4)})
create("UIStroke", contentArea, {Thickness = 1, Color = Color3.fromRGB(50, 50, 58)})

-- 分頁 1：ESP
local pageEsp = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true})

local function makeToggle(parent, text, yPos, defaultState, callback)
	local btn = create("TextButton", parent, {
		Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, yPos),
		BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = (defaultState and "  [☑] " or "  [  ] ") .. text,
		TextColor3 = defaultState and C_VIS or C_HID, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
	})
	create("UICorner", btn, {CornerRadius = UDim.new(0, 4)})
	local state = defaultState
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = (state and "  [☑] " or "  [  ] ") .. text
		btn.TextColor3 = state and C_VIS or C_HID
		callback(state)
	end)
	return btn
end

makeToggle(pageEsp, "enabled (總開關)", 15, espEnabled, function(s) espEnabled = s end)
makeToggle(pageEsp, "highlight/box (方塊透視)", 48, boxEsp, function(s) boxEsp = s end)
makeToggle(pageEsp, "name tag (名稱標籤)", 81, nameEsp, function(s) nameEsp = s end)
makeToggle(pageEsp, "health bar (左側血條)", 114, healthEsp, function(s) healthEsp = s end)
makeToggle(pageEsp, "distance (距離顯示)", 147, distEsp, function(s) distEsp = s end)

local sliderLabel = create("TextLabel", pageEsp, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 185), BackgroundTransparency = 1, Text = "limit distance: " .. maxDist .. "m", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local sliderBg = create("Frame", pageEsp, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 208), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", sliderBg, {CornerRadius = UDim.new(1, 0)})
local sliderFill = create("Frame", sliderBg, {Size = UDim2.new((maxDist - minDist)/(maxDistLimit - minDist), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", sliderFill, {CornerRadius = UDim.new(1, 0)})
local sliderBtn = create("TextButton", sliderBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

-- 分頁 2：Aimbot
local pageAim = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false})

local camLockBtn = create("TextButton", pageAim, {
	Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, 10),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = "  [  ] head lock (強制鎖頭)",
	TextColor3 = C_HID, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", camLockBtn, {CornerRadius = UDim.new(0, 4)})

local fovToggleBtn = create("TextButton", pageAim, {
	Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, 42),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = "  [☑] draw fov (顯示範圍圈)",
	TextColor3 = C_VIS, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", fovToggleBtn, {CornerRadius = UDim.new(0, 4)})

local fovSliderLabel = create("TextLabel", pageAim, {Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(0, 15, 0, 78), BackgroundTransparency = 1, Text = "fov size: " .. aimbotFovSize, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 11, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local fovSliderBg = create("Frame", pageAim, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 96), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", fovSliderBg, {CornerRadius = UDim.new(1, 0)})
local fovSliderFill = create("Frame", fovSliderBg, {Size = UDim2.new((aimbotFovSize - 30) / (400 - 30), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", fovSliderFill, {CornerRadius = UDim.new(1, 0)})
local fovSliderBtn = create("TextButton", fovSliderBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

-- 分頁 3：Misc (飛天與穿牆)
local pageMisc = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false})

local flyToggleBtn = create("TextButton", pageMisc, {
	Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, 10),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = "  [  ] fly (飛天)",
	TextColor3 = C_HID, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", flyToggleBtn, {CornerRadius = UDim.new(0, 4)})

local flySliderLabel = create("TextLabel", pageMisc, {Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(0, 15, 0, 44), BackgroundTransparency = 1, Text = "fly speed: " .. flySpeed, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 11, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local flySliderBg = create("Frame", pageMisc, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 62), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", flySliderBg, {CornerRadius = UDim.new(1, 0)})
local flySliderFill = create("Frame", flySliderBg, {Size = UDim2.new(flySpeed / flySpeedLimit, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", flySliderFill, {CornerRadius = UDim.new(1, 0)})
local flySliderBtn = create("TextButton", flySliderBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

local noclipToggleBtn = create("TextButton", pageMisc, {
	Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, 85),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = "  [  ] noclip (穿牆)",
	TextColor3 = C_HID, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", noclipToggleBtn, {CornerRadius = UDim.new(0, 4)})

-- 分頁切換
local function switchTab(tab)
	pageEsp.Visible = (tab == 1)
	pageAim.Visible = (tab == 2)
	pageMisc.Visible = (tab == 3)
	tabEsp.TextColor3 = (tab == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
	tabAim.TextColor3 = (tab == 2) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
	tabMisc.TextColor3 = (tab == 3) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
end
tabEsp.MouseButton1Click:Connect(function() switchTab(1) end)
tabAim.MouseButton1Click:Connect(function() switchTab(2) end)
tabMisc.MouseButton1Click:Connect(function() switchTab(3) end)

-- 滑動條拖動邏輯
local draggingSlider, draggingFovSlider, draggingFlySlider = false, false, false
sliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)
fovSliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingFovSlider = true end end)
flySliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingFlySlider = true end end)

UserInputService.InputChanged:Connect(function(i)
	if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		if draggingSlider then
			local relX = math.clamp((i.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
			sliderFill.Size = UDim2.new(relX, 0, 1, 0)
			maxDist = math.floor(minDist + (relX * (maxDistLimit - minDist)))
			sliderLabel.Text = "limit distance: " .. maxDist .. "m"
		elseif draggingFovSlider then
			local relX = math.clamp((i.Position.X - fovSliderBg.AbsolutePosition.X) / fovSliderBg.AbsoluteSize.X, 0, 1)
			fovSliderFill.Size = UDim2.new(relX, 0, 1, 0)
			aimbotFovSize = math.floor(30 + (relX * (400 - 30)))
			fovSliderLabel.Text = "fov size: " .. aimbotFovSize
			fovCircleFrame.Size = UDim2.new(0, aimbotFovSize * 2, 0, aimbotFovSize * 2)
		elseif draggingFlySlider then
			local relX = math.clamp((i.Position.X - flySliderBg.AbsolutePosition.X) / flySliderBg.AbsoluteSize.X, 0, 1)
			flySliderFill.Size = UDim2.new(relX, 0, 1, 0)
			flySpeed = math.floor(1 + (relX * (flySpeedLimit - 1)))
			flySliderLabel.Text = "fly speed: " .. flySpeed
		end
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		draggingSlider, draggingFovSlider, draggingFlySlider = false, false, false
	end
end)

-- 飛天優化主迴圈（支援上下視角位移）
RunService.RenderStepped:Connect(function(dt)
	if frame.Visible then stroke.Color = Color3.fromHSV((tick() * 0.5) % 1, 1, 1) end
	fovCircleFrame.Visible = camLockOn and aimbotFovEnabled

	local myChar = LP.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	if flyEnabled and myChar and myRoot then
		local hum = myChar:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = true end

		local moveDir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

		if hum and hum.MoveDirection.Magnitude > 0 then
			moveDir = moveDir + hum.MoveDirection
		end

		if moveDir.Magnitude > 0 then
			myRoot.CFrame = myRoot.CFrame + (moveDir.Unit * flySpeed * dt * 15)
		end
		myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	else
		if myChar then
			local hum = myChar:FindFirstChildOfClass("Humanoid")
			if hum and hum.PlatformStand then hum.PlatformStand = false end
		end
	end

	if noclipEnabled and myChar then
		for _, part in ipairs(myChar:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- 按鈕點擊事件
camLockBtn.MouseButton1Click:Connect(function()
	camLockOn = not camLockOn
	target = nil
	if not camLockOn then Cam.CameraType = Enum.CameraType.Custom end
	camLockBtn.Text = camLockOn and "  [☑] head lock (強制鎖頭)" or "  [  ] head lock (強制鎖頭)"
	camLockBtn.TextColor3 = camLockOn and C_VIS or C_HID
end)

fovToggleBtn.MouseButton1Click:Connect(function()
	aimbotFovEnabled = not aimbotFovEnabled
	fovToggleBtn.Text = aimbotFovEnabled and "  [☑] draw fov (顯示範圍圈)" or "  [  ] draw fov (顯示範圍圈)"
	fovToggleBtn.TextColor3 = aimbotFovEnabled and C_VIS or C_HID
end)

flyToggleBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled and LP.Character then
		for _, part in ipairs(LP.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	flyToggleBtn.Text = flyEnabled and "  [☑] fly (飛天)" or "  [  ] fly (飛天)"
	flyToggleBtn.TextColor3 = flyEnabled and C_VIS or C_HID
end)

noclipToggleBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipToggleBtn.Text = noclipEnabled and "  [☑] noclip (穿牆)" or "  [  ] noclip (穿牆)"
	noclipToggleBtn.TextColor3 = noclipEnabled and C_VIS or C_HID
end)

local function applyDrag(obj)
	local dragging, isDragged, start, pos
	obj.InputBegan:Connect(function(i)
		if not uiLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging, isDragged, start, pos = true, false, i.Position, obj.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not uiLocked and dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - start
			if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then isDragged = true end
			obj.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	return function() return isDragged end
end

local isBtnDragged = applyDrag(btn)
applyDrag(frame)

btn.MouseButton1Click:Connect(function() if not isBtnDragged() then frame.Visible = not frame.Visible end end)
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
lockBtn.MouseButton1Click:Connect(function()
	uiLocked = not uiLocked
	lockBtn.Text = "鎖定UI：" .. (uiLocked and "開" or "關")
	lockBtn.TextColor3 = uiLocked and C_VIS or C_HID
end)
