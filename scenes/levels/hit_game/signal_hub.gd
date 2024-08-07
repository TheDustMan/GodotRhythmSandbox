extends Node

@export var synchronizer: Synchronizer
@export var print_hit_handler: PrintHitHandler
@export var hit_detector: HitDetector
@export var rhythm_pattern_player: RhythmPatternPlayer
@export var rhythm_animation_coordinator: RhythmAnimationCoordinator

# Hit Detection

func _on_hit_detector_early_hit() -> void:
	print_hit_handler.on_early_hit()


func _on_hit_detector_late_hit() -> void:
	print_hit_handler.on_late_hit()


func _on_hit_detector_miss_hit() -> void:
	print_hit_handler.on_miss_hit()


func _on_hit_detector_perfect_hit() -> void:
	print_hit_handler.on_perfect_hit()


# Input Handling

func _on_input_handler_primary_action() -> void:
	hit_detector.on_player_action()


func _on_input_handler_start_pressed() -> void:
	synchronizer.stop()
	synchronizer.start("beat")
	# TODO Pattern-player must be started after synchronizer to receive
	# initialization data. Try to make this not required.
	rhythm_pattern_player.play("4onbeat", -1)


func _on_input_handler_quit_pressed() -> void:
	synchronizer.stop()


# Rhythm Pattern Player

func _on_rhythm_pattern_player_next_rhythm_event(event: RhythmEvent) -> void:
	rhythm_animation_coordinator.on_next_rhythm_event(event)
	hit_detector.on_next_rhythm_event(event)
