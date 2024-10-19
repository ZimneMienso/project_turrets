extends Resource
class_name SpawnPool

## Id of the unit type
@export var type_id: String
## The number of units to spawn trougout the level
@export var unit_count: int
## The distribution of units troughout the waves
@export var curve: Curve
# that's for callables to define spawn patterns
#@export_enum() var test: String
## Time the spawner should be inactive after spawning this unit
@export var spawn_cooldown: float
