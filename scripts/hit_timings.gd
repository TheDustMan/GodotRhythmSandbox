extends Resource
class_name HitTimings

# The amount of time around an event that we consider a “perfect” hit. Essentially, a hit
# can be up to (threshold/2) amount of time early, or up to (threshold/2) amount of time
# late. This value can be viewed as a sort of time radius around events.
@export var perfect_radius_s: float

# The amount of time past the perfect threshold that an input will be
# considered "late"
@export var late_threshold_s: float

# The amount of time before the perfect threshold that an input will be
# considered "early"
@export var early_threshold_s: float

# The threshold layers can be visualized as follows:
#
#  |  Miss
#  |
# --- Early Start Time
#  |
#  |
#  |
# --- Early End / Perfect Start
#  |
#  |
# ------ <-- Event time
#  |
#  |
# --- Perfect End / Late Start
#  |
#  |
#  |
# --- Late End
#  |
#  |  Miss
