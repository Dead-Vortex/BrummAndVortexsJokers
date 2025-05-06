--Define each joker texture as a seperate spritesheet

SMODS.Atlas {
	key = "default",
	path = "default.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "atombomb",
	path = "atombomb.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "crinklecut",
	path = "crinklecut.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "doubledown",
	path = "doubledown.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "skong",
	path = "skong.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "holyfu",
	path = "holyfu.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "eraser",
	path = "eraser.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "placeholder",
	path = "placeholder.png",
	px = 71,
	py = 95
}

--Jokers

SMODS.Joker {
	key = 'atombomb',
	loc_txt = {
		name = 'Atom Bomb',
		text = {
			"{X:chips,C:white}X#2#{} Chips",
			"{X:mult,C:white}X#1#{} Mult"
		}
	},
	config = { extra = { Xmult = 2, Xchips = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.Xchips } }
	end,
	blueprint_compat = true,
	rarity = 3,
	atlas = 'atombomb',
	pos = { x = 0, y = 0 },
	cost = 9,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult,
				xchips = card.ability.extra.Xchips
			}
		end
	end
}

SMODS.Joker {
	key = 'doubledown',
	loc_txt = {
		name = 'Double Down',
		text = {
			"Create a random",
			"{C:spectral}Spectral{} card if all",
			"{C:attention}Blinds{} are skipped",
			"this {C:attention}Ante{}",
			"{C:inactive}(Must have room){}"
		}
	},
	display_size = { w = 71, h = 89 },
	pixel_size = { w = 71, h = 89 },
	config = { extra = { skipped_blinds = 0 } },
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	blueprint_compat = false,
	-- TODO: fix blueprint compat
	rarity = 2,
	atlas = 'doubledown',
	pos = { x = 0, y = 0 },
	cost = 5,
	calculate = function(self, card, context)
		if context.skip_blind then
			card.ability.extra.skipped_blinds = card.ability.extra.skipped_blinds + 1
			if card.ability.extra.skipped_blinds == 2 and #G.consumeables.cards < G.consumeables.config.card_limit then
			card.ability.extra.skipped_blinds = 0
			G.E_MANAGER:add_event(Event({
					func = function()
						local card = SMODS.create_card{set = 'Spectral'}
						G.consumeables:emplace(card)
						return true
					end
				}))
						card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
						{ message = "+1 Spectral", colour = G.C.SECONDARY_SET.Spectral })
			end
		end
		if context.setting_blind then
			card.ability.extra.skipped_blinds = 0
		end
	end
}

SMODS.Joker {
	key = 'crinklecut',
	loc_txt = {
		name = 'Crinkle Cut',
		text = {
			"{X:chips,C:white}X#1#{} Chips",
			"Loses {X:chips,C:white}X#2#{} Chips",
			"at end of round"
		}
	},
	config = { extra = { Xchips = 3, Xchips_loss = 0.2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xchips, card.ability.extra.Xchips_loss } }
	end,
	blueprint_compat = true,
	eternal_compat = false,
	rarity = 3,
	atlas = 'crinklecut',
	pos = { x = 0, y = 0 },
	cost = 7,
	calculate = function(self, card, context)
		if context.joker_main then
			return { xchips = card.ability.extra.Xchips }
		end
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
			card.ability.extra.Xchips = card.ability.extra.Xchips - card.ability.extra.Xchips_loss
			if card.ability.extra.Xchips <= 0 and not context.blueprint then
				card:remove_from_deck()
				card:start_dissolve({ G.C.RED }, nil, 1.6)
				return { message = localize("k_eaten_ex"), colour = G.C.FILTER }
			else
				if not context.blueprint then
					card_eval_status_text(card, 'extra', nil, nil, nil,
						{ message = "-X0.2 Chips", colour = G.C.CHIPS })
				end
			end
		end
	end
}

--SMODS.Joker {
--	key = 'collector',
--	loc_txt = {
--		name = 'Collector',
--		text = {
--			"{C:mult}+#1#{} Mult for each",
--			"unique ranked scoring",
--			"card in played hand"
--		}
--	},
--	config = { extra = { mult = 5 } },
--	loc_vars = function(self, info_queue, card)
--		return { vars = { card.ability.extra.mult } }
--	end,
--	rarity = 1,
--	atlas = 'default',
--	pos = { x = 0, y = 0 },
--	cost = 3,
--	calculate = function(self, card, context)
--		if context.joker_main then
--			if not table.contains(uniquecards, context.other_card:get_id())
--				table.insert(uniquecards, context.other_card:get_id())
--			return { mult = card.ability.extra.mult *  }
--		end
--	end
--}

SMODS.Joker {
	key = 'gamblerjoker',
	loc_txt = {
		name = 'Gambler Joker',
		text = {
			"Gains {C:mult}+1{} Mult per",
			"card scored",
			"{C:green}#2# in #3#{} chance to reset",
			"at end of round",
			"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
		}
	},
	config = { extra = { mult = 0, odds = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, G.GAME.probabilities.normal, card.ability.extra.odds } }
	end,
	blueprint_compat = true,
	rarity = 1,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 3,
	calculate = function(self, card, context)
		if context.before and not context.blueprint then
			card.ability.extra.mult = card.ability.extra.mult + #context.scoring_hand
			card_eval_status_text(card, 'extra', nil, nil, nil,
				{ message = "+".. card.ability.extra.mult.. " Mult", colour = G.C.MULT })
		end
		if context.joker_main then
			return { mult = card.ability.extra.mult }
		end
		if context.end_of_round and context.game_over == false and not context.repetition and not context.blueprint then
			if pseudorandom('gamblerjoker') < G.GAME.probabilities.normal / card.ability.extra.odds then
				card.ability.extra.mult = 0
				card_eval_status_text(card, 'extra', nil, nil, nil,
					{ message = "Reset" })
			end
		end
	end
}

SMODS.Joker {
	key = 'braindamage',
	loc_txt = {
		name = 'Drain Bamage',
		text = {
			"{C:dark_edition}+#1#{} Joker Slot#3#",
			"{C:dark_edition}-#2#{} Joker Slot when",
			"{C:attention}Boss Blind{} defeated"
		}
	},
	config = { extra = { extra_slots = 2, slot_loss = 1, plural = "s" } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.extra_slots, card.ability.extra.slot_loss, card.ability.extra.plural } }
	end,
	blueprint_compat = true,
	eternal_compat = false,
	rarity = 2,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
--		G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.extra_slots
		if context.end_of_round and context.game_over == false and G.GAME.blind.boss and not context.repetition and not context.blueprint then
			card.ability.extra.extra_slots = card.ability.extra.extra_slots - card.ability.extra.slot_loss
		end
		if card.ability.extra.extra_slots == 0 then
			card:remove_from_deck()
			card:start_dissolve({ G.C.RED }, nil, 1.6)
			return { message = "Braincells?", colour = G.C.FILTER }
		end
		if card.ability.extra.extra_slots == 1 then
			card.ability.extra.plural = ""
		else
			card.ability.extra.plural = "s"
		end
	end
}

--Vouchers

SMODS.Voucher {
	key = 'refund',
	loc_txt = {
		name = 'Refund',
		text = {
			"Gain {C:money}$5{} when skipping",
			"a Booster Pack"
		}
	},
	calculate = function(self, card, context)
		if context.skipping_booster then
			ease_dollars(5)
		end
	end
}

SMODS.Voucher {
	key = 'gamblingaddiction',
	loc_txt = {
		name = 'Gambling Addiction',
		text = {
			"Create a {C:attention}Wheel of Fortune{}",
			"after {C:attention}Boss Blind{} is defeated",
			"{C:inactive}(Must have room){}"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.c_wheel_of_fortune
	end,
	calculate = function(self, card, context)
		if context.end_of_round and G.GAME.blind.boss and context.main_eval and ((#G.consumeables.cards + G.GAME.consumeable_buffer) < G.consumeables.config.card_limit) and not G.GAME.used_vouchers['v_bvjokers_gamblingdisorder'] then
			G.E_MANAGER:add_event(Event({
					func = function()
						SMODS.add_card{key = "c_wheel_of_fortune"}
						return true
					end
			}))
		end
	end
}

SMODS.Voucher {
	key = 'gamblingdisorder',
	loc_txt = {
		name = 'Gambling Disorder',
		text = {
			"Create a {C:dark_edition}Negative{}",
			"{C:attention}Wheel of Fortune{} after",
			"defeating a {C:attention}Blind{}",
			"{C:red}-$1{} per round"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		info_queue[#info_queue + 1] = G.P_CENTERS.c_wheel_of_fortune
	end,
	requires = {'v_bvjokers_gamblingaddiction'},
	calculate = function(self, card, context)
		if context.setting_blind then
			ease_dollars(-7)
		end
		if context.end_of_round and context.main_eval and (#G.consumeables.cards + G.GAME.consumeable_buffer) < G.consumeables.config.card_limit then
			G.E_MANAGER:add_event(Event({
					func = function()
						local card = SMODS.add_card{key = "c_wheel_of_fortune"}
						card:set_edition('e_negative', true)
						return true
					end
			}))
		end
	end
}