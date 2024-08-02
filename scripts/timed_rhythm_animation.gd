extends Node
class_name TimedRhythmAnimation

var _sprite: RhythmAnimatedSprite = null
var _animation_name: String = ""
var _time_until: float = 0.0

var _post_beat_enabled: bool = false
var _post_beat_animation_time: float = 0.0
var _pre_beat_animation_time: float = 0.0
var _post_beat_time: float = 0.0
var _expired: bool = false

func _init(
		sprite: RhythmAnimatedSprite,
		animation_name: String,
		time_until: float,
		time_per_beat: float) -> void:
	self._sprite = sprite
	self._animation_name = animation_name
	self._time_until = time_until

	_pre_beat_animation_time = time_per_beat * sprite.get_rhythm_animation_data(animation_name).pre_beats
	_post_beat_animation_time = time_per_beat * sprite.get_rhythm_animation_data(animation_name).post_beats

func update(delta: float) -> void:
	if _expired:
		return

	var beat_frame: int = _sprite.get_rhythm_animation_data(_animation_name).beat_frame
	var animated_sprite: AnimatedSprite2D = _sprite.get_sprite()

	_time_until = _time_until - delta
	if _time_until < _pre_beat_animation_time and _time_until > 0.0:
		animated_sprite.animation = _animation_name
		if beat_frame == 0:
			animated_sprite.frame = 0
		else:
			var time_per_pre_frame: float = _pre_beat_animation_time / beat_frame
			animated_sprite.frame = floorf((_pre_beat_animation_time - _time_until) / time_per_pre_frame)

	if not _post_beat_enabled:
		if _time_until <= 0.0:
			animated_sprite.frame = beat_frame
			_post_beat_time = 0.0
			_post_beat_enabled = true
		return

	_post_beat_time += delta
	var time_per_post_frame: float = _post_beat_animation_time / (animated_sprite.sprite_frames.get_frame_count(_animation_name) - beat_frame)
	animated_sprite.frame = beat_frame + floorf(_post_beat_time / time_per_post_frame)
	if _post_beat_time > _post_beat_animation_time:
		_post_beat_enabled = false
		_expired = true

func cancel() -> void:
	_expired = true

func expired() -> bool:
	return _expired
