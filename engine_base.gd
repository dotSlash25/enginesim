extends Node2D
class_name Engn

@export var maxTorque : float = 225
@export var maxPower : float = 120e3
@export var flywheelInertia : float = 0.2
@export var gearRatios : Array[float] = []
@export var finalDriveRatio : float = 3.91
@export var torqueCurveConsts : Array[int] = []
@export var clutchStiffness : float = 12.5
@export var starterMotorTorque : float = 40
@export var starterRPM : int = 1000
@export var flywheelDragLCoeff : float = 0.005
@export var flywheelDragQCoeff : float = 0.001
@export var drivetrainEfficiency : float = 0.85
@export var sound : Resource

var flywheelAngularVelocity : float = 0
var torque : float = 0
var car
var gear : int = 0

func _ready() -> void:
	car = get_parent()
	car.engine = self
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()

func update(throttle, clutchEngaged, delta) -> void:
	if self.flywheelAngularVelocity > 2: 
		$AudioStreamPlayer.stream_paused = false
		$AudioStreamPlayer.pitch_scale = remap(self.getRPM(), 0, torqueCurveConsts[3], 0, 1.5)
	else:
		$AudioStreamPlayer.stream_paused = true
	if self.flywheelAngularVelocity < 0: 
		self.flywheelAngularVelocity = 0
	var finalRatio = self.gearRatios[self.gear] * self.finalDriveRatio
	self.torque = max(throttle, 0.051) * self.getTorque()

	if self.torque * self.flywheelAngularVelocity > self.maxPower:
		self.torque = self.maxPower / self.flywheelAngularVelocity

	var tClutch = 0
	if self.gear and clutchEngaged:
		var w1Wheel = car.wheelAngularVelocity * finalRatio
		tClutch = self.clutchStiffness * (self.flywheelAngularVelocity - w1Wheel)
	if tClutch > self.maxTorque:
		tClutch = self.maxTorque
	elif tClutch < -self.maxTorque:
		tClutch = -self.maxTorque
	
	var wheelTorque = tClutch * finalRatio * drivetrainEfficiency if self.gear and clutchEngaged else 0

	var alphaWheel = wheelTorque / car.inertia
	car.wheelAngularVelocity += alphaWheel * delta

	self.torque -= tClutch
	var fDrag = self.flywheelAngularVelocity ** 2 * self.flywheelDragQCoeff + self.flywheelAngularVelocity * self.flywheelDragLCoeff
	fDrag = min(fDrag, self.maxTorque / 6)
	self.torque -= fDrag
	var alpha = self.torque / self.flywheelInertia
	self.flywheelAngularVelocity += alpha * delta

func getRPM() -> float:
	return flywheelAngularVelocity * 60 / TAU

func getTorque() -> float:
	var rpm = self.getRPM()
	var t0 = self.torqueCurveConsts[0]
	var t1 = self.torqueCurveConsts[1]
	var t2 = self.torqueCurveConsts[2]
	var t3 = self.torqueCurveConsts[3]
	if rpm < t0:
		return 0
	elif rpm < t1:
		return self.maxTorque * ((rpm - t0) / (t1 - t0))
	elif rpm < t2:
		return self.maxTorque
	elif rpm < t3:
		return self.maxTorque * (1.0 - (rpm - t2) / (t3 - t2))
	else:
		return 0.0

func start(delta) -> bool:
	var sTorque = self.starterMotorTorque
	if self.getRPM() >= self.starterRPM:
		return true
	else:
		self.flywheelAngularVelocity += sTorque * delta / self.flywheelInertia
	return false
