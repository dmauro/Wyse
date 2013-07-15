id = 0
get_id = ->
    value = id
    id += 1
    return value

class wyse.Node
    constructor: (@tag, @parent, @styles) ->
        @id = get_id()
        @children = []

    update_styles: (styles) ->
        for property, value of styles
            @styles[property] = value

    add_child: (node) ->
        @children.push node

    remove_child: (node) ->
        for i in [0...@children.length]
            if @children[i] is child
                @children.splice i, 1
                return

    for_self_and_each_parent_recursive: (handler) ->
        return_value = handler @
        if @parent and return_value isnt false
            @parent.for_self_and_each_parent_recursive handler

