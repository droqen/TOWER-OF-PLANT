extends CharacterBody2D

var flickerbuf : int = 20

func _ready():
	$CollisionShape2D.disabled = true
	velocity = Vector2.RIGHT.rotated(PI*randf()*2) * randf_range(1,2)
	position += velocity * 4
	velocity.y -= 2.0
	flickerbuf = 30 + roundi(velocity.length()*randf_range(4,6))

func _physics_process(delta: float) -> void:
	position += velocity
	velocity *= 0.98
	velocity.y += 0.001 # gradual gravity
	if flickerbuf > 0:
		flickerbuf -= 1
		if flickerbuf <= 0: show(); $CollisionShape2D.disabled = false;
		elif flickerbuf % 6 < 3: hide()
		else: show()
