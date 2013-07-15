# This should be handling all click events for the elements.
# It also needs to consider isolation mode.

class wyse.Sandbox
    constructor: (@id_name, @width=640, @height=480) ->
        @sandbox_element = crel 'div', { class : "default_sandbox" }
        @isolation_sandbox_element = crel 'div', { class : "isolation_sandbox" }
        @element_outlines = crel 'div', { class : "element_outlines" }
        @marquee = crel 'div', { class : "marquee" }
        @element = crel 'div', { id : @id_name, style : "width:#{@width}px;height:#{@height}px;" }, @sandbox_element, @isolation_sandbox_element, @element_outlines, @marquee
        @isolated_node = null
        @hovered_node = null
        @get_node_from_id_handler = ->
        @update_scope_handler = ->
        @nodes_selected_handler = ->
        @request_nodes_reselected_handler = ->

    add_node: (node) ->
        node.element = crel node.tag, { class : "sandbox_node_#{node.id}" }
        parent = node.parent?.element or @sandbox_element
        parent.appendChild node.element
        @update_styling_for_node node

        # We need to update the isolation layer as well
        if node.parent? and node.parent is @isolated_node
            @clone_isolated_node node.parent

        # We need to update the outlines
        @request_nodes_reselected_handler()

    remove_node: (node) ->
        # Update the isolation layer also
        if @isolated_node
            @clone_isolated_node node.parent

        parent = node.parent?.element or @sandbox_element
        parent.removeChild node.element
        node.element = null

    get_style_for_node: (node) ->
        style = ""
        for property, value of node.styles
            style += "#{property}:#{value};"
        return style

    get_layout_for_element: (element, is_outline=false) ->
        # Layout returned as:
        # { width:px, height:px, left:px, top:px }
        $element = $(element)
        outline_border = 1 #px

        offset = $element.offset()
        top_adjust = 0
        left_adjust = 0
        unless is_outline or $element.css("position") in ["absolute", "fixed"]
            top_adjust -= parseInt $element.css('margin-top'), 10
            left_adjust -= parseInt $element.css('margin-left'), 10
            # I'm not sure why this is needed.. curious...
            top_adjust -= 1
            left_adjust -= 1
        if is_outline
            # Adjust for the outline's own border
            left_adjust -= outline_border
            top_adjust -= outline_border
        left = offset.left + left_adjust + @element.scrollLeft
        top = offset.top + top_adjust + @element.scrollTop

        if $element.css("box-sizing") is "content-box" and not is_outline
            width = $element.width()
            height = $element.height()
        else if $element.css("box-sizing") is "padding-box" and not is_outline
            width = $element.outerWidth()
            width -= parseInt $element.css('border-left-width'), 10
            width -= parseInt $element.css('border-right-width'), 10
            height = $element.outerHeight()
            height -= parseInt $element.css('border-top-width'), 10
            height -= parseInt $element.css('border-bottom-width'), 10
        else if $element.css("box-sizing") is "border-box" or is_outline
            width = $element.outerWidth()
            height = $element.outerHeight()
        if is_outline
            width -= outline_border * 2
            height -= outline_border *2

        return {
            width   : width
            height  : height
            left    : left
            top     : top
        }

    get_layout_string_for_node: (node, is_outline=false) ->
        layout = @get_layout_for_element node.element, is_outline
        style = "position:absolute;"
        style += "width:#{layout.width}px;"
        style += "height:#{layout.height}px;"
        style += "top:#{layout.top}px;"
        style += "left:#{layout.left}px;"
        return style

    clone_isolated_node: (node) ->
        @isolation_sandbox_element.innerHTML = ''
        clone = node.element.cloneNode true
        style = @get_style_for_node node
        style += @get_layout_string_for_node node
        clone.style.cssText = style
        @isolation_sandbox_element.appendChild clone

    isolate_node: (node) ->
        # Clear out the isolation sandbox, then make a deep clone
        # of the isolated node and place it in the isolation sandbox
        node = null if node is @isolated_node
        if node
            @clone_isolated_node node
            @element.className = "isolated"
        else
            @isolation_sandbox_element.innerHTML = ''
            @element.className = ""
        @isolated_node = node
        @update_scope_handler node

    update_styling_for_node: (node) ->
        # Update style
        style = @get_style_for_node node
        node.element.style.cssText = style

        # Update style of isolated clone if necessary
        is_isolated = false
        node.for_self_and_each_parent_recursive (parent_node) ->
            if parent_node is @isolated_node
                is_isolated = true
                return false
        is_root_isolated_node = node is @isolated_node
        if is_isolated
            element = document.querySelector "##{@id_name} .isolation_sandbox .sandbox_node_#{node.id}"
            if is_root_isolated_node
                style = @update_style_with_node_layout style, node
            element.style.cssText = style

        # Update selection outlines
        @request_nodes_reselected_handler()

    create_outline: (class_name, id) ->
        return crel 'div', { class : "outline #{class_name}", "data-id" : id }, crel 'div'

    set_marqueed_nodes: (node_array) ->
        # Remove all others
        $(@element_outlines).find(".under_marquee").remove()
        # Create new selection outlines
        return unless node_array
        for node in node_array
            outline = @create_outline "under_marquee", node.id
            style = @get_layout_string_for_node node, true
            outline.style.cssText = style
            @element_outlines.appendChild outline

    set_selected_nodes: (node_array) ->
        # Remove all other selection
        $(@element_outlines).find(".selected").remove()
        # Create new selection outlines
        return unless node_array
        for node in node_array
            outline = @create_outline "resizable selected", node.id
            style = @get_layout_string_for_node node, true
            outline.style.cssText = style
            @element_outlines.appendChild outline

    set_hovered_node: (node) ->
        return if node is @hovered_node
        @hovered_node = node
        # Remove other hovers
        $(@element_outlines).find(".hovering").remove()
        if node
            outline = @create_outline "resizable hovering", node.id
            style = @get_layout_string_for_node node, true
            outline.style.cssText = style
            @element_outlines.appendChild outline

    get_node_id_from_class_name: (class_name) ->
        class_name_array = class_name.split "_"
        id = parseInt class_name_array[class_name_array.length - 1], 10
        id = null if isNaN id
        return id

    bind: ->
        $element = $(@element)

        # Isolate a node on double click
        $element.dblclick =>
            $target = $(event.target)
            isolated_node = null
            # Only allow us to directly isolate deeper in if we're already isolated
            if not @isolated_node? or $target.parents(".isolation_sandbox").length
                id = @get_node_id_from_class_name event.target.className
                isolated_node = @get_node_from_id_handler id
            @isolate_node isolated_node

        # Handle clicking distincly from dragging, which jQuery UI handles
        do =>
            start_x = 0
            start_y = 0
            click_threshold = 3

            $element.mousedown =>
                start_x = event.pageX
                start_y = event.pageY

            $element.mouseup =>
                diff_x = Math.abs event.pageX - start_x
                diff_y = Math.abs event.pageY - start_y
                if diff_x < click_threshold and diff_y < click_threshold
                    id = @get_node_id_from_class_name event.target.className
                    target_node = @get_node_from_id_handler id
                    target_node_array = if target_node then [target_node] else null
                    @nodes_selected_handler target_node_array, event.shiftKey

        # Hover outlines
        do =>
            mouse_is_down = false
            $element.mousedown ->
                mouse_is_down = true
                return true
            $element.mouseup ->
                mouse_is_down = false
                return true

            $element.mousemove =>
                return if mouse_is_down
                id = @get_node_id_from_class_name event.target.className
                unless id?
                    # If we're hovering the hover outline, pass it on to the node
                    id = parseInt event.target.parentNode.getAttribute("data-id"), 10
                hovered_node = @get_node_from_id_handler id
                @set_hovered_node hovered_node

            $element.mouseout =>
                return unless event.target is @element
                @set_hovered_node null

        # Marquee
        do =>
            $sandbox = $(@sandbox_element)
            offset = $element.offset()
            x1 = 0
            y1 = 0
            x2 = 0
            y2 = 0
            marquee_is_drawn = false

            get_nodes_under_rectangle = (x1, y1, x2, y2) =>
                # Invert rectangle if needed
                if x1 > x2
                    x2=x1+(x1=x2)-x2
                if y1 > y2
                    y2=y1+(y1=y2)-y2

                root = if @isolated_node then @isolation_sandbox_element else @sandbox_element
                overlapped = []
                check_node_recursively = (element) =>
                    layout = @get_layout_for_element element, true
                    ex1 = layout.left - offset.left
                    ey1 = layout.top - offset.top
                    ex2 = ex1 + layout.width
                    ey2 = ey1 + layout.height
                    if (x1 < ex2 and x2 > ex1 and y1 < ey2 and y2 > ey1)
                        # Get the node
                        id = @get_node_id_from_class_name element.className
                        node = @get_node_from_id_handler id
                        overlapped.push node
                    for child in element.childNodes
                        check_node_recursively child

                for child in root.childNodes
                    check_node_recursively child

                return overlapped

            draw_marquee_handler = =>
                marquee_is_drawn = true
                # Deselect all
                x2 = event.pageX - offset.left + @element.scrollLeft
                y2 = event.pageY - offset.top + @element.scrollTop

                # Draw marquee constrained to width/height (minus size with border)
                x2 = Math.min(Math.max(0, x2), $sandbox.width() - 2)
                y2 = Math.min(Math.max(0, y2), $sandbox.height() - 2)

                left = if x2 > x1 then x1 else x2
                top = if y2 > y1 then y1 else y2
                width = if x2 > x1 then x2 - x1 else x1 - x2
                height = if y2 > y1 then y2 - y1 else y1 - y2

                style = "display:block;"
                style += "width:#{width}px;"
                style += "height:#{height}px;"
                style += "top:#{top}px;"
                style += "left:#{left}px;"

                @marquee.style.cssText = style

                marqueed_nodes = get_nodes_under_rectangle x1, y1, x2, y2
                @set_marqueed_nodes marqueed_nodes

            $element.mousedown =>
                # Make sure we haven't clicked on a node
                return unless event.target.className.indexOf("sandbox_node_") is -1
                return if event.target.parentNode.getAttribute("data-id")?
                x1 = event.pageX - offset.left + @element.scrollLeft
                y1 = event.pageY - offset.top + @element.scrollTop
                $(window).on "mousemove", draw_marquee_handler

            $(window).mouseup =>
                $(window).off "mousemove", draw_marquee_handler
                return unless marquee_is_drawn

                marquee_is_drawn = false
                selected_nodes = get_nodes_under_rectangle x1, y1, x2, y2
                @nodes_selected_handler selected_nodes, event.shiftKey
                @marquee.style.display = "none"
                @set_marqueed_nodes null




        