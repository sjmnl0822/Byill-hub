local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()



local Window = Rayfield:CreateWindow({

   Name = "빌리 허브",

   LoadingTitle = "빌리 허브",

   LoadingSubtitle = "by 빌리",

   ConfigurationSaving = {

      Enabled = false,

      FolderName = nil,

      FileName = "Example Hub"

   },

   Discord = {

      Enabled = false,

      Invite = "noinvitelink",

      RememberJoins = true

   }

})



local FirstTab = Window:CreateTab("군대게임", nil)

local FirstSection = FirstTab:CreateSection("군대게임 전용")



local targetPlayerName = "" -- Variable to store the target player name

local activeConnections = {} -- To store active player chat connections



local Input = FirstTab:CreateInput({

   Name = "호스트",

   PlaceholderText = "호스트 닉네임",

   RemoveTextAfterFocusLost = true,

   Callback = function(Text)

       -- Disconnect existing connections

       for _, conn in pairs(activeConnections) do

           conn:Disconnect()

       end

       activeConnections = {}



       targetPlayerName = Text

       print("Target player set to: " .. targetPlayerName)



       local function rotateCharacter(angle)

           local character = game.Players.LocalPlayer.Character -- Always use LocalPlayer's character

           if character and character:FindFirstChild("HumanoidRootPart") then

               local rootPart = character.HumanoidRootPart

               rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(angle), 0) -- Rotate left if angle is positive, right if negative

           end

       end



       local function mimicAndPrint(message)

           local chatService = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")

           chatService:FireServer(message, "System") -- Mimic chat with System channel



           if not _G.lastPrintedMessage or _G.lastPrintedMessage ~= message then

               print(message) -- Print the message

               _G.lastPrintedMessage = message



               if message == "Right face." then

                   rotateCharacter(-90) -- Rotate 90 degrees to the right

               elseif message == "Left face." then

                   rotateCharacter(90) -- Rotate 90 degrees to the left

               elseif message == "About face." then

                   rotateCharacter(180) -- Rotate 180 degrees to the right

               elseif message == "Right incline." then

                   rotateCharacter(-45) -- Rotate 45 degrees to the right

               elseif message == "Left incline." then

                   rotateCharacter(45) -- Rotate 45 degrees to the left

               end

           end

       end



       local function onPlayerChatted(player)

           local connection = player.Chatted:Connect(function(message)

               local trimmedMessage = message:gsub("%s+$", "") -- Trim trailing whitespace

               if player.Name == targetPlayerName then

                   mimicAndPrint(trimmedMessage)

               end

           end)



           table.insert(activeConnections, connection) -- Store connection

       end



       local Players = game:GetService("Players")



       for _, player in ipairs(Players:GetPlayers()) do

           onPlayerChatted(player)

       end



       Players.PlayerAdded:Connect(onPlayerChatted)

   end,

})



local Button = FirstTab:CreateButton({

   Name = "페이스 테스트 스크립트 실행",

   Callback = function()

       print("페이스 테스트 스크립트 실행 완료, 호스트 닉네임 : " .. (targetPlayerName ~= "" and targetPlayerName or "None"))

   end,

})



local SecondTab = Window:CreateTab("모든 게임", nil)

local SecondSection = SecondTab:CreateSection("주로 사용하는 것")



SecondTab:CreateButton({

   Name = "Inf Jump",

   Callback = function()

       game:GetService("UserInputService").JumpRequest:Connect(function()

           game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")

       end)

       print("Inf Jump Activated!")

   end,

})



SecondTab:CreateButton({

   Name = "God Mode",

   Callback = function()

       loadstring(game:HttpGet("https://raw.githubusercontent.com/zephyr10101/ignore-touchinterests/main/main", true))()

       print("God Mode Activated!")

   end,

})



SecondTab:CreateButton({

   Name = "NoClip",

   Callback = function()

       loadstring(game:HttpGet("https://raw.githubusercontent.com/MaksBloxX/NoClipScript/main/NoClip%20Roblox", true))()

       print("NoClip Activated!")

   end,

})



-- 세 번째 탭 추가

local ThirdTab = Window:CreateTab("속도 및 점프 설정", nil)

local ThirdSection = ThirdTab:CreateSection("속도 및 점프 조정")



-- 기본값 변수

local inputSpeed = 16 -- 기본 WalkSpeed

local inputJumpPower = 50 -- 기본 JumpPower



-- 속도 입력 필드

ThirdTab:CreateInput({

    Name = "속도 입력",

    PlaceholderText = "예: 50",

    RemoveTextAfterFocusLost = false,

    Callback = function(Text)

        local number = tonumber(Text) -- 입력 값을 숫자로 변환

        if number and number >= 16 and number <= 100 then

            inputSpeed = number

            print("입력된 속도: " .. inputSpeed)

        else

            print("유효하지 않은 속도입니다. (16~100 사이로 입력하세요)")

        end

    end,

})



-- 속도 설정 실행 버튼

ThirdTab:CreateButton({

    Name = "속도 설정 실행",

    Callback = function()

        local character = game.Players.LocalPlayer.Character

        if character and character:FindFirstChild("Humanoid") then

            character.Humanoid.WalkSpeed = inputSpeed

            print("WalkSpeed 설정됨: " .. inputSpeed)

        else

            print("캐릭터가 로드되지 않았습니다.")

        end

    end,

})



-- 점프력 입력 필드

ThirdTab:CreateInput({

    Name = "점프력 입력",

    PlaceholderText = "예: 100",

    RemoveTextAfterFocusLost = false,

    Callback = function(Text)

        local number = tonumber(Text) -- 입력 값을 숫자로 변환

        if number and number >= 50 and number <= 200 then

            inputJumpPower = number

            print("입력된 점프력: " .. inputJumpPower)

        else

            print("유효하지 않은 점프력입니다. (50~200 사이로 입력하세요)")

        end

    end,

})



-- 점프력 설정 실행 버튼

ThirdTab:CreateButton({

    Name = "점프력 설정 실행",

    Callback = function()

        local character = game.Players.LocalPlayer.Character

        if character and character:FindFirstChild("Humanoid") then

            character.Humanoid.JumpPower = inputJumpPower

            print("JumpPower 설정됨: " .. inputJumpPower)

        else

            print("캐릭터가 로드되지 않았습니다.")

        end

    end,

})
