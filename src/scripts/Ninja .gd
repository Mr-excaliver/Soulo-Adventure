extends KinematicBody2D
signal set_health_bar
signal kunai_update
signal health_update
signal slow_mo
signal slow_mo_end

const UP = Vector2(0, -1)
const ACCELERATION = 50
const  MAX_SPEED = 300
const JUMP_HEIGHT = -475
const GRAVITY = 20
const KUNAI  = preload("res://src/scenes/kunai.tscn")
onready var kunai_cooldown = $kunai_cooldown
onready var Pivot = $melee_range/attack_hitbox/attack_area
onready var Anim_player = $AnimationPlayer
onready var anim_sprite = $Sprite
onready var holder = $item_position
onready var atk_cooldown = $Atk
onready var invincible = $invincibility
onready var hitarea = $Player_hitbox
var motion = Vector2()
var jump_count = 0
var can_jump = false
var state = MOVEMENT
export var max_health = 6
var health = 0
var knockback = Vector2.ZERO
var knockback_strength = 43
var knockback_dir = 1
export var cap_kunai_amount = 69
var kunai_amount = 0
var end_of_slow = false
var in_progress = true
enum{
	MOVEMENT,
	ATTACK,
	HIT
}
func _ready() -> void:


	max_health = max_health
	health = max_health
	emit_signal("set_health_bar", health , max_health)
	kunai_amount = cap_kunai_amount

func _physics_process(_delta) -> void:


	motion.y += GRAVITY
	kunai_attack_info()

	if position.y > 900:
		health = 0 
		emit_signal("health_update", health)
		get_parent().get_node("ScreenShake").screen_shake(0.5, 4 , 100)
		queue_free()

	match state:
		MOVEMENT:
			movement()
		ATTACK:
			attack()
		HIT:
			hit()
		

	motion = move_and_slide(motion, UP)
func kunai_attack_info():

	var button_down = 0
	if kunai_amount > 0:

		if Input.is_action_just_pressed("mouse")&& state !=  ATTACK:
			button_down = 1
		if Input.is_action_just_released("mouse") && in_progress == false or end_of_slow == true:
			end_of_slow = false
			Engine.time_scale = 1
			emit_signal("slow_mo_end")
			get_parent().get_node("Camera2D").zoom_out()
			button_down = 2



		if button_down == 0:
			pass
		elif button_down == 1:
			get_parent().get_node("Camera2D").zoom_in()
			emit_signal("slow_mo")
			Engine.time_scale = .2
			in_progress = false
		elif button_down == 2 && kunai_cooldown.is_stopped():
			ranged_attack()
			flip()
			kunai_amount = kunai_amount - 1
			emit_signal("kunai_update", kunai_amount)
			button_down = 0
			

func movement() -> void:
	if Input.is_action_just_pressed("attack") && atk_cooldown.is_stopped():
		state = ATTACK
	
	if Input.is_action_pressed("right"):#movement to the right 
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		anim_sprite.flip_h = false
		Pivot.position.x = 50
		$melee_range/attack_hitbox/attack_down.position.x = 10
		holder.position.x = -6
		if Input.is_action_pressed("mouse") && kunai_amount > 0:
			anim_sprite.play("ground")
		else:
			anim_sprite.play("run")
		
	elif Input.is_action_pressed("left"):# movement to the left 
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		anim_sprite.flip_h = true
		Pivot.position.x = -50
		$melee_range/attack_hitbox/attack_down.position.x = -10
		holder.position.x = 6
		if Input.is_action_pressed("mouse") && kunai_amount > 0:
			anim_sprite.play("ground")
			pass
		else:
			anim_sprite.play("run") 

	else:
		motion.x = lerp(motion.x, 0, 0.2)
		if Input.is_action_pressed("mouse") && kunai_amount > 0:
			anim_sprite.play("ground")
			pass
		else:
			anim_sprite.play("idle") #motion idle

		
	if is_on_floor():# jump and double jump


		if Input.is_action_just_pressed("jump"):
			motion.y = JUMP_HEIGHT
			jump_count = 1
			can_jump = true 

	elif jump_count < 2 :#limiting double jump to 2 jumps
		if motion.y < 0:
			if Input.is_action_pressed("mouse") && kunai_amount > 0:
				anim_sprite.play("air")
				pass
			else:
				anim_sprite.play("jump")
		else:
			if Input.is_action_pressed("mouse") && kunai_amount > 0:
				anim_sprite.play("air")
				pass
			else:
				anim_sprite.play("fall")
		if Input.is_action_just_pressed("jump") && can_jump == true:
			get_parent().get_node("ScreenShake").screen_shake(0.4, 3, 50)
			motion.y = JUMP_HEIGHT
			jump_count = 2

	elif jump_count == 2 :
		can_jump  = false
		if motion.y < 0:
			if Input.is_action_pressed("mouse") && kunai_amount > 0:
				anim_sprite.play("air")
				pass
			else:
				anim_sprite.play("double_jump")
		else:
			if Input.is_action_pressed("mouse") && kunai_amount > 0:
				anim_sprite.play("air")
				pass
			else:
				anim_sprite.play("fall")
func hit():
	anim_sprite.material.set_shader_param("flash_modifier", 0.854)
	state = MOVEMENT
	$not_hit.start()
func attack() -> void:
	motion.x = lerp(motion.x, 0, 0.1)
	anim_sprite.play("attacking")
	Anim_player.play("attacking")
	atk_cooldown.start()

func _on_Sprite_animation_finished() -> void:
	state = MOVEMENT 

func ranged_attack():
	if KUNAI:
		var kunai = KUNAI.instance()
		get_tree().current_scene.add_child(kunai)
		kunai.global_position = holder.global_position
		var kunai_rotation = holder.global_position.direction_to((get_global_mouse_position() + Vector2(rand_range(-1, 1), rand_range(-1, 1)))).angle()
		kunai.rotation = kunai_rotation
		kunai_cooldown.start()


func flip():
	if get_global_mouse_position() > self.global_position:
		anim_sprite.flip_h = false
	if get_global_mouse_position() < self.global_position:
		anim_sprite.flip_h = true 

func _on_hitbox_area_entered(area: Area2D) -> void:

	if area.name == "health_pack" :
		health = max_health
		emit_signal("health_update", health)

			
	elif area.name != "health_pack":
		if invincible.is_stopped():
			state = HIT
			health -= 1
			invincible.start()

		emit_signal("health_update", health)
		var look_dir
		look_dir = int(self.global_position.x - area.global_position.x)

		if look_dir > 1:
			knockback_dir = 1
		if look_dir < 1:
			knockback_dir = -1 

		knockback = ((knockback_strength  * knockback_dir) * (look_dir * knockback_dir))/6
		get_parent().get_node("ScreenShake").screen_shake(0.5, 15 , 100)
		motion.x += knockback
	if health <= 0:
		get_parent().get_node("ScreenShake").screen_shake(0.5, 15 , 100)
		queue_free()


func kunai_drop(rand_drop) -> void:
	kunai_amount = min( cap_kunai_amount ,kunai_amount + rand_drop)
	emit_signal("kunai_update", kunai_amount)











func on_hit() -> void:
	anim_sprite.material.set_shader_param("flash_modifier", 0)


func end_slow_mo() -> void:
	end_of_slow = true
	in_progress = true
