extends Node2D

signal cursor_mode_changed(mode);

var anim_frame = 0;
@onready var frame_timer = Timer.new();

# Game-wide variables
var cursor_mode = "default";

## Set all game-wide variables to the values they should have
## at the beginning of the game.
func init_vars():
	cursor_mode = "default";

func _ready():
	add_child(frame_timer);
	frame_timer.start(0.5681);
	frame_timer.connect("timeout", update_anim);


func set_cursor_mode(mode):
	cursor_mode = mode;
	emit_signal("cursor_mode_changed", mode);

## Wait x seconds before continuing.
func wait(seconds):
	return await get_tree().create_timer(seconds).timeout;

func update_anim():
	anim_frame = (anim_frame + 1) % 4;
