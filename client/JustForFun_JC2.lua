class "JustForFun_JC2"

function JustForFun_JC2:__init()
	self.Banner = ""
	self.BannerTime = 0

	Network:Subscribe("Banner", self, self.BannerNetwork)
	Events:Subscribe("Render", self, self.Render)
end

function JustForFun_JC2:BannerNetwork(t)
	self.Banner = t.banner
	self.BannerTime = os.clock
end

function JustForFun_JC2:Render(args)
	local Position = Vector2(Render.Width/2, 0)
	
	Position.y = Position.y + Render:GetTextHeight(self.Banner, TextSize.Large)
	Position.x = Position.x - Render:GetTextWidth(self.Banner, TextSize.Large) / 2
		
	Render:DrawText(Position, self.Banner, Color( 255, 255, 0, 255),TextSize.Large)
end

justforfun = JustForFun_JC2()