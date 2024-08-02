extends AnimatedSprite2D

@export var animation_rhythm_data: Array[RhythmAnimationData]

var _animation_lookup: Dictionary

func _ready() -> void:
	for data in animation_rhythm_data:
		_animation_lookup[data.animation_name] = data

func get_animation_rhythm_data(animation_name: String) -> RhythmAnimationData:
	if animation_name in _animation_lookup:
		return _animation_lookup[animation_name]

	return null
