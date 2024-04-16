extends Node2D

signal all_dead;
signal level_was_aborted;

var enemies = [];
var skip = false;

# For instanciating
var Grunt = preload("res://actors/Grunt.tscn");

const SCREEN_WIDTH = 480;
const SCREEN_HEIGHT = 270;
const LEFT = -30;
const RIGHT = SCREEN_WIDTH + 30;
const MIN_Y = 100;

@onready var navigation_region = $NavigationRegion2D;

func _ready():
	MusicPlayer.play_music("main");
	Game.init_vars();
	
	do_level();

func _process(_delta):
	pass

func get_player():
	return get_tree().get_nodes_in_group("player")[0];

func do_level():
	const B = 100;
	const H = SCREEN_HEIGHT - B;

	var player = get_player();
	player.global_position = Vector2(200, 180);
	
	#await show_title(1);
	
	player.summon();
	player.locked = true;
	await Game.wait(1);
	if skip:
		return;
	
	await DialogOverlay.do_dialog([{
		"actor": "demon",
		"type": "line",
		"mood": "unhappy",
		"lines": [
			"Another summon?",
			"Man, I just came down from the last one."
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"COME ON, DEMON! ONE LAST CONTRACT IS OPEN.",
			"IT'S RAIDING TIME!"
		]
	}], false);
	
	if skip:
		return;
	
	await DialogOverlay.do_dialog([{
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"WELCOME!",
			"TO!",
			"THE!",
			"TUTORIAL!"
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "halfsmile",
		"lines": [
			"I think I've seen that place before.",
			"\nIsn't this the old cave at X%ä!ges place?"
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"SILENCE!"
		]
	},{
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"YOU'RE UNDER MY COMMAND NOW!",
			"\nI SUMMONED YOU!"
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "neutral",
		"lines": [
			"LET'S START AT THE BEGINNING.",
			"RUN BEFORE YOU WALK.",
			"#wait:3",
			"\nWALK AROUND NOW!"
		]
	}], false);
	
	if skip:
		return;
	
	fade_in($ControlsMove, 1);
	
	var walked = false;
	var start_position = player.global_position;
	player.locked = false;
	while (!walked):
		await Game.wait(4);
		if start_position != player.global_position:
			walked = true;
			fade_out($ControlsMove, 1);
			break;
		else:
			DialogOverlay.do_dialog([{
				"actor": "lich",
				"type": "line",
				"mood": "angry",
				"lines": [
					"MOVE!"
				]
			}], false, self);
	
	if skip:
		return;
		
	player.locked = true;
	
	await DialogOverlay.do_dialog([{
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"YOU MOVED!",
			"\nMUHAHAHAHA!",
			"YOU'RE BOUND TO MY COMMAND."
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "unhappy",
		"lines": [
			"That felt stupid.",
			"Is that all you summoned me for?"
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"NOW...",
			"\nYOU MUST LEARN HOW TO STAY ALIVE!",
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"ACTUALLY, THAT'S EASY.",
			"\nJUST DON'T GET HIT.",
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "shocked",
		"lines": [
			"Well, isn't that nice to know."
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "hehe",
		"lines": [
			"Actually... on my couch there's a really low chance to-",
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"NO!",
			"YOU DODGE!",
			"DODGE NOW!"
		]
	}], false, self);
	player.locked = false;
	
	if skip:
		return;
	
	fade_in($ControlsDodge, 1);
	
	await player.dodged;
	await Game.wait(1);
	player.locked = true;
	
	if skip:
		return;
	
	fade_out($ControlsDodge, 1);
	
	await DialogOverlay.do_dialog([{
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"MUHAHAHAHA!",
			"THAT'S THE WAY.",
			"JUMP, MY MINION!"
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "unhappy",
		"lines": [
			"There must be a more chill way to..."
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "neutral",
		"lines": [
			"LAST THING!"
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"YOU HAVE TO FIGHT!",
			"AND FOR THAT YOU HAVE TO HIT!"
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "happy",
		"lines": [
			"Hit what?"
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"ANYTHING!",
			"EVERYTHING!",
			"THE AIR!",
			"JUST HIT AROUND!"
		]
	}], false, self);
	
	if skip:
		return;
	
	fade_in($ControlsHit, 1);
	
	player.locked = false;
	
	await player.attacked;
	await Game.wait(2);
	
	fade_out($ControlsHit, 1);
	
	player.locked = true;
	
	if skip:
		return;
	
	await DialogOverlay.do_dialog([{
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"WELL THAT WASN'T SO HARD, WAS IT!?"
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "happy",
		"lines": [
			"It's all done now? Great, let me just-"
		]
	},{
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"GREAT!",
			"YOU'RE READY.",
			"LET'S INVADE A KINGDOM!"
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "shocked",
		"lines": [
			"Wait, what?"
		]
	}], false, self);
	
	if skip:
		return;
	
	await player.desummon();
	player.locked = false;
	SceneManager.change_scene("res://scenes/MainScene/MainScene.tscn");


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


func spawn_grunt(x: float, y: float):
	var new_grunt = Grunt.instantiate();
	new_grunt.global_position.x = x;
	new_grunt.global_position.y = y;
	
	enemies.append(new_grunt);
	new_grunt.connect("dead", _remove_enemy.bind(new_grunt));
	navigation_region.add_child(new_grunt);
	return new_grunt;



func _remove_enemy(grunt: Node2D):
	enemies.erase(grunt);
	if enemies.size() == 0:
		emit_signal("all_dead");


func fade_in(node: Node2D, duration: float = 1):
	node.modulate = Color.TRANSPARENT;
	node.show();
	var tween = get_tree().create_tween();
	tween.tween_property(node, "modulate", Color.WHITE, duration);
	return tween.finished;

func fade_out(node: Node2D, duration: float = 1):
	var tween = get_tree().create_tween();
	tween.tween_property(node, "modulate", Color.TRANSPARENT, duration);
	node.hide();
	return await tween.finished;
	
func _on_skip_button_pressed() -> void:
	skip = true;
	DialogOverlay.skip_dialog();
	SceneManager.change_scene("res://scenes/MainScene/MainScene.tscn");
