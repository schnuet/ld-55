extends CharacterBody2D

signal dead;

const SPEED: float = 40;
const FRICTION = 0.20;

var max_health: float = 25;
var health: float = 25;

var damage = 5;

enum State {
	PREPARE,
	JUMP,
	ATTACK,
	HURT,
	DIE
};
var state = State.PREPARE;

enum Direction {
	LEFT,
	RIGHT
}

var orientation = Direction.LEFT;

var hurt_recoil_speed: Vector2 = Vector2.ZERO;


@onready var hitbox = $Hitbox;
@onready var hurtbox = $hurtbox;
@onready var animated_sprite = $AnimatedSprite2D;
@onready var healthbar = $HealthbarBig;
@onready var animated_sprite_y = animated_sprite.position.y;
@onready var shadow = $Shadow;

@onready var prepare_timer = $prepare_timer;
@onready var attack_timer = $attack_timer;

@onready var navigation_agent = $NavigationAgent2D;

func _ready():
	
	healthbar.appear();
	
	set_state(State.PREPARE);
	
	hitbox.connect("hit", _on_hit);

func _physics_process(delta: float) -> void:
	match state:
		State.PREPARE:
			_update_prepare(delta);
		State.JUMP:
			_update_jump(delta);
		State.ATTACK:
			_update_attack(delta);
		State.HURT:
			_update_hurt(delta);
		State.DIE:
			_update_die(delta);


# ============
# PREPARE

func _enter_prepare():
	animated_sprite.play("crouch");
	await Game.wait(0.5);
	if state == State.PREPARE:
		set_state(State.JUMP);
	
func _update_prepare(_delta: float):
	var player_direction = get_player_position() - global_position;
	update_orientation(player_direction);

func get_player_position():
	var player = get_player();
	var player_pos = player.global_position;
	return player_pos;


# ========
# JUMP

var jump_target_pos = Vector2.ZERO;
var jump_start_position = Vector2.ZERO;

var jump_time_max: float = 0.5;
var jump_time: float = jump_time_max;

func _enter_jump():
	animated_sprite.play("jump_up");
	
	set_collision_layer_value(9, false);
	if jump_target_pos == null:
		jump_target_pos = get_player_position();
	jump_start_position = global_position;
	jump_time = jump_time_max;

func _update_jump(delta: float):
	jump_time -= delta;
	var percent_done: float = 1.0 - (jump_time) / jump_time_max;
	
	global_position = lerp(jump_start_position, jump_target_pos, percent_done);
	
	if percent_done >= 0.5 and animated_sprite.animation != "jump_down":
		animated_sprite.play("jump_down");
		
	var jump_progress = map_centered(percent_done);
	var jump_height = jump_progress * 100;
	animated_sprite.position.y = animated_sprite_y - jump_height;
	
	if percent_done >= 1:
		set_collision_layer_value(9, true);
		set_state(State.ATTACK);

## returns 1 when x is 0.5; 0 if x is 0 or 1.
func map_centered(x: float) -> float:
	return -4*((x - 0.5) * (x - 0.5)) + 1.0;

# ============
# ATTACK

var attack_has_hit = false;

func _enter_attack():
	jump_target_pos = null;
	animated_sprite.play("attack");
	hit(damage);
	var attack_move = (get_player_position() - global_position).normalized();
	velocity = attack_move * 600;
	attack_timer.start(1);
	await attack_timer.timeout;
	if state == State.ATTACK:
		print("attack done, move to prepare");
		set_state(State.PREPARE);

func _update_attack(_delta: float):
	pass

func hit(hit_strength: float = 1):
	hurtbox.damage = hit_strength;
	hurtbox.activate();

# ============
# HURT

func _enter_hurt():
	print("hurt enter");
	velocity = hurt_recoil_speed;
	
	await Game.wait(0.1);
	
	if state == State.HURT:
		set_state(State.PREPARE);

func _update_hurt(_delta):
	velocity *= 0.9;
	move_and_slide();


func _on_hit(damage: float, player: Node2D):
	if state == State.JUMP:
		return;
	
	get_hit(damage, (global_position - player.global_position).normalized());

func get_hit(damage: float, direction: Vector2):
	health = max(health - damage, 0);
	hurt_recoil_speed = direction * 40;
	set_state(State.HURT);
	
	if health == 0:
		set_state(State.DIE);

# ============
# DIE

func _enter_die():
	shadow.hide();
	var tween = get_tree().create_tween();
	var fade_duration = 1;
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration);
	await tween.finished;
	emit_signal("dead");
	queue_free();
	
func _update_die(_delta):
	velocity *= 0.9;
	move_and_slide();


# ============
# STATE MANAGEMENT

func set_state(new_state: State):
	if state == State.DIE:
		return;
		
	match new_state:
		State.PREPARE: _enter_prepare();
		State.JUMP: _enter_jump();
		State.ATTACK: _enter_attack();
		State.HURT: _enter_hurt();
		State.DIE: _enter_die();
		_: print("UNDEFINED ENTER STATE!!");
	state = new_state;

# ============
# ORIENTATION

func update_orientation(direction: Vector2):
	if direction.x > 0.5:
		set_orientation(Direction.RIGHT);
	if direction.x < 0.5:
		set_orientation(Direction.LEFT);

func set_orientation(orient: Direction):
	orientation = orient;
	
	if orientation == Direction.LEFT:
		animated_sprite.flip_h = true;
	else:
		animated_sprite.flip_h = false;


func get_player() -> CharacterBody2D:
	return get_tree().get_nodes_in_group('player')[0];

