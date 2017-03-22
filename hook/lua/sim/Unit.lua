--****************************************************************************
--**
--**  File     :  /lua/unit.lua
--**  Author(s):  John Comes, David Tomandl, Gordon Duclos
--**
--**  Summary  : The Unit lua module
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--
--Mod code originally written by Eni
--Modified by Eni, Ghaleon(?), Lewnatics(?), Stormrideron and SATA24

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
        local buffACUTypes = {'COMRange','ACUHealth','ACUResourceProduction','ACURateOfFire','COMShield'}
        local buffSCUTypes = {'COMShield'}
        local buffSTRUCTURETypes = {'ResourceProduction'}
        local buffSHIELDTypes = {'EnergyCon'}
        local buffENERGYSTORAGETypes = {'StorageEnergy'}--SATA24
        local buffMASSSTORAGETypes = {'StorageMass'}    --SATA24

        local buff50Types = {'PerkHealth'}
        local buff100Types = {'PerkROF'}
        local buff150Types = {'PerkRegen'}
        local buff200Types = {'PerkSH'}
        local buff250Types = {'PerkMS'}
        local buff300Types = {'PerkSR'}
        local buff350Types = {'PerkRange'}
        local buff400Types = {'PerkDamage'}

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

        --Do unit buff checks that apply to all units (Code refactoring below by SATA24)
        for k,bType in buffTypes do
            Buff.ApplyBuff( self, 'Veterancy' .. bType)
        end

        --Check for Hardened, Veteran, or Elite Status
        if (old == 600) then 
            self.BuffHardenedCheck = true 
        else
            self.BuffHardenedCheck = false
        end
        if (old == 800) then
            self.BuffVeteranCheck = true
        else
            self.BuffVeteranCheck = false
        end
        if (old == 1000) then
            self.BuffEliteCheck = true
        else
            self.BuffEliteCheck = false
        end

        if (self.BuffHardenedCheck) then 
            for k,bType in buffHardenedTypes do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end

        if (self.BuffVeteranCheck) then
            for k,bType in buffVeteranTypes do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end

        if (self.BuffEliteCheck) then
            for k,bType in buffEliteTypes do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end

        --Check for buffs applied on levels of multiples of 50, up to level 400
        if (old == 50) then
            self.Buff50Check = true
        else
            self.Buff50Check = false
        end
        if (old == 100) then
            self.Buff100Check = true
        else
            self.Buff100Check = false
        end
        if (old == 150) then
            self.Buff150Check = true
        else
            self.Buff150Check = false
        end
        if (old == 200) then
            self.Buff200Check = true
        else
            self.Buff200Check = false
        end
        if (old == 250) then
            self.Buff250Check = true
        else
            self.Buff250Check = false
        end
        if (old == 300) then
            self.Buff300Check = true
        else
            self.Buff300Check = false
        end
        if (old == 350) then
            self.Buff350Check = true
        else
            self.Buff350Check = false
        end
        if (old == 400) then
            self.Buff400Check = true
        else
            self.Buff400Check = false
        end

        if (self.Buff50Check) then
            for k,bType in buff50Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end
        end

        if (self.Buff100Check) then
            for k,bType in buff100Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end
        end

        if (self.Buff150Check) then
            for k,bType in buff150Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end
        end
        
        if (self.Buff200Check) then
            for k,bType in buff200Types do
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
        
        if (self.Buff250Check) then
            for k,bType in buff250Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end
        
        if (self.Buff300Check) then
            for k,bType in buff300Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end
                
        if (self.Buff350Check) then
            for k,bType in buff350Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end
                
        if (self.Buff400Check) then
            for k,bType in buff200Types do
                Buff.ApplyBuff( self, 'Veterancy' .. bType)
            end
        end

        --Check for unit-type specific buffs

        if bpA.Categories then
        --Check for buffs specific to "COMMAND" units (ie. ACUs)

            if table.find(bpA.Categories,'COMMAND') then
                for k,bType in buffACUTypes do
                    Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end

                if(old == 100) then
                    self.BuffSupCan1Check = true
                else
                    self.BuffSupCan1Check = false
                end
                if(old == 200) then 
                    self.BuffSupCan2Check = true
                else
                    self.BuffSupCan2Check = false
                end
                if(old == 300) then
                    self.BuffSupCan3Check = true
                else
                    self.BuffSupCan3Check = false
                end
                if(old == 400) then
                    self.BuffSupCan4Check = true
                else
                    self.BuffSupCan4Check = false
                end
                if (old == 500) then
                    self.BuffSupCan5Check = true
                else
                    self.BuffSupCan5Check = false
                end

                if (self.BuffSupCan1Check) then
                    for k,bType in buffSupCan1Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffSupCan2Check) then
                    for k,bType in buffSupCan2Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffSupCan3Check) then
                    for k,bType in buffSupCan3Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffSupCan4Check) then
                    for k,bType in buffSupCan4Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffSupCan5Check) then
                    for k,bType in buffSupCan5Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end

                if (old == 100) then
                    self.BuffACUHealth1Check = true
                else
                    self.BuffACUHealth1Check = false
                end
                if (old == 200) then
                    self.BuffACUHealth2Check = true
                else
                    self.BuffACUHealth2Check = false
                end
                if (old == 300) then
                    self.BuffACUHealth3Check = true
                else
                    self.BuffACUHealth3Check = false
                end
                if (old == 400) then
                    self.BuffACUHealth4Check = true
                else
                    self.BuffACUHealth4Check = false
                end
                if (old == 500) then
                    self.BuffACUHealth5Check = true
                else
                    self.BuffACUHealth5Check = false
                end

                if (self.BuffACUHealth1Check) then
                    for k,bType in buffACUHealthTypes do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end

                if (self.BuffACUHealth2Check) then
                    for k,bType in buffACUHealthTypes do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffACUHealth3Check) then
                    for k,bType in buffACUHealthTypes do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffACUHealth4Check) then
                    for k,bType in buffACUHealthTypes do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffACUHealth5Check) then
                    for k,bType in buffACUHealthTypes do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
            end
        --End check for "COMMAND" buffs

        --Check for buffs specific to "SUBCOMMANDER" units (ie. SACUs)
            if table.find(bpA.Categories,'SUBCOMMANDER') then   --There used to be a typo here. Previouly, it read "if table.find(bpA.Categories,'SUBCOMMAND') then" 
                                                                --instead of "if table.find(bpA.Categories,'SUBCOMMANDER') then". --SATA24
                for k,bType in buffSCUTypes do
                    Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end

                if (old ==  75) then
                    self.BuffRam1Check = true
                else
                    self.BuffRam1Check = false
                end
                if (old == 150) then
                    self.BuffRam2Check = true
                else
                    self.BuffRam2Check = false
                end
                if (old == 225) then
                    self.BuffRam3Check = true
                else
                    self.BuffRam3Check = false
                end
                if (old == 300) then
                    self.BuffRam4Check = true
                else
                    self.BuffRam4Check = false
                end
                if (old == 375) then
                    self.BuffRam5Check = true
                else
                    self.BuffRam5Check = false
                end

                if (self.BuffRam1Check) then
                    for k,bType in buffRam1Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffRam2Check) then
                    for k,bType in buffRam2Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end

                if (self.BuffRam3Check) then
                    for k,bType in buffRam3Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end

                if (self.BuffRam4Check) then
                    for k,bType in buffRam4Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end

                if (self.BuffRam5Check) then
                    for k,bType in buffRam5Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
            end
        --End check for "SUBCOMMANDER" buffs

        --Check for buffs specific to "STRUCTURE" units (ie. Buildings)
            if table.find(bpA.Categories,'STRUCTURE') then

                for k,bType in buffSTRUCTURETypes do
                    Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end

                if (old == 100) then
                    self.BuffME1Check = true
                else
                    self.BuffME1Check = false
                end
                if (old == 175) then
                    self.BuffME2Check = true
                else
                    self.BuffME2Check = false
                end
                if (old == 250) then
                    self.BuffME3Check = true
                else
                    self.BuffME3Check = false
                end
                
                if (self.BuffME1Check) then
                    for k,bType in buffME1Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end

                if (self.BuffME2Check) then
                    for k,bType in buffME2Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
                
                if (self.BuffME3Check) then
                    for k,bType in buffME3Types do
                        Buff.ApplyBuff( self, 'Veterancy' .. bType)
                    end
                end
            end
        --End check for "STRUCTURE" units

        --Check for buffs specific to "SHIELD" units (ie. Shield Generators)
            if table.find(bpA.Categories,'SHIELD') then

                for k,bType in buffSHIELDTypes do
                    Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end
            end
        --End check for "SHIELD" units

        --Check for buffs specific to "MASSSTORAGE" units (ie. T1 Mass Storage) --SATA24
            if table.find(bpA.Categories,'MASSSTORAGE') then

                for k,bType in buffMASSSTORAGETypes do
                    Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end
            end
        --End check for "MASSSTORAGE" units --SATA24

        --Check for buffs specific to "ENERGYSTORAGE" units (ie. T1 Energy Storage) --SATA24
            if table.find(bpA.categories, 'ENERGYSTORAGE') then

                for k,bType in buffENERGYSTORAGETypes do
                    Buff.ApplyBuff( self, 'Veterancy' .. bType)
                end
            end
        --End check for "ENERGYSTORAGE" units --SATA24

        end
        --End buff check (Code refactoring above by SATA24)--

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