class wyse.PropertyEditor
    constructor: (@id_name) ->
        @node_style_updated_handler = ->
        @element = crel 'div', { id : @id_name }

    set_selected_nodes: (node_array) ->

