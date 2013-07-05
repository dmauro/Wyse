#####################################################
# Selection Marquee and hover/select/marquee outlines
#####################################################
_marquee = null
_constrain_width = 0
_constrain_height = 0

_available_elements = ->
    # Returns all elements that are available based on our current scope
    if wyse.scope is wyse.default_scope
        return wyse.elements
    else
        return _get_element_and_all_children wyse.scope

_get_parent_closest_to_scope_from_element = (element) ->
    while element.parent and element.parent isnt wyse.scope
        element = element.parent
    return element

_get_elements_under_marquee = ->
    # Returns all available elements that touch the marquee
    # Will use the the parent of a group
    available = _available_elements()
    overlapping = []
    for ele in available
        offset = ele.offset()
        sandbox_offset = wyse.settings.sandbox.offset()
        x1 = offset.left - sandbox_offset.left
        y1 = offset.top - sandbox_offset.top
        x2 = x1 + ele.outer_width()
        y2 = y1 + ele.outer_height()
        if _marque.x1 < x2 and _marquee.x2 > x1 and _marquee.y1 < y2 and _marquee.y2 > y1
            # Confirmed overlap
            ele = _get_parent_closest_to_scope_from_element ele
            overlapping.push ele
    return overlapping

_get_element_and_all_children = (element, stop_at_scope=false) ->
    elements = []
    _add_self_and_children = (ele) ->
        elements.push ele
        # Don't get its children if we're in its scope
        return if stop_at_scope and ele is wyse.scope
        for child in ele.children
            _add_self_and_children child
    _add_self_and_children element
    return elements

_draw_resize_border_around = (group) ->
    elements = []
    for element in group
        all = _get_element_and_all_children element, true
        for element in all
            elements.push element
    if elements.length > 1
        console.log "draw a single border"
        # Draw a single border around each
    # Draw a resize border around all of them

wyse.redraw_selection = ->
    _draw_resize_border_around wyse.selection


