# Server Runtime Backbone

`WebUi` keeps Phoenix-side runtime authority explicit from the beginning.

During the scaffold phase this means:

- the server runtime has its own namespace and entry module
- server responsibilities stay separate from frontend rendering concerns
- canonical renderer and transport code do not own server runtime state

Later phases will define mount behavior, state coordination, browser
synchronization, and canonical event handling in this area.
