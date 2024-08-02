extends Node

# Description
# This class coordinates playing animations of a sprite at a
# specific time as denoted by reception of RhythmEvents, which
# contain information about when in the future the event will occur

# Exports

# The rhythm-animated sprite containing the animations to use
@export var rhythm_animated_sprite: RhythmAnimatedSprite

# A list of strings representing the order of the animations
# to play during each event
@export var animation_pattern: AnimationPattern

# Private Data

# The current index of the animation pattern
var _animation_index: int

var _time_between_beats: float = 0.0
var _post_beat_enabled: bool = false
var _post_beat_animation_time: float = 0.0
var _pre_beat_animation_time: float = 0.0
var _post_beat_time: float = 0.0
var _time_to_next_beat: float = 0.0
var _timer: Timer

var _timed_animations: Array[TimedRhythmAnimation]

func _ready() -> void:
	Events.connect("beat_started", Callable(self, "_on_beat_started"))
	_animation_index = 0

func _process(delta: float) -> void:
	var to_remove: Array[int] = []
	for i in range(_timed_animations.size()):
		if _timed_animations[i].expired():
			to_remove.push_back(i)
		else:
			_timed_animations[i].update(delta)
	for i in to_remove:
		_timed_animations.remove_at(i)


func _on_rhythm_pattern_player_next_rhythm_event(event: RhythmEvent) ->void:
	if _animation_index >= animation_pattern.get_animation_count():
		_animation_index = 0
	#print("next animation=", animation_pattern.get_animation_name(_animation_index), ", time_until=", event.time_until)
	var _timed_animation := TimedRhythmAnimation.new(
			rhythm_animated_sprite,
			animation_pattern.get_animation_name(_animation_index),
			event.time_until,
			_time_between_beats)
	_timed_animations.push_back(_timed_animation)
	_animation_index += 1


func _on_beat_started(msg: Dictionary) -> void:
	_time_between_beats = 1.0 / (msg.bpm / 60.0)


func reset() -> void:
	_animation_index = 0
