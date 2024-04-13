extends Node2D

@onready var Grunt = preload("res://actors/Grunt.tscn");

@onready var navigation_region = $NavigationRegion2D;

func _ready():
	Game.init_vars();
	
	do_level(1);

func _process(_delta):
	$Label.text = str(get_player().health);

func get_player():
	return get_tree().get_nodes_in_group("player")[0];


func do_level(level_number: int):
	const LEFT = -30;
	const RIGHT = 720;
	const MIN_Y = 100;
	
	const B = 100;
	const H = 360 - 100;
	
	
	match(level_number):
		1:
			await Game.wait(2);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(7);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(10);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(10);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(10);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);

func spawn_grunt(x, y):
	var new_grunt = Grunt.instantiate();
	new_grunt.global_position.x = x;
	new_grunt.global_position.y = y;
	
	navigation_region.add_child(new_grunt);
	return new_grunt;
	
	
