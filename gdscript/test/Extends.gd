extends 'EvaluateData.gd'


func execute():
    print('Testing file extends')
    var o = ObjectTemplate.new()
    for i in data.values():
        if o.evaluate(i.reqs[0], i.reqs[1], i.reqs[2]):
            print(i.action, ' success')
        else:
            print(i.action, ' failure')

func _ready():
    execute()