--****************************************************************************
--**
--**  File     :  /cdimage/units/UAL0001/UAL0001_script.lua
--**  Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos
--**
--**  Summary  :  Aeon Commander Script
--**
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local oldUAL0001 = UAL0001
UAL0001 = Class(oldUAL0001) {

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        --Resource Allocation
        if enh == 'ResourceAllocation' then
            if not Buffs['AeonACUTResourceAllocation'] then
                BuffBlueprint {
                    Name = 'AeonACUTResourceAllocation',
                    DisplayName = 'AeonACUTResourceAllocation',
                    BuffType = 'AeonACUTResourceAllocation',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MassProductionBuf = {
                            Add =  bp.ProductionPerSecondMass,
                            Mult = 1,
                        },
                        EnergyProductionBuf = {
                            Add = bp.ProductionPerSecondEnergy,
                            Mult = 1.0,
                        },
                    },
                }
            end

            Buff.ApplyBuff(self, 'AeonACUTResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'AeonACUTResourceAllocation',false)
        elseif enh == 'ResourceAllocationAdvanced' then
            if Buffs['AeonACUTResourceAllocation'] then
                Buff.RemoveBuff(self,'AeonACUTResourceAllocation',false)
            end

            if not Buffs['AeonACUTResourceAllocationAdvanced'] then
                BuffBlueprint {
                    Name = 'AeonACUTResourceAllocationAdvanced',
                    DisplayName = 'AeonACUTResourceAllocationAdvanced',
                    BuffType = 'AeonACUTResourceAllocationAdvanced',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MassProductionBuf = {
                            Add =  bp.ProductionPerSecondMass,
                            Mult = 1,
                        },
                        EnergyProductionBuf = {
                            Add = bp.ProductionPerSecondEnergy,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonACUTResourceAllocationAdvanced')
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            Buff.RemoveBuff(self,'AeonACUTResourceAllocationAdvanced',false)
        else
            oldUAL0001.CreateEnhancement(self, enh)

        end

    end,

}

TypeClass = UAL0001