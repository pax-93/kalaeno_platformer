extends Node

var player_health: int

func _ready() -> void:
	SignalBus.player_takes_damage.connect(_handle_player_take_damage)

func get_player_health() -> int: 
	return player_health

func set_player_health(amount) -> void:
	player_health = amount

func _handle_player_take_damage(damage_amount: int) -> void:
	player_health -= damage_amount
