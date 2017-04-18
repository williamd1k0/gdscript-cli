# GD Script CLI

GD Script CLI implementation

![status](https://img.shields.io/badge/status-200%25_unstable-red.svg?style=flat-square)
![python](https://img.shields.io/badge/python-3.4%2B-blue.svg?style=flat-square)
![license](https://img.shields.io/github/license/williamd1k0/gdscript-cli.svg?style=flat-square)

# About

This project is a cli implementation of the GD Script.

GD Script is the language used in Godot Game Engine (more info about Godot [here](https://godotengine.org/)).

# Why

Some of the Godot Engine users know that the editor has a cli command to execute scripts outside the project (`godot -s script.gd`). So, what is the purpose of this project?

Actually the built-in command don't executes any kind of script because the script must inherits from `SceneTree` or `MainLoop`.

This limitation makes it very difficult to run simple scripts and other kind of scripts that need to inherit from another class.

So, this project is a tool to execute simple and complex scripts, direct from cli (one line or small block scripts) or from script files.

