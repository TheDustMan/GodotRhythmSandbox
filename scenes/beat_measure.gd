extends Node2D

@export var _moving_beat_scene: PackedScene
var _beat_markers: Array[Node]
var _moving_beat: MovingBeat
var _beat_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	_beat_markers = $BeatMarkers.get_children()
	_moving_beat = _moving_beat_scene.instantiate()
	_moving_beat.position = _beat_markers[0].position
	$Beats.add_child(_moving_beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass
	
func _on_beat(msg: Dictionary) -> void:
	if _beat_counter >= _beat_markers.size():
		_beat_counter = 0
	_moving_beat.position = _beat_markers[_beat_counter].position
	_beat_counter += 1
	
