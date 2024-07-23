extends Node2D

var _tween: Tween = null
var _timers: Array[Timer] = [null, null]
var _current_timer: int = 0
var _counter: int = 0
var _time_between_beats: float = 0.0
var _perfect_offset_ratio: float = 1.0 / 16.0
var _perfect_offset: float = 0.0
@onready var _initial_scale: Vector2 = self.scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("beat_started", Callable(self, "_on_beat_started"))
	Events.connect("beat_incremented", Callable(self, "_on_beat"))
	Events.connect("primary_action_pressed", Callable(self, "_on_action_pressed"))
	
	for i in range(_timers.size()):
		_timers[i] = Timer.new()
		_timers[i].name = "timer:" + str(i) 
		_timers[i].one_shot = true
		_timers[i].connect("timeout", Callable(self, "_on_timeout").bind(_timers[i]))
		add_child(_timers[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass

func _on_beat_started(msg: Dictionary):
	_time_between_beats = 1.0 / (msg.bpm / 60.0);
	_perfect_offset = _time_between_beats * _perfect_offset_ratio
	print("time between beats: ", _time_between_beats)

func _on_beat(msg: Dictionary):

	_tween = create_tween()
	var property_tween = _tween.tween_property(
		self,
		"scale",
		_initial_scale,
		_time_between_beats)
	property_tween.from(_initial_scale * 1.5)
	_tween.play()
	

	var timer: Timer = _get_current_timer()
	timer.wait_time = _time_between_beats + (_time_between_beats / 4.0)
	timer.start()
	_increment_timer_counter()

func _get_current_timer() -> Timer:
	return _timers[_counter]

func _increment_timer_counter() ->void:
	_counter += 1
	if _counter >= 2:
		_counter = 0

func _on_timeout(timer: Timer) -> void:
	pass

func _on_action_pressed() -> void:
	print("-------")
	for timer in _timers:
		var elapsed_time = timer.wait_time - timer.time_left
		if not timer.is_stopped() and elapsed_time > _time_between_beats / 2.0:
			var offset: float = absf(_time_between_beats - elapsed_time) - _perfect_offset
			if elapsed_time < _time_between_beats - _perfect_offset:
				$Label.text = "Early!"
				print("Early by ", offset)
			elif elapsed_time > _time_between_beats + _perfect_offset:
				print("Late by ", offset)
				$Label.text = "Late!"
			else:
				$Label.text = "Perfect!"
