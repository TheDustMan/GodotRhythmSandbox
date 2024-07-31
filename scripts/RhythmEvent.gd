extends Object
class_name RhythmEvent

var name: String
var index: int
var time_until: float

func _init(name: String, index: int, time_until: float) -> void:
	self.name = name
	self.index = index
	self.time_until = time_until
