DECAY_TIME=5

brutality = {
	currentBrutality=0,
	maxBrutality=100,
	decaying=false,
	decayTimer=0,
	tier0={
		minimum=0,
		maximum=24,
		decayRate=0.5,
		damageBoost=0,
		xKnockbackBoost=0,
		yKnockbackBoost=0,
		hitboxBoost=0,
		sequenceAttackDelay=0,
		defenseBoost=0,
		speedBoost=0,
		lifeSteal=0
	},
	tier1={
		minimum=25,
		maximum=49,
		decayRate=3,
		damageBoost=5,
		xKnockbackBoost=5,
		yKnockbackBoost=5,
		hitboxBoost=10,
		sequenceAttackDelay=0,
		defenseBoost=1,
		speedBoost=10,
		lifeSteal=0
	},
	tier2={
		minimum=50,
		maximum=74,
		decayRate=5,
		damageBoost=10,
		xKnockbackBoost=10,
		yKnockbackBoost=10,
		hitboxBoost=20,
		sequenceAttackDelay=0,
		defenseBoost=2,
		speedBoost=20,
		lifeSteal=1
	},
	tier3={
		minimum=75,
		maximum=100,
		decayRate=15,
		damageBoost=15,
		xKnockbackBoost=15,
		yKnockbackBoost=15,
		hitboxBoost=30,
		sequenceAttackDelay=0,
		defenseBoost=3,
		speedBoost=30,
		lifeSteal=2
	}
}

function brutality:addBrutality(amount,multiplier)
	self.currentBrutality=self.currentBrutality+(amount*multiplier)
	brutality:resetDecayTimer()
end

function brutality:resetDecayTimer()
	self.decayTimer=DECAY_TIME
	self.decaying=False
end

function brutality:getCurrentTier()
	if self.currentBrutality>self.tier3.minimum then
		return self.tier3
	elseif self.currentBrutality>self.tier2.minimum then
		return self.tier2
	elseif self.currentBrutality>self.tier1.minimum then
		return self.tier1
	else
		return self.tier0
	end
end

function brutality:update(dt)
	if self.currentBrutality>100 then
		self.currentBrutality=100
	end
	if self.decaying then
		self.currentBrutality=self.currentBrutality-(brutality:getCurrentTier().decayRate*dt)
	else
		self.decayTimer=self.decayTimer-dt
		if self.decayTimer<=0 then
			self.decaying=true
		end
	end
	if self.currentBrutality<0 then
		self.currentBrutality=0
	end
end

