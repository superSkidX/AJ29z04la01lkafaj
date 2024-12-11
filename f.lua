local Fluent = loadstring(game:HttpGet('https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'))();
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua'))();
local InterfaceManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua'))();

local players = game:GetService('Players');
local repoStore = game:GetService('ReplicatedStorage');
local runService = game:GetService('RunService');

local function getScript(url)
	if (type(url) ~= 'string') then return warn('getscript failed 1'); end;

	local baseUrl = 'https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/';
	local suc, res = pcall(function() return game:HttpGet(string.format('%s%s.lua', baseUrl, url)); end);
	if (not suc or table.find({'404: Not Found', '400: Invalid Request'}, res)) then return warn('getscript failed 2'); end;

	local fun, err = loadstring(res, url);
	if (not fun) then return warn('getscript syntax err', err); end;

	return fun();
end;

local Maid = getScript('helpers/maid');
local basics = getScript('helpers/basics');

local lplr = players.LocalPlayer;
local cam = workspace.CurrentCamera;

local junk = workspace.Junk;

local sls;

local maid = Maid.new();
local funcs = {};

local niggers = {};

do -- stuff
	local controllers = lplr.PlayerScripts.Client.Controllers;
	local knit = require(repoStore.Packages.Knit);

	local actionService = knit.GetService('ActionService');
	local matchController = knit.GetController('MatchController');

	sls = {
		actionService = actionService,
		doAction = actionService.PerformAction,
		leapController = require(controllers.Action.Leap),
		matchController = matchController,
		staminaController = require(controllers.Stamina),
	};

	maid.ballAuraPart = Instance.new('Part');
	maid.ballAuraPart.Transparency = 0.75;
	maid.ballAuraPart.Anchored = true;
	maid.ballAuraPart.CanCollide = false;
	maid.ballAuraPart.CanTouch = false;
	maid.ballAuraPart.CFrame = CFrame.new(0, 9e9, 0);
	maid.ballAuraPart.Size = Vector3.one;
	maid.ballAuraPart.Shape = Enum.PartType.Ball;
	maid.ballAuraPart.CastShadow = false;
	maid.ballAuraPart.Material = Enum.Material.ForceField;
	maid.ballAuraPart.Color = Color3.fromRGB(255, 0, 0);
	maid.ballAuraPart.Parent = nil;

	task.spawn(function()
		while (true) do
			if (not lplr:GetAttribute('TeamPosition')) then task.wait(); continue; end;

			local root = lplr.Character and lplr.Character.PrimaryPart;
			if (not root) then task.wait(); continue; end;

			local rootPos = root.CFrame.Position;
			if (rootPos.Y <= 55) then task.wait(); continue; end;

			root.CFrame = CFrame.new(rootPos.X, 45, rootPos.Z);

			runService.Heartbeat:Wait();
		end;
	end);
end;

do -- hooking
	local oldNamecall;
	local function onNamecall(self, ...)
		local method = getnamecallmethod();
		local caller = getcallingscript();

		if (method:lower() == 'kick' and tostring(caller):lower() == 'anticheat' and self == lplr) then
			return;
		end;

		return oldNamecall(self, ...);
	end;

	oldNamecall = hookmetamethod(game, '__namecall', onNamecall);

	local oldConsume = sls.staminaController.Consume;
	sls.staminaController.Consume = function(...)
		if (niggers.infStamina) then return true; end;

		return oldConsume(...);
	end;
end;

local req = request or http_request;
if (req) then
	for i = 6463, 6472 do
		if (pcall(function()
			request({
				Url = string.format('http://127.0.0.1:%s/rpc?v=1', i),
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
					Origin = 'https://discord.com'
				},
				Body = vac.encode({
					cmd = 'INVITE_BROWSER',
					args = {code = 'Gxg42Eshpy'},
					nonce = httpService:GenerateGUID(false)
				})
			});
		end)) then
			break;
		end;
	end;
end;

do -- funcs
	function funcs.antiTackle()
		while (niggers.antiTackle) do
			local ball = sls.matchController:GetComponent('Football');
			if (not ball or not ball:HasFootball()) then task.wait(); continue; end;

			sls.actionService:PerformActionThenGet('EvadeActivated');
			task.wait();
		end;
	end;

	function funcs.ballAura()
		while (niggers.ballAura) do
			local root = lplr.Character and lplr.Character.PrimaryPart;
			if (not root) then task.wait(); continue; end;

			local ball = junk:FindFirstChild('Football');
			if (not ball) then task.wait(); continue; end;

			maid.ballAuraPart.Parent = cam;
			maid.ballAuraPart.CFrame = root.CFrame;
			maid.ballAuraPart.Size = Vector3.one * tonumber(niggers.ballAuraRange);

			local mag = (root.CFrame.Position - ball.CFrame.Position).Magnitude;
			if (mag > 20) then task.wait(); continue; end;

			if (ball:GetAttribute('State') ~= 'Released' or mag > tonumber(niggers.ballAuraRange)) then task.wait(); continue; end;

			sls.doAction:Fire('PickUpBall', ball, ball:GetAttribute('ReleaseId'));

			task.wait();
		end;

		maid.ballAuraPart.Parent = nil;
		maid.ballAuraPart.CFrame = CFrame.new(0, 9e9, 0);
		maid.ballAuraPart.Size = Vector3.one;
	end;

	function funcs.noDiveDelay(t)
		local func = debug.getupvalue(sls.leapController.BindActionToController, 7);
		debug.setconstant(func, 12, t and 0 or 0.71);
	end;

	function funcs.ballTP()
		local ball = junk:FindFirstChild('Football');
		if (not ball) then task.wait(); return; end;

		sls.doAction:Fire('PickUpBall', ball, ball:GetAttribute('ReleaseId'));
	end;

	function funcs.shootBall()
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local ball = sls.matchController:GetComponent('Football');
		if (not ball) then return; end;

		local possessedBall = ball:GetPossessedFootball();
		if (not possessedBall) then return; end;

		local ballComponent = ball:GetFootballComponent(possessedBall);
		if (not ballComponent) then return; end;

		local force = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z) * 500;

		possessedBall:SetAttribute('State', 'Released');
		ballComponent:Shoot(root.CFrame.Position, force);
	end;
end;

local Window = Fluent:CreateWindow({
    Title = "VCS discord.gg/Gxg42Eshpy",
    SubTitle = "__vocat on discord",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Character = Window:AddTab({ Title = "Character"}),
	Gameplay = Window:AddTab({ Title = "Gameplay"}),
    Settings = Window:AddTab({ Title = "Settings"})
}

do
    do -- character
		local Speed = Tabs.Character:AddToggle("Speed", {Title = "Speed"});

		Speed:OnChanged(function(val)
			basics.speedVelo(val, 30);
		end);

		local Fly = Tabs.Character:AddToggle("Fly", {Title = "Fly"});

		Fly:OnChanged(function(val)
			basics.flyVelo(val, 100);
		end);

		local InfStamina = Tabs.Character:AddToggle("Inf Stamina", {Title = "Inf Stamina"});

		InfStamina:OnChanged(function(val)
			niggers.infStamina = val;
		end);
	end;

	do -- gameplay
		local at = Tabs.Gameplay:AddToggle("at", {Title = "Anti Tackle"});

		at:OnChanged(function(val)
			funcs.antiTackle();
			niggers.antiTackle = val;
		end);

		local ba = Tabs.Gameplay:AddToggle("ba", {Title = "Ball Aura"});

		ba:OnChanged(function(val)
			funcs.ballAura();
			niggers.ballAura = val;
		end);

		local bar = Tabs.Gameplay:AddSlider("bar", {
			Title = "Slider",
        	Default = 20,
        	Min = 1,
        	Max = 20,
        	Rounding = 1,
		});

		bar:OnChanged(function(val)
			niggers.ballAuraRange = val;
		end);

		local nnd = Tabs.Gameplay:AddToggle("nnd", {Title = "No Dive Delay"});

		nnd:OnChanged(function(val)
			funcs.noDiveDelay(val);
		end);

		local gb = Tabs.Gameplay:AddKeybind("gb", {
			Title = "Get Ball",
			Mode = "Toggle", -- Always, Toggle, Hold
			Default = "G"
		});

		gb:OnClick(function()
			funcs.ballTP();
		end);

		local sb = Tabs.Gameplay:AddKeybind("sb", {
			Title = "Shoot Ball",
			Mode = "Toggle", -- Always, Toggle, Hold
			Default = "T"
		});

		sb:OnClick(function()
			funcs.shootBall();
		end);
	end;
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "NOTICE:",
    Content = "FOR BALL AURA PLEASE TOGGLE UNTIL YOU SEE THE RED CIRCLE, THEN U CAN TURN IT OFF AND ON.",
    Duration = 20
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

