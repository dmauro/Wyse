################
# CSS Validation
################

############################
# Common Regular Expressions
############################
_color_names = [
    "AliceBlue", "AntiqueWhite", "Aqua", "Aquamarine", "Azure", "Beige", "Bisque", "Black",
    "BlanchedAlmond", "Blue", "BlueViolet", "Brown", "BurlyWood", "CadetBlue", "Chartreuse",
    "Chocolate", "Coral", "CornflowerBlue", "Cornsilk", "Crimson", "Cyan", "DarkBlue",
    "DarkCyan", "DarkGoldenRod", "DarkGray", "DarkGrey", "DarkGreen", "DarkKhaki",
    "DarkMagenta", "DarkOliveGreen", "Darkorange", "DarkOrchid", "DarkRed", "DarkSalmon",
    "DarkSeaGreen", "DarkSlateBlue", "DarkSlateGray", "DarkSlateGrey", "DarkTurquoise",
    "DarkViolet", "DeepPink", "DeepSkyBlue", "DimGray", "DimGrey", "DodgerBlue", "FireBrick",
    "FloralWhite", "ForestGreen", "Fuchsia", "Gainsboro", "GhostWhite", "Gold", "GoldenRod",
    "Gray", "Grey", "Green", "GreenYellow", "HoneyDew", "HotPink", "IndianRed", "Indigo",
    "Ivory", "Khaki", "Lavender", "LavenderBlush", "LawnGreen", "LemonChiffon", "LightBlue",
    "LightCoral", "LightCyan", "LightGoldenRodYellow", "LightGray", "LightGrey", "LightGreen",
    "LightPink", "LightSalmon", "LightSeaGreen", "LightSkyBlue", "LightSlateGray",
    "LightSlateGrey", "LightSteelBlue", "LightYellow", "Lime", "LimeGreen", "Linen",
    "Magenta", "Maroon", "MediumAquaMarine", "MediumBlue", "MediumOrchid", "MediumPurple",
    "MediumSeaGreen", "MediumSlateBlue", "MediumSpringGreen", "MediumTurquoise",
    "MediumVioletRed", "MidnightBlue", "MintCream", "MistyRose", "Moccasin", "NavajoWhite",
    "Navy", "OldLace", "Olive", "OliveDrab", "Orange", "OrangeRed", "Orchid", "PaleGoldenRod",
    "PaleGreen", "PaleTurquoise", "PaleVioletRed", "PapayaWhip", "PeachPuff", "Peru", "Pink",
    "Plum", "PowderBlue", "Purple", "Red", "RosyBrown", "RoyalBlue", "SaddleBrown", "Salmon",
    "SandyBrown", "SeaGreen", "SeaShell", "Sienna", "Silver", "SkyBlue", "SlateBlue",
    "SlateGray", "SlateGrey", "Snow", "SpringGreen", "SteelBlue", "Tan", "Teal", "Thistle",
    "Tomato", "Turquoise", "Violet", "Wheat", "White", "WhiteSmoke", "Yellow", "YellowGreen",
    "transparent", "currentColor"
]
_re_named_color = '(?:'
for color in _color_names
    _re_named_color += (color + '|')
_re_named_color = _re_named_color.slice 0, -1
_re_named_color += ')'
_color_names = null

console.log "RENAMED COLOR", window.named_color = _re_named_color

#_re_positive_int = '\\d+'
#_re_int = '-?' + _re_positive_int
#_re_percentage = '\\d+%'
_re_ascii_string = "(?:\"(?:[\\x20\\x21\\x23-\\x7E]|\\\")*\"|'(?:[\\x20-\\x26\\x28-\\x7E]|\\')*')"
_re_unquoted_ascii_string = "(?:(?:\\[\\x33-\\x40\\x5B-\\x60\\x7B-\\x7E]|[\\x41-\\x5A\\x61-\\x7A])*)"
_re_positive_number = "(?:\\d+|\\d*\\.\\d+)"
_re_number = "-?#{_re_positive_number}"
_re_decimal_percentage = "(?:0|1|0*\\.\\d+)"
_re_positive_length = "(?:0|#{_re_positive_number}(?:em|ex|ch|rem|vh|vw|vmin|vmax|px|mm|cm|in|pt|pc))"
_re_length = "-?#{_re_positive_length}"
_re_angle = "#{_re_number}(?:deg|grad|rad|turn)"
_re_frequency = "#{_re_number}(?:Hz|kHz)"
_re_ratio = "\\d+ */ *\\d+"
_re_resolution = "#{_re_number}(?:dpi|dpcm|dppx)"
_re_position = "(?:(?:left|center|right|top|bottom|\\d+%|#{_re_length})|(?:left|center|right|\\d+%|#{_re_length}) +(?:top|center|bottom|\\d+%|#{_re_length})|(?:center|(?:left|right)(?: +\\d+%|#{_re_length})?) +(?:center|(?:top|bottom)(?: +\\d+%|#{_re_length})?))"

_re_hex_color = "(?:#(?:[A-Fa-f0-9]{6}|[A-Fa-f0-9]{3}))"
_re_hsl_color = "hsl\\(\\d{1,3}, *\\d+%, *\\d+%\\)"
_re_hsla_color = "hsla\\(\\d{1,3}, *\\d+%, *\\d+%, *#{_re_decimal_percentage}\\)"
_re_rgb_color = "rgb\\(\\d{1,3}, *\\d{1,3}, *\\d{1,3}\\)"
_re_rgba_color = "rgba\\(\\d{1,3}, *\\d{1,3}, *\\d{1,3}, *#{_re_decimal_percentage}\\)"
_re_color = "(?:#{_re_named_color}|#{_re_hsl_color}|#{_re_hsla_color}|#{_re_rgb_color}|#{_re_rgba_color}|#{_re_hex_color})"
_re_color_stop = "#{_re_color} (?:#{_re_length}|\\d+%)"
_re_color_stop_list = "#{_re_color_stop}(?:, *#{_re_color_stop})"
_re_extent_keyword = "(?:closest-corner|closest-side|farthest-corner|farthest-side)"
_re_linear_gradient = "(?:repeating-)?linear-gradient\\((?:#{_re_angle}|to (?:side|corner), *)?#{_re_color_stop_list}\\)"
_re_radial_gradient = "(?:repeating-)?radial-gradient\\((?:(?:(?:circle|#{_re_length})(?: +at +#{_re_position})?|(?:ellipse|(?:\\d+%|#{_re_length} *){2})(?: +at +#{_re_position})?|(?:(?:circle|ellipse)|#{_re_extent_keyword})(?: +at +#{_re_position})?)|at +#{_re_position}), +#{_re_color_stop_list}\\)"

_re_uri = "url\\([-a-zA-Z0-9@:%_\\+.~#?&//=]+\\)"
_re_image = "(?:#{_re_uri}|#{_re_linear_gradient}|#{_re_radial_gradient})"

_re_shape = "rect\\((?:#{_re_length}, *){3}#{_re_length}\\)"
_re_timing_function = "cubic-bezier\\((?:-?#{_re_decimal_percentage}|#{_re_positive_number})(?:, *-?#{_re_decimal_percentage}){3}\\)"
_re_user_ident = "(?:[a-zA-Z]|\\\\[a-zA-Z0-9]{1, 4} +[a-zA-Z0-9]+|-|_){1}(?:[a-zA-Z0-9]|\\\\.)*"
_re_content_sizing = "(?:border-box|padding-box|content-box)"
_re_attachment = "(?:scroll|fixed|local)"
_re_repeat_style = "(?:(?:repeat-x|repeat-y|repeat|space|round|no-repeat)|(?:(?:repeat|space|round|no-repeat) *){2})"
_re_image_or_none = "(?:none|#{_re_image})"
_re_bg_color = "(?:#{_re_color}|inherit)"
_re_bg_size = "(?:(?:contain|cover)|(?:\\d+%|#{_re_positive_length}|auto)(?: +\\d+%|#{_re_positive_length}|auto)?)"
_re_border_width = "(?:#{_re_positive_length}|thin|medium|thick)"
_re_border_style = "(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)"
_re_border_image_outset = "(?:(?:#{_re_length} *|\\d+% *){1,4}|inherit)"
_re_border_image_repeat = "(?:(?:(?:stretch|repeat|round|space) *){1,2}|inherit)"
_re_border_image_slice = "(?:(?:(?:#{_re_positive_number}|\\d+%)(?: *fill)?){1,4}|inherit)"
_re_border_image_source = "(?:#{_re_image_or_none}|inherit)"
_re_border_image_width = "(?:(?:(?:#{_re_positive_length}|\\d+%|#{_re_positive_number}|auto) *){1,4}|inherit)"
_re_font_family_name_single = "(?:#{_re_ascii_string}|#{_re_unquoted_ascii_string})"
_re_font_family_name = "(?:#{_re_font_family_name_single}(?:, *#{_re_font_family_name_single})*)"
_re_font_size = "(?:xx-small|x-small|small|medium|large|x-large|xx-large|smaller|larger|#{_re_positive_length}|\\d+%|inherit)"
_re_box_shadow_standard = "(?:(?:inset *)?#{_re_length} *#{_re_length}(?: #{_re_positive_length}*)?(?: *#{_re_length})?(?: *#{_re_color})?)"
_re_box_shadow_backwards = "(?:(?:#{_re_color} *)?#{_re_length} *#{_re_length}(?: #{_re_positive_length}*)?(?: *#{_re_length})?(?: *inset)?)"
_re_box_shadow = "(?:#{_re_box_shadow_standard}|#{_re_box_shadow_backwards})"
_re_text_shadow = "(?:(?:#{_re_color} *)?#{_re_length} *#{_re_length}(?: *#{_re_positive_length})?|#{_re_length} *#{_re_length}(?: *#{_re_positive_length})?(?: *#{_re_color})?)"
_re_font_style = "(?:normal|italic|oblique|inherit)"
_re_font_weight = "(?:normal|bold|bolder|lighter|[1-9]00|inherit)"
_re_font_variant = "(?:normal|small-caps|inherit)"
_re_line_height = "(?:normal|#{_re_number}|#{_re_length}|\\d+%)"
_re_feature_tag_value = "(?:#{_re_ascii_string}(?: *(?:\\d+|on|off))?)"

# Shared exact matches
_re_int_exact = "^\\d+$"
_re_color_exact = "^#{_re_color}$"
_re_length_exact = "^auto|inherit|#{_re_length}|\\d+%$"
# DO IT THE COFFESCRIPT WAY
_re_bg_repeat_exact = "^#{_re_repeat_style}(?:, *#{_re_repeat_style})*$"
_re_bg_position_exact = "^#{_re_position}(?:, *#{_re_position})*$"
_re_bg_clip_exact = "^#{_re_content_sizing}(?:, *#{_re_content_sizing})*$"
_re_bg_attachment_exact = "^#{_re_attachment}(?:, *#{_re_attachment})*$"
_re_bg_image_exact = "^#{_re_image_or_none}(?:, *#{_re_image_or_none})*$"
_re_bg_size_exact = "^#{_re_bg_size}(?:, *#{_re_bg_size})*$"
_re_border_color_exact = "^#{_re_color}|inherit$"
_re_border_style_exact = "^#{_re_border_style}|inherit$"
_re_border_width_exact = "^#{_re_border_width}$"
_re_margin_exact = "^#{_re_length}|\\d+%|inherit|auto$"
_re_padding_exact = "^#{_re_positive_length}|\\d+%|inherit$"
_re_overflow_exact = "^visible|hidden|scroll|auto$"

# Complex shorthand matches
_fun_background = (value) ->
    # Split into layers
    layers = value.split ","
    i = 0
    for layer in layers
        # Remove trailing spaces
        layer = layer.replace new RegExp(" *$"), ""
        is_final_layer = i is layers.length - 1

        # Make sure only the final layer has a bg color
        bg_color = layer.match new RegExp(_re_bg_color, "i")
        if bg_color and !is_final_layer
            console.log "Background layers cannot have a color unless they are the final layer."
            return false

        # Remove all the options (which can be in any order) and make sure nothing is left
        layer = layer.replace new RegExp(_re_bg_color, "i"), ""
        layer = layer.replace new RegExp(_re_image_or_none, "i"), ""
        layer = layer.replace new RegExp("(?:#{_re_position}(?: */ *#{_re_bg_size})?)", "i"), ""
        layer = layer.replace new RegExp(_re_repeat_style, "i"), ""
        layer = layer.replace new RegExp(_re_attachment, "i"), ""
        layer = layer.replace new RegExp("(?:#{_re_content_sizing} *){1,2}", "i"), ""
        # Remove spaces again
        layer = layer.replace new RegExp(" *$"), ""
        if layer.length
            console.log "\"#{value}\" is not a valid background value"
            return false
        i++
    return true

_fun_border_image = (value) ->
    # Strip out the parts that match and make sure nothing is left
    value = value.replace new RegExp(_re_border_image_source, "i"), ""
    value = value.replace new RegExp(_re_border_image_slice + "(?:(?: */ #{_re_border_image_width}*)|(?:#{_re_border_image_width})? */ *#{_re_border_image_outset})?", "i"), ""
    value = value.replace new RegExp(_re_border_image_repeat, "i"), ""
    value = value.replace new RegExp(" *$"), ""
    if value.length
        console.log "\"#{value}\" is not a valid border-image value"
        return false
    return true

_fun_border = (value) ->
    # For the border and border(-top|-bottom|-left|-right) shorthands
    # Strip out the parts that match and make sure nothing is left
    value = value.replace new RegExp(_re_border_width, "i"), ""
    value = value.replace new RegExp(_re_border_style, "i"), ""
    value = value.replace new RegExp(_re_color, "i"), ""
    value = value.replace new RegExp(" *$"), ""
    if value.length
        console.log "\"#{value}\" is not a valid border value"
        return false
    return true

_fun_font = (value) ->
    value = value.replace new RegExp(_re_font_style, "i"), ""
    value = value.replace new RegExp(_re_font_variant, "i"), ""
    value = value.replace new RegExp(_re_font_weight, "i"), ""
    value = value.replace new RegExp("(^ *)( *$)"), ""
    unless value.match new RegExp("#{_re_font_size}(?: */ *#{_re_line_height})? *#{_re_font_family_name}")
        console.log "\"#{value}\" is not a valid font value"
        return false
    return true

_property_checks =
    'width'                 : "^available|min-content|max-content|fit-content|auto|(?:(?:#{_re_length}|\\d+%)(?: border-box| content-box)?)$"
    'height'                : _re_length_exact
    'left'                  : _re_length_exact
    'right'                 : _re_length_exact
    'top'                   : _re_length_exact
    'bottom'                : _re_length_exact
    'background'            : _fun_background
    'background_attachment' : _re_bg_attachment_exact
    'background-clip'       : _re_bg_clip_exact
    'background-color'      : "^#{_re_bg_color}$"
    'background-image'      : _re_bg_image_exact
    'background-origin'     : _re_bg_clip_exact
    'background-position'   : _re_bg_position_exact
    'background-repeat'     : _re_bg_repeat_exact
    'background-size'       : _re_bg_size_exact
    'border'                : _fun_border
    'border-top'            : _fun_border
    'border-right'          : _fun_border
    'border-bottom'         : _fun_border
    'border-left'           : _fun_border
    'border-image'          : _fun_border_image
    'border-image-outset'   : "^#{_re_border_image_outset}$"
    'border-image-repeat'   : "^#{_re_border_image_repeat}$"
    'border-image-source'   : "^#{_re_border_image_source}$"
    'border-image-width'    : "^#{_re_border_image_width}$"
    'border-color'          : "^(?:#{_re_color} *){1,4}|inherit$"
    'border-top-color'      : _re_border_color_exact
    'border-right-color'    : _re_border_color_exact
    'border-bottom-color'   : _re_border_color_exact
    'border-left-color'     : _re_border_color_exact
    'border-style'          : "^(?:#{_re_border_style} *){1,4}|inherit$"
    'border-top-style'      : _re_border_style_exact
    'border-right-style'    : _re_border_style_exact
    'border-bottom-style'   : _re_border_style_exact
    'border-left-style'     : _re_border_style_exact
    'border-width'          : "^(?:#{_re_border_width} *){1,4}|inherit$"
    'border-top-width'      : _re_border_width_exact
    'border-right-width'    : _re_border_width_exact
    'border-bottom-width'   : _re_border_width_exact
    'border-left-width'     : _re_border_width_exact
    'border-radius'         : "^(?:(?:#{_re_length}|\\d+%) *){1,4}(?: */ *(?:(?:#{_re_length}|\\d+%) *){1,4})?$"
    'font'                  : _fun_font
    'font-family'           : "^#{_re_font_family_name}$"
    'font-feature-settings' : "^normal|#{_re_feature_tag_value}(?:, *#{_re_feature_tag_value})*$"
    'font-size'             : "^#{_re_font_size}$"
    'font-size-adjust'      : "^#{_re_number}|none|inherit$"
    'font-stretch'          : "^inherit|ultra-condensed|extra-condensed|condensed|semi-condensed|normal|semi-expaded|expanded|extra-expanded|ultra-expanded$"
    'font-style'            : "^#{_re_font_style}$"
    'font-variant'          : "^#{_re_font_variant}$"
    'font-weight'           : "^#{_re_font_weight}$"
    'line-height'           : "^#{_re_line_height}$"
    'letter-spacing'        : "^normal|#{_re_length}$"
    'box-shadow'            : "^none|#{_re_box_shadow}(?:, *#{_re_box_shadow})*$"
    'text-shadow'           : "^none|#{_re_text_shadow}(?:, *#{_re_text_shadow})*$"
    'display'               : '^inherit|none|inline|block|list-item|inline-block|inline-table|table|table-caption|table-cell|table-column|table-column-group|table-footer-group|table-header-group|table-row|table-row-group|$'
    'position'              : '^static|relative|absolute|fixed|inherit$'
    'box-sizing'            : "^#{_re_content_sizing}$"
    'float'                 : '^left|right|none|inherit$'
    'clear'                 : '^none|left|right|both|inherit$'
    'margin'                : "^(?:(?:#{_re_length}|\\d+%) *){1,4}|inherit|auto$"
    'margin-top'            : _re_margin_exact
    'margin-right'          : _re_margin_exact
    'margin-bottom'         : _re_margin_exact
    'margin-left'           : _re_margin_exact
    'padding'               : "^(?:(?:#{_re_positive_length}|\\d+%) *){1,4}$"
    'padding-top'           : _re_padding_exact
    'padding-right'         : _re_padding_exact
    'padding-bottom'        : _re_padding_exact
    'padding-left'          : _re_padding_exact
    'overflow'              : "^visible|hidden|scroll|auto|inherit$"
    'overflow-x'            : _re_overflow_exact
    'overflow-y'            : _re_overflow_exact
    'pointer-events'        : "^auto|none|visiblePainted|visibleFill|visibleStroke|visible|painted|fill|stroke|all|inherit$"
    'text-align'            : "^left|right|center|justify$"
    'opacity'               : "^#{_re_decimal_percentage}$"
    'z-index'               : _re_int_exact

##################
# Validation Class
##################

class wyse.CSSValidator
    validate_pair: (property, value) ->
        test = _property_checks[property]
        unless test
            console.log "Don't recognize the property #{property}"
            return false
        if typeof test is "function"
            return test(value)
        else
            return true if new RegExp(test, "i").test value
        console.log "Value \"#{value}\" is not valid for property \"#{property}\""
        return false
