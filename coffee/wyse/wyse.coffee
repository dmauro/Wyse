window.wyse = {}

wyse.default_styles =
    div     :
        padding         : "10px"
        margin          : "50px"
        border          : "5px solid black"
        background      : "#eee"
    button  :
        padding         : "20px 75px"

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
