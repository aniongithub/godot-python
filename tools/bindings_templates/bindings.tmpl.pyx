# /!\ Autogenerated code, modifications will be lost /!\
# see `tools/generate_bindings.py`

from godot._hazmat.gdnative_api_struct cimport *
from godot._hazmat.gdapi cimport pythonscript_gdapi10 as gdapi10
from godot._hazmat.conversion cimport *
from godot.builtins cimport *


__ERR_MSG_BINDING_NOT_AVAILABLE = "No Godot binding available"


### Classes ###

{% from 'class.tmpl.pyx' import render_class, render_class_gdapi_ptrs_init -%}
{%- for cls in classes %}
{{ render_class(cls) }}
{%- endfor %}

### Global constants ###

{% for key, value in constants.items() %}
{{key}} = {{value}}
{% endfor %}

### Class&singletons needed for Pythonscript bootstrap ###

# Godot classes&singletons are not all available when loading Pythonscript.
# Hence greedy loading is done only for items needed for Pythonscript
# bootstrap.
# The remaining loading will be achieved when loading the first python script
# (where at this point Godot should have finished it initialization).

{% set early_needed_bindings = ["_OS", "_ProjectSettings"] %}
cdef godot_object *_ptr
{% for cls in classes %}
{% if cls["name"] in early_needed_bindings %}
{{ render_class_gdapi_ptrs_init(cls) }}
{% if cls["singleton"] %}
_ptr = gdapi10.godot_global_get_singleton("{{ cls['singleton_name'] }}")
if _ptr != NULL:
    {{ cls['singleton_name'] }}: {{ cls["name"] }} = {{ cls["name"] }}.from_ptr(_ptr)
else:
    print("ERROR: cannot load singleton `{{ cls['singleton_name'] }}` required for Pythonscript init")
{% endif %}
{% endif %}
{% endfor %}

### Remining bindings late intialization ###

cdef bint _bindings_initialized = False

{% for cls in classes %}
{% if cls["name"] not in early_needed_bindings %}
{% if cls["singleton"] %}
{{ cls['singleton_name'] }}: {{ cls["name"] }} = {{ cls["name"] }}.from_ptr(NULL)
{% endif %}
{% endif %}
{% endfor %}

cdef void _initialize_bindings():
    global _bindings_initialized
    if _bindings_initialized:
        return

{%- for cls in classes %}
{%- if cls["name"] not in early_needed_bindings %}
    {{ render_class_gdapi_ptrs_init(cls)  | indent }}
{%- if cls["singleton"] %}
    global {{ cls['singleton_name'] }}
    (<{{ cls["name"] }}>{{ cls['singleton_name'] }})._gd_ptr = gdapi10.godot_global_get_singleton("{{ cls['singleton_name'] }}")
    if (<{{ cls["name"] }}>{{ cls['singleton_name'] }})._gd_ptr == NULL:
        print('Cannot retreive singleton {{ cls['singleton_name'] }}')
{%- endif %}
{%- endif %}
{%- endfor %}

    _bindings_initialized = True
