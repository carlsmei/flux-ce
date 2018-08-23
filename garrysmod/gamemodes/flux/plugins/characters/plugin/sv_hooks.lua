function flCharacters:PlayerInitialSpawn(player)
  player:SetNoDraw(true)
  player:SetNotSolid(true)
  player:Lock()

  timer.Simple(1, function()
    if (IsValid(player)) then
      player:KillSilent()
      player:StripAmmo()
    end
  end)
end

function flCharacters:ClientIncludedSchema(player)
  character.Load(player)
end

function flCharacters:PostCharacterLoaded(player, character)
  hook.RunClient(player, "PostCharacterLoaded", character.id)
end

function flCharacters:OnActiveCharacterSet(player, character)
  player:Spawn()
  player:SetModel(character.model or "models/humans/group01/male_02.mdl")

  player:StripAmmo()

  if (istable(character.ammo)) then
    for k, v in pairs(character.ammo) do
      player:SetAmmo(v, k)
    end

    character.ammo = nil
  end

  hook.Run("PostCharacterLoaded", player, character)
end

function flCharacters:OnCharacterChange(player, oldChar, newCharID)
  player:SaveCharacter()
  character.Load(player)
end

function flCharacters:PlayerDisconnected(player)
  player:SaveCharacter()
end

function flCharacters:PlayerDeath(player, inflictor, attacker)
  player:SaveCharacter()
end

function flCharacters:DatabaseConnected()
  create_table('fl_characters', function(t)
    t:primary_key 'id'
    t:string { 'steam_id', null = false }
    t:string { 'name', null = false }
    t:string 'model'
    t:string 'phys_desc'
    t:integer 'money'
    t:json 'ammo'
    t:json 'inventory'
    t:json 'data'
    t:timestamp 'created_at'
    t:timestamp 'updated_at'
  end)
end
