extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.play_music("main");


func _on_back_button_pressed():
	SceneManager.change_scene("res://screens/StartScreen/StartScreen.tscn");
