extends Node
class_name HitDetector

# Signals

signal perfect_hit
signal early_hit
signal late_hit
signal miss_hit

# Exports

# The amount of time around an event that we consider a “perfect” hit. Essentially, a hit
# can be up to (threshold/2) amount of time early, or up to (threshold/2) amount of time
# late. This value can be viewed as a sort of time radius around events.
@export var perfect_time_threshold_s: float

 #The amount of time before the perfect_threshold time begins that hits will be
 #considered “early”.
@export var  early_time_threshold_s: float

 # The amount of time after the perfect_threshold time ends that hits will be
 # considered “late”.
@export var  late_time_threshold_s: float

# The threshold layers can be visualized as follows:
#
#  |  Miss
#  |
# --- Early Start Time
#  |
#  |
#  |
# --- Early End / Perfect Start
#  |
#  |
# ------ <-- Event time
#  |
#  |
# --- Perfect End / Late Start
#  |
#  |
#  |
# --- Late End
#  |
#  |  Miss


# Private

# Stores timestamps of all upcoming events
var _upcoming_events: Array[float] = []

func _ready() -> void:
	pass

# Does processing to track a timestamp used for detecting hit accuracy in
# _on_player_action
func _process(delta: float) -> void:
	var current_time := Time.get_unix_time_from_system();
	var remove_events: Array[int] = []
	for i in range(_upcoming_events.size()):
		var event_time := _upcoming_events[i]
		if current_time > event_time + (perfect_time_threshold_s / 2.0) + late_time_threshold_s:
			emit_signal("miss_hit")
			remove_events.push_back(i)
	for idx in remove_events:
		_upcoming_events.remove_at(idx)


# Need to track when the beat occurs because most likely this class will need to
# implement its own time-tracking mechanism so that the hit timings can be
# synchronized with the actual beat
func on_beat(msg: Dictionary) -> void:
	pass

# Handler for receiving the next event
func on_next_rhythm_event(event: RhythmEvent) -> void:
	_upcoming_events.push_back(Time.get_unix_time_from_system() + event.time_until)


# Handler for the player’s action (e.g. some controller input).
# utilizes the current time-tracker to determine the hit accuracy.
# Will broadcast signals depending on accuracy (miss, early, perfect, late)
func on_player_action() -> void:
	if _upcoming_events.size() == 0:
		emit_signal("miss_hit")
		return

	var current_time := Time.get_unix_time_from_system();
	var remove_events: Array[int] = []
	for i in range(1):#range(_upcoming_events.size()):
		var remove: bool = true
		var event_time := _upcoming_events[i]
		var perfect_threshold_s = perfect_time_threshold_s / 2.0
		var early_threshold_s = event_time - perfect_threshold_s - early_time_threshold_s
		var late_threshold_s = event_time + perfect_threshold_s + late_time_threshold_s
		var distance := current_time - event_time;
		if absf(distance) <= perfect_threshold_s:
			emit_signal("perfect_hit")
		elif current_time > event_time + perfect_threshold_s and \
			 current_time <= event_time + perfect_threshold_s + late_time_threshold_s:
			emit_signal("late_hit")
		elif current_time > event_time + perfect_threshold_s + late_time_threshold_s:
			emit_signal("miss_hit")
		elif current_time < event_time - perfect_threshold_s and \
			 current_time >= event_time - perfect_threshold_s - early_time_threshold_s:
			emit_signal("early_hit")
		elif current_time < event_time - perfect_threshold_s - early_time_threshold_s:
			emit_signal("miss_hit")
		else:
			remove = false
		if remove:
			remove_events.push_back(i)
	for idx in remove_events:
		_upcoming_events.remove_at(idx)
