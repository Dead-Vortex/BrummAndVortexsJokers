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

SMODS.Atlas {
	key = "photochad",
	path = "photochad.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "spaghetti",
	path = "spaghetti.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "refund",
	path = "vouchers/refund.png",
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
				return {message = "+1 Spectral"}
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
	rarity = 2,
	atlas = 'crinklecut',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.joker_main then
			return { xchips = card.ability.extra.Xchips }
		end
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
			card.ability.extra.Xchips = card.ability.extra.Xchips - card.ability.extra.Xchips_loss
			if card.ability.extra.Xchips <= 0 and not context.blueprint then
				card:start_dissolve({ G.C.RED }, nil, 1.6)
				return{ message = localize('k_eaten_ex') }
			else
				if not context.blueprint then
					return { message = "-X0.2 Chips", colour = G.C.CHIPS }
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'collector',
	loc_txt = {
		name = 'Collector',
		text = {
			"{C:mult}+#1#{} Mult for each",
			"unique ranked scoring",
			"card in played hand"
		}
	},
	config = { extra = { mult = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 3,
	calculate = function(self, card, context)
		local uniquecardcount = 0
		local uniquecards = {}
		if context.individual and context.cardarea == G.play then
			if not table.contains(card.ability.extra.uniquecards, context.other_card:get_id()) then
				table.insert(card.ability.extra.uniquecards, context.other_card:get_id())
				card.ability.extra.uniquecardcount = card.ability.extra.uniquecardcount + 1
			end
		end
		if context.joker_main then
			return { mult = card.ability.extra.mult * card.ability.extra.uniquecardcount }
--			uniquecardcount = 0
--			uniquecards = {}
		end
	end
}

SMODS.Joker {
	key = 'gamblerjoker',
	loc_txt = {
		name = 'Gambler Joker',
		text = {
			"Gains {C:mult}+1{} Mult per",
			"card in played hand",
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
			return { message = "+".. card.ability.extra.mult.. " Mult", colour = G.C.MULT })
		end
		if context.joker_main then
			return { mult = card.ability.extra.mult }
		end
		if context.end_of_round and context.game_over == false and not context.repetition and not context.blueprint then
			if pseudorandom('gamblerjoker') < G.GAME.probabilities.normal / card.ability.extra.odds then
				card.ability.extra.mult = 0
				return { message = "Reset" })
			end
		end
	end
}

SMODS.Joker {
	key = 'braindamage',
	loc_txt = {
		name = 'Drain Bamage',
		text = {
			"{C:dark_edition}+#1#{} Joker Slots",
			"{C:dark_edition}-#2#{} Joker Slot when",
			"{C:attention}Boss Blind{} defeated"
		}
	},
	config = { extra = { extra_slots = 2, slot_loss = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.extra_slots, card.ability.extra.slot_loss, card.ability.extra.plural } }
	end,
	blueprint_compat = false,
	eternal_compat = false,
	rarity = 3,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 8,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.extra_slots
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.extra_slots
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.game_over == false and G.GAME.blind.boss and not context.repetition and not context.blueprint then
			card.ability.extra.extra_slots = card.ability.extra.extra_slots - card.ability.extra.slot_loss
			G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slot_loss
			return { message = "-1 Joker Slot", colour = G.C.DARK_EDITION }
		end
		if card.ability.extra.extra_slots < 1 then
			card:start_dissolve({ G.C.RED }, nil, 1.6)
			return{ message = "Braincells?" }
		end
	end
}

SMODS.Joker {
	key = 'photochad',
	loc_txt = {
		name = 'Photochad',
		text = {
			"If first played card is a",
			"{C:attention}#1#{} of {C:mult}#2#{},",
			"{C:attention}retrigger{} it twice and",
			"give {X:mult,C:white}X2{} Mult when scored",
			"Changes to a different",
			"{C:attention}face{} card at end of round"
		}
	},
	config = { extra = { card = "King", suit = "Hearts", xmult = 2, face_cards = {"King", "Queen", "Jack"} } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.card, card.ability.extra.suit, card.ability.extra.xmult }, colours = { G.C.SUITS[card.ability.extra.suit] } }
	end,
	blueprint_compat = true,
	rarity = 3,
	atlas = 'photochad',
	pos = { x = 0, y = 0 },
	cost = 9,
	calculate = function(self, card, context)
		if context.end_of_round and not context.blueprint then
			card.ability.extra.card = pseudorandom_element(card.ability.extra.face_cards, seed)
			card.ability.extra.suit = pseudorandom_element(SMODS.Suits, seed)
			print(pseudorandom_element(SMODS.Suits, seed))
		end
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end
	end
}

SMODS.Joker {
	key = 'crackheadjoker',
	loc_txt = {
		name = 'Crackhead Joker',
		text = {
			"This Joker gains {X:mult,C:white}X#2#{} Mult for",
			"every card discarded this round",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
		}
	},
	config = { extra = { xmult = 1, xmult_gain = 0.07 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain } }
	end,
	blueprint_compat = true,
	rarity = 3,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 9,
	calculate = function(self, card, context)
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end
		if context.discard and not context.blueprint then
			card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
			return { message = "X".. card.ability.extra.xmult.. " Mult", colour = G.C.MULT })
		end
		if context.end_of_round and not context.blueprint then
			card.ability.extra.xmult = 1
		end
	end
}

SMODS.Joker {
	key = 'holyfuck',
	loc_txt = {
		name = 'Holy Fu-',
		text = {
			"{X:mult,C:white}X#1#{} Mult",
			"Every time another card's",
			"{C:dark_edition}Edition{} or {X:mult,C:white}XMult{} activates, multiply",
			"this joker's mult by {X:mult,C:white}X#2#{}"
		}
	},
	config = { extra = { xmult = 2, xmult_increase = 1.25 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
		info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
		info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
		return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_increase } }
	end,
	blueprint_compat = true,
	rarity = 4,
	atlas = 'holyfu',
	pos = { x = 0, y = 0 },
	cost = 20,
	calculate = function(self, card, context)
		if context.post_joker then
			card.ability.extra.xmult = card.ability.extra.xmult * card.ability.extra.xmult_increase
		end
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end
	end,
}

SMODS.Joker {
	key = 'wildfire',
	loc_txt = {
		name = 'Wildfire',
		text = {
			"{C:green}#3# in #1#{} chance for each",
			"played card to recieve a random",
			"{C:attention}Enhancement, Seal,{} or {C:dark_edition}Edition{}",
			"when scored",
			"{C:green}#3# in #2#{} chance for each",
			"played card to be destroyed",
			"when scored"
		}
	},
	config = { extra = { enhance_odds = 10, destroy_odds = 20, chosen_enhance = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.enhance_odds, card.ability.extra.destroy_odds, (G.GAME.probabilities.normal or 1) } }
	end,
	blueprint_compat = true,
	rarity = 2,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 7,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			other_card = card
			if pseudorandom('wildfire') < G.GAME.probabilities.normal / card.ability.extra.destroy_odds then
				if context.destroy_card and context.cardarea == G.play then
					return {remove = true}
				end
			end
--			if pseudorandom('wildfire') < G.GAME.probabilities.normal / card.ability.extra.enhance_odds then
--				card.ability.extra.chosen_enhance = pseudorandom('wildfire')
--				if card.ability.extra.chosen_enhance < 0.34 then
--					card:set_ability(SMODS.poll_enhancement())
--				elseif card.ability.extra.chosen_enhance > 0.33 and card.ability.extra.chosen_enhance < 0.66 then
--					card:set_seal(SMODS.poll_seal())
--				else
--					card:set_edition(poll_edition())
--				end
--			end
		end
	end
}

SMODS.Joker {
	key = 'spaghetti',
	loc_txt = {
		name = 'Spaghetti',
		text = {
			"Levels up the next",
			"{C:attention}#1#{} played {C:attention}poker hands{}"
		}
	},
	config = { extra = { uses = 8 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.uses } }
	end,
	blueprint_compat = true,
	rarity = 2,
	atlas = 'spaghetti',
	pos = { x = 0, y = 0 },
	cost = 7,
	calculate = function(self, card, context)
		if context.before then
			if not context.blueprint then
				card.ability.extra.uses = card.ability.extra.uses - 1
			end
			return { level_up = true, message = localize('k_level_up_ex') }
		end
		if context.final_scoring_step and not context.blueprint then
			if card.ability.extra.uses < 1 then
				card:start_dissolve({ G.C.RED }, nil, 1.6)
				return { message = localize('k_eaten_ex') }
			end
		end
	end,
}

SMODS.Joker {
	key = 'placeholder',
	loc_txt = {
		name = 'Placeholder',
		text = {
			"{X:mult,C:white}X#1#{} Mult",
			"Destroyed when Boss Blind defeated",
			"{C:inactive}(note to self: finish joker later){}"
		}
	},
	config = { extra = { xmult = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	blueprint_compat = true,
	rarity = 2,
	atlas = 'placeholder',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.end_of_round and G.GAME.blind.boss and not context.blueprint then
			card:remove_from_deck()
				card:start_dissolve({ G.C.RED }, nil, 1.6)
				return { message = "Final assets created!", colour = G.C.FILTER }
		end
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end
	end,
}

SMODS.Joker {
	key = 'primetime',
	loc_txt = {
		name = 'Prime Time',
		text = {
			"Each played {C:attention}2{}, {C:attention}3{}, {C:attention}5{}, or {C:attention}7{} gives",
			"{C:mult}+#1#{} Mult when scored"
		}
	},
	config = { extra = { mult = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	blueprint_compat = true,
	rarity = 1,
	atlas = 'default',
	pos = { x = 0, y = 0 },
	cost = 5,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == 2
			or context.other_card:get_id() == 3
			or context.other_card:get_id() == 5
			or context.other_card:get_id() == 7
			then
				return { mult = card.ability.extra.mult }
			end
		end
	end,
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
	atlas = 'refund',
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
		if context.end_of_round
		and G.GAME.blind.boss
		and context.main_eval
		and ((#G.consumeables.cards + G.GAME.consumeable_buffer) < G.consumeables.config.card_limit)
		and not G.GAME.used_vouchers['v_bvjokers_gamblingdisorder']
		then
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
			"{C:red}-$7{} per round"
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