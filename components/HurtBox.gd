extends Area2D

signal activated();

@export var damage: float = 1.0;
var in_range: bool = false;

func activate():
	emit_signal("activated");
