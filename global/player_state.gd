extends Node

var health_amount: int
var stamina_amount: int

func _ready() -> void:
	SignalBus.player_take_damage.connect(_handle_player_take_damage)
	SignalBus.player_use_stamina.connect(_handle_player_uses_stamina)

func get_player_health() -> int: 
	return health_amount

func get_player_stamina() -> int: 
	return stamina_amount

func set_player_health(amount) -> void:
	health_amount = amount

func set_player_stamina(amount) -> void:
	stamina_amount = amount

func _handle_player_take_damage(amount: int) -> void:
	health_amount -= amount

func _handle_player_uses_stamina(amount: int) -> void:
	stamina_amount -= amount
