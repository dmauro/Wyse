$('#tools button').click ->
    new wyse.Element "div"

$('#editor button.clone').click ->
    selection = wyse.property_editor.selection.slice()
    new_selection = []
    for ele in selection
        new_selection.push ele.clone()
    for ele in new_selection
        ele.select()

$('#editor button.update_css').click wyse.update_css

$(->
    wyse.wire()

    $('#editor input')
    .focus(keypress.stop_listening)
    .blur(keypress.listen)
)
