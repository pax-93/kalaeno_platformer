extends Node

var max_stamina_amount: int = 100
var health_amount: int
var stamina_amount: int
var attacking: bool

func _ready() -> void:
	#Player HEALTH signals
	SignalBus.player_take_damage.connect(_handle_player_take_damage)
	SignalBus.player_gain_health.connect(_handle_player_gains_health)
	
	#Player STAMINA signals
	SignalBus.player_use_stamina.connect(_handle_player_uses_stamina)
	SignalBus.player_gain_stamina.connect(_handle_player_gains_stamina)

func get_player_health() -> int: 
	return health_amount

func get_player_stamina() -> int: 
	return stamina_amount

func set_player_health(amount) -> void:
	health_amount = amount

func set_player_stamina(amount) -> void:
	stamina_amount = amount

func set_attacking_state(new_attacking_state: bool) -> void:
	attacking = new_attacking_state

func get_attacking_state() -> bool:
	return attacking

func _handle_player_take_damage(amount: int) -> void:
	health_amount -= amount

func _handle_player_gains_health(amount: int) -> void:
	health_amount += amount

func _handle_player_uses_stamina(amount: int) -> void:
	stamina_amount -= amount

func _handle_player_gains_stamina(amount: int) -> void:
	if stamina_amount + amount >= max_stamina_amount:
		stamina_amount = max_stamina_amount
	else:
		stamina_amount += amount
