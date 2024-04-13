extends Node2D

@export var max_health = 100;
@export var health = 100;

@onready var progress_bar = $ProgressBar;

@onready var parent = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "max_health" in parent:
		max_health = parent.max_health;
		
	progress_bar.max_value = max_health;

func _process(delta: float) -> void:
	if "health" in parent:
		health = parent.health;
		
	progress_bar.value = health;
