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
	Title = "SD脚本中心" .. " V1.0",
	SubTitle = "by 牢大",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({ Title = "主要功能", Icon = "" }),
}

local Options = Fluent.Options
do
	Tabs.Main:AddParagraph({
		Title = "SD交流群",
		Content = "529972437\n购买脚本找群内管理[Traxiad]"
	})


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

Window:SelectTab(1)

Fluent:Notify({
	Title = "SD脚本中心",
	Content = "脚本加载完毕！",
	Duration = 8
})
