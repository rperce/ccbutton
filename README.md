ccbutton
========

Button API for ComputerCraft

This file goes in `<minecraft_dir>/saves/<world>/computer/<id>/`, where
`<world>` is the world your computer is in and `<id>` is the id of the computer
(running 'id' without quotes on the computer will tell you what that is).

Use this in your program by starting with `os.loadAPI("button")`.

The layout is divided into areas, which contain rows, which contain buttons.
Buttons stretch horizontally to fit their row; rows stretch vertically to fit
their area, and areas must have precisely defined sizes.

Begin by calling `button.open("dir")`, using the same direction you would with
`peripheral.open` to the Advanced Monitor on which these buttons will be
running.  Then add areas, rows, and buttons as below, and finally call
`button.loop()` to being listening for screen-touch events.  Manually redrawing
the screen may be performed by use of `button.draw()`.

Note that all methods below use braces, not parentheses.  In Lua, calling
`method{}` is syntactic sugar for calling `method({})`---and all these methods
expect a single table argument.

Areas
-----
A new area is generated by calling `button.area{[x1, y1, [x2, y2]]}`.  `x1`
and `x2` must be integral numbers: positions on the monitor, starting from (1,1)
in the top-left corner and increasing towards the bottom-right; `x2` and `y2`
may be integers or strings.  If integers, they are takes as literal positions;
if strings, they are taken as relative distances.  Consider the following
examples, where `.` are spots on the monitor and `#` covers the defined area.

    button.area{2, 2, 3, 4}     button.area{2, 2, "3", "4"}
             .....                         .....
             .##..                         .###.
             .##..                         .###.
             .##..                         .###.
             .....                         .###.
             .....                         .....

Numbers may be negative; in that case it is assumed to be an offset from the
right or bottom sides of the monitor.  For example, 
`button.area{5, -1, "10", -1}` creates an area from the fifth column and
last row that is ten columns wide and extends to the last row (which is where it
started, so the area is only one row tall).  Negative relative distance is not
supported.

`x1` and `y1` default to 1; `x2` and `y2` default to -1.  These values will be
used for arguments that are missing or nil.

This method returns an integer id to the created area for use in row adding, as
seen below.

Rows
----
A new row in an area is generated by calling `button.row{[aID]}`.
`aID` is the ID of the area to which you wish to add a row, as returned by the
previous call to `button.area`.  If it is not provided or is invalid, the
last-used area is utilized.  If there is no such area, a new area encompassing
the entire monitor is created and used.  Rows are added in top-down order: a new
row will be below all previously added rows in its area.  Within each area, each
row except the last has one empty line below it for spacing.

This method returns a table containing, in order, the ID of the area the row is
in and the ID of the row in that area for use in button adding, as seen below.

Buttons
-------
A new button in an area is generated by calling `button.new{[rID,] action}`.
`rID` is the table containing area/row IDs to which you wish to add a button, as
returned by the previous call to `button.row`.  If the row part is nil or
otherwise invalid, the last-used row is utilized.  If there is no such row, a
new row in the specified area is created and used.  If no area is specified (or
if the specified area is invalid), a new area encompassing the entire monitor is
created and used.  Buttons are added in left-right order: a new button will be
to the right of previously created buttons in its row.  Within each row, each
button except the last has one blank character after it for spacing.

Alternatively, one may call `button.single{[x1, y1, [x2, y2,]] action}`, which
creates a new area at the specified location using normal area-creation rules,
gives the area a single row, and adds to that row a single button with the
specified action. This does affect what counts as "most recently used" for
adding buttons and rows without specific IDs.

The `action` method passed should return the text of the button (default ""),
the foreground color of the text (default white), and the background color of
the button (default green) in that order. The defaults above will be used for
any return values that are nil or of the incorrect type.
