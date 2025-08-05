extends Control

signal end_slow_mo
onready var scene_tree : = get_tree()
onready var pause_overlay := $PauseOverlay
onready var healthfull = $Heart_full
onready var healthempty = $Heart_empty

var paused : = false setget set_paused

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause"):
		self.paused = !paused
		scene_tree.is_input_handled()

func _ready() -> void:
	PlayerData.connect("score_updated", self , "score_change")
	score_change()
func set_paused(value: bool):
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value




func _on_Quit_button():
	self.paused = !paused
	PlayerData.score = 0


func _on_resume_button_refresh():
	self.paused = !paused


func _on_Retry_button():
	self.paused = !paused
	PlayerData.score = 0


func score_change():
	$score.text = "score    " + str(PlayerData.score)


func _on_Ninja__health_update(health) -> void:
	healthfull.rect_size.x = health * 22



func _on_Ninja__kunai_update(kunai_amount) -> void:
	$kunai_remaining.text = str(kunai_amount)



func _set_health_bar(health , max_health) -> void:
	healthempty.rect_size.x = 22 * max_health
	healthfull.rect_size.x = 22 * health


func slow_mo() -> void:
	$TextureRect.visible = true
	$TextureRect/AnimationPlayer.play("fade_in")


func slow_mo_end() -> void:
	$TextureRect.visible = false
	$TextureRect/AnimationPlayer.play("reset")

func faded_in(anim_name: String) -> void:
	if anim_name == "fade_in":
		emit_signal("end_slow_mo")
	


