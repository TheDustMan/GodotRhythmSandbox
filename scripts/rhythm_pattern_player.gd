extends Node
class_name RhythmPatternPlayer

# Handles playing a pattern with the correct timings defined within
# the pattern.
# Can store multiple patterns that can be invoked by name.
#  - Initial version will only allow one pattern at a time
#
# How should event signals be sent out?
# - signals: every time a new event is on the horizon, send out a signal with info about when the event is scheduled to occur. Allows for multiple consumers per event.
# - callbacks: play() method is passed a callback that will be invoked. Limits to only one consumer per event.
#
# How should events be invoked?
# - One at a time
# - When the current event expires, need to immediately send out the next with the correct “time_util” value
# - How does this class track when an event passes?

# Broadcasts the time until the next event is scheduled to occur
signal next_rhythm_event(event: RhythmEvent)

# Broadcasts when a pattern is finished
# TODO add name of pattern?
signal pattern_complete()

# The available patterns to play, with a name assigned to each one
@export var	patterns: Array[RhythmPattern]

# Private variables

# Indicates which is the next event to broadcast when playing a pattern
var _pattern_index: int = 0

# The timer to use for waiting for each individual event in a pattern to
# expire
var _pattern_timer: Timer = null

# The number of times to repeat the pattern being played
var _pattern_repeats: int = 1

# The number of times the current pattern has been played
var _pattern_play_count: int = 0

# The name of the current pattern being played
var _pattern_name: String = ""

# The time between beats
var _time_between_beats: float = 0.0

# Allows for looking up available patterns in the pattern array by name
var _pattern_lookup: Dictionary = {}

# Tracks whether or not the pattern has started playing
var _pattern_started: bool = false

# A timestamp for when tracking for the upcoming event began.
# Set it to the current timestamp for each new upcoming event being processed.
var _time_began_event_tracking: float = 0.0

# A timestamp for when each of the upcoming events should occur.
# Set to current timestamp plus the time until the event should occur,
# for the current _pattern_index
var _time_event_should_occur: float = 0.0

# A timestamp tracking the progress towards the upcoming event.
# Set to current timestamp each time a new upcoming event is transmitted.
var _time_progress_updated_by_beat: float = 0.0

# Stores the amount of time that has passed since the last beat has occurred.
# This should be reset to zero every time a beat occurs, and updating with the
# time delta on every process call.
# Use this to see if we've reached the next event time between beats.
var _intermediate_processing_progress: float = 0.0

# Used to stall progress tracking of a new pattern so that the pattern can start exactly on
# the next upcoming beat
var _new_upcoming_pattern: bool = false

func _ready() -> void:
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	Events.connect("beat_started", Callable(self, "_on_beat_started"))

	for pattern in patterns:
		_pattern_lookup[pattern.get_pattern_name()] = pattern

	_time_between_beats = 0.0
	_pattern_name = ""
	_pattern_repeats = 0
	_pattern_play_count = 0
	_pattern_index = 0
	#_pattern_timer = Timer.new()
	#_pattern_timer.autostart = false
	#add_child(_pattern_timer)
	#_pattern_timer.connect("timeout", Callable(self, "_on_pattern_timer_timeout"))

func _process(delta: float) -> void:
	# If there's a new pattern being played, we want to stall until the next beat occurs
	if _new_upcoming_pattern or not _pattern_started:
		return

	# Track intermediate time progress between beats
	_intermediate_processing_progress += delta

	if _intermediate_processing_progress >= _time_between_beats:
		#print("over by=", _intermediate_processing_progress[_pattern_index] - _time_between_beats);
		return

	var progress := _time_progress_updated_by_beat + _intermediate_processing_progress

	if progress >= _time_event_should_occur:
		#print("_intermediate_processing_progress[",_pattern_index, "]=", _intermediate_processing_progress[_pattern_index])
		#print("progress=", progress, " _time_event_should_occur[", _pattern_index, "]=", _time_event_should_occur[_pattern_index])
		self._on_event_complete()

# Plays the patterns with the specified name
# name: The name of the pattern to play
# play_count: The number of times to play the animation,
#   use -1 to indicate loop
func play(name: String, repeats: int=1) -> void:
	if name not in _pattern_lookup:
		print("No pattern name [", name, "] in available patterns")
		return

	_new_upcoming_pattern = true
	_pattern_started = true
	_pattern_name = name
	_pattern_play_count = 0
	_pattern_repeats = repeats
	# 1. Calculate the time until the next event
	# 2. Emit a signal with the time util the next event
	# 3. Start an internal timer that will expire when the
	#    upcoming event time is reached
	# 4. When the timer expires, broacast the time until the next event
	# 5. Rinse and repeat
	self._prepare_next_event()


# Stops playing the specified animation
# If no animation name is specified, then stops all
func stop(name: String = "") -> void:
	_pattern_started = false
	_pattern_name = ""
	_pattern_play_count = 0
	_pattern_repeats = 0
	#_pattern_timer.stop()
	_pattern_index = 0
	pass

func _on_event_complete() -> void:
	# TODO
	# Increment pattern index so that next event is accessed
	_pattern_index += 1
	var proceed: bool = true
	if _pattern_index >= _pattern_lookup[_pattern_name].get_event_count():
		_pattern_play_count += 1
		# The entire pattern is finished, should we continue?
		if _pattern_repeats == -1 or _pattern_play_count < _pattern_repeats:
			_pattern_index = 0
			proceed = true
		else:
			# We're done
			_pattern_name = ""
			_pattern_index = 0
			_pattern_play_count = 0
			_pattern_repeats = 0
			proceed = false

	if not proceed:
		return

	self._prepare_next_event()

func _prepare_next_event() -> void:
	# Calculate time to next event
	# TODO: Right now this will be done entirely using timers,
	#   but we eventually need to integrate this with the beat
	#   to keep it more in sync with the music

	var leading_beats: float = 0.0
	if _pattern_index == 0:
		# The first event will have extra lead time defined
		# for the entire pattern
		leading_beats = _pattern_lookup[_pattern_name].get_leading_beats()

	var beats_until_event: float = _pattern_lookup[_pattern_name].get_event(_pattern_index)

	var leading_time: float = leading_beats * _time_between_beats
	var time_until_event: float = leading_time + (beats_until_event * _time_between_beats)
	#_pattern_timer.wait_time = leading_time + time_until_event
	#_pattern_timer.start()
	#print("emitting[", _pattern_index, "] time_until=", time_until_event)
	#print("emitting[", _pattern_index, "] pattern_name=", _pattern_name)
	#print("emitting[", _pattern_index, "] at time=", Time.get_unix_time_from_system())

	_time_began_event_tracking = Time.get_unix_time_from_system();
	#print("_time_began_event_tracking=", _time_began_event_tracking, ", time_until_event=", time_until_event)
	_time_event_should_occur = _time_began_event_tracking + time_until_event
	#print("slated to occur in the future=", _time_event_should_occur[_pattern_index])
	_time_progress_updated_by_beat = _time_began_event_tracking
	_intermediate_processing_progress = 0.0
	#print("set intermediate to 0 for index=", _pattern_index)

	next_rhythm_event.emit(RhythmEvent.new(_pattern_name, _pattern_index, time_until_event))

func _on_beat_started(msg: Dictionary) -> void:
	_time_between_beats = (1.0 / (msg.bpm / 60.0))

func _on_beat(msg: Dictionary) -> void:
	if _new_upcoming_pattern:
		_time_progress_updated_by_beat = Time.get_unix_time_from_system()
		_intermediate_processing_progress = 0.0
		_new_upcoming_pattern = false
	else:
		#print("beat")
		#print("_time_progress_updated_by_beat=", _time_progress_updated_by_beat, ", msg.time_since_last_beat=", msg.time_since_last_beat)
		_time_progress_updated_by_beat+= msg.time_since_last_beat
		#print("calculated time bw beats=", _time_between_beats, ", actual time=", msg.time_since_last_beat)
		_intermediate_processing_progress = 0.0

