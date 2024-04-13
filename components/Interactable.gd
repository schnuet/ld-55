extends Area2D

signal interactor_entered(interactor_parent: Node2D);
signal interactor_left(interactor_parent: Node2D);
signal activate(interactor_parent: Node2D);

var interactors: Array[Area2D] = [];

func _ready() -> void:
	var starting_interactors = get_overlapping_areas();
	for area in starting_interactors:
		add_interactor(area);
	
	connect("area_entered", _on_area_entered);
	connect("area_exited", _on_area_exited);

func _on_area_entered(area: Area2D) -> void:
	add_interactor(area);
	emit_signal("interactor_entered", area.get_parent());

func _on_area_exited(area: Area2D) -> void:
	remove_interactor(area);
	emit_signal("interactor_left", area.get_parent());

func add_interactor(area: Area2D):
	interactors.append(area);
	area.connect("activated", _on_interactor_activate.bind(area));
	
func remove_interactor(area: Area2D):
	interactors.erase(area);
	area.disconnect("activated", _on_interactor_activate.bind(area));

func _on_interactor_activate(interactor: Area2D):
	var interactor_parent = interactor.get_parent();
	emit_signal("activate", interactor_parent);
