extends CanvasLayer

@onready var health_amount: Label = $TopBar/HealthContainer/HealthAmount
@onready var stamina_amount: Label = $TopBar/StaminaContainer/StaminaAmount

func _physics_process(delta: float) -> void:
	
	if PlayerState.get_player_health() <= 0:
		health_amount.text = "0"
	else:
		health_amount.text = str(PlayerState.get_player_health())
	
	stamina_amount.text = str(PlayerState.get_player_stamina())
