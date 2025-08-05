extends Area2D

onready var FIREBALL = preload("res://src/scenes/fireball.tscn")
signal kunai_drop
onready var detect_col = $ranged_soul/detect_range/CollisionShape2D
onready var pivot_pos = self.global_position
onready var spawn = $ranged_soul/Position2D
onready var Collision = $ranged_soul/CollisionShape2D
onready var shoot_cooldown = $ranged_soul/shoot_cooldown
onready var collision = $ranged_soul/detect_range/CollisionShape2D
onready var detect_range = $ranged_soul/detect_range
onready var main_soul = $ranged_soul
onready var sprite = $ranged_soul/sprite
onready var shield = $ranged_soul/force_sheild/AnimatedSprite
onready var force_shield = $ranged_soul/force_sheild
onready var actual_health = $ranged_soul/HEALTHBAR
onready var health_health = $ranged_soul/healthbar
onready var Update_tween = $ranged_soul/Update_tween
onready var health_visi_timer = $ranged_soul/Health_visibility
var score = 15
var hit = false
var max_health = 30
var health = max_health
var shield_dura =  20
var target
var player
var colour = Color(1.0 ,.329 , .289)
export (int) var des_rotation = -180
export (bool) var move_shield = true
var dmg = 10
var variant_dmg = 0 
var kunai_refill : Array = [ 2 , 3 , 4]
var length = Vector2()
export var diff = Vector2(100 , 0)
export var rotation_speed = PI
export var radius = 105
export var fire_rate = 0.5
var shoot_at

func _ready():
	set_process(false)
	move_shield = move_shield
	actual_health.visible = false
	health_health.visible = false
	actual_health.max_value = max_health
	health_health.max_value = max_health
	diff = diff 
	length = pivot_pos + diff
	main_soul.global_position = length
	Collision.disabled = true
	shoot_cooldown.wait_time = fire_rate
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	if move_shield == false:
		force_shield.queue_free()


func _process(delta):


	if player:
		if player.global_position.x > main_soul.global_position.x:
			sprite.flip_h = false
		elif player.global_position.x < main_soul.global_position.x:
			sprite.flip_h = true 
	if hit == true:
		hit = false
		sprite.material.set_shader_param("flash_modifier", 0.854)
		$ranged_soul/flash.start()
	else:
		if move_shield == true:
			sprite.play("idle")
			self.rotation += (rotation_speed * delta) / 3 
			$ranged_soul.global_rotation = 0
		else:
			Collision.disabled = false
			sprite.play("no_sheild")


	if target :
		if $ranged_soul/atk_timer.is_stopped():
			shoot_at = spawn.global_position.direction_to((target.global_position + Vector2(rand_range(-0.05, 0.05), rand_range(-0.05, 0.05)))).angle()
			shoot()


func health_method():
	
	var stunned = [1 , 0 , 0]
	var stun = stunned[randi() % stunned.size()]
	if stun == 1:
		$ranged_soul/stun.start()
		if detect_col:
			detect_col.set_deferred("disabled", true)
	else:
		pass
	hit = true

	actual_health.visible = true
	health_health.visible = true
	health -= variant_dmg
	actual_health.value = health
	Update_tween.interpolate_property(health_health, "value", health_health.value , health , 0.4 , Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	Update_tween.start()
	health_visi_timer.start()
	if health <= 0:
		die()


func die():
	var rand_drop = kunai_refill[randi() % kunai_refill.size()]
	PlayerData.score += score
	emit_signal("kunai_drop", rand_drop)
	queue_free()

func shoot():
	var fireball_rotation
	if FIREBALL && shoot_cooldown.is_stopped():
		var fireball = FIREBALL.instance()
		get_tree().current_scene.add_child(fireball)
		fireball.global_position = spawn.global_position
		fireball_rotation = shoot_at
		fireball.rotation = fireball_rotation
		shoot_cooldown.start()

func _on_ranged_soul_area_entered(area: Area2D) -> void:
	get_parent().get_node("ScreenShake").screen_shake(0.5 , 12 , 150)


	var melee_dmg = [20 , 30, 20 , 20]
	var ranged_dmg = [10, 20, 10 , 10]
	var damager = area.name
	if damager == "attack_hitbox":
		variant_dmg = melee_dmg[randi() % melee_dmg.size()]
	elif damager == "kunai":
		variant_dmg = ranged_dmg[randi() % ranged_dmg.size()]
	else:
		variant_dmg = 0 
	
	health_method()

func _on_detect_range_area_entered(area: Area2D) -> void:
	$ranged_soul/atk_timer.start()
	if target == null:
		target = area
		player = area


func _on_detect_range_area_exited(area: Area2D) -> void:
	if target == area:
		target = null




func _on_force_sheild_area_entered(_area: Area2D) -> void:
	get_parent().get_node("ScreenShake").screen_shake(0.5, 12 , 150)
	shield_dura = shield_dura - dmg 
	shield.material.set_shader_param("flash_modifier", 0.854)
	$ranged_soul/flash.start()
	if shield_dura <= 0:
		force_shield.queue_free()
		move_shield = false
	yield(shield,"animation_finished")
	shield.play("normal")








func _on_stun_timeout() -> void:
	if detect_col:
		detect_col.disabled = false





func inside_wall(body: Node) -> void:
	if body.name == "tomb tilemap":
		dmg = 0



func outside_wall(_body: Node) -> void:
	dmg = 10 


func _on_flash_timeout() -> void:
	sprite.material.set_shader_param("flash_modifier", 0)
	if force_shield:
			shield.material.set_shader_param("flash_modifier", 0)


func _on_Health_visibility_timeout() -> void:
	actual_health.visible = false
	health_health.visible = false


func not_visible() -> void:
	set_process(false)


func visible() -> void:
	set_process(true)
