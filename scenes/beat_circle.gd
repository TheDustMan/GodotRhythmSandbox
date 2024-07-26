extends Node2D

@export var _moving_beat_scene: PackedScene = null
@export var _ghost_scene: PackedScene = null
@onready var _follow := $Path2D/PathFollow2D
var _tween: Tween = null

var _moving_beat: Node2D = null
var _ghost: Node2D = null

func create_ghost() -> void:
	_ghost.global_position = _moving_beat.global_position
	_ghost.global_rotation = _moving_beat.global_rotation
	_ghost.visible = true
	
func remove_ghost() -> void:
	_ghost.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	Events.connect("beat_started", Callable(self, "_on_reset"))
	Events.connect("beat_stopped", Callable(self, "_on_reset"))
	_moving_beat = _moving_beat_scene.instantiate()
	_follow.add_child(_moving_beat)
	_ghost = _ghost_scene.instantiate()
	_ghost.visible = false
	self.add_child(_ghost)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass
	
func _on_beat(msg: Dictionary) -> void:
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
	
func _on_reset(msg) -> void:
	if _tween != null and _tween.is_running():
		_tween.stop()
		_tween = null
	_follow.progress_ratio = 0
	remove_ghost()

func _on_action() -> void:
	create_ghost()
	$BeatText._on_action_pressed()
