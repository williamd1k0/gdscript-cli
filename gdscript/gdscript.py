"""
The MIT License (MIT)

Copyright (c) 2017 William Tumeo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

# WARN: This code is a bit messy, be careful
# TODO: Add automatic script mode check (priority)
# TODO: Add an error handler
# TODO: Fix/Sync script line number
# TODO: Improve script template
# TODO: Remove `fire` module (cool module but bloated)
# TODO: Add documentation...
# TODO: Add verbose mode/command (not a priority)
# TODO: Profit :P


import os
import subprocess
import sys
import re


__version__ = 0, 1, 0

VERBOSE = False
#GODOT_BINARY = r'./Godot_v2.1.2-stable_linux_server.64'
GODOT_BINARY = os.environ.get('GODOT_BINARY', 'godot.exe')
DEFAULT_OUTPUT = os.environ.get('DEFAULT_OUTPUT', 'windows')


def text_indent(text):
    indented = ''
    for line in text.split('\n'):
        indented += '    '+line+'\n'
    return indented.strip('\n')


class GodotScript(object):

    MODE_EXTENDS = 0
    MODE_CLASS = 1
    MODE_SIMPLE = 2

    CLASS_BODY = """extends SceneTree
{body}
func _init():
    var timer = Timer.new()
    get_root().add_child(timer)
    timer.set_wait_time({timer})
    timer.start()
    var instance = {name}.new()
    get_root().add_child(instance)
    yield(timer, 'timeout')
    quit()
"""
# TODO: Add wait mode - requires get_tree().quit()

    EXTENDS_BODY = """class __GeneratedGodotClass__:
{body}
"""

    SIMPLE_BODY = """extends Node
func _ready():
{body}
"""

    def __init__(self, body, mode=0, name=None, timer=1, path=None):
        self._body = body
        self._name = name
        self.mode = mode
        self.timer = timer
        self.path = path
        self.map_lines = 1

    @property
    def body(self):
        if self.mode == self.MODE_CLASS:
            return self._body
        elif self.mode == self.MODE_EXTENDS:
            self.map_lines += 1
            return self.EXTENDS_BODY.format(body=text_indent(self._body))
        elif self.mode == self.MODE_SIMPLE:
            self.map_lines += 3
            return self.EXTENDS_BODY.format(
                body=text_indent(self.SIMPLE_BODY.format(
                    body=text_indent(self._body)
                ))
            )

    @property
    def name(self):
        return '__GeneratedGodotClass__' if self._name is None else self._name

    def full_body(self):
        return self.CLASS_BODY.format(
            body=self.body, name=self.name, timer=self.timer
        )

    def __repr__(self):
        return self.full_body()

    @classmethod
    def from_simple(cls, body):
        return cls(body, cls.MODE_SIMPLE)

    @classmethod
    def from_file(cls, path, mode, wait=1):
        with open(path, 'r', encoding='utf-8') as gds:
            body = gds.read()
            body.replace('\t', '    ')
        return cls(
            body, mode, timer=wait,
            path=os.path.dirname(os.path.abspath(path))
        )

    @classmethod
    def from_file_ex(cls, path, wait=1):
        return cls.from_file(path, cls.MODE_EXTENDS, wait)

    @classmethod
    def from_file_cls(cls, path, wait=1):
        raise NotImplementedError()
        # return cls.from_file(path, cls.MODE_CLASS, wait)


class OutputProcess(object):

    def __init__(self, output):
        self.output = output

    def has_errors(self):
        return False

    def strip(self):
        return self.output.strip() # Raw output

    def clean(self):
        # TODO
        return self.strip() # No errors output

    def errors(self):
        # TODO
        return self.strip() # Errors only output

class WindowsOutput(OutputProcess):

    def strip(self):
        clean_output = ''
        for line in self.output.split('\n'):
            if 'EXEC PATHP??:' in line:
                continue
            if 'DETECTED MONITORS:' in line:
                continue
            clean_output += line+'\n'
        return clean_output.strip()

class LinuxServerOutput(OutputProcess):

    def strip(self):
        clean_output = ''
        for line in self.output.split('\n'):
            # FIXME: Ignoring rasterizer errors
            # servers/visual/visual_server_raster.cpp:4821
            if '\033[1;31mERROR:' in line:
                continue
            if '\033[0;31m   At:' in line:
                continue
            clean_output += line+'\n'
        return clean_output.strip()

OUTPUT_PROCESSES = {
    'windows': WindowsOutput,
    'linux-server': LinuxServerOutput
}


class ScriptProcess(object):
    ROOT = os.path.dirname(os.path.abspath(sys.argv[0]))
    cache = 0
    script_name = '.gdscript{0}.gd'
    godot_bin = ''

    def __init__(self, script_body, cache=0, gdbin=None, op=OutputProcess):
        self.script_body = script_body
        self.cache = cache
        self.godot_bin = gdbin
        self.output_process_class = op

    @property
    def script(self):
        if self.script_body.path is not None:
            return os.path.join(
                self.script_body.path, self.script_name.format(self.cache)
            )
        return self.script_name.format(self.cache)

    @property
    def command(self):
        cmd = (
            self.godot_bin, '-s',
            os.path.join(os.path.abspath(os.getcwd()), self.script)
        )
        if self.script_body.path is not None:
            cmd = cmd + ('-p', self.script_body.path)
        if VERBOSE:
            print('GODOT COMMAND:', cmd)
        if 'win' in sys.platform:
            cmd = cmd + ('--no-window',)
        return cmd


    def output(self, mode):
        return open(
            os.path.join(self.ROOT, '.gdscript{0}.log'.format(self.cache)),
            mode
        )

    def save_script(self):
        with open(self.script, 'w', encoding='utf-8') as gds:
            gds.write(str(self.script_body))
        del gds

    def execute_script(self):
        if 'win' in sys.platform:
            info = subprocess.STARTUPINFO()
            info.dwFlags = subprocess.STARTF_USESHOWWINDOW
            info.wShowWindow = 0 # SW_HIDE
            process = subprocess.Popen(
                self.command,
                stdout=subprocess.PIPE,
                startupinfo=info
            )
        else:
            process = subprocess.Popen(self.command, stdout=subprocess.PIPE)

        output_list = []
        re_ogl = re.compile(r'OpenGL ES [23]\.0 Renderer:')
        re_err = re.compile(r'\.gd:(\d+)')
        while True:
            ignore_next = False
            error = None
            for line in process.stdout.readlines():
                uline = line.decode('utf-8').strip()
                output_list.append(uline)
                if not ignore_next:
                    if VERBOSE:
                        print(uline)
                    elif error is not None:
                        line_err = int(re_err.search(uline).group(1))
                        line_err -= self.script_body.map_lines
                        print(error)
                        print('\tAt: <script>:%s' % line_err)
                        error = None
                    else:
                        if 'SCRIPT ERROR: ' in uline:
                            error = uline.replace('SCRIPT ERROR: ', '').replace('GDScript::reload: ', '')
                        elif 'WARNING: ' in uline or 'ERROR: ' in uline:
                            if 'WARNING: cleanup: ObjectDB Instances still exist' in uline:
                                print('WARNING: Possible memory leak!')
                            ignore_next = True
                        elif re_ogl.match(uline) is None:
                            print(uline)
                else:
                    ignore_next = False
            if process.poll() is not None:
                break

        output = self.output('w')
        output.write('\n'.join(output_list))
        output.close()
        # TODO: Dynamic output check
        output_clean = self.output_process_class('\n'.join(output_list))
        #print(output_clean.strip())
        os.unlink(self.script)
        return output_clean.strip()

    def exec_godot_script(self):
        self.save_script()
        return self.execute_script()


class GodotREPL(object):
    """
    Godot REPL implementation.
    """

    def __init__(self, godot, output_analyzer=None):
        self._count = 0
        self._godot = godot
        self._output = output_analyzer

    def _create_process(self, script):
        self._count += 1
        return ScriptProcess(script, self._count-1, self._godot, self._output)

    def oneline(self, code):
        """Executes one line of code."""
        script = GodotScript.from_simple(code)
        process = self._create_process(script)
        process.exec_godot_script()

    def block(self, code):
        """Executes a block of code."""
        mode, path, wait = None, None, None
        if True: # mode == 'extends':
            script = GodotScript(code)
        elif mode == 'class':
            script = GodotScript.from_file_cls(path, wait)
        process = self._create_process(script)
        process.exec_godot_script()

    def eval(self, expression):
        """Evaluates a boolean expression."""
        code = 'print(bool({0}))'.format(expression)
        self.oneline(code)

    def file(self, path, mode='extends', wait=1):
        """Executes a script file <script.gd>."""
        # TODO: Add automatic mode check
        if mode == 'extends':
            script = GodotScript.from_file_ex(path, wait)
        elif mode == 'class':
            script = GodotScript.from_file_cls(path, wait)
        process = self._create_process(script)
        process.exec_godot_script()



if __name__ == '__main__':
    import fire

    fire.Fire(
        GodotREPL(GODOT_BINARY, OUTPUT_PROCESSES[DEFAULT_OUTPUT]),
        name='gdscript'
    )
