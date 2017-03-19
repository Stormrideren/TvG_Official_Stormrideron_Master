local OldSetLayout = SetLayout

function SetLayout()
    OldSetLayout()

    local controls = import('/lua/ui/game/unitview.lua').controls

    LayoutHelpers.Below(controls.vetXPBar, controls.icon, 0)
    LayoutHelpers.AtLeftIn(controls.vetXPBar, controls.icon, 0)

    controls.vetXPBar.Width:Set(50)
    controls.vetXPBar.Height:Set(3)
    controls.vetXPBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.vetXPBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))


    LayoutHelpers.AtLeftTopIn(controls.healthBar, controls.bg, 66, 25)
    --controls.healthBar.Height:Set(9)
    LayoutHelpers.Below(controls.shieldBar, controls.healthBar)
    controls.shieldBar.Height:Set(14)
    --controls.shieldBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_green.dds'))
    --controls.shieldBar:SetDropShadow(true)


    LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar,0)
    --LayoutHelpers.AtCenterIn(controls.shieldText, controls.shieldBar)
    controls.shieldBar.Height:Set(2)

    LayoutHelpers.Below(controls.vetXPText, controls.vetXPBar,1)
    LayoutHelpers.AtLeftIn(controls.vetXPText, controls.vetXPBar, 0)
    controls.vetXPText:SetDropShadow(true)


    LayoutHelpers.AtLeftTopIn(controls.statGroups[1].icon, controls.bg, 70, 55)
    LayoutHelpers.RightOf(controls.statGroups[1].value, controls.statGroups[1].icon, 5)
    LayoutHelpers.Below(controls.statGroups[2].icon, controls.statGroups[1].icon,0)
    LayoutHelpers.RightOf(controls.statGroups[2].value, controls.statGroups[2].icon, 5)
    LayoutHelpers.Below(controls.Buildrate, controls.statGroups[2].value,1)

        LayoutHelpers.CenteredAbove(controls.XPText, controls.bg,0)

end