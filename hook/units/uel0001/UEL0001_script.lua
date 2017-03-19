--****************************************************************************
--**  Summary  :  UEF Commander Script
--****************************************************************************
local oldUEL0001 = UEL0001
UEL0001 = Class(oldUEL0001) {
    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

         --ResourceAllocation
        if enh == 'ResourceAllocation' then
            if not Buffs['UefACUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'UefACUResourceAllocation',
                    DisplayName = 'UefACUResourceAllocation',
                    BuffType = 'UefACUResourceAllocation',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MassProductionBuf = {
                            Add =  bp.ProductionPerSecondMass,
                            Mult = 1.0,
                        },
                        EnergyProductionBuf = {
                            Add = bp.ProductionPerSecondEnergy,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'UefACUResourceAllocation',false)
        else
            oldUEL0001.CreateEnhancement(self, enh)
        end
    end,



}
TypeClass = UEL0001