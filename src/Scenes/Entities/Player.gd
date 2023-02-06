extends KinematicBody2D

onready var healthbar = self.get_parent().get_node('Healthbar')
var type = 'Player'
var has_died = false
var max_health = 600
var curr_health = max_health
var velocity = Vector2()
var speeds = [
	500,
	800
]
var speed = speeds[0]
var strafe_speed = 100 + speed/2
var dir = 0
var gravity_vec = Vector2()
var bullet = preload("res://Scenes/Projectiles/Bullet.tscn")
var missle = preload("res://Scenes/Projectiles/Missle.tscn")
var can_fire = 0
var can_crash = 0
var missle_delay = 300
var can_fire_missle = 0
var crash_delay = 60
var fire_delay = 3
var ammo = 3000
var max_ammo = 6000
var ammo_cap = 40
var ammo_regen = 20
var affect = 'no_item'
var has_affect = 0
var affect_time = 180


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
			
func _physics_process(delta):
	if has_died: return
	handle_input()
	check_pos()
	update_variables()
	update_game_components()
	velocity.x = move_and_slide(velocity+gravity_vec).x
	if curr_health == 0: player_death()

func update_variables():
	can_crash = max(can_crash-1, 0)
	can_fire = max(can_fire-1, 0)
	can_fire_missle = max(can_fire_missle-1, 0)
	has_affect = max(has_affect-1, 0)
	if has_affect == 0:
		remove_affect()
	ammo = min(ammo+ammo_regen, max_ammo)
	
func update_game_components():
	var ammobar = self.get_parent().get_node('Ammobar')
	ammobar.value = ammo
	
func handle_input():
	handle_directional_input()
	handle_other_input()
		
func handle_directional_input():
	velocity = Vector2()
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	# Directions
	if up:
		velocity.y = -speed
	if down:
		velocity.y += speed
	if right:
		velocity.x = strafe_speed
	if left: 
		velocity.x -= strafe_speed

func handle_other_input():
	
	var reg_attack = Input.is_action_pressed('ui_accept')
	var missle_attack = Input.is_action_pressed('ui_special_attack')
	var powerup = Input.is_action_pressed('ui_select')
	
	if reg_attack and can_fire <= 0 and ammo > max_ammo/ammo_cap:
		var b1 = bullet.instance()
		var b2 = bullet.instance()
		self.get_parent().add_child(b1)
		self.get_parent().add_child(b2)
		b1.init(self, self.get_node('Gun1').get_global_position())
		b2.init(self, self.get_node('Gun2').get_global_position())
		ammo -= max_ammo/ammo_cap
		can_fire = fire_delay
	elif missle_attack and can_fire_missle <= 0:
		var mouse_pos = get_viewport().get_mouse_position()
		var mis = missle.instance()
		self.get_parent().add_child(mis)
		mis.init(self, mouse_pos)
		can_fire_missle = missle_delay
	if powerup:
		get_parent().get_node('Items').most_recent_item()
	
func player_death():
	has_died = true
	$AnimatedSprite.animation = 'Death'
	$AnimatedSprite.play()
	yield($AnimatedSprite, 'animation_finished')
	self.visible = false
			
func check_pos():
	var bounds_x = self.get_parent().bounds_x
	var bounds_y = self.get_parent().bounds_y
	# check x
	if (position.x > bounds_x[0]):
		position.x = bounds_x[0]
	elif (position.x < bounds_x[1]):
		position.x = bounds_x[1]
	# check y
	if (position.y > bounds_y[0]):
		position.y = bounds_y[0]
	elif (position.y < bounds_y[1]):
		position.y = bounds_y[1]
		
func apply_affect(affect):
	self.affect = affect
	has_affect = affect_time
	if affect == 'speed':
		speed = speeds[1]
		strafe_speed = 100 + speed/2
	elif affect == 'heal':
		curr_health = max_health
		healthbar.value = curr_health
	
func remove_affect():
	affect = 'no_item'
	speed = speeds[0]
	strafe_speed = 100 + speed/2
	
func handle_collision(proj) -> bool:
	if proj.parent in type:
		return false
	else:
		if affect != 'invincibility':
			curr_health = max(curr_health - proj.damage, 0)
			healthbar.value = curr_health
		return true
