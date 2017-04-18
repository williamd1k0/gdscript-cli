extends Node

const Bhaskara = preload('Bhaskara.gd')

func _ready():
    print('Importing Bhaskara!')
    print(Bhaskara.bhaskara(2, -4, 0))
