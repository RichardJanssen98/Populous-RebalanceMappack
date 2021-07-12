_g = gsi()

function EnableSpellCharging(_pn, _spell)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging = _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging ~ (1<<_spell-1)
end

function DisableSpellCharging(_pn, _spell)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging = _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging | (1<<_spell-1)
end

function EnableSpell(_pn, _spell)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsAvailable = _g.ThisLevelInfo.PlayerThings[_pn].SpellsAvailable | (1 << _spell)
end

function DisableSpell(_pn, _spell)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsAvailable = _g.ThisLevelInfo.PlayerThings[_pn].SpellsAvailable ~ (1 << _spell)
end

function SetOneShotCharges(_pn, _spell, _num)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsAvailableOnce[_spell] = _g.ThisLevelInfo.PlayerThings[_pn].SpellsAvailableOnce[_spell] | _num
end

function ResetSpellsCharging()
  for j = 0, 7 do
    for i = 0, 21 do
      if (i ~= 2 and i ~= 17) then
        DisableSpellCharging(j, i)
      end
    end
  end
end
