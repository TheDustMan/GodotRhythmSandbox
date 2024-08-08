extends Object
class_name RhythmEvent

# Data broadcasted about each event when a rhythm pattern is being played

var name: String
var index: int
var time_until: float
var time_of_event: float

func _init(name: String, index: int, time_until: float) -> void:
	self.name = name
	self.index = index
	self.time_until = time_until
	self.time_of_event = Time.get_unix_time_from_system() + time_until
