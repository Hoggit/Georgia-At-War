-- Carrier Windfacer
--   Copyright (C) 2019  Gil Castillo
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with this program.  If not, see <https://www.gnu.org/licenses/>
--
-- @Gillogical 

-- Turns a carrier to blow a set amount of wind over a deck
--
-- Can also be used generically to turn units into wind
--
-- Calculates carrier offset heading required to remove crosswind component
--
-- Carrier begins turning into wind if any of a filtered list of aircraft are within rStartOps
-- Carrier returns to starting point if no aircraft are within rEndOps
-- 
-- I'll be honest, I didn't know about the TACAN issue and am fixing it the same way as Wrench's carrier script. Maybe give that a look if you want a different view on Carrier Ops.

-- Carrier Initiation Function
-- function Windface.InitCarrier(carrier, zoneName)
-- carrier: Name of Carrier unit
-- zoneName: Name of operating zone
-- Place the carrier roughly within the center of the operating zone in the mission editor for best results. The Carrier uses the size of the zone as a reference, it doesn't actually define the movement bounds

-- TODO (GAW)
-- Report the carrier's position, BRC and whether or not it is currently active or recovering via radio command, or at a given time period
-- Replace player unit loop with world.searchObjects to determine if we have units in range to activate the carrier
-- Tweak the proximity searches. We probably want to do the activation checks more often as players probably won't Marshall Stack while it turns onto heading.
-- Current worst case scenario is that a player enters the activation zone with 9:59 before the next check, and then even after that will have to wait for the carrier to turn to heading

Windface = {}
--Windface.param = {}
Windface.aDeckAngle		= mist.utils.toRadian(10)	-- Degrees
Windface.vTotalWind		= 15	-- m/s total wind required over deck (15m/s ~ 30knots)
Windface.vMinUnitSpeed	= 3		-- m/s minimum speed of the unit (3m/s ~ 6 knots)
Windface.rStartOps		= 18500	-- m from carrier when a valid unit will trigger ops ~10nm
Windface.rEndOps		= 55560	-- m from carrier when a lack of valid units will cause it to return to initial position ~30nm
Windface.rMaxRange		= 55600	-- m from start position where Carrier will ignore recovery ops and begin to return to base. Currently set to 1 hourish assuming 30 knot speed

function Windface.CalculateOffset(currentPos)
	local windDir		= atmosphere.getWind({x = currentPos.x, y = currentPos.y + 5, z = currentPos.z})
	local windHeading	= mist.utils.getDir(windDir, currentPos)
	local vWind			= mist.vec.mag(windDir)
	
	-- Solving using the cosine rule gives us a quadratic equation with 2 solutions, we want the one where the wind is pointing towards the carrier
	local b = 2 * Windface.vTotalWind * math.cos(Windface.aDeckAngle)
	local c = - (vWind * vWind - Windface.vTotalWind * Windface.vTotalWind)
	local vMinWind = Windface.vTotalWind * math.sin(Windface.aDeckAngle)
	
	local aCarrierDelta = 0
	local vCarrier = 0
	-- If we're below minimum wind just drive straight into it
	-- I've added the case for an indeterminate quadratic solution too, although the above should be the only way that happens
	if vWind > vMinWind and (b*b - 4 * c) >= 0 then
		local vCarrier1 = (b + math.sqrt(b*b - 4 * c)) * 0.5
		local vCarrier2 = (b - math.sqrt(b*b - 4 * c)) * 0.5
		vCarrier = math.min(vCarrier1,vCarrier2)
		
		local aWindVTotal	= 0
		if vCarrier > Windface.vMinUnitSpeed then
			aWindVTotal		= math.acos((Windface.vTotalWind * Windface.vTotalWind + vWind * vWind - vCarrier * vCarrier) / (2 * Windface.vTotalWind * vWind))
		else
			vCarrier = Windface.vMinUnitSpeed
			aWindVTotal		= math.asin(vCarrier * math.sin(Windface.aDeckAngle) / vWind)
		end
		local aWindVCarrier	= math.pi - Windface.aDeckAngle - aWindVTotal
		-- This should always result in a positive as the carrier BRC is clockwise to the angle
		aCarrierDelta	= math.pi - aWindVCarrier
	end
	
	env.info( mist.utils.serialize('Position ', currentPos), false )
	env.info( mist.utils.serialize('Wind ', windDir), false )
	local msgText = string.format("Wind %03d/%.2f m/s; Calculated Carrier Speed %.2f m/s",  (mist.utils.toDegree(windHeading + math.pi)) % 360, vWind, vCarrier)
	env.info( msgText, false )
	
	-- Perform the heading calcs
	-- Since we are working with raw positions and vectors we shouldn't account for projection variation
	local aWindUncorrected	= mist.utils.getDir(windDir) + math.pi
	local aCarrierHeading	= aWindUncorrected + aCarrierDelta
	local vecCarrierDir		= {x = math.cos(aCarrierHeading), y = 0, z = math.sin(aCarrierHeading)}
	
	msgText = string.format("Uncorrected Wind angle %0.3f/%03d, Carrier Delta %0.3f/%03d, Carrier Heading %0.3f/%03d", aWindUncorrected, (mist.utils.toDegree(aWindUncorrected) % 360), aCarrierDelta, mist.utils.toDegree(aCarrierDelta), aCarrierHeading, (mist.utils.toDegree(aCarrierHeading) % 360))
	env.info( msgText, false )
	
	local offsetData = { vSpeed = vCarrier, aDelta = aCarrierDelta, aCarrierHeading = aCarrierHeading, vecWindDir = windDir, vecCarrierDir = vecCarrierDir}
	
	return offsetData
end

-- Turns carrier into wind
function Windface.BeginOps(carrierData)
	local timeToNextOp = carrierData.nextOpTime - timer.getTime()
	if timeToNextOp > 0 then
		mist.message.add({text = string.format("Carrier is currently recovering position for another %d minutes" , timeToNextOp / 60), displayTime = 10, msgFor = {coa={'all'}}})
		return
	end
	
	local carrierPosition = carrierData.unit:getPosition().p
	local offsetData	= Windface.CalculateOffset(carrierPosition)
	
	local vecEndPoint	= mist.vec.add(carrierPosition, mist.vec.scalar_mult(offsetData.vecCarrierDir, carrierData.zone.radius))

	local route = {} 
	route[1] = mist.ground.buildWP(carrierPosition, 'Cone', offsetData.vSpeed)
	route[2] = mist.ground.buildWP(vecEndPoint, 'Cone', offsetData.vSpeed)
	local route = mist.goRoute(carrierData.group ,route)

	if route == true then
		mist.message.add({text = string.format("Begin Carrier Ops BRC %03d" , (mist.utils.toDegree(mist.utils.getDir(offsetData.vecCarrierDir, carrierPosition)) % 360)), displayTime = 10, msgFor = {coa={'all'}}})
	end
	carrierData.status		= "Active"
end

-- Sends carrier towards the downwind radial of the AO, using the wind from the current carrier position
-- With Dynamic weather this will create some variation in the carrier positioning, but that isn't a big problem
function Windface.EndOps(carrierData)
	local carrierPosition = carrierData.unit:getPosition().p
	local offsetData	= Windface.CalculateOffset(carrierPosition)
	
	local vecReciprocal	= {x = -offsetData.vecCarrierDir.x, y = 0, z = -offsetData.vecCarrierDir.z}
	local vecEndPoint	= mist.vec.add(carrierData.zone.point, mist.vec.scalar_mult(vecReciprocal, carrierData.zone.radius))

	-- Recover at flank speed
	local route = {} 
	route[1] = mist.ground.buildWP(carrierPosition, 'Cone', 15)
	route[2] = mist.ground.buildWP(vecEndPoint, 'Cone', 15)
	local route = mist.goRoute(carrierData.group ,route)
	
	
	if route == true then
		mist.message.add({text = string.format("Carrier Ops suspended, returning to Marshalling point"), displayTime = 10, msgFor = {coa={'all'}}})
	end
	carrierData.status		= "Recovering"
end

-- Cycle carrier ops based on AO location and whether or not there are any valid player aircraft in the area
function Windface.CheckOps(carrierData)
	-- Trigger the TACAN workaround
	trigger.action.pushAITask(carrierData.group, 1)
	
	-- First check that the carrier is still in the AO
	local carrierPosition = carrierData.unit:getPosition().p
	local carrierRadius = mist.vec.mag(mist.vec.sub(carrierPosition, carrierData.zone.point))
	
	env.info( "Carrier radius " .. carrierRadius, false )
	env.info( "Zone radius " .. carrierData.zone.radius, false )
	env.info( "Carrier Status " .. carrierData.status, false )
	if carrierRadius > carrierData.zone.radius then
		Windface.EndOps(carrierData)
		-- The carrier takes 2-5 minutes to get up to speed from stationary
		-- We need to allow the carrier time to recover properly, or else it will get stuck in a very small orbit that will give recovering aircraft very little time to land
		carrierData.nextOpTime = timer.getTime() + 1200
		return
	end
	
	-- TODO: We need to filter based on player aircraft
	local players = coalition.getPlayers(coalition.side.BLUE)
	
	-- Check for any aircraft inside the operation start zone
	if carrierData.status == "Recovering" then
		local playersInsideStartTrigger = 0
		env.info( "Checking for any players inside start trigger", false )
		
		for i = 1, #players do
			local u = players[i]
			local playerName = u:getPlayerName()
			local playerPos = u:getPosition().p
			env.info( mist.utils.serialize('PlayerPosition ', playerPos), false )
			local playerRadius =  mist.vec.mag(mist.vec.sub(carrierPosition, playerPos))
			env.info( "Player Distance to Carrier " .. playerRadius, false )
			if playerRadius < Windface.rStartOps then
				playersInsideStartTrigger = playersInsideStartTrigger + 1
			end
		end
		
		if playersInsideStartTrigger > 0 then
			Windface.BeginOps(carrierData)
		end
		
	-- Check to see that there are zero aircraft inside the operation end zone
	else
		local playersInsideEndTrigger = 0
		env.info( "Checking for zero players inside end trigger", false )
		
		for i = 1, #players do
			local u = players[i]
			local playerName = u:getPlayerName()
			local playerPos = u:getPosition().p
			env.info( mist.utils.serialize('PlayerPosition ', playerPos), false )
			env.info( mist.utils.serialize('CarrierPosition ', carrierPosition), false )
			local playerRadius =  mist.vec.mag(mist.vec.sub(carrierPosition, playerPos))
			env.info( "Player Distance to Carrier " .. playerRadius, false )
			if playerRadius < Windface.rEndOps then
				playersInsideEndTrigger = playersInsideEndTrigger + 1
			end
		end
		
		if playersInsideEndTrigger == 0 then
			Windface.EndOps(carrierData)
		end
	end
end

function Windface.InitCarrier(carrier, zoneName)
	local zone = trigger.misc.getZone(zoneName)
	local carrierUnit = Unit.getByName(carrier)
	
	
	if carrierUnit == nil then
		env.info( "Carrier Unit '" .. carrier .. "' not found", false )
		return
	end
	if zone == nil then
		env.info( "Zone '" .. zoneName .. "' not found", false )
		return
	end
	local carrierGroup		= carrierUnit:getGroup()
	local carrierGroupName	= carrierGroup:getName()
	local carrierPosition	= carrierUnit:getPosition().p
	
	--local vecReciprocal		= {x = -offsetData.vecCarrierDir.x, y = 0, z = -offsetData.vecCarrierDir.z}
	
	local carrierData		= {}
	carrierData.zone		= zone
	carrierData.unit		= carrierUnit
	carrierData.group		= carrierGroup
	carrierData.nextOpTime	= -1
	carrierData.status		= ""
	
	Windface.BeginOps(carrierData)
	
	-- Check operations every 10 minutes
	carrierTickId = mist.scheduleFunction ( Windface.CheckOps, {carrierData}, timer.getTime() + 600, 600 )
	
end

function Windface.InitPlaneGuard(carrier, helicopter, isNew)
	local helicopterUnit = Unit.getByName(helicopter)
	local carrierUnit = Unit.getByName(carrier)
	
	local logOut = ""
	
	if carrierUnit == nil then
		env.info( "Carrier Unit '" .. carrier .. "' not found", false )
		return
	end
	if helicopterUnit == nil then
		env.info( "Helicopter '" .. helicopter .. "' not found", false )
		return
	end
	local carrierGroup		= carrierUnit:getGroup()
	local carrierGroupName	= carrierGroup:getName()
	-- Flatten all the directions and renormalise
	local carrierPosition	= carrierUnit:getPosition().p
	local carrierSBDir		= carrierUnit:getPosition().z
	local carrierDirection	= carrierUnit:getPosition().x
	carrierPosition.y		= 0
	carrierSBDir.y			= 0
	carrierDirection.y		= 0
	carrierSBDir			= mist.vec.scalar_mult(carrierSBDir, mist.vec.mag(carrierSBDir))
	carrierDirection		= mist.vec.scalar_mult(carrierDirection, mist.vec.mag(carrierDirection))
	local carrierVelocity	= carrierUnit:getVelocity()
	
	-- Adjust the starboard position forward 150m
	carrierPosition = mist.vec.add(carrierPosition, mist.vec.scalar_mult(carrierDirection, 150))
	
	env.info( mist.utils.serialize('Helciopter Positional ', helicopterUnit:getPosition()), false )
	local helicopterPosition	= helicopterUnit:getPosition().p
	helicopterPosition.y		= 0
	
	local vecToHelicopter	= mist.vec.sub(helicopterPosition, carrierPosition)
	local dirToHelicopter	= mist.vec.scalar_mult(vecToHelicopter, mist.vec.mag(vecToHelicopter))
	local hCarrierRaw		= mist.utils.getDir(carrierDirection)
	local hToHelicopterRaw	= mist.utils.getDir(dirToHelicopter)
	local hDifference		= math.abs(hCarrierRaw - hToHelicopterRaw)
	
	--[[
	local v = mist.vec.sub(helicopterPosition,carrierPosition)
	local t = mist.vec.dp(v, carrierSBDir)
	local Projection = mist.vec.add(carrierPosition, mist.vec.scalar_mult(carrierSBDir, t))
	stationError	=	mist.vec.mag(mist.vec.sub(Projection, helicopterPosition))
	]]--
	local stationError		= mist.vec.mag(mist.vec.cp(vecToHelicopter, carrierSBDir)) -- |CH x SBDir| / |SBDir| but SBDir is already normalised
	if hDifference < (math.pi * 0.5) then -- We need to reduce speed if we're in front of the carrier starboard line
		stationError = -stationError
	end
	
	-- We have a station error in meters, now convert to a 1 minute speed
	stationError = stationError / 60
	
	local stationPosition	= mist.vec.add(carrierPosition, mist.vec.scalar_mult(carrierSBDir, 180))	-- 0.1nm starboard
	local finalPosition		= mist.vec.add(stationPosition, mist.vec.scalar_mult(carrierVelocity, 300))	-- Station position + 5 minutes travel
	local baseSpeed			= mist.vec.mag(carrierVelocity)
	
	logOut = logOut .. string.format("Carrier Raw Heading: %03d, Heading to Helicopter %03d, Base Speed: %0.2f m/s, Speed Error: %0.2f m/s"
									, mist.utils.toDegree(hCarrierRaw), mist.utils.toDegree(hToHelicopterRaw), baseSpeed, stationError
									)
	--mist.message.add({text = logOut, displayTime = 10, msgFor = {coa={'all'}}})
	
	
	local route = {} 
	route[1] = mist.heli.buildWP(stationPosition, 'flyOverPoint',baseSpeed + stationError, 100)
	--route[2] = mist.heli.buildWP(mist.vec.add(stationPosition, mist.vec.scalar_mult(carrierVelocity, 120)), 'flyOverPoint',baseSpeed + stationError, 100)
	route[2] = mist.heli.buildWP(finalPosition, 'flyOverPoint',baseSpeed + stationError, 100)
	local route = mist.goRoute(helicopterUnit:getGroup(), route)
	env.info(logOut, false )
	--env.info(, false )
	
	-- Check Plane Guard every 60s
	if isNew then
		carrierTickId = mist.scheduleFunction ( Windface.InitPlaneGuard, {carrier, helicopter, false}, timer.getTime() + 60, 60 )
	end
	--timer.scheduleFunction(Windface.InitPlaneGuard, {carrier, helicopter}, timer.getTime() + 60)
	
end
