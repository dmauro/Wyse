##########################################
# Element/Selection Movement with keyboard
##########################################
_nudge_active = (dir, multiplier = 1) ->
    switch dir
        when "up left"
            _nudge_active "up", multiplier
            _nudge_active "left", multiplier
            return
        when "up right"
            _nudge_active "up", multiplier
            _nudge_active "right", multiplier
            return
        when "down left"
            _nudge_active "down", multiplier
            _nudge_active "left", multiplier
            return
        when "down right"
            _nudge_active "down", multiplier
            _nudge_active "right", multiplier
            return
        when "up"
            prop = "top"
            value = -1 * multiplier
            break
        when "down"
            prop = "top"
            value = 1 * multiplier
            break
        when "left"
            prop = "left"
            value = -1 * multiplier
            break
        when "right"
            prop = "left"
            value = 1 * multiplier
            break

    for ele in wyse.property_editor.selection
        ele.adjust_property prop, value
    top_adjust = if prop in ["top", "bottom"] then value else 0
    left_adjust = if prop in ["left", "right"] then value else 0

wyse.wire_element_movement = ->
    nudge_combos = []
    for dir in ["up", "down", "left", "right", "up left", "up right", "down left", "down right"]
        ((dir) ->
            nudge_combos.push(
                keys            : dir,
                on_keydown      : ->
                    _nudge_active dir, 1
                is_exclusive    : true
                prevent_default : true
            )
            nudge_combos.push(
                keys            : "shift " + dir,
                on_keydown      : ->
                    _nudge_active dir, 10
                is_exclusive    : true
                prevent_default : true
            )
        )(dir)
    keypress.register_many nudge_combos
