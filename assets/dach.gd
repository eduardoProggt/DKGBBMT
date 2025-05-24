extends Node3D
class_name Dach

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn():
	pass	

func display(result):
	pass

func finish_spawning():
	pass

func spawn_gost(node: Connector):
	var relevant_positions_horizontal = [
		node.get_center() + Vector3(12,0,5),
		node.get_center() + Vector3(12,0,-5),
		node.get_center() + Vector3(-12,0,5),
		node.get_center() + Vector3(-12,0,-5),
		]
	var relevant_positions_vertical = [		
		node.get_center() + Vector3(5,0,12),
		node.get_center() + Vector3(5,0,-12),
		node.get_center() + Vector3(-5,0,12),
		node.get_center() + Vector3(-5,0,-12),
		]
	
	var collisionBox : CollisionShape3D = find_child("CollisionShape3D")
	for pos in relevant_positions_horizontal:
		var newCollisionBox : CollisionShape3D = collisionBox.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		var body = StaticBody3D.new()
		var shape :BoxShape3D = newCollisionBox.shape
		var middle = (pos + node.get_center()) / 2
		
		body.global_transform.origin =  (pos + node.get_center() - shape.size) / 2 + Vector3(0,0.6,6) #Der Vector resultiert daraus, dass die Shape 13,0,6 ist aber 13,0,-6 die Position, daher die Halfte *2 = -6 abziehen
		body.add_child(newCollisionBox)
		get_tree().current_scene.add_child(body)
		Utils.spawn_debug_sphere(get_tree(),pos)
	for pos in relevant_positions_vertical:
		var newCollisionBox : CollisionShape3D = collisionBox.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		newCollisionBox.rotate(Vector3(0,1,0), PI/2)
		var body = StaticBody3D.new()
		var shape :BoxShape3D = newCollisionBox.shape
		var middle = (pos + node.get_center()) / 2
		
		body.global_transform.origin =  (pos + node.get_center() - shape.size) / 2 + Vector3(0,0.6,6) #Der Vector resultiert daraus, dass die Shape 13,0,6 ist aber 13,0,-6 die Position, daher die Halfte *2 = -6 abziehen
		body.add_child(newCollisionBox)
		get_tree().current_scene.add_child(body)
		Utils.spawn_debug_sphere(get_tree(),pos)
