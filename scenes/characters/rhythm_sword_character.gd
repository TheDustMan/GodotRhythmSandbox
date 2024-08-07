extends Node2D

func _ready() -> void:
	Events.connect("beat_started", Callable(self, "_on_beat_started"))

func _on_beat_started(track_data: AudioTrackData) -> void:
	$RhythmPatternPlayer.play("one_beat", -1)
