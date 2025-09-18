local w = ScrW()
local h = ScrH()
local cSoundmixerMute = "snd_soundmixer Citadel_Dialog_Only"
local cSoundmixerDefault = "snd_soundmixer Default_Mix"

local panelBlackout

local function WhiteFlash()
	-- Create a white flash effect
    local flash = vgui.Create("DPanel")
    flash:SetSize(ScrW(), ScrH())
    flash:SetBackgroundColor(Color(255, 255, 255))
    flash:SetAlpha(255)
    flash:AlphaTo(0, 4, 0, function() flash:Remove() end)
end

local function FadeToBlack()
	local ply = LocalPlayer()
	
	ply:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 255), 0, 0)
	ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 5, 0)
	
	timer.Simple(5, function()
            ply:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 255), 0, 0)
    end )
end

local function FadeIn()
	local ply = LocalPlayer()
	
	ply:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 255), 0, 0)
	ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 5, 0)
end

net.Receive("ix_GmanCharacterInvisible", function()
	local target = net.ReadPlayer()
	local targetCharacter = target:GetCharacter()
	local targetCharID = targetCharacter:GetID()
	
	local function RemoveCharTooltip(entity, character, panel)
		if panel and character:GetID() == targetCharID then
			panel:SetVisible(false)
		end
	end
	
	hook.Add("PopulateImportantCharacterInfo", "RemoveCharTooltip_" .. targetCharID, RemoveCharTooltip)
	hook.Add("PopulateCharacterInfo", "RemoveCharTooltip_" .. targetCharID, RemoveCharTooltip)

	target:SetNoDraw(true)
end)

net.Receive("ix_GmanCharacterVisible", function()
	local target = net.ReadPlayer()
	local targetCharacter = target:GetCharacter()
	
	hook.Remove("PopulateImportantCharacterInfo", "RemoveCharTooltip_" .. targetCharacter:GetID())
	hook.Remove("PopulateCharacterInfo", "RemoveCharTooltip_" .. targetCharacter:GetID())
	
	target:SetNoDraw(false)
end)

net.Receive("ix_GmanFreezeEffect", function()

	local sender = net.ReadPlayer()
	
	local COLOR_ACTIVE = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0.04,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.05,
		["$pp_colour_contrast"] = 1.13,
		["$pp_colour_colour"] = 0.4,
		["$pp_colour_mulr"] = 0.03,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0.08
	}

	render.Clear( 0, 0, 0, 0 )
	render.ClearDepth()
	
    -- Create a custom render target
    local rtTexture = GetRenderTarget("RT_FreezeFrame", w, h, false)
    -- Function to capture scene to custom RT
    local function CaptureSceneToRT()
        render.PushRenderTarget(rtTexture)
		render.OverrideAlphaWriteEnable( true, true )
        render.Clear(0, 0, 0, 255, true, true)
        render.RenderView({
            origin = LocalPlayer():EyePos(),
            angles = LocalPlayer():EyeAngles(),
			--aspect = rtWidth / rtHeight,
            w = ScrW(), 
            h = ScrH(),
            drawviewmodel = false,
            fov = 90,
			drawhud = false,
			dopostprocess = true
        })
        render.PopRenderTarget()
    end

    -- Capture the scene once when the effect is activated
    CaptureSceneToRT()

    -- Create a material for the render target
    local rtMaterial = CreateMaterial("RTMaterial", "UnlitGeneric", {
		["$basetexture"] = rtTexture:GetName(),
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["$nolod"] = 1,
        ["$ignorez"] = 1,
        ["$translucent"] = 0,  -- Ensure the material is not translucent
        ["$alpha"] = 1,
        ["$alphatest"] = 1,
        ["$additive"] = 0,
    })

    -- Function to draw the render target texture on the screen
    local function DrawRTTexture()
		cam.Start2D()
			render.SetMaterial( rtMaterial )
			render.DrawScreenQuad()
			DrawColorModify(COLOR_ACTIVE)
		cam.End2D()
    end
	
	local function DrawSenderModel()
		cam.Start3D()
			sender:DrawModel()
		cam.End3D()
	end
	
	local senderChar = sender:GetCharacter()
	
	-- Add render hook
    hook.Add("HUDPaint", "DrawRTTexture", DrawRTTexture)
	hook.Add("PostRender", "DrawSenderModel_" .. senderChar:GetID(), DrawSenderModel)
	-- Add soundmixer
	LocalPlayer():ConCommand(cSoundmixerMute)
	
	WhiteFlash()
end)

net.Receive("ix_GmanBlackoutEffect", function()
    FadeToBlack()
    -- -- Add the blackout HUD hook
    -- hook.Add("HUDPaint", "BlackoutScreen", function()
        -- -- Implement blackout screen rendering
    -- end)
end)

net.Receive("ix_GmanUnBlackoutEffect", function()
    FadeIn()
end)

net.Receive("ix_GmanUnFreezeEffect", function()
	local sender = net.ReadPlayer()
	local senderChar = sender:GetCharacter()
    -- Remove the hooks that create the freeze effect
    hook.Remove("HUDPaint", "DrawRTTexture")
	hook.Remove("PostRender", "DrawSenderModel_" .. senderChar:GetID())
	-- Remove soundmixer
	LocalPlayer():ConCommand(cSoundmixerDefault)
    
    WhiteFlash()
end)
