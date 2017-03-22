--****************************************************************************
--**
--**  File     :  /lua/sim/buff.lua
--**
--**  Copyright � 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- The Unit's BuffTable for applied buffs looks like this:
--
-- Unit.Buffs = {
--    Affects = {
--        <AffectType (Regen/MaxHealth/etc)> = {
--            BuffName = {
--                Count = i,
--                Add = X,
--                Mult = X,
--            }
--        }
--    }
--    BuffTable = {
--        <BuffType (LEVEL/CATEGORY)> = {
--            BuffName = {
--                Count = i,
--                Trash = trashbag,
--            }
--        }
--    }
--
--Function to apply a buff to a unit.
--This function is a fire-and-forget.  Apply this and it'll be applied over time if there is a duration.
--
--Mod code originally written by Eni
--Modified by Eni, Ghaleon(?), Lewnatics(?), Stormrideron and SATA24

function ApplyBuff(unit, buffName, instigator)
    if unit:IsDead() then
        return
    end
    --LOG ('buf.apply:',buffName)
    instigator = instigator or unit

    --buff = table of buff data
    local def = Buffs[buffName]
    --LOG('*BUFF: FullBuffTable: ', repr(Buffs))
    --LOG('*BUFF: BuffsTable: ', repr(def))
    if not def then
        error("*ERROR: Tried to add a buff that doesn\'t exist! Name: ".. buffName, 2)
        return
    end

    if def.EntityCategory then
        local cat = ParseEntityCategory(def.EntityCategory)
        if not EntityCategoryContains(cat, unit) then
            return
        end
    end

    if def.BuffCheckFunction then
        if not def:BuffCheckFunction(unit) then
            --LOG('return buff check')
            return
        end
    end

    local ubt = unit.Buffs.BuffTable

    if def.MinLevel and def.MinLevel > unit.VeteranLevel then return end

    if def.MaxLevel and def.MaxLevel < unit.VeteranLevel then return end


    if def.Stacks == 'REPLACE' and ubt[def.BuffType] then
        for key, bufftbl in unit.Buffs.BuffTable[def.BuffType] do
            RemoveBuff(unit, key, true)
        end
    end


    --If add this buff to the list of buffs the unit has becareful of stacking buffs.
    if not ubt[def.BuffType] then
        ubt[def.BuffType] = {}
    end

    if def.Stacks == 'IGNORE' and ubt[def.BuffType] and table.getsize(ubt[def.BuffType]) > 0 then
        --LOG('return Ignore')
        return
    end

    local data = ubt[def.BuffType][buffName]
    if not data then
        -- This is a new buff (as opposed to an additional one being stacked)
        data = {
            Count = 1,
            Trash = TrashBag(),
            BuffName = buffName,
        }
        ubt[def.BuffType][buffName] = data
    else
        -- This buff is already on the unit so stack another by incrementing the
        -- counts. data.Count is how many times the buff has been applied
        data.Count = data.Count + 1

    end

    local uaffects = unit.Buffs.Affects
    if def.Affects then
        for k,v in def.Affects do
            -- Don't save off 'instant' type affects like health and energy
            if k != 'Health' and k != 'Energy' then
                if not uaffects[k] then
                    uaffects[k] = {}
                end

                if not uaffects[k][buffName] then
                    -- This is a new affect.
                    local affectdata = {
                        BuffName = buffName,
                        Count = 1,
                    }
                    for buffkey, buffval in v do
                        affectdata[buffkey] = buffval
                    end
                    uaffects[k][buffName] = affectdata
                else
                    -- This affect is already there, increment the count
                    uaffects[k][buffName].Count = uaffects[k][buffName].Count + 1
                end
            end
        end
    end

    if def.Duration and def.Duration > 0 then
        local thread = ForkThread(BuffWorkThread, unit, buffName, instigator)
        unit.Trash:Add(thread)
        data.Trash:Add(thread)
    end

    PlayBuffEffect(unit, buffName, data.Trash)

    ubt[def.BuffType][buffName] = data

    if def.OnApplyBuff then
        def:OnApplyBuff(unit, instigator)
    end

    BuffAffectUnit(unit, buffName, instigator, false)
end

function BuffWorkThread(unit, buffName, instigator)

    local buffTable = Buffs[buffName]

    local totPulses = buffTable.DurationPulse

    if not totPulses then
        WaitSeconds(buffTable.Duration)
    else
        local pulse = 0
        local pulseTime = buffTable.Duration / totPulses

        while pulse <= totPulses and not unit:IsDead() do

            WaitSeconds(pulseTime)
            BuffAffectUnit(unit, buffName, instigator, false)
            pulse = pulse + 1

        end
    end

    RemoveBuff(unit, buffName)
end

function BuffAffectUnit(unit, buffName, instigator, afterRemove)

    local buffDef = Buffs[buffName]

    local buffAffects = buffDef.Affects

    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end

    for atype, vals in buffAffects do

        if atype == 'Health' then

            --Note: With health we don't actually look at the unit's table because it's an instant happening.  We don't want to overcalculate something as pliable as health.

            local health = unit:GetHealth()
            local val = ((buffAffects.Health.Add or 0) + health) * (buffAffects.Health.Mult or 1)
            local healthadj = val - health

            if healthadj < 0 then
                -- fixme: DoTakeDamage shouldn't be called directly
                local data = {
                    Instigator = instigator,
                    Amount = -1 * healthadj,
                    Type = buffDef.DamageType or 'Spell',
                    Vector = VDiff(instigator:GetPosition(), unit:GetPosition()),
                }
                unit:DoTakeDamage(data)
            else
                unit:AdjustHealth(instigator, healthadj)

                --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed health to ', repr(val))
            end

        elseif atype == 'MaxHealth' then

            --local unitbphealth = unit:GetBlueprint().Defense.MaxHealth or 1
            if not unit.basehp then unit.basehp = unit:GetMaxHealth() end

            local oldmax = unit:GetMaxHealth()
            local oldcurrent = unit:GetHealth()

            local val = BuffCalculate(unit, buffName, 'MaxHealth', unit.basehp)
            val = math.ceil(val)

            unit:SetMaxHealth(val)
            unit:SetHealth(unit, val * oldcurrent/oldmax)
            --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max health to ', repr(val))

        elseif atype == 'Regen' or atype == 'RegenPercent' then

            local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
            local val = BuffCalculate(unit, buffName, 'Regen', bpregn)
            local regenperc, bool, exists = BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth())
            if exists then
                val = val +  regenperc
            end
            unit:SetRegenRate(val)
            unit.Sync.RegenRate = val

            --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed regen rate to ', repr(val))
--         elseif atype == 'RegenPercent' then
--
--             local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
--             local val = BuffCalculate(unit, buffName, 'Regen', bpregn)
--             LOG(val)
--             local val = val + BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth())
--             unit:SetRegenRate(val)
--             unit.Sync.RegenRate = val
--             LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed regen rate to ', repr(val))
--            local val = false

--             if afterRemove then
--                 --Restore normal regen value plus buffs so I don't break stuff. Love, Robert
--                 local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
--                 val = BuffCalculate(unit, nil, 'Regen', bpregn)
--             else
--                 --Buff this sucka
--                 val = BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth())
--             end
--
--             unit:SetRegenRate(val)
--             unit.Sync.RegenRate = val

        elseif atype == 'StorageEnergy' then
            local val = BuffCalculate(unit, buffName, 'StorageEnergy', unit:GetBlueprint().StorageEnergy or 0)
            unit:SetStat('StorageEnergy', val)

        elseif atype == 'StorageMass' then
            local val = BuffCalculate(unit, buffName, 'StorageMass', unit:GetBlueprint().StorageMass or 0)
            unit:SetStat('StorageMass', val)

        elseif atype == 'ShieldHP' then

            local shield = unit:GetShield()
            if not shield then return end

            local oldShieldmax = shield:GetMaxHealth()
            local oldShieldcurrent = shield:GetHealth()

            local ratio = shield:GetMaxHealth() / shield:GetHealth()
            local val = BuffCalculate(unit, buffName, atype, shield.spec.ShieldMaxHealth)
            val = math.ceil(val)
            shield:SetMaxHealth(val)
           -- shield:SetHealth(shield,ratio*val)
            shield:SetHealth(shield, val * oldShieldcurrent/oldShieldmax)
            unit.Sync.ShieldMaxHp = val
            --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max shieldhealth to ', repr(val))

         elseif atype == 'ShieldRegen' then

            local shield = unit:GetShield()
            if not shield then return end
            --local spec = shield:GetSpec()
            local valregen = shield.spec.ShieldRegenRate
            --local valrecharge = spec.ShieldRechargeTime
            --local valrechargeenergy = spec.ShieldEnergyDrainRechargeTime
            valregen = BuffCalculate(unit, buffName, atype, valregen)
            unit.Sync.ShieldRegen = valregen
            shield:SetShieldRegenRate(valregen)
            --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed shieldregen to ', repr(valregen))
			
        elseif atype == 'Damage' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if wep.Label != 'DeathWeapon' and wep.Label != 'DeathImpact' then
                    if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                    local wepbp = wep:GetBlueprint()
                        local val = BuffCalculate(unit, buffName, atype, wepbp.Damage)
                        if val >= ( math.abs(val) + 0.5 ) then
                            val = math.ceil(val)
                        else
                            val = math.floor(val)
                        end
                        wep.Damage = val
                        --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage to ', repr(val))

                        if wepbp.NukeOuterRingDamage and wepbp.NukeInnerRingDamage then
                            unit.NukeOuterRingDamage = BuffCalculate(unit, buffName, atype, wepbp.NukeOuterRingDamage)
                            unit.NukeInnerRingDamage = BuffCalculate(unit, buffName, atype, wepbp.Damage)
                        end
                    end
                end
            end

        elseif atype == 'DamageRadius' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                    local val = BuffCalculate(unit, buffName, atype, wepbp.DamageRadius)
                    wep.DamageRadius = val
                    --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed AoE to ', repr(val))

                    if wepbp.NukeOuterRingRadius and wepbp.NukeInnerRingRadius then
                        unit.NukeOuterRingRadius = (BuffCalculate(unit, buffName, atype, wepbp.NukeOuterRingRadius)+wepbp.NukeInnerRingRadius)/2
                        unit.NukeInnerRingRadius = (BuffCalculate(unit, buffName, atype, wepbp.NukeInnerRingRadius)+wepbp.NukeInnerRingRadius)/2
                    end
                end
            end

        elseif atype == 'MaxRadius' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                    local val = BuffCalculate(unit, buffName, atype, wepbp.MaxRadius)
                    --LOG(wepbp.Label .. ' newRange:' .. val)
                    wep:ChangeMaxRadius(val)
                    wep.rangeMod = val / wepbp.MaxRadius
                end

                --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max radius to ', repr(val))
            end

        elseif atype == 'RateOfFireBuf' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                    local val = BuffCalculate(unit, buffName, atype, wepbp.RateOfFire)
                    --LOG(wepbp.Label .. ' newRoF:' .. val)
                    wep.bufRoF = val
                    wep:ChangeRateOfFire(val/wep.adjRoF)
                end
            end

        elseif atype == 'MoveMult' then
            local UnitType = unit:GetBlueprint().Categories
            --LOG(repr(UnitType))
            if not table.find(UnitType,'AIR') then
                local val = BuffCalculate(unit, buffName, 'MoveMult', 1)
                unit:SetSpeedMult(val)
                unit:SetAccMult(val)
                unit:SetTurnMult(val)
                --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed speed/accel/turn mult to ', repr(val))
            end

        elseif atype == 'Stun' and not afterRemove then

            unit:SetStunned(buffDef.Duration or 1, instigator)

            --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed stunned for ', repr(buffDef.Duration or 1))

            if unit.Anims then
                for k, manip in unit.Anims do
                    manip:SetRate(0)
                end
            end

        elseif atype == 'WeaponsEnable' then

            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local val, bool = BuffCalculate(unit, buffName, 'WeaponsEnable', 0, true)

                wep:SetWeaponEnabled(bool)
            end

        elseif atype == 'VisionRadius' then
            local intelbp = unit:GetBlueprint().Intel
            local val
            if (intelbp.MaxVisionRadius and intelbp.MinVisionRadius) then
                val = BuffCalculate(unit, buffName, 'VisionRadius', intelbp.MaxVisionRadius or 0)
                unit.MaxVisionRadius = val
                unit:SetIntelRadius('Vision', val)

                val = BuffCalculate(unit, buffName, 'VisionRadius', intelbp.MinVisionRadius or 0)
                unit.MinVisionRadius = val
            else
                val = BuffCalculate(unit, buffName, 'VisionRadius', intelbp.VisionRadius or 0)
                unit:SetIntelRadius('Vision', val)
            end
            --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed Vison to ', repr(val))

        elseif atype == 'RadarRadius' then
            local val = BuffCalculate(unit, buffName, 'RadarRadius', unit:GetBlueprint().Intel.RadarRadius or 0)

            if val <= 0 then
                unit:DisableIntel('Radar')
                return
            end


            if not unit:IsIntelEnabled('Radar') then
                unit:InitIntel(unit:GetArmy(),'Radar', val)
                unit:EnableIntel('Radar')
            else
                unit:SetIntelRadius('Radar', val)
                unit:EnableIntel('Radar')
            end


        elseif atype == 'OmniRadius' then
            local val = BuffCalculate(unit, buffName, 'OmniRadius', unit:GetBlueprint().Intel.OmniRadius or 0)

            if val <= 0 then
                unit:DisableIntel('Omni')
                return
            end


             if not unit:IsIntelEnabled('Omni') then
                unit:InitIntel(unit:GetArmy(),'Omni', val)
                unit:EnableIntel('Omni')
            else
                unit:SetIntelRadius('Omni', val)
                unit:EnableIntel('Omni')
            end

        elseif atype == 'BuildRate' then
            local val = BuffCalculate(unit, buffName, 'BuildRate', unit:GetBlueprint().Economy.BuildRate or 1)
            unit:SetBuildRate( val )

        elseif atype == 'EnergyProductionBuf' then
            local val = BuffCalculate(unit, buffName, 'EnergyProductionBuf', unit:GetBlueprint().Economy.ProductionPerSecondEnergy or 0)
            unit.EnergyProdMod = val
            unit:UpdateProductionValues()

        elseif atype == 'MassProductionBuf' then
            local val = BuffCalculate(unit, buffName, 'MassProductionBuf', unit:GetBlueprint().Economy.ProductionPerSecondMass or 0)
            unit.MassProdMod = val
            unit:UpdateProductionValues()

        -------- ADJACENCY BELOW --------
        elseif atype == 'EnergyActive' then
            local val = BuffCalculate(unit, buffName, 'EnergyActive', 1)
            unit.EnergyBuildAdjMod = val
            unit:UpdateConsumptionValues()
            --LOG('*BUFF: EnergyActive = ' ..  val)

        elseif atype == 'MassActive' then
            local val = BuffCalculate(unit, buffName, 'MassActive', 1)
            unit.MassBuildAdjMod = val
            unit:UpdateConsumptionValues()
            --LOG('*BUFF: MassActive = ' ..  val)

        elseif atype == 'EnergyMaintenance' then
            local val = BuffCalculate(unit, buffName, 'EnergyMaintenance', 1)
            unit.EnergyMaintAdjMod = val
            unit:UpdateConsumptionValues()
            --LOG('*BUFF: EnergyMaintenance = ' ..  val)

        elseif atype == 'MassMaintenance' then
            local val = BuffCalculate(unit, buffName, 'MassMaintenance', 1)
            unit.MassMaintAdjMod = val
            unit:UpdateConsumptionValues()
            --LOG('*BUFF: MassMaintenance = ' ..  val)

        elseif atype == 'EnergyProduction' then
            local val = BuffCalculate(unit, buffName, 'EnergyProduction', 1)
            unit.EnergyProdAdjMod = val
            unit:UpdateProductionValues()
            --LOG('*BUFF: EnergyProduction = ' .. val)

        elseif atype == 'MassProduction' then
            local val = BuffCalculate(unit, buffName, 'MassProduction', 1)
            unit.MassProdAdjMod = val
            unit:UpdateProductionValues()
            --LOG('*BUFF: MassProduction = ' .. val)

        elseif atype == 'EnergyWeapon' then
            local val = BuffCalculate(unit, buffName, 'EnergyWeapon', 1)
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                if wep:WeaponUsesEnergy() then
                    wep.AdjEnergyMod = val
                end
            end
            --LOG('*BUFF: EnergyWeapon = ' ..  val)

         elseif atype == 'RateOfFire' then
            for i = 1, unit:GetWeaponCount() do
                 local wep = unit:GetWeapon(i)
                 local wepbp = wep:GetBlueprint()
                 local weprof = wepbp.RateOfFire

                 -- Set new rate of fire based on blueprint rate of fire.=
                 local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)

                 local delay = 1 / wepbp.RateOfFire
                 wep.adjRoF= val
                 wep:ChangeRateOfFire(wep.bufRoF/wep.adjRoF)
                 --wep:ChangeRateOfFire( 1 / ( val * delay ) )
                --LOG(string.format('*BUFF: RateOfFire = %f (val:%f)' , 1 / ( val * delay ),val))
            end



--   CLOAKING is a can of worms.  Revisit later.
--        elseif atype == 'Cloak' then
--
--            local val, bool = BuffCalculate(unit, buffName, 'Cloak', 0)
--
--            if unit:IsIntelEnabled('Cloak') then
--
--                if bool then
--                    unit:InitIntel(unit:GetArmy(), 'Cloak')
--                    unit:SetRadius('Cloak')
--                    unit:EnableIntel('Cloak')
--
--                elseif not bool then
--                    unit:DisableIntel('Cloak')
--                end
--
--            end

        elseif atype != 'Stun' then
            WARN("*WARNING: Tried to apply a buff with an unknown affect type of " .. atype .. " for buff " .. buffName)
        end
    end
end

--BuffCalculate(unit, buffName, 'RateOfFire', wepbp.RateOfFire)

--Calculates the buff from all the buffs of the same time the unit has.
function BuffCalculate(unit, buffName, affectType, initialVal, initialBool) --It seems like the argument "buffname" is not used in this function. Perhaps we should delete it from the function definition
                                                                            --and everywhere BuffCalculate() is called, to perhaps speed things up a bit? --SATA24
    --Add all the
    local adds = 0
    local mults = 1.0
    local exists = false
    local divs = 1.0
    local bool = initialBool or false

    local highestCeil = false
    local lowestFloor = false


    if not unit.Buffs.Affects[affectType] then
        --LOG(affectType .. ' is missing!')
        --LOG(repr(unit.Buffs.Affects))
        return initialVal, bool, exists
    end

    for k, v in unit.Buffs.Affects[affectType] do
        exists = true

        if v.Add and v.Add != 0 then
            adds = adds + (v.Add * v.Count)
        end

        if v.Mult then
            for i=1,v.Count do
                if v.Mult >= 1 then
                    mults = mults + v.Mult - 1
                else                            --Here, when calculating the accumulated effect of the "mult" and "div" values of the specified effect on the current unit, why are the mults ADDED, yet 
                    divs = divs * v.Mult        --the DIVS are multiplied? IE: for a given effect, v.Mult = 1.01, or a 1% gain, and count = 10, and thus MULTS = (1.0 + (10 * (1.01 - 1)), which equals 1.1,
                end                             --or a 10% buff, or in other words, 100% * 1.1buff. MULTS is not v.Mult ^ count, but rather ((v.Mult - 1) * count) + 1. The value of MULTS increases linearly
            end                                 --with count. However, if v.Mults = 0.99, or a 1% loss, and count = 10, then DIVS = v.Mult ^ count, and thus, unlike for a positive value of v.Mults, DIVS
        end                                     --decreases logarithmically, not linearly. Or, in other words, the amount of positive bonus, or increase in value, is based on the ORIGINAL blueprint stat,
                                                --but the amount of negative bonus, or decrease in value, is based on the CURRENT unit stat, not the original before any TvG buffs. --SATA24
        if not v.Bool then
            bool = false
        else
            bool = true
        end

        if v.Ceil and (not highestCeil or highestCeil < v.Ceil) then
            highestCeil = v.Ceil
        end

        if v.Floor and (not lowestFloor or lowestFloor > v.Floor) then
            lowestFloor = v.Floor
        end
    end

--     if not domult then
--         mults = 0
--         divs = 0
--     end

    --Adds are calculated first, then the mults.  May want to expand that later.
    local returnVal = (initialVal + adds) * mults * divs
    if lowestFloor and returnVal < lowestFloor then returnVal = lowestFloor end

    if highestCeil and returnVal > highestCeil then returnVal = highestCeil end


    --LOG('*BUFFCALC: Type:' .. affectType ..' initialVal:' ..  initialVal .. ' adds:' .. adds .. ' mults:' .. mults .. ' returnVal:' .. returnVal)
    return returnVal, bool, exists
end



--Removes buffs
function RemoveBuff(unit, buffName, removeAllCounts, instigator)

    local def = Buffs[buffName]
    --LOG('BUFF to remove :: ',repr (def))
    local unitBuff = unit.Buffs.BuffTable[def.BuffType][buffName]

    for atype,_ in def.Affects do
        local list = unit.Buffs.Affects[atype]
        if list and list[buffName] then
            -- If we're removing all buffs of this name, only remove as
            -- many affects as there are buffs since other buffs may have
            -- added these same affects.
            if removeAllCounts then
                list[buffName].Count = list[buffName].Count - unitBuff.Count
            else
                list[buffName].Count = list[buffName].Count - 1
            end

            if list[buffName].Count <= 0 then
                list[buffName] = nil
            end
        end
    end


    if not unitBuff.Count then
        local stg = "*WARNING: BUFF: unitBuff.Count is nil.  Unit: "..unit:GetUnitId().." Buff Name: ".. buffName.." Unit BuffTable: ", repr(unitBuff)
        error(stg, 2)
    else
        unitBuff.Count = unitBuff.Count - 1
    end

    if removeAllCounts or unitBuff.Count <= 0 then
        -- unit:PlayEffect('RemoveBuff', buffName)
        unitBuff.Trash:Destroy()
        unit.Buffs.BuffTable[def.BuffType][buffName] = nil
    end

    if def.OnBuffRemove then
        def:OnBuffRemove(unit, instigator)
    end

    -- FIXME: This doesn't work because the magic sync table doesn't detect
    -- the change. Need to give all child tables magic meta tables too.
    if def.Icon then
        -- If the user layer was displaying an icon, remove it from the sync table
        local newTable = unit.Sync.Buffs
        table.removeByValue(newTable,buffName)
        unit.Sync.Buffs = table.copy(newTable)
    end

    BuffAffectUnit(unit, buffName, unit, true)

    --LOG('*BUFF: Removed ', buffName)
end

function HasBuff(unit, buffName)
    local def = Buffs[buffName]
    if not def then
        return false
    end
    local bonu = unit.Buffs.BuffTable[def.BuffType][buffName]
    if bonu then
        return true
    end
    return false
end

function PlayBuffEffect(unit, buffName, trsh)

    local def = Buffs[buffName]
    if not def.Effects then
        return
    end

    for k, fx in def.Effects do
        local bufffx = CreateAttachedEmitter(unit, 0, unit:GetArmy(), fx)
        if def.EffectsScale then
            bufffx:ScaleEmitter(def.EffectsScale)
        end
        trsh:Add(bufffx)
        unit.TrashOnKilled:Add(bufffx)
    end
end

--
-- DEBUG FUNCTIONS
--
_G.PrintBuffs = function()
    local selection = DebugGetSelection()
    for k,unit in selection do
        if unit.Buffs then
            LOG('Buffs = ', repr(unit.Buffs))
        end
    end
end