local Schema = Schema

ix.hints = ix.hints or {}

ix.gui.hints = ix.gui.hints or {}
ix.gui.hints.visible = ix.gui.hints.visible or {}

function ix.hints.AddHint(ent)
	if ent and isentity(ent) and IsValid(ent) then
		local panel = vgui.Create("ixHint")
		ix.gui.hints[ent] = panel
		panel:SetText(ent:GetDescription())
	end
	
end

function ix.hints.GetHint(ent)
	return ix.gui.hints[ent]
end

function ix.hints.RemoveHint(ent)
	if ix.gui.hints[ent] then
		ix.gui.hints[ent]:Remove()
	end
end

trNextRun = CurTime()

function ix.hints.CheckVisibility(ent, panel)
	if panel and ispanel(panel) then
		-- print("entered CheckVisibility")
		if not ent:GetEnabled() then return false end
		-- print("ent is enabled")
		
		local ply = LocalPlayer()

		if not ply then return end
		
		local screenPos = ent:GetPos():ToScreen()
		panel:SetText(ent:GetDescription())
		panel:SetPos(screenPos.x, screenPos.y)
		
		local bCanSeePanel = true
		
		local plyPos = ply:GetPos()
		local worldPos = ent:GetPos()
		local dist = plyPos:DistToSqr(worldPos)
		local rangeSqr = (ent:GetDrawRange() or 0)
		
		-- print("CheckVisibility: dist = " .. tostring(dist))
		
		if dist <= rangeSqr then
			if CurTime() >= trNextRun then
			
				if not LocalPlayer():IsLineOfSightClear(worldPos) then
					bCanSeePanel = false;	
				end
			
				-- local tr = util.TraceHull( {
				-- start = LocalPlayer():EyePos(),
				-- endpos = ent:GetPos()
				-- } )
				
				-- if not (tr.Entity == ent) then
					-- bCanSeePanel = false;							
				-- end
				
				trNextRun = CurTime() + 0.35
			end
		else
			bCanSeePanel = false;
		end
		
		if bCanSeePanel then
			if panel:GetAlpha() == 0 then
				-- panel:SetVisible(true)
				panel:SetAlpha(255)
				panel:SizeToContents()
				-- panel:PaintManual(true)
			end
		else
			if panel:GetAlpha() > 0 then
				panel:SetAlpha(0)
			end
		end				
	end
end

function ix.hints.UpdateHints()
	for k, v in pairs(ix.gui.hints or {}) do
		if k and IsValid(k) and k:GetEnabled() then
			ix.hints.CheckVisibility(k, v)
		end
	end
end

hook.Add("PostDrawTranslucentRenderables", "DrawHintPanels", function(bDepth, bSkybox)
	ix.hints.UpdateHints()
end)

-- entity will network self on init
-- net receiver will pass entity to ix.hints:AddHint(ent)
-- AddHint will initialize a hint panel and add it to ix.gui.hints with entity as key

-- entities will only use serverside code to save and network panel information to players
-- clientside, entities will check for players w