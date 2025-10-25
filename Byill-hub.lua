-- 완전 초기화
if _G.FaceSystemRunning then
	_G.FaceSystemRunning = false
	if _G.FaceEvent then _G.FaceEvent:Destroy() end
	if _G.FaceChatConnection then _G.FaceChatConnection:Disconnect() end
	if _G.FaceGui and _G.FaceGui.Destroy then pcall(function() _G.FaceGui:Destroy() end) end
	if _G.TrackingConnection then _G.TrackingConnection:Disconnect() end
	task.wait(0.2)
end
_G.FaceSystemRunning = true
_G.FaceEvent = Instance.new("BindableEvent")

-----------------------------------------------------
-- 기본 서비스
-----------------------------------------------------
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
_G.FaceGui = Rayfield

-----------------------------------------------------
-- GUI 구성
-----------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "Host Menu",
	LoadingTitle = "Face Test System"
})
local Tab = Window:CreateTab("Control")

local TargetPlayer
local FaceTestActive = false

-- 🧭 상태 표시
local StatusParagraph = Tab:CreateParagraph({
	Title = "Face Test 상태",
	Content = "❌ 비활성 상태"
})

local function UpdateStatus(active)
	if active then
		StatusParagraph:Set({
			Title = "Face Test 상태",
			Content = "<font color='rgb(0,255,0)'>✅ 활성 상태</font>"
		})
	else
		StatusParagraph:Set({
			Title = "Face Test 상태",
			Content = "<font color='rgb(255,0,0)'>❌ 비활성 상태</font>"
		})
	end
end

-----------------------------------------------------
-- 🧩 Tester 입력 (Rayfield 알림 포함)
-----------------------------------------------------
Tab:CreateInput({
	Name = "Tester 이름 입력",
	PlaceholderText = "플레이어 이름",
	RemoveTextAfterFocusLost = false,
	Callback = function(name)
		local player = game.Players:FindFirstChild(name)
		if player then
			TargetPlayer = player
			Rayfield:Notify({
				Title = "✅ Tester 입력 확인됨",
				Content = string.format("(%s)", name),
				Duration = 3
			})
		else
			Rayfield:Notify({
				Title = "❌ Tester 찾을 수 없음",
				Content = string.format("입력한 이름: %s", name),
				Duration = 3
			})
		end
	end
})

-----------------------------------------------------
-- 🧭 제식 명령
-----------------------------------------------------
local Commands = {
	["Right face."] = -90,
	["Left face."] = 90,
	["Right incline."] = -45,
	["Left incline."] = 45,
	["About face."] = 180,
	["Control face."] = "control",
	["Center face."] = "center",
	["Face Test Start."] = "start",
	["Face Test End."] = "end"
}

-----------------------------------------------------
-- 💬 채팅 감지
-----------------------------------------------------
_G.FaceChatConnection = TextChatService.MessageReceived:Connect(function(m)
	if not _G.FaceSystemRunning or not m.TextSource then return end
	local p = game.Players:GetPlayerByUserId(m.TextSource.UserId)
	if p ~= TargetPlayer then return end
	local t = m.Text:gsub("^[-;]", "")
	if Commands[t] then
		_G.FaceEvent:Fire(t)
	end
end)

-----------------------------------------------------
-- 🎮 제식 동작 처리
-----------------------------------------------------
_G.FaceEvent.Event:Connect(function(cmd)
	local host = game.Players.LocalPlayer
	local hhrp = host.Character and host.Character:FindFirstChild("HumanoidRootPart")
	if not hhrp then return end

	local function CameraShake()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local base = cam.CFrame
		for i = 1, 2 do
			cam.CFrame = base * CFrame.new(math.random(-1,1)*0.1, math.random(-1,1)*0.1, 0)
			task.wait(0.02)
		end
		cam.CFrame = base
	end

	if cmd == "start" or cmd == "Face Test Start." then
		FaceTestActive = true
		UpdateStatus(true)
		CameraShake()

	elseif cmd == "end" or cmd == "Face Test End." then
		FaceTestActive = false
		UpdateStatus(false)
		CameraShake()
		if _G.TrackingConnection then _G.TrackingConnection:Disconnect() end
		_G.TrackingConnection = nil

	elseif cmd == "Control face." then
		if not FaceTestActive then return end
		if _G.TrackingConnection then _G.TrackingConnection:Disconnect() end
		CameraShake()
		_G.TrackingConnection = RunService.RenderStepped:Connect(function()
			if not TargetPlayer then return end
			local thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not thrp then return end
			local dir = thrp.Position - hhrp.Position
			hhrp.CFrame = CFrame.lookAt(hhrp.Position, hhrp.Position + Vector3.new(dir.X, 0, dir.Z))
		end)

	elseif cmd == "Center face." then
		if _G.TrackingConnection then _G.TrackingConnection:Disconnect() end
		_G.TrackingConnection = nil
		CameraShake()

	elseif FaceTestActive then
		local rot = Commands[cmd]
		if type(rot) == "number" then
			CameraShake()
			TweenService:Create(
				hhrp,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{CFrame = hhrp.CFrame * CFrame.Angles(0, math.rad(rot), 0)}
			):Play()
		end
	end
end)
