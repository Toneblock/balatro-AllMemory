----------------------------------------------
------------MOD CODE -------------------------

local allm = SMODS.current_mod

function allm_hide(arg, obj)
	if allm.config[arg] then
		if arg == 'tooltips' and allm_hide('tooltips_exclude') and obj then
			local whitelist = {
				'tag_orbital',
				'j_castle',
				'j_mail',
				'j_ancient',
				'j_idol',
				'j_todo_list',
			}
			local key = nil
			if obj.key then
				key = obj.key
			elseif obj.config and obj.config.center then
				key = obj.config.center.key
			elseif obj.config and obj.config.ref_table then
				key = obj.config.ref_table.key
			end
			key = key or 'NULL'
			for i, v in ipairs(whitelist) do
				if v == key then return false end
			end
		elseif arg == 'poker_hands' and G.STATE == G.STATES.HAND_PLAYED and not obj == 'level' then
			return false
		end
		return true
	end
end

-- hooks and hooks and hooks

-- hide boss effect descriptions
local localize_ref = localize
function localize(args, misc_cat)
	if allm_hide('boss_effects') then
		if args.type == 'raw_descriptions' and args.set == 'Blind' then
			args.key = 'bl_small'
		end
	end
	return localize_ref(args, misc_cat)
end


-- hide deck preview (collide state spoofing)
local update_selecting_hand_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
	if allm_hide('deck') then
		local old_collide = self.deck.cards[1].states.collide.is
		self.deck.cards[1].states.collide.is = false
		local ret = update_selecting_hand_ref(self, dt)
		self.deck.cards[1].states.collide.is = old_collide
		return ret
	end
	return update_selecting_hand_ref(self, dt)
end
-- disable deck peeking
local deck_info_ref = G.FUNCS.deck_info
G.FUNCS.deck_info = function(e)
	if allm_hide('deck') then return end
	return deck_info_ref(e)
end

-- handle hand rows
local hand_row_ref = create_UIBox_current_hand_row
function create_UIBox_current_hand_row(handname, simple)
	if allm_hide('poker_hands') then
		local old_hand = G.GAME.hands[handname]
		G.GAME.hands[handname] = {
			level = '?',
			chips = '?',
			mult = '?',
			played = '?',
			visible = old_hand.visible
		}
		local ret = hand_row_ref(handname, simple)
		G.GAME.hands[handname] = old_hand
		return ret
	end
	return hand_row_ref(handname, simple)
end

-- hide hand chip total
local chip_total_ref = G.FUNCS.hand_chip_total_UI_set
G.FUNCS.hand_chip_total_UI_set = function(e)
	if allm_hide('score') then
		if G.GAME.current_round.current_hand.chip_total < 1 then
			G.GAME.current_round.current_hand.chip_total_text = ''
		else
    			G.GAME.current_round.current_hand.chip_total_text = '????'
		end
		return
	end
	return chip_total_ref(e)
end
-- hide hand chips (the blue ones)
local hand_chip_ref = G.FUNCS.hand_chip_UI_set
G.FUNCS.hand_chip_UI_set = function(e)
	if allm_hide('score') then
    		G.GAME.current_round.current_hand.chip_text = '?'
		return
	end
	return hand_chip_ref(e)
end
-- hide hand mult
local hand_mult_ref = G.FUNCS.hand_mult_UI_set
G.FUNCS.hand_mult_UI_set = function(e)
	if allm_hide('score') then
    		G.GAME.current_round.current_hand.mult_text = '?'
		return
	end
	return hand_mult_ref(e)
end
local chip_ref = G.FUNCS.chip_UI_set
G.FUNCS.chip_UI_set = function(e)
	if allm_hide('score') then
		G.GAME.chips_text = '????'
		return
	end
	return chip_ref(e)
end

allm.config_tab = function(e)
	return allm_get_page()
end

function allm_get_page(page)
	if true then
		return {n=G.UIT.ROOT, config = {align = "cm", padding = 0.15, r = 0.1, colour = G.C.BLACK}, nodes = {
			{n=G.UIT.C, config = {align = "cm", padding = 0.35, r = 0.1, colour = lighten(G.C.BLACK, 0.1)}, nodes = {
				create_toggle{
					label = "Hide all tooltips",
					w = 0,
					ref_table = allm.config, 
					ref_value = "tooltips"
				},
				create_toggle{
					label = "*Exclude certain tooltips",
					w = 0,
					h = 0, -- h doesn't seem to work
					ref_table = allm.config, 
					ref_value = "tooltips_exclude",
					scale = 0.50,
					label_scale = 0.3,
				},
				create_toggle{
					label = "Hide Boss Blind effects", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "boss_effects" 
				},
				create_toggle{
					label = "Hide deck information", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "deck" 
				},
				create_toggle{
					label = "Hide buy costs and sell values", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "costs" 
				},
				create_toggle{
					label = "Hide score requirements", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "requirements" 
				},
				create_toggle{
					label = "Hide current money", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "money" 
				},
			}},
			{n=G.UIT.C, config = {align = "cm", padding = 0.35, r = 0.1, colour = lighten(G.C.BLACK, 0.1)}, nodes = {
				create_toggle{
					label = "Hide poker hand information", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "poker_hands" 
				},
				create_toggle{
					label = "Hide hands and discards", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "hands_discards" 
				},
				create_toggle{
					label = "Hide ante and round", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "ante" 
				},
				create_toggle{
					label = "Hide card amount and limit info", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "cardarea_limits" 
				},
				create_toggle{
					label = "Hide score", 
					w = 0,
					ref_table = allm.config, 
					ref_value = "score" 
				},
			}}
		}}
	end
end

SMODS.Atlas({
    key = "modicon",
    path = "allm_icon.png",
    px = 34,
    py = 34
}):register()

----------------------------------------------
------------MOD CODE END----------------------
