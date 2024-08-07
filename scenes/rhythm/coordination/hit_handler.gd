extends Node
class_name PrintHitHandler

func on_perfect_hit() -> void:
	print("PERFECT")


func on_miss_hit() -> void:
	print("MISS")


func on_late_hit() -> void:
	print("LATE")


func on_early_hit() -> void:
	print("EARLY")

