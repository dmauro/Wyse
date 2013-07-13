class wyse.NodeManager
    constructor: (@id_name) ->
        @nodes = []
        @node_scope = null
        @selected_nodes = []

        @sandbox = new wyse.Sandbox "sandbox"
        @sandbox.get_node_from_id_handler = (node_id) =>
            for node in @nodes
                return node if node.id is node_id
        @sandbox.update_scope_handler = (node) =>
            @node_scope = node
        @sandbox.node_selected_handler = (node) =>
            # If it is the only node selected, deselect it
            # otherwise, make it the only node selected
            selected_nodes = []
            if node and not (node in @selected_nodes and @selected_nodes.length is 1)
                selected_nodes = [node]
            @set_selected_nodes selected_nodes

        @layers = new wyse.Layers "layers"

        @property_editor = new wyse.PropertyEditor "property_editor"
        @property_editor.node_style_updated_handler = (styles) =>
            node = null # Should be selected node
            if node
                @update_node_style node, styles

        @toolbar = new wyse.Toolbar "toolbar"
        @toolbar.create_node_handler = (tag) =>
            @create_node tag
        @toolbar.remove_node_handler = =>
            @remove_selected_nodes()

        @element = crel 'div', { id : @id_name },
            @sandbox.element,
            @layers.element,
            @property_editor.element,
            @toolbar.element

    bind: ->
        @sandbox.bind()
        @toolbar.bind()

    update_node_style = (node, styles) ->
        node.styles = styles
        @sandbox.update_styling_for_node node

    tag_can_go_in_node: (tag, node) ->
        # Some tags cannot have block children
        return true unless node
        return true if node.tag not in wyse.cannot_contain_block_tags
        return true if tag in wyse.inline_tags
        return false

    create_node: (tag) ->
        parent = @node_scope
        # Make sure we this type of node can go inside this one
        if not parent? or @tag_can_go_in_node tag, node
            default_styles = wyse.default_styles[tag] or {}
            node = new wyse.Node tag, parent, default_styles
            @add_node node

    add_node: (node) ->
        @nodes.push node
        @sandbox.add_node node
        @layers.add_node node

    remove_selected_nodes: ->
        for node in @selected_nodes
            @remove_node node
        @set_selected_nodes []

    remove_node: (node) ->
        @layers.remove_node node
        @sandbox.remove_node node
        for i in [0...@nodes.length]
            if @nodes[i] is node
                @nodes.splice i, 1
                break
        node.parent?.remove_child node

    change_node_position: ->
        # We need to deal with nodes getting shuffled around

    set_selected_nodes: (node_array) ->
        @selected_nodes = node_array
        @sandbox.set_selected_nodes node_array
        @layers.set_selected_nodes node_array
        @property_editor.set_selected_nodes node_array
