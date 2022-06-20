extends CanvasLayer

onready var paused = false

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_released("pause"):
		if paused == true:
			paused = false
		elif paused == false:
			paused = true
	if paused:
		$ColorRect.visible = true
		get_tree().paused = true
	elif ! paused:
		$ColorRect.visible = false
		get_tree().paused = false
		
func _ready():
	$ColorRect.visible = false
	

func _on_Quit_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	paused = false


func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
