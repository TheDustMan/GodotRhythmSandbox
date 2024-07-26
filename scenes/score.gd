extends Node2D

var _score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func increment(by: int) -> void:
	_score += by;
	$ScoreValue.text = str(_score)

func reset() -> void:
	_score = 0
	$ScoreValue.text = str(_score)
