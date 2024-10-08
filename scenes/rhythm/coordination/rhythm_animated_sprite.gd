extends Node
class_name RhythmAnimatedSprite

# A wrapper around an AnimatedSprite2D that let's you specify various
# timing aspects of how each animation should behave when played to
# the rhythm (defined within RhythmAnimationData)

@export var animated_sprite: AnimatedSprite2D
@export var rhythm_animation_data: Array[RhythmAnimationData]

var _animation_lookup: Dictionary

func _ready() -> void:
	for data in rhythm_animation_data:
		_animation_lookup[data.animation_name] = data

func get_rhythm_animation_data(animation_name: String) -> RhythmAnimationData:
	if animation_name in _animation_lookup:
		return _animation_lookup[animation_name]

	return null

func get_sprite() -> AnimatedSprite2D:
	return animated_sprite
