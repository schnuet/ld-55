extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.play_music("main");
	await Game.wait(1);
	
	$introvideo.play();
	await $introvideo.animation_finished;
	
	SceneManager.change_scene("res://scenes/TutorialScene/TutorialScene.tscn");
	
	#await DialogOverlay.do_dialog([
		#{
			#"actor": "lich",
			#"type": "line",
			#"lines": [
				#"Professor Jeff!",
				#"We're counting on you!",
				#"We've got a fresh shipment of plants from CR708."
			#]
		#},
		#{
			#"actor": "prof",
			#"type": "line",
			#"lines": [
				#"Great! I'm on my way. What do they do?"
			#]
		#},
		#{
			#"actor": "chef",
			#"type": "line",
			#"lines": [
				#"Thats the thing.",
				#"We don't know.",
				#"We don't even get to plant them all at once!",
			#]
		#},
		#{
			#"actor": "chef",
			#"type": "line",
			#"lines": [
				#"They keep canibalizing each other!",
			#]
		#},
		#{
			#"actor": "prof",
			#"type": "line",
			#"lines": [
				#"Strange.",
				#"Did you try pulling them out and putting them in again?"
			#]
		#},
		#{
			#"actor": "chef",
			#"type": "line",
			#"lines": [
				#"Well, that's YOUR job now.",
				#"Plant them all!"
			#]
		#},
		#{
			#"actor": "prof",
			#"type": "line",
			#"lines": [
				#"Okaydokay.",
				#"Let's better start slow..."
			#]
		#},
	#],
	#self);


func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/TutorialScene/TutorialScene.tscn");

