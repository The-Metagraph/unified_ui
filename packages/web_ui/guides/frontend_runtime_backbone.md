# Frontend Runtime Backbone

`WebUi` treats the Elm frontend runtime as a first-class package boundary
instead of as an implementation detail hidden inside the Phoenix side.

During the scaffold phase this means:

- frontend responsibilities have a dedicated namespace
- browser bootstrapping and asset entrypoints stay isolated from canonical model code
- bounded local state remains a frontend concern rather than a package-boundary authority

Later phases will define Elm startup, hydration, browser message handling, and
frontend realization of native and canonical widget state.
