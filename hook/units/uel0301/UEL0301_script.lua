--****************************************************************************
--**  Summary  :  UEF SubCommander Script
--****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

local oldUEL0301 = UEL0301
UEL0301 = Class(oldUEL0301) {


    CreateEnhancement = function(self, enh)
        CommandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        if enh =='ResourceAllocation' then
            if not Buffs['UefSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'UefSCUResourceAllocation',
                    DisplayName = 'UefSCUResourceAllocation',
                    BuffType = 'UefSCUResourceAllocation',
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
            Buff.ApplyBuff(self, 'UefSCUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'UefSCUResourceAllocation',false)
        else
            oldUEL0301.CreateEnhancement(self, enh)
        end
    end,



}

TypeClass = UEL0301