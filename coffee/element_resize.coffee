################################################
# Resize by dragging logic for selected elements
################################################
wyse.resize_from_corner = (elements, down_event, corner) ->
    prev_x = down_event.pageX
    prev_y = down_event.pageY
    $(window).bind "mouseup", ->
        wyse.is_resizing_element = false
        $(window).unbind "mousemove.wyse_resize"
    $(window).bind "mousemove.wyse_resize", ->
        wyse.is_resizing_element = true
        x_diff = event.pageX - prev_x
        y_diff = event.pageY - prev_y
        for ele in elements
            ele.adjust_property "width", x_diff
            ele.adjust_property "height", y_diff
        prev_x = event.pageX
        prev_y = event.pageY

wyse.bind_selection_for_drag = (selection, elements) ->
    width = selection.outerWidth()
    height = selection.outerHeight()
    offset = selection.offset()
    selection.bind "mousedown", ->
        # Decide which corner we're clicking on
        if event.pageX < offset.left + width/2
            if event.pageY < offset.top + height/2
                corner = "nw"
            else
                corner = "sw"
        else
            if event.pageY < offset.top + height/2
                corner = "ne"
            else
                corner = "se"
        wyse.resize_from_corner elements, event, corner