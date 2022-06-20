extends Area2D



func _on_EnergyToken_body_entered(body):
	$Sprite.visible = false
	$CollisionShape2D.disabled = true
	yield(get_tree().create_timer(2),"timeout")
	$Sprite.visible = true
	$CollisionShape2D.disabled = false
	
