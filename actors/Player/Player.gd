extends CharacterBody2D

signal desummoned;
signal summoned;
signal died;

const SPEED = 120.0;
const FRICTION = 0.20;

var base_max_health: float = 10;
var max_health: float = 10;
var health: float = 10;

var hit_damage_1 = 1;
var hit_damage_2 = 1;
var hit_damage_3 = 2;

enum Direction {
	LEFT,
	RIGHT
}
var orientation = Direction.RIGHT;

enum State {
	DESUMMONED,
	SUMMONING,
	MOVE,
	HIT_1,
	HIT_2,
	HIT_3,
	ATTACK,
	DODGE,
	DIE
}
var state: State = State.SUMMONING;

var dodge_available = true;

var hit_action_triggered = false;
var hit_end_position: Vector2 = Vector2.ZERO;

@onready var hitbox = $hitbox;
@onready var hurtbox_hit_right = $hurtbox_hit_right;
@onready var hurtbox_hit_left = $hurtbox_hit_left;
@onready var animated_sprite = $AnimatedSprite2D;
@onready var summoning_circle = $summoning_circle;
@onready var healthbar = $Healthbar;
@onready var shadow = $Shadow;

func _ready() -> void:
	#$AnimatedSprite2D/PointLight2D.hide();
	set_state(State.SUMMONING);

func _physics_process(delta: float) -> void:
	match (state):
		State.SUMMONING:
			_update_summoning(delta);
		State.MOVE:
			_update_move(delta);
		State.HIT_1:
			_update_hit_1();
		State.HIT_2:
			_update_hit_2();
		State.HIT_3:
			_update_hit_3();
		State.DODGE:
			_update_dodge();
		State.DESUMMONED:
			pass;
	

# ===========
# MOVE

func _enter_move():
	velocity = Vector2.ZERO;
	animated_sprite.animation = "walk";

func _update_move(_delta: float):
	if health == 0:
		set_state(State.DIE);
		return;
	if Input.is_action_just_pressed("dodge"):
		enter_dodge();
		return;
	
	if Input.is_action_just_released("hit"):
		set_state(State.HIT_1);
		return;
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("left", "right", "up", "down");
	
	# Using the follow steering behavior.
	var target_velocity = direction * (SPEED + Game.speed_buff * 30);
	velocity += (target_velocity - velocity) * FRICTION;
	update_orientation();

	move_and_slide();
	
	if velocity.length() < 2:
		if animated_sprite.is_playing():
			animated_sprite.stop();
	else:
		if !animated_sprite.is_playing():
			animated_sprite.play();


# ===========
# HITTING

func _enter_hit_1():
	update_hit_end_position(10);
	hit_action_triggered = false;
	animated_sprite.play("attack");
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	hit(hit_damage_1);
	await animated_sprite.animation_finished;
	if hit_action_triggered:
		set_state(State.HIT_2);
	else:
		set_state(State.MOVE);
	
func _update_hit_1():
	if Input.is_action_just_released("hit"):
		hit_action_triggered = true;
	
	global_position = lerp(global_position, hit_end_position, 0.2);


func _enter_hit_2():
	update_hit_end_position(15);
	hit_action_triggered = false;
	animated_sprite.play("attack");
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	hit(hit_damage_2);
	await animated_sprite.animation_finished;
	if hit_action_triggered:
		set_state(State.HIT_3);
	else:
		set_state(State.MOVE);
	
func _update_hit_2():
	if Input.is_action_just_released("hit"):
		hit_action_triggered = true;


func _enter_hit_3():
	update_hit_end_position(20);
	hit_action_triggered = false;
	animated_sprite.play("attack");
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	hit(hit_damage_3);
	await animated_sprite.animation_finished;
	set_state(State.MOVE);
	
func _update_hit_3():
	pass


func hit(hit_strength: float = 1):
	hit_strength = hit_strength + Game.damage_buff;
	if orientation == Direction.LEFT:
		hurtbox_hit_left.damage = hit_strength;
		hurtbox_hit_left.activate();
	if orientation == Direction.RIGHT:
		hurtbox_hit_right.damage = hit_strength;
		hurtbox_hit_right.activate();


func update_hit_end_position(strength: float):
	if orientation == Direction.LEFT:
		hit_end_position = global_position + Vector2(-strength, 0);
	if orientation == Direction.RIGHT:
		hit_end_position = global_position + Vector2(strength, 0);



# ========
# DODGING

func enter_dodge():
	animated_sprite.play("dodge");
	var input_direction = Input.get_vector("left", "right", "up", "down");
	if input_direction.is_zero_approx():
		if orientation == Direction.RIGHT:
			input_direction = Vector2(1, 0);
		else:
			input_direction = Vector2(-1, 0);
	
	set_collision_mask_value(9, false);
	set_collision_layer_value(10, false);
	velocity = input_direction * get_dodge_distance();
	
	
	set_state(State.DODGE);
	await Game.wait(0.4);
	set_collision_mask_value(9, true);
	set_collision_layer_value(10, true);
	set_state(State.MOVE);

func get_dodge_distance():
	return 500 + Game.dodge_distance_buff;

func _update_dodge():
	velocity *= 0.9;
	move_and_slide();


# =============
# DIE

func _enter_die():
	print("player dies");
	var tween = get_tree().create_tween();
	animated_sprite.modulate = Color.RED;
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3);
	tween.set_ease(Tween.EASE_IN);
	Game.wait(5);
	state = State.DESUMMONED;
	await desummon();
	emit_signal("died");

# =============
# DIE


func _enter_summoning():
	print("enter summoning");
	animated_sprite.play("summon");
	shadow.hide();
	animated_sprite.show();
	var original_sprite_pos = animated_sprite.position;
	animated_sprite.modulate = Color.TRANSPARENT;
	summoning_circle.modulate = Color.TRANSPARENT;
	summoning_circle.visible = true;
	healthbar.hide();
	
	await Game.wait(1);
	
	var tween = get_tree().create_tween();
	tween.tween_property(summoning_circle, "modulate", Color.WHITE, 0.5);
	await tween.finished;
	
	await Game.wait(0.1);
	
	summoning_circle.play();
	await summoning_circle.frame_changed;
	await summoning_circle.frame_changed;
	await summoning_circle.frame_changed;
	await summoning_circle.frame_changed;
	
	animated_sprite.position = animated_sprite.position - Vector2(0, 5);
	
	var tween_demon = get_tree().create_tween();
	tween_demon.tween_property(animated_sprite, "modulate", Color.WHITE, 1);
	tween_demon.set_ease(Tween.EASE_OUT);
	var tween_demon_2 = get_tree().create_tween();
	tween_demon_2.tween_property(animated_sprite, "position", animated_sprite.position - Vector2(0, 20), 1);
	tween_demon_2.set_ease(Tween.EASE_OUT);
	
	await summoning_circle.animation_finished;
	await tween_demon.finished;
	
	var tween_demon_d = get_tree().create_tween();
	tween_demon_d.tween_property(animated_sprite, "position", animated_sprite.position + Vector2(0, 3), 0.5);
	tween_demon_d.set_ease(Tween.EASE_IN_OUT);
	await tween_demon_d.finished;
	var tween_demon_u = get_tree().create_tween();
	tween_demon_u.tween_property(animated_sprite, "position", animated_sprite.position - Vector2(0, 3), 0.5);
	tween_demon_u.set_ease(Tween.EASE_IN_OUT);
	await tween_demon_u.finished;
	var tween_demon_db = get_tree().create_tween();
	tween_demon_db.tween_property(animated_sprite, "position", animated_sprite.position + Vector2(0, 3), 0.5);
	tween_demon_db.set_ease(Tween.EASE_IN_OUT);
	await tween_demon_db.finished;
	
	# fall
	var tween_demon_3 = get_tree().create_tween();
	tween_demon_3.tween_property(animated_sprite, "position", original_sprite_pos, 0.1);
	tween_demon_3.set_ease(Tween.EASE_IN);
	
	var tween_out = get_tree().create_tween();
	tween_out.tween_property(summoning_circle, "modulate", Color.TRANSPARENT, 0.5);
	
	await tween_demon_3.finished;
	await Game.wait(0.1);
	
	healthbar.show();
	shadow.show();
	emit_signal("summoned");
	set_state(State.MOVE);


func _update_summoning(_delta):
	pass
	
func summon():
	print("summon player");
	set_state(State.SUMMONING);
	return self.summoned;

# ============
# DESUMMONED

func _enter_desummoned():
	animated_sprite.play("summon");
	shadow.hide();
	healthbar.hide();
	summoning_circle.modulate = Color.TRANSPARENT;
	summoning_circle.visible = true;
	
	# fade summining circle in
	var tween = get_tree().create_tween();
	tween.tween_property(summoning_circle, "modulate", Color.WHITE, 0.5);
	await tween.finished;
	
	await Game.wait(0.1);
	
	var original_sprite_pos = animated_sprite.position;
	animated_sprite.position = animated_sprite.position - Vector2(0, 5);
	var tween_demon_2 = get_tree().create_tween();
	tween_demon_2.tween_property(animated_sprite, "position", animated_sprite.position - Vector2(0, 20), 1);
	tween_demon_2.set_ease(Tween.EASE_OUT);
	
	summoning_circle.play();
	await summoning_circle.frame_changed;
	await summoning_circle.frame_changed;
	await summoning_circle.frame_changed;
	await summoning_circle.frame_changed;
	
	await summoning_circle.animation_finished;
	await tween_demon_2.finished;
	
	# fall
	var tween_demon_3 = get_tree().create_tween();
	tween_demon_3.tween_property(animated_sprite, "position", original_sprite_pos, 0.2);
	tween_demon_3.set_ease(Tween.EASE_IN);
	var tween_demon = get_tree().create_tween();
	tween_demon.tween_property(animated_sprite, "modulate", Color.TRANSPARENT, 0.2);
	tween_demon.set_ease(Tween.EASE_OUT);
	
	await Game.wait(0.5);
	
	var tween_out = get_tree().create_tween();
	tween_out.tween_property(summoning_circle, "modulate", Color.TRANSPARENT, 0.5);
	
	await Game.wait(1);
	emit_signal("desummoned");

func desummon():
	set_state(State.DESUMMONED);
	return desummoned;

# ==========
# STATE MANAGEMENT

func set_state(new_state: State):
	var new_state_name = State.keys()[new_state];
	
	if state == State.DIE:
		print("can't leave death ", new_state_name);
		# no leaving death
		return;
	
	if state == State.DESUMMONED:
		if new_state == State.DESUMMONED:
			print("restart desummoned ", new_state_name);
			_enter_desummoned();
			state = new_state;
			return;
		elif new_state == State.SUMMONING:
			print("summoning ", new_state_name);
			# only move from desummoned to summoning
			_enter_summoning();
			state = new_state;
			return;
		else:
			print("can't leave desummoned ", new_state_name);
			return;
	
	state = new_state;
	match new_state:
		State.MOVE: _enter_move();
		State.HIT_1: _enter_hit_1();
		State.HIT_2: _enter_hit_2();
		State.HIT_3: _enter_hit_3();
		State.DIE: _enter_die();
		State.SUMMONING: _enter_summoning();
		State.DESUMMONED: _enter_desummoned();
	
	print("new player state: ", State.keys()[new_state]);


func update_orientation():
	if velocity.x > 0:
		set_orientation(Direction.RIGHT);
	if velocity.x < 0:
		set_orientation(Direction.LEFT);


func set_orientation(orient: Direction):
	orientation = orient;
	
	if orientation == Direction.LEFT:
		hurtbox_hit_left.show();
		hurtbox_hit_right.hide();
		animated_sprite.flip_h = true;
	else:
		hurtbox_hit_left.hide();
		hurtbox_hit_right.show();
		animated_sprite.flip_h = false;

func _on_hitbox_hit(damage: float, hitter: Node2D) -> void:
	if (
		state == State.DESUMMONED or
		state == State.SUMMONING or
		state == State.DODGE or
		state == State.DIE
	):
		return;
	print("player hit ", damage, " ", hitter);
	if (
		state == State.DODGE or
		state == State.SUMMONING or
		state == State.DESUMMONED or
		state == State.DIE
	):
		return;
		
	var direction = hitter.global_position - global_position;
	velocity = -direction.limit_length(1) * 200;

	health = max(health - damage, 0);
	var tween = get_tree().create_tween();
	animated_sprite.modulate = Color.RED;
	
	#var light = $AnimatedSprite2D/PointLight2D;
	#light.visible = true;
	#light.energy = 12;
	
	var duration = 0.3;
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, duration);
	#tween.tween_property(light, "energy", 1, duration);
	tween.set_ease(Tween.EASE_IN);

	if (health <= 0):
		set_state(State.DIE);

func update_health():
	var before = max_health;
	max_health = base_max_health + Game.health_buff * 5;
	var difference = max_health - before;
	# heal by the newly gained health
	health = min(max_health, difference);
