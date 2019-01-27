#!/usr/bin/sh

echo "Assertion tests ->"
python gdscript.py -o "assert(false)"
python gdscript.py "
extends Node

func _ready():
    assert(false)
"
python gdscript.py 'test/errors/Assertion.gd'

echo ""
echo "Identifier Not Found tests ->"
python gdscript.py "print(i)"
python gdscript.py "
extends Node

func _ready():
    print(i)
"
python gdscript.py 'test/errors/Identifier.gd'

echo ""
echo "Type tests ->"
python gdscript.py "print('1'+1)"
python gdscript.py "
extends Label

func _ready():
    text = 1
"

echo ""
echo "Memory leak tests ->"
python gdscript.py "Node.new()"
python gdscript.py "
extends Node

func _ready():
    var leak = Node.new()
"