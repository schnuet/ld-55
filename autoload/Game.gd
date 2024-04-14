extends Node2D

var anim_frame = 0;

# Game-wide variables

var dodge_available = true;
var health_buff = 0;
var speed_buff = 0;
var damage_buff = 0;
var dodge_distance_buff = 0;

## Set all game-wide variables to the values they should have
## at the beginning of the game.
func init_vars():
	dodge_available = true;


func _ready():
	pass

## Wait x seconds before continuing.
func wait(seconds):
	return await get_tree().create_timer(seconds).timeout;

func update_anim():
	anim_frame = (anim_frame + 1) % 4;
