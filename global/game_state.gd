extends Node

# load player hp from save file or if first run set the hp to blah

func init_game() -> void:
	PlayerState.set_player_health(10)
