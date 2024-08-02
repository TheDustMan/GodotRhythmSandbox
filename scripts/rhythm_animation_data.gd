extends Resource
class_name RhythmAnimationData

# The name of the animation this data is associated with
@export var animation_name: String = ""

# The frame of the animation that should occur exactlyon the beat
@export var beat_frame: int = 0

# The number of beats before the beat_frame to begin playing the animation
@export var pre_beats: float = 0.0

# The number of beats after the beat_frame to finishing playing remainder
# of the animation
@export var post_beats: float = 0.0
