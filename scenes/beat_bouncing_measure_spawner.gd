extends Node2D

@export var _moving_beat_scene: PackedScene
var _beat_markers: Array[Node]
var _beat_paths: Array[Node]
var _moving_beat: MovingBeat
var _beat_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	_beat_markers = $BeatMarkers.get_children()
	_beat_paths = $BeatPaths.get_children()
	_moving_beat = _moving_beat_scene.instantiate()
	_moving_beat.position = _beat_markers[0].position
	#$Beats.add_child(_moving_beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_beat(msg):
	if _beat_counter >= _beat_markers.size() - 1:
		_beat_counter = 0
		return
	
	_moving_beat.position = _beat_markers[_beat_counter].position
	
	# Create a new Polygon2D node
	#var polygon = Polygon2D.new()
	#polygon.polygon = Array([Vector2(-25, -25), Vector2(25, -25), Vector2(25, 25), Vector2(-25, 25)])  # A square
	#polygon.color = Color(0, 1, 0)  # Green color
	var follow = _beat_paths[_beat_counter].get_node("PathFollow2D")
	follow.add_child(_moving_beat)
	
	var time_between_beats = 1.0 / (msg.bpm / 60.0);
	var tween = create_tween()
	var property_tween = tween.tween_property(
		follow,
		"progress_ratio",
		1,
		time_between_beats)
	property_tween.from(0)
	property_tween.set_ease(Tween.EASE_OUT_IN)
	tween.play()
	_beat_counter += 1
	
