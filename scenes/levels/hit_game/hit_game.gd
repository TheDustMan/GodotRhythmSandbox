extends Node2D

signal start_pressed
signal quit_pressed
signal restart_pressed
signal primary_action

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if Input.is_action_just_pressed("space_action"):
		start_pressed.emit()
	if Input.is_action_just_pressed("quit_action"):
		quit_pressed.emit()
	if Input.is_action_just_pressed("primary_action"):
		primary_action.emit()


func _on_start_pressed() -> void:
	$Synchronizer.stop()
	$Synchronizer.start("beat")
	# TODO Pattern-player must be started after synchronizer to receive
	# initialization data. Try to make this not required.
	$RhythmPatternPlayer.play("fast", -1)


func _on_quit_pressed() -> void:
	$Synchronizer.stop()


func _on_primary_action() -> void:
	pass

