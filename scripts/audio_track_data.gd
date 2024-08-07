extends Node
class_name AudioTrackData

# This will be broadcasted every time a new audio stream is started
# by the audio synchronizer

var track_name: String
var bpm: int

func _init(track_name: String, bpm: int):
	self.track_name = track_name
	self.bpm = bpm
