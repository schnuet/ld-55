extends Node2D

@onready var logo = $Logo;
@onready var black_overlay = $BlackOverlay;
@onready var start_button = $StartButton;
@onready var credits_button = $CreditsButton;

# Called when the node enters the scene tree for the first time.
func _ready():
	# prepare intro
	
	# hide the buttons
	start_button.hide();
	credits_button.hide();
	
	# show a black screen
	black_overlay.show();
	
	# make logo transparent
	#logo.modulate = Color.TRANSPARENT;
	
	MusicPlayer.play_music("main");

	await Game.wait(1);
	
	fade_in_logo();
	fade_in_from_black();
	
	await Game.wait(2);
	
	start_button.show();
	credits_button.show();

func _process(_delta):
	pass;
	#var f = Game.anim_frame % 8;
	#
	#$AnimatedSprite2D.frame = f;
	
func fade_in_logo():
	if (!is_instance_valid(logo)):
		return;
	var tween = create_tween().tween_property(logo, "modulate", Color.WHITE, 2);
	await tween.finished;
	
func fade_in_from_black():
	var tween = get_tree().create_tween().tween_property(black_overlay, "modulate", Color.TRANSPARENT, 2);
	await tween.finished;

func _on_start_button_pressed():
	SceneManager.change_scene("res://scenes/MainScene/MainScene.tscn");


func _on_credits_button_pressed():
	SceneManager.change_scene("res://screens/CreditsScreen/CreditsScreen.tscn");
