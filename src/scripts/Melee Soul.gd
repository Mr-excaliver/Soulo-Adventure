extends KinematicBody2D

signal kunai_drop
const MAX_SPEED = 200
const ACCELERATION = 5
const KNOCKBACK = 30

var block = 0
var max_health = 60
var health = max_health
var motion = Vector2()
var direction = 1
var right_pathway =  0
var left_pathway = 0
var knockback = Vector2.ZERO
var knockback_strength = 34
var knockback_dir = 1

onready var Update_tween = $Update_tween
onready var current_position = global_position.x
onready var original_altitude = global_position.y
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var atk_hurtbox = $atk/hurtbox/CollisionShape2D
onready var atk_holder = $atk/hurtbox
onready var identifier = $right
onready var identifier2 = $right_down

onready var timer_atk = $attack_recovery
onready var timer = $stun_timer
onready var invinc_timer = $invincible
onready var hitbox = $hitbox/hit_area
onready var actual_health = $HEALTHBAR
onready var health_health = $healthbar
export var right_length = 50
export var left_length = -50
export (bool) var move_active : bool = true
var kunai_refill : Array = [0, 1 , 2 , 3 , 4]
var state = move_state
var score = 10
var variant_dmg = 0 
enum {
	move_state
	attack_state
	hit_state
}
func _ready() -> void:
	health_health.visible = false
	actual_health.visible = false
	health_health.max_value = max_health
	actual_health.max_value = max_health

func _physics_process(_delta):

	if global_position.y != original_altitude:
		global_position.y = original_altitude
	
	if timer_atk.is_stopped():
		if identifier.is_colliding() == true or identifier2.is_colliding() == true:
			motion.x = lerp(motion.x , 0 , 0.5)
			state = attack_state



	match state:
		move_state:
			move()
		attack_state:
			attack()
		hit_state:
			hit()

	motion = move_and_slide(motion)

func hit():
	sprite.material.set_shader_param("flash_modifier", 0.854)
	state = move_state 
	$flash.start()
func move():
	sprite.play("idle")
	right_pathway = right_length + current_position
	left_pathway = left_length + current_position

	if global_position.x >= right_pathway:
		direction = -1 
		motion.x = lerp(motion.x , 0, 0.1)
	if global_position.x <= left_pathway:
		direction = 1 
		motion.x = lerp(motion.x, 0, 0.1)

	if motion.x > MAX_SPEED:
		motion.x = MAX_SPEED

	if direction == 1:
		motion.x = min(motion.x + ACCELERATION , MAX_SPEED)
		sprite.flip_h = false
		flip()
	else:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		sprite.flip_h = true
		flip()

func attack():
	if identifier.enabled == true:
		anim_player.play("attack")
		sprite.play("attack")
		yield(anim_player,"animation_finished")
		state = move_state
		timer_atk.start()

func die():
	var rand_drop = kunai_refill[randi() % kunai_refill.size()]
	PlayerData.score += score
	emit_signal("kunai_drop", rand_drop)
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	hitbox.set_deferred("disabled", false)
	invinc_timer.start()
	#setting damage
	var melee_dmg = [20 , 30 , 20 , 20]
	var ranged_dmg = [10, 20 , 10 , 10]
	var damager = area.name
	if damager == "attack_hitbox":
		variant_dmg = melee_dmg[randi() % melee_dmg.size()]
	elif damager == "kunai":
		variant_dmg = ranged_dmg[randi() % ranged_dmg.size()]
	else:
		variant_dmg = 0 
	#determining whether to stun or not
	var stunned = [0 , 1 , 1 ]
	var stun = stunned[randi() % stunned.size()]
	if stun == 1:
		timer.start()
		identifier.enabled = false
		identifier2.enabled = false
	else:
		pass
	#changing state
	state = hit_state
	#taking damage
	health_health.visible = true
	actual_health.visible = true
	$healthbar_visiblility.start()
	health -= variant_dmg
	actual_health.value = health
	Update_tween.interpolate_property(health_health,"value", health_health.value, health , 0.4 , Tween.TRANS_SINE , Tween.EASE_IN_OUT, 0)
	Update_tween.start()
	#knockback
	var look_dir = null
	look_dir = int(self.global_position.x - area.global_position.x)
	if look_dir > 1:
		knockback_dir = 1
	if look_dir < 1:
		knockback_dir = -1 
	if knockback_dir == 1 && look_dir > 50:
		look_dir = look_dir - 25
	if knockback_dir == -1 && look_dir < -50:
		look_dir = look_dir + 25

	knockback = ((knockback_strength  * knockback_dir) * (look_dir * knockback_dir))/  8
	
	motion.x += knockback
	knockback = lerp(knockback , 0 , 0.5)
	get_parent().get_parent().get_node("ScreenShake").screen_shake(0.4, 15, 150)
	#checking whether health below or equals 0
	if health <= 0:
		die()

func flip():
		atk_hurtbox.position.x = 43 * direction
		identifier.cast_to.y = 50 * direction
		identifier2.cast_to.y = 55 * direction




func _on_VisibilityNotifier2D_screen_exited() -> void:
	set_physics_process(false)




func _on_VisibilityNotifier2D_screen_entered() -> void:
	set_physics_process(true)






func timeout() -> void:
	identifier.enabled = true
	identifier2.enabled = true



func _on_invincible_timeout() -> void:
	hitbox.disabled = false


func _on_flash_timeout() -> void:
	sprite.material.set_shader_param("flash_modifier", 0)


func _on_healthbar_visiblility_timeout() -> void:
	health_health.visible = false
	actual_health.visible = false
