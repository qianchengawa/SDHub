local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local httpService = game:GetService("HttpService")
local units = loadstring(game:HttpGet('https://raw.githubusercontent.com/qianchengawa/SDHub/refs/heads/main/Units.txt'))()
function GetTowersData()
	local towers = {}
	for i=1,#workspace.Scripted.TowerData:GetChildren() , 1 do-- in ipairs(workspace.Scripted.TowerData:GetChildren()) do
		local v = workspace.Scripted.TowerData:GetChildren()[tonumber(i)]
		if v == nil then
			break
		end
		towers[tonumber(i)] = tostring(v.Name.."/"..v:GetAttribute("ID"))
	end
	for i,v in pairs(towers) do
		print(i.." "..v)
	end
	return towers
end
function Save(data)
	local fullPath = "SDHub.json"
	local success, encoded = pcall(httpService.JSONEncode, httpService, data)
	if not success then
		return false
	end
	writefile(fullPath, encoded)
	return true
end

function Load()
	local file = "SDHub.json"
	if not isfile(file) then return false end

	local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
	if not success then return false end
	return decoded
end

local Window = Rayfield:CreateWindow({
	Name = "SDHub V2.21",
	Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
	LoadingTitle = "SDHub",
	LoadingSubtitle = "by 牢大",
	Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
	ConfigurationSaving = {
		Enabled = false,
	},
})

if game.PlaceId == 14279724900 then --游戏内
	local Tab = Window:CreateTab("主要功能", 4483362458)
	local part = Instance.new("Part")
	local speed = 1


	local Section = Tab:CreateSection("倍速")


	local Dropdown = Tab:CreateDropdown({
		Name = "选择倍速",
		Options = {"1","2", "3", "4", "5"},
		CurrentOption = {"1"},
		MultipleOptions = false,
		Callback = function(Options)
			speed = tonumber(unpack(Options))
			print(unpack(Options))
		end,
	})
	local V = false
	local Toggle = Tab:CreateToggle({
		Name = "锁定倍速",
		CurrentValue = false,
		Callback = function(Value)
			V = Value
			pcall(function()
				while V do
					repeat wait() until game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed").Value ~= speed
					game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change"):FireServer(tonumber(speed))
				end
			end)
		end,
	})


	local Section = Tab:CreateSection("视角")


	local Button = Tab:CreateButton({
		Name = "保存当前视角位置",
		Callback = function()
			game:GetService("Players").LocalPlayer.CameraMinZoomDistance = game:GetService("Players").LocalPlayer.CameraMaxZoomDistance
			part.CFrame = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
			wait(1)
			game:GetService("Players").LocalPlayer.CameraMinZoomDistance = 0.5
			Save({HumanoidCFrame = tostring(game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame),CameraCFrame = tostring(workspace.CurrentCamera.CFrame)})
		end,
	})
	local V1 = false
	local Toggle = Tab:CreateToggle({
		Name = "锁定视角到保存位置",
		CurrentValue = false,
		Callback = function(Value)
			V1 = Value
			local cc
			local hc
			pcall(function()
				local data = Load()
				for i,v in pairs(data) do
					if i == "CameraCFrame" then
						local cefra = v:split(", ")
						cc = CFrame.new(unpack(cefra))
					elseif i == "HumanoidCFrame" then
						local cefra = v:split(", ")
						hc = CFrame.new(unpack(cefra))
					end
				end
			end)
			workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
				if V1 == true then
					game:GetService("Players").LocalPlayer.CameraMinZoomDistance = game:GetService("Players").LocalPlayer.CameraMaxZoomDistance
					workspace.CurrentCamera.CameraSubject = part
					workspace.CurrentCamera.CFrame = cc
					part.CFrame = hc
					part.Anchored = true
					part.Transparency = 1
					part.CanCollide = false
				else
					workspace.CurrentCamera.CameraSubject = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid")
					game:GetService("Players").LocalPlayer.CameraMinZoomDistance = 0.5
					return
				end
			end)

		end
	})


	local Section = Tab:CreateSection("辅助")


	local V2 = false
	local Toggle = Tab:CreateToggle({
		Name = "自动跳过",
		CurrentValue = false,
		Flag = "WavwSkip", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			V2 = Value
			task.spawn(function()
				while V2 do
					game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("waveSkip"):FireServer(true)
					wait(.1)
				end
			end)
		end,
	})










	local Tab = Window:CreateTab("娱乐功能", "audio-lines")

	local Section = Tab:CreateSection("塔(仅自己可见)")

	local atowers = GetTowersData()

	local TowerData
	local ClockNope = Instance.new("BoolValue")
	local Dropdown = Tab:CreateDropdown({
		Name = "选择塔",
		Options = atowers,
		MultipleOptions = false,
		Flag = "SLTower", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Options)
			local Tower = unpack(Options)
			TowerData = workspace.Scripted.TowerData[tostring(string.sub(Tower,0,string.find(Tower,"/") - 1))]
			ClockNope.Value = TowerData:GetAttribute("ClockNope")
		end,
	})

	workspace.Scripted.TowerData.ChildRemoved:Connect(function()
		Dropdown:Refresh(GetTowersData())
	end)
	workspace.Scripted.TowerData.ChildAdded:Connect(function()
		Dropdown:Refresh(GetTowersData())
	end)

	local Dropdown = Tab:CreateDropdown({
		Name = "伪装品质",
		Options = {"钻石","诅咒","黄金","普通"},
		MultipleOptions = false,
		Flag = "SLSkin", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Options)
			local pz = unpack(Options)
			if pz == "钻石" then
				TowerData:SetAttribute("ShardType","Diamond")
			elseif pz == "诅咒" then
				TowerData:SetAttribute("ShardType","Cursed")
			elseif pz == "黄金" then
				TowerData:SetAttribute("ShardType","Golden")
			elseif pz == "普通" then
				TowerData:SetAttribute("ShardType",nil)
			end
		end,
	})

	local buff

	local Dropdown = Tab:CreateDropdown({
		Name = "选择buff",
		Options = {"伤害","攻速","范围","减费","收入","未知"},
		MultipleOptions = false,
		Flag = "SLSkin", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Options)
			local pz = unpack(Options)
			if not TowerData.Boosters:FindFirstChild("Special") then
				local sp = Instance.new("NumberValue",TowerData.Boosters)
				sp.Name = "Special"
				local dm = Instance.new("NumberValue",sp)
				dm.Name = "DMG"
				local spa = Instance.new("IntValue",sp)
				spa.Name = "SPA"
				local rng = Instance.new("IntValue",sp)
				rng.Name = "RNG"
				local cos = Instance.new("IntValue",sp)
				cos.Name = "COST"
				local cas = Instance.new("IntValue",sp)
				cas.Name = "CASH"
				local hd = Instance.new("IntValue",sp)
				hd.Name = "HD"
			end
			if pz == "伤害" then
				buff = TowerData.Boosters.Special.DMG
			elseif pz == "攻速" then
				buff = TowerData.Boosters.Special.SPA
			elseif pz == "范围" then
				buff = TowerData.Boosters.Special.RNG
			elseif pz == "减费" then
				buff = TowerData.Boosters.Special.COST
			elseif pz == "收入" then
				buff = TowerData.Boosters.Special.CASH
			elseif pz == "未知" then
				buff = TowerData.Boosters.Special.HD
			end
		end,
	})

	local Input = Tab:CreateInput({
		Name = "编辑buff数值",
		CurrentValue = "",
		PlaceholderText = "输入数字",
		RemoveTextAfterFocusLost = false,
		Flag = "Input1",
		Callback = function(Text)
			if buff then
				buff.Value = tonumber(Text)
			end
		end,
	})

	local Toggle = Tab:CreateToggle({
		Name = "不能被时钟加成",
		CurrentValue = false,
		Flag = "Toggle1",
		Callback = function(Value)
			TowerData:SetAttribute("ClockNope",Value)
		end,
	})

	ClockNope.Changed:Connect(function()
		Toggle:Set(ClockNope.Value)
	end)

	local Input = Tab:CreateInput({
		Name = "编辑售卖价格",
		CurrentValue = "",
		PlaceholderText = "输入数字",
		RemoveTextAfterFocusLost = false,
		Flag = "Input2",
		Callback = function(Text)
			TowerData:SetAttribute("SellPrice",tonumber(Text))
		end,
	})

	local Input = Tab:CreateInput({
		Name = "编辑攻击模式文本",
		CurrentValue = "",
		PlaceholderText = "输入文本",
		RemoveTextAfterFocusLost = false,
		Flag = "Input2",
		Callback = function(Text)
			TowerData:SetAttribute("TargetMode",Text)
		end,
	})
elseif game.PlaceId == 14279693118 then --大厅
	local stype
	local Tab = Window:CreateTab("娱乐功能", "audio-lines")
	local Section = Tab:CreateSection("更改抽奖池子（自己可见）")
	local Dropdown = Tab:CreateDropdown({
		Name = "选择品质",
		Options = {"普通","罕见","稀有","史诗","传奇","神话","神圣"},
		MultipleOptions = false,
		Flag = "Dropdown1",
		Callback = function(Options)
			local t = unpack(Options)
			if t == "普通" then
				stype = "Common"
			elseif t == "罕见" then
				stype = "Uncommon"
			elseif t == "稀有" then
				stype = "Rare"
			elseif t == "史诗" then
				stype = "Epic"
			elseif t == "传奇" then
				stype = "Legendary"
			elseif t == "神话" then
				stype = "Mythical"
			elseif t == "神圣" then
				stype = "Godly"
			end
		end,
	})
	local Dropdown = Tab:CreateDropdown({
		Name = "更改为",
		Options = units,
		MultipleOptions = false,
		Flag = "Dropdown1",
		Callback = function(Options)
			if stype then
				game:GetService("ReplicatedStorage"):SetAttribute(stype,unpack(Options))
			end
		end,
	})
	local Section = Tab:CreateSection("全球经验（自己可见）")

	local Input = Tab:CreateInput({
		Name = "更改全球经验",
		CurrentValue = game:GetService("ReplicatedStorage"):GetAttribute("BattlepassGlobalXP"),
		PlaceholderText = "输入数字",
		RemoveTextAfterFocusLost = false,
		Flag = "Input1",
		Callback = function(Text)
			game:GetService("ReplicatedStorage"):SetAttribute("BattlepassGlobalXP",tonumber(Text))
		end,
	})
elseif game.PlaceId == 18711550363 then --交易大厅
	local cvl = Instance.new("NumberValue")
	local Tab = Window:CreateTab("主要功能", 4483362458)
	local Section = Tab:CreateSection("透视")
	local V = false
	local Toggle = Tab:CreateToggle({
		Name = "水晶透视",
		CurrentValue = false,
		Flag = "Toggle1",
		Callback = function(Value)
			V = Value
			task.spawn(function()
				pcall(function()
					game:GetService("RunService").RenderStepped:Connect(function()
						if V == true then
							for i,v in pairs (game:GetService("Workspace"):GetChildren()) do
								if v.Name == "Crystal" and v:GetAttribute("P") ~= true then
									pcall(function()
										v:SetAttribute("P",true)
										local hl = Instance.new("Highlight")
										hl.FillColor = v.Color
										hl.FillTransparency = 0
										hl.OutlineTransparency = 0.5
										hl.Parent = v
										local ui = Instance.new("BillboardGui")
										ui.AlwaysOnTop = true
										ui.Size = UDim2.new(0,100,0,50)
										ui.StudsOffset = Vector3.new(0,5,0)
										local text = Instance.new("TextLabel")
										text.Text = "Crystal"
										text.Size = UDim2.new(1,0,1,0)
										text.BackgroundTransparency = 1
										text.TextColor3 = v.Color
										text.Font = Enum.Font.SourceSansBold
										text.TextScaled = true
										text.Parent = ui
										ui.Parent = v
										ui.Adornee = v
									end)
								end
							end
						else
							for i,v in pairs (game:GetService("Workspace"):GetChildren()) do
								if v.Name == "Crystal" and v:GetAttribute("P") == true then
									pcall(function()
										v:FindFirstChild("BillboardGui"):Destroy()
										v:FindFirstChild("Highlight"):Destroy()
										v:SetAttribute("P",false)
									end)
								end
							end
							return
						end
					end)
				end)
			end)
		end,
	})


	local Section = Tab:CreateSection("实用")


	local ui = Instance.new("BillboardGui")
	ui.AlwaysOnTop = true
	ui.Size = UDim2.new(4,0,2,0)
	ui.ExtentsOffsetWorldSpace = Vector3.new(0,5,0)
	ui.MaxDistance = 32
	local text = Instance.new("TextLabel")
	text.TextStrokeColor3 = Color3.new(0, 0, 0)
	text.TextStrokeTransparency = 0
	text.Size = UDim2.new(1,0,0.5,0)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.SourceSansBold
	text.TextScaled = true
	local V2 = false
	local Toggle = Tab:CreateToggle({
		Name = "显示玩家状态",
		CurrentValue = false,
		Flag = "Toggle1",
		Callback = function(Value)
			V2 = Value
			game:GetService("RunService").RenderStepped:Connect(function()
				if V2 == true then
					for i,v in ipairs (game:GetService("Players"):GetPlayers()) do
						if v:GetAttribute("P") ~= true then
							pcall(function()
								local cui = ui:Clone()
								local Character = v.Character or v.CharacterAdded:Wait()
								cui.Parent = Character:FindFirstChild("HumanoidRootPart")
								local value = text:Clone()
								value.Position = UDim2.new(0,0,0,0)
								value.Parent = cui
								value.Text = tostring("仓库总价值"..string.sub(Character.HumanoidRootPart.Value.TextLabel.Text,string.find(Character.HumanoidRootPart.Value.TextLabel.Text,":")+1,-1))
								Character.HumanoidRootPart.Value.TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
									value.Text = tostring("仓库总价值"..string.sub(Character.HumanoidRootPart.Value.TextLabel.Text,string.find(Character.HumanoidRootPart.Value.TextLabel.Text,":")+1,-1))
								end)
								Character.HumanoidRootPart.ChildRemoved:Connect(function(valuet)
									if valuet.Name == "Value" then
										Character.HumanoidRootPart.ChildAdded:Connect(function(valuea)
											if valuea.Name == "Value" then
												value.Text = tostring("仓库总价值"..string.sub(valuea.TextLabel.Text,string.find(valuea.TextLabel.Text,":")+1,-1))
											end
										end)
									end
								end)
								value.TextColor3 = Character.HumanoidRootPart.Value.TextLabel.TextColor3
								local trading = text:Clone()
								text.Position = UDim2.new(0,0,0.5,0)
								trading.Parent = cui
								if v:GetAttribute("Trading") then
									trading.Text = tostring("交易状态: 正在与'"..v:GetAttribute("Trading").."'交易")
									trading.TextColor3 = Color3.fromRGB(217, 0, 255)
								else
									trading.Text = "交易状态: 空闲"
									trading.TextColor3 = Color3.fromRGB(143, 255, 51)
								end
								v:GetAttributeChangedSignal("Trading"):Connect(function()
									if v:GetAttribute("Trading") then
										trading.Text = tostring("交易状态: 正在与'"..v:GetAttribute("Trading").."'交易")
										trading.TextColor3 = Color3.fromRGB(217, 0, 255)
									else
										trading.Text = "交易状态: 空闲"
										trading.TextColor3 = Color3.fromRGB(143, 255, 51)
									end
								end)
								v:SetAttribute("P",true)
							end)
						end
					end
				else
					for i,v in ipairs (game:GetService("Players"):GetPlayers()) do
						if v:GetAttribute("P") == true then
							pcall(function()
								v.Character.HumanoidRootPart:FindFirstChild("BillboardGui"):Destroy()
								v:SetAttribute("P",false)
							end)
						end
					end
					return
				end
			end)
		end,
	})







	local Tab = Window:CreateTab("娱乐功能", "audio-lines")




	local Section = Tab:CreateSection("更改价格(仅自己可见)")
	local Values = game:GetService("ReplicatedStorage"):GetAttributes()
	local Attr = {}
	local count = 1
	local SLAttr
	for i,v in pairs(Values) do
		Attr[tonumber(count)] = i
		count += 1
	end
	local Dropdown = Tab:CreateDropdown({
		Name = "选择属性",
		Options = Attr,
		MultipleOptions = false,
		Flag = "Dropdown1",
		Callback = function(Options)
			SLAttr = unpack(Options)
			cvl.Value = game:GetService("ReplicatedStorage"):GetAttribute(SLAttr)
		end,
	})

	local Input = Tab:CreateInput({
		Name = "更改价值",
		CurrentValue = "",
		PlaceholderText = "输入数字",
		RemoveTextAfterFocusLost = false,
		Flag = "Input1",
		Callback = function(Text)
			if typeof(tonumber(Text)) == "number" then
				game:GetService("ReplicatedStorage"):SetAttribute(SLAttr,tonumber(Text))
			end
		end,
	})

	cvl.Changed:Connect(function()
		Input:Set(cvl.Value)
	end)
end
