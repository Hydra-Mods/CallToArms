local Name, AddOn = ...
local CTA = AddOn.CTA

local LastSoundTime = 0

function CTA:PlaySound()
	if (not self.Settings.PlaySound) then
		return
	end

	local Now = GetTime()

	if ((Now - LastSoundTime) >= 5) then
		PlaySound(SOUNDKIT.MAP_PING, "Master")
		LastSoundTime = Now
	end
end