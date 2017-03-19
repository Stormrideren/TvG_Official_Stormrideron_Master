--****************************************************************************
--**
--**  File     :  /lua/unit.lua
--**  Author(s):  John Comes, David Tomandl, Gordon Duclos
--**
--**  Summary  : The Unit lua module
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local oldUnit=Unit
Unit = Class(oldUnit) {

    OnCreate = function(self)
        oldUnit.OnCreate(self)
        local bp = self:GetBlueprint()
        if bp.Economy.XPperLevel then -- just to make certain this is not called
            --for units which do not need it
            self.XPnextLevel = bp.Economy.XPperLevel
            self.xp = 0
--            self.Txp = 0
            self.XpModfierInCombat = 3
            self.XpModfierOutOfCombat = 1
            self.XpModfierCombat = 1
            self.XpModfier = 0.25
            self.XpModfierBuffed = 0.5
            self.XpModfierOld = 0.25
            self.Waittime = bp.Economy.xpTimeStep * 0.002
            self.VeteranLevel = 1
            self.LevelProgress = 1
            self.Sync.LevelProgress = self.LevelProgress
            self.Sync.RegenRate = bp.Defense.RegenRate
        end
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        if self:GetBlueprint().Economy.xpTimeStep then
            self:ForkThread(self.XPOverTime)
            self.XpModfier = self.XpModfierOld
        end
        oldUnit.OnStopBeingBuilt(self, builder, layer)
    end,

--testcode
    --Economy-this is for everything which requires energy to be run: intel, shields etc
    SetMaintenanceConsumptionActive = function(self)
        if self.XPOverTimeThread then KillThread(self.XPOverTimeThread) end
        self.XPOverTimeThread = ForkThread(self.XPOverTime, self)
        oldUnit.SetMaintenanceConsumptionActive(self)
    end,

    SetMaintenanceConsumptionInactive = function(self)
        KillThread(self.XPOverTimeThread)
        oldUnit.SetMaintenanceConsumptionInactive(self)
    end,
--testcode end

    XPOverTime = function(self)
        if not self:GetBlueprint().Economy.xpTimeStep then return end -- sanity check
        --local waittime = (self:GetBlueprint().Economy.xpTimeStep + self.VeteranLevel)* 0.01

       -- WaitSeconds(self.Waittime + (self.VeteranLevel * 0.5 - 1) * 0.05 ) --wait longer to improve performance
        while not self:IsDead() do
            self:AddXP(self.XPnextLevel* self.XpModfier * self.XpModfierCombat)
            WaitSeconds(self.Waittime + (self.VeteranLevel * 0.5 - 1) * 0.01 )
        end
    end,

    startBuildXPThread = function(self)
        local levelPerSecond = self:GetBlueprint().Economy.BuildXPLevelpSecond
        if not levelPerSecond then return end
        WaitSeconds(1)--when you build THAT fast you do not need any xp, another performance tweak
        while not self:IsDead() do
            self.XpModfier = self.XpModfierBuffed
            self:AddXP(self.XPnextLevel/(1 + self.VeteranLevel*0.3) + 3 ) --adjusted again, removed ceil, performance
            WaitSeconds(59) -- to reduce the performance impact
        end
    end,


--testcode


    -- reworked builder xp to include upgrades and allow for pausing
    -- launchers are still unaffected
    -- inconsistent gains for commanders.
    SetActiveConsumptionActive = function(self)
   		self.XpModfier = self.XpModfierBuffed
        if self.BuildXPThread then 
        	KillThread(self.BuildXPThread) 
        end
        self.BuildXPThread = ForkThread(self.startBuildXPThread, self)
        oldUnit.SetActiveConsumptionActive(self)
    end,

    SetActiveConsumptionInactive = function(self)
        self.XpModfier = self.XpModfierOld
        KillThread(self.BuildXPThread)
        if self.BuildXPThread then KillThread(self.BuildXPThread) end
        oldUnit.SetActiveConsumptionInactive(self)
    end,

    OnProductionPaused = function(self)
        KillThread(self.BuildXPThread)
        if self.BuildXPThread then KillThread(self.BuildXPThread) end
        oldUnit.OnProductionPaused(self)
    end,

    OnProductionUnpaused = function(self)
        if self.BuildXPThread then KillThread(self.BuildXPThread) end
        self.BuildXPThread = ForkThread(self.startBuildXPThread, self)
        oldUnit.OnProductionUnpaused(self)
    end,

--end testcode


--    OnStartBuild = function(self, unitBeingBuilt, order)
--        --LOG('unit:OnStartBuild')
--        self.BuildXPThread = ForkThread(self.startBuildXPThread, self)
--        oldUnit.OnStartBuild(self, unitBeingBuilt, order)
--    end,
--
    OnStopBuild = function(self, unitBeingBuilt)
        self.XpModfier = self.XpModfierOld
        --LOG('unit:OnStopBuild')
        KillThread(self.BuildXPThread)
        oldUnit.OnStopBuild(self, unitBeingBuilt)
    end,

    OnFailedToBuild = function(self)
        self.XpModfier = self.XpModfierOld
        --LOG('unit:OnFailedToBuild')
        KillThread(self.BuildXPThread)
        oldUnit.OnFailedToBuild(self)
    end,


    ------------------------------------------------------------------------------------- VETERANCY
    ---------------------------------------------------------------------------------

    -- use this to go through the AddKills function rather than directly setting veterancy
    SetVeterancy = function(self, veteranLevel)
        veteranLevel = veteranLevel or 0
        if veteranLevel <= 5 then
            return oldUnit.SetVeterancy(self, veteranLevel)
        else
            local bp = self:GetBlueprint()-- change suggested by Gilbot
            if bp.Veteran['Level'..veteranLevel] then
                self:AddKills(bp.Veteran['Level'..veteranLevel])
            else
                WARN('SetVeterancy called on ' .. self:GetUnitId()
                .. ' with veteran level ' .. veteranLevel
                .. ' which was not defined in its BP file. '
                .. ' Veterancy level has not been set.'
                )
            end
        end
    end,

    --Check to see if we should veteran up.
    CheckVeteranLevel = function(self)
        if not self.XPnextLevel then return end
        local bp = self:GetBlueprint()
--        LOG('xp:' .. self.xp.. ' level at:' .. self.XPperLevel)
        while self.xp >= self.XPnextLevel do
            self.xp = self.xp - self.XPnextLevel
            self.XPnextLevel = bp.Economy.XPperLevel * (1+ 0.1*self.VeteranLevel)
            self:SetVeteranLevel(self.VeteranLevel + 1)--fix this, it is causing  overhead
        end
        self.LevelProgress = self.xp / self.XPnextLevel + self.VeteranLevel
        self.Sync.LevelProgress = self.LevelProgress
--        self.Sync.XPnextLevel = self.Txp - self.xp + self.XPnextLevel
        -- syncing XP need for Levelup, calculation within the UI is faulty.
    end,

    --fix, 117 did not adjust this to reflect new balance
    AddLevels = function(self, levels)
        local bp = self:GetBlueprint()
        local curlevel = self.VeteranLevel
        local percent = self.LevelProgress - curlevel
        local xpAdd = 0
        if levels >= (1-percent) then
            xpAdd = self.XPnextLevel * (1-percent)
            levels=levels-(1-percent)
        else
            xpAdd =self.XPnextLevel * levels
            levels=0
        end
        while levels > 1 do
            levels=levels-1
            curlevel = curlevel +1
            xpAdd=xpAdd + bp.Economy.XPperLevel * (1+ 0.1*curlevel) --fixed
        end -- to account for the 10% increase per gained level
        xpAdd=xpAdd + bp.Economy.XPperLevel * (1+ 0.1*(curlevel+1)) * levels
        self:AddXP(xpAdd) --same
    end,

SetVeteranLevel = function(self, level)
--LOG(' ')
--LOG('*DEBUG: '.. self:GetBlueprint().Description .. ' VETERAN UP! LEVEL ', repr(level))
local old = self.VeteranLevel
self.VeteranLevel = level
local bpA = self:GetBlueprint()
-- Apply default veterancy buffs
local buffTypes = { 'Regen', 'Health', 'Damage','DamageArea','Range','Speed','Vision','OmniRadius','Radar','BuildRate','RateOfFire','Shield'}
local buffACUTypes = {'COMRange','ACUHealth','ACUResourceProduction','ACURateOfFire','COMShield','CEC'}
local buffSCUTypes = {'COMShield','CEC'}
local buffSTRUCTURETypes = {'ResourceProduction'}
local buffSHIELDTypes = {'EnergyCon'}

local buff25Types = {'PerkHealth'}
local buff50Types = {'PerkROF'}
local buff75Types = {'PerkRegen'}
local buff100Types = {'PerkSH'}
local buff125Types = {'PerkMS'}
local buff150Types = {'PerkSR'}
local buff175Types = {'PerkRange'}
local buff200Types = {'PerkDamage'}

local buffME1Types = {'MEBoost1'}
local buffME2Types = {'MEBoost2'}
local buffME3Types = {'MEBoost3'}

local buffRam1Types = {'PerkRambo1'}
local buffRam2Types = {'PerkRambo2'}
local buffRam3Types = {'PerkRambo3'}
local buffRam4Types = {'PerkRambo4'}
local buffRam5Types = {'PerkRambo5'}

local buffACUHealthTypes = {'ACUHP'}

local buffHardenedTypes = {'PerkHardened'}
local buffVeteranTypes = {'PerkVeteran'}
local buffEliteTypes = {'PerkElite'}

local buffSupCan1Types = {'PerkSCC1'}
local buffSupCan2Types = {'PerkSCC2'}
local buffSupCan3Types = {'PerkSCC3'}
local buffSupCan4Types = {'PerkSCC4'}
local buffSupCan5Types = {'PerkSCC5'}

if bpA.Categories then
	for k,bType in buffTypes do
		Buff.ApplyBuff( self, 'Veterancy' .. bType)
	end
end

if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
	for k,bType in buffACUTypes do
		Buff.ApplyBuff( self, 'Veterancy' .. bType)
	end
end

if bpA.Categories and table.find(bpA.Categories,'SUBCOMMAND') then
	for k,bType in buffSCUTypes do
		Buff.ApplyBuff( self, 'Veterancy' .. bType)
	end
end

if bpA.Categories and table.find(bpA.Categories,'STRUCTURE') then
	for k,bType in buffSTRUCTURETypes do
		Buff.ApplyBuff( self, 'Veterancy' .. bType)
	end
end

if bpA.Categories and table.find(bpA.Categories,'SHIELD') then
	for k,bType in buffSHIELDTypes do
		Buff.ApplyBuff( self, 'Veterancy' .. bType)
	end
end

		self.Buff25Check = old - math.floor(old/50)*50
		self.Buff50Check = old - math.floor(old/100)*100
		self.Buff75Check = old - math.floor(old/150)*150
		self.Buff100Check = old - math.floor(old/200)*200
		self.Buff125Check = old - math.floor(old/250)*250
		self.Buff150Check = old - math.floor(old/300)*300
		self.Buff175Check = old - math.floor(old/350)*350
		self.Buff200Check = old - math.floor(old/400)*400
		
		self.BuffME1Check = old - math.floor(old/100)*100
		self.BuffME2Check = old - math.floor(old/175)*175
		self.BuffME3Check = old - math.floor(old/250)*250

		self.BuffRam1Check = old - math.floor(old/75)*75
		self.BuffRam2Check = old - math.floor(old/150)*150
		self.BuffRam3Check = old - math.floor(old/225)*225
		self.BuffRam4Check = old - math.floor(old/300)*300
		self.BuffRam5Check = old - math.floor(old/375)*375

		self.BuffACUHealth1Check = old - math.floor(old/100)*100
		self.BuffACUHealth2Check = old - math.floor(old/200)*200
		self.BuffACUHealth3Check = old - math.floor(old/300)*300
		self.BuffACUHealth4Check = old - math.floor(old/400)*400
		self.BuffACUHealth5Check = old - math.floor(old/500)*500

		self.BuffSupCan1Check = old - math.floor(old/100)*100
		self.BuffSupCan2Check = old - math.floor(old/200)*200
		self.BuffSupCan3Check = old - math.floor(old/300)*300
		self.BuffSupCan4Check = old - math.floor(old/400)*400
		self.BuffSupCan5Check = old - math.floor(old/500)*500
		
		self.BuffHardenedCheck = old - math.floor(old/600)*600
		self.BuffVeteranCheck = old - math.floor(old/800)*800
		self.BuffEliteCheck = old - math.floor(old/1000)*1000

		if self.BuffSupCan1Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffSupCan1Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffSupCan2Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffSupCan2Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffSupCan3Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffSupCan3Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffSupCan4Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffSupCan4Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffSupCan5Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffSupCan5Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffHardenedCheck == 0 then
		 	for k,bType in buffHardenedTypes do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end

		if self.BuffVeteranCheck == 0 then
		 	for k,bType in buffVeteranTypes do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end

		if self.BuffEliteCheck == 0 then
		 	for k,bType in buffEliteTypes do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
		
		if self.BuffACUHealth1Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffACUHealthTypes do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end

		if self.BuffACUHealth2Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffACUHealthTypes do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffACUHealth3Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffACUHealthTypes do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffACUHealth4Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffACUHealthTypes do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffACUHealth5Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'COMMAND') then
				for k,bType in buffACUHealthTypes do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end

		if self.BuffRam1Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'SUBCOMMANDER') then
				for k,bType in buffRam1Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffRam2Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'SUBCOMMANDER') then
				for k,bType in buffRam2Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end

			if self.BuffRam3Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'SUBCOMMANDER') then
				for k,bType in buffRam3Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end

		if self.BuffRam4Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'SUBCOMMANDER') then
				for k,bType in buffRam4Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end

		if self.BuffRam5Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'SUBCOMMANDER') then
				for k,bType in buffRam5Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffME1Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'STRUCTURE') then
				for k,bType in buffME1Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end

		if self.BuffME2Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'STRUCTURE') then
				for k,bType in buffME2Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.BuffME3Check == 0 then
			if bpA.Categories and table.find(bpA.Categories,'STRUCTURE') then
				for k,bType in buffME3Types do
					Buff.ApplyBuff( self, 'Veterancy' .. bType)
				end
			end
		end
		
		if self.Buff25Check == 0 then
		 	for k,bType in buff25Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end

		if self.Buff50Check == 0 then
		 	for k,bType in buff50Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end

		if self.Buff75Check == 0 then
		 	for k,bType in buff75Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
		
		if self.Buff100Check == 0 then
		 	for k,bType in buff100Types do
				local shield = self:GetShield()
	            if not shield then 
	            	--self:AddToggleCap('RULEUTC_ShieldToggle')
	            	self:CreateShield(bpA)
	            	--self:SetEnergyMaintenanceConsumptionOverride(bpA.MaintenanceConsumptionPerSecondEnergy or 0)
	            	--self:SetMaintenanceConsumptionActive()
	            end
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
		
		if self.Buff125Check == 0 then
		 	for k,bType in buff125Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
		
		if self.Buff150Check == 0 then
		 	for k,bType in buff150Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
				
		if self.Buff175Check == 0 then
		 	for k,bType in buff175Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
				
		if self.Buff200Check == 0 then
		 	for k,bType in buff200Types do
		     	Buff.ApplyBuff( self, 'Veterancy' .. bType)
		     end
		end
		
        -- Get any overriding buffs if they exist
        local bp = self:GetBlueprint().Buffs
        --Check for unit buffs

        if bp then
            for bLevel,bData in bp do
                if (bLevel == 'Any' or bLevel == 'Level'..level) then
                    for bType,bValues in bData do
                        local buffName = self:CreateUnitBuff(bLevel,bType,bValues)
                        if buffName then
                            Buff.ApplyBuff( self, buffName )
                        end
                    end
                end
            end
        end

        self:GetAIBrain():OnBrainUnitVeterancyLevel(self, level)
        self:DoUnitCallbacks('OnVeteran')
    end,

    --function to generate the new veterancy buffs
    CreateUnitBuff = function(self, levelName, buffType, buffValues)

        -- Generate a buff based on the unitId
        local buffName = self:GetUnitId() .. levelName .. buffType
        local buffMinLevel = nil
        local buffMaxLevel = nil
        if buffValues.MinLevel then buffMinLevel = buffValues.MinLevel end
        if buffValues.MaxLevel then buffMaxLevel = buffValues.MaxLevel end


        -- Create the buff if needed
        if not Buffs[buffName] then
            --LOG(buffName .. ': '..buffMinLevel.. ' - '..buffMaxLevel)
            BuffBlueprint {
                MinLevel = buffMinLevel,
                MaxLevel = buffMaxLevel,
                Name = buffName,
                DisplayName = buffName,
                BuffType = buffType,
                Stacks = buffValues.Stacks,
                --self.BuffTypes[buffType].BuffStacks,
                Duration = buffValues.Duration,
                Affects = buffValues.Affects,
            }
        end

        -- Return the buffname so the buff can be applied to the unit
        return buffName
    end,

    --Allowing buff bonus and adj bonus at same time!!
    UpdateProductionValues = function(self)
        local bpEcon = self:GetBlueprint().Economy
        if not bpEcon then return end
        self:SetProductionPerSecondEnergy( (self.EnergyProdMod or bpEcon.ProductionPerSecondEnergy or 0)* (self.EnergyProdAdjMod or 1) )
        self:SetProductionPerSecondMass( (self.MassProdMod or bpEcon.ProductionPerSecondMass or 0) * (self.MassProdAdjMod or 1) )
    end,

    AddXP = function(self,amount)
        if not self.XPnextLevel then return end
--        self.Txp = self.Txp + (math.ceil(amount))
--        self.Sync.Txp = self.Txp-- Total EXP collected
        self.xp = self.xp + (amount)--removed ceil, hope this speeds things up
--        LOG('___' .. amount .. repr(self:GetBlueprint().Description))
        self:CheckVeteranLevel()
    end,

    IsInCombat = function(self, instigator)
         if self.BuildXPThread then 
         	KillThread(self.BuildXPThread)
         end
         if instigator.BuildXPThread then 
         	KillThread(instigator.BuildXPThread)
         end
         --self:ForkThread(self.DoTakeDamage)
         --self:ForkThread(instigator.DoTakeDamage)
         self.BuildXPThread = ForkThread(self.startBuildXPThread, self)
         instigator.BuildXPThread = ForkThread(instigator.startBuildXPThread, self)

         self.XpModfierCombat = self.XpModfierInCombat;
         instigator.XpModfierCombat = instigator.XpModfierInCombat;

         WaitSeconds(2)
         if self.BuildXPThread then 
         	KillThread(self.BuildXPThread)
         end
         if instigator.BuildXPThread then 
         	KillThread(instigator.BuildXPThread)
         end

         self.XpModfierCombat = self.XpModfierOutOfCombat;
         instigator.XpModfierCombat = instigator.XpModfierOutOfCombat;
         oldUnit.IsInCombat(self, instigator)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        if instigator and IsUnit(instigator) and not instigator:IsDead() and not self:IsDead()then
            local bp = self:GetBlueprint()
            local iLevel = instigator.VeteranLevel
            local vLevel = self.VeteranLevel
            --Wait to prevent multi damage exploit
            if bp.Economy.xpPerHp then
            ForkThread(self.IsInCombat, self,instigator)
            --    local preAdjHealth = self:GetHealth()
                if amount>=self:GetHealth() then
                	--if self:IsDead() then
                   		instigator:AddXP(bp.Economy.xpPerHp*vLevel*4.5 + vLevel/iLevel* 13.5 * bp.Economy.xpValue + vLevel)

                   	--	end
                  -- self.XpModfierCombat = self.XpModfierOutOfCombat;
                  -- instigator.XpModfierCombat = self.XpModfierOutOfCombat;
                   -- instigator:AddXP(bp.Economy.xpValue*vLevel)
                    --local sLevel = self.VeteranLevel
--                    LOG('___sL: ' .. sLevel)
                    --local xpR = sLevel
                   -- instigator:AddXP(bp.Economy.xpValue*xpR*0.25)
                   -- --xp gains only on killing a unit
--                    LOG('___xpR: ' .. xpR  )
--                    LOG('___xpV: ' .. bp.Economy.xpValue  )
--                    LOG('___xpT: ' .. (bp.Economy.xpValue*xpR*AoE))
                end
            end
        end
        oldUnit.DoTakeDamage(self, instigator, amount, vector, damageType)

        if self:IsDead() then return end
		--self:IsInCombat(self, instigator)
		--instigator:IsInCombat(self, instigator)
    end,

    GetShield = function(self)
        return self.MyShield or nil
    end,
}

