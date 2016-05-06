-----------------------------------
-- Author: Johan Hanssen Seferidis
--
-- Comments: Sets all idle units that are not selected to fight. That has as effect to reclaim if there is low metal
--					 , repair nearby units and assist in building if they have the possibility.
--					 If you select the unit while it is being idle the widget is not going to take effect on the selected unit.
--
-------------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name = "Auto Reclaim/Heal/Assist",
		desc = "Makes idle unselected builders/rez/nanos to reclaim metal if metal bar is not full, repair nearby units and assist in building",
		author = "Pithikos",
		date = "Nov 21, 2010",
		license = "GPLv3",
        version = 1.5,
		layer = 0,
		enabled = true --enable automatically
	}
end

-- v1.5 Fight command now excludes units that are in cloak state


--------------------------------------------------------------------------------------
local echo           = Spring.Echo
local getUnitPos     = Spring.GetUnitPosition
local orderUnit      = Spring.GiveOrderToUnit
local getUnitTeam    = Spring.GetUnitTeam
local isUnitSelected = Spring.IsUnitSelected
local getGameSeconds = Spring.GetGameSeconds
local getUnitStates  = Spring.GetUnitStates
local isCloaked      = Spring.GetUnitIsCloaked
local getUnitDefID   = Spring.GetUnitDefID
local ingameSecs     = 0
local lastOrderGivenInSecs= 0
local reclaimers     = {} -- Reclaimers because it includes builders, rezzers, com
myTeamID=-1;



--------------------------------------------------------------------------------------


-- Disabling the widget
function widget:Initialize()
	  local _, _, spec = Spring.GetPlayerInfo(Spring.GetMyPlayerID())
	  if spec then
		    widgetHandler:RemoveWidget()
		    return false
	  end
	  myTeamID=Spring.GetMyTeamID()
end
function widget:PlayerChanged(playerID)
	  local _, _, spec = Spring.GetPlayerInfo(Spring.GetMyPlayerID())
	  if spec then
	      widgetHandler:RemoveWidget()
	      return false
	  end
end


-- Give reclaimers the FIGHT command every second
function widget:GameFrame()
	ingameSecs=math.floor(getGameSeconds())
	if (ingameSecs>lastOrderGivenInSecs) then
		for unitID in pairs(reclaimers) do
			local x, y, z = getUnitPos(unitID)
			local states = getUnitStates(unitID)
			if (not isUnitSelected(unitID) and not states['cloak']) then
				orderUnit(unitID, CMD.FIGHT, { x, y, z }, {})
			end
			lastOrderGivenInSecs=ingameSecs
		end
	end
end


-- Register reclaimer that has gone idle
function widget:UnitIdle(unitID, unitDefID, unitTeam)
  --check if unit is mine
	if (myTeamID==getUnitTeam(unitID)) then
		local udef = getUnitDefID(unitID)
		local ud = UnitDefs[udef]
		if (ud["canReclaim"] and not ud.isFactory) then
			  reclaimers[unitID]=true
		end

	end
end


--Unregister reclaimer once it is given a command
function widget:UnitCommand(unitID)
	for reclaimerID in pairs(reclaimers) do
		if (reclaimerID==unitID) then
			reclaimers[reclaimerID]=nil
		end
	end
end
