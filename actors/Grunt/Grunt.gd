extends CharacterBody2D

const SPEED: float = 80;
const FRICTION = 0.20;
#var velocity = Vector2.ZERO;

var max_health: float = 4;
var health: float = 4;

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

@onready var hitbox = $Hitbox;
@onready var hurtbox_left = $hurtbox_left;
@onready var hurtbox_right = $hurtbox_right;
@onready var animated_sprite = $AnimatedSprite2D;

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


func _enter_chase():
	pass

func _update_chase(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		if hurtbox_left.in_range:
			if orientation != Direction.LEFT:
				set_orientation(Direction.LEFT);
			set_state(State.PREPARE);
			return;
		
		if hurtbox_right.in_range:
			if orientation != Direction.RIGHT:
				set_orientation(Direction.RIGHT);
			set_state(State.PREPARE);
			return;
	
	var closest_player_position = get_player_position();
	navigation_agent.target_position = get_closest_player_hit_position(closest_player_position);
	
	if (navigation_agent.is_navigation_finished()):
		return;
	
	var target_position = navigation_agent.get_next_path_position();
	
	var direction = (target_position - global_position).normalized();
	var target_velocity = direction * SPEED;
	
	var intended_velocity = velocity + (target_velocity - velocity) * FRICTION;
	navigation_agent.set_velocity(intended_velocity);
	
	update_orientation(velocity);
	global_position += velocity * delta;


func _enter_prepare():
	prepare_timer.start(1);
	
func _update_prepare(_delta: float):
	if prepare_timer.is_stopped():
		set_state(State.ATTACK);



func _enter_attack():
	attack_timer.start(0.5);
	hit();

func _update_attack(_delta: float):
	if attack_timer.is_stopped():
		set_state(State.CHASE);


func _enter_hurt():
	print("hurt enter");
	velocity = hurt_recoil_speed * 5;
	
	await Game.wait(0.5);
	
	if state == State.HURT:
		set_state(State.CHASE);

func _update_hurt(_delta):
	velocity *= 0.9;
	move_and_slide();


func hit(hit_strength: float = 1):
	if orientation == Direction.LEFT:
		hurtbox_left.damage = hit_strength;
		hurtbox_left.activate();
	if orientation == Direction.RIGHT:
		hurtbox_right.damage = hit_strength;
		hurtbox_right.activate();



func _on_hit(damage: float, player: Node2D):
	get_hit(damage, (global_position - player.global_position).normalized());

func get_hit(damage: float, direction: Vector2):
	health = max(health - damage, 0);
	hurt_recoil_speed = direction * 80;
	set_state(State.HURT);
	
	if health == 0:
		die();


func die():
	set_state(State.DIE);
	var tween = get_tree().create_tween();
	var fade_duration = 1;
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration);
	await tween.finished;
	queue_free();

func _enter_die():
	pass
func _update_die(_delta):
	velocity *= 0.9;
	move_and_slide();

func set_state(new_state: State):
	match new_state:
		State.CHASE: _enter_chase();
		State.PREPARE: _enter_prepare();
		State.ATTACK: _enter_attack();
		State.HURT: _enter_hurt();
		State.DIE: _enter_die();
		_: print("UNDEFINED ENTER STATE!!");
	state = new_state;


func update_orientation(direction: Vector2):
	if direction.x > 0.5:
		set_orientation(Direction.RIGHT);
	if direction.x < 0.5:
		set_orientation(Direction.LEFT);


func set_orientation(orient: Direction):
	orientation = orient;
	
	if orientation == Direction.LEFT:
		hurtbox_left.show();
		hurtbox_right.hide();
		animated_sprite.flip_h = true;
	else:
		hurtbox_left.hide();
		hurtbox_right.show();
		animated_sprite.flip_h = false;


func get_player() -> CharacterBody2D:
	return get_tree().get_nodes_in_group('player')[0];

func get_player_position():
	var player = get_player();
	var player_pos = player.global_position;
	return player_pos;

func get_closest_player_hit_position(player_pos: Vector2):
	if player_pos.x < global_position.x:
		return Vector2(player_pos.x + 16, player_pos.y);
	else:
		return Vector2(player_pos.x - 16, player_pos.y);


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if state == State.CHASE:
		velocity = safe_velocity