extends Control

var timer = null;
var tween = null;

@onready var char_boxes = {
	"demon": $demon,
	"lich": $lich
};

@onready var box = null;
@onready var speech_box = null;
@onready var panel = null;
@onready var portrait = null;
@onready var backdrop = $Backdrop;

var open_dialogue = false;
var period = null;
var skip = false;

var period_in = false;

func _ready():
	backdrop.hide();
	hide_all_char_boxes();
	$SkipButton.hide();

func _process(delta: float) -> void:
	if Input.is_action_just_released("ui_accept"):
		accept_line();
	if Input.is_action_just_released("ui_cancel"):
		skip_dialog();

func do_dialog(lines: Array, skippable = true, scene_to_pause: Node = null):
	move_to_front();
	if scene_to_pause:
		scene_to_pause.process_mode = Node.PROCESS_MODE_DISABLED;
	
	show_backdrop();
	
	await Game.wait(0.75);
	
	skip = false;
	if skippable:
		$SkipButton.show();
	
	print("visible", speech_box);
	
	for line in lines:
		if skip == true:
			continue;

		var char_box = get_char_box(line.get("actor"));
		await switch_box(char_box);
		
		if line.has("mood"):
			var p = char_box.get_node("Portrait");
			p.animation = line.get("mood");
		
		if line.get("type") == "line":
			await update_speech(line);
		elif line.get("type") == "action":
			await line.get("action").call();
	
	$SkipButton.hide();
	hide_box(box);
	hide_backdrop();
	
	box = null;
	skip = false;
	
	if scene_to_pause:
		scene_to_pause.process_mode = Node.PROCESS_MODE_INHERIT;
	
func switch_box(new_box):
	if box == new_box:
		return;
	
	hide_box(box);
		
	box = new_box;
	panel = box.get_node("Panel");
	period = box.get_node("period");
	speech_box = panel.get_node("Speech");
	speech_box.text = "";
	portrait = box.get_node("Portrait");
	await show_box(box);

func update_speech(line):
	period.hide();
	var texts = line.get("lines");
	speech_box.visible_characters = 0;
	speech_box.text = "";
	
	if line.get("style") == "scream":
		speech_box.uppercase = true;
	else:
		speech_box.uppercase = false;
	
	for text in texts:
		if skip == true:
			return;
		
		if text.begins_with("#wait:"):
			var seconds = text.to_float();
			print("wait ", seconds, " seconds");
			await Game.wait(seconds);
			continue;
		
		print("next line!");
		$Dialog.playing = true;
		var old_text_length = len(speech_box.text);
		if old_text_length > 0:
			text = " " + text;
		var new_text_length = len(text);
		var text_length = old_text_length + new_text_length;
		speech_box.text += text;
		open_dialogue = true;
		tween = get_tree().create_tween();
		tween.tween_property(speech_box, "visible_characters", text_length, new_text_length * 0.03).from(old_text_length);
		await tween.finished;
		open_dialogue = false;
		speech_box.visible_characters = text_length;
		timer = get_tree().create_timer(0.3)
		await timer.timeout;
	
	if skip == true:
		return;
	
	timer = get_tree().create_timer(len(speech_box.text) * 0.2);
	fade_period_in();
	await timer.timeout

func show_box(box_to_show):
	if box_to_show == null:
		return;
	if box_to_show.visible == true:
		return;
	$Text_bubble.play();
	period.hide();
	box_to_show.show();
	
	#animate portrait
	var p_final_x = portrait.position.x;
	if portrait.position.x < 640:
		portrait.position.x -= 40;
	else:
		portrait.position.x += 40;
	var portrait_tween = get_tree().create_tween();
	portrait_tween.tween_property(portrait, "position:x", p_final_x, 0.125);
	portrait_tween.set_ease(Tween.EASE_OUT);
	
	#animate panel
	var panel_final_y = panel.position.y;
	panel.position.y += 10;
	var panel_tween = get_tree().create_tween();
	panel_tween.tween_property(panel, "position:y", panel_final_y, 0.125);
	panel_tween.set_ease(Tween.EASE_OUT);
	
	await panel_tween.finished

func hide_box(box_to_hide):
	if box_to_hide == null:
		return;
	if box_to_hide.visible == false:
		return;
	
	box_to_hide.hide();


func hide_all_char_boxes():
	for char_name in char_boxes:
		char_boxes.get(char_name).hide();

func get_char_box(char_name: String) -> Node2D:
	return char_boxes.get(char_name);


func show_backdrop():
	backdrop.color = Color.TRANSPARENT;
	backdrop.show();
	var _tween = get_tree().create_tween();
	_tween.tween_property(backdrop, "color", Color(0, 0, 0, 0.5), 0.5);
	
func hide_backdrop():
	var _tween = get_tree().create_tween();
	_tween.tween_property(backdrop, "color", Color.TRANSPARENT, 0.5);
	_tween.tween_callback(backdrop.hide);

func _unhandled_input(event):
	if (
		event is InputEventMouseButton and event.is_pressed()
	) or (
		event.is_action("ui_accept")
	):
		accept_line();

func accept_line():
	if timer != null and timer.time_left > 0:
		timer.time_left = 0.0001;
	elif tween != null and tween.is_running():
		tween.stop();
		tween.emit_signal("finished");

func _on_skip_button_pressed():
	skip_dialog();

func skip_dialog():
	skip = true;
	
	if timer != null and timer.time_left > 0:
		timer.time_left = 0;
		timer.emit_signal("timeout");
	elif tween != null and tween.is_running():
		tween.stop();
		tween.emit_signal("finished");

func _on_dialog_finished():
	if open_dialogue:
		$Dialog.play();

func fade_period_in():
	if period == null:
		return;
	
	period.show();
	var tween = get_tree().create_tween();
	tween.set_ease(tween.EASE_OUT);
	tween.tween_property(period, "modulate", Color.WHITE, 0.4);
	tween.connect("finished", _on_period_in);

func _on_period_in():
	if period != null:
		var tween = get_tree().create_tween();
		tween.set_ease(tween.EASE_OUT);
		tween.tween_property(period, "modulate", Color.TRANSPARENT, 0.4);
		tween.connect("finished", _on_period_out);

func _on_period_out():
	if period != null and period.visible:
		fade_period_in();
