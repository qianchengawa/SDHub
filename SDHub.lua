local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local bloon = false
local httpService = game:GetService("HttpService")


function Save(data)
	local fullPath = "SDHub.json"
	local success, encoded = pcall(httpService.JSONEncode, httpService, data)
	if not success then
		return false, "文件导出错误"
	end
	writefile(fullPath, encoded)
	Fluent:Notify({
		Title = "提示",
		Content = "保存成功！",
		SubContent = "", -- Optional
		Duration = 5 -- Set to nil to make the notification not disappear
	})
	return true
end

function Load()
	local file = "SDHub.json"
	if not isfile(file) then return false end

	local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
	if not success then return false end
	return decoded
end
local Window = Fluent:CreateWindow({
	Title = "SD脚本中心" .. " V1.34",
	SubTitle = "by 牢大 游戏id "..game.PlaceId,
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl
})

if game.PlaceId == 14279724900 then --游戏内
	local part = Instance.new("Part")
	pcall(function()
		local data = Load()
		for i,v in pairs(data) do
			if i == "HumanoidCFrame" then
				local cefra = v:split(", ")
				part.CFrame = CFrame.new(unpack(cefra))
				part.Anchored = true
				part.Transparency = 1
				part.CanCollide = false
			end
		end
	end)
	pcall(function()
		local Tabs = {
			Main = Window:AddTab({ Title = "主要功能", Icon = "" }),
		}

		local Options = Fluent.Options
		do	
			Tabs.Main:AddParagraph({
				Title = "SD交流群",
				Content = "529972437\n购买脚本找群内管理[Traxiad]"
			})

			local Dropdown = Tabs.Main:AddDropdown("SLSpeed", {
				Title = "选择倍速",
				Values = {"1","2","3","4","5"},
				Multi = false,
				Default = 1,
			})

			Dropdown:SetValue("1")

			local speed

			Dropdown:OnChanged(function(Value)
				speed = Value
			end)

			local Toggle = Tabs.Main:AddToggle("Speed", {Title = "锁定选择倍速", Default = false })
			Toggle:OnChanged(function()
				task.spawn(function()
					pcall(function()
						if Options.Speed.Value == true then
							game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change"):FireServer(tonumber(speed))
						end 
						game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed").Changed:Connect(function()
							pcall(function()
								if Options.Speed.Value == true and game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed").Value ~= speed then
									game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change"):FireServer(tonumber(speed))
								elseif Options.Speed.Value == false then
									return
								end
							end)
						end)
					end)
				end)
			end)
			
			Options.Speed:SetValue(false)

			Tabs.Main:AddButton({
				Title = "保存摄像机位置",
				Description = "保存一次后再次进入游戏无需保存",
				Callback = function()
					Window:Dialog({
						Title = "保存摄像机位置",
						Content = "确定保存当前摄像机位置吗",
						Buttons = {
							{
								Title = "确定",
								Callback = function()
									game:GetService("Players").LocalPlayer.CameraMinZoomDistance = game:GetService("Players").LocalPlayer.CameraMaxZoomDistance
									game:GetService("Players").LocalPlayer.CameraMinZoomDistance = 1
									part.CFrame = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
									wait(1)
									Save({HumanoidCFrame = tostring(game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame),CameraCFrame = tostring(workspace.CurrentCamera.CFrame)})
								end
							},
							{
								Title = "取消",
								Callback = function()
									print("Cancelled")
								end
							}
						}
					})
				end
			})

			local Toggle = Tabs.Main:AddToggle("Body", {Title = "固定摄像机到保存的位置", Default = false  })
			Toggle:OnChanged(function()
				task.spawn(function()
					workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
						if Options.Body.Value == true then
							pcall(function()
								local data = Load()
								for i,v in pairs(data) do
									if i == "CameraCFrame" then
										local cefra = v:split(", ")
										game:GetService("Players").LocalPlayer.CameraMinZoomDistance = game:GetService("Players").LocalPlayer.CameraMaxZoomDistance
										workspace.CurrentCamera.CameraSubject = part
										workspace.CurrentCamera.CFrame = CFrame.new(unpack(cefra))
									end
								end
							end)
						else
							workspace.CurrentCamera.CameraSubject = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid")
							game:GetService("Players").LocalPlayer.CameraMinZoomDistance = 1
							return
						end
					end)
				end)
			end)
			Options.Body:SetValue(false)
			
			local Toggle = Tabs.Main:AddToggle("WaveSkip", {Title = "自动跳过）", Default = false , Description = "修复游戏内自动跳过失效"})
			Toggle:OnChanged(function()
				task.spawn(function()
					while Options.WaveSkip.Value do
						game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("waveSkip"):FireServer(true)
						wait(.1)
					end
				end)
			end)
			local towers = {}
			local tower
			local function GetTowersData()
				for i,v in ipairs(workspace.Scripted.TowerData:GetChildren()) do
					towers[v.Name] = tostring(v.Name..v:GetAttribute("ID"))
				end
				Options.SLTower.Values:SetValue(towers)
			end
			GetTowersData()
			workspace.Scripted.TowerData.ChildRemoved:Connect(function()
				GetTowersData()
			end)
			workspace.Scripted.TowerData.ChildAdded:Connect(function()
				GetTowersData()
			end)
			local Dropdown = Tabs.Main:AddDropdown("SLTower", {
				Title = "选择塔",
				Values = towers,
				Multi = false,
			})
			Dropdown:OnChanged(function(Value)
				tower = Value
			end)
		end
	end)
elseif game.PlaceId == 14279693118 then --大厅
	pcall(function()
		local Tabs = {
			Main = Window:AddTab({ Title = "主要功能", Icon = "" }),
		}

		local Options = Fluent.Options
		do	
			Tabs.Main:AddParagraph({
				Title = "SD交流群",
				Content = "529972437\n购买脚本找群内管理[Traxiad]\n大厅暂时无功能"
			})
		end
	end)
elseif game.PlaceId == 18711550363 then --交易大厅
	pcall(function()
		local Tabs = {
			Main = Window:AddTab({ Title = "主要功能", Icon = "" }),
		}

		local Options = Fluent.Options
		do	
			Tabs.Main:AddParagraph({
				Title = "SD交流群",
				Content = "529972437\n购买脚本找群内管理[Traxiad]"
			})

			local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "水晶透视", Default = false })
			local vb = false
			Toggle:OnChanged(function()
				vb = Options.MyToggle.Value
				task.spawn(function()
					pcall(function()
						game:GetService("RunService").RenderStepped:Connect(function()
							if vb == true then
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
			end)
			Options.MyToggle:SetValue(false)
		end
	end)
elseif game.PlaceId ~= 18711550363 and game.PlaceId ~= 14279724900 and game.PlaceId ~= 14279693118 then
	local Tabs = {
		Main = Window:AddTab({ Title = "暂不支持该场景/游戏", Icon = "" }),
	}
end
Window:SelectTab(1)

Fluent:Notify({
	Title = "SD脚本中心",
	Content = "脚本加载完毕！",
	Duration = 8
})
