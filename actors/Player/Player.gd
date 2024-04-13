extends CharacterBody2D

const SPEED = 120.0;
const FRICTION = 0.20;

var health: float = 10;

var controllable: bool = true;

enum Direction {
	LEFT,
	RIGHT
}
var orientation = Direction.RIGHT;

enum State {
	MOVE,
	HIT_1,
	HIT_2,
	HIT_3,
	ATTACK,
	DODGE,
	DIE
}
var state: State = State.MOVE;

var dodge_available = true;

var hit_action_triggered = false;
var hit_end_position: Vector2 = Vector2.ZERO;

@onready var hitbox = $hitbox;
@onready var hurtbox_hit_right = $hurtbox_hit_right;
@onready var hurtbox_hit_left = $hurtbox_hit_left;
@onready var animated_sprite = $AnimatedSprite2D;


func _physics_process(delta: float) -> void:
	match (state):
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
	

# ===========
# MOVE

func _enter_move():
	velocity = Vector2.ZERO;
	animated_sprite.animation = "walk";

func _update_move(_delta: float):
	if (!controllable): return;
	
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
	var target_velocity = direction * SPEED;
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
	hit();
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
	hit();
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
	hit();
	await animated_sprite.animation_finished;
	set_state(State.MOVE);
	
func _update_hit_3():
	pass


func hit(hit_strength: float = 1):
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
	velocity = input_direction * get_dodge_distance();
	
	
	set_state(State.DODGE);
	await Game.wait(0.4);
	set_collision_mask_value(9, true);
	set_state(State.MOVE);

func get_dodge_distance():
	return 500 + Game.dodge_distance_buff;

func _update_dodge():
	velocity *= 0.9;
	move_and_slide();


func set_state(new_state: State):
	match new_state:
		State.MOVE: _enter_move();
		State.HIT_1: _enter_hit_1();
		State.HIT_2: _enter_hit_2();
		State.HIT_3: _enter_hit_3();
	state = new_state;


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

func _on_hitbox_hit(damage: float, _hitter: Node2D) -> void:
	health -= damage;

	if (health <= 0):
		die();

func die():
	controllable = false;
	Game.wait(5);
	SceneManager.change_scene("res://scenes/MainScene/MainScene.tscn")
	
