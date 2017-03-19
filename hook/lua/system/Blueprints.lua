do
--local VeterancyHelper = import('/mods/TotalVeterancy/helper/VeterancyHelper.lua')
    local oldModBP = ModBlueprints

    function ModBlueprints(all_bps)
        oldModBP(all_bps)
	
        local scaling = 0.5 --(square root)
        local evenkills = 1 -- was 4--adjusted xp gained by *0.25
        local ACUbaseValue = 1600  --
        local SCUbaseValue = 6400  -- 30k if calculated by cost

		local once = true
        for id,bp in all_bps.Unit do
            if bp.Defense.RegenRate == nil then
                bp.Defense.RegenRate = 0
            end
            local RegenMod = 1.375*(50 - 1 / (0.00000060257 * bp.Defense.MaxHealth + 0.020016))
            bp.Defense.RegenRate = bp.Defense.RegenRate + RegenMod

            -- Override for ACUs, SCUs and Specific Units
            if bp.Economy and not bp.Economy.xpBaseValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime and table.find(bp.Categories,'COMMAND') then
           		bp.Economy.xpTimeStep = 275
                bp.Economy.xpBaseValue = ACUbaseValue
            end--acu
            if bp.Economy and not bp.Economy.xpBaseValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime and table.find(bp.Categories,'SUBCOMMANDER') then
           		bp.Economy.xpTimeStep = 90.75
                bp.Economy.xpBaseValue = SCUbaseValue
            end--scu

            --calculate xp depending on xpBaseValue of from cost if no base value is set.
            --old values are not overwritten
            if bp.Economy and not bp.Economy.xpValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime and (not table.find(bp.Categories,'UNTARGETABLE') or bp.Economy.xpBaseValue) then
                bp.Economy.xpValue = math.pow((bp.Economy.xpBaseValue or (bp.Economy.BuildCostMass + bp.Economy.BuildCostEnergy*0.1 + bp.Economy.BuildTime*0.04)),scaling)
                --if bp.Description then LOG(bp.Description .. ' ' .. bp.Economy.xpValue) end
            end

            --calculate xp per level depending on own value and kills per level set.
            if bp.Economy and not bp.Economy.XPperLevel and bp.Economy.xpValue then
                bp.Economy.XPperLevel = bp.Economy.xpValue * evenkills
            end
            if bp.Economy and bp.Defense and not bp.Economy.xpPerHp and bp.Economy.xpValue and bp.Defense.MaxHealth then
                bp.Economy.xpPerHp = bp.Economy.xpValue / bp.Defense.MaxHealth
            end

            --AutoXP merge
            --T1
            if bp.Categories and table.find(bp.Categories,'TECH1') and not table.find(bp.Categories,'MASSPRODUCTION') then
                bp.Economy.xpTimeStep = 50
            end

            --T2
            if bp.Categories and table.find(bp.Categories,'TECH2') and not table.find(bp.Categories,'MASSPRODUCTION') then
                bp.Economy.xpTimeStep = 75
            end

            --T3
            if bp.Categories and table.find(bp.Categories,'TECH3') and not table.find(bp.Categories,'MASSPRODUCTION') then
                bp.Economy.xpTimeStep = 112.5
            end

            --Experimental
            if bp.Categories and table.find(bp.Categories,'EXPERIMENTAL') and table.find(bp.Categories,'STRUCTURE')then
                bp.Economy.xpTimeStep = 500
            end
            if bp.Categories and table.find(bp.Categories,'EXPERIMENTAL') and not table.find(bp.Categories,'STRUCTURE')then
                bp.Economy.xpTimeStep = 250
            end

            --T1 LAND Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH1') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'AIR') and not table.find(bp.Categories,'NAVAL') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = 30
            end

            --T1 NAVAL Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH1') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'LAND') and not table.find(bp.Categories,'AIR') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = 55
            end

            --T1 AIR Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH1') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'LAND') and not table.find(bp.Categories,'NAVAL') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = 80
            end
			
			--T2 LAND Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH2') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'AIR') and not table.find(bp.Categories,'NAVAL') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = 30*1.5
            end

            --T2 NAVAL Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH2') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'LAND') and not table.find(bp.Categories,'AIR') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = 55*1.5
            end

             --T2 AIR Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH2') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'LAND') and not table.find(bp.Categories,'NAVAL') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = 80*1.5
            end
			
			--T3 LAND Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH3') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'AIR') and not table.find(bp.Categories,'NAVAL') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = (30*1.5)*2
            end

            --T3 NAVAL Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH3') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'LAND') and not table.find(bp.Categories,'AIR') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = (55*1.5)*2
            end

             --T3 AIR Levels faster
            if bp.Categories and table.find(bp.Categories,'TECH3') and not table.find(bp.Categories,'STRUCTURE') and not table.find(bp.Categories,'LAND') and not table.find(bp.Categories,'NAVAL') and not table.find(bp.Categories,'ENGINEER')then
                bp.Economy.xpTimeStep = (80*1.5)*2
            end
			
            --structures which generate resources gain AutoXP
            --MassXP
            if bp.Categories and table.find(bp.Categories,'STRUCTURE') and (table.find(bp.Categories,'MASSEXTRACTION') or  table.find(bp.Categories,'MASSFABRICATION') or table.find(bp.Categories,'MASSPRODUCTION')) and not bp.Economy.xpTimeStep and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 30
            end
       
           -- PowerplantXP
            if bp.Categories and table.find(bp.Categories,'STRUCTURE') and table.find(bp.Categories,'ENERGYPRODUCTION') and not bp.Economy.xpTimeStep and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 45
            end

            -- Intel gains xp
            if bp.Categories and table.find(bp.Categories,'INTELLIGENCE') and (table.find(bp.Categories,'STRUCTURE') or table.find(bp.Categories,'MOBILESONAR')) and not bp.Economy.xpTimeStep and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 125
           end

            -- Immobile Shields gain xp
            if bp.Categories and table.find(bp.Categories,'STRUCTURE') and table.find(bp.Categories,'SHIELD') and not bp.Economy.xpTimeStep  and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 150
            end

            -- All other structures T1
            if bp.Categories and table.find(bp.Categories,'STRUCTURE') and table.find(bp.Categories,'TECH1') and not table.find(bp.Categories,'ENERGYPRODUCTION') and not table.find(bp.Categories,'CONSTRUCTION') and not table.find(bp.Categories,'MASSPRODUCTION') and not bp.Economy.xpTimeStep and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 25
            end

            -- All other structures T2
            if bp.Categories and table.find(bp.Categories,'STRUCTURE') and table.find(bp.Categories,'TECH2') and not table.find(bp.Categories,'ENERGYPRODUCTION') and not table.find(bp.Categories,'CONSTRUCTION') and not table.find(bp.Categories,'MASSPRODUCTION') and not bp.Economy.xpTimeStep and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 40
            end

            -- All other structures T3
            if bp.Categories and table.find(bp.Categories,'STRUCTURE') and table.find(bp.Categories,'TECH3') and not table.find(bp.Categories,'ENERGYPRODUCTION') and not table.find(bp.Categories,'CONSTRUCTION') and not table.find(bp.Categories,'MASSPRODUCTION') and not bp.Economy.xpTimeStep and not table.find(bp.Categories,'UNTARGETABLE') then
                bp.Economy.xpTimeStep = 70
            end

            --BuildXP
            if bp.Categories and (table.find(bp.Categories,'CONSTRUCTION') or table.find(bp.Categories,'ENGINEER') or table.find(bp.Categories,'FACTORY') ) and not table.find(bp.Categories,'UNTARGETABLE') and not bp.Economy.BuildxpLevelpSecond then
                bp.Economy.BuildXPLevelpSecond = (math.random(20,40))
            end
        end
    end
end
