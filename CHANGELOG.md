# Changelog

## [v2.1.0] - 2021-03-29

New features:

- Controls and Options

Changes:

- deltaTime: now the `update` function can accept a optionally parameter `dt` that represents the time difference between two consecutive frames.

- `onevent` for multiple widgets: now its possible to set the same event callback for multiple widgets with just one call to the `onevent` function.

## [v2.0.0] - 2021-03-16

Mos of the interface was recreated, but remains almost the same. The most significant differences are the following:

- The `createCanvas` function was removed, now use the `init` function or the `@init` macro.
- The `loop!` function does not exist anymore, now use the `start` (without any arguments) instead.
- Instead of passing each function (setup and update) as arguments to the previous `loop!` function, you now use the `@use` macro in those function declarations.
- There are no events functions anymore, like `onmousemotion!` or `onkeypress!`, now, each event can be attactched to the application by using the `@use` macro.
- The `key` function was renamed to `keyboard`.
- The `on!` function was renamed to `onevent`.

Features in this release:

- More GtkWidgets supported
- Concise and extensible layout system
- The `loadsprite` and `drawsprite` image allows you to draw and resize images without the 'blurry' effect.
- SVG path utilities: the `getpoints` function allows you to convert an SVG Path data string into a list of points
- New macros: `@framerate` returns you the current framerate; `@framecount` returns you the number of the current frame.
- The `Grid` widget now supports cells that spans multiple rows and columns, nos just rows or columns.
- New helper macros:`@spacing`, `@expand`, `@homogeneous` and `@on`.

Bugs fixed

- Many bugs fixed
- Now the *keypress* event is only fired when the canvas is focused
- The FPS remains the same, even when the window is resized