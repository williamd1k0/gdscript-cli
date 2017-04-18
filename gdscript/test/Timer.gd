# -*- mode: wait -*-
extends Node

var timer = Timer.new()
var timer2 = Timer.new()

func _ready():
    print('Timer test')
    timer.set_wait_time(5)
    timer2.set_wait_time(3)
    add_child(timer)
    timer.start()
    yield(timer, 'timeout')
    timer.add_child(timer2)
    timer2.start()
    yield(timer2, 'timeout')
    print('Timer done')
    get_tree().quit()
