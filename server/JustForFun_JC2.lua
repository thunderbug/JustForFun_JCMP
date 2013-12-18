class "JustForFun_JC2"

function JustForFun_JC2:__init()
	self.Banners = {}
	self.AmountBanners = 0
	self.CurrentBanner = 0
	self.timer = Timer()

	self:ReadBanners()
	
	Events:Subscribe("PostTick", self, self.PostTick)
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
	print(t.banner)
	self.CurrentBanner = self.CurrentBanner + 1
end

justforfun = JustForFun_JC2()