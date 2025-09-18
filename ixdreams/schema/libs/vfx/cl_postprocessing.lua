ix.vfx.postprocess = {}

ix.vfx.postprocess.active = {}

ix.vfx.postprocess.defaults = {
	bloom = {
		0.0, 
		0.65, 
		0.0, 
		0.0, 
		0.0, 
		0.0},
	colorModify = {0, 
		0.0, 
		0.0,
		0.0, 
		1.0, 
		0.0, 
		1.0, 
		0.0,
		0.0, 
		0.0},
	motionBlur = {
		1.0,
		1.0,
		0.0},
	sharpen = {
		0,
		0}.
	toytown = {
		0,
		0}
}

ix.vfx.postprocess.tables = {
	bloom = {
		0.0, 
		0.65, 
		0.0, 
		0.0, 
		0.0, 
		0.0},
	bokehDOF = {
		512, 
		256},
	colorModify = {0, 
		0.0, 
		0.0,
		0.0, 
		1.0, 
		0.0, 
		1.0, 
		0.0,
		0.0, 
		0.0}
	materialOverlay = {
		""
		0.30},
	motionBlur = {
		1.0,
		1.0,
		0.0}
	sharpen = {
		0,
		0},
	sobel = {
		1.0},
	sunbeams = {
		0.0,
		0.95,
		0.0},
	texturize = {
		1,
		""},
	toytown = {
		0,
		0}
}

for k, v in pairs(ix.vfx.postprocess.tables) do
	kCopy = k
	kCapitalized = kCopy:gsub("^%l", string.upper)

	ix.vfx.postprocess["Get" .. kCapitalized] = function(key)
		return ix.vfx.postprocess.tables[key]
	end
	
	ix.vfx.postprocess["Set" .. kCapitalized] = function(...)
		local tbl = ix.vfx.postprocess.tables[kCopy]
		local args = {...}
		
		for i = 1, #tbl do
			tbl[i] = args[i] or tbl[i]
		end	
		
		ix.vfx.postprocess.tables[kCopy] = tbl
	end
	
	ix.vfx.postprocess["SetDraw" .. kCapitalized] = function(enable)
		ix.vfx.postprocess.active[k] = enable or nil
	end
	
	if ix.vfx.postprocess.defaults[k] then
		ix.vfx.postprocess["Blend" .. kCapitalized] = function(...)
			local args = {...}
			local tbl = ix.vfx.postprocess.tables[kCopy]
			local defaultTbl = ix.vfx.postprocess.defaults[kCopy]
			
			for i = 1, #tbl do
				if isnumber(tbl[i]) then
					local difference = args[i] - defaultTbl[i]
					
					tbl[i] = tbl[i] + difference
				end
			end
			
			ix.vfx.postprocess.tables[kCopy] = tbl
		end
		
		ix.vfx.postprocess["Unblend" .. kCapitalized] = function(...)
			local args = {...}
			local tbl = ix.vfx.postprocess.tables[kCopy]
			local defaultTbl = ix.vfx.postprocess.defaults[kCopy]
			
			for i = 1, #tbl do
				if isnumber(tbl[i]) and args[i] then
					local difference = args[i] - defaultTbl[i]
					
					tbl[i] = tbl[i] - difference
				end
			end
			
			ix.vfx.postprocess.tables[kCopy] = tbl
		end
	end
end

hook.Add( "RenderScreenspaceEffects", "ixVfxDrawShaders", function()

	-- dynamically toggle draw calls
	
	if ix.vfx and ix.vfx.postprocess then
		for k, _ in pairs(ix.vfx.postprocess.active) do
			local funcName = "Draw" .. k:gsub("^%l", string.upper)
			local tbl = ix.vfx.postprocess.tables[k]
			
			if _G[funcName] and (tbl and tbl ~= {}) then
				_G[funcName](table.unpack(tbl))
			end
		end	
	end
end )