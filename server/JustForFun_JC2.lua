class "JustForFun_JC2"

local mysql = require "luasql.mysql"

function JustForFun_JC2:__init()
	self.Banners = {}
	self.AmountBanners = 0
	self.CurrentBanner = 0
	self.timer = Timer()

	self:ReadBanners()
	
	Events:Subscribe("PostTick", self, self.PostTick)
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
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

function JustForFun_JC2:PostTick(args)
	if self.CurrentBanner > 0 then
		if self.timer:GetSeconds() > 15 then
			if self.CurrentBanner > self.AmountBanners then
				self.CurrentBanner = 1
			end
			self:SendBanner(self.Banners[self.CurrentBanner])
			self.timer:Restart()
		end
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
    end
    
    return false
end

function JustForFun_JC2:PlayerJoin(args)
	Chat:Broadcast("JFF|"..args.player:GetName().." has joined the server!",Color(255, 255, 0,255))
end

function JustForFun_JC2:PlayerQuit(args)
	Chat:Broadcast("JFF|"..args.player:GetName().." has left the server!",Color(255, 255, 0,255))
end

justforfun = JustForFun_JC2()