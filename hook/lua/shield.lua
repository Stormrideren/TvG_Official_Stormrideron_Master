--****************************************************************************
--**
--**  File     :  /lua/shield.lua
--**  Author(s):  John Comes, Gordon Duclos
--**
--**  Summary  : Shield lua module
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local oldShield = Shield
Shield = Class(oldShield) {

    InitBuffValues = function(self,spec)
        self.spec = spec
        if spec.Owner then self.XPperDamage = spec.Owner:GetBlueprint().Economy.xpValue /spec.ShieldMaxHealth else self.XPperDamage = 0 end
         spec.Owner.Sync.ShieldMaxHp = spec.ShieldMaxHealth -- replace this with generic
         spec.Owner.Sync.ShieldRegen = spec.ShieldRegenRate -- method to directly query
        --LOG(spec.ShieldRegenRate)
        --LOG(self.XPperDamage)
       end,

    OnCreate = function(self,spec)
        self:InitBuffValues(spec)
        oldShield.OnCreate(self,spec)
       end,

    ChargingUp = function(self, curProgress, time)
        oldShield.ChargingUp(self, curProgress, time)
        self:SetHealth(self,self:GetMaxHealth())
    end,

    OnDamage =  function(self,instigator,amount,vector,type)
        local absorbed = self:OnGetDamageAbsorption(instigator,amount,type)
        local hp = self:GetMaxHealth()
        if (self.XPperDamage*absorbed) > 3 then
               self.Owner:AddXP(self.XPperDamage*absorbed*0.25)
--               LOG('___' .. self.XPperDamage*absorbed)
           end
        oldShield.OnDamage(self,instigator,amount,vector,type)
    end,
}

local oldUnitShield = PersonalShield
PersonalShield = Class(oldUnitShield){

    OnCreate = function(self,spec)
        Shield.InitBuffValues(self,spec)
        oldUnitShield.OnCreate(self,spec)
       end,

    ChargingUp = function(self, curProgress, time)
        oldUnitShield.ChargingUp(self, curProgress, time)
        self:SetHealth(self,self:GetMaxHealth())
    end,
}

