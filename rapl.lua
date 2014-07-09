local function deepcompare(t1,t2)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end

    if ty1 ~= 'table' then return t1 == t2 end

    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not deepcompare(v1,v2) then return false end
    end
    return true
end
if debug.getinfo(3) then
    t = {}
    local function err(str)
        local strout = "Expected "..str
        local short_src = debug.getinfo(3, 'S').short_src
        local i = 3
        local bug = debug.getinfo(i+1, 'Sl')
        while bug.short_src == short_src do
            strout = strout.."\n\t(via "..bug.short_src..":"..bug.currentline..")"
            i = i + 1
            bug = debug.getinfo(i+1, 'Sl')
        end
        error(strout, 3)
    end
    function t.Equal(exp, is)
        if is ~= exp then
            err(tostring(exp)..", was "..tostring(is))
    end end
    function t.NotEqual(nexp, is)
        if is == exp then
            err("not "..tostring(nexp))
    end end
    function t.Same(exp, is)
        if not deepcompare(exp, is) then
            err(tostring(exp)..", was "..tostring(is))
    end end
    function t.NotSame(nexp, is)
        if deepcompare(exp, is) then
            err("not "..tostring(nexp))
    end end
    function t.NotNil(is)
        if not is then
            err("not nil")
    end end
    function t.Nil(is)
        if is then
            err("nil")
    end end
    function t.Empty(table)
        local ct = 0
        for _,__ in pairs(table) do ct = ct + 1 end
        if ct ~= 0 then
            err("empty table, has "..ct.." items")
    end end
    function t.Sized(n, table)
        local ct = 0
        for _,__ in pairs(table) do ct = ct + 1 end
        if ct ~= n then 
            err(n.." items, found "..ct)
    end end
    function t.Errored(str, fn, ...)
        local s, e = pcall(fn, ...)
        if s then
            err("error \""..str.."\"; no error")
        elseif not e:find(str) then
            err("error \""..str.."\"; got \""..e.."\"")
    end end
    return t
else
    local args = {...}
    local function reset() return '\27[00m' end
    local function red(str) return '\27[1;31m'..str..reset() end
    local function green(str) return '\27[0;32m'..str..reset() end
    if #args == 0 then
        print(red("Please provide files to test"))
        os.exit()
    end

    local suites = {}
    local before = nil
    for i, file in ipairs(args) do
        if file:find(".lua") then
            file = file:sub(1, file:find(".lua")-1)
        end
        local t = require(file)
        if not(type(t) == "table") then
            print(red("Please ensure test files return a table of methods"))
            os.exit()
        end

        local names = {}
        for n, _ in pairs(t) do
            if n ~= "before" then
                table.insert(names, n)
            end
        end
        table.sort(names)
        table.insert(suites, {names, t})


        if t.before then
            if type(t.before) == "function" then
                before = t.before
                t.before = nil
            end
        end
    end

    local o = {}
    local pass = 0
    local fail = 0
    local time = os.clock()
    for _, file in ipairs(suites) do
        local names, t = file[1], file[2]
        for _,m in ipairs(names) do
            local s=true, e
            if before then s, e = pcall(before) end
            if s then s, e = pcall(t[m]) end
            if s then
                io.write(green('.'))
                pass = pass + 1
            else
                io.write(red('E'))
                table.insert(o, e)
                fail = fail + 1
            end
        end
    end
    time = (os.clock() - time) * 1000
    print()
    table.sort(o, function(a, b)
        local file = {a:sub(1, a:find(':')-1), b:sub(1, b:find(':')-1)}
        if file[1] == file[2] then
            local a1, a2 = a:find(':.+:')
            local b1, b2 = b:find(':.+:')
            return tonumber(a:sub(a1+1, a2-1)) < tonumber(b:sub(b1+1, b2-1))
        end
        return a < b
    end)
    for _,m in pairs(o) do
        print(m)
    end

    print()
    print("Tests: "..(pass+fail).." ("..green(pass).."/"..red(fail)..")")
    print("Time elapsed: "..time.."ms")
end
