_g = gsi()

function EnableBuilding(_pn, _building)
	 _g.ThisLevelInfo.PlayerThings[_pn].BuildingsAvailable = _g.ThisLevelInfo.PlayerThings[_pn].BuildingsAvailable | (1 << _building)
end

function DisableBuilding(_pn, _building)
	_g.ThisLevelInfo.PlayerThings[_pn].BuildingsAvailable = _g.ThisLevelInfo.PlayerThings[_pn].BuildingsAvailable ~ (1 << _building)
end
