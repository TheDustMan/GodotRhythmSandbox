extends Node2D

@export var _moving_beat_scene: PackedScene = null
@onready var _follow := $Path2D/PathFollow2D
var _moving_beat: MovingBeat
var _tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	Events.connect("beat_started", Callable(self, "_on_reset"))
	Events.connect("beat_stopped", Callable(self, "_on_reset"))
	_moving_beat = _moving_beat_scene.instantiate()
	_follow.add_child(_moving_beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_beat(msg):
	var time_between_beats = 1.0 / (msg.bpm / 60.0);
	_tween = create_tween()
	var property_tween = _tween.tween_property(
		_follow,
		"progress_ratio",
		1,
		time_between_beats)
	property_tween.from(0)
	property_tween.set_ease(Tween.EASE_OUT_IN)
	_tween.play()
	
func _on_reset(msg):
	if _tween != null and _tween.is_running():
		_tween.stop()
		_tween = null
	_follow.progress_ratio = 0
