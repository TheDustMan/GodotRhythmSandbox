extends Node

signal beat_incremented(msg: Dictionary)
signal beat_started(msg: Dictionary)
signal beat_stopped(msg: Dictionary)

signal beat_early(msg: Dictionary)
signal beat_late(msg: Dictionary)
signal beat_perfect(msg: Dictionary)
signal beat_miss_early(msg: Dictionary)
signal beat_miss_late(msg: Dictionary)
