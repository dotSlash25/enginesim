extends Node2D

@onready var label: Label = $CanvasLayer/Control/MarginContainer/VBoxContainer/Label
@onready var gearLabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/Label2
@onready var rpmLabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/Label3
@onready var car = $RedCar

func _process(delta: float) -> void:
	label.text = "Speed: " + str(roundf(car.velocity.length()) * 3.6 / 10) + "km/h"
	rpmLabel.text = "RPM: " + str(car.engine.getRPM())
	gearLabel.text = "Gear: " + str(car.engine.gear)
