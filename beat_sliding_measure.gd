extends Node2D

@export var _moving_beat_scene: PackedScene
var _beat_markers: Array[Node]
var _moving_beat: MovingBeat
var _beat_counter: int = 0
var _tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	Events.connect("beat_started", Callable(self, "_on_reset"))
	Events.connect("beat_stopped", Callable(self, "_on_reset"))
	_beat_markers = $BeatMarkers.get_children()
	_moving_beat = _moving_beat_scene.instantiate()
	_moving_beat.position = _beat_markers[0].position
	$Beats.add_child(_moving_beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_beat(msg):
	if _beat_counter >= _beat_markers.size() - 1:
		_beat_counter = 0
		return
	
	_moving_beat.position = _beat_markers[_beat_counter].position
	var time_between_beats = 1.0 / (msg.bpm / 60.0);
	_tween = create_tween()
	var property_tween = _tween.tween_property(
		_moving_beat,
		"position",
		_beat_markers[_beat_counter + 1].position,
		time_between_beats)
	property_tween.from(_beat_markers[_beat_counter].position)
	_tween.play()
	_beat_counter += 1
	
func _on_reset(msg):
	if _tween != null and _tween.is_running():
		_tween.stop()
	_beat_counter = 0
	_moving_beat.position = _beat_markers[_beat_counter].position
