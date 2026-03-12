# Used by "mix format"
[
  import_deps: [:spark],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # Spark DSL entities (will be populated as we define them)
    ui: 1,
    # Widgets
    text: 1,
    button: 1,
    label: 1,
    text_input: 1,
    # Layouts
    vbox: 1,
    hbox: 1,
    # Styles
    style: 1
  ]
]
