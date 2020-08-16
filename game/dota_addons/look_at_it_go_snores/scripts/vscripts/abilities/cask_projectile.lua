cask_projectile = class({})

function cask_projectile:GetAbilityTextureName()
	return "witch_doctor_paralyzing_cask"
end

-------------------------------------------

function cask_projectile:OnSpellStart()
	if IsServer() then
		if self.abilities == nil then self.abilities = self:GetCaskAbilities() end
		
		EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Cast", self:GetCaster())
		local hTarget = self:GetCursorTarget()
		print(hTarget:GetUnitName())

		-- Parameters
		local bounces = 3
		
		local info = {
			EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
			Ability = self,
			iMoveSpeed = 1000,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			bDodgeable = false,
			bProvidesVision = false,
			ExtraData =
			{
				bounces = bounces,
				speed = 1000,
				bounce_delay = 0.3,
			}
		}

		ProjectileManager:CreateTrackingProjectile( info )
	end
end

function cask_projectile:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Bounce", hTarget)

	if hTarget then
		-- ability check one more time
		if self.abilities == nil then self.abilities = self:GetCaskAbilities() end
		self:Punish(hTarget)
	end
	if ExtraData.bounces > 0 then
		Timers:CreateTimer(ExtraData.bounce_delay, function()
			-- Finds all units in the area
			local enemies = FindUnitsInRadius(	self:GetCaster():GetTeamNumber(), 
												hTarget:GetAbsOrigin(), 
												nil, 
												FIND_UNITS_EVERYWHERE, 
												DOTA_UNIT_TARGET_TEAM_ENEMY, 
												DOTA_UNIT_TARGET_ALL, 
												DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
												0, 
												false)

			-- Go through the target tables, checking for the first one that isn't the same as the target
			local tJumpTargets = {}
			-- If the target is an enemy, bounce on an enemy.
			for _,unit in pairs(enemies) do
				if hTarget then
					if (unit ~= hTarget) and (not unit:IsOther()) then
						table.insert(tJumpTargets, unit)
					end
				end
			end

			if #tJumpTargets == 0 then
				-- End of spell
				return nil
			end
			
			-- yeet
			local index = math.random(#tJumpTargets)
			local projectile = {
				Target = tJumpTargets[index],
				Source = hTarget,
				Ability = self,
				EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
				bDodgable = false,
				bProvidesVision = false,
				iMoveSpeed = ExtraData.speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData =
				{
					bounces 			= ExtraData.bounces - 1,
					speed				= ExtraData.speed,
					bounce_delay 		= ExtraData.bounce_delay,
				}
			}
			ProjectileManager:CreateTrackingProjectile(projectile)
		end)
	else
		return nil
	end
end

function cask_projectile:GetCaskAbilities()
	local abilities = {}
	local caster = self:GetCaster()
	
	local bannedBehaviours = {
		DOTA_ABILITY_BEHAVIOR_HIDDEN,
		DOTA_ABILITY_BEHAVIOR_PASSIVE,
		DOTA_ABILITY_BEHAVIOR_TOGGLE,
		DOTA_ABILITY_BEHAVIOR_ATTACK,
	}
	
	for index = 0,15 do
		-- Ability in question
		local ability = caster:GetAbilityByIndex(index)
		
		-- Ability checkpoint
		if ability == nil then goto continue end
		if ability:GetAbilityName() == "cask_projectile" then goto continue end
		for _,behaviour in pairs(bannedBehaviours) do
			if bit.band( ability:GetBehavior(), behaviour ) == behaviour then goto continue end
		end
		
		-- Add that ability after checkpoint
		print(ability:GetAbilityName())
		table.insert(abilities, ability)
		
		-- Skip
		::continue::
	end
	
	return abilities
end

function cask_projectile:Punish(hDumbass)
	local caster = self:GetCaster()
	local ability = self.abilities[math.random(#self.abilities)]
	local notLevelled = false
	if ability:GetLevel() == 0 then
		ability:SetLevel(1)
		notLevelled = true
	end
	
	caster:SetCursorCastTarget(hDumbass)
	ability:OnSpellStart()
	
	if notLevelled then ability:SetLevel(0) end
end

--[[

does anyone know why this breaks the code?

		local projectile =
			{
				EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
				Ability = self,
				Target = hTarget,
				Source = self:GetCaster(),
				
				
				bDodgable = false,
				bProvidesVision = false,
				iMoveSpeed = speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData =
				{
					bounces = bounces,
					speed = 1000,
					bounce_delay = 0.3,
				}
			}
		ProjectileManager:CreateTrackingProjectile(projectile)
		--]]