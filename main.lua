local mod = RegisterMod("Under The Pit", 1)
local game = Game()
local sound = SFXManager()
local rng = RNG()
local rundata = {}
local json = require("json")

-- ===== SAVING SYSTEM ===== --

local function saveData(data)
	data = json.encode(data)
	Isaac.SaveModData(mod, data)
end

local function loadData()
	if Isaac.HasModData(mod) then
		local data = Isaac.LoadModData(mod)
		if data ~= nil then
			return json.decode(data)
		end
	end
	return {}
end

function mod:gameStartSave(fromsave)
	if fromsave == true then
		rundata = loadData()
		return
	end
	rundata = {}
	saveData(rundata)
end

function mod:gameExitSave()
	saveData(rundata)
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.gameStartSave)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.gameExitSave)

-- LOCAL --
--------------------------------
local ghostvacuum_seek = false
--------------------------------
local suck_effect = nil
--------------------------------
local bone_count = 0
local electrodevice_time = 0
local ghostvacuum_time = 0
local lacrimalsac_count = 0
local teslatower_time = 0
--------------------------------
local boglebell_nodrop = false
--------------------------------
local ghost_heart_count = 0
--------------------------------

-- ITEM LIST --
----------------------------------------------------------------------
local acne = Isaac.GetItemIdByName("Acne")
local boglebell = Isaac.GetItemIdByName("Bogle Bell")
local bookofassistance = Isaac.GetItemIdByName("Book of Assistance")
local bookofexodus = Isaac.GetItemIdByName("Book of Exodus")
local brokenmonitor = Isaac.GetItemIdByName("Broken Monitor")
local cressetofgrievance = Isaac.GetItemIdByName("Cresset of Grievance")
local cupidsheart = Isaac.GetItemIdByName("Cupid's Heart")
local deity = Isaac.GetItemIdByName("Deity")
local electrodevice = Isaac.GetItemIdByName("Electro Device")
local emfmeter = Isaac.GetItemIdByName("EMF Meter")
local eyeofthebeholder = Isaac.GetItemIdByName("Eye of the Beholder")
local fissure = Isaac.GetItemIdByName("Fissure")
local gasolinehose = Isaac.GetItemIdByName("Gasoline Hose")
local ghostbelt = Isaac.GetItemIdByName("Ghost Belt")
local ghostvacuum = Isaac.GetItemIdByName("Ghost Vacuum")
local haniwafigure = Isaac.GetItemIdByName("Haniwa Figure")
local isaacssoul = Isaac.GetItemIdByName("Isaac's Soul")
local lacrimalsac = Isaac.GetItemIdByName("Lacrimal Sac")
local modelingclay = Isaac.GetItemIdByName("Modeling Clay")
local puzzler = Isaac.GetItemIdByName("Puzzler")
local rood = Isaac.GetItemIdByName("Rood")
local rottencandy = Isaac.GetItemIdByName("Rotten Candy")
local spectrumcontainer = Isaac.GetItemIdByName("Spectrum Container")
local suspiciousseal = Isaac.GetItemIdByName("Suspicious Seal")
local teslatower = Isaac.GetItemIdByName("Tesla Tower")
local trappedsoul = Isaac.GetItemIdByName("Trapped Soul")
local unholygrail = Isaac.GetItemIdByName("Unholy Grail")
local warpwhistle = Isaac.GetItemIdByName("Warp Whistle")
----------------------------------------------------------------------

-- TRINKET LIST --
----------------------------------------------------------------------
local dynamite = Isaac.GetTrinketIdByName("Dynamite")
local glitchedskull = Isaac.GetTrinketIdByName("Glitched Skull")
local greedypenny = Isaac.GetTrinketIdByName("Greedy Penny")
local infrared = Isaac.GetTrinketIdByName("Infrared")
local proboscis = Isaac.GetTrinketIdByName("Proboscis")
local tournamentticket = Isaac.GetTrinketIdByName("Tournament Ticket")
----------------------------------------------------------------------

-- COSTUMES --
------------------------------------------------------------------------------------------
local deity_costume = Isaac.GetCostumeIdByPath("gfx/characters/deity.anm2")
local lacrimalsac_costume = Isaac.GetCostumeIdByPath("gfx/characters/lacrimal_sac.anm2")
local rood_costume = Isaac.GetCostumeIdByPath("gfx/characters/rood.anm2")
local rottencandy_costume = Isaac.GetCostumeIdByPath("gfx/characters/rotten_candy.anm2")
local teslatower_costume = Isaac.GetCostumeIdByPath("gfx/characters/tesla_tower.anm2")
local unholygrail_costume = Isaac.GetCostumeIdByPath("gfx/characters/unholy_grail.anm2")
------------------------------------------------------------------------------------------
local deity_check = false
local lacrimalsac_check = false
local rood_check = false
local rottencandy_check = false
local teslatower_check = false
local unholygrail_check = false
------------------------------------------------------------------------------------------

-- CARDS --
--------------------------------------------------------------
local GiantBook = Sprite()
GiantBook:Load("gfx/ui/giantbook/giantbook.anm2", false)
--------------------------------------------------------------
local drawtwocard = Isaac.GetCardIdByName("Draw Two Card")
local poundsigncard = Isaac.GetCardIdByName("Pound Sign Card")
local reversecard = Isaac.GetCardIdByName("Reverse Card")
local skipcard = Isaac.GetCardIdByName("Skip Card")
local wildcard = Isaac.GetCardIdByName("Wild Card")
--------------------------------------------------------------

-- RUNES --
------------------------------------------
local calc = Isaac.GetCardIdByName("Calc")
local ear = Isaac.GetCardIdByName("Ear")
local gar = Isaac.GetCardIdByName("Gar")
local ior = Isaac.GetCardIdByName("Ior")
local stan = Isaac.GetCardIdByName("Stan")
------------------------------------------

-- CURSES --
-------------------------------------------------------------------------------
local CURSE_HAUNTED = 1 << (Isaac.GetCurseIdByName("Curse of the Haunted") - 1)
-------------------------------------------------------------------------------

-- CHALLENGES --
-------------------------------------------------------------------------
local CHALLENGE_GHOST_HUNTER = Isaac.GetChallengeIdByName("Ghost Hunter")
-------------------------------------------------------------------------

--========== MC_POST_UPDATE ==========--

function mod:postupdate()
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	GiantBook:Update()
	-- Deity --
	if player:HasCollectible(deity) then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			-- Enemy HP Nerf --
			if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity:GetData().deity_health_check == nil then
				entity:GetData().deity_health_check = true
				if player:GetCollectibleNum(deity) == 1 then
					entity.MaxHitPoints = entity.MaxHitPoints * 0.9
					entity.HitPoints = entity.HitPoints * 0.9
				else
					entity.MaxHitPoints = entity.MaxHitPoints * 0.8
					entity.HitPoints = entity.HitPoints * 0.8
				end
			end
		end
		-- Fake Damage --
		if player:GetData().deity_damage == true then
			player:GetData().deity_damage = nil
			player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 160)
		end
	end
	-- Fissure --
	if player:HasCollectible(fissure) then
		-- Bone Orbital Damage --
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 3 and entity.Variant == 128 then
				if entity:GetData().bone_check == nil then
					entity:GetData().bone_check = true
					bone_count = bone_count + 0.01 -- 1% Damage Multiplier
				end
			end
		end
		-- Bone Orbital Reset --
		if bone_count < 0 then
			bone_count = 0
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	-- Lacrimal Sac --
	if player:HasCollectible(lacrimalsac) then
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end
	-- Rood --
	if player:HasCollectible(rood) then
		-- Devil Room --
		local room = game:GetLevel():GetCurrentRoom()
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 1000 and entity.Variant == 6 and entity:GetData().statue_check == nil then -- Angel Statue
				for j, ent in pairs(Isaac.GetRoomEntities()) do
					if ent.Type == 1000 and ent.Variant == 1 then -- Bomb Explosion
						local distance = (ent.Position - entity.Position):Length()
						if distance <= 80 then
							entity:GetData().statue_check = true
							entity:Remove()
							-- Devil statue check --
							if rundata.devil_statue_bombed == nil then
								rundata.devil_statue_bombed = true
							end
							-- Boss Music --
							if math.random(2) == 1 then
								MusicManager():Play(Music.MUSIC_BOSS, 0.5)
							else
								MusicManager():Play(Music.MUSIC_BOSS2, 0.5)
							end
							-- Unclear room --
							room:SetClear(false)
							for k = 0, DoorSlot.NUM_DOOR_SLOTS -1 do
								local door = room:GetDoor(k)
								if door ~= nil then
									door:Close(true)
								end
							end
							-- Spawn the dark angels --
							if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then -- No keys
								local darkangel = Isaac.Spawn(271, 1, 0, entity.Position, Vector(0,0), entity)
								if darkangel:GetData().custom_dark_angel == nil then
									darkangel:GetData().custom_dark_angel = true
								end
								darkangel.MaxHitPoints = darkangel.MaxHitPoints * 0.67
								darkangel.HitPoints = darkangel.HitPoints * 0.67
							elseif player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then -- Both keys
								if rng:RandomInt(2) == 1 then
									local darkangel = Isaac.Spawn(271, 1, 0, entity.Position, Vector(0,0), entity)
									if darkangel:GetData().custom_dark_angel == nil then
										darkangel:GetData().custom_dark_angel = true
									end
									darkangel.MaxHitPoints = darkangel.MaxHitPoints * 0.67
									darkangel.HitPoints = darkangel.HitPoints * 0.67
								else
									local darkangel = Isaac.Spawn(272, 1, 0, entity.Position, Vector(0,0), entity)
									if darkangel:GetData().custom_dark_angel == nil then
										darkangel:GetData().custom_dark_angel = true
									end								
									darkangel.MaxHitPoints = darkangel.MaxHitPoints * 0.67
									darkangel.HitPoints = darkangel.HitPoints * 0.67
								end
							else -- One key
								local darkangel = Isaac.Spawn(272, 1, 0, entity.Position, Vector(0,0), entity)
								if darkangel:GetData().custom_dark_angel == nil then
									darkangel:GetData().custom_dark_angel = true
								end
								darkangel.MaxHitPoints = darkangel.MaxHitPoints * 0.67
								darkangel.HitPoints = darkangel.HitPoints * 0.67
							end
						end
					end
				end
				-- Check if devil statue was bombed --
				if rundata.devil_statue_bombed == true then
					entity:Remove()
				end
			end
			-- Reverse Pacts --
			local HPcheck = player:GetMaxHearts()
			if room:GetType() == RoomType.ROOM_ANGEL then
				-- Angel Shop --
				if entity.Type == 5 and entity.Variant == 100 and entity:ToPickup():IsShopItem() and entity:ToPickup().Price < 0 then
					if player:GetSoulHearts() >= 6
					or player:GetPlayerType() == PlayerType.PLAYER_THELOST
					or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
					or player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
						if entity:ToPickup().Price ~= -3 then
							entity:ToPickup().Price = -3
						end
					else
						if not player:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
							if entity:ToPickup().Price ~= -2 then
								entity:ToPickup().Price = -2
							end
						else -- Judas Tongue Synergy
							if entity:ToPickup().Price ~= -1 then
								entity:ToPickup().Price = -1
							end
						end
					end
				end
				-- Item Reroll --
				if entity.Type == 5 and entity.Variant == 10 and entity:ToPickup():IsShopItem() and entity:ToPickup().Price > 0 then
					entity:Remove()
					local reroll = Isaac.Spawn(5, 100, 0, entity.Position, Vector(0,0), nil)
					if player:GetSoulHearts() >= 6
					or player:GetPlayerType() == PlayerType.PLAYER_THELOST
					or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
					or player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
						reroll:ToPickup().TheresOptionsPickup = false
						reroll:ToPickup().AutoUpdatePrice = false
						reroll:ToPickup().Price = -3 -- Soul Hearts
					else
						if not player:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
							reroll:ToPickup().TheresOptionsPickup = false
							reroll:ToPickup().AutoUpdatePrice = false
							reroll:ToPickup().Price = -2 --  One Red Heart
						else -- Judas Tongue Synergy
							reroll:ToPickup().TheresOptionsPickup = false
							reroll:ToPickup().AutoUpdatePrice = false
							reroll:ToPickup().Price = -1 --  One Red Heart
						end
					end
				end
			end
		end
		-- Disable statue collision --
		local getroom = game:GetRoom()
		local gridSize = room:GetGridSize()
		for i = 0, gridSize -1 do
			gridEntity = getroom:GetGridEntity(i)
			if (gridEntity ~= nil) then
				local gridType = gridEntity.GetType(gridEntity)
				if gridType == GridEntityType.GRID_STATUE then	
					getroom:RemoveGridEntity(gridEntity:GetGridIndex(), 0, false)
				end
			end
		end
	end
	-- Rotten Candy --
	if player:HasCollectible(rottencandy) then
		if player:GetCollectibleNum(rottencandy) == 1 then
			if rundata.rottencandy_flies == nil then
				player:AddBlueFlies(2, Isaac.GetFreeNearPosition(player.Position, 40), nil)
				rundata.rottencandy_flies = true
			end
		end
		-- Diplopia --
		if player:GetCollectibleNum(rottencandy) == 2 then
			if rundata.rottencandy_flies2 == nil then
				player:AddBlueFlies(2, Isaac.GetFreeNearPosition(player.Position, 40), nil)
				rundata.rottencandy_flies2 = true
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:EvaluateItems()
	end
	-- Tesla Tower --
	if player:HasCollectible(teslatower) then
		if room:GetAliveEnemiesCount() > 0 then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) == false and player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) == false then
				if teslatower_time < 10 then
					if game:GetFrameCount() % player.MaxFireDelay == 0 then
						teslatower_time = teslatower_time + 1
					end
				else
					local enemy = nil
					for i, entity in pairs(Isaac.GetRoomEntities()) do
						if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
							local distance = (player.Position - entity.Position):Length()
							local range = (-player.TearHeight * 5)
							if distance <= range then
								if not player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
									enemy = entity
								else -- Jacob's Ladder Synergy
									local laser = player:FireTechLaser(player.Position, 2, (entity.Position - player.Position):Normalized(), false, true)
									laser:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0, 0, 200), 0, 0, false, true)
									laser.TearFlags = player.TearFlags
									laser.SpriteScale = laser.SpriteScale * 3
									laser.CollisionDamage = player.Damage * 3
									teslatower_time = 0
								end
							end
						end
					end
					if enemy ~= nil then
						local laser = player:FireTechLaser(player.Position, 2, (enemy.Position - player.Position):Normalized(), false, true)
						laser:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0, 191, 255), 0, 0, false, true)
						laser.TearFlags = player.TearFlags
						laser.SpriteScale = laser.SpriteScale * 3
						laser.CollisionDamage = player.Damage * 3
						teslatower_time = 0
					end
				end
			end
		else
			if teslatower_time > 0 then
				teslatower_time = 0
			end
		end
	end
	-- Unholy Grail --
	if player:HasCollectible(unholygrail) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	--===== Trinkets =====--
	if player:HasTrinket(dynamite) then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_BOMBDROP and entity.SpawnerType == 1 and entity:GetData().blaze_check == nil then
				entity:GetData().blaze_check = true
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
					entity.SpriteScale = entity.SpriteScale * 1.1
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
						entity:ToBomb().RadiusMultiplier = 1.25
					else
						entity:ToBomb().RadiusMultiplier = 1.5
					end
				else -- Mom's Box Synergy
					entity.SpriteScale = entity.SpriteScale * 1.2
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
						entity:ToBomb().RadiusMultiplier = 1.5
					else
						entity:ToBomb().RadiusMultiplier = 2
					end
				end
			end
		end
	end
	-- Infrared --
	if player:HasTrinket(infrared) then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			-- Laser --
			if entity.Type == EntityType.ENTITY_LASER and (entity.SpawnerType ~= 1 and entity.SpawnerType ~= 3 and entity.SpawnerType ~= 4) then
				entity:ToLaser():SetHomingType(0)
			end
			-- Projectile --
			if entity.Type == EntityType.ENTITY_PROJECTILE and (entity.SpawnerType ~= 1 and entity.SpawnerType ~= 3 and entity.SpawnerType ~= 4) then
				entity:ToProjectile().HomingStrength = 0
			end
		end
	end
	-- Proboscis --
	if player:HasTrinket(proboscis) then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			-- Enemy Bullet --
			if entity.Type == EntityType.ENTITY_PROJECTILE then
				for j, ent in pairs(Isaac.GetRoomEntities()) do
					if ent.Type == 3 and ent.Variant == 43 then -- Blue Fly
						local distance = (entity.Position - ent.Position):Length()
						if distance <= 15 then
							entity:Kill()
						end
					end
				end
			end
			-- Enemy Creep --
			if entity.Type == 1000 and (entity.Variant == 22 or entity.Variant == 23 or entity.Variant == 24 or entity.Variant == 25 or entity.Variant == 26) then
				for j, ent in pairs(Isaac.GetRoomEntities()) do
					if ent.Type == 3 and ent.Variant == 73 then -- Blue Spider
						local distance = (entity.Position - ent.Position):Length()
						if distance <= 15 then
							entity:Kill()
						end
					end
				end
			end
		end
	end
	-- Tournament Ticket --
	if player:HasTrinket(tournamentticket) then
		if room:IsClear() then
			local gridSize = room:GetGridSize()
			for i = 1, gridSize do
				gridEntity = room:GetGridEntity(i)
				if (gridEntity ~= nil) then
					local gridVariant = gridEntity.GetVariant(gridEntity)
					local gridDoor = gridEntity:ToDoor()
					if gridDoor and gridVariant ~= 7 then
						if gridDoor.TargetRoomType == RoomType.ROOM_CHALLENGE and gridDoor:IsLocked() then
							gridDoor:Open()
						end
					end
				end
			end
		end
	end
	--=== Devil Chest ===--
	if rundata.devilchest ~= nil then
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
	--=== Ghost Hunter Challenge ===--
	if game.Challenge == CHALLENGE_GHOST_HUNTER then
		game:Darken(1,10)
		-- Check Ghost Vacuum --
		if rundata.ghosthunter_challenge == nil then
			rundata.ghosthunter_challenge = true
			player:AddCollectible(ghostvacuum, 6, false)
		end
		-- Night Light Item --
		if not player:HasCollectible(425) then
			player:AddCollectible(425, 0, false)
		end
		-- Entities --
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsVulnerableEnemy() and entity:IsBoss() == false and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity:HasEntityFlags(EntityFlag.FLAG_CHARM) == false and entity:ToNPC():IsChampion() == false then
				if entity:GetData().ghosthunter_check == nil then
					entity:GetData().ghosthunter_check = true
					entity:SetColor(Color(1.0, 1.0, 1.0, 0.3, 0, 0, 0), 0, 0, false, false)
				end
			end
			if entity:GetData().ghosthunter_check == true then
				if entity:HasEntityFlags(EntityFlag.FLAG_SLOW) then
					entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				else
					entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				end
			end
		end
	end
end

--========== MC_EVALUATE_CACHE ==========--

function mod:evaluatecache(player, cacheFlag)
	local room = game:GetLevel():GetCurrentRoom()
	-- Fissure --
	if player:HasCollectible(fissure) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE and bone_count > 0 then
			player.Damage = player.Damage * (bone_count + 1)
		end
	end
	-- Lacrimal Sac --
	if player:HasCollectible(lacrimalsac) and player:GetData().sac_collect ~= nil then
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			local MIN_TEAR_DELAY = 5
			if player.MaxFireDelay >= MIN_TEAR_DELAY then
				player.MaxFireDelay = player.MaxFireDelay - player:GetData().sac_collect
			elseif player.MaxFireDelay < MIN_TEAR_DELAY and player:GetData().sac_collect > 0 then
				player:GetData().sac_collect = player:GetData().sac_collect - 1
			end
		end
	end
	-- Rotten Candy --
	if player:HasCollectible(rottencandy) then
		if player:GetCollectibleNum(rottencandy) == 1 then
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				local MIN_TEAR_DELAY = 5
				if player.MaxFireDelay >= MIN_TEAR_DELAY + 1 then
					player.MaxFireDelay = player.MaxFireDelay - 1
				elseif player.MaxFireDelay >= MIN_TEAR_DELAY then
					player.MaxFireDelay = MIN_TEAR_DELAY
				end
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 0.15
			end
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + 0.05
			end
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + 0.05
			end
			if cacheFlag == CacheFlag.CACHE_RANGE then
				player.TearHeight = player.TearHeight - 2.5
			end
		else -- Diplopia
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				local MIN_TEAR_DELAY = 5
				if player.MaxFireDelay >= MIN_TEAR_DELAY + 2 then
					player.MaxFireDelay = player.MaxFireDelay - 2
				elseif player.MaxFireDelay >= MIN_TEAR_DELAY then
					player.MaxFireDelay = MIN_TEAR_DELAY
				end
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 0.3
			end
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + 0.1
			end
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + 0.1
			end
			if cacheFlag == CacheFlag.CACHE_RANGE then
				player.TearHeight = player.TearHeight - 5
			end
		end
	end
	-- Unholy Grail --
	if player:HasCollectible(unholygrail) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE and rundata.unholy_bonus_damage ~= nil then
			if rundata.unholy_bonus_damage <= 100 then
				local damage = 1 + (rundata.unholy_bonus_damage * 0.005) -- 100 Champion enemies limit
				player.Damage = player.Damage * damage
			elseif rundata.unholy_bonus_damage == 100 then
				player.Damage = player.Damage * 1.5
			else
				sound:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
				rundata.unholy_bonus_damage = nil
				player:AddMaxHearts(2)
				player:AddHearts(2)
				Isaac.Spawn(1000, 49, 0, player.Position, Vector(0,0), player)
			end
		end
	end
	--=== Devil Chest ===--
	if rundata.devilchest == true then
		-- Random Stat Up --
		-- Firedelay --
		if rundata.devilchest_firedelay ~= nil then
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				local MIN_TEAR_DELAY = 5
				if player.MaxFireDelay >= MIN_TEAR_DELAY + rundata.devilchest_firedelay then
					player.MaxFireDelay = player.MaxFireDelay - rundata.devilchest_firedelay
				elseif player.MaxFireDelay >= MIN_TEAR_DELAY then
					player.MaxFireDelay = MIN_TEAR_DELAY
				end
			end
		end
		-- Damage --
		if rundata.devilchest_damage ~= nil then
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + rundata.devilchest_damage
			end
		end
		-- Shotspeed --
		if rundata.devilchest_shotspeed ~= nil then
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + rundata.devilchest_shotspeed
			end
		end
		-- Speed --
		if rundata.devilchest_speed ~= nil then	
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + rundata.devilchest_speed
			end
		end
		-- Range --
		if rundata.devilchest_range ~= nil then
			if cacheFlag == CacheFlag.CACHE_RANGE then
				player.TearHeight = player.TearHeight - rundata.devilchest_range
			end
		end
		-- Luck --
		if rundata.devilchest_luck ~= nil then
			if cacheFlag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck + rundata.devilchest_luck
			end
		end
	end
end

--========== MC_NPC_UPDATE ==========--

function mod:npcupdate(npc)
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	-- Dripler --
	if npc.Type == 288 and npc.Variant == 600 then
		if npc:GetSprite():IsEventTriggered("Bleed") then
			Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0,0), npc)
		end
	end
	-- Host Creep --
	if npc.Type == 242 and npc.Variant == 600 then
		-- Attack --
		if npc:GetSprite():IsEventTriggered("Shoot") then
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 9 and entity.SpawnerType == 242 and entity.SpawnerVariant == 600 then
					entity:Remove()
				end
			end
			local angle = ((player.Position - npc.Position) + Vector(0,15)):GetAngleDegrees()
			local shot = Isaac.Spawn(9, 0, 0, npc.Position:__sub(Vector(0,-15)), Vector.FromAngle(angle):Resized(9), nil):ToProjectile()
			shot:AddHeight(-8.5)
			shot:AddFallingAccel(-0.02)
		end
	end
	-- Mangled Gaper --
	if npc.Type == 21 and npc.Variant == 600 then
		-- Red Creep --
		if npc.SubType == 0 or npc.SubType == 1 then
			if npc:GetSprite():IsEventTriggered("Bleed") then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 1, npc.Position, Vector(0,0), npc)
			end
		end
		-- Blue Creep --
		if npc.SubType == 2 then
			if npc:GetSprite():IsEventTriggered("Bleed") then
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 1, npc.Position, Vector(0,0), npc):ToEffect()
				creep.Color = Color(1.0, 1.0, 1.0, 1.0, 10, 200, 255)
				creep:Update()
			end
		end
	end
	-- Walrus --
	if npc.Type == 902 and npc.Variant == 0 then
		-- Spawn --
		if npc:GetData().walrus_spawn == nil then
			npc:GetData().walrus_spawn = true
			npc:GetSprite():Play("Appear", true)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		end
		-- First Event --
		if npc:GetSprite():IsEventTriggered("effW") and npc:GetSprite():IsPlaying("Idle") then
			Isaac.Spawn(1000,6,600,npc.Position, Vector(0,0),npc)
			sound:Play(Isaac.GetSoundIdByName("Vilez"), 1, 0, false, 1)
		end
		-- Second Event --
		if npc:GetSprite():IsEventTriggered("effW2") and npc:GetSprite():IsPlaying("Idle") then
			Isaac.Spawn(1000,6,600,npc.Position, Vector(0,0),npc)
			sound:Play(Isaac.GetSoundIdByName("Zalez"), 1, 0, false, 1)
		end
		-- Third Event --
		if npc:GetSprite():IsEventTriggered("effW3") and npc:GetSprite():IsPlaying("Idle") then
			Isaac.Spawn(1000,6,600,npc.Position, Vector(0,0),npc)
			sound:Play(Isaac.GetSoundIdByName("Water Shoot"), 1, 0, false, 1)
		end
		-- Shoot --
		local angle = (player.Position - npc.Position):GetAngleDegrees()
		if npc:GetSprite():IsEventTriggered("WaterPoof") then
			for i = 1, 12 do
				local params = ProjectileParams()
				params.Variant = 4
				params.FallingSpeedModifier = -math.random(8,35) * 0.4
				params.FallingAccelModifier = 0.5
				npc:FireProjectiles(npc.Position, Vector.FromAngle(angle+math.random(1,25)):Resized(math.random(3,9)), 0, params)
			end
		end
		-- Burrow --
		if npc:GetSprite():IsFinished("Appear") or npc:GetSprite():IsFinished("Idle") then
			npc:GetSprite():Play("Move", true)
		end
		-- Movement --
		if npc:GetSprite():IsPlaying("Move") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
			-- Timer --
			if npc:GetData().walrus_time == nil then
				npc:GetData().walrus_time = 0
			else
				if (npc:GetData().walrus_time > 30 and math.random(100) == 1) or npc:GetData().walrus_time > 220 then
					npc:GetSprite():Play("Idle", true)
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
					npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
					npc:GetData().walrus_time = 0
				else
					npc:GetData().walrus_time = npc:GetData().walrus_time + 1
				end
			end
			-- Random Movement --
			if npc:GetData().walrus_move == nil then
				npc:GetData().walrus_move = 0
				npc:GetData().walrus_moveangle = Vector(math.random(-360,360),math.random(-360,360)):GetAngleDegrees()
				npc:GetData().walrus_movespeed = math.random(1500,6000)
			else
				if npc:GetData().walrus_move < 30 and math.random(50) > 1 then
					npc:GetData().walrus_move = npc:GetData().walrus_move + 1
					npc.Velocity = Vector.FromAngle(npc:GetData().walrus_moveangle):Resized(npc:GetData().walrus_movespeed)
				else
					npc:GetData().walrus_move = 0
					npc:GetData().walrus_moveangle = Vector(math.random(-360,360),math.random(-360,360)):GetAngleDegrees()
					npc:GetData().walrus_movespeed = math.random(1500,6000)
				end
			end
		end
		-- Clear Flags --
		if npc:GetSprite():IsPlaying("Idle") then
			if npc:GetData().walrus_move ~= nil then
				npc:GetData().walrus_move = nil
				npc:GetData().walrus_moveangle = 0
				npc:GetData().walrus_movespeed = 0
			end
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
		end
	end
	if npc.Type == 1000 and npc.Variant == 6 and npc.SubType == 600 then -- Water Effect --
		if npc:GetSprite():IsEventTriggered("Ssui") then
			npc:Remove()
		end
	end
	--=== Enemy Replacement ===--
	-- Blue Gaper -> Blue Mangled Gaper
	if (npc.Type == 297 or npc.Type == 298) and npc.Variant == 0 then
		if npc:GetData().bluegaper_replace == nil then
			npc:GetData().bluegaper_replace = true
			if rng:RandomInt(3) == 1 then -- 33% Chance
				npc:Remove()
				local replaced = Isaac.Spawn(21, 600, 2, npc.Position, Vector(0,0), npc)
				replaced:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
	end
	-- Electro Device EMP Timer --
	if npc:GetData().electro_effect == true then
		-- Timer --
		local count = 300
		if npc:GetData().electro_effect_count == nil then
			npc:GetData().electro_effect_count = 0
		elseif npc:GetData().electro_effect_count >= count then
			npc:GetData().electro_effect = nil
			npc:GetData().electro_effect_count = nil
		else
			npc:GetData().electro_effect_count = npc:GetData().electro_effect_count + 1
			if game:GetFrameCount() % 2 == 0 then
				npc:SetColor(Color(0.0, 0.0, 1.0, 1.0, 0, 0, 0), 2, 0, false, true)
				if npc.HitPoints > 0 then
					local damage = 1 / player.MaxFireDelay
					npc.HitPoints = npc.HitPoints - damage
				end
			end
		end
		-- Projectile Repel --
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if (entity.Type == 7 or entity.Type == 9) and entity.SpawnerType == npc.Type then
				entity:Remove()
			end
		end
	end
	--==================== Poop Mimics ====================--
	--=== Poop Mimics ===--
	if npc.Type == 900 then
		-- Npc Flags --
		if npc:GetData().poop_mimic_flags == nil then
			npc:GetData().poop_mimic_flags = true
			npc:GetSprite():Play("Idle")
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		end
		-- Wait for the player --
		if npc:GetData().poop_mimic_surprise == nil and player:GetMovementDirection() ~= Direction.NO_DIRECTION then
			local distance = (player.Position - npc.Position):Length()
			if distance <= 150 then
				npc:GetData().poop_mimic_surprise = true
				npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
				npc:GetSprite():Play("Surprise")
			end
		end
		-- Surprise Animation --
		if npc:GetSprite():IsFinished("Surprise") then
			npc:GetData().poop_mimic_surprise = false
			npc:GetSprite():Play("Wait")
		end
		-- Waiting Animation --
		if npc:GetData().poop_mimic_surprise == false then
			if npc:GetSprite():IsPlaying("Wait") then
				-- Timer --
				if npc:GetData().poop_mimic_time == nil then
					npc:GetData().poop_mimic_time = 0
				else
					if npc:GetData().poop_mimic_time < 30 then
						npc:GetData().poop_mimic_time = npc:GetData().poop_mimic_time + 1
					else
						if npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) == false then
							npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
						end
						local distance = (player.Position - npc.Position):Length()
						if distance <= 150 then
							npc:GetSprite():Play("Shoot")
							npc:GetData().poop_mimic_time = 0
							if npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
								npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
							end
						end
					end
				end
			end
			if npc:GetSprite():IsFinished("Shoot") then
				npc:GetSprite():Play("Wait")
			end
		end
		-- Reward Animation --
		if npc:GetSprite():IsPlaying("Death") then
			-- Difficulty Check --
			if npc:GetSprite():GetFrame() == 15 then
				if game.Difficulty ~= Difficulty.DIFFICULTY_NORMAL and game.Difficulty ~= DIFFICULTY_GREED then
					if rng:RandomInt(3) ~= 1 then
						npc:GetSprite():SetFrame("Death", 25)
					end
				end
			end
			-- Shoot Drop --
			if npc:GetSprite():IsEventTriggered("Reward") then
				local target = npc:ToNPC():GetPlayerTarget()
				local angle = ((target.Position - npc.Position) - Vector(0,32)):GetAngleDegrees()
				if npc.Variant == 0 then -- Brown Poop Mimic
					local chance = math.random(4)
					if chance == 1 then
						Isaac.Spawn(5, 10, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Random Heart
					elseif chance == 2 then
						Isaac.Spawn(5, 20, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Random Penny
					elseif chance == 3 then
						Isaac.Spawn(5, 30, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Random Key
					else
						Isaac.Spawn(5, 40, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Random Bomb
					end
				elseif npc.Variant == 1 then -- Red Poop Mimic
					local chance = math.random(3)
					if chance == 1 then
						Isaac.Spawn(5, 10, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Red Heart
					elseif chance == 2 then
						Isaac.Spawn(5, 70, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Random Pill
					else
						Isaac.Spawn(5, 300, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Random Card
					end
				elseif npc.Variant == 2 then -- Corny Poop Mimic
					local chance = math.random(3)
					if chance == 1 then
						Isaac.Spawn(5, 50, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(18), npc) -- Random Chest
					elseif chance == 2 then
						Isaac.Spawn(5, 69, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Sack
					else
						Isaac.Spawn(5, 350, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Trinket
					end
				elseif npc.Variant == 3 then -- Black Poop Mimic
					local chance = math.random(3)
					if chance == 1 then
						Isaac.Spawn(5, 10, 3, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Soul Heart
					elseif chance == 2 then
						Isaac.Spawn(5, 10, 6, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Black Heart
					else
						Isaac.Spawn(5, 360, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Red Chest
					end
				elseif npc.Variant == 4 then -- Golden Poop Mimic
					local chance = math.random(3)
					if chance == 1 then
						Isaac.Spawn(5, 10, 7, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Gold Heart
					elseif chance == 2 then
						Isaac.Spawn(5, 30, 2, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Gold Key
					else
						Isaac.Spawn(5, 40, 4, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Gold Bomb
					end
				elseif npc.Variant == 5 then -- Rainbow Poop Mimic
					Isaac.Spawn(5, 100, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Pedestal Item
				elseif npc.Variant == 6 then
					local chance = math.random(2)
					if chance == 1 then
						Isaac.Spawn(5, 10, 10, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Eternal Heart
					else
						Isaac.Spawn(5, 53, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(6), npc) -- Eternal Chest
					end
				end
			end
		end
		-- Death Animation --
		if npc:GetSprite():IsFinished("Death") then
			npc:Remove()
			local variant = npc.Variant
			Isaac.GridSpawn(GridEntityType.GRID_POOP, variant, npc.Position, true)
		end
		--===== Poop Mimic Attacks =====--
		if npc.Variant == 0 then -- Brown Poop Mimic
			local target = npc:ToNPC():GetPlayerTarget()
			local angle = ((target.Position - npc.Position) - Vector(0,32)):GetAngleDegrees()
			-- Surprise Attack --
			if npc:GetSprite():IsEventTriggered("Surprise") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.5)
				local shot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(12), npc)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				shot:SetColor(Color(1.0, 0.3, 0.3, 0.7, 0.5, 0, 0), 0, 0, false, false)
				shot:ToProjectile():AddFallingAccel(-0.02)
				shot:ToProjectile().Scale = shot:ToProjectile().Scale + 0.6
			end
			-- Normal Attack --
			if npc:GetSprite():IsEventTriggered("Shoot") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.25)
				local shot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(10), npc)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				shot:SetColor(Color(1.0, 1.0, 1.0, 0.7, 0, 0, 0), 0, 0, false, false)
				shot:ToProjectile():AddFallingAccel(-0.02)
			end
		end
		if npc.Variant == 1 then -- Red Poop Mimic
			local target = npc:ToNPC():GetPlayerTarget()
			local angle = ((target.Position - npc.Position) - Vector(0,32)):GetAngleDegrees()
			-- Surprise Attack --
			if npc:GetSprite():IsEventTriggered("Surprise") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.5)
				local shot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(angle):Resized(12), npc)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				shot:SetColor(Color(1.0, 0.3, 0.3, 0.7, 0, 0, 0), 0, 0, false, false)
				shot:ToProjectile():AddFallingAccel(-0.02)
				shot:ToProjectile().Scale = shot:ToProjectile().Scale + 0.6
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.RED_CREEP)
			end
			-- Normal Attack 1 --
			if npc:GetSprite():IsEventTriggered("Shoot") then
				local randomangle = ((target.Position - npc.Position) + Vector(math.random(-60,60),math.random(-60,60))):GetAngleDegrees()
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.25)
				local shot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position:__sub(Vector(0,-32)), Vector.FromAngle(randomangle):Resized(10), npc)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				shot:SetColor(Color(1.0, 1.0, 1.0, 0.7, 0, 0, 0), 0, 0, false, false)
				shot:ToProjectile():AddFallingAccel(-0.02)
			end
			-- Normal Attack 2 --
		end
		if npc.Variant == 2 then -- Corny Poop Mimic
			local target = npc:ToNPC():GetPlayerTarget()
			local angle = ((target.Position - npc.Position) - Vector(0,32)):GetAngleDegrees()
			-- Surprise Attack --
			if npc:GetSprite():IsEventTriggered("Surprise") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.5)
				local shot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 5, 0, npc.Position:__add(Vector(0,32)), Vector.FromAngle(angle):Resized(12), npc)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				shot:SetColor(Color(1.0, 0.3, 0.3, 0.7, 0, 0, 0), 0, 0, false, false)
				shot:ToProjectile():AddFallingAccel(-0.02)
				shot:ToProjectile().Scale = shot:ToProjectile().Scale + 0.2
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.BOOMERANG)
			end
			-- Normal Attack --
			if npc:GetSprite():IsEventTriggered("Shoot") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.25)
				local shot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 5, 0, npc.Position:__add(Vector(0,32)), Vector.FromAngle(angle):Resized(6), npc)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				shot:SetColor(Color(1.0, 1.0, 1.0, 0.7, 0, 0, 0), 0, 0, false, false)
				shot:ToProjectile():AddFallingAccel(-0.005)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.SINE_VELOCITY)
				shot:ToProjectile():AddProjectileFlags(ProjectileFlags.BURST)
			end
		end
		if npc.Variant == 5 then -- Black Poop Mimic
			local target = npc:ToNPC():GetPlayerTarget()
			local angle = (target.Position - npc.Position):GetAngleDegrees()
			-- Surprise Attack --
			if npc:GetSprite():IsEventTriggered("Surprise") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.5)
				local angle = (player.Position - npc.Position):GetAngleDegrees() + player:GetVelocityBeforeUpdate()
				local brimstone = EntityLaser.ShootAngle(1, npc.Position, angle, 10, Vector(0,0), npc)
				brimstone:SetColor(Color(1.0, 0.3, 0.3, 1.0, 0, 0, 0), 0, 0, false, false)
			end
			-- Normal Attack --
			if npc:GetSprite():IsEventTriggered("Shoot") then
				sound:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.25)
				local angle = (player.Position - npc.Position):GetAngleDegrees()
				local brimstone = EntityLaser.ShootAngle(1, npc.Position, angle, 10, Vector(0,0), npc)
			end
		end
	end
end

--========== MC_POST_PICKUP_UPDATE ==========--

function mod:pickupupdate(pickup)
	local player = Isaac.GetPlayer(0)
	local room = game:GetLevel():GetCurrentRoom()
	--=== Devil Chest ===--
	-- Appear --
	if pickup.Variant == 5 and pickup.SubType == 360 and pickup:GetData().devil_chest_check == nil then -- Red Chest
		pickup:GetData().devil_chest_check = true
		if pickup:GetSprite():IsPlaying("Appear") then
			if rng:RandomInt(50) == 1 then -- 2% Chance
				npc:Morph(5, 600, 3, -1)
			end
		end
	end
	if pickup.Variant == 600 and pickup.SubType == 3 then -- Devil Chest
		-- Open Chest --
		local distance1 = (player.Position - pickup.Position):Length()
		local distance2 = player.Size + pickup.Size
		if distance1 < distance2 then
			if player:GetMaxHearts() > 0 and pickup:GetSprite():IsPlaying("Idle") then
				player:AddMaxHearts(-2)
				if player:GetMaxHearts() == 0 and player:GetSoulHearts() == 0 then -- Kills Isaac if not having any hearts
					player:TakeDamage(666, DamageFlag.DAMAGE_DEVIL, EntityRef(pickup), 0)
				end
				pickup:GetSprite():Play("Open")
			end
		end
		-- Remove --
		if pickup:GetSprite():IsFinished("Open") then
			pickup:Remove()
		end
		-- Drop Sound / Rewards --
		if pickup:GetSprite():IsEventTriggered("DropSound") then
			sound:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0, false, 1)
			local chance = pickup:GetDropRNG():RandomInt(5)
			if chance == 1 then -- Nothing
				local poof = Isaac.Spawn(1000, 16, 0, pickup.Position, Vector(0,0), pickup)
				poof:SetColor(Color(0.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
			else
				sound:Play(SoundEffect.SOUND_SATAN_SPIT, 1, 0, false, 1)
				local chance2 = pickup:GetDropRNG():RandomInt(4)
				if chance2 == 1 then -- Devil Item
					local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector(0,0), pickup)
					poof:SetColor(Color(0.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
					Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_DEVIL, true, room:GetDecorationSeed()), Isaac.GetFreeNearPosition(pickup.Position, 80), Vector(0,0), pickup)
				elseif chance2 == 2 then -- Random Stat Up
					local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector(0,0), pickup)
					poof:SetColor(Color(1.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
					-- Stats --
					if rundata.devilchest == nil then
						rundata.devilchest = true
					end
					local chance3 = pickup:GetDropRNG():RandomInt(6)
					if chance3 == 1 then
						if rundata.devilchest_firedelay == nil then -- Firedelay
							rundata.devilchest_firedelay = 1
						else
							rundata.devilchest_firedelay = rundata.devilchest_firedelay + 1
						end
					elseif chance3 == 2 then
						if rundata.devilchest_damage == nil then -- Damage
							rundata.devilchest_damage = 1.5
						else
							rundata.devilchest_damage = rundata.devilchest_damage + 1.5
						end
					elseif chance3 == 3 then
						if rundata.devilchest_shotspeed == nil then -- Shotspeed
							rundata.devilchest_shotspeed = 0.2
						else
							rundata.devilchest_shotspeed = rundata.devilchest_shotspeed + 0.2
						end
					elseif chance3 == 4 then
						if rundata.devilchest_speed == nil then -- Speed
							rundata.devilchest_speed = 0.2
						else
							rundata.devilchest_speed = rundata.devilchest_speed + 0.2
						end
					elseif chance3 == 5 then
						if rundata.devilchest_range == nil then -- Range
							rundata.devilchest_range = 5.25
						else
							rundata.devilchest_range = rundata.devilchest_range + 5.25
						end
					else
						if rundata.devilchest_luck == nil then -- Luck
							rundata.devilchest_luck = 1
						else
							rundata.devilchest_luck = rundata.devilchest_luck + 1
						end
					end
					local distance = (player.Position - pickup.Position)
					local angle = distance:GetAngleDegrees()
					-- Aesthetic Laser --
					laser = EntityLaser.ShootAngle(5, pickup.Position, angle, 1, Vector(0,0), player)
					laser:SetColor(Color(1.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
					laser.SpriteScale = laser.SpriteScale * 0.25
					laser.CollisionDamage = 0
					laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					laser:SetMaxDistance(distance:Length())
				elseif chance2 == 3 then -- Runes
					local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector(0,0), pickup)
					poof:SetColor(Color(0.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
					local pickCount = (pickup:GetDropRNG():RandomInt(3) + 1)
					for i = 1, pickCount do
						Isaac.Spawn(5, 301, 0, pickup.Position, Vector((math.random(40)-30)/4,(math.random(40)-30)/4), pickup)
					end
				else -- Black Hearts
					local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector(0,0), pickup)
					poof:SetColor(Color(0.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
					local pickCount = (pickup:GetDropRNG():RandomInt(3) + 1)
					for i = 1, pickCount do
						Isaac.Spawn(5, 10, 6, pickup.Position, Vector((math.random(40)-30)/4,(math.random(40)-30)/4), pickup)
					end
				end
			end
		end
		-- Evil Laugh --
		if pickup:GetSprite():IsEventTriggered("EvilLaugh") then
			sound:Play(SoundEffect.SOUND_BROWNIE_LAUGH, 1, 0, false, 1.5)
		end
	end
end

--========== MC_ENTITY_TAKE_DMG ==========--

function mod:entitydamage(entity, amount, flag, source, countdown)
	local player = Isaac.GetPlayer(0)
	local room = game:GetLevel():GetCurrentRoom()
	-- Deity --
	if player:HasCollectible(deity) then
		if entity.Type == EntityType.ENTITY_PLAYER and flag ~= DamageFlag.DAMAGE_FAKE then
			local chance = (rng:RandomInt(110) + 1)
			if (chance + math.ceil(player.Luck * 7.5)) > 90 then -- 10% Chance / 50% Chance with at least 12 luck
				if rng:RandomInt(2) == 1 then
					if player:GetData().deity_damage == nil then
						player:GetData().deity_damage = true
						Isaac.Spawn(1000, 112, 0, player.Position, Vector(0,0), player)
						return false
					end
				end
			end
		end
	end
	-- Fissure --
	if player:HasCollectible(fissure) then
		-- Boneless Player --
		if entity.Type == EntityType.ENTITY_PLAYER and flag ~= DamageFlag.DAMAGE_FAKE then
			for i, ent in pairs(Isaac.GetRoomEntities()) do
				bone_count = 0
				if ent.Type == 3 and ent.Variant == 128 then
					ent:Kill()
					player:AnimatePitfallOut()
				end
			end
		end
		-- Boneless Enemy --
		if entity:IsVulnerableEnemy() and amount >= entity.HitPoints then
			local chance = (rng:RandomInt(100) + 1)
			if (chance + math.ceil(player.Luck * 3.7)) > 90 then -- 10% Chance / 100% Chance with at least 24 luck
				Isaac.Spawn(3, 128, 0, entity.Position, Vector(0,0), player)
			end
		end
		-- Bone Orbital Dies --
		if entity.Type == 3 and entity.Variant == 128 and amount >= entity.HitPoints then
			bone_count = bone_count - 0.01
		end
	end
	-- Lacrimal Sac --
	if player:HasCollectible(lacrimalsac) then
		-- Tear Effect --
		if entity:IsVulnerableEnemy() and amount >= entity.HitPoints and entity:GetData().sac_damage == nil then
			entity:GetData().sac_damage = true
			if player.MaxFireDelay > 5 then
				if player:GetData().sac_collect == nil then player:GetData().sac_collect = 0 end
				player:GetData().sac_collect = player:GetData().sac_collect + 1
			end
		end
		-- Tear Reset --
		if entity.Type == EntityType.ENTITY_PLAYER then
			for i = 1, lacrimalsac_count do
				local p = player.ShotSpeed * 10
				local n = (-player.ShotSpeed) * 10
				player:FireTear(player.Position, Vector(math.random(n,p),math.random(n,p)), false, false, false)
			end
			if flag ~= DamageFlag.DAMAGE_FAKE then
				lacrimalsac_count = 0
			end
		end
	end
	-- Rood --
	if player:HasCollectible(rood) then
		-- Player Hit --
		if entity.Type == EntityType.ENTITY_PLAYER then
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
					if not entity:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
						entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
						entity:GetData().rood_bleeding = true
					end
					local room = game:GetLevel():GetCurrentRoom()
					room:EmitBloodFromWalls(1,5)
				end
			end
		end
		-- Dark Angel Death --
		if room:GetType() == RoomType.ROOM_DEVIL then
			if (entity.Type == 271 or entity.Type == 272) and amount >= entity.HitPoints and entity:GetData().custom_dark_angel == true and entity:GetData().dead_angel == nil then
				entity:GetData().dead_angel = true
				if not player:HasTrinket(TrinketType.TRINKET_FILIGREE_FEATHERS) then
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
						Isaac.Spawn(5, 100, 238, Isaac.GetFreeNearPosition(entity.Position,40), Vector(0,0), entity)
					elseif player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) and not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
						Isaac.Spawn(5, 100, 238, Isaac.GetFreeNearPosition(entity.Position,40), Vector(0,0), entity)
					elseif player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
						Isaac.Spawn(5, 100, 239, Isaac.GetFreeNearPosition(entity.Position,40), Vector(0,0), entity)
					end
				else -- Filigree Feathers Synergy
					if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
					else
						Isaac.Spawn(5, 100, 0, Isaac.GetFreeNearPosition(entity.Position,40), Vector(0,0), entity)
					end
				end
			end
		end
	end
	-- Unholy Grail --
	if player:HasCollectible(unholygrail) then
		if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and amount >= entity.HitPoints then
			local distance = (player.Position - entity.Position)
			local angle = distance:GetAngleDegrees()
			laser = EntityLaser.ShootAngle(5, entity.Position, angle, 1, Vector(0,0), player)
			laser:SetColor(Color(1.0, 0.0, 0.0, 1.0, 0, 0, 0), 0, 0, false, false)
			laser.SpriteScale = laser.SpriteScale * 0.25
			laser.CollisionDamage = 0
			laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			laser:SetMaxDistance(distance:Length())
			if rundata.unholy_bonus_damage == nil then
				rundata.unholy_bonus_damage = 0
			end
			rundata.unholy_bonus_damage = rundata.unholy_bonus_damage + 1
		end
	end
	--===== NPCS =====--
	-- Dripler --
	if entity.Type == 288 and entity.Variant == 600 then
		if amount >= entity.HitPoints then
			local chance = math.random(2)
			if chance == 1 then -- Cardinal --
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(0,1):Normalized() * 10, entity)
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(1,0):Normalized() * 10, entity)
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(0,-1):Normalized() * 10, entity)
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(-1,0):Normalized() * 10, entity)
			else -- Diagonal --
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(1,1):Normalized() * 10, entity)
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(-1,1):Normalized() * 10, entity)
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(-1,-1):Normalized() * 10, entity)
				Isaac.Spawn(9, 1, 0, entity.Position, Vector(1,-1):Normalized() * 10, entity)
			end
		end
	end
	-- Flaming Mangled Gaper --
	if entity.Type == 21 and entity.Variant == 600 and entity.SubType == 1 then
		if amount >= entity.HitPoints then
			local fire = Isaac.Spawn(1000, 51, 0, entity.Position, Vector(0,0), npc):ToEffect()
			fire:SetDamageSource(9)
			fire:SetTimeout(400)
		end
	end
	-- Host Creep --
	if entity.Type == 242 and entity.Variant == 600 then
		if entity:GetSprite():IsPlaying("Walk") then
			return false
		end
	end
	--===== Poop Mimics =====--
	-- Poop Mimic --
	if entity.Type == 900 then
		local room = game:GetLevel():GetCurrentRoom()
		if entity:GetData().poop_mimic_surprise == nil then
			entity:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
			entity:GetSprite():Play("Surprise")
		else
			if (entity:GetSprite():IsPlaying("Wait")) and flag ~= DamageFlag.DAMAGE_BOOGER then
				if entity:GetData().poop_mimic_time ~= nil then
					entity:GetData().poop_mimic_time = 0
				end
				return false
			else
				-- Death --
				if amount >= entity.HitPoints then
					if not entity:GetSprite():IsPlaying("Death") then
						sound:Play(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1, 0, false, 1.25)
						entity:GetSprite():Play("Death", true)
						entity:AddEntityFlags(EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
						entity:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
					end
					return false
				end
			end
		end
	end
end

--========== MC_POST_NEW_ROOM ==========--

function mod:newroom()
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local gridSize = room:GetGridSize()
	-- Lacrimal Sac --
	if player:GetData().sac_collect ~= nil then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA) then
			player:GetData().sac_collect = 0
		end
	end
	-- Rood --
	if player:HasCollectible(rood) then
		--Devil Deal --
		if room:GetType() == RoomType.ROOM_DEVIL and room:IsFirstVisit() then
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 and entity.Variant == 100 and entity:ToPickup():IsShopItem() == true then
					entity:Remove()
					local choice = Isaac.Spawn(5, 100, entity.SubType, entity.Position, Vector(0,0), entity)
					choice:ToPickup().TheresOptionsPickup = true
				end
			end
		end
		-- Angel Deal --
		if room:GetType() == RoomType.ROOM_ANGEL and room:IsFirstVisit() then
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 and entity.Variant == 100 and entity:ToPickup():IsShopItem() == false then
					if player:GetSoulHearts() >= 6
					or player:GetPlayerType() == PlayerType.PLAYER_THELOST
					or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
					or player:GetPlayerType() == PlayerType.PLAYER_THESOUL
					or player:GetName() == "Ruah" then
						entity:ToPickup().TheresOptionsPickup = false
						entity:ToPickup().AutoUpdatePrice = false
						entity:ToPickup().Price = -3 -- Soul Hearts
					else
						if not player:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
							entity:ToPickup().TheresOptionsPickup = false
							entity:ToPickup().AutoUpdatePrice = false
							entity:ToPickup().Price = -2 --  One Red Heart
						else -- Judas Tongue Synergy
							entity:ToPickup().TheresOptionsPickup = false
							entity:ToPickup().AutoUpdatePrice = false
							entity:ToPickup().Price = -1 --  One Red Heart
						end
					end
				end
			end
		end
		-- Angel Pact --
		if game:GetDevilRoomDeals() > 0 then
			level:AddAngelRoomChance(1)
		end
	end
	--===== Poop Mimic Spawning / Soul Objects =====--
	if room:IsFirstVisit() and room:IsClear() == false then
		for i = 1, gridSize do
			gridEntity = room:GetGridEntity(i)
			if (gridEntity ~= nil) then
				local gridVariant = gridEntity.GetVariant(gridEntity)
				local gridPoop = gridEntity:ToPoop()
				-- Poop Mimics --
				if gridPoop and gridVariant >= 0 then -- Brown
					if game.Difficulty == Difficulty.DIFFICULTY_NORMAL or game.Difficulty == DIFFICULTY_GREED then
						if rng:RandomInt(50) == 1 then
							room:RemoveGridEntity(gridEntity:GetGridIndex(), 0, false)
							local mimic = Isaac.Spawn(900, gridVariant, 0, gridEntity.Position, Vector(0,0), nil)
							mimic:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						end
					else
						if rng:RandomInt(25) == 1 then
							room:RemoveGridEntity(gridEntity:GetGridIndex(), 0, false)
							local mimic = Isaac.Spawn(900, gridVariant, 0, gridEntity.Position, Vector(0,0), nil)
							mimic:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						end
					end
				end
			end
		end
	end
end

--========== MC_PRE_SPAWN_CLEAN_AWARD ==========--

function mod:cleanaward(RNG, pos)
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	-- Bogle Bell --
	if boglebell_nodrop == true then
		boglebell_nodrop = false
		player:DischargeActiveItem()
		return true
	end
	-- Glitched Skull --
	if player:HasTrinket(glitchedskull) then
		if room:GetType() == RoomType.ROOM_BOSS and level:GetStage() ~= LevelStage.STAGE6 and level:GetStage() ~= LevelStage.STAGE7 and level:GetStage() ~= LevelStage.STAGE7_GREED then
			if RNG:RandomInt(5) == 1 then
				level.EnterDoor = -1
				level.LeaveDoor = -1
				local roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ERROR, false, rng)
				game:StartRoomTransition(roomIndex, Direction.NO_DIRECTION, 0)
			end
		end
	end
end

--========== MC_POST_NEW_LEVEL ==========--

function mod:newlevel()
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	-- Lacrimal Sac --
	if player:HasCollectible(lacrimalsac) then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA) then
			player:GetData().sac_collect = 0
		end
	end
	-- Rood --
	if player:HasCollectible(rood) then
		if rundata.devil_statue_bombed == true then
			rundata.devil_statue_bombed = nil
		end
	end
end

--========== MC_USE_ITEM ==========--

function mod:useitem(collectibleType, RNG)
	local player = Isaac.GetPlayer(0)
	-- Bogle Bell --
	if collectibleType == boglebell then
		local room = game:GetLevel():GetCurrentRoom()
		if room:IsFirstVisit() and room:IsClear() then
			boglebell_nodrop = true
			room:RespawnEnemies()
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				-- Spawn Ghost Minions --
				if entity:IsVulnerableEnemy() and entity:IsBoss() == false and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity:HasEntityFlags(EntityFlag.FLAG_CHARM) == false then
					entity:AddCharmed(-1)
					entity:SetColor(Color(1.0, 1.0, 1.0, 0.3, 0, 0, 0), 0, 0, false, false)
				end
				-- Remove Invencible Enemies --
				if (entity:IsInvincible() or entity:IsBoss()) and entity:HasEntityFlags(EntityFlag.FLAG_CHARM) == false and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
					entity:Remove()
				end
			end
		end
		return true
	end
	-- Book of Assistance --
	if collectibleType == bookofassistance then
		local room = game:GetLevel():GetCurrentRoom()
		local handcheck = false
		sound:Play(Isaac.GetSoundIdByName("Phone Call"), 0.75, 0, false, 1)
		local hand = Isaac.Spawn(213, 0, 0, player.Position, Vector(0,0), player)
		hand:AddEntityFlags(EntityFlag.FLAG_CHARM)
		hand:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
		hand:GetData().Isaac_hand = true
		hand.MaxHitPoints = 1
		hand.HitPoints = 1
		hand.CollisionDamage = 0
		hand:ToNPC().CanShutDoors = false
		return true
	end
	-- Book of Exodus --
	if collectibleType == bookofexodus then
		local room = game:GetLevel():GetCurrentRoom()
		local gridSize = room:GetGridSize()
		sound:Play(Isaac.GetSoundIdByName("Cannon Shot"), 2, 0, false, 1)
		game:ShakeScreen(15)
		for i = 1, gridSize do
			gridEntity = room:GetGridEntity(i)
			if (gridEntity ~= nil) then
				local gridType = gridEntity.GetType(gridEntity)
				local gridVariant = gridEntity.GetVariant(gridEntity)
				local gridPit = gridEntity:ToPit()
				local gridPoop = gridEntity:ToPoop()
				local gridRock = gridEntity:ToRock()
				-- Invencible Grid --
				if gridRock and (gridType == GridEntityType.GRID_ROCKB or gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.LOCK) then
					room:RemoveGridEntity(gridEntity:GetGridIndex(), 0, false)
					--room:Update()
				end
				-- Poop --
				if (gridPoop and gridVariant >= 0) then
					gridPoop:Destroy(true)
				end
				-- Rock --
				if (gridRock and gridVariant >= 0) then
					gridRock:Destroy(true)
				end
				-- Spider Web / TNT --
				if gridType == GridEntityType.GRID_SPIDERWEB or gridType == GridEntityType.GRID_TNT then
					gridEntity:Destroy(true)
				end
				-- Pit --
				if gridPit then
					gridPit:MakeBridge()
				end
			end
		end
		return true
	end
	-- Electro Device --
	if collectibleType == electrodevice then
		--sound:Play(Isaac.GetSoundIdByName("EMP"), 0.5, 0, false, 1)
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			-- EMP Effect --
			if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false and entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) == false then
				if entity:GetData().electro_effect == nil then
					entity:GetData().electro_effect = true
				end
			end
			-- Repels bullets and lasers --
			if entity:GetData().electro_effect == true then
				for j, ent in pairs(Isaac.GetRoomEntities()) do
					if (ent.Type == 7 or ent.Type == 9) and ent.SpawnerType == entity.Type then
						ent:Die()
					end
				end
			end
		end
		return true
	end
end

--========== MC_POST_RENDER ==========--

function mod:postrender()
	local player = Isaac.GetPlayer(0)
	--=== Giant Book ===--
	if GiantBook:IsPlaying("Appear") then
		GiantBook:RenderLayer(0, Isaac.WorldToRenderPosition(Vector(320,300), true))
		if GiantBook:GetFrame() < 33 then
			player.Velocity = Vector(0,0)
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) == false and entity:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) == false then
					if entity:GetData().giantbook_delay == nil then
						entity:GetData().giantbook_delay = true
						entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
					end
				end
			end
		else
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:GetData().giantbook_delay == true then
					entity:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
				end
			end
		end
	end
	-- Deity --
	if player:HasCollectible(deity) and deity_check == false then
		player:AddNullCostume(deity_costume)
		deity_check = true
	elseif player:HasCollectible(deity) == false and deity_check then
		player:TryRemoveNullCostume(deity_costume)
		deity_check = false
	end
	-- Lacrimal Sac --
	if player:HasCollectible(lacrimalsac) and lacrimalsac_check == false then
		player:AddNullCostume(lacrimalsac_costume)
		lacrimalsac_check = true
	elseif player:HasCollectible(lacrimalsac) == false and lacrimalsac_check then
		player:TryRemoveNullCostume(lacrimalsac_costume)
		lacrimalsac_check = false
	end
	-- Rood Costume --
	if player:HasCollectible(rood) and rood_check == false then
		player:AddNullCostume(rood_costume)
		rood_check = true
	elseif player:HasCollectible(rood) == false and rood_check then
		player:TryRemoveNullCostume(rood_costume)
		rood_check = false
	end
	-- Rotten Candy --
	if player:HasCollectible(rottencandy) and rottencandy_check == false then
		player:AddNullCostume(rottencandy_costume)
		rottencandy_check = true
	elseif player:HasCollectible(rottencandy) == false and rottencandy_check then
		player:TryRemoveNullCostume(rottencandy_costume)
		rottencandy_check = false
	end
	-- Tesla Tower --
	if player:HasCollectible(teslatower) and teslatower_check == false then
		player:AddNullCostume(teslatower_costume)		
		teslatower_check = true
	elseif player:HasCollectible(teslatower) == false and teslatower_check then
		player:TryRemoveNullCostume(teslatower_costume)
		teslatower_check = false
	end
	-- Unholy Grail --
	if player:HasCollectible(unholygrail) and unholygrail_check == false then
		player:AddNullCostume(unholygrail_costume)
		unholygrail_check = true
	elseif player:HasCollectible(unholygrail) == false and unholygrail_check then
		player:TryRemoveNullCostume(unholygrail_costume)
		unholygrail_check = false
	end
end

-------------------- CALLBACKS --------------------------------------
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.postupdate)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.evaluatecache)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.npcupdate)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.pickupupdate)
--mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.tearupdate)
--mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.tearcollision)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.entitydamage)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.newroom)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.cleanaward)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.newlevel)
--mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, eyeinit, eyeofthebeholder_familiar)
--mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, ghostinit, ghostheart_orbital)
--mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, eyeupdate, eyeofthebeholder_familiar)
--mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ghostupdate, ghostheart_orbital)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useitem)
--mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.usecard)
--mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.usepill)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.postrender)
---------------------------------------------------------------------