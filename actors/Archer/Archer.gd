extends CharacterBody2D

signal dead;

const SPEED: float = 80;
const FRICTION = 0.20;
#var velocity = Vector2.ZERO;

var max_health: float = 4;
var health: float = 4;

var damage = 2;

enum State {
	CHASE,
	PREPARE,
	ATTACK,
	HURT,
	DIE
};
var state = State.CHASE;

enum Direction {
	LEFT,
	RIGHT
}

var orientation = Direction.LEFT;

var hurt_recoil_speed: Vector2 = Vector2.ZERO;

var ArcherArrow = preload("res://actors/Archer/ArcherArrow.tscn");

@onready var hitbox = $Hitbox;
@onready var animated_sprite = $AnimatedSprite2D;
@onready var shadow = $Shadow;

@onready var prepare_timer = $prepare_timer;
@onready var attack_timer = $attack_timer;

@onready var navigation_agent = $NavigationAgent2D;

func _ready():
	set_state(State.CHASE);
	navigation_agent.connect("velocity_computed", _on_navigation_agent_2d_velocity_computed);

	hitbox.connect("hit", _on_hit);

func _physics_process(delta: float) -> void:
	match state:
		State.CHASE:
			_update_chase(delta);
		State.PREPARE:
			_update_prepare(delta);
		State.ATTACK:
			_update_attack(delta);
		State.HURT:
			_update_hurt(delta);
		State.DIE:
			_update_die(delta);


# ============
# PREPARE

func _enter_prepare():
	animated_sprite.play("shoot");
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	await animated_sprite.frame_changed;
	set_state(State.ATTACK);

func _update_prepare(_delta: float):
	var direction = get_player_position() - global_position;
	update_orientation(direction);


# ============
# ATTACK

func _enter_attack():
	shoot(damage);
	await animated_sprite.animation_finished;
	await Game.wait(1);
	set_state(State.CHASE);

func _update_attack(_delta: float):
	pass

func shoot(damage: float):
	var new_arrow = ArcherArrow.instantiate();
	new_arrow.global_position = global_position - Vector2(0, 30);
	var player = get_player();
	new_arrow.damage = damage;
	new_arrow.target_position = player.global_position + player.velocity.limit_length(1) * 40;
	get_parent().add_child(new_arrow);

# ============
# HURT

func _enter_hurt():
	animated_sprite.play("hurt");
	print("hurt enter");
	velocity = hurt_recoil_speed * 5;
	
	await Game.wait(0.3);
	
	if state == State.HURT:
		set_state(State.CHASE);

func _update_hurt(_delta):
	velocity *= 0.9;
	move_and_slide();


func _on_hit(damage: float, player: Node2D):
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
	get_player().heal(1);
	shadow.hide();
	var tween = get_tree().create_tween();
	var fade_duration = 1;
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration);
	await tween.finished;
	dead.emit();
	queue_free();
	
func _update_die(_delta):
	velocity *= 0.9;
	move_and_slide();


# ============
# CHASE

func _enter_chase():
	animated_sprite.play("run");

func _update_chase(delta: float) -> void:
	if velocity.length() < 2:
		animated_sprite.stop();
	else:
		if !animated_sprite.is_playing():
			animated_sprite.play();
	
	if (
		(global_position.x > 80 and global_position.x < 400) and
		navigation_agent.is_navigation_finished() or navigation_agent.distance_to_target() < 7
	):
		if global_position.x > 80 and global_position.x < 400:
			set_state(State.PREPARE);
		
	var closest_player_position = get_player_position();
	navigation_agent.target_position = get_closest_player_safe_position(closest_player_position);
	
	if (navigation_agent.is_navigation_finished()):
		return;
	
	var target_position = navigation_agent.get_next_path_position();
	
	var direction = (target_position - global_position).normalized();
	var target_velocity = direction * SPEED;
	
	var intended_velocity = velocity + (target_velocity - velocity) * FRICTION;
	navigation_agent.set_velocity(intended_velocity);
	
	update_orientation(velocity);

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if state == State.CHASE:
		velocity = safe_velocity.limit_length(SPEED);
		move_and_slide();


func get_player_position():
	var player = get_player();
	var player_pos = player.global_position;
	return player_pos;

func get_closest_player_safe_position(player_pos: Vector2):
	
	if global_position.x > 20 and global_position.x < 470:
		var distance = (player_pos - global_position).length();
		if distance > 200:
			return global_position;
	
	var x = player_pos.x;
	var y = player_pos.y;
	
	var screen_width = 480;
	var screen_height = 270;
	var battlefield_start = 112;
	var battlefield_height = 121;
	
	if player_pos.x < screen_width / 2:
		x += 120;
	else:
		x -= 120;
	
	if player_pos.y < battlefield_start + battlefield_height / 2:
		y += 30;
	elif player_pos.y > battlefield_start + battlefield_height / 2:
		y -= 30;
	
	return Vector2(x, y);

# ============
# STATE MANAGEMENT

func set_state(new_state: State):
	if state == State.DIE:
		return;
	
	if new_state == State.ATTACK and state != State.PREPARE:
		new_state = State.CHASE;
		
	match new_state:
		State.CHASE: _enter_chase();
		State.PREPARE: _enter_prepare();
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

