extends Node2D

signal start_pressed
signal quit_pressed
signal restart_pressed
signal primary_action

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space_action"):
		start_pressed.emit()
	if Input.is_action_just_pressed("quit_action"):
		quit_pressed.emit()
	if Input.is_action_just_pressed("primary_action"):
		primary_action.emit()


func _on_start_pressed():
	$Synchronizer.stop()
	$Synchronizer.start()


func _on_quit_pressed():
	$Synchronizer.stop()


func _on_primary_action():
	$BeatCircle._on_action()
