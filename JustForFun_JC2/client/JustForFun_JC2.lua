class "JustForFun_JC2"

function JustForFun_JC2:__init()
	self.Banner = ""
	self.BannerTime = os.clock()
	self.FadeOut = 255
	self.fuel = 1

	Network:Subscribe("Banner", self, self.BannerNetwork)
	Network:Subscribe("VehicleFuel", self, self.FuelCheck)
	Events:Subscribe("Render", self, self.Render)
end

function JustForFun_JC2:BannerNetwork(t)
	self.Banner = t.banner
	self.BannerTime = os.clock()
	self.FadeOut = 255
end

function JustForFun_JC2:FuelCheck(VehicleFuel)
	if not LocalPlayer:InVehicle() then return end
	
	self.fuel = VehicleFuel[LocalPlayer:GetVehicle():GetId()]
	Events:Fire("SendFuel",self.fuel)
end

function JustForFun_JC2:Render(args)
	if Game:GetState() ~= GUIState.Game then return end

	self:RenderBanner()
	self:RenderPosition()
end

function JustForFun_JC2:RenderBanner() 
	local BannerPosition = Vector2(Render.Width/2, 0)
	if os.clock() - self.BannerTime < 10 then
		BannerPosition.y = BannerPosition.y + Render:GetTextHeight(self.Banner, TextSize.Large)
		BannerPosition.x = BannerPosition.x - Render:GetTextWidth(self.Banner, TextSize.Large) / 2
		
		local Alpha = self:BannerFadeOut()	
		Render:DrawText(BannerPosition,self.Banner,Color(48, 0, 0, Alpha),TextSize.Large)
		Render:DrawText(BannerPosition + Vector2( 1, 1 ), self.Banner,Color(48, 0, 0, Alpha * 0.5),TextSize.Large)
	end
end

function JustForFun_JC2:BannerFadeOut()
	local DiffTime = os.clock() - self.BannerTime
	
	if DiffTime < 8 then
		self.FadeOut = 254
		return 255
	elseif self.FadeOut < 255 and self.FadeOut > 2 then
		local Interval = DiffTime - 8
		self.FadeOut = 255 * (1 - Interval)
		return 255 * (1 - Interval)
	else
		return 0
	end
end

function JustForFun_JC2:RenderPosition()
	local CurrentPosition = LocalPlayer:GetPosition()
	local ScreenPosition = Vector2(65,185)
	local ScreenPosition2 = Vector2(75,197)
	Render:DrawText(ScreenPosition,"X:"..math.floor(CurrentPosition.x,0).." Y:"..math.floor(CurrentPosition.y,0),Color(255,255,255,255),10)
	Render:DrawText(ScreenPosition2,"Z:"..math.floor(CurrentPosition.z,0),Color(255,255,255,255),10)
end

justforfun = JustForFun_JC2()