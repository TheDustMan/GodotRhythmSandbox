extends Node
class_name AnimationPattern

# A name that this pattern can be referenced by
@export var pattern_name: String

# Array of strings representing the order in which animations
# should be played
@export var animations: Array[String]

# Returns the series of animation string names that make
# up this pattern
func get_animations() -> Array[String]:
	return animations

# Note: Will raise IndexError exception if index is out of bounds
func get_animation_name(index: int) -> String:
	return animations[index]

# The number of animations in this pattern
func get_animation_count() -> int:
	return animations.size()

# Returns the name by which this pattern is identified
func get_pattern_name() -> String:
	return pattern_name
