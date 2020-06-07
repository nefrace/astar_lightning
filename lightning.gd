extends Node2D

export var points_w = 120
export var points_h = 60
export var points_gap = 10

var astar : AStar2D = AStar2D.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", self, "on_timeout") # Just callback
	
	for i in range(points_w): # Fill it with points
		for j in range(points_h):
			astar.add_point(i+j*points_w, Vector2(i*points_gap, j*points_gap), rand_range(1, 10)) 
	
	for i in range(points_w):  # Connect neighbors to each other
		for j in range(points_h):
			for ii in range(-1, 1):
				for jj in range(-1, 1):
					var di = i+ii
					var dj = j+jj
					var ida = i+j*points_w
					var idb = di+dj*points_w
					if !(ii == 0 and jj == 0):
						if di >= 0 and di < points_w and dj >= 0 and dj <= points_h:
							astar.connect_points(ida, idb, true) 


func on_timeout(): # When timer is out
	var a = Vector2(rand_range(0, points_w * points_gap), 0) # Random top point
	var b = Vector2(rand_range(0, points_w * points_gap), points_h * points_gap) # Random bottom point
	var l = lightning(a, b, 5, self) # Generate lightning
	
	$Tween.interpolate_property(l, "modulate", Color(1,1,1,1), Color(1,1,1,0),0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN) # Fade smooth
	$Tween.start()
	
	$Timer.wait_time = rand_range(.1, 1) 
	$Timer.start()

func lightning(start_point, end_point, width, parent):
	var start_id = astar.get_closest_point(start_point) # Getting indexes of points
	var end_id = astar.get_closest_point(end_point)
	var path = astar.get_point_path(start_id, end_id) # Calculate path
	var line : Line2D = Line2D.new() # Visual line class
	line.width = width
	line.points = path
	parent.add_child(line)
	if width > 1: # if line is thick, we can generate some branches
		var branches = randi()%3+1
		for i in range(branches):
			var point_id = randi()%(path.size()-1) # Getting random index in path array
			var begin = path[point_id]
			var dir = (path[point_id+1]-begin).normalized() # direction vector of lightning in 'begin' point
			var end = begin + ((dir*width*50)).rotated(rand_range(-PI/3, PI/3)) # some point in distance from 'begin'
			lightning(begin, end, width-1, line)	# Recursively generate a new lightning and it as children to current.
													# On each new iteration new branches will be added as childs to the old ones
	return line
