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
-- ⚙️ 서비스 로드
-----------------------------------------------------
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
_G.FaceGui = Rayfield

-----------------------------------------------------
-- 🪪 GUI 구성
-----------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "Host Menu",
	LoadingTitle = "Face Test System"
})
local Tab = Window:CreateTab("Control")

local TargetPlayer
local FaceTestActive = false
_G.TraineeCount = 1 -- 기본 인원수

-- 상태 표시
local StatusParagraph = Tab:CreateParagraph({
	Title = "Face Test 상태",
	Content = "❌ 비활성 상태"
})

local function UpdateStatus(active)
	StatusParagraph:Set({
		Title = "Face Test 상태",
		Content = active
			and "<font color='rgb(0,255,0)'>✅ 활성 상태</font>"
			or "<font color='rgb(255,0,0)'>❌ 비활성 상태</font>"
	})
end

-----------------------------------------------------
-- 👥 인원 수 입력 (복수형 판정용)
-----------------------------------------------------
Tab:CreateInput({
	Name = "인원 수 입력",
	PlaceholderText = "예: 1 또는 3",
	RemoveTextAfterFocusLost = false,
	Callback = function(num)
		local n = tonumber(num)
		if n and n > 0 then
			_G.TraineeCount = math.floor(n)
			Rayfield:Notify({
				Title = "👥 인원 수 설정됨",
				Content = string.format("%d명 기준으로 명령 해석됩니다.", _G.TraineeCount),
				Duration = 3
			})
		else
			Rayfield:Notify({
				Title = "⚠️ 잘못된 입력",
				Content = "인원 수는 1 이상의 숫자여야 합니다.",
				Duration = 3
			})
		end
	end
})

-----------------------------------------------------
-- 🧩 Tester 입력
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
				Content = "(" .. name .. ")",
				Duration = 3
			})
		else
			Rayfield:Notify({
				Title = "❌ Tester 찾을 수 없음",
				Content = "입력한 이름: " .. name,
				Duration = 3
			})
		end
	end
})

-----------------------------------------------------
-- 🧭 Face Test 제식 명령
-----------------------------------------------------
local Commands = {
	["Right face."] = -90, ["Left face."] = 90,
	["Right incline."] = -45, ["Left incline."] = 45,
	["About face."] = 180, ["Control face."] = "control",
	["Center face."] = "center", ["Face Test Start."] = "start",
	["Face Test End."] = "end"
}

-----------------------------------------------------
-- 🪖 훈련 + 사격 명령
-----------------------------------------------------
local TrainingSet = {
	["SF L on me."] = true, ["Prepare,"] = true, ["Forward,"] = true, ["Quick,"] = true,
	["March!"] = true, ["Remarch!"] = true, ["Gas Prepare,"] = true, ["Gas! Gas! Gas!"] = true,
	["Singing."] = true, ["Gas End."] = true, ["Ready,"] = true, ["Set,"] = true,
	["Begin!"] = true, ["Advance!"] = true, ["Go up."] = true, ["Down,"] = true,
	["Jump!"] = true, ["Halt."] = true, ["Fire!"] = true, ["Cease fire."] = true,
	["Stand."] = true, ["Crouch."] = true, ["Prone."] = true
}

-----------------------------------------------------
-- 💬 채팅 감지
-----------------------------------------------------
_G.FaceChatConnection = TextChatService.MessageReceived:Connect(function(m)
	if not _G.FaceSystemRunning or not m.TextSource then return end
	local p = game.Players:GetPlayerByUserId(m.TextSource.UserId)
	if p ~= TargetPlayer then return end
	local t = m.Text:gsub("^[-;]", "")
	_G.FaceEvent:Fire(t)
end)

-----------------------------------------------------
-- 🎮 명령 처리
-----------------------------------------------------
_G.FaceEvent.Event:Connect(function(cmd)
	local host = game.Players.LocalPlayer
	local hhrp = host.Character and host.Character:FindFirstChild("HumanoidRootPart")
	if not hhrp then return end

	local function CameraShake()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local base = cam.CFrame
		for _ = 1, 2 do
			cam.CFrame = base * CFrame.new(math.random(-1,1)*0.1, math.random(-1,1)*0.1, 0)
			task.wait(0.02)
		end
		cam.CFrame = base
	end

	-- ⚔️ Face Test 제식 처리
	if Commands[cmd] then
		if cmd == "Face Test Start." then
			FaceTestActive = true
			UpdateStatus(true)
			CameraShake()
			Rayfield:Notify({ Title = "⚔️ Face Test 시작", Content = "제식 명령 활성화됨.", Duration = 3 })

		elseif cmd == "Face Test End." then
			FaceTestActive = false
			UpdateStatus(false)
			CameraShake()
			if _G.TrackingConnection then _G.TrackingConnection:Disconnect() end
			_G.TrackingConnection = nil
			Rayfield:Notify({ Title = "🪖 Face Test 종료", Content = "제식 명령 비활성화됨.", Duration = 3 })

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

		elseif FaceTestActive and type(Commands[cmd]) == "number" then
			CameraShake()
			TweenService:Create(
				hhrp,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = hhrp.CFrame * CFrame.Angles(0, math.rad(Commands[cmd]), 0) }
			):Play()
		end
		return
	end

	-- 🪖 일반 훈련/사격/STS 명령 처리
	if not FaceTestActive then
		local isGunCmd = string.match(cmd, "^Hold the%s+[%w%s]*gun?s?%.$")
			or string.match(cmd, "^Down%s+[%w%s]*gun?s?%.$")
		local isBulletCmd = string.match(cmd, "^Prepare,%s*[%d]+%s*Bullet?s?%.$")
		local isSTS = string.match(cmd, "^STS on the%s+[%a]+%s+pad?s?%.$")
			or string.match(cmd, "^STS on the%s+[%a]+%s+line?s?%.$")

		-- 복수형 검사
		local function checkPlural(word)
			local plural = string.sub(word or "", -1) == "s"
			local count = _G.TraineeCount or 1
			return (count > 1 and plural) or (count == 1 and not plural)
		end

		local pluralOk = true
		local lower = cmd:lower()
		if string.find(lower, "gun") then
			pluralOk = checkPlural(cmd:match("gun[s]?"))
		elseif string.find(lower, "bullet") then
			pluralOk = checkPlural(cmd:match("bullet[s]?"))
		elseif string.find(lower, "pad") then
			pluralOk = checkPlural(cmd:match("pad[s]?"))
		elseif string.find(lower, "line") then
			pluralOk = checkPlural(cmd:match("line[s]?"))
		end

		-- 최종 알람
		if TrainingSet[cmd] or isGunCmd or isBulletCmd or isSTS then
			Rayfield:Notify({
				Title = "🪖 명령 인식됨",
				Content = cmd .. (pluralOk and "" or " (Fake)"),
				Duration = 3
			})
		end
	end
end)
