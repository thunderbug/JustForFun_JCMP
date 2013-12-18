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
	if Game:GetState() ~= GUIState.Game then return end

	local ChatPosition = Vector2(Render.Width/2, 0)
	
	ChatPosition.y = ChatPosition.y + Render:GetTextHeight(self.Banner, TextSize.Large)
	ChatPosition.x = ChatPosition.x - Render:GetTextWidth(self.Banner, TextSize.Large) / 2
		
	Render:DrawText(ChatPosition, self.Banner, Color(255, 255, 0, 255),TextSize.Large)
end

justforfun = JustForFun_JC2()