extends 'BaseClass.gd'

func test():
    .test()
    print(get_script().get_base_script().resource_path)

func _ready():
    test()
