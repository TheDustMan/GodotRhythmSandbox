extends Node2D

@export var animated_sprite: AnimatedSprite2D = null
@export var animation_name: String = ""
@export var beat_frame: int = 0

var _time_between_beats: float = 0.0
var _post_beat_enabled: bool = false
var _post_beat_animation_time: float = 0.0
var _pre_beat_animation_time: float = 0.0
var _post_beat_time: float = 0.0
var _time_to_next_beat: float = 0.0


func _ready() -> void:
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	Events.connect("beat_started", Callable(self, "_on_beat_started"))

func _process(delta: float) -> void:
	_time_to_next_beat = maxf(0.0, _time_to_next_beat - delta)
	if _time_to_next_beat < _pre_beat_animation_time:
		if beat_frame == 0:
			animated_sprite.frame = 0
		else:
			var time_per_pre_frame: float = _pre_beat_animation_time / beat_frame
			animated_sprite.frame = floorf((_pre_beat_animation_time - _time_to_next_beat) / time_per_pre_frame)

	if not _post_beat_enabled:
		return
	
	_post_beat_time += delta
	var time_per_post_frame: float = _post_beat_animation_time / (animated_sprite.sprite_frames.get_frame_count(animation_name) - beat_frame)
	animated_sprite.frame = beat_frame + floorf(_post_beat_time / time_per_post_frame)
	if _post_beat_time > _post_beat_animation_time:
		_post_beat_enabled = false

func _on_beat_started(msg: Dictionary) -> void:
	_time_between_beats = 1.0 / (msg.bpm / 60.0)
	_time_to_next_beat = _time_between_beats
	_post_beat_time = 0.0
	_post_beat_enabled = true
	_pre_beat_animation_time = _time_between_beats / 4.0
	_post_beat_animation_time = _time_between_beats / 2.0
	
func _on_beat(msg: Dictionary) -> void:
	_time_to_next_beat = _time_between_beats
	animated_sprite.frame = beat_frame
	_post_beat_time = 0.0
	_post_beat_enabled = true
