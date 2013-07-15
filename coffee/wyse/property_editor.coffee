class wyse.PropertyEditor
    constructor: (@id_name) ->
        @element = crel 'div', { id : @id_name },
            crel('textarea', { class : "styles" }),
            crel 'button', { class : "update_styles" }, "Update Styles"
        @node_style_updated_handler = ->
        @validate_css_pair_handler = ->

    bind: ->
        $("##{@id_name} button.update_styles").on "click", =>
            @update_styles()

    update_styles: ->
        text = $("##{@id_name} textarea.styles").val()

        # Remove unecessary whitespace
        text = text.replace new RegExp('\\s*:\\s*', 'g'), ":"
        text = text.replace new RegExp('\\s*;\\s*', 'g'), ";"

        # Split into pairs
        pairs = text.split ';'
        pairs.splice -1, 1
        syles = null
        for pair in pairs
            pair = pair.split ':'
            result = @validate_css_pair_handler pair[0], pair[1]
            if result
                styles = styles or {}
                styles[pair[0]] = pair[1]
        if styles
            @node_style_updated_handler styles

    set_selected_nodes: (node_array) ->
        # Get common styles and display
