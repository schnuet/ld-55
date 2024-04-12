extends Area2D

signal activated();

func activate():
	emit_signal("activated");
