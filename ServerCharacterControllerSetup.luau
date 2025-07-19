local Players = game:GetService("Players")

local function setupDefaultHumanoid(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then
        warn("Character missing Humanoid for default setup", character)
        return
    end
    -- Manual death/respawn for reliability
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                character:Destroy()
                player:LoadCharacter()
            end
        end
    end)
    print("[DefaultHumanoid] Setup complete for", character.Name)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupDefaultHumanoid)
end)