extends Node

@onready var players = get_children() as Array[AudioStreamPlayer];
@onready var current_player = null;

var original_volumes = {};

func _ready():
	for player in players:
		original_volumes[player.name] = player.volume_db;
		player.volume_db = -60;
		var stream = player.stream;
		stream.loop = true;
	
func play_music(music_name: String):
	# prevent stopping music if it is playing already:
	if current_player and current_player.name == music_name:
		return;
	elif current_player:
		current_player.stop();
		current_player = null;

	for player in players:
		if player.name == music_name:
			player.play();
	
	fade_to(music_name);

func fade_and_stop(time: float = 0.5):
	if current_player == null:
		return;
	
	var tween = get_tree().create_tween();
	# fade out current player
	tween.tween_property(current_player, "volume_db", -40, time);
	return tween.finished;

func fade_to(music_name):
	if current_player and current_player.name == music_name:
		return;
	
	var player = get_node(music_name);
	
	var time = 0.5;
	
	var tween = get_tree().create_tween();
	
	if current_player:
		# fade out current player
		tween.tween_property(current_player, "volume_db", -40, time);
	
	# fade in
	tween.tween_property(player, "volume_db", original_volumes.get(player.name), time);
	
	current_player = player;
	
#
#func play_music(music_name:String):
#	if current_music_name == music_name:
#		return;
#
#	stop();
#
#	current_music_name = music_name;
#	stream = music_streams.get(current_music_name);
#
#	play();
#
#func register_stream(stream_path:String, music_name:String):
#	music_streams[music_name] = load(stream_path);
