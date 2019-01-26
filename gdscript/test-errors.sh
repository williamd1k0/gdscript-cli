#!/usr/bin/sh

echo "Assertion tests ->"
python gdscript.py oneline "assert(false)"
python gdscript.py block "
extends Node

func _ready():
    assert(false)
"
python gdscript.py file 'test/errors/Assertion.gd'

echo ""
echo "Identifier Not Found tests ->"
python gdscript.py oneline "print(i)"
python gdscript.py block "
extends Node

func _ready():
    print(i)
"
python gdscript.py file 'test/errors/Identifier.gd'

echo ""
echo "Type tests ->"
python gdscript.py oneline "print('1'+1)"
python gdscript.py block "
extends Label

func _ready():
    text = 1
"

echo ""
echo "Memory leak tests ->"
python gdscript.py oneline "Node.new()"
python gdscript.py block "
extends Node

func _ready():
    var leak = Node.new()
"