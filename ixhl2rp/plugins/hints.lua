local PLUGIN = PLUGIN

PLUGIN.name = "Hint System"
PLUGIN.description = "Adds periodic hints to help players."
PLUGIN.author = "Riggs Mackay and Blue"

ix.lang.AddTable("english", {
    optHints = "Toggle hints",
    optHintsDelay = "Hints delay",
    optdHints = "Whether or not hints should be shown.",
    optdHintsDelay = "The delay between hints.",
})

ix.option.Add("hints", ix.type.bool, true, {
    category = "Hint System",
    default = true,
})

ix.option.Add("hintsDelay", ix.type.number, 300, {
    category = "Hint System",
    min = 30 ,
    max = 1800,
    decimals = 1,
    default = 300,
})

ix.hints = ix.hints or {}
ix.hints.stored = {
    "Don't drink the water; they put something in it to make you forget.",
    "This world has little to offer without friends.",
    "The cameras listen to you.",
    "Don't mess with the Combine; they took over Earth in 7 hours.",
    "Ask for help. In tough times you'll be surprised how kind people are.",
    "Civil Protection began as a militarized offshoot to proteect urban centers during the new adminstration from Xen fauna. As unrest grew, they replaced the police entirely.",
    "Try cooking something every now and then! All you need is a stove and ingredients.",
    "The city is under constant surveillance. Cameras, scanners—you're always being watched.",
    "An estimated 800 million to 1.3 billion people died during the portal storms.",
    "Obey. Forget. Comply. But some things are too important to forget.",
    "The streets are empty, yet you are never alone",
    "This world is borrowed. One day, someone will take it back.",
    "Kurtz & Mayer is a famous arms manufacture that managed to cozy up to the early occupation. They secured a deal with the new administration, ensuring their company will survive by supplying arms to Overwatch."
}

if CLIENT then
    local nextHint = 0

    function PLUGIN:Think()
        if not ix.option.Get("hints", true) then return end

        if nextHint < CurTime() then
            local hint = ix.hints.stored[math.random(#ix.hints.stored)]
            ix.util.Notify(hint) -- Uses Helix's built-in notification system
            nextHint = CurTime() + ix.option.Get("hintsDelay", 300)
        end
    end
end
