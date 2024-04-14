extends Area2D

signal activated();
signal entered_range;
signal left_range;

@export var damage: float = 1.0;
var in_range: bool = false;

func activate():
	emit_signal("activated");

func enter_range():
	in_range = true;
	emit_signal("entered_range");

func leave_range():
	in_range = false;
	emit_signal("left_range");
