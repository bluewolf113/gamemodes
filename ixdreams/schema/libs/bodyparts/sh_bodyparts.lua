

local bodyHuman = {
	head = {
		cerebrum = {type = "default", status = "normal"}, 
		cerebellum = {type = "default", status = "normal"},  -- overwatch cerebellum implant: soft "aimbot" that pulls the cursor to the head-chest area of any players within a certain range
		brainstem = {type = "default", status = "normal"}, 
		limbicSystem = {type = "default", status = "normal"}, 
		frontalLobe = {type = "default", status = "normal"},
		eyeR = {type = "default", status = "normal"}, -- both eyes filter the entire screen. only one creates a blended gradient
		eyeL = {type = "default", status = "normal"},
		},
	torso = {
		armR = {type = "default", status = "normal"},
		armL = {type = "default", status = "normal"},
		spine = {type = "default", status = "normal"},
		heart = {type = "default", status = "normal"},
		lungR = {type = "default", status = "normal"},
		lungL = {type = "default", status = "normal"},
		stomach = {type = "default", status = "normal"},
		liver = {type = "default", status = "normal"},
		kidneyR = {type = "default", status = "normal"},
		kidneyL = {type = "default", status = "normal"}
	},
	lowerBody = {
		pelvis = {type = "default", status = "normal"},
		legR = {type = "default", status = "normal"},
		legL = {type = "default", status = "normal"}
	}
}

local species = {"human" = {bodyHuman}, "vortigaunt" = {}, "headcrab" = {}, "acontroller" = {}, "agrunt" = {}}

-- states = {enhanced, normal, maimed, crippled, missing}
