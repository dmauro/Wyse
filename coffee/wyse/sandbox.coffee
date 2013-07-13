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
        @node_selected_handler = ->

    add_node: (node) ->
        node.element = crel node.tag, { class : "sandbox_node_#{node.id}" }
        parent = node.parent?.element or @sandbox_element
        parent.appendChild node.element
        @update_styling_for_node node

        # We need to update the isolation layer as well
        if node.parent? and node.parent is @isolated_node
            @clone_isolated_node node.parent

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

    get_layout_for_element: (element, force_border_box=false) ->
        # Layout returned as:
        # { width:px, height:px, left:px, top:px }
        $element = $(element)
        offset = $element.offset()
        top_adjust = 0
        left_adjust = 0
        unless force_border_box #FIXME: So selection is drawn properly
            top_adjust = parseInt $element.css('border-top-width'), 10
            left_adjust = parseInt $element.css('border-left-width'), 10
        top = offset.top - top_adjust
        left = offset.left - left_adjust
        if $element.css("box-sizing") is "content-box" and not force_border_box
            width = $element.width()
            height = $element.height()
        else if $element.css("box-sizing") in ["border-box", "padding-box"] or force_border_box
            width = $element.outerWidth()
            height = $element.outerHeight()
        return {
            width   : width
            height  : height
            left    : left
            top     : top
        }

    get_layout_string_for_node: (node, force_border_box=false) ->
        layout = @get_layout_for_element node.element, force_border_box
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

    create_outline: (class_name) ->
        return crel 'div', { class : "outline #{class_name}" }, crel 'div'

    set_selected_nodes: (node_array) ->
        # Remove all other selection
        $(@element_outlines).find(".selected").remove()
        # Create new selection outlines
        for node in node_array
            outline = @create_outline "resizable selected"
            style = @get_layout_string_for_node node, true
            outline.style.cssText = style
            @element_outlines.appendChild outline

    set_hovered_node: (node) ->
        return if node is @hovered_node
        @hovered_node = node
        # Remove other hovers
        $(@element_outlines).find(".hovering").remove()
        if node
            outline = @create_outline "resizable hovering"
            style = @get_layout_string_for_node node, true
            outline.style.cssText = style
            @element_outlines.appendChild outline

    get_node_id_from_class_name: (class_name) ->
        class_name_array = class_name.split "_"
        id = parseInt class_name_array[class_name_array.length - 1], 10
        return id

    select_node: (node) ->
        @node_selected_handler node

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
                console.log "mouseup"
                diff_x = Math.abs event.pageX - start_x
                diff_y = Math.abs event.pageY - start_y
                if diff_x < click_threshold and diff_y < click_threshold
                    id = @get_node_id_from_class_name event.target.className
                    target_node = @get_node_from_id_handler id
                    @select_node target_node

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
                hovered_node = @get_node_from_id_handler id
                @set_hovered_node hovered_node

        # Marquee
        do =>
            offset = $element.offset()
            x1 = 0
            y1 = 0

            get_elements_under_rectangle = (x1, y1, x2, y2) =>
                root = if @isolated_node then @isolation_sandbox_element else @sandbox_element
                overlapped = []
                for element in root.childNodes
                    layout = @get_layout_for_element element, true
                    ex1 = layout.left - offset.left
                    ey1 = layout.top - offset.top
                    ex2 = ex1 + layout.width
                    ey2 = ey1 + layout.height
                    console.log ex1, ey1, ex2, ey2
                    console.log x1, y1, x2, y2
                    overlapped.push(element) if (x1 < ex2 and x2 > ex1 and y1 < ey2 and y2 > ey1)
                console.log "overlapped:", overlapped.length

            draw_marquee_handler = =>
                # Deselect all
                @node_selected_handler null
                x2 = event.pageX - offset.left
                y2 = event.pageY - offset.top

                # Draw marquee constrained to width/height
                x2 = Math.min(Math.max(0, x2), @width)
                y2 = Math.min(Math.max(0, y2), @height)

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

                get_elements_under_rectangle x1, y1, x2, y2

                # FIXME: Preview which ones will be selected

            $element.mousedown =>
                # Make sure we haven't clicked on a node
                return unless event.target.className.indexOf("sandbox_node_") is -1
                x1 = event.pageX - offset.left
                y1 = event.pageY - offset.top
                $(window).on "mousemove", draw_marquee_handler

            $(window).mouseup =>
                
                # FIXME: Select from marquee here

                $(window).off "mousemove", draw_marquee_handler
                @marquee.style.display = "none"




        