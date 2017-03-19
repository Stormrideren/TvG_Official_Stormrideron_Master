--****************************************************************************
--**  Summary  :  Aeon Sub Commander Script
--****************************************************************************

oldUAL0301 = UAL0301
UAL0301 = Class(oldUAL0301) {

    CreateEnhancement = function(self, enh)
        CommandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        --Teleporter
        --ResourceAllocation

        if enh == 'ResourceAllocation' then
            if not Buffs['AeonSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'AeonSCUResourceAllocation',
                    DisplayName = 'AeonSCUResourceAllocation',
                    BuffType = 'AeonSCUResourceAllocation',
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
            Buff.ApplyBuff(self, 'AeonSCUResourceAllocation')
        elseif enh == 'AeonSCUResourceAllocation' then
            Buff.RemoveBuff(self,'AeonSCUResourceAllocation',false)

        else
            oldUAL0301.CreateEnhancement(self, enh)
        end
    end,

}

TypeClass = UAL0301
