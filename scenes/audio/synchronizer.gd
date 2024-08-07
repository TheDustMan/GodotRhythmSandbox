extends Node
class_name Synchronizer

@export var tracks: Array[AudioTrack]

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

var _track_lookup: Dictionary

@onready var _player := $AudioStreamPlayer

func start(track_name: String) -> void:
	if track_name not in _track_lookup:
		print("[Synchronizer] No track named ", track_name, " found")
		return

	_reset()
	var track_data := AudioTrackData.new(track_name, _track_lookup[track_name].bpm)
	_load_track(track_name)
	Events.emit_signal("beat_started", track_data)

func stop() -> void:
	_reset()
	playing = false
	_player.stop()
	Events.emit_signal("beat_stopped", {})

func _ready() -> void:
	#Events.connect("track_selected", self, "_load_track")
	for track in tracks:
		print("[Synchronizer] Detected track ", track.track_name)
		_track_lookup[track.track_name] = track


func play_audio() -> void:
	var time_delay := AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	await get_tree().create_timer(time_delay)
	playing = true
	_player.play()


func _process(_delta: float) -> void:
	if not playing or not _player.playing:
		return

	var time := 0.0
	time = _player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES

	var beat := int(time * bpm / 60.0)
	if beat != last_beat:
		Events.emit_signal("beat_incremented", {"bpm" : bpm, "time_since_last_beat" : Time.get_unix_time_from_system() - last_beat_time})
		last_beat = beat
		last_beat_time = Time.get_unix_time_from_system()

func _load_track(track_name: String) -> void:
	_player.stream = load(_track_lookup[track_name].path)
	bpm = _track_lookup[track_name].bpm
	play_audio()

func _reset() -> void:
	last_beat = 0
	last_beat_time = 0
