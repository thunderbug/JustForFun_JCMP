class "JustForFun_JC2"

function JustForFun_JC2:__init()
	-- Mysql
	self.luasql = require("luasql.mysql")
	self.mysql = self.luasql.mysql()
	self.MysqlConnection = nil

	-- Ingame Banners
	self.Banners = {}
	self.AmountBanners = 0
	self.CurrentBanner = 0
	self.BannerTimer = Timer()

	self:ReadBanners()
	self:MysqlInit()
	
	-- Fuel
	self.Vehicle = {}
	self.VehicleTime = Timer()
	
	-- Events
	Events:Subscribe("PreTick", self, self.PreTick)
	Events:Subscribe("PostTick", self, self.PostTick)
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
	Events:Subscribe("PlayerSpawn", self, self.PlayerSpawn)
end

function JustForFun_JC2:MysqlInit()
	local Settings = { }

	local file = io.open("ServerSettings.txt", "r")
	for line in file:lines() do
		local TempSetting = self:explode(" = ",line)
		Settings[TempSetting[1]] = TempSetting[2]
	end
	
	self.MysqlConnection = self.mysql:connect(Settings["MysqlDatabase"],Settings["MysqlUsername"],Settings["MysqlPassword"],Settings["MysqlHost"],Settings["MysqlPort"])
	self.MysqlConnection:setautocommit(true)
	
	print("<mysql> MYSQL driver version is: "..self.luasql._MYSQLVERSION)
	print("<mysql> "..self.luasql._COPYRIGHT)
	print("<mysql> "..self.luasql._DESCRIPTION)
	print("<mysql> "..self.luasql._VERSION)
end

function JustForFun_JC2:ReadBanners()
	local file = io.open("ServerBanners.txt", "r")
	local i = 0

	if file == nil then
		print("No ServersBanners.txt File Found!")
		return
	end
	
	for line in file:lines() do
		i = i + 1
		self.Banners[i] = line
	end
	
	self.AmountBanners = i
	
	if self.AmountBanners > 0 then
		self.CurrentBanner = 1
	end
	
	print("Loaded ".. self.AmountBanners .." Banners")
	
	file:close()
end

function JustForFun_JC2:PreTick(args)

end

function JustForFun_JC2:PostTick(args)
	if self.CurrentBanner > 0 then
		if self.BannerTimer:GetSeconds() > 15 then
			if self.CurrentBanner > self.AmountBanners then
				self.CurrentBanner = 1
			end
			self:SendBanner(self.Banners[self.CurrentBanner])
			self.BannerTimer:Restart()
		end
	end
	
	if self.VehicleTime:GetMilliseconds() > 500 then
		local OldVehicles = self.Vehicle
		self.Vehicle = { }
	
		for SVehicle in Server:GetVehicles() do
			if OldVehicles[SVehicle:GetId()] == nil then
				self.Vehicle[SVehicle:GetId()] = 1
			else
				local Speed = SVehicle:GetLinearVelocity():Length() * 3.6
				self.Vehicle[SVehicle:GetId()] = OldVehicles[SVehicle:GetId()] - (0.00001 * Speed + 0.0002)
				if self.Vehicle[SVehicle:GetId()] < 0 or self.Vehicle[SVehicle:GetId()] == 0 then
					self.Vehicle[SVehicle:GetId()] = 0
				end
			end
		end
		
		Network:Broadcast("VehicleFuel",self.Vehicle)
		self.VehicleTime:Restart()
	end
end

function JustForFun_JC2:SendBanner(Banner)
	t = {["banner"] = Banner}
	Network:Broadcast("Banner", t)
	self.CurrentBanner = self.CurrentBanner + 1
end

function JustForFun_JC2:PlayerChat(args)
	local msg = args.text
    local player = args.player

	if(msg:sub(1, 1) ~= "/" ) then
		return true
	end    
    
    local cmdargs = {}
    for word in string.gmatch(msg, "[^%s]+") do
        table.insert(cmdargs, word)
    end
    
    if(cmdargs[1] == "/getpos") then
		Chat:Broadcast("Postion|" .. player:GetName() .. ":" .. tostring(player:GetPosition()),Color(255,255,255,255))
	elseif(cmdargs[1] == "/tphere") then
		Player.GetById(tonumber(cmdargs[2])):Teleport(player:GetPosition(),player:GetAngle())
	elseif(cmdargs[1] == "/tpto") then
		player:Teleport(Player.GetById(tonumber(cmdargs[2])):GetPosition(),Player.GetById(tonumber(cmdargs[2])):GetAngle())
	elseif(cmdargs[1] == "/spawn") then
		player:Teleport(Vector3(-10726, 203, -2714),player:GetAngle())
	elseif(cmdargs[1] == "/refuel") then
		if not player:InVehicle() then return end
		self.Vehicle[player:GetVehicle():GetId()] = 1
		Chat:Send(player,"Vehicle refueld, have fun driving again!",Color(255,255,255,255))
	elseif(cmdargs[1] == "/nofuel") then
		if not player:InVehicle() then return end
		self.Vehicle[player:GetVehicle():GetId()] = 0
    end
    
    return false
end

function JustForFun_JC2:PlayerJoin(args)
	Chat:Broadcast("JFF| "..args.player:GetName().." has joined the server!",Color(255, 255, 0,255))
end

function JustForFun_JC2:PlayerQuit(args)
	Chat:Broadcast("JFF| "..args.player:GetName().." has left the server!",Color(255, 255, 0,255))
	
	local Position = args.player:GetPosition()
	self.MysqlConnection:execute("UPDATE `Player` SET  `X` =  '"..tostring(Position.x).."', `Y` =  '"..tostring(Position.y).."', `Z` =  '"..tostring(Position.z).."' WHERE  `SteamID` = '"..tostring(args.player:GetSteamId()).."';")
end

function JustForFun_JC2:PlayerSpawn(args)
	local PlayerInfo = self.MysqlConnection:execute("SELECT * FROM  `Player` WHERE  `SteamID` =  '"..tostring(args.player:GetSteamId()).."'")
	if PlayerInfo:numrows() == 0 then
		self.MysqlConnection:execute("INSERT INTO `Player` (`Name`, `SteamID`, `X`, `Y`, `Z`) VALUES ('"..tostring(args.player:GetName()).."', '"..tostring(args.player:GetSteamId()).."', -10726, 203, -2714);")
	end
	
	local PlayerInfo = self.MysqlConnection:execute("SELECT * FROM  `Player` WHERE  `SteamID` =  '"..tostring(args.player:GetSteamId()).."'")
	local Player = PlayerInfo:fetch({},"a")
	args.player:SetPosition(Vector3(tonumber(Player["X"]),tonumber(Player["Y"]),tonumber(Player["Z"])))
	
	return false
end

function JustForFun_JC2:explode(div,str) -- credit: http://richard.warburton.it
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

justforfun = JustForFun_JC2()