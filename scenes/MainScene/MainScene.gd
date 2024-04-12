extends Node2D

func _ready():
	Game.init_vars();

func _process(_delta):
	pass

## Show a specific dialog
func show_level_dialog(dialog_name: String):
	match dialog_name:
		"intro":
			await DialogOverlay.do_dialog([
				{
					"actor": "chef",
					"type": "line",
					"lines": [
						"Professor Jeff!",
						"We're counting on you!",
						"We've got a fresh shipment of plants from CR708."
					]
				},
				{
					"actor": "prof",
					"type": "line",
					"lines": [
						"Great! I'm on my way. What do they do?"
					]
				},
				{
					"actor": "chef",
					"type": "line",
					"lines": [
						"Thats the thing.",
						"We don't know.",
						"We don't even get to plant them all at once!",
					]
				},
				{
					"actor": "chef",
					"type": "line",
					"lines": [
						"They keep canibalizing each other!",
					]
				},
				{
					"actor": "prof",
					"type": "line",
					"lines": [
						"Strange.",
						"Did you try pulling them out and putting them in again?"
					]
				},
				{
					"actor": "chef",
					"type": "line",
					"lines": [
						"Well, that's YOUR job now.",
						"Plant them all!"
					]
				},
				{
					"actor": "prof",
					"type": "line",
					"lines": [
						"Okaydokay.",
						"Let's better start slow..."
					]
				},
			],
			self);


#func fade_out_menu():
	#var tween = get_tree().create_tween();
	#tween.tween_property(menu, "position:y", default_menu_y + 50, 1);
	#tween.set_ease(Tween.EASE_IN);
	#await tween.finished;
#
#func fade_in_menu():
	#var tween = get_tree().create_tween();
	#$Console_up.play();
	#tween.tween_property(menu, "position:y", default_menu_y, 1);
	#tween.set_ease(Tween.EASE_OUT);
	#await tween.finished;


func _on_leave_hotspot_click() -> void:
	SceneManager.change_scene("res://screens/OutroScreen/OutroScreen.tscn");
