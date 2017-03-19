--****************************************************************************
--**
--**  File     :  /lua/defaultunits.lua
--**  Author(s):  John Comes, Gordon Duclos
--**
--**  Summary  :  Default definitions of units
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

----------------------------------------------------------------------------------------------------------------------------------
----  STRUCTURE UNITS
----------------------------------------------------------------------------------------------------------------------------------
local oldStructureUnit = StructureUnit
StructureUnit = Class(oldStructureUnit) {
    OnStartBuild = function(self, unitBeingBuilt, order )
        oldStructureUnit.OnStartBuild(self, unitBeingBuilt, order )
        if unitBeingBuilt:GetUnitId() == self:GetBlueprint().General.UpgradesTo and order == 'Upgrade' then
            self.upgrading = true
        else
            self.upgrading = nil
        end
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        if builder.upgrading then
            self:AddLevels(builder.LevelProgress)
        end
        oldStructureUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    OnFailedToBeBuilt = function(self)
        self.upgrading = nil
        oldStructureUnit.OnFailedToBeBuilt(self)
    end,

    OnStopBuild = function(self, unitBuilding)
         self.upgrading = nil
         oldStructureUnit.OnStopBuild(self, unitBuilding)
    end,

}


