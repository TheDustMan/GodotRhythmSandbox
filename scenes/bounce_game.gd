extends Node2D

signal start_pressed
signal quit_pressed
signal restart_pressed
signal primary_action

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("beat_early", Callable(self, "_on_beat_early"))
	Events.connect("beat_late", Callable(self, "_on_beat_late"))
	Events.connect("beat_perfect", Callable(self, "_on_beat_perfect"))
	Events.connect("beat_miss_late", Callable(self, "_on_beat_miss_late"))
	Events.connect("beat_miss_early", Callable(self, "_on_beat_miss_early"))


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
	$Synchronizer.start()


func _on_quit_pressed() -> void:
	$Synchronizer.stop()


func _on_primary_action() -> void:
	$BeatCircle._on_action()
	
func _on_beat_early(msg: Dictionary) -> void:
	$Score.increment(1)
	
func _on_beat_late(msg: Dictionary) -> void:
	$Score.increment(1)
	
func _on_beat_perfect(msg: Dictionary) -> void:
	$Score.increment(1)
	
func _on_beat_miss_late(msg: Dictionary) -> void:
	$Score.reset()

func _on_beat_miss_early(msg: Dictionary) -> void:
	$Score.reset()
