ITEM.name = "Mama's Cookbook"
ITEM.model = "models/props_lab/binderredlabel.mdl"
ITEM.category = "Literature"
ITEM.width = 1
ITEM.height = 2
ITEM.description = "Everyone loves mama"
ITEM.price = 0

ITEM.pages = {
    [1] = "SUNNY EGGY TOAST\nStep 1: Take a nice slice of Bread.\nStep 2: Crack one Egg ever so gently into a warm pan.\nStep 3: Let it sizzle until the edges smile at you.\nStep 4: Place the egg on the bread, and there you have a cheerful breakfast to start your day.",
    
    [2] = "CARROT & POTATO STEW\nStep 1: Peel a Carrot and a Potato, sweetie.\nStep 2: Chop them into friendly little cubes.\nStep 3: Place them in a pot with water, and let them bubble away.\nStep 4: Stir now and then, whispering kind thoughts, until they are soft and cozy.",
    
    [3] = "APPLE BUTTER FRY-UP\nStep 1: Slice up a shiny Apple, darling.\nStep 2: Melt a pat of Butter in your pan.\nStep 3: Lay the apple slices in gently, and let them caramelize.\nStep 4: Serve warm — it tastes like a hug in food form.",
    
    [4] = "BEEF & BEAN SOUP\nStep 1: Open your Canned Beef, my love.\nStep 2: Add a handful of Beans.\nStep 3: Place them together in a pot with water.\nStep 4: Let them simmer until the flavors cuddle together, making a hearty soup to warm your tummy.",
    
    [5] = "POTATO PANCAKES\nStep 1: Mash up a Potato until it’s fluffy.\nStep 2: Crack in an Egg to help it hold hands.\nStep 3: Shape into little patties, like tiny pancakes.\nStep 4: Fry them in a pan until they are golden and smiling back at you.",
    
    [6] = "🍞 APPLE SUGAR TOAST\nStep 1: Take a slice of Bread, sweetheart.\nStep 2: Add thin slices of Apple on top.\nStep 3: Sprinkle a little Sugar, like fairy dust.\nStep 4: Toast in a pan until the apples are soft and the bread is golden.",
    
    [7] = "ROOTY FRIENDS STEW\nStep 1: Gather Carrot, Potato, and Onion — they are best friends.\nStep 2: Chop them up and place them in a pot of water.\nStep 3: Let them dance together in the broth.\nStep 4: Cook until they are tender and cheerful, ready to comfort you.",
    
    [8] = "BEAN SCRAMBLE\nStep 1: Crack an Egg into a bowl, darling.\nStep 2: Add a spoonful of Beans.\nStep 3: Whisk them together until they giggle.\nStep 4: Pour into a pan and cook until fluffy and full of joy.",
    
    [9] = "BEEF & POTATO HOTPOT\nStep 1: Chop up a Potato into hearty chunks.\nStep 2: Add Canned Beef to keep it company.\nStep 3: Place them in a pot with broth.\nStep 4: Simmer until everything is tender and the flavors are hugging tightly.",
    
    [10] = "APPLE OMELET\nStep 1: Crack an Egg into a bowl, sweetie.\nStep 2: Add slices of Apple, folding them in gently.\nStep 3: Pour into a warm pan.\nStep 4: Cook until golden and fluffy — a silly, sweet omelet that will make you smile."
}

ITEM.functions.use = {
    name = "Open",
    icon = "icon16/pencil.png",
    OnRun = function(item)
        local client = item.player
        local id = item:GetID()

        if id then
            local cleanPages = {}
            for k, v in pairs(item.pages or {}) do
                cleanPages[k] = tostring(v)
            end

            netstream.Start(client, "receiveBook", id, cleanPages, item.name)
        end

        return false
    end
}

ITEM:PostHook("OnItemTransferred", function(self, oldInventory, newInventory)
    local receiver = self.player

    if IsValid(receiver) then
        receiver:EmitSound("items/paper_pickup.wav", 60)
    end
end)