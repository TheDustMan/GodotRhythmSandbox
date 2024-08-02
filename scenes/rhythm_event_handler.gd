extends Node


func _on_rhythm_pattern_player_next_rhythm_event(event: RhythmEvent):
	print("Received event[name=", event.name, ",index=", event.index, ",time_until=", event.time_until, "]")
