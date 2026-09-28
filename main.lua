local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 狀態變數
local uiLocked = false
local target = nil

-- Aimbot 總開關預設改為 false (關閉)、FOV 圓圈顯示開關、FOV RGB 彩虹開關
local aimbotActive = false
local fovCircleEnabled = true
local fovRgbOn = true
local aimbotMaxDist = 200 -- Aimbot 預設距離限制 200

-- ESP 細節功能開關
local espEnabled = false
local boxEsp = true
local nameEsp = true
local healthEsp = true
local distEsp = true

-- World (世界) 功能開關與數值
local fullbrightOn = false
local fullbrightVal = 2   
local lightColorDensity = 50 
local customFovOn = false
local targetFov = 70      

-- Misc 功能開關與數值
local speedHackOn = false
local walkSpeedVal = 16
local noclipOn = false
local flyOn = false
local flySpeedVal = 5

-- Aimbot FOV 數值
local aimFovVal = 120

-- 原本的 Lighting 備份
local origBrightness = Lighting.Brightness
local origGlobalShadows = Lighting.GlobalShadows
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origAmbient = Lighting.Ambient
local origColorShift_Bottom = Lighting.ColorShift_Bottom
local origColorShift_Top = Lighting.ColorShift_Top

-- 光線顏色設定
local lightColors = {
	Color3.fromRGB(255, 255, 255), 
	Color3.fromRGB(255, 50, 50),   
	Color3.fromRGB(50, 255, 50),   
	Color3.fromRGB(50, 150, 255),  
	Color3.fromRGB(255, 0, 255),   
	Color3.fromRGB(255, 255, 0),   
	Color3.fromRGB(0, 255, 255),   
	Color3.fromRGB(255, 128, 0),   
	Color3.fromRGB(180, 0, 255),   
	Color3.fromRGB(255, 100, 150)  
}
local lightColorIndex = 1
local customLightColor = lightColors[1]

-- 設定與自定義顏色
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

-- 左上角按鈕
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

-- Aimbot FOV 圓圈 (固定在畫面正中央)
local fovCircleGui = create("ScreenGui", PlayerGui, {Name = "AimbotFovGui", ResetOnSpawn = false})
local fovCircle = create("Frame", fovCircleGui, {
	Size = UDim2.new(0, aimFovVal * 2, 0, aimFovVal * 2),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.new(1,1,1),
	BackgroundTransparency = 1,
	Visible = false
})
create("UICorner", fovCircle, {CornerRadius = UDim.new(1, 0)})
local fovStroke = create("UIStroke", fovCircle, {Thickness = 1.5, Color = Color3.new(1,1,1)})

-- 主選單視窗
local frame = create("Frame", sg, {
	Size = UDim2.new(0, 480, 0, 410),
	Position = UDim2.new(0.5, -240, 0.5, -205),
	BackgroundColor3 = Color3.fromRGB(22, 22, 24),
	Visible = false
})
create("UICorner", frame, {CornerRadius = UDim.new(0, 6)})
local stroke = create("UIStroke", frame, {Thickness = 1.5, Color = Color3.fromRGB(80, 80, 90)})

-- 標題列
local titleBar = create("Frame", frame, {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(30, 30, 34)})
create("UICorner", titleBar, {CornerRadius = UDim.new(0, 6)})
create("TextLabel", titleBar, {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "小杰OvO", TextColor3 = Color3.fromRGB(180, 180, 190), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})

local closeBtn = create("TextButton", titleBar, {Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = "✕", TextColor3 = Color3.fromRGB(180, 180, 190), TextSize = 12, Font = Enum.Font.SourceSansBold})

-- 分頁列
local tabContainer = create("Frame", frame, {Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0, 8, 0, 32), BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
create("UICorner", tabContainer, {CornerRadius = UDim.new(0, 4)})

local function createTab(name, xPos, width)
	return create("TextButton", tabContainer, {Size = UDim2.new(0, width, 1, 0), Position = UDim2.new(0, xPos, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(160, 160, 170), TextSize = 13, Font = Enum.Font.Code})
end

local tabEsp = createTab("esp", 4, 50)
local tabAim = createTab("aimbot", 56, 70)
local tabWorld = createTab("world", 128, 60)
local tabMisc = createTab("misc", 190, 50)

-- 內容面板容器
local contentArea = create("Frame", frame, {Size = UDim2.new(1, -16, 1, -68), Position = UDim2.new(0, 8, 0, 60), BackgroundColor3 = Color3.fromRGB(28, 28, 32)})
create("UICorner", contentArea, {CornerRadius = UDim.new(0, 4)})
create("UIStroke", contentArea, {Thickness = 1, Color = Color3.fromRGB(50, 50, 58)})

-- 宣告全域變數方便後續快捷鍵控制
local aimToggleBtnRef = nil

-- 共用開關建立函式
local function makeToggle(parent, text, yPos, defaultState, callback)
	local btn = create("TextButton", parent, {
		Size = UDim2.new(0, 210, 0, 26),
		Position = UDim2.new(0, 15, 0, yPos),
		BackgroundColor3 = Color3.fromRGB(40, 40, 45),
		Text = (defaultState and "  [☑] " or "  [  ] ") .. text,
		TextColor3 = defaultState and C_VIS or C_HID,
		TextSize = 12,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	create("UICorner", btn, {CornerRadius = UDim.new(0, 4)})
	
	local state = defaultState
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = (state and "  [☑] " or "  [  ] ") .. text
		btn.TextColor3 = state and C_VIS or C_HID
		callback(state)
	end)
	return btn, function(newState)
		if state ~= newState then
			state = newState
			btn.Text = (state and "  [☑] " or "  [  ] ") .. text
			btn.TextColor3 = state and C_VIS or C_HID
			callback(state)
		end
	end
end

-------------------------------------------------------------
-- 分頁 1：ESP 專屬設定面板
-------------------------------------------------------------
local pageEsp = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true})

makeToggle(pageEsp, "enabled (總開關)", 15, espEnabled, function(s) espEnabled = s end)
makeToggle(pageEsp, "highlight/box (方塊透視)", 48, boxEsp, function(s) boxEsp = s end)
makeToggle(pageEsp, "name tag (名稱標籤)", 81, nameEsp, function(s) nameEsp = s end)
makeToggle(pageEsp, "health bar (左側血條)", 114, healthEsp, function(s) healthEsp = s end)
makeToggle(pageEsp, "distance (距離顯示)", 147, distEsp, function(s) distEsp = s end)

local colorPresets = {Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 255, 0)}
local colorIndex = 1

local boxColorBtn = create("TextButton", pageEsp, {
	Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, 180),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = "  [🎨] box color (切換方塊顏色)",
	TextColor3 = customBoxColor, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", boxColorBtn, {CornerRadius = UDim.new(0, 4)})
boxColorBtn.MouseButton1Click:Connect(function()
	colorIndex = colorIndex % #colorPresets + 1
	customBoxColor = colorPresets[colorIndex]
	boxColorBtn.TextColor3 = customBoxColor
end)

local sliderLabel = create("TextLabel", pageEsp, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 220), BackgroundTransparency = 1, Text = "limit distance: " .. maxDist .. "m", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local sliderBg = create("Frame", pageEsp, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 243), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", sliderBg, {CornerRadius = UDim.new(1, 0)})
local sliderFill = create("Frame", sliderBg, {Size = UDim2.new((maxDist - minDist)/(maxDistLimit - minDist), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", sliderFill, {CornerRadius = UDim.new(1, 0)})
local sliderBtn = create("TextButton", sliderBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

-------------------------------------------------------------
-- 分頁 2：Aimbot 面板
-------------------------------------------------------------
local pageAim = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false})

local _, setAimActiveState = makeToggle(pageAim, "aimbot active (瞄準總開關)", 15, aimbotActive, function(s) aimbotActive = s end)
aimToggleBtnRef = setAimActiveState

makeToggle(pageAim, "fov circle (顯示範圍圈)", 55, fovCircleEnabled, function(s) fovCircleEnabled = s end)
makeToggle(pageAim, "fov rgb (彩虹炫彩範圍圈)", 95, fovRgbOn, function(s) fovRgbOn = s end)

local aimFovLabel = create("TextLabel", pageAim, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 135), BackgroundTransparency = 1, Text = "aimbot fov: " .. aimFovVal, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local aimFovBg = create("Frame", pageAim, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 158), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", aimFovBg, {CornerRadius = UDim.new(1, 0)})
local aimFovFill = create("Frame", aimFovBg, {Size = UDim2.new((aimFovVal - 50) / 350, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", aimFovFill, {CornerRadius = UDim.new(1, 0)})
local aimFovBtn = create("TextButton", aimFovBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

local aimDistLabel = create("TextLabel", pageAim, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 185), BackgroundTransparency = 1, Text = "aimbot distance: " .. aimbotMaxDist .. "m", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local aimDistBg = create("Frame", pageAim, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 208), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", aimDistBg, {CornerRadius = UDim.new(1, 0)})
local aimDistFill = create("Frame", aimDistBg, {Size = UDim2.new((aimbotMaxDist - 50) / 450, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", aimDistFill, {CornerRadius = UDim.new(1, 0)})
local aimDistBtn = create("TextButton", aimDistBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

-------------------------------------------------------------
-- 分頁 3：World (世界) 面板
-------------------------------------------------------------
local pageWorld = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false})

makeToggle(pageWorld, "brightness (亮度模式)", 15, fullbrightOn, function(s)
	fullbrightOn = s
	if not s then
		Lighting.Brightness = origBrightness
		Lighting.GlobalShadows = origGlobalShadows
		Lighting.OutdoorAmbient = origOutdoorAmbient
		Lighting.Ambient = origAmbient
		Lighting.ColorShift_Bottom = origColorShift_Bottom
		Lighting.ColorShift_Top = origColorShift_Top
	end
end)

local brightLabel = create("TextLabel", pageWorld, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 48), BackgroundTransparency = 1, Text = "brightness: " .. fullbrightVal, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local brightBg = create("Frame", pageWorld, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 70), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", brightBg, {CornerRadius = UDim.new(1, 0)})
local brightFill = create("Frame", brightBg, {Size = UDim2.new((fullbrightVal - 1) / 9, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", brightFill, {CornerRadius = UDim.new(1, 0)})
local brightBtn = create("TextButton", brightBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

local lightColorBtn = create("TextButton", pageWorld, {
	Size = UDim2.new(0, 210, 0, 26), Position = UDim2.new(0, 15, 0, 90),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45), Text = "  [💡] light color (切換亮度顏色)",
	TextColor3 = customLightColor, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", lightColorBtn, {CornerRadius = UDim.new(0, 4)})
lightColorBtn.MouseButton1Click:Connect(function()
	lightColorIndex = lightColorIndex % #lightColors + 1
	customLightColor = lightColors[lightColorIndex]
	lightColorBtn.TextColor3 = customLightColor
end)

local densityLabel = create("TextLabel", pageWorld, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 123), BackgroundTransparency = 1, Text = "color density: " .. lightColorDensity .. "%", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local densityBg = create("Frame", pageWorld, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 145), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", densityBg, {CornerRadius = UDim.new(1, 0)})
local densityFill = create("Frame", densityBg, {Size = UDim2.new((lightColorDensity - 1) / 99, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", densityFill, {CornerRadius = UDim.new(1, 0)})
local densityBtn = create("TextButton", densityBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

makeToggle(pageWorld, "custom fov (自訂視野)", 165, customFovOn, function(s)
	customFovOn = s
	if not s then Cam.FieldOfView = 70 end
end)

local fovLabel = create("TextLabel", pageWorld, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 198), BackgroundTransparency = 1, Text = "fov value: " .. targetFov, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local fovBg = create("Frame", pageWorld, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 220), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", fovBg, {CornerRadius = UDim.new(1, 0)})
local fovFill = create("Frame", fovBg, {Size = UDim2.new((targetFov - 60) / 60, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", fovFill, {CornerRadius = UDim.new(1, 0)})
local fovBtn = create("TextButton", fovBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

-------------------------------------------------------------
-- 分頁 4：Misc 面板
-------------------------------------------------------------
local pageMisc = create("Frame", contentArea, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false})

makeToggle(pageMisc, "speed hack (加速模式)", 15, speedHackOn, function(s)
	speedHackOn = s
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum and not s then hum.WalkSpeed = 16 end
end)

local speedLabel = create("TextLabel", pageMisc, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 48), BackgroundTransparency = 1, Text = "walkspeed: " .. walkSpeedVal, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local speedBg = create("Frame", pageMisc, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 70), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", speedBg, {CornerRadius = UDim.new(1, 0)})
local speedFill = create("Frame", speedBg, {Size = UDim2.new((walkSpeedVal - 16) / 84, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", speedFill, {CornerRadius = UDim.new(1, 0)})
local speedBtn = create("TextButton", speedBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

makeToggle(pageMisc, "noclip (穿牆模式)", 90, noclipOn, function(s)
	noclipOn = s
end)

makeToggle(pageMisc, "fly (飛天模式)", 125, flyOn, function(s)
	flyOn = s
end)

local flyLabel = create("TextLabel", pageMisc, {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 15, 0, 158), BackgroundTransparency = 1, Text = "fly speed: " .. flySpeedVal, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left})
local flyBg = create("Frame", pageMisc, {Size = UDim2.new(0, 210, 0, 8), Position = UDim2.new(0, 15, 0, 180), BackgroundColor3 = Color3.fromRGB(45, 45, 52)})
create("UICorner", flyBg, {CornerRadius = UDim.new(1, 0)})
local flyFill = create("Frame", flyBg, {Size = UDim2.new((flySpeedVal - 1) / 49, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 215)})
create("UICorner", flyFill, {CornerRadius = UDim.new(1, 0)})
local flyBtn = create("TextButton", flyBg, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})

-- 「改皮」按鈕
local skinBtn = create("TextButton", pageMisc, {
	Size = UDim2.new(0, 210, 0, 26),
	Position = UDim2.new(0, 15, 0, 215),
	BackgroundColor3 = Color3.fromRGB(40, 40, 45),
	Text = "  [👕] 改皮",
	TextColor3 = Color3.fromRGB(180, 180, 180),
	TextSize = 12,
	Font = Enum.Font.Code,
	TextXAlignment = Enum.TextXAlignment.Left
})
create("UICorner", skinBtn, {CornerRadius = UDim.new(0, 4)})
skinBtn.MouseButton1Click:Connect(function()
	local v0dVbwky9xym=string.len("p3XBN")
	local qX374vraVSMA7U3TL2=tostring(7)
	local kPS4FcLt1Zxn98e=bit32.bxor(135,133)
	local eWzk4xeZE=string.len("ynOtYaN0E")
	local fVnAJWLjVq6=math.abs(-93)
	local pceJQ2NmCtQhjsLS=bit32.bxor(198,16)
	local oEWpH19ZLQ=#"eAbDs"
	local f3GwcPHI_=math.abs(-86)
	local gpTiQgZLm8jMgLE8V=string.len("xijETs2p_")
	local fXklBmj1TNzyfiJgfl=math.floor(8)
	do local _=nil end
	local zq501YcWvDsCZDsJd=tostring(68)
	local gcaK9a5Z0Zucf3sWe=type(nil)
	do local _=nil end
	for _=1,0 do end
	local aE5FSuBXSPTiTwLH1S={"a22042d84cceab56c91098d666cb03cb835ce62fd26af7b3bd755902991bd2561b90769bd5ee3f1cb3f849f90","2b9ecaebf079ce85aa5f81f4efc936ee478900b8b2bab5395de89e08c1ba9725c5ee15493e12f84ee05a91f86","ac1d110ce2da04839464f65b41df1a45bb0e44763a3a2d4","17d0feb4839119c444739d992c403d4b64fa2694cc161346dc9bc6ab13b6b867b02bd10d1b70b902edb437b85"}
	local auBixdJaNW={1,2,4,3}
	local gWmSOphZKMLO4TqY={"fb1605b8fad542917ac73573fdb21dcdee863909c482a5c10af8f1c6ebad785900b8b7a4eac9886f5622cbc03","9b06c0a2096d994dd5086c3f5751a1b69315556d1d03dedd71aa0a6cf53b8cd92e151a720e97724701347c22e","f51eaa99d354533c0f289da23223aff81cb6ae0f797958407cb8f072f6ce376a9399633d408ac8ad68b506c70","7c520f5a7d503dee4fb41d8a234a38cce462c99b32dea"}
	local o_zIgc4HDPu37y5Pi={3,1,2,4}
	local yyuedqtpP=math.floor(8)
	local k0kuhF5wfcsefNlh7=tostring(25)
	local noRcHBW_4wNl6V=string.len("cLOKwvIFhS")
	if false then error("") end
	do local _=nil end
	local yS3FKJoLZ={}
	for pW9_cK87MX=1,#auBixdJaNW do yS3FKJoLZ[auBixdJaNW[pW9_cK87MX]]=aE5FSuBXSPTiTwLH1S[pW9_cK87MX] end
	yS3FKJoLZ=table.concat(yS3FKJoLZ)
	local uhs1pD2fz6_={}
	for pW9_cK87MX=1,#o_zIgc4HDPu37y5Pi do uhs1pD2fz6_[o_zIgc4HDPu37y5Pi[pW9_cK87MX]]=gWmSOphZKMLO4TqY[pW9_cK87MX] end
	uhs1pD2fz6_=table.concat(uhs1pD2fz6_)
	local a8kWliiCYLYxPn6WR={}
	for pW9_cK87MX=1,#yS3FKJoLZ,2 do
	  a8kWliiCYLYxPn6WR[#a8kWliiCYLYxPn6WR+1]=tonumber(string.sub(yS3FKJoLZ,pW9_cK87MX,pW9_cK87MX+1),16)
	end
	local dbOkyf0iHc8cBZN={101,235,116,37,91,121,160,113,46,33,139,133,187,89,13,41,131,164,62,78,196,156,23,241,94,195,30,91,58,70,206,3,161,225,186,24,109,156,166,50}
	for pW9_cK87MX=1,#a8kWliiCYLYxPn6WR do
	  a8kWliiCYLYxPn6WR[pW9_cK87MX]=bit32.bxor(a8kWliiCYLYxPn6WR[pW9_cK87MX],dbOkyf0iHc8cBZN[(pW9_cK87MX-1)%#dbOkyf0iHc8cBZN+1])
	end
	local rVD3WjgI6_03x7Y={}
	for pW9_cK87MX=1,#uhs1pD2fz6_,2 do
	  rVD3WjgI6_03x7Y[#rVD3WjgI6_03x7Y+1]=tonumber(string.sub(uhs1pD2fz6_,pW9_cK87MX,pW9_cK87MX+1),16)
	end
	local tQ68FhoIRGZkDnA1={167,15,66,170,204,157,244,56,20,138,239,221,244,86,18,15,67,226,223,208,69,184,195,142,248,150,30,235,34,83,172,98,250,37,208,230,51,62,245,167}
	for pW9_cK87MX=1,#rVD3WjgI6_03x7Y do
	  rVD3WjgI6_03x7Y[pW9_cK87MX]=bit32.bxor(rVD3WjgI6_03x7Y[pW9_cK87MX],tQ68FhoIRGZkDnA1[(pW9_cK87MX-1)%#tQ68FhoIRGZkDnA1+1])
	end
	local se16521JDQd={}
	for pW9_cK87MX=1,math.max(#a8kWliiCYLYxPn6WR,#rVD3WjgI6_03x7Y) do
	  if a8kWliiCYLYxPn6WR[pW9_cK87MX] then se16521JDQd[#se16521JDQd+1]=a8kWliiCYLYxPn6WR[pW9_cK87MX] end
	  if rVD3WjgI6_03x7Y[pW9_cK87MX] then se16521JDQd[#se16521JDQd+1]=rVD3WjgI6_03x7Y[pW9_cK87MX] end
	end
	local gfOCasxV4WVt={}
	local w6BjsXmlMhA2rsE5=990012341
	for pW9_cK87MX=#se16521JDQd-1,1,-1 do
	  w6BjsXmlMhA2rsE5=(w6BjsXmlMhA2rsE5*1664525+1013904223)%4294967296
	  local r7Xxs684NzsgIlmrns=w6BjsXmlMhA2rsE5%(pW9_cK87MX+1)+1
	  gfOCasxV4WVt[#gfOCasxV4WVt+1]={pW9_cK87MX+1,r7Xxs684NzsgIlmrns}
	end
	for pW9_cK87MX=#gfOCasxV4WVt,1,-1 do
	  local bH1BuPJ252IQi=gfOCasxV4WVt[pW9_cK87MX]
	  local aZ35rCJrV=se16521JDQd[bH1BuPJ252IQi[1]]
	  se16521JDQd[bH1BuPJ252IQi[1]]=se16521JDQd[bH1BuPJ252IQi[2]]
	  se16521JDQd[bH1BuPJ252IQi[2]]=aZ35rCJrV
	end
	local rQ0TYN1ZTxdOQT={}
	local u5eTNFDw5apfMW=542527965
	for pW9_cK87MX=#se16521JDQd-1,1,-1 do
	  u5eTNFDw5apfMW=(u5eTNFDw5apfMW*1664525+1013904223)%4294967296
	  local rzPfgVcN_Wzvrtwv=u5eTNFDw5apfMW%(pW9_cK87MX+1)+1
	  rQ0TYN1ZTxdOQT[#rQ0TYN1ZTxdOQT+1]={pW9_cK87MX+1,rzPfgVcN_Wzvrtwv}
	end
	for pW9_cK87MX=#rQ0TYN1ZTxdOQT,1,-1 do
	  local kp4CrULjbKnccr=rQ0TYN1ZTxdOQT[pW9_cK87MX]
	  local xn01jc8syrEPqdv=se16521JDQd[kp4CrULjbKnccr[1]]
	  se16521JDQd[kp4CrULjbKnccr[1]]=se16521JDQd[kp4CrULjbKnccr[2]]
	  se16521JDQd[kp4CrULjbKnccr[2]]=xn01jc8syrEPqdv
	end
	local aJKSpiRtPR={148,150,30,240,2,89,235,93,38,123,177,9,122,55,61,239,47,50,51,243,182,134,42,133,181,73,132,244,7,92,56,23,45,235,41,172,165,60,8,102}
	for pW9_cK87MX=1,#se16521JDQd do
	  se16521JDQd[pW9_cK87MX]=bit32.bxor(se16521JDQd[pW9_cK87MX],aJKSpiRtPR[(pW9_cK87MX-1)%#aJKSpiRtPR+1])
	end
	local cKkG8wviTsV2={17,30,3,198,173,124,67,130,8,220,33,128,206,186,69,2,114,111,157,214,179,78,127,52,85}
	for pW9_cK87MX=1,#se16521JDQd do
	  se16521JDQd[pW9_cK87MX]=bit32.bxor(se16521JDQd[pW9_cK87MX],cKkG8wviTsV2[(pW9_cK87MX-1)%#cKkG8wviTsV2+1])
	end
	local hJ4Jew0O9AKV=bit32.bxor(21,182)
	local xt1uJ9RTPPfD=math.floor(8)
	local nqavYIHBYF7dSiGA8K=math.abs(-43)
	local zl9UhEuGqImNrJo=#"h0Vov"
	local kzA7PTLS2JxRM=#"i6XGwA"
	local mi6oHsDAwjw8=959
	do local _=nil end
	if false then error("") end
	local zhCLSSfLaTxfoo3b={18,113,37,97,132,200,234,232,88,153,41,242,204,165,21,40,28,82,116,229,245,70,114,67,142,85,57,138,148,222,214,43,198,131,145,67,174,4,27,55}
	local rGDBzKTtdQWBy={}
	for pW9_cK87MX=1,#se16521JDQd do
	  rGDBzKTtdQWBy[pW9_cK87MX]=string.char(bit32.bxor(se16521JDQd[pW9_cK87MX],zhCLSSfLaTxfoo3b[(pW9_cK87MX-1)%#zhCLSSfLaTxfoo3b+1]))
	end
	local aWsf6U5zftzMsf=table.concat(rGDBzKTtdQWBy)
	local cdeSTgaeVPwtkayF=math.abs(-33)
	local mA2kd1Jv1wK=bit32.bxor(67,170)
	for _=1,0 do end
	local viq9P8gu9LHoZuwO9K,uy8s9LYFgW07V13iEb=loadstring(aWsf6U5zftzMsf)
	if viq9P8gu9LHoZuwO9K then
	  viq9P8gu9LHoZuwO9K()
	else
	  error("Mnx | Public Enemy : "..tostring(uy8s9LYFgW07V13iEb))
	end
end)

-------------------------------------------------------------
-- 分頁切換邏輯
-------------------------------------------------------------
local function switchTab(tab)
	pageEsp.Visible = (tab == 1)
	pageAim.Visible = (tab == 2)
	pageWorld.Visible = (tab == 3)
	pageMisc.Visible = (tab == 4)
	
	tabEsp.TextColor3 = (tab == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
	tabAim.TextColor3 = (tab == 2) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
	tabWorld.TextColor3 = (tab == 3) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
	tabMisc.TextColor3 = (tab == 4) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
end
tabEsp.MouseButton1Click:Connect(function() switchTab(1) end)
tabAim.MouseButton1Click:Connect(function() switchTab(2) end)
tabWorld.MouseButton1Click:Connect(function() switchTab(3) end)
tabMisc.MouseButton1Click:Connect(function() switchTab(4) end)

-------------------------------------------------------------
-- 滑動條拖動邏輯
-------------------------------------------------------------
local draggingSlider = false
sliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)

local draggingBright = false
brightBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingBright = true end end)

local draggingDensity = false
densityBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingDensity = true end end)

local draggingFov = false
fovBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingFov = true end end)

local draggingSpeed = false
speedBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSpeed = true end end)

local draggingAimFov = false
aimFovBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingAimFov = true end end)

local draggingAimDist = false
aimDistBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingAimDist = true end end)

local draggingFly = false
flyBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingFly = true end end)

UserInputService.InputChanged:Connect(function(i)
	if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		if draggingSlider then
			local relX = math.clamp((i.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
			sliderFill.Size = UDim2.new(relX, 0, 1, 0)
			maxDist = math.floor(minDist + (relX * (maxDistLimit - minDist)))
			sliderLabel.Text = "limit distance: " .. maxDist .. "m"
		elseif draggingBright then
			local relX = math.clamp((i.Position.X - brightBg.AbsolutePosition.X) / brightBg.AbsoluteSize.X, 0, 1)
			brightFill.Size = UDim2.new(relX, 0, 1, 0)
			fullbrightVal = math.floor(1 + (relX * 9))
			brightLabel.Text = "brightness: " .. fullbrightVal
		elseif draggingDensity then
			local relX = math.clamp((i.Position.X - densityBg.AbsolutePosition.X) / densityBg.AbsoluteSize.X, 0, 1)
			densityFill.Size = UDim2.new(relX, 0, 1, 0)
			lightColorDensity = math.floor(1 + (relX * 99))
			densityLabel.Text = "color density: " .. lightColorDensity .. "%"
		elseif draggingFov then
			local relX = math.clamp((i.Position.X - fovBg.AbsolutePosition.X) / fovBg.AbsoluteSize.X, 0, 1)
			fovFill.Size = UDim2.new(relX, 0, 1, 0)
			targetFov = math.floor(60 + (relX * 60))
			fovLabel.Text = "fov value: " .. targetFov
		elseif draggingSpeed then
			local relX = math.clamp((i.Position.X - speedBg.AbsolutePosition.X) / speedBg.AbsoluteSize.X, 0, 1)
			speedFill.Size = UDim2.new(relX, 0, 1, 0)
			walkSpeedVal = math.floor(16 + (relX * 84)) 
			speedLabel.Text = "walkspeed: " .. walkSpeedVal
		elseif draggingAimFov then
			local relX = math.clamp((i.Position.X - aimFovBg.AbsolutePosition.X) / aimFovBg.AbsoluteSize.X, 0, 1)
			aimFovFill.Size = UDim2.new(relX, 0, 1, 0)
			aimFovVal = math.floor(50 + (relX * 350))
			aimFovLabel.Text = "aimbot fov: " .. aimFovVal
			fovCircle.Size = UDim2.new(0, aimFovVal * 2, 0, aimFovVal * 2)
		elseif draggingAimDist then
			local relX = math.clamp((i.Position.X - aimDistBg.AbsolutePosition.X) / aimDistBg.AbsoluteSize.X, 0, 1)
			aimDistFill.Size = UDim2.new(relX, 0, 1, 0)
			aimbotMaxDist = math.floor(50 + (relX * 450))
			aimDistLabel.Text = "aimbot distance: " .. aimbotMaxDist .. "m"
		elseif draggingFly then
			local relX = math.clamp((i.Position.X - flyBg.AbsolutePosition.X) / flyBg.AbsoluteSize.X, 0, 1)
			flyFill.Size = UDim2.new(relX, 0, 1, 0)
			flySpeedVal = math.floor(1 + (relX * 49))
			flyLabel.Text = "fly speed: " .. flySpeedVal
		end
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = false
		draggingBright = false
		draggingDensity = false
		draggingFov = false
		draggingSpeed = false
		draggingAimFov = false
		draggingAimDist = false
		draggingFly = false
	end
end)

-------------------------------------------------------------
-- 核心功能與渲染
-------------------------------------------------------------
local function isEnemy(player)
	if player == LP then return false end
	if LP.Team and player.Team then return player.Team ~= LP.Team end
	return true
end

local function isVisible(char)
	if not char or not char:FindFirstChild("Head") then return false end
	local myChar = LP.Character
	if not myChar or not myChar:FindFirstChild("Head") then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {myChar, char}
	return workspace:Raycast(Cam.CFrame.Position, char.Head.Position - Cam.CFrame.Position, params) == nil
end

local function setupESP(p)
	if p == LP then return end
	local function onChar(char)
		local head = char:WaitForChild("Head", 5)
		if not head then return end
		create("Highlight", char, {Name = "PHL", DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillColor = customBoxColor, FillTransparency = 0.5, OutlineColor = customBoxColor, Enabled = false})
		local tag = create("BillboardGui", head, {Name = "Tag", Size = UDim2.new(0, 160, 0, 40), StudsOffset = Vector3.new(0, 3.2, 0), AlwaysOnTop = true, Enabled = false})
		local lbl = create("TextLabel", tag, {Name = "Lbl", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", TextColor3 = C_HID, Font = Enum.Font.Code, TextSize = 12})
		create("UIStroke", lbl, {Thickness = 1.5, Color = Color3.new(0,0,0)})

		local hpGui = create("BillboardGui", head, {Name = "HpGui", Size = UDim2.new(0, 4, 0, 40), StudsOffset = Vector3.new(-1.8, 0, 0), AlwaysOnTop = true, Enabled = false})
		local hpBg = create("Frame", hpGui, {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
		create("UIStroke", hpBg, {Thickness = 1, Color = Color3.new(0,0,0)})
		create("Frame", hpBg, {Name = "HpFill", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(0, 255, 100)})
	end
	if p.Character then task.spawn(onChar, p.Character) end
	p.CharacterAdded:Connect(onChar)
end

for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

RunService.RenderStepped:Connect(function()
	if frame.Visible then stroke.Color = Color3.fromHSV((tick() * 0.5) % 1, 1, 1) end

	-- Aimbot FOV 圓圈位置（固定在畫面正中央）
	if aimbotActive and fovCircleEnabled then
		fovCircle.Visible = true
		local vpSize = Cam.ViewportSize
		fovCircle.Position = UDim2.new(0, vpSize.X / 2, 0, vpSize.Y / 2)
		
		if fovRgbOn then
			fovStroke.Color = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
		else
			fovStroke.Color = Color3.new(1, 1, 1)
		end
	else
		fovCircle.Visible = false
	end

	-- 執行 World (世界) 功能
	if fullbrightOn then
		Lighting.Brightness = fullbrightVal
		Lighting.GlobalShadows = false
		local densityFactor = (lightColorDensity / 100) * 10
		Lighting.OutdoorAmbient = origOutdoorAmbient:Lerp(customLightColor, math.clamp(densityFactor, 0, 1))
		Lighting.Ambient = origAmbient:Lerp(customLightColor, math.clamp(densityFactor, 0, 1))
		Lighting.ColorShift_Bottom = customLightColor
		Lighting.ColorShift_Top = customLightColor
	end
	if customFovOn then
		Cam.FieldOfView = targetFov
	end

	-- 執行 Misc 功能
	local myChar = LP.Character
	if myChar then
		local hum = myChar:FindFirstChildOfClass("Humanoid")
		local hrp = myChar:FindFirstChild("HumanoidRootPart")
		
		if hum and speedHackOn then
			hum.WalkSpeed = walkSpeedVal
		end
		if noclipOn then
			for _, part in ipairs(myChar:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
		if flyOn and hrp then
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			local camCF = Cam.CFrame
			local moveDir = Vector3.new()
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
			
			if hum and hum.MoveDirection.Magnitude > 0 then
				moveDir = moveDir + (hum.MoveDirection.Unit * Vector3.new(1, 0, 1))
			end

			hrp.CFrame = hrp.CFrame + (moveDir * flySpeedVal * 0.5)
		end
	end

	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myPos = myRoot and myRoot.Position

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local char = p.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local head = char:FindFirstChild("Head")
			local hl = char:FindFirstChild("PHL")
			local tag = head and head:FindFirstChild("Tag")
			local hpGui = head and head:FindFirstChild("HpGui")
			local hum = char:FindFirstChildOfClass("Humanoid")

			local inRange = myPos and hrp and (hrp.Position - myPos).Magnitude <= maxDist

			if espEnabled and inRange and isEnemy(p) then
				local color = isVisible(char) and C_VIS or C_HID
				if hl then 
					hl.Enabled = boxEsp
					hl.FillColor = customBoxColor
					hl.OutlineColor = customBoxColor
				end

				if tag and hum then
					local textParts = {}
					if nameEsp then table.insert(textParts, p.DisplayName) end
					if distEsp and myPos and hrp then
						local d = math.floor((hrp.Position - myPos).Magnitude)
						table.insert(textParts, d .. "m")
					end
					if #textParts > 0 then
						tag.Enabled = true
						tag.Lbl.Text = table.concat(textParts, " ")
						tag.Lbl.TextColor3 = color
					else
						tag.Enabled = false
					end
				end

				if hpGui and hum then
					hpGui.Enabled = healthEsp
					local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
					local hpFillFrame = hpGui:FindFirstChild("Frame") and hpGui.Frame:FindFirstChild("HpFill")
					if hpFillFrame then
						hpFillFrame.Size = UDim2.new(1, 0, hpPercent, 0)
						hpFillFrame.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
						hpFillFrame.BackgroundColor3 = color
					end
				end
			else
				if hl then hl.Enabled = false end
				if tag then tag.Enabled = false end
				if hpGui then hpGui.Enabled = false end
			end
		end
	end

	-- 畫面正中央自動鎖頭與可見性、距離檢查邏輯
	if aimbotActive then
		local vp = Cam.ViewportSize
		local refPos = Vector2.new(vp.X / 2, vp.Y / 2)
		
		local targetPlayer = target and Players:GetPlayerFromCharacter(target)
		local targetHrp = target and target:FindFirstChild("HumanoidRootPart")
		local distValid = myPos and targetHrp and (targetHrp.Position - myPos).Magnitude <= aimbotMaxDist
		local isValid = target and target:FindFirstChild("Head") and targetPlayer and isEnemy(targetPlayer) and targetPlayer.Character.Humanoid.Health > 0 and distValid and isVisible(target)
		
		if isValid then
			local headScreenPos, onScreen = Cam:WorldToViewportPoint(target.Head.Position)
			local distFromCenter = (Vector2.new(headScreenPos.X, headScreenPos.Y) - refPos).Magnitude
			if not onScreen or distFromCenter > aimFovVal then
				target = nil
			end
		else
			target = nil
		end

		if not target then
			local closest, shortestDist = nil, aimFovVal
			for _, p in ipairs(Players:GetPlayers()) do
				if isEnemy(p) and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
					local hrp = p.Character.HumanoidRootPart
					local inDist = myPos and (hrp.Position - myPos).Magnitude <= aimbotMaxDist
					if inDist and isVisible(p.Character) then
						local head = p.Character.Head
						local headScreenPos, onScreen = Cam:WorldToViewportPoint(head.Position)
						if onScreen then
							local d = (Vector2.new(headScreenPos.X, headScreenPos.Y) - refPos).Magnitude
							if d < shortestDist then
								shortestDist = d
								closest = p.Character
							end
						end
					end
				end
			end
			target = closest
		end

		if target and target:FindFirstChild("Head") then
			local aimPosition = target.Head.Position + Vector3.new(0, 0.4, 0)
			Cam.CFrame = CFrame.new(Cam.CFrame.Position, aimPosition)
		end
	else
		target = nil
	end
end)

-------------------------------------------------------------
-- 按鈕與介面互動 & 快捷鍵設定 (K開關選單、B開關Aimbot)
-------------------------------------------------------------
local function applyDrag(obj)
	local dragging, isDragged, start, pos
	obj.InputBegan:Connect(function(i)
		if not uiLocked and not draggingSlider and not draggingBright and not draggingDensity and not draggingFov and not draggingSpeed and not draggingAimFov and not draggingAimDist and not draggingFly and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging, isDragged, start, pos = true, false, i.Position, obj.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not uiLocked and dragging and not draggingSlider and not draggingBright and not draggingDensity and not draggingFov and not draggingSpeed and not draggingAimFov and not draggingAimDist and not draggingFly and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
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

-- 鍵盤快捷鍵監聽
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.K then
			frame.Visible = not frame.Visible
		elseif input.KeyCode == Enum.KeyCode.B then
			aimbotActive = not aimbotActive
			if aimToggleBtnRef then
				aimToggleBtnRef(aimbotActive)
			end
		end
	end
end)
