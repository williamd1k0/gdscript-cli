# GDScript CLI

GDScript CLI wrapper

![python](https://img.shields.io/badge/python-3.4%2B-blue.svg?style=flat-square)
![godot](https://img.shields.io/badge/Godot-3.0%2B-blue.svg?style=flat-square)
![license](https://img.shields.io/badge/License-Meteor-lightgray.svg?style=flat-square)
[![Donations](https://img.shields.io/badge/Donations-USD%2FBRL%2FBTC%2FBCH-%238571aa?style=flat-square)](https://tumeo.space/donations/)

# About

This project is a command-line wrapper for GDScript.

GDScript is the language used in Godot Game Engine (more info about Godot [here](https://godotengine.org/)).

# Why

Some of the Godot Engine users know that the editor has a cli command to execute scripts outside the project (`godot -s script.gd`). So, what is the purpose of this project?

Actually the built-in command doesn't execute any kind of script because the script must inherits from `SceneTree` or `MainLoop`.

This limitation makes it very difficult to run simple scripts and other kind of scripts that need to inherit from another class.

So, this project is a tool to execute simple and complex scripts, direct from cli (one line or small block scripts) or from script files.

# Project Structure

This tool is implemented using built-in script command (`godot -s`). I have some points to reuse the built-in command instead of writing a GDScript parser:

1. I started this project using my spare time, so I'll take too long implementing a parser from scratch.

2. I'm not the best C++ developer (I'm the worst actually), so I'll take too long trying to reuse gdscript C++ module.

3. Since I don't have much time, my focus is on rapid implementation, not better (this doesn't mean the code is poorly written).

4. The built-in command works fine for now :)

# Main Goals

The main goal is run GDScript through a web server. It will ease snippet tests, especially for new users.

The other goal is run GDScript easily from cli, no need to create a new project just to test a simple script (GDScript as general-purpose language intensifies).

# Development

>TODO
