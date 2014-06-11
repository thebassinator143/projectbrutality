

brutality = {
	currentBrutality=0,
	maxBrutality=100,
	tier0={
		minimum=0,
		maximum=24,
		decayRate=1,
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
	print(self)
	brutality.currentBrutality=brutality.currentBrutality+(self*amount)
end

function brutality:getCurrentTier()
	if brutality.currentBrutality>brutality.tier3.minimum then
		return brutality.tier3
	elseif brutality.currentBrutality>brutality.tier2.minimum then
		return brutality.tier2
	elseif brutality.currentBrutality>brutality.tier1.minimum then
		return brutality.tier1
	else
		return brutality.tier0
	end
end

function brutality:update(dt)
	if brutality.currentBrutality>100 then
		brutality.currentBrutality=100
	end
	brutality.currentBrutality=brutality.currentBrutality-(brutality.getCurrentTier().decayRate*self)
	if brutality.currentBrutality<0 then
		brutality.currentBrutality=0
	end
end

