_wire_sandbox = ->
    wyse.settings.sandbox.dblclick ->
        return if event.shiftKey
        target = wyse.get_element_from_node event.target
        if target
            wyse.toggle_scope target
        else
            wyse.reset_scope()

    # Do our own click so it doesn't fire if we're dragging
    start_x = 0
    start_y = 0
    click_threshold = 3
    wyse.settings.sandbox.mousedown ->
        start_x = event.pageX
        start_y = event.pageY
    wyse.settings.sandbox.mouseup ->
        diff_x = Math.abs event.pageX - start_x
        diff_y = Math.abs event.pageY - start_y
        if diff_x < click_threshold and diff_y < click_threshold
            target = wyse.get_element_from_node event.target
            if target
                target.clicked event
            else
                wyse.clear_selection()

    wyse.settings.sandbox.bind "mousemove.wyse_hover", ->
        return if wyse.is_drawing_marquee
        target = wyse.get_element_from_node event.target
        wyse.draw_hover_outline target

    return

window.wyse = {};

wyse.wire = (settings) ->
    defaults = {
        sandbox     : $('#sandbox')
        editor      : $('#editor')
        marquee     : $('#marquee')
        outlines    : $('#element_outlines')

        selecting_class     : "selecting"
    }
    wyse.settings = $.extend defaults, settings
    wyse.property_editor = new wyse.PropertyEditor
    wyse.wire_marquee_selection()
    wyse.wire_element_movement()
    wyse.elements = []
    wyse.scope = wyse.default_scope = wyse.settings.sandbox
    _wire_sandbox()

wyse.deselect_all = ->
    for ele in wyse.elements
        ele.deselect()

wyse.get_element_from_node = (node) ->
    for ele in wyse.elements
        return ele if ele.does_this_belong_to_you node
    return false

wyse.update_css = ->
    # Temp to test CSS validation
    text = $('textarea').val()

    # Remove unecessary whitespace
    text = text.replace new RegExp('\\s*:\\s*', 'g'), ":"
    text = text.replace new RegExp('\\s*;\\s*', 'g'), ";"
    # Split into pairs
    pairs = text.split ';'
    pairs.splice -1, 1
    for pair in pairs
        pair = pair.split ':'
        result = css_validator.test_pair pair[0], pair[1]
        if result
            for ele in wyse.property_editor.selection
                ele.update_property pair[0], pair[1]

class wyse.Element
    constructor: (@_node_tag, styles) ->
        @parent = null
        @_node = @_original_node = null
        @children = []
        @styles = styles or {
            width       : "100px"
            height      : "100px"
            border      : "1px solid #aaa"
            background  : "#eee"
            position    : "absolute"
        }
        @css = ""
        @create_node()
        @wire_element()
        wyse.elements.push @
        @select_only()

    create_node: ->
        @_node = @_original_node = $("<#{@_node_tag}></#{@_node_tag}>");
        @update_appearance()
        unless wyse.scope is wyse.default_scope
            @parent = wyse.scope
            # We have to clone the node because of the isolation layer duplicate
            @_node = @_node.add @_node.clone()
            wyse.scope.append @_node, @
        else
            wyse.scope.append @_node

    update_appearance: ->
        for property, value of @styles
            @_node.css property, value

    wire_element: ->
        _previous_position = null
        @_node.draggable().bind("dragstart", (event, ui) =>
            return false unless event.target is @_node[0]
            @select_only() unless @is_selected
            _previous_position = ui.position
            wyse.clear_hover_outlines()
        ).bind("drag", (event, ui) =>
            wyse.property_editor.update_property_fields()
            # Drag all selected items along with it
            left_adjust = ui.position.left - _previous_position.left
            top_adjust = ui.position.top - _previous_position.top
            for ele in wyse.property_editor.selection
                continue if ele is @
                ele.adjust_property "left", left_adjust
                ele.adjust_property "top", top_adjust
            _previous_position = ui.position
            @update_property "left", ui.position.left
            @update_property "top", ui.position.top
        )

    clicked: (event) ->
        return if @is_locked
        if @parent and @parent isnt wyse.scope
            return @parent.clicked event
        if @is_selected
            if event.shiftKey
                @deselect()
            else
                @select_only()
        else
            if event.shiftKey
                @select()
            else
                @select_only()

    select_only: ->
        wyse.deselect_all()
        @select()

    select: ->
        return if @is_selected
        @is_selected = true
        wyse.property_editor.add_to_selection @ 
        wyse.redraw_selection()
        wyse.clear_hover_outlines()

        # Putting this here for now
        style_text = ""
        for property, value of @styles
            style_text += "#{property} : #{value};\n"
        $('#editor textarea').text style_text

    deselect: ->
        return unless @is_selected
        @is_selected = false
        wyse.property_editor.remove_from_selection @
        wyse.redraw_selection()

    get_property: (property) ->
        return @_node.css property

    update_property: (property, value) ->
        @_node.css property, value
        @styles[property] = @get_property property
        if @is_selected
            wyse.property_editor.update_property @, property
        wyse.redraw_selection()

    adjust_property: (property, float) ->
        value = parseInt @get_property property, 10
        value = value or 0
        @update_property property, value + float

    outer_width: ->
        return @_node.outerWidth()

    outer_height: ->
        return @_node.outerHeight()

    position: ->
        return @_node.position()

    offset: ->
        return @_node.offset()

    add_class: (name) ->
        return @_node.addClass name

    remove_class: (name) ->
        return @_node.removeClass name

    append: (node, element) ->
        # Because this item is isolated, we need to append to both copies of the node
        $(@_node[0]).append node[0]
        $(@_node[1]).append node[1]
        @children.push element

    clone: ->
        styles = $.extend {}, @styles
        styles["left"] = (parseInt(styles["left"], 10) + 10 ) + "px"
        styles["top"] = (parseInt(styles["top"], 10) + 10) + "px"
        return new wyse.Element "div", styles

    add_node: (node) ->
        @_node = @_node.add node

    reset_node: ->
        @_node = @_original_node

    does_this_belong_to_you: (node) ->
        for _, _node of @_node
            return true if node is _node
        return false

class wyse.PropertyEditor
    constructor: ->
        @_node = null
        @selection = []
        @properties = {
            "width"             : "width"
            "height"            : "height"
            "left"              : "x"
            "top"               : "y"
            "background-color"  : "color"
            "border-width"      : "border width"
            "border-color"      : "border color"
            "border-radius"     : "border radius"
            "box-shadow"        : "box shadow"
            "text-shadow"       : "text shadow"
            "opacity"           : "opacity"
            "z-index"           : "z index"
        }
        @create_node()
        @wire_editor()

    hide: ->
        @_node.css "visibility", "hidden"

    show: ->
        @_node.css "visibility", "visible"

    add_to_selection: (element) ->
        @selection.push element
        @update_property_fields()
        @show()

    remove_from_selection: (element) ->
        for i in [0...@selection.length]
            if element is @selection[i]
                @selection.splice i, 1
                @hide() unless @selection.length
                @update_property_fields()
                return

    create_node: ->
        node_string = "<ul>"
        for property, name of @properties
            node_string += "<li><label>#{name}</label><input data-property=\"#{property}\" type=\"text\"></li>"
        node_string += "</ul>"
        @_node = $(node_string)
        wyse.settings.editor.append @_node
        @hide()

    update_property_fields: ->
        return unless @selection.length
        for property, _ of @properties
            value = @selection[0].get_property property
            if @selection.length > 1
                for ele in @selection
                    value = "" unless value is ele.get_property property
            input = $('input[data-property=' + property + ']', @_node)
            input.val value

    update_property: (element, property) ->
        value = element.get_property property
        input = $('input[data-property=' + property + ']', @_node)
        for ele in @selection
            value = "" unless value is ele.get_property property
        input.val value

    wire_editor: ->
        self = @
        @_node.delegate 'input', 'change', (e) ->
            input = $(this)
            value = input.val()
            property = input.data "property"
            for ele in self.selection
                ele.update_property property, value
        return
