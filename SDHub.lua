local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local bloon = false
local httpService = game:GetService("HttpService")
function Save(name,data)
	if (not name) then
		return false
	end
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

function Load(name)
	if (not name) then
		return false
	end
	local file = "SDHub.json"
	if not isfile(file) then return false end

	local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
	if not success then return false end
	return true,decoded
end
local Window = Fluent:CreateWindow({
	Title = "SD脚本中心" .. " V1.1",
	SubTitle = "by 牢大 游戏id "..game.PlaceId,
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl
})

if game.PlaceId == 14279724900 then --游戏内
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

			local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
				Title = "锁定倍速",
				Values = {"1","2","3","4","5"},
				Multi = false,
				Default = 1,
			})

			Dropdown:SetValue("1")

			local speed = 1

			Dropdown:OnChanged(function(Value)
				speed = Value
				game:GetService("RunService").RenderStepped:Connect(function()
					game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change"):FireServer(tonumber(speed))
					if speed ~= Value then
						return
					end
				end)	
			end)

			Tabs.Main:AddButton({
				Title = "设定身体位置",
				Description = "设定一次后再次进入游戏无需再次设定",
				Callback = function()
					Window:Dialog({
						Title = "设定身体位置",
						Content = "确定设定身体为当前位置吗",
						Buttons = {
							{
								Title = "确定",
								Callback = function()
									Save("Humanoid",{HumanoidCFrame = tostring(game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame),CameraCFrame = tostring(workspace.CurrentCamera.CFrame)})
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

			local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "固定身体到设定位置", Default = false })
			local vb = false
			Toggle:OnChanged(function()
				vb = Options.MyToggle.Value
				task.spawn(function()
					while true do
						pcall(function()
							local bloon,data = Load("Humanoid")
							for i,v in pairs(data) do
								if i == "HumanoidCFrame" then
									local cefra = v:split(", ")
									game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(unpack(cefra))
									game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Anchored = true
									for i,p in ipairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
										if p:IsA("BasePart") then
											p.CanCollide = false
											p.Transparency = 1
										end
									end
								elseif i == "CameraCFrame" then
									local cefra = v:split(", ")
									workspace.CurrentCamera.CFrame = CFrame.new(unpack(cefra))
								end
							end
						end)
						if vb == false then
							pcall(function()
								game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Anchored = false
							end)
							for i,p in ipairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
								if p:IsA("BasePart") then
									p.CanCollide = true
									p.Transparency = 0
								end
							end
							break
						end
						wait()
					end
				end)
			end)
			Options.MyToggle:SetValue(false)
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
										v:SetAttribute("P",true)
										local hl = Instance.new("Highlight")
										hl.FillColor = v.Color
										hl.FillTransparency = 0
										hl.OutlineTransparency = 0.5
										hl.Parent = v
										local ui = Instance.new("BillboardGui")
										ui.AlwaysOnTop = true
										ui.Size = UDim2.new(0,100,0,50)
										local text = Instance.new("TextLabel")
										text.Text = "{Crystal}"
										text.Size = UDim2.new(1,0,1,0)
										text.BackgroundTransparency = 1
										text.TextColor3 = v.Color
										text.Font = Enum.Font.SourceSansBold
										text.TextScaled = true
										text.Parent = ui
										ui.Parent = v
										ui.Adornee = v
										v.CanCollide = false
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

