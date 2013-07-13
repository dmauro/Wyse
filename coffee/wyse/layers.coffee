class wyse.Layers
    constructor: (@id_name) ->
        @element = crel 'div', { id : @id_name }

    add_node: (node) ->
        parent = node.parent?.layers_element or @element
        node.layers_element = crel 'div.layer'
        parent.appendChild node.layers_element

    remove_node: (node) ->
        parent = node.parent?.layers_element or @element
        parent.removeChild node.layers_element

    set_selected_nodes: (node_array) ->
        