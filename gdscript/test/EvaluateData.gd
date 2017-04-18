extends Node

var data = {
    'action1': {
        'reqs': ['stat1', '>=', 1],
        'action': 'foo'
    },
    'action2': {
        'reqs': ['stat2', '<', 3],
        'action': 'bar'
    }
}

class Evaluate:

    func evaluate(property, condition, value):
        print(get(property), ' ', condition, ' ', value)
        if condition == '==':
            return get(property) == value
        elif condition == '!=':
            return get(property) != value
        elif condition == '>':
            return get(property) > value
        elif condition == '>=':
            return get(property) >= value
        elif condition == '<':
            return get(property) < value
        elif condition == '<=':
            return get(property) <= value

class ObjectTemplate:
    extends Evaluate
    var stat1 = 0
    var stat2 = 1
    var stat3 = 0

func execute():
    print('Evaluating some data')
    var obj_test = ObjectTemplate.new()
    for i in data.values():
        if obj_test.evaluate(i.reqs[0], i.reqs[1], i.reqs[2]):
            print(i.action, ' success')
        else:
            print(i.action, ' failure')

func _ready():
    execute()
