extends Node

enum {
    OPTION1=1<<0,
    OPTION2=1<<1,
    OPTION3=1<<2
}

var flags = 0

func _ready():
    print('Testing enums and bitwise')
    print(flags)
    print(flags ^OPTION1)
    flags ^= OPTION2
    print(flags)
    print(flags & OPTION3)
