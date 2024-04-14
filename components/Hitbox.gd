# HITBOX
extends Area2D

signal hit(damage: float, hitter: Node2D);

signal hurtbox_entered(hurtbox_parent: Node2D);
signal hurtbox_left(hurtbox_parent: Node2D);

var hurtboxes: Array[Area2D] = [];

func _ready() -> void:
	var starting_hurtboxes = get_overlapping_areas();
	for area in starting_hurtboxes:
		add_hurtbox(area);
	
	connect("area_entered", _on_area_entered);
	connect("area_exited", _on_area_exited);

func _on_area_entered(area: Area2D) -> void:
	add_hurtbox(area);
	emit_signal("hurtbox_entered", area.get_parent());

func _on_area_exited(area: Area2D) -> void:
	remove_hurtbox(area);
	emit_signal("hurtbox_left", area.get_parent());

func add_hurtbox(hurtbox: Area2D):
	hurtboxes.append(hurtbox);
	hurtbox.connect("activated", _on_hurtbox_activate.bind(hurtbox));
	hurtbox.enter_range();
	
func remove_hurtbox(hurtbox: Area2D):
	hurtboxes.erase(hurtbox);
	hurtbox.disconnect("activated", _on_hurtbox_activate.bind(hurtbox));
	hurtbox.leave_range();

func _on_hurtbox_activate(hurtbox: Area2D):
	var hurtbox_parent = hurtbox.get_parent();
	emit_signal("hit", hurtbox.damage, hurtbox_parent);
