extends ProgressBar

@export var max_health = 100;
@export var health = 100;

@onready var parent = get_parent();

func _ready():
	hide();

func _process(delta: float) -> void:
	var SCREEN_HEIGHT = 270;
	
	# reposition
	global_position.x = 9;
	global_position.y = SCREEN_HEIGHT - size.y - 9;
	
	if "max_health" in parent:
		max_value = parent.max_health;
	if "health" in parent:
		value = parent.health;

func appear():
	modulate = Color.TRANSPARENT;
	show();
	var tween = get_tree().create_tween();
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(self, "modulate", Color.WHITE, 0.5);
