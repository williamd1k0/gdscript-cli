#!/usr/bin/sh


echo "Assertion tests ->"
python gdscript.py oneline "assert(false)"
python gdscript.py block "
extends Node

func _ready():
    assert(false)
"
python gdscript.py file 'test/errors/Assertion.gd'


echo "Identifier Not Found tests ->"
python gdscript.py oneline "print(i)"
python gdscript.py block "
extends Node

func _ready():
    print(i)
"
python gdscript.py file 'test/errors/Identifier.gd'
