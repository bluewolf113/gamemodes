
ITEM.name = "Beer Bottle";
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl";
ITEM.width	= 1;
ITEM.height	= 2;
ITEM.description = "The solution and the problem.";
ITEM.category = "Containers";
ITEM.liquid = "beer"                               -- default to being empty
ITEM.capacity = 700                             -- max capacity of the container, in mL
ITEM.emptyContainer = false                       -- item uniqueID that the container should become upon being empty. generally, only use this for bottles of things you want to start filled - say, beer you want to become a beer bottle.