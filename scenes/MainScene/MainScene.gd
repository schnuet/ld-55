extends Node2D

signal all_dead;
signal level_was_aborted;

var enemies = [];

# For instanciating
var Grunt = preload("res://actors/Grunt.tscn");
var Knight = preload("res://actors/Knight.tscn");
var Archer = preload("res://actors/Archer.tscn");
var Boss = preload("res://actors/Boss.tscn");

const SCREEN_WIDTH = 480;
const SCREEN_HEIGHT = 270;
const LEFT = -30;
const RIGHT = SCREEN_WIDTH + 30;
const MIN_Y = 100;

var current_level = 1;
var open_end_card: Node2D = null;

@onready var navigation_region = $NavigationRegion2D;

func _ready():
	$card.hide();
	
	MusicPlayer.play_music("main");
	Game.init_vars();
	
	get_player().connect("died", restart_level);
	
	do_level(current_level);

func _process(_delta):
	pass

func get_player():
	return get_tree().get_nodes_in_group("player")[0];


var level_aborted = false;
var in_level = false;

func do_level(level_number: int):
	in_level = true;
	level_aborted = false;
	current_level = level_number;
	
	if level_number > 2:
		$ImageV1.hide();
		$Bg2.show();
	else:
		$ImageV1.show();
		$Bg2.hide();

	const B = 100;
	const H = SCREEN_HEIGHT - B;
	
	var player = get_player();
	player.global_position = Vector2(200, 180);
	await player.summon();
	await Game.wait(1);
	
	match(level_number):
		1:
			#spawn_knight(LEFT, B + H * 0.75);
			#await are_all_dead();
			
			spawn_archer(RIGHT, B + H * 0.5);
			
			print("before await");
			await are_all_dead();
			print("after first await");
			
			#var boss = spawn_boss(RIGHT + 50, B + H * 0.5);
			#boss.jump_target_pos = Vector2(400, 180);
			#await are_all_dead();
			
			#spawn_archer(LEFT, B + H * 0.25);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(LEFT, B + H * 0.75);
			print("before second await");
			await are_all_dead();
			print("after second await");
			
			print("level aborted", level_aborted);
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return;
			
			await player.desummon();
			
			show_end_card(2);
		2:
			spawn_knight(LEFT, B + H * 0.75);
			await are_all_dead();
			spawn_knight(LEFT, B + H * 0.8);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(7);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await player.desummon();
			
			show_end_card(3);
			
		3:
			spawn_knight(LEFT, B + H * 0.75);
			spawn_archer(RIGHT, B + H * 0.5);
			await are_all_dead();
			spawn_knight(LEFT, B + H * 0.8);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(1);
			spawn_grunt(RIGHT, B + H * 0.75);
			spawn_archer(RIGHT, B + H * 0.5);
			await Game.wait(7);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await player.desummon();
			show_end_card(4);
			
		4:
			spawn_archer(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(1);
			spawn_knight(LEFT, B + H * 0.8);
			await Game.wait(1);
			spawn_knight(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(1);
			spawn_knight(RIGHT, B + H * 0.5);
			spawn_archer(RIGHT, B + H * 0.5);
			await Game.wait(7);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await MusicPlayer.fade_and_stop(1);
			MusicPlayer.play_music("boss");
			
			var boss = spawn_boss(RIGHT + 100, B + H * 0.5);
			boss.jump_target_pos = Vector2(400, 180);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await player.desummon();
			
			SceneManager.change_scene("res://screens/OutroScreen/OutroScreen.tscn");

	in_level = false;


func are_all_dead():
	if level_aborted:
		return true;
	return all_dead;


func show_end_card(next_level: int):
	#var card = get_node("endcard_" + str(next_level));
	var card = get_node("card");
	card.show();
	open_end_card = card;
	card.get_node("button_health").connect("pressed", choose_health);
	card.get_node("button_damage").connect("pressed", choose_damage);
	card.get_node("button_healing").connect("pressed", choose_healing);

func choose_health():
	Game.health_buff += 1;
	get_player().update_health();
	open_end_card.hide();
	do_level(current_level + 1);

func choose_damage():
	Game.damage_buff += 1;
	open_end_card.hide();
	do_level(current_level + 1);

func choose_healing():
	var player = get_player();
	player.health = player.max_health;
	open_end_card.hide();
	do_level(current_level + 1);
	
func choose_speed():
	Game.speed_buff += 1;
	open_end_card.hide();
	do_level(current_level + 1);



func restart_level():
	print("restart level");
	level_aborted = true;
	for enemy in enemies:
		enemy.set_state(enemy.State.DIE);
	enemies = [];
	emit_signal("all_dead");
	if in_level:
		await level_was_aborted;
		print("signal received");
	else:
		print("not in level");
	var player = get_player();
	player.health = player.max_health;
	print("doing_level ", current_level);
	do_level(current_level);


func spawn_grunt(x: int, y: int):
	if level_aborted:
		return;
		
	var new_grunt = Grunt.instantiate();
	new_grunt.global_position.x = x;
	new_grunt.global_position.y = y;
	
	enemies.append(new_grunt);
	new_grunt.connect("dead", _remove_enemy.bind(new_grunt));
	navigation_region.add_child(new_grunt);
	return new_grunt;

func spawn_knight(x: float, y: float):
	if level_aborted:
		return;
		
	var new_knight = Knight.instantiate();
	new_knight.global_position.x = x;
	new_knight.global_position.y = y;
	
	enemies.append(new_knight);
	new_knight.connect("dead", _remove_enemy.bind(new_knight));
	navigation_region.add_child(new_knight);
	return new_knight;


func spawn_archer(x: float, y: float):
	if level_aborted:
		return;
		
	var new_archer = Archer.instantiate();
	new_archer.global_position.x = x;
	new_archer.global_position.y = y;
	
	enemies.append(new_archer);
	new_archer.connect("dead", _remove_enemy.bind(new_archer));
	navigation_region.add_child(new_archer);
	return new_archer;


func spawn_boss(x: float, y: float):
	if level_aborted:
		return;
		
	var new_boss = Boss.instantiate();
	new_boss.global_position.x = x;
	new_boss.global_position.y = y;
	
	enemies.append(new_boss);
	new_boss.connect("dead", _remove_enemy.bind(new_boss));
	navigation_region.add_child(new_boss);
	return new_boss;

func _remove_enemy(grunt: Node2D):
	enemies.erase(grunt);
	if enemies.size() == 0:
		emit_signal("all_dead");

