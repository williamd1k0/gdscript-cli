#!/usr/bin/sh


echo "One line tests ->"
python gdscript.py oneline "print('Hello World from command-line!')"
python gdscript.py oneline "print(OS.get_engine_version())"
python gdscript.py oneline "print(OS.get_screen_size(0))"


echo "Block tests ->"
python gdscript.py block "
extends Node

func _ready():
    var list = []
    for i in range(1000):
        list.append(i)
    print(list)
"


echo "Script file tests ->"
python gdscript.py file 'test/Bhaskara.gd'
python gdscript.py file 'test/EvaluateData.gd'
python gdscript.py file 'test/Import.gd'
python gdscript.py file 'test/Extends.gd'
python gdscript.py file 'test/Enums.gd' # 2.1.3
