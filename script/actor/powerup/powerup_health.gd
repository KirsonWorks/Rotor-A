extends PowerupBase

func collect(player: Player) -> void:
	player.add_health(HEALTH)
