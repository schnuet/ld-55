## A clickable area can be clicked with the mouse.
## It reacts when the mouse enters or leaves the area.

extends Area2D

signal mouse_in;
signal mouse_out;
signal click;

var disabled = false;

func _ready() -> void:
	connect("mouse_entered", _on_mouse_enter);
	connect("mouse_exited", _on_mouse_exit);
	connect("input_event", _on_input_event);

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if disabled:
		return;
		
	# CLICK HANDLER!
	if event is InputEventMouseButton and event.is_pressed():
		get_viewport().set_input_as_handled();
		emit_signal("click");

func _on_mouse_enter():
	if (disabled): return;
	emit_signal("mouse_in");

func _on_mouse_exit():
	if (disabled): return;
	emit_signal("mouse_out");
		
func disable():
	disabled = true;
	modulate = Color(0, 0, 0, 0.4);

func enable():
	disabled = false;
	modulate = Color.WHITE;
