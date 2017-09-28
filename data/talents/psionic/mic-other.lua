newTalent { --Dark Charge. negative vim regen, takes psi to sustain.
    name = "Dusk Bringer", short_name = "MIC_DARK_CHARGE",
    type = {"psionic/mic-other", 1},
    points = 1,
    no_npc_use = true,
    mode = "sustained", no_sustain_autoreset = true,
    no_energy = true,
    no_npc_use = true,
    cooldown = 30,
    sustain_psi = 30,
    drain_vim = 12, --drain_xxx is a N I C E thing to use
    radius = 2, --i honestly have no clue why i did this??? used to be getRadius but not a function
    tactical = {ATTACKAREA = {DARKNESS = 2}},
    target = function(self, t)
        if self.growthTimer == nil then self.growthTimer = 0 end
        return {type = "ball", range = 0, radius = math.min(t.radius + self.growthTimer, 8), selffire = false} --max radius of 8 which is pretty huge
    end,
    activate = function(self, t)
        self.growthTimer = 1
        return {}
    end,
    deactivate = function(self, t, p)
        local dam = self:mindCrit(self:callTalent(self.T_MIC_DARK_ANGER, "getDamage")) + self:callTalent(self.T_MIC_DARK_ANGER, "getDamage")*0.2*math.min(self.growthTimer, self:callTalent(self.T_MIC_DARK_ANGER, "getMaxTurnCharge")) --Might need diminishing returns.
        local tg = self:getTalentTarget(t)
        self.growthTimer = nil
        self:project(tg, self.x, self.y, DamageType.DARKNESS, dam)
        if core.shader.active() then
            game.level.map:particleEmitter(self.x, self.y, tg.radius, "starfall", {radius=tg.radius, tx=self.x, ty=self.y})
        else
            game.level.map:particleEmitter(self.x, self.y, tg.radius, "circle", {oversize=0.7, a=60, limit_life=16, appear=8, speed=-0.5, img="darkness_celestial_circle", radius=tg.radius})
        end
        return true
    end,
    iconOverlay = function(self, t, p) --For telling how many charges, shameless copy pasted from embers
        local val = self.growthTimer or 0
        if val <= 0 then return "" end
        local fnt = "buff_font_small"
        return tostring(math.ceil(val)), fnt
    end,
    callbackOnActBase = function(self, t)
        if self:getVim() < 12 then self:forceUseTalent(self.T_MIC_DARK_CHARGE, {ignore_energy = true}) return end
        local p = self:isTalentActive(t.id) if not p then return end
		self.growthTimer = math.min(self.growthTimer + 1, 6) --make sure growth timer doesnt exceed what i want it to
    end,
    info = function(self, t)
        local maxTurn = self:callTalent(self.T_MIC_DARK_ANGER, "getMaxTurnCharge")
        local dam = self:callTalent(self.T_MIC_DARK_ANGER, "getDamage")
        return([[Draw the latent darkness within you, charging for a maximum of %d turns. Upon deactivation, the darkness that you collected will explode outward in a radius of 2 minimum or 8 maximum, depending directly on how long you charged the talent. The explosion will deal %0.1f darkness damage, increased by 20%% for every turn that you had charged up to the max turn limit.
While charging, the radius will always increase up to 8, but the damage will stop increasing once the max turn threshold is passed.
The damage will scale with both your #GOLD#mindpower#WHITE# and #VIOLET#spellpower#WHITE#. This talent utilizes mind critical strike chance.
#RED#While sustained, this talent will drain 12 vim every turn.#RED#]]):format(maxTurn, damDesc(self, DamageType.DARKNESS, dam))
    end
}
