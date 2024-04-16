extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var parent = get_parent();
	$Label.text = parent.State.keys()[parent.state];
