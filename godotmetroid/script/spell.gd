extends AnimatedSprite2D

var speed : int = 600
var direction : int
var damage_amount : int = 1
var spell_impact_effect = preload("res://scenes/SpellImpactEffect.tscn")

func _physics_process(delta):
	move_local_x(direction * speed * delta)
	
func _on_timer_timeout():
	queue_free()


func _on_hitbox_area_entered(area):
	print("Bullet area entered")
	spell_impact()


func _on_hitbox_body_entered(body):
	print("Bullet body entered")
	spell_impact()
	
func spell_impact():
	var spell_impact_effect_instance = spell_impact_effect.instantiate() as Node2D
	spell_impact_effect_instance.global_position = global_position
	get_parent().add_child(spell_impact_effect_instance)
	queue_free()

func get_damage_amount() -> int:
	return damage_amount
