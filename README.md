# codegen
Code generation library and tools


## Requirements
- neovim
    - telescope

## Install
Install package
```lua
{ "willhoyle/codegen" }
```

## Getting Started

### Register Action
Register an action in a lua file, then trigger with command: `:Codegen my_comand`
```lua
local codegen = require('codegen')

codegen.register_action("my_command",
  function()
    local c = codegen.Codegen.new()
    print('hello world')
  end
)
```

### Telescope Prompt
Use prompts to get more information from the user.
```lua
local codegen = require('codegen')

codegen.register_action("examples.prompt",
  function()
    local c = codegen.Codegen.new()
    local service_name = c.choice:get_telescope({ title = "What is the service name?" })
    print(service_name)
)
```


### Add lines to a new file
Create a language specific file handle. If file doesn't exist, insert lines, and save.
Inserts lines at end of file if file already has content.
```lua
local codegen = require('codegen')

codegen.register_action("examples.add_lines",
  function()
    local c = codegen.Codegen.new()

    local my_file = c.python:file("examples.add_lines.py")
    if not my_file.exists then
      my_file:insert({"print('hello')", "print('world')"})
    end
    my_file:save()
  end
)
```

### Templating ([lustache](https://github.com/Olivine-Labs/lustache) )
Get input from user, render template using input.
```lua
local codegen = require('codegen')
local template = require('codegen.template')

codegen.register_action("examples.template",
  function()
    local c = codegen.Codegen.new()
    local service_name = c.choice:get_telescope({ title = "What is the service name?" })

    local my_file = c.python:file("examples.template.py")
    local lines = template.render("print('hello {{ service_name }}')", {service_name=service_name})
    my_file:insert(lines)
    my_file:save()
  end
)
```

### Insert imports
If the language handle provides it, insert imports.
Inserts imports after the last import statement. If more control is needed, an external tool such as `isort`
can be used to organize the imports on save.
```lua
local codegen = require('codegen')

codegen.register_action("examples.imports",
  function()
    local c = codegen.Codegen.new()

    local my_file = c.python:file("examples.imports.py")
    local lines = template.render([[
import sys


print('hello')]]
)
    my_file:insert(lines)
    my_file:insert_imports({
        "import os"
    })
    my_file:save()
  end
)
```

### Fragment
Code fragments can render templates, and handle imports.
```lua
local codegen = require('codegen')
local Fragment = require('codegen.fragment')

codegen.register_action("examples.fragment",
  function()
    local c = codegen.Codegen.new()
    local service_name = c.choice:get_telescope({ title = "What is the service name?" })

    local my_file = c.python:file("examples.fragment.py")
    local app = Fragment.new("print('hello {{ service_name }}')"
      {
        data = { service_name = service_name },
        imports = { 'import sys', 'import os' }
      }
    )
    my_file:insert(app) -- insert accepts a table of lines or a fragment
    my_file:save()
  end
)
```
