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
    is.Empty(u.rows)
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
end

function test.button_errors()
    is.Errored("Error: action required.", new)
end
return test
