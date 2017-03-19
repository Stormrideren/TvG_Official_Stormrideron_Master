local oldURL0001 = URL0001
URL0001 = Class(oldURL0001) {

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)

        local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end

        if enh == 'ResourceAllocation' then
            if not Buffs['CybranACUTResourceAllocation'] then
                BuffBlueprint {
                    Name = 'CybranACUTResourceAllocation',
                    DisplayName = 'CybranACUTResourceAllocation',
                    BuffType = 'CybranACUTResourceAllocation',
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
            Buff.ApplyBuff(self, 'CybranACUTResourceAllocation')

        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'CybranACUTResourceAllocation',false)
        else
            oldURL0001.CreateEnhancement(self, enh)
        end
    end,
}

TypeClass = URL0001
