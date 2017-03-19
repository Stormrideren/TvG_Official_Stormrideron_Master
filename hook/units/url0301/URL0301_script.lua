--****************************************************************************
--**  Summary  :  Cybran Sub Commander Script
--****************************************************************************


oldURL0301 = URL0301
URL0301 = Class(oldURL0301) {

    CreateEnhancement = function(self, enh)
        CCommandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        if enh == 'ResourceAllocation' then
            if not Buffs['CybranSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'CybranSCUResourceAllocation',
                    DisplayName = 'CybranSCUResourceAllocation',
                    BuffType = 'CybranSCUResourceAllocation',
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
            Buff.ApplyBuff(self, 'CybranSCUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'CybranSCUResourceAllocation',false)
        else
            oldURL0301.CreateEnhancement(self, enh)
        end
    end,
}

TypeClass = URL0301
