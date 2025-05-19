extends CharacterBody2D

@export var inertia : float = 80
@export var wheelRadius : float = 0.37
@export var wheelBase : int = 5
@export var brakeTorque : float = 1200
@export var steerAngle : float = 0.1
@export var dragLCoeff : float = 0.005
@export var dragQCoeff : float = 0.001

var engine : Engn
var wheelAngularVelocity : float = 0
var rot : float = 0

@onready var sprite = $Sprite2D
@onready var col = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		engine.start(delta)
	
	if Input.is_action_just_pressed("ui_up"): engine.gear += 1
	elif Input.is_action_just_pressed("ui_down"): engine.gear -= 1
	
	var throttle = Input.get_axis("down", "up")
	if throttle < 0:
		var brake = brakeTorque * delta / inertia
		if wheelAngularVelocity > 0: wheelAngularVelocity -= brake
		elif wheelAngularVelocity < 0: wheelAngularVelocity += brake
		throttle = 0
	engine.update(throttle, true, delta)
	
	var wDrag = self.wheelAngularVelocity ** 2 * self.dragQCoeff + self.wheelAngularVelocity * self.dragLCoeff
	self.wheelAngularVelocity -= wDrag * delta / self.inertia
	var speed = self.wheelAngularVelocity * self.wheelRadius
	
	velocity = col.transform.x * speed                                                                                                                 
	
	var steer_input = Input.get_axis("left", "right")
	steer_input *= -steerAngle
	
	var front_wheel = position + col.transform.x * self.wheelBase / 2.0
	var rear_wheel = position - col.transform.x * self.wheelBase / 2.0
	
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_input) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = new_heading * velocity.length()
	if d < 0:
		velocity = -new_heading * velocity.length()
	rot = new_heading.angle()
	sprite.set_sprite_rotation(rot)
	$CollisionShape2D.rotation = rot
	velocity *= 10
	move_and_slide()
