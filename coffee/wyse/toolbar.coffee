class wyse.Toolbar
    constructor: (@id_name) ->
        @element = crel 'div', { id : @id_name },
            crel('button', { class : "create_div" }, "Create DIV"),
            crel('button', { class : "create_button" }, "Create BUTTON"),
            crel('button', { class : "remove_node" }, "Remove Selected Element(s)")
        @create_node_handler = ->
        @remove_node_handler = ->

    bind: ->
        root = $("##{@id_name}")
        root.find(".create_div").on "click", =>
            @create_node_handler "div"
        root.find(".create_button").on "click", =>
            @create_node_handler "button"
        root.find(".remove_node").on "click", =>
            @remove_node_handler()