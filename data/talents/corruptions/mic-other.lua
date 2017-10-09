newTalent { --Dark Charge. negative vim regen, takes psi to sustain.
    name = "Rebalance", short_name = "MIC_REBALANCE",
    type = {"corruption/mic-other", 1},
    points = 1,
    no_npc_use = true,
    cooldown = self:callTalent(self.T_MIC_BALANCE, "reCooldown"),
    target = function(self, t) end,
    action = function(self, t)
        local dur = self:callTalent(self.T_MIC_BALANCE, "reGetDuration")
        local psiPercent = self:getPsi()/self.max_psi --grabbing percentages for readability and ease of use
        local vimPercent = self:getVim()/self.max_vim
        local tg = {type="hit", range = range}
        local x,y,target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        if psiPercent < vimPercent then
            self.vim = self.max_vim * psiPercent
            target:setEffect(target.EFF_SPELLSHOCKED, dur, {apply_power = 100})
        end
        else 
            self.psi = self.max_psi * vimPercent
            target:setEffect(target.EFF_BRAINLOCKED, dur, {apply_power = 100})

        end
    end,
    info = function(self, t)
        local dur = self:callTalent(self.T_MIC_BALANCE, "reGetDuration")
        return([[Bring the forces within you closer in balance.
If your #BROWN#vim pool#WHITE# is percentually greater than your #BLUE#psi pool#WHITE#, your #BROWN#vim#WHITE# pool will be set to the same percent as your #BLUE#psi pool#WHITE# and you will apply spellshock (lowers all resistance by 20%%) for %d turns to your target.
If your #BLUE#psi pool#WHITE# is percentually greater than your #BROWN#vim pool#WHITE#, your #BLUE#psi pool#WHITE# will be set to the same percent as your #BROWN#vim pool#WHITE# and you will apply brainlock (prevents talents from cooling down) for %d turns to your target.
]]):format(dur, dur)
    end,
}
