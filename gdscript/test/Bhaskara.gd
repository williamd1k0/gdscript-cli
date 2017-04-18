extends Node

export(float) var a = 2
export(float) var b = -4
export(float) var c = 0

func _ready():
	print("Calculating Bhaskara!")
	print(calc_delta(a, b, c))
	print(bhaskara(a, b, c))

static func bhaskara(a, b, c):
	if calc_delta(a, b, c) < 0:
		return null
	return calc_bhaskara(a, b, c)

static func calc_delta(a, b, c):
	return b*b - 4*a*c

static func calc_bhaskara(a, b, c):
	var x1 = -b + sqrt(calc_delta(a, b, c))
	var x2 = -b - sqrt(calc_delta(a, b, c))
	return Vector2(x1, x2) / (2*a)
