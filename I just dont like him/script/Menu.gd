extends Control

func _on_PlayButton_pressed():
	get_tree().change_scene("res://scenes/World.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
