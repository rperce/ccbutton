require('button')
is = require('rapl')
test = {}
function test.before()
    reset()
end
local function test_table(n, i, a, b, c, d)
    is.Sized(n, button_areas)
    is.NotNil(button_areas[i])
    local u = button_areas[i]
    is.Equal(a, u.x1)
    is.Equal(b, u.y1)
    is.Equal(c, u.x2)
    is.Equal(d, u.y2)
end
function test.area_errors()
    is.Errored("Error: call with area{}, not area().", area, 1)
end
function test.area_all_default_none()
    local i=area()
    is.Equal(1, i)
    test_table(1, 1, 1, 1, -1, -1)
end
function test.area_all_default_table()
    local i = area{}
    is.Equal(1, i)
    test_table(1, 1, 1, 1, -1, -1)
end
function test.area_vals()
    local i = area{2, 3, 4, 5}
    is.Equal(1, i)
    test_table(1, 1, 2, 3, 4, 5)
end
function test.multiple_area_ids()
    local i = area()
    is.Equal(1, i)
    i = area()
    is.Equal(2, i)
end
function test.add_couple_areas()
    area() area() area() area()
    local i = area()
    is.Equal(5, i)
end

function test.row_errors()
    is.Errored("Error: call with row{}, not row().", row, 1)
end
function test.row_makes_area()
    local i = row()
    is.NotNil(last_area)
    is.Equal(1, last_area)
    is.Same({1, 1}, i)
    is.Sized(1, button_areas[last_area].rows)
    is.Empty(button_areas[last_area].rows[1])
end
function test.row_to_specific_area()
    area() local i = area()
    row{i}
    is.Empty(button_areas[1].rows)
    is.Sized(1, button_areas[2].rows)
    is.Same({}, button_areas[2].rows[1])
end

function test.new_errors()
    is.Errored("Error: call with new{}, not new().", new, 1)
    is.Errored("Error: action required.", new)
    is.Errored("Error: action required.", new, {{1, 1}})
    is.Errored("Error: first arg must be table or function.", new, {1, function() end})
end
function test.uses_last_area()
    area() area()
    new{function() return "pass" end}
    is.Sized(0, button_areas[1].rows)
    is.Sized(1, button_areas[2].rows)
    is.Sized(1, button_areas[2].rows[1])
    is.Equal("pass", button_areas[2].rows[1][1].action());
end
function test.uses_last_row()
    area() local i=area() row{i} row{i}
    new{function() return "pass" end}
    is.Sized(0, button_areas[2].rows[1])
    is.Sized(1, button_areas[2].rows[2])
    is.Equal("pass", button_areas[2].rows[2][1].action())
end
function test.uses_specific_row()
    area() local i=area() row{i} row{i} row{i}
    new{{nil, 2}, function() return "pass" end}
    is.Sized(0, button_areas[2].rows[1])
    is.Sized(1, button_areas[2].rows[2])
    is.Sized(0, button_areas[2].rows[3])
    is.Equal("pass", button_areas[2].rows[2][1].action())
end
function test.uses_specific_row_and_area()
    area() local i=row() row() area() row() row()
    is.Same({1, 1}, i)
    new{i, function() return "pass" end}
    is.Sized(1, button_areas[1].rows[1])
    is.Sized(0, button_areas[1].rows[2])
    is.Sized(0, button_areas[2].rows[1])
    is.Sized(0, button_areas[2].rows[2])
    is.Equal("pass", button_areas[1].rows[1][1].action())
end

function test.single_errors()
    is.Errored("Error: call with single{}, not single()", single, 1)
    is.Errored("Error: last argument to single must be function.", single)
end
function test.single_default_area()
    single{function() return "pass" end}
    test_table(1, 1, 1, 1, -1, -1)
    is.Equal("pass", button_areas[1].rows[1][1].action())
end
function test.single_explicit_area()
    single{2, 3, "4", "5", function() return "pass" end}
    test_table(1, 1, 2, 3, "4", "5")
    is.Equal("pass", button_areas[1].rows[1][1].action())
end

return test
