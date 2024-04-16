extends Area2D

var damage = 2;

@export var target_position: Vector2 = Vector2.ZERO;
var start_position = Vector2.ZERO;
var shadow_start_position = Vector2.ZERO;
var shadow_target_position = Vector2.ZERO;

var time_max = 2;
var fly_time = 2;

@onready var shadow = $Shadow;

func _ready():
	start_position = global_position;
	shadow_target_position = shadow.position;
	shadow_start_position = shadow.position + Vector2(0, 30);
	var distance = (target_position - start_position).length();
	time_max = distance * 0.006;
	fly_time = time_max;

func _process(delta: float) -> void:
	fly_time -= delta;
	var percent_done: float = 1.0 - (fly_time) / time_max;
	
	global_position = position_at(percent_done);
	shadow.position = lerp(shadow_start_position, shadow_target_position, percent_done);
	
	var next_position = position_at(percent_done + 0.2);
	var direction = next_position - global_position;
	
	$Arrow.look_at(next_position);
	
	if percent_done >= 1:
		queue_free();

func position_at(percent: float):
	var pos = lerp(start_position, target_position, percent);
	var fly_progress = map_centered(percent);
	if percent < 0.5:
		fly_progress += 0.5 * (0.5 - percent);
	var jump_height = fly_progress * -10;
	pos.y += jump_height;
	return pos;

## returns 1 when x is 0.5; 0 if x is 0 or 1.
func map_centered(x: float) -> float:
	return -4*((x - 0.5) * (x - 0.5)) + 1.0;


func _on_hurt_box_entered_range() -> void:
	$HurtBox.damage = damage;
	$HurtBox.activate();
	queue_free();
