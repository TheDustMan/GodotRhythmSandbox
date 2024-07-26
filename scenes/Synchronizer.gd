extends Node

enum SyncSource {
	SYSTEM_CLOCK,
	SOUND_CLOCK,
}

var bpm: int
const BARS = 4

const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0

var playing := false
var sync_source := SyncSource.SYSTEM_CLOCK

# Used by system clock.
var time_begin: float
var time_delay: float

var last_beat: int = 0
var last_beat_time: float = 0

@onready var _stream := $AudioStreamPlayer

func start() -> void:
	_reset()
	var msg := {
		"stream" : "res://assets/sounds/the_comeback2.ogg",
		"bpm" : 116
	}
	_load_track(msg)
	Events.emit_signal("beat_started", msg)
	
func stop() -> void:
	_reset()
	playing = false
	_stream.stop()
	Events.emit_signal("beat_stopped", {})

func _ready() -> void:
	#Events.connect("track_selected", self, "_load_track")
	pass


func play_audio() -> void:
	var time_delay := AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	await get_tree().create_timer(time_delay)
	playing = true
	_stream.play()


func _process(_delta: float) -> void:
	if not playing or not _stream.playing:
		return

	var time := 0.0
	time = _stream.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES
	
	var beat := int(time * bpm / 60.0)
	if beat != last_beat:
		Events.emit_signal("beat_incremented", {"bpm" : bpm})
	last_beat = beat
	last_beat_time = time

func _load_track(msg: Dictionary) -> void:
	_stream.stream = load(msg.stream)
	bpm = msg.bpm
	play_audio()
	
func _reset() -> void:
	last_beat = 0
	last_beat_time = 0
