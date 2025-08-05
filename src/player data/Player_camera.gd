extends Camera2D

var min_zoom = Vector2(.9, .9)
var zoom_speed = Vector2(.1 , .1)




func zoom_in():
	offset = Vector2(5, 5)
	if zoom > min_zoom:
		zoom -= zoom_speed

func zoom_out():
	offset = Vector2(0 , 0)
	zoom = Vector2(1 , 1)
