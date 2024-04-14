extends ProgressBar

@export var max_health = 100;
@export var health = 100;

@onready var parent = get_parent();

func _process(delta: float) -> void:
	if "max_health" in parent:
		max_value = parent.max_health;
	if "health" in parent:
		value = parent.health;
