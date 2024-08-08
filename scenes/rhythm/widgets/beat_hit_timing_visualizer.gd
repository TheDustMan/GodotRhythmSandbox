extends Node2D
class_name BeatHitTimingVisualizer

# Exports

@export var hit_timings: HitTimings

# Used for scaling the dimensions of the visualization according to
# prescribed timings
@export var pixels_per_second: float

# The scene to use for creating time markers
@export var time_marker_scene: PackedScene

# Private

var _upcoming_events: Array[RhythmEvent] = []

# Maps event index to a TimeMarker representing the marker
var _time_markers: Dictionary = {}

var _time_marker_ghosts: Array[TimeMarker] = []


# Framework

func _ready() -> void:

	# Adjust timing box sizes
	var early_start_boundary := (hit_timings.perfect_radius_s / 2.0) + hit_timings.early_threshold_s
	var early_end_boundary := (hit_timings.perfect_radius_s / 2.0)
	var late_start_boundary := (hit_timings.perfect_radius_s / 2.0)
	var late_end_boundary := (hit_timings.perfect_radius_s / 2.0) + hit_timings.late_threshold_s
	var perfect_start_boundary := early_end_boundary
	var perfect_end_boundary := late_start_boundary

	var early_start_pos: float = $CenterMarker.position.y - (early_start_boundary * pixels_per_second)
	var early_end_pos: float = $CenterMarker.position.y - (early_end_boundary * pixels_per_second)
	var perfect_start_pos: float = early_end_pos
	var perfect_end_pos: float = $CenterMarker.position.y + (late_start_boundary * pixels_per_second)
	var late_start_pos: float = perfect_end_pos
	var late_end_pos: float = $CenterMarker.position.y + (late_end_boundary * pixels_per_second)
	print("early_start=", early_start_pos)
	print("early_end=", early_end_pos)
	print("perfect_start=", perfect_start_pos)
	print("perfect_end=", perfect_end_pos)
	print("late_start=", late_start_pos)
	print("late_end=", late_end_pos)

	var early_half_height := (early_end_pos - early_start_pos) / 2.0
	var perfect_half_height := (perfect_end_pos - perfect_start_pos) / 2.0
	var late_half_height := (late_end_pos - late_start_pos) / 2.0

	# Early's shape position
	$Early.position.y = -1 * (perfect_half_height + early_half_height)

	# Early's end boundary
	$Early.polygon[0].y = early_half_height
	$Early.polygon[1].y = early_half_height

	# Early's start boundary
	$Early.polygon[2].y = -early_half_height
	$Early.polygon[3].y = -early_half_height

	# Perfect's shape position
	$Perfect.position = $CenterMarker.position

	# Perfect's end boundary
	$Perfect.polygon[0].y = perfect_half_height
	$Perfect.polygon[1].y = perfect_half_height

	# Perfect's start boundary
	$Perfect.polygon[2].y = -perfect_half_height
	$Perfect.polygon[3].y = -perfect_half_height

	# Late's shape position
	$Late.position.y = perfect_half_height + late_half_height

	# Late's end boundary
	$Late.polygon[0].y = late_half_height
	$Late.polygon[1].y = late_half_height

	# Late's start boundary
	$Late.polygon[2].y = -late_half_height
	$Late.polygon[3].y = -late_half_height

	print("early position=", $Early.position)
	print("perfect position=", $Perfect.position)
	print("late position=", $Late.position)
	print("early vertices:")
	#for v in $Early.polygon:
		#print("  ", v)
	#print("perfect vertices:")
	#for v in $Perfect.polygon:
		#print("  ", v)
	#print("late vertices:")
	#for v in $Late.polygon:
		#print("  ", v)


func _process(delta: float) -> void:

	var center_y_pos: float = $CenterMarker.position.y
	var current_time := Time.get_unix_time_from_system()
	var remove_idx: Array[int] = []
	for i in range(_upcoming_events.size()):
		var time_until_event := _upcoming_events[i].time_of_event - current_time
		var distance_from_center := pixels_per_second * time_until_event

		# Move the marker to its new position
		_time_markers[_upcoming_events[i]].position.y = center_y_pos - distance_from_center

		var late_boundary_time := _upcoming_events[i].time_of_event + (hit_timings.perfect_radius_s / 2.0) + hit_timings.late_threshold_s
		if current_time > late_boundary_time:
			remove_idx.push_back(i)
			#self.on_hit()
			pass
	for i in remove_idx:
		remove_child(_time_markers[_upcoming_events[i]])
		_time_markers.erase(_upcoming_events[i])
		_upcoming_events.remove_at(i)

# Public

# Invoked when user-input is received.
func on_hit() -> void:
	if _time_markers.size() == 0:
		return

	for marker in _time_marker_ghosts:
		remove_child(marker)

	# Place the ghost at the position of the most recent event time marker
	var event_marker := time_marker_scene.instantiate()
	event_marker.position = _time_markers[_upcoming_events[0]].position
	event_marker.color = Color(0.5, 0.5, 0.5, 1)
	add_child(event_marker)

	_time_marker_ghosts.push_back(event_marker)

	# Now remove the most recent timer marker and event since they
	# no longer need to be tracked
	remove_child(_time_markers[_upcoming_events[0]])
	_time_markers.erase(_upcoming_events[0])
	_upcoming_events.remove_at(0)

# Passed information about the next rhythm event
# (time until)
func on_next_event(event: RhythmEvent) -> void:

	_upcoming_events.push_back(event)

	# Calculate the starting position based on the amount of time
	# until the event and the pixels_per_second value
	var center_y_pos: float = $CenterMarker.position.y
	var time_marker_pixel_distance = pixels_per_second * event.time_until

	var event_marker := time_marker_scene.instantiate()
	event_marker.position = Vector2(0, center_y_pos - time_marker_pixel_distance)
	event_marker.color = Color(0, 0, 0, 1)
	add_child(event_marker)
	# Associate this marker with the most recent event
	_time_markers[event] = event_marker



