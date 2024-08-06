extends Resource
class_name RhythmAnimationData

# Metadata used when creating a RhythmAnimatedSprite to specify
# various timing aspects of the animation when payed to a rhythm

# The name of the animation this data is associated with
@export var animation_name: String = ""

# The frame of the animation that should occur exactly on the beat
@export var beat_frame: int = 0

# The number of beats before the beat_frame to begin playing the animation
@export var pre_beats: float = 0.0

# The number of beats after the beat_frame to finishing playing remainder
# of the animation
@export var post_beats: float = 0.0

# Whether to only play the beat_frame (ignores any specified pre-/post-beat times
@export var beat_frame_only: bool = false
