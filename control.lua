local base_util = require("__core__/lualib/util")
local small_ruins = {require("ruins/small-fluid-burner"), require("ruins/small-reinforced-windturbines"),  require("ruins/small-sentinel-outpost")}
local medium_ruins = {require("ruins.medium-creep-biomass"), require("ruins.medium-fuel-plant"), require("ruins/medium-tree-greenhouse")}
local large_ruin = require("ruins/large-matter-plant")

local function make_ruin_set()
  -- Get the base ruin set of the AbandonedRuins mod. This creates a copy of that ruin set.
  local base_ruins = remote.call("AbandonedRuins", "get_ruin_set", "base")

  -- Add the custom Krastorio2 ruins to the existing ruins.
  for _, ruin in pairs(small_ruins) do
    table.insert(base_ruins.small, ruin)
  end
  for _, ruin in pairs(medium_ruins) do
    table.insert(base_ruins.medium, ruin)
  end
  table.insert(base_ruins.large, large_ruin)

  if settings.startup["kr-more-realistic-weapon"].value then
    -- With the weapon overhaul, turrets use the krastorio2 ammo instead of base game ammo.
    --  So, replace those spawned items within the ruins.
    replace_item_name_in_all_ruins(base_ruins, "firearm-magazine", "rifle-magazine")
    replace_item_name_in_all_ruins(base_ruins, "piercing-rounds-magazine", "armor-piercing-rifle-magazine")
  end

  -- Provide the extended and modified ruin set as the "krastorio2" set.
  remote.call("AbandonedRuins", "add_ruin_set", "krastorio2", base_ruins.small, base_ruins.medium, base_ruins.large)
end

-- The ruin set is created always when the game is loaded, since the ruin sets are not save/loaded by AbandonedRuins.
--  Since this is using on_load, we must be sure that it always produces the same result for everyone.
--   Luckily, it's okay to do ruin changes based on a startup setting here since those cannot change during the game.
script.on_init(make_ruin_set)
script.on_load(make_ruin_set)


function replace_item_name_in_all_ruins(ruin_set, value, replacement)
  for _, ruin in pairs(ruin_set.small) do
    replace_item_name(ruin, value, replacement)
  end
  for _, ruin in pairs(ruin_set.medium) do
    replace_item_name(ruin, value, replacement)
  end
  for _, ruin in pairs(ruin_set.large) do
    replace_item_name(ruin, value, replacement)
  end
end

function replace_item_name(ruin, name, replacement)
  if not (ruin.entities and next(ruin.entities) ~= nil) then return end
  for _, entity in pairs(ruin.entities) do
    if entity[3] and entity[3].items then
      local items = base_util.copy(entity[3].items)
      for item, count in pairs(items) do
        if item == name then
          entity[3].items[replacement] = count
          entity[3].items[name] = nil
        end
      end
    end
  end
end
