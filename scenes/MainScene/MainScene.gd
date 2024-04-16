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

var title_1_showed = false;
var title_2_showed = false;
var title_3_showed = false;
var title_4_showed = false;

@onready var navigation_region = $NavigationRegion2D;
@onready var card = $card;
@onready var button_health = $card/button_health;
@onready var button_damage = $card/button_damage;

func _ready():
	card.hide();
	button_health.connect("pressed", choose_health);
	button_damage.connect("pressed", choose_damage);
	#$card.get_node("button_healing").connect("pressed", choose_healing);
	
	MusicPlayer.play_music("main");
	Game.init_vars();
	
	get_player().connect("died", restart_level);
	
	do_level(current_level);

func _process(_delta):
	if card.visible:
		if Input.is_action_just_released("left"):
			button_health.grab_focus();
		if Input.is_action_just_released("right"):
			button_damage.grab_focus();

func get_player():
	return get_tree().get_nodes_in_group("player")[0];


var level_aborted = false;
var in_level = false;

func switch_level_bg(level_number):
	#var tween = get_tree().create_tween();
	#$black.modulate = Color.TRANSPARENT;
	#$black.show();
	#tween.tween_property($black, "modulate", Color.WHITE, 0.5);
	#await tween.finished;
	
	if level_number == 1:
		$bg_1.show();
		$fg_1.show();
	elif level_number == 2:
		$bg_2.show();
	elif level_number == 3:
		$bg_3.show();
		$fg_1.hide();
		$fg_2.show();
	elif level_number == 4:
		$bg_4.show();
	elif level_number == 5:
		$bg_5.show();
		$fg_2.hide();
		$fg_3.show();
	elif level_number == 6:
		$bg_6.show();
	elif level_number == 7:
		$bg_7.show();
	
	#var tween_out = get_tree().create_tween();
	#$black.modulate = Color.TRANSPARENT;
	#
	#tween_out.tween_property($black, "modulate", Color.TRANSPARENT, 0.5);
	#await tween_out.finished;
	#$black.hide();

func do_level(level_number: int):
	in_level = true;
	level_aborted = false;
	current_level = level_number;

	const B = 100;
	const H = SCREEN_HEIGHT - B;

	var player = get_player();
	player.global_position = Vector2(200, 180);
	
	if level_number == 1:
		if !title_1_showed:
			title_1_showed = true;
			await show_title(1);
	if level_number == 3:
		if !title_2_showed:
			title_2_showed = true;
			await show_title(2);
	if level_number == 5:
		if !title_3_showed:
			title_3_showed = true;
			await show_title(3);
	if level_number == 7:
		if !title_4_showed:
			title_4_showed = true;
			await show_title(4);
	
	await player.summon();
	await Game.wait(1);
	
	match(level_number):
		# WOOD 1
		1:
			spawn_grunt(LEFT, B + H * 0.5);
			await are_all_dead();
			
			await DialogOverlay.do_dialog([{
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"DID YOU FEEL THAT?"
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "halfsmile",
				"lines": [
					"Sure, I hit him.",
					"How could I not feel that?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "angry",
				"lines": [
					"YOU WERE HEALED!",
					"KILLING HEALS YOU!",
					"THIS ALONE SHOULD BE YOUR REWARD."
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "unhappy",
				"lines": [
					"Well, great, nice, that's awesome...",
					"Can we go on?"
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "hehe",
				"lines": [
					"I've got an album to listen to."
				]
			}], true, self);
			
			
			spawn_grunt(RIGHT, B + H * 0.5);
			spawn_grunt(LEFT, B + H * 0.75);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return;
			
			await player.desummon();
			
			await DialogOverlay.do_dialog([{
				"actor": "demon",
				"type": "line",
				"mood": "happy",
				"lines": [
					"It's over! Free at last!"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"NOT SO FAST!",
					"I'VE GOT SOMETHING FOR YOU!"
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "shocked",
				"lines": [
					"What now?"
				]
			},], true, self);
			
			await show_end_card(2);
			await Game.wait(1);
			
			await DialogOverlay.do_dialog([{
				"actor": "demon",
				"type": "line",
				"mood": "hehe",
				"lines": [
					"What is this supposed to be?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "unhappy",
				"lines": [
					"AN OFFER!",
					"JUST CHOOSE ONE: HEALTH OR DAMAGE?"
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "halfsmile",
				"lines": [
					"What health or damage?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"YOU'LL GET BETTER IN ONE.",
					"BUT ONLY IN ONE!"
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "happy",
				"lines": [
					"Is this a blue pill, red pill thing?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "angry",
				"lines": [
					"JUST CHOOSE ONE!"
				]
			}], true, self);
		
		# WOOD 2
		2:
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(3);
			spawn_grunt(LEFT, B + H * 0.2);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(6);
			spawn_grunt(RIGHT, B + H * 0.5);
			spawn_grunt(LEFT, B + H * 0.5);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await player.desummon();
			
			show_end_card(3);
		
		# CITY 1
		3:
			spawn_archer(LEFT, B + H * 0.2);
			spawn_grunt(RIGHT, B + H * 0.5);
			spawn_grunt(LEFT, B + H * 0.4);
			await are_all_dead();
			
			spawn_grunt(RIGHT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.2);
			await Game.wait(3);
			spawn_archer(RIGHT, B + H * 0.2);
			spawn_archer(LEFT, B + H * 0.6);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await player.desummon();
			
			await Game.wait(1);
			await DialogOverlay.do_dialog([{
				"actor": "demon",
				"type": "line",
				"mood": "unhappy",
				"lines": [
					"We're in the city now?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"AN EVIL CITY!",
					"ITS EXISTANCE DISTURBS ME!"
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "unhappy",
				"lines": [
					"Your summons disturb me."
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "angry",
				"lines": [
					"When is this over?",
					"I want some peace!"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "neutral",
				"lines": [
					"SOON, YOU'LL SEE.",
					"WHY DON'T YOU LOOK AT THIS PARCHMENT HERE..."
				]
			}], true, self);
			await Game.wait(1);
			
			await show_end_card(4);

		# CITY 2
		4:
			spawn_archer(LEFT, B + H * 0.2);
			spawn_grunt(RIGHT, B + H * 0.5);
			spawn_grunt(LEFT, B + H * 0.4);
			await Game.wait(6);
			spawn_archer(LEFT, B + H * 0.6);
			spawn_grunt(LEFT, B + H * 0.2);
			spawn_grunt(RIGHT, B + H * 0.2);
			await are_all_dead();
			
			spawn_archer(RIGHT, B + H * 0.2);
			await Game.wait(2);
			spawn_archer(LEFT, B + H * 0.4);
			spawn_archer(RIGHT, B + H * 0.5);
			await Game.wait(4);
			spawn_archer(LEFT, B + H * 0.3);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit();
				in_level = false;
				return
			
			await player.desummon();
			show_end_card(5);
		
		# CASTLE 1
		5:
			spawn_knight(LEFT, B + H * 0.8);
			await are_all_dead();
			
			spawn_archer(RIGHT, B + H * 0.5);
			spawn_knight(LEFT, B + H * 0.8);
			spawn_archer(RIGHT, B + H * 0.5);
			await are_all_dead();
			
			spawn_archer(LEFT, B + H * 0.5);
			spawn_archer(RIGHT, B + H * 0.3);
			spawn_knight(RIGHT, B + H * 0.8);
			spawn_grunt(LEFT, B + H * 0.4);
			spawn_grunt(LEFT, B + H * 0.8);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
			
			await Game.wait(1);
			await DialogOverlay.do_dialog([{
				"actor": "demon",
				"type": "line",
				"mood": "shocked",
				"lines": [
					"Why are we moving to the castle?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"WE'RE NOT HERE TO STAY.",
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"LET'S JUST SAY WE'RE HERE TO VISIT AN OLD FRIEND OF MINE."
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "unhappy",
				"lines": [
					"I'm not that big of a party guy.",
					"Could we just be done with the summons?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "neutral",
				"lines": [
					"JUST A FEW MORE.",
					"WE'RE NEARLY THERE."
				]
			}], true, self);
			await Game.wait(1);
			
			await player.desummon();
			show_end_card(6);
		
		# CASTLE 2
		6:
			spawn_archer(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			spawn_knight(LEFT, B + H * 0.8);
			await Game.wait(4);
			spawn_knight(LEFT, B + H * 0.8);
			spawn_archer(RIGHT, B + H * 0.8);
			spawn_grunt(LEFT, B + H * 0.5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(5);
			spawn_grunt(RIGHT, B + H * 0.5);
			await Game.wait(4);
			spawn_knight(RIGHT, B + H * 0.5);
			spawn_archer(RIGHT, B + H * 0.5);
			await Game.wait(7);
			await are_all_dead();
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
				
			await Game.wait(1);
			await DialogOverlay.do_dialog([{
				"actor": "demon",
				"type": "line",
				"mood": "angry",
				"lines": [
					"We're done now?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"OH, YOU CAN'T LEAVE NOW.",
					"\nNOT WITHOUT MEETING THE king."
				]
			}, {
				"actor": "demon",
				"type": "line",
				"mood": "unhappy",
				"lines": [
					"Is THAT your old friend?"
				]
			}, {
				"actor": "lich",
				"type": "line",
				"mood": "happy",
				"lines": [
					"HE'LL BE DELIGHTED TO SEE US."
				]
			}], true, self);
			await Game.wait(1);
			
			await player.desummon();
			show_end_card(7);
		
		# BOSS
		7:
			await MusicPlayer.fade_and_stop(1);
			MusicPlayer.play_music("boss");
			
			var boss = spawn_boss(RIGHT + 100, B + H * 0.5);
			boss.jump_target_pos = Vector2(400, 180);
			await are_all_dead();
			
			await MusicPlayer.fade_and_stop(1);
			await MusicPlayer.play_music("main");
			
			if level_aborted:
				level_aborted = false;
				level_was_aborted.emit()
				in_level = false;
				return
		
			await Game.wait(1);
			await player.desummon();
			
			SceneManager.change_scene("res://screens/OutroScreen/OutroScreen.tscn");

	in_level = false;


func show_title(level):
	var title_node = get_node("title_" + str(level));
	title_node.modulate = Color.TRANSPARENT;
	title_node.show();
	
	var tween_in = get_tree().create_tween();
	tween_in.tween_property(title_node, "modulate", Color.WHITE, 1);
	await tween_in.finished;
	
	await Game.wait(1);
	
	var tween_out = get_tree().create_tween();
	tween_out.tween_property(title_node, "modulate", Color.TRANSPARENT, 1);
	await tween_out.finished;
	title_node.hide();
	
	return await Game.wait(0.1);

func are_all_dead():
	if level_aborted:
		return true;
	return all_dead;


func show_end_card(next_level: int):
	if next_level == 99:
		button_damage.disabled = true;
		button_health.disabled = true;
	var card = get_node("card");
	card.show();
	card.modulate = Color.TRANSPARENT;
	var tween = get_tree().create_tween();
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(card, "modulate", Color.WHITE, 0.5);
	open_end_card = card;
	return await tween.finished;

func close_end_card():
	switch_level_bg(current_level + 1);
	var tween = get_tree().create_tween();
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(card, "modulate", Color.TRANSPARENT, 0.5);
	await tween.finished;
	await Game.wait(0.5);
	card.hide();
	button_health.release_focus();
	button_damage.release_focus();
	return;

func choose_health():
	Game.health_buff += 1;
	get_player().update_health();
	await close_end_card();
	do_level(current_level + 1);

func choose_damage():
	Game.damage_buff += 1;
	await close_end_card();
	do_level(current_level + 1);

#func choose_healing():
	#var player = get_player();
	#player.health = player.max_health;
	#close_end_card();
	#do_level(current_level + 1);
	
func choose_speed():
	Game.speed_buff += 1;
	open_end_card.hide();
	do_level(current_level + 1);



func restart_level():
	if Game.mode == "hard":
		SceneManager.change_scene("res://scenes/MainScene/MainScene.tscn");
	else:
		show_death_note();
		print("restart level");
		level_aborted = true;
		for enemy in enemies:
			enemy.set_state(enemy.State.DIE);
		enemies = [];
		emit_signal("all_dead");
		emit_signal("all_dead");
		emit_signal("all_dead");
		if in_level:
			await level_was_aborted;
			print("signal received");
		else:
			print("not in level");
		var player = get_player();
		player.health = player.max_health;
		print("doing_level ", current_level);
		
		await Game.wait(2);
		do_level(current_level);

func show_death_note():
	var death_note = get_node("title_death");
	death_note.modulate = Color.TRANSPARENT;
	death_note.show();
	
	var tween_in = get_tree().create_tween();
	tween_in.tween_property(death_note, "modulate", Color.WHITE, 1);
	await tween_in.finished;
	
	await Game.wait(1);
	
	var tween_out = get_tree().create_tween();
	tween_out.tween_property(death_note, "modulate", Color.TRANSPARENT, 1);
	await tween_out.finished;
	death_note.hide();
	
	return await Game.wait(0.1);

func spawn_grunt(x: float, y: float):
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


func do_dialog(dialog_number: float):
	match dialog_number:
		1:
			await DialogOverlay.do_dialog([
			{
				"actor": "lich",
				"type": "line",
				"lines": [
					"Professor Jeff!",
					"We're counting on you!",
					"We've got a fresh shipment of plants from CR708."
				]
			}], self);
			return;
