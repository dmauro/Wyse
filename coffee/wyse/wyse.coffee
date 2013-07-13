window.wyse = {}

wyse.default_styles =
    div     :
        padding         : "10px"
        border          : "1px solid black"
        background      : "#eee"

wyse.cannot_contain_blocks_tags = [
    "p"
]

wyse.inline_tags = [
    "button"
    "span"
]

# Ready the DOM
$(->
    manager = new wyse.NodeManager "wyse"
    document.body.appendChild manager.element
    manager.bind()
)
