local MAX_SCREEN_DISTANCE = 1000

local function getScreenPos( ent, aimVector )
	local w, h, pos, ang = ent:GetMediaPlayerPosition()
	local eyePos = LocalPlayer():EyePos()

	if pos:Distance( eyePos ) > MAX_SCREEN_DISTANCE then
		return
	end

	local screenNormal = ang:Up()

	if screenNormal:Dot( aimVector ) > 0 then
		return -- prevent clicks from behind the screen
	end

	local hitPos = util.IntersectRayWithPlane(
		eyePos,
		aimVector,
		pos,
		screenNormal
	)

	if not hitPos then
		return
	end

	if MediaPlayer.DEBUG then
		debugoverlay.Cross( hitPos, 1, 60 )
	end

	local localPos = WorldToLocal( pos, ang, hitPos, ang )
	local x, y = -localPos.x, localPos.y

	if ( x < 0 or x > w ) or ( y < 0 or y > h ) then
		return -- out of screen bounds
	end

	return x / w, y / h
end

local function checkScreenClick( aimVector )
	for name, mp in pairs( MediaPlayer.List ) do
		local ent = mp.Entity
		if IsValid( mp ) and not ent:IsDormant() then
			local x, y = getScreenPos( ent, aimVector )
			if x then
				mp:OnMousePressed( x, y )
			end
		end
	end
end


local function mousePressed( mouseCode, aimVector )
	if mouseCode ~= MOUSE_LEFT then
		return
	end

	checkScreenClick( aimVector )
end
hook.Add( "GUIMouseReleased", "MediaPlayer.ScreenIntersect", mousePressed )

--[[
local function bindPressed( ply, bind, pressed )
	if not ( bind == "+attack" and pressed ) then
		return
	end

	local aimVector = ply:GetAimVector()
	checkScreenClick( aimVector )
end
hook.Add( "PlayerBindPress", "MediaPlayer.ScreenIntersect", bindPressed )
]]
