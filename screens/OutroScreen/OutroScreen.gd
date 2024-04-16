extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.play_music("main");
	
	await DialogOverlay.do_dialog([{
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"MUHAHAHAHA!",
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "happy",
		"lines": [
			"GONE WITH YOU!",
			"#wait:1",
			"AWAY AT LEAST!",
			"\nMUHAHAHAHA!",
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "hehe",
		"lines": [
			"You are talking to me, right?"
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"NO!!",
			"\nCOME HERE!",
			"ONE MORE CONTRACT.",
			"JUST HAVE ONE MORE!"
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "happy",
		"lines": [
			"I think I had enough."
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"OH, COME ON, DON'T BE A DOWNER!",
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"WE'RE HAVING SO MUCH FUN HERE!",
		]
	},  {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"YOU CAN'T GO NOW, THE NIGHT IS STILL YOUNG!",
		]
	}, {
		"actor": "lich",
		"type": "action",
		"action": show_card
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"COME ON, SIGN ANOTHER CONTRACT!",
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "hehe",
		"lines": [
			"No. I've had enough.",
			"I'll be home and chill."
		]
	}, {
		"actor": "lich",
		"type": "action",
		"action": hide_card
	}, {
		"actor": "lich",
		"type": "action",
		"action": start_credits
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"YEAH??",
			"WE'LL SEE US AGAIN, DEMON!",
		]
	}, {
		"actor": "lich",
		"type": "line",
		"mood": "angry",
		"lines": [
			"THIS IS NOT OVER YET!!",
		]
	}, {
		"actor": "demon",
		"type": "line",
		"mood": "hehe",
		"lines": [
			"Actually, for me it is.",
			"My contract is done.",
			"See you next time!"
		]
	}], true);

	await Game.wait(2);
	
	SceneManager.change_scene("res://screens/CreditsScreen/CreditsScreen.tscn");

func start_credits():
	var tween = get_tree().create_tween();
	tween.set_ease(tween.EASE_IN_OUT);
	tween.tween_property($Credits, "global_position", Vector2(0, -270), 10);

func show_card():
	$card.show();
	$card.global_position.y = 270;
	var tween = get_tree().create_tween();
	tween.set_ease(tween.EASE_OUT);
	tween.tween_property($card, "global_position", Vector2.ZERO, 0.5);
	return tween.finished;

func hide_card():
	var tween = get_tree().create_tween();
	tween.set_ease(tween.EASE_OUT);
	tween.tween_property($card, "global_position", Vector2(0, 280), 0.5);
	await tween.finished;
	$card.hide();


func _on_back_button_pressed():
	SceneManager.change_scene("res://screens/CreditsScreen/CreditsScreen.tscn");
