#####################################
# Item highlighting/selecting/marquee
#####################################
_marquee = null
_constrain_width = null
_constrain_height = null

_get_elements_in_marquee = ->
    if wyse.scope is wyse.default_scope
        available_elements = wyse.elements
    else
        available_elements = [wyse.scope]
    overlapping = []
    x1 = _marquee.start[0]
    y1 = _marquee.start[1]
    x2 = _marquee.end[0]
    y2 = _marquee.end[1]
    for ele in available_elements
        continue if ele.is_locked #TODO: make items lockable
        offset = ele.offset()
        sandbox_offset = wyse.settings.sandbox.offset()
        ex1 = offset.left - sandbox_offset.left
        ey1 = offset.top - sandbox_offset.top
        ex2 = ex1 + ele.outer_width()
        ey2 = ey1 + ele.outer_height()
        overlapping.push(ele) if (x1 < ex2 and x2 > ex1 and y1 < ey2 and y2 > ey1)
    return overlapping

_draw_marquee = (x1, y1, x2, y2) ->
    # Constrain to container
    x2 = Math.min(Math.max(0, x2), _constrain_width)
    y2 = Math.min(Math.max(0, y2), _constrain_height)

    left = if x2 > x1 then x1 else x2
    top = if y2 > y1 then y1 else y2
    width = if x2 > x1 then x2 - x1 else x1 - x2
    height = if y2 > y1 then y2 - y1 else y1 - y2

    wyse.settings.marquee.css(
        display : "block"
        left    : left
        top     : top
        width   : width
        height  : height
    )

    _marquee =
        start   : [left, top]
        end     : [left + width, top + height]

    _highlight()
    return

_select_from_marquee = ->
    wyse.clear_selection()
    return unless _marquee
    _un_highlight()
    overlapping = _get_elements_in_marquee()
    for ele in overlapping
        ele.select()
    wyse.settings.marquee.css "display", "none"
    _marquee = null
    return

_draw_outline = (x, y, w, h, class_name, elements) ->
    selection = $("<div class=\"outline #{class_name}\"><div></div></div>")
    selection.css(
        left    : x
        top     : y
        width   : w
        height  : h
    )
    wyse.settings.outlines.append selection
    # If it looks resizable, it should be bound for resize also
    if class_name.indexOf "resizable" > -1
        wyse.bind_selection_for_drag selection, elements

_draw_single_outline = (element, class_name) ->
    offset = element.offset()
    sandbox_offset = wyse.settings.sandbox.offset()
    left = offset.left - sandbox_offset.left
    top = offset.top - sandbox_offset.top
    _draw_outline left, top, element.outer_width(), element.outer_height(), class_name, [element]

_draw_multi_outline = (group=wyse.property_editor.selection, class_name="resizable selected") ->
    x1 = Infinity
    y1 = Infinity
    x2 = -Infinity
    y2 = -Infinity
    expand_outer_bounds = (ele) ->
        offset = ele.offset()
        sandbox_offset = wyse.settings.sandbox.offset()
        x = offset.left - sandbox_offset.left
        y = offset.top - sandbox_offset.top
        width = ele.outer_width()
        height = ele.outer_height()
        x1 = x if x < x1
        y1 = y if y < y1
        x2 = x + width if x + width > x2
        y2 = y + height if y + height > y2
    for ele in group
        expand_outer_bounds ele
    _draw_outline x1, y1, x2 - x1, y2 - y1, class_name, group

_get_parent_closest_to_scope_from_element = (element) ->
    while element.parent and element.parent isnt wyse.scope
        element = element.parent
    return element

_get_group_from_element = (element) ->
    # Looking at a single element, find the entirety of its group
    element = _get_parent_closest_to_scope_from_element element
    group = [element]
    # Recurse through tree to get all child elements
    add_children = (ele) ->
        for child in ele.children
            group.push child
            add_children child
    add_children(element) unless element is wyse.scope
    return group

_draw_group_outline = (group, class_name="", multi_class_name=null) ->
    for ele in group
        _draw_single_outline ele, class_name
    _draw_multi_outline group, multi_class_name or class_name

_highlight = ->
    _un_highlight()
    highlighted = _get_elements_in_marquee()
    for ele in highlighted
        group = _get_group_from_element ele
        _draw_group_outline group, "highlighted"

_un_highlight = ->
    wyse.settings.outlines.children(".highlighted").remove()

_hovering = null

#################
# Public Function
#################
wyse.clear_selection = ->
    wyse.settings.outlines.children(".selected").remove()

wyse.clear_hover_outlines = ->
    wyse.settings.outlines.children(".hovering").remove()

wyse.draw_hover_outline = (element) ->
    return if wyse.is_resizing_element
    return if element is _hovering
    _hovering = element
    wyse.clear_hover_outlines()
    return unless element
    return if element.is_selected
    _draw_single_outline element, "resizable hovering"

wyse.redraw_selection = ->
    wyse.clear_selection()
    return unless wyse.property_editor.selection
    for ele in wyse.property_editor.selection
        group = _get_group_from_element ele
        _draw_group_outline group, "selected", "resizable selected"
    if wyse.property_editor.selection.length > 1
        _draw_multi_outline()

wyse.wire_marquee_selection = ->
    _constrain_width = wyse.settings.sandbox.width()
    _constrain_height = wyse.settings.sandbox.height()

    wyse.settings.sandbox.bind "mousedown.wyse", (down_event) ->
        _first_time = true
        # Make sure we've not clicked on an element
        return unless down_event.target is wyse.settings.sandbox[0]
        offset = wyse.settings.sandbox.offset()
        x1 = down_event.pageX - offset.left
        y1 = down_event.pageY - offset.top
        $(window).bind "mousemove.wyse", (move_event) ->
            if _first_time
                wyse.is_drawing_marquee = true
                wyse.deselect_all()
                $('body').addClass wyse.settings.selecting_class
            _first_time = false
            x2 = move_event.pageX - offset.left
            y2 = move_event.pageY - offset.top
            _draw_marquee x1, y1, x2, y2
    wyse.settings.sandbox.bind "mouseup.wyse", (up_event) ->
        return unless up_event.target is wyse.settings.sandbox[0]
        wyse.deselect_all()
    $(window).bind "mouseup.wyse", ->
        $(window).unbind "mousemove.wyse"
        wyse.is_drawing_marquee = false
        _select_from_marquee()
        $('body').removeClass wyse.settings.selecting_class
    return
