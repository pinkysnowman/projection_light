local function light_it_up(itemstack, placer, pointed_thing)
	local pos = pointed_thing.above
	if minetest.get_item_group(minetest.get_node(pos).name, "water") > 0 then
		minetest.add_node(pos, {name = "projection_light:water_light"}) 
	else
		minetest.add_node(pos, {name = "projection_light:light"})
	end
	for i = 1,60 do
		local pos1 = {x=pos.x, y=pos.y-i, z=pos.z}
		local pos2 = {x=pos1.x, y=pos1.y-1, z=pos1.z}
		if minetest.get_item_group(minetest.get_node( {x=pos1.x, y=pos1.y+1, z=pos1.z}).name, "light") < 1
		and pos ~= {x=pos1.x, y=pos1.y+1, z=pos1.z} then 
			return 
		end
		if minetest.get_node(pos1).name == "air" then
			minetest.add_node(pos1, {name = "projection_light:light_node"} ) 
		elseif minetest.get_node(pos1).name == "default:water_source" then
			minetest.add_node(pos1, {name = "projection_light:water_light_node"} ) 
		end
	end
	return
end

local function lights_off(pos)
	for i = 1,60 do
		local pos1 = {x=pos.x, y=pos.y-i, z=pos.z}
		if minetest.get_node(pos).name == "projection_light:light" then
			minetest.add_node(pos, {name = "air"} )
		elseif minetest.get_node(pos).name == "projection_light:water_light" then
			minetest.add_node(pos, {name = "default:water_source"} )
		end
		if minetest.get_node(pos1).name == "projection_light:light_node" then
			minetest.add_node(pos1, {name = "air"} )
		elseif minetest.get_node(pos1).name == "projection_light:water_light_node" then
			minetest.add_node(pos1, {name = "default:water_source"} )
		elseif minetest.get_node(pos1).name == ( "projection_light:light" or "projection_light:water_light" ) then
			return 
		end
	end
end

minetest.register_node("projection_light:light_node", {
	description = "light node",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 14,
	buildable_to = true,
	is_ground_content = false,
	groups = {unbreakable=1, light=1, not_in_creative_inventory = 1},
})

minetest.register_node("projection_light:water_light_node", {
	description = "Water light node",
	drawtype = "liquid",
	tiles = {
		{
			name = "default_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		{
			name = "default_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	alpha = 160,
	paramtype = "light",
	light_source = 14,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "none",
	liquid_alternative_source = "projection_light:water_light_node",
	liquid_viscosity = 1,
	post_effect_color = {a = 120, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 1, light=1, not_in_creative_inventory=1},
})

minetest.register_node("projection_light:light", {
	description = "Projection Lighting",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.5 , 0.3125, -0.5, 0.5, 0.5, 0.5},},
	},
	tiles = { "projection_light_light.png" },
	sunlight_propagates = false,
	paramtype = "light",
	walkable = true,
	light_source = 14,
	drop = "projection_light:light",
	groups = { snappy = 3, light=2 },
	selection_box = {
		type = "fixed",
		fixed = {{-0.5 , 0.3125, -0.5, 0.5, 0.5, 0.5},}, 
	},
	on_place = function(itemstack, placer, pointed_thing)
		light_it_up(itemstack, placer, pointed_thing)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		lights_off(pos)
	end,
}) 

minetest.register_node("projection_light:water_light", {
	description = "Underwater Projection Lighting",
	tiles = { "default_steel_block.png", "projection_light_light.png", "default_steel_block.png" },
	sunlight_propagates = false,
	paramtype = "light",
	light_source = 14,
	drop = "projection_light:light",
	groups = { snappy = 3, light=2, not_in_creative_inventory=1 },
	on_place = function(pointed_thing)
		light_it_up(itemstack, placer, pointed_thing)
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		lights_off(pos)
	end,
})

minetest.register_abm({
	nodenames = {"group:light"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local na =  minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		local nu =  minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		local nn =  node.name
		local is_light = minetest.get_item_group(na, "light")
		if is_light == 0 and minetest.get_item_group(nn, "light") < 2 and na ~= "ignore" then
			if node.name == "projection_light:water_light_node" then
				minetest.add_node(pos, {name = "default:water_source"})
			else
				minetest.remove_node(pos)
			end
		elseif nu == "air" then
			minetest.add_node({x=pos.x, y=pos.y-1, z=pos.z}, {name = "projection_light:light_node"})
		elseif nu == "default:water_source" then
			minetest.add_node({x=pos.x, y=pos.y-1, z=pos.z}, {name = "projection_light:water_light_node"})
		end
	end
})

--crafts
minetest.register_craft({
	output = "projection_lights:light";
	recipe = {
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot", },
		{ "group:glass", "default:torch", "group:glass", },
		{ "group:glass", "default:torch", "group:glass", },
	}
})
minetest.register_craft({
	output = "projection_lights:light";
	recipe = {
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot", },
		{ "default:glass", "default:torch", "default:glass", },
		{ "default:glass", "default:torch", "default:glass", },
	}
})
if (minetest.get_modpath("moreblocks")) then
	minetest.register_craft({
		output = "projection_lights:light";
		recipe = {
			{ "moreblocks:super_glo_glass", "", "", },
			{ "moreblocks:super_glo_glass", "", "", },
			{ "moreblocks:super_glo_glass", "", "", },
		}
	})
end
if (minetest.get_modpath("homedecor")) then
	minetest.register_craft({
		output = "projection_lights:light";
		recipe = {
			{ "homedecor:glowlight_quarter_white", "", "", },
			{ "homedecor:glowlight_quarter_white", "", "", },
			{ "homedecor:glowlight_quarter_white", "", "", },
		}
	})
end