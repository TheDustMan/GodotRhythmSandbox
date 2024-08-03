extends Node
class_name RhythmPattern

# How is this used?
# Someone defines a pattern, then another component must access the
# timings within to coordinate actions according to the timings in the
# pattern

# Exports

# A name that this pattern can be referenced by
@export var pattern_name: String

# Number of beats before the pattern starts.
# If looping, this will be the number of beats before the next
# instance of the pattern begins
@export var leading_beats: float

# Array of floats representing the number of beats between actions
# once the pattern begins
@export var event_times: Array[float]

# Public Methods

# Returns the series of timings for this pattern
func get_events_times() -> Array[float]:
	return event_times

# Note: Will raise IndexError exception if index is out of bounds
func get_event(index: int) -> float:
	return event_times[index]

# The number of events
func get_event_count() -> int:
	return event_times.size()

# Returns the name by which this pattern is identified
func get_pattern_name() -> String:
	return pattern_name

func get_leading_beats() -> float:
	return leading_beats
