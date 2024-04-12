extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.fade_to("main");


func _on_back_button_pressed():
	SceneManager.change_scene("res://screens/CreditsScreen/CreditsScreen.tscn");
