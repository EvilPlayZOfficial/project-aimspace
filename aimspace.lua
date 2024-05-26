local repo = 'https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/main/1%20Tokyo%20Lib%20(FIXED)/Tokyo%20Lib%20Source.lua'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
	Title = 'project aimspace by @evilplayz_main and @eth.cpp',
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 1
})

--// Defined

local Camera = workspace.CurrentCamera
local Players = workspace.Players
local Ignore = workspace.Ignore
local Blatant = Ignore.Blatant

--// Roblox

local Vector3New = Vector3.new

--// Services

local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

--// Tables

local Tabs = {
	Maintab = Window:AddTab('Main'),
	ESPtab = Window:AddTab('ESP'),
	Blatanttab = Window:AddTab('Blatant'),
	Settings = Window:AddTab('Settings'),
}

local Sections = {

	--// Main Tab

	Aimbot = Tabs.Maintab:AddLeftGroupbox('Aimbot'),
	AimbotSettings = Tabs.Maintab:AddRightGroupbox('Aimbot Settings'),

	--// ESP Tab

	ESP = Tabs.ESPtab:AddLeftGroupbox('ESP'),
	ESPsettings = Tabs.ESPtab:AddRightGroupbox('Configuration'),

	Grenade = Tabs.ESPtab:AddLeftGroupbox('Grenades'),
	Lighting = Tabs.ESPtab:AddRightGroupbox('Lighting'),
	Blatant = Tabs.Blatanttab:AddLeftGroupbox('Blatant'),
	Player = Tabs.Blatanttab:AddLeftGroupbox('Player'),
}

local FeatureTable = {
	Combat = {
		SilentAim = {Enabled = false, Hitchance = 100, DummyRange = 0, DynamicFOV = false},
		WallCheck = false,
		TeamCheck = false,
		Hitpart = 7, --// 6 = Torso, 7 = Head
	},
	ESP = {

		--// Features \\--

		Box = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)},
		Tracers = {Enabled = false, Color = Color3.fromRGB(255, 255, 255), Origin = "Middle"},
		Chams = {Enabled = false, FillColor = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(255, 255, 255), VisibleOnly = false, FillTransparency = 0, OutlineTransparency = 0},

		TeamCheck = false,
		UseTeamColor = false, --// Team colors dont apply to chams btw

		--// Other \\--

		Lighting = {
			OverrideAmbient = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)},
		},

		Grenade = {
			GrenadeESP = {Enabled = false, Color = Color3.fromRGB(255, 255, 255), Transparency = 0},
			TrailModifier = {Enabled = false, Color = Color3.fromRGB(255, 255, 255), TrailLifetime = 0.55},
		}

	},
	Blatant = {
		Player = {
			Fly = {Enabled = false, Speed = 0},
			Bhop = false,
			JumpPowerModifier = {Enabled = false, Power = 50},
			HipHeight = 0,
		}
	},
}

local Storage = {
	Index = {
		Head = 7,
		Torso = 6,
	},
	ESP = {
		Boxes = {},
		Tracers = {},
		Chams = {},
	},
	Other = {
		ViewportSize = Camera.ViewportSize,
		ClosestPlayer = nil,
	},
}

local Functions = {
	Normal = {},
	ESP = {},
}

--// Objects

local FOVCircle = Drawing.new("Circle")
do --// Drawing object properties

	do --// Circle

		FOVCircle.Transparency = 1
		FOVCircle.Visible = false
		FOVCircle.Color = Color3.fromRGB(255, 255, 255)
		FOVCircle.Radius = 0

	end

end

--// Rest

do --// Main

	do --// Elements

		do --// Aimbot Tab

			Sections.Aimbot:AddToggle('SilentAim', {
				Text = 'Silent Aim',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Combat.SilentAim.Enabled = Value
				end
			})

			Sections.Aimbot:AddToggle('VisualiseRange', {
				Text = 'Visualise Range',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FOVCircle.Visible = Value
				end
			}):AddColorPicker('VisualiseRangeColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Range Color',
				Transparency = 0,

				Callback = function(Value)
					FOVCircle.Color = Value
				end
			})

			Sections.Aimbot:AddToggle('DynamicRange', {
				Text = 'Dynamic Range',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Combat.SilentAim.DynamicFOV = Value
				end
			})
			Sections.Aimbot:AddSlider('AimbotRange', {
				Text = 'Range',
				Default = 0,
				Min = 0,
				Max = 1000,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.Combat.SilentAim.DummyRange = Value --// im not gonna use flags, but feel free to switch to it :D
				end
			})

			Sections.Aimbot:AddDropdown('Aimpart', {
				Values = { 'Head', 'Torso', 'Random' },
				Default = 1,
				Multi = false,

				Text = 'Aim Part',
				Tooltip = nil,

				Callback = function(Value)
					if Storage.Index[Value] ~= nil then
						FeatureTable.Combat.Hitpart = Storage.Index[Value]
					else
						FeatureTable.Combat.Hitpart = "Random"
					end
				end
			})

			--// Aimbot Settings

			Sections.AimbotSettings:AddToggle('WallCheck', {
				Text = 'Wall Check',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Combat.WallCheck = Value
				end
			})

			Sections.AimbotSettings:AddToggle('TeamCheck', {
				Text = 'Team Check',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Combat.TeamCheck = Value
				end
			})

			Sections.AimbotSettings:AddSlider('Hitchance', {
				Text = 'Hitchance',
				Default = 100,
				Min = 0,
				Max = 100,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.Combat.SilentAim.Hitchance = Value
				end
			})

		end

		do --// ESP Tab

			Sections.ESP:AddToggle('Box', {
				Text = 'Box',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Box.Enabled = Value
				end
			}):AddColorPicker('BoxColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Box Color',
				Transparency = 0,

				Callback = function(Value)
					FeatureTable.ESP.Box.Color = Value
				end
			})

			Sections.ESP:AddToggle('Tracers', {
				Text = 'Tracers',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Tracers.Enabled = Value
				end
			}):AddColorPicker('TracerColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Tracer Color',
				Transparency = 0,

				Callback = function(Value)
					FeatureTable.ESP.Tracers.Color = Value
				end
			})

			Sections.ESP:AddToggle('Chams', {
				Text = 'Chams',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Chams.Enabled = Value
				end
			}):AddColorPicker('FillColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Fill Color',
				Transparency = 0,

				Callback = function(Value)
					FeatureTable.ESP.Chams.FillColor = Value
				end
			}):AddColorPicker('OutlineColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Outline Color',
				Transparency = 0,

				Callback = function(Value)
					FeatureTable.ESP.Chams.OutlineColor = Value
				end
			})

			--// Settings

			Sections.ESPsettings:AddToggle('ChamsVisOnly', {
				Text = 'Chams Visible Only',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Chams.VisibleOnly = Value
				end
			})

			Sections.ESPsettings:AddToggle('TeamCheck', {
				Text = 'Team Check',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.TeamCheck = Value
				end
			})

			Sections.ESPsettings:AddToggle('TeamColors', {
				Text = 'Use Team Colors',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.UseTeamColor = Value
				end
			})

			Sections.ESPsettings:AddSlider('ChamFillTransparency', {
				Text = 'Cham Fill Transparency',
				Default = 0,
				Min = 0,
				Max = 1,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.ESP.Chams.FillTransparency = Value
				end
			})

			Sections.ESPsettings:AddSlider('ChamOutlineTransparency', {
				Text = 'Cham Outline Transparency',
				Default = 0,
				Min = 0,
				Max = 1,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.ESP.Chams.OutlineTransparency = Value
				end
			})

			Sections.ESPsettings:AddDropdown('TracerOrigin', {
				Values = { 'Top', 'Middle', 'Bottom', 'Gun' },
				Default = 2,
				Multi = false,

				Text = 'Tracer Origin',
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Tracers.Origin = Value
				end
			})

			--// Lighting Section

			Sections.Lighting:AddToggle('OverrideAmbient', {
				Text = 'Override Ambient',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Lighting.OverrideAmbient.Enabled = Value
				end
			}):AddColorPicker('AmbientColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Ambient Color',
				Transparency = 0,

				Callback = function(Value)
					if FeatureTable.ESP.Lighting.OverrideAmbient.Enabled then
						FeatureTable.ESP.Lighting.OverrideAmbient.Color = Value

						do --// Properties

							Functions.Normal:SetAmbient("Ambient", Value)
							Functions.Normal:SetAmbient("OutdoorAmbient", Value)
							Functions.Normal:SetAmbient("ColorShift_Top", Value)
							Functions.Normal:SetAmbient("ColorShift_Bottom", Value)

						end
					end
				end
			})

			--// Grenade Section

			Sections.Grenade:AddToggle('Grenade', {
				Text = 'Grenade ESP',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Grenade.GrenadeESP.Enabled = Value
				end
			}):AddColorPicker('GrenadeColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Grenade Color',
				Transparency = 0,

				Callback = function(Value)
					FeatureTable.ESP.Grenade.GrenadeESP.Color = Value
				end
			})

			Sections.Grenade:AddToggle('TrailModifier', {
				Text = 'Trail Modifier',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.ESP.Grenade.TrailModifier.Enabled = Value
				end
			}):AddColorPicker('TrailColor', {
				Default = Color3.fromRGB(255, 255, 255),
				Title = 'Trail Color',
				Transparency = 0,

				Callback = function(Value)
					FeatureTable.ESP.Grenade.TrailModifier.Color = Value
				end
			})

			Sections.Grenade:AddSlider('TrailLifetime', {
				Text = 'Trail Lifetime',
				Default = 0.55,
				Min = 0,
				Max = 10,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.ESP.Grenade.TrailModifier.TrailLifetime = Value
				end
			})

		end

		do --// Blatant Tab

			--// Player section

			Sections.Player:AddToggle('Fly', {
				Text = 'Fly',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Blatant.Player.Fly.Enabled = Value
				end
			})

			Sections.Player:AddToggle('Bhop', {
				Text = 'Bhop',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Blatant.Player.Bhop = Value
				end
			})

			Sections.Player:AddToggle('JumpModifier', {
				Text = 'Override Jump Power',
				Default = false,
				Tooltip = nil,

				Callback = function(Value)
					FeatureTable.Blatant.Player.JumpPowerModifier.Enabled = Value
				end
			})

			Sections.Player:AddSlider('JumpPower', {
				Text = 'Jump Power',
				Default = 0,
				Min = 0,
				Max = 80,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.Blatant.Player.JumpPowerModifier.Power = Value
				end
			})

			Sections.Player:AddSlider('HipHeight', {
				Text = 'Hip Height',
				Default = 0,
				Min = 0,
				Max = 50,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.Blatant.Player.HipHeight = Value
				end
			})

			Sections.Player:AddSlider('FlySpeed', {
				Text = 'Fly Speed',
				Default = 0,
				Min = 0,
				Max = 50,
				Rounding = 1,
				Compact = false,

				Callback = function(Value)
					FeatureTable.Blatant.Player.Fly.Speed = Value
				end
			})

		end

	end

	do --// Logic

		do --// Functions

			do --// Regular

				do --// Lighting

					function Functions.Normal:SetAmbient(Property, Value)
						if FeatureTable.ESP.Lighting.OverrideAmbient.Enabled then
							Lighting[Property] = Value
						end
					end

				end

				do --// Players

					function Functions.Normal:GetTeam(Player)
						if Player ~= nil and Player.Parent ~= nil and Player:FindFirstChildOfClass("Folder") then
							local Helmet = Player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
							if Helmet then
								if Helmet.BrickColor == BrickColor.new("Black") then
									return game.Teams.Phantoms
								end
								return game.Teams.Ghosts
							end
						end
					end

					function Functions.Normal:GetPlayers()
						local PlayerList = {}
						for i,Teams in Players:GetChildren() do
							for i,Players in Teams:GetChildren() do
								table.insert(PlayerList, Players)
							end
						end
						return PlayerList
					end

				end

				do --// LocalPlayer
					function Functions.Normal:GetGun()
						for i,Viewmodel in Camera:GetChildren() do
							if Viewmodel:IsA("Model") and not Viewmodel.Name:find("Arm") then
								return Viewmodel
							end
						end
						return nil
					end
				end

				do --// Math

					function Functions.Normal:Measure(Origin, End)
						return (Origin - End).Magnitude
					end

					function Functions.Normal:GetLength(Table) --// This isnt even math btw, but its not related to any of the other sections so whatever lol
						local Int = 0
						for WhatTheSigma in Table do
							Int += 1
						end
						return Int
					end

				end

			end

			do --// Aimbot

				function Functions.Normal:getClosestPlayer()
					local Player = nil
					local Hitpart = nil
					local Distance = math.huge

					for i, Players in Functions.Normal:GetPlayers() do
						if Players ~= nil then
							local Children = Players:GetChildren()

							local Torso = Children[6]

							local Screen = Camera:WorldToViewportPoint(Torso.Position)
							local MeasureDistance = (Vector2.new(Storage.Other.ViewportSize.X / 2, Storage.Other.ViewportSize.Y / 2) - Vector2.new(Screen.X, Screen.Y)).Magnitude

							local PlayerIsVisible = (not FeatureTable.Combat.WallCheck) or Functions.Normal:PlayerVisible(Players, Camera.CFrame.Position, Torso.Position, {Blatant, Ignore, Players:FindFirstChildOfClass("Folder")})

							if MeasureDistance < Distance and MeasureDistance <= FOVCircle.Radius * 1.25 and PlayerIsVisible then
								Player = Players
								Distance = MeasureDistance

								if tostring(FeatureTable.Combat.Hitpart):find("Random") then
									local Keys = {}

									do --// WhatTheSigma
										for WhatTheSigma in Storage.Index do
											table.insert(Keys, WhatTheSigma)
										end
									end

									local Index = math.random(1, Functions.Normal:GetLength(Keys))
									local Rndm = Keys[Index]

									Hitpart = Children[Storage.Index[Rndm]]
								else
									Hitpart = Children[FeatureTable.Combat.Hitpart]
								end
							end
						end
					end

					return {Closest = Player, Hitpart = Hitpart}
				end

				function Functions.Normal:PlayerVisible(Player, Origin, End, Ignorelist)

					local Params = RaycastParams.new()
					do --// Param Properties

						Params.FilterDescendantsInstances = Ignorelist
						Params.FilterType = Enum.RaycastFilterType.Exclude
						Params.IgnoreWater = true

					end

					local CastRay = workspace:Raycast(Origin, End - Origin, Params)
					if CastRay and CastRay.Instance then
						if CastRay.Instance:IsDescendantOf(Player) then
							return true
						end
					end
					return false

				end

			end

			do --// ESP
				function Functions.ESP:Create(Player)

					if not table.find(Storage.ESP.Boxes, Player) then

						local Box = Drawing.new("Square")
						Box.Color = Color3.fromRGB(255,255,255)
						Box.Transparency = 1
						Box.Visible = true
						Box.Thickness = 1
						Box.ZIndex = 2

						do --// Table insert

							table.insert(Storage.ESP.Boxes, Box)
							table.insert(Storage.ESP.Boxes, Player)

						end

					end
					if not table.find(Storage.ESP.Tracers, Player) then

						local Tracer = Drawing.new("Line")
						Tracer.Transparency = 1
						Tracer.Visible = true
						Tracer.Color = Color3.fromRGB(255,255,255)

						do --// Table insert

							table.insert(Storage.ESP.Tracers, Tracer)
							table.insert(Storage.ESP.Tracers, Player)

						end

					end

				end

				function Functions.ESP:ClearTable(esps, esptable, index)
					for i = 1, #esps do
						esps[i]:Destroy()
					end
					do --// Table clear
						table.remove(esptable, index)
						table.remove(esptable, index-1)
					end
				end
			end

		end

		do --// Loops

			task.spawn(function()
				while task.wait() do --// gl working with the dogshit code, skids :D

					do --// Combat

						do --// Aimbot

							if FeatureTable.Combat.SilentAim.Enabled then

								local Enemy = Storage.Other.ClosestPlayer
								local Target = Enemy.Closest
								if Target ~= nil and (FeatureTable.Combat.TeamCheck and Functions.Normal:GetTeam(Target) ~= game.Players.LocalPlayer.Team or not FeatureTable.Combat.TeamCheck) then

									local Hitpart = Enemy.Hitpart
									local Gun = Functions.Normal:GetGun()

									if Hitpart and Gun then
										for i, GunParts in Gun:GetChildren() do
											pcall(function()
												local Joints = GunParts:GetJoints()
												if GunParts.Name:find("SightMark") or GunParts.Name:find("FlameSUP") or GunParts.Name:find("Flame") then
													local Vector = Vector3New()

													do --// Hitchance

														local Chance = FeatureTable.Combat.SilentAim.Hitchance
														if Chance < 100 then --// Pretty awful but it works
															local MissChance = (100 - Chance) / 100
															local x = math.random() * 3 - 1
															local y = math.random() * 3 - 1
															local z = math.random() * 3 - 1 
															Vector = Vector3New(x, y, z) * MissChance
														end

													end

													Joints[1].C0 = Joints[1].Part0.CFrame:ToObjectSpace(CFrame.lookAt(Joints[1].Part1.Position, (Hitpart.Position + Vector)))
												end
											end)
										end
									end

								end

							end


						end

					end

					do --// ESP

						for i,Players in Functions.Normal:GetPlayers() do --// bro... so p1000
							Functions.ESP:Create(Players)
						end

						do --// Box ESP

							for i,Player in Storage.ESP.Boxes do --// Box logic (obviously)
								if typeof(Player) == "Instance" then

									local Box = Storage.ESP.Boxes[i-1]

									if FeatureTable.ESP.Box.Enabled and Player:IsDescendantOf(workspace) then
										local Torso = Player:GetChildren()[6]
										if Torso ~= nil then
											local Position, OnScreen = Camera:WorldToViewportPoint(Torso.Position) --// Convert to screen pos since we're rendering the boxes on the screen (duh)

											local Team = Functions.Normal:GetTeam(Player)
											local TeamColor = Team.TeamColor

											if OnScreen and FeatureTable.ESP.TeamCheck and tostring(Team) ~= game.Players.LocalPlayer.Team.Name or not FeatureTable.ESP.TeamCheck then

												local PosX = Position.X - (Box.Size.X / 2)
												local PosY = Position.Y - (Box.Size.Y / 2)
												local Scale = 1000/(Camera.CFrame.Position - Torso.Position).Magnitude*80/Camera.FieldOfView --// Very simple box distance scale

												Box.Position = Vector2.new(PosX, PosY)
												Box.Size = Vector2.new(2 * Scale, 3 * Scale)
												Box.Visible = true

												if FeatureTable.ESP.UseTeamColor then --// 😭
													if tostring(TeamColor) == "Bright blue" then
														Box.Color = Color3.fromRGB(0, 162, 255)
													elseif tostring(TeamColor) == "Bright orange" then
														Box.Color = Color3.fromRGB(255, 162, 0)
													end
												else
													Box.Color = FeatureTable.ESP.Box.Color
												end

											else

												Functions.ESP:ClearTable({Box}, Storage.ESP.Boxes, i)

											end

										else

											Functions.ESP:ClearTable({Box}, Storage.ESP.Boxes, i)

										end
									else

										Functions.ESP:ClearTable({Box}, Storage.ESP.Boxes, i)

									end
								end
							end

						end

						do --// Tracer ESP

							for i,Player in Storage.ESP.Tracers do --// Tracer logic (obviously once again)
								if typeof(Player) == "Instance" then

									local Tracer = Storage.ESP.Tracers[i-1]

									if FeatureTable.ESP.Tracers.Enabled and Player:IsDescendantOf(workspace) then
										local Torso = Player:GetChildren()[6]
										if Torso ~= nil then
											local Position, OnScreen = Camera:WorldToViewportPoint(Torso.Position) --// Convert to screen pos since we're rendering the boxes on the screen (duh)

											local Team = Functions.Normal:GetTeam(Player)
											local TeamColor = Team.TeamColor

											if OnScreen and FeatureTable.ESP.TeamCheck and tostring(Team) ~= game.Players.LocalPlayer.Team.Name or not FeatureTable.ESP.TeamCheck then

												local Origin = FeatureTable.ESP.Tracers.Origin
												local Value
												if Origin ~= "Gun" then

													if Origin == "Top" then
														Value = 0 
													elseif Origin == "Middle" then
														Value = Storage.Other.ViewportSize.Y / 2
													elseif Origin == "Bottom" then
														Value = Storage.Other.ViewportSize.Y
													end

													Tracer.From = Vector2.new(Storage.Other.ViewportSize.X / 2, Value)
													Tracer.To = Vector2.new(Position.X, Position.Y)
												else

													local Gun = Functions.Normal:GetGun()
													if Gun ~= nil and Gun:FindFirstChild("Flame") then
														local TipPosition = Camera:WorldToViewportPoint(Gun["Flame"].Position) or Camera:WorldToViewportPoint(Gun["FlameSUP"].Position)
														Tracer.From = Vector2.new(TipPosition.X, TipPosition.Y)
														Tracer.To = Vector2.new(Position.X, Position.Y)
													else
														Functions.ESP:ClearTable({Tracer}, Storage.ESP.Tracers, i)
													end

												end

												if FeatureTable.ESP.UseTeamColor then
													if tostring(TeamColor) == "Bright blue" then
														Tracer.Color = Color3.fromRGB(0, 162, 255)
													elseif tostring(TeamColor) == "Bright orange" then
														Tracer.Color = Color3.fromRGB(255, 162, 0)
													end
												else
													Tracer.Color = FeatureTable.ESP.Tracers.Color
												end

											else

												Functions.ESP:ClearTable({Tracer}, Storage.ESP.Tracers, i)

											end

										else

											Functions.ESP:ClearTable({Tracer}, Storage.ESP.Tracers, i)

										end
									else

										Functions.ESP:ClearTable({Tracer}, Storage.ESP.Tracers, i)

									end
								end
							end

						end

						do --// Cham ESP

							for i, Player in Functions.Normal:GetPlayers() do
								if Player ~= nil then

									local Highlight = Player:FindFirstChildOfClass("Highlight")
									local Team = Functions.Normal:GetTeam(Player)
									local TeamColor = Team.TeamColor

									if FeatureTable.ESP.Chams.Enabled and (FeatureTable.ESP.TeamCheck and tostring(Team) ~= game.Players.LocalPlayer.Team.Name or not FeatureTable.ESP.TeamCheck) then

										if not Highlight then
											Highlight = Instance.new("Highlight", Player)
										end

										Highlight.Enabled = true
										Highlight.Adornee = Player
										Highlight.FillColor = FeatureTable.ESP.Chams.FillColor
										Highlight.OutlineColor = FeatureTable.ESP.Chams.OutlineColor
										Highlight.FillTransparency = FeatureTable.ESP.Chams.FillTransparency
										Highlight.OutlineTransparency = FeatureTable.ESP.Chams.OutlineTransparency
										Highlight.DepthMode = FeatureTable.ESP.Chams.VisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop

										if FeatureTable.ESP.UseTeamColor then --// 😭
											if tostring(TeamColor) == "Bright blue" then
												Highlight.FillColor = Color3.fromRGB(0, 162, 255)
												Highlight.OutlineColor = Color3.fromRGB(0, 162, 255)
											elseif tostring(TeamColor) == "Bright orange" then
												Highlight.FillColor = Color3.fromRGB(255, 162, 0)
												Highlight.OutlineColor = Color3.fromRGB(255, 162, 0)
											end
										else
											Highlight.FillColor = FeatureTable.ESP.Chams.FillColor
											Highlight.OutlineColor = FeatureTable.ESP.Chams.OutlineColor
										end

									else

										if Highlight then
											Highlight:Destroy()
										end

									end

								end
							end

						end

					end

					do --// Blatant

						do --// Player

							local LocalPlayer = Ignore:FindFirstChild("RefPlayer")
							if LocalPlayer then
								local Humanoid = LocalPlayer:FindFirstChildOfClass("Humanoid")

								do --// Player Modifications

									if Humanoid then

										if FeatureTable.Blatant.Player.JumpPowerModifier.Enabled then
											Humanoid.JumpPower = FeatureTable.Blatant.Player.JumpPowerModifier.Power
										end
										if FeatureTable.Blatant.Player.Fly.Enabled then

											local Direction = Vector3New()

											if LocalPlayer then

												local LookVector = Camera.CFrame.LookVector * Vector3New(1, 0, 1)
												local Directions = { --// Very optimized real!
													[Enum.KeyCode.W] = LookVector,
													[Enum.KeyCode.S] = -LookVector,
													[Enum.KeyCode.D] = Vector3New(-LookVector.Z, 0, LookVector.X),
													[Enum.KeyCode.A] = Vector3New(LookVector.Z, 0, -LookVector.X),
													[Enum.KeyCode.Space] = Vector3New(0, 5 * 5, 0),
													[Enum.KeyCode.LeftControl] = Vector3New(0, -5 * 5, 0)
												}

												for Key, Dir in Directions do
													if UserInputService:IsKeyDown(Key) then
														Direction = Direction + Dir
													end
												end

												if Direction.Magnitude > 0 then
													Direction = Direction.Unit
													LocalPlayer.HumanoidRootPart.Velocity = Direction * FeatureTable.Blatant.Player.Fly.Speed
													LocalPlayer.HumanoidRootPart.Anchored = false
												else
													LocalPlayer.HumanoidRootPart.Velocity = Vector3New()
													LocalPlayer.HumanoidRootPart.Anchored = true
												end

											end

										end
										if UserInputService:IsKeyDown(Enum.KeyCode.Space) and FeatureTable.Blatant.Player.Bhop then
											Humanoid.Jump = true
										end
										Humanoid.HipHeight = FeatureTable.Blatant.Player.HipHeight

									end

								end

							end

						end

					end

					do --// Extra

						Storage.Other.ClosestPlayer = Functions.Normal:getClosestPlayer()

						do --// FOV Circle

							local Dynamic = FeatureTable.Combat.SilentAim.DummyRange / math.tan(math.rad(Camera.FieldOfView / 2))
							FOVCircle.Position = Vector2.new(Storage.Other.ViewportSize.X/2, Storage.Other.ViewportSize.Y/2)

							if FeatureTable.Combat.SilentAim.DynamicFOV then
								FOVCircle.Radius = Dynamic
							else
								FOVCircle.Radius = FeatureTable.Combat.SilentAim.DummyRange
							end

						end

					end

				end
			end)

		end

		do --// Connections

			Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				Storage.Other.ViewportSize = Camera.ViewportSize
			end)

			do --// Lighting (I love this part)

				Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
					Functions.Normal:SetAmbient("Ambient", FeatureTable.ESP.Lighting.OverrideAmbient.Color)
				end)

				Lighting:GetPropertyChangedSignal("OutdoorAmbient"):Connect(function()
					Functions.Normal:SetAmbient("OutdoorAmbient", FeatureTable.ESP.Lighting.OverrideAmbient.Color)
				end)

				Lighting:GetPropertyChangedSignal("ColorShift_Top"):Connect(function()
					Functions.Normal:SetAmbient("ColorShift_Top", FeatureTable.ESP.Lighting.OverrideAmbient.Color)
				end)

				Lighting:GetPropertyChangedSignal("ColorShift_Bottom"):Connect(function()
					Functions.Normal:SetAmbient("ColorShift_Bottom", FeatureTable.ESP.Lighting.OverrideAmbient.Color)
				end)

			end

			Blatant.ChildAdded:Connect(function(Child)
				if tostring(Child.Name):find("Trigger") then 
					if FeatureTable.ESP.Grenade.GrenadeESP.Enabled then
						local Billboard = Instance.new("BillboardGui", Child)
						local Frame = Instance.new("Frame", Billboard)
						local UICorner = Instance.new("UICorner", Frame)

						do --// Properties
							do --// BillboardGui
								Billboard.Enabled = true
								Billboard.AlwaysOnTop = true
								Billboard.Size = UDim2.new(1, 0, 1, 0)
								Billboard.Adornee = Child
							end
							do --// Frame
								Frame.Size = UDim2.new(1, 0, 1, 0)
								Frame.BackgroundTransparency = FeatureTable.ESP.Grenade.GrenadeESP.Transparency
								Frame.BackgroundColor3 = FeatureTable.ESP.Grenade.GrenadeESP.Color
							end
							do --// UICorner
								UICorner.CornerRadius = UDim.new(0, 50)
							end
						end
					end
					if FeatureTable.ESP.Grenade.TrailModifier.Enabled then
						local Trail = Child:WaitForChild("Trail")
						Trail.Lifetime = FeatureTable.ESP.Grenade.TrailModifier.TrailLifetime
						Trail.Color = ColorSequence.new(FeatureTable.ESP.Grenade.TrailModifier.Color)
					end
				end
			end)


		end


	end

end

Library:OnUnload(function()
	Library.Unloaded = true
end)

local MenuGroup = Tabs['Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('project aimspace')
SaveManager:SetFolder('project aimspace/PF')

SaveManager:BuildConfigSection(Tabs['Settings'])
ThemeManager:ApplyToTab(Tabs['Settings'])
SaveManager:LoadAutoloadConfig()
