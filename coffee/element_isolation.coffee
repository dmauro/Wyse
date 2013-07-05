#########################
# Isolate elements/groups
#########################
_isolate = (element) ->
    wyse.deselect_all()
    for ele in wyse.elements
        ele.remove_class "isolated"
    element.add_class "isolated"
    iso_sandbox = wyse.settings.sandbox.clone()
    iso_sandbox.attr "id", "sandbox_isolation"
    iso_sandbox.insertAfter wyse.settings.sandbox
    wyse.settings.sandbox.addClass "isolation_mode"
    element.add_node iso_sandbox.find ".isolated"

_unisolate = (element) ->
    for ele in wyse.elements
        ele.remove_class "isolated"
    wyse.settings.sandbox.removeClass "isolation_mode"
    $('#sandbox_isolation').remove()
    element.reset_node() if element instanceof wyse.Element

_set_scope = (scope) ->
    wyse.scope = scope
    _isolate(scope) unless scope is wyse.default_scope

wyse.toggle_scope = (element) ->
    if element is wyse.scope
        _set_scope wyse.default_scope
        _unisolate element
    else
        _set_scope element

wyse.reset_scope = ->
    wyse.toggle_scope wyse.scope
