cols = 40

function map f, list
    res = []
    for itm in list
        res.push f(itm)
    return res

function any list
    for elem in list
        if elem
            return true
    return false

function wcswidth text
    return text.length

function wrap line
    if wcswidth(line) <= cols
        return [line]
    else
        pat = /\s+/g
        prev = 0
        while (m = pat.exec line)
            cur = m.index + m[0].length
            curw = wcswidth(line.substr 0, cur)
            if curw > cols
                break
            else
                prev = cur
        rest = wrap(line.substr prev)
        return [line.substr(0, prev)].concat rest

function tx-process text
    lines = text.split '\n'
    toobig = (line) -> wcswidth(line) > cols
    autowrap = any(map toobig, lines)
    reallines = []

    if autowrap
        for paragraph in text.split /[\t \v\f\r]*(?:\n[\t \v\f\r]*)+/
            Array::push.apply(reallines, wrap paragraph)
            reallines.push ''
    else
        for line in lines
            Array::push.apply(reallines, wrap line)
    return reallines


$ ->
    position = 0
    base-position = 0
    reference-time = 0
    speed = 0
    default-speed = 0.6

    scr = $ \#script 
    orig-text = ""

    skip-to = (line) ->
        base-position := line
        position := base-position
        reference-time := performance.now!
        if speed == 0
            set-speed 1
            set-speed 0


    set-speed = (spd) ->
        need-upd = speed == 0
        speed := spd
        base-position := position
        reference-time := performance.now!
        if speed != 0 and need-upd
            update!

    set-default-speed = (spd) ->
        default-speed := spd
        $(\#gauge).css height: "#{10 * default-speed * 1.2}em"
        if speed != 0
            set-speed default-speed
    set-default-speed 0.6
    
    update = ->
        if speed != 0
            scr.css will-change: "transform"
            now = performance.now!
            position := base-position + speed * (now - reference-time) / 1000
            scr.css transform: "translateY(#{-position*1.2}em)"
            requestAnimationFrame update
        else
            scr.css will-change: ""
    reload = ->
        scr.html ''
        for line in tx-process orig-text
            scr.append $('<div></div>').addClass(\scriptrow).text(line)

    $ \#reset .click ->
        skip-to 0

    $ \#faster .click ->
        set-speed(if speed == 0 then default-speed else 0)
        console.log "Set speed to #{speed}"

    $ \#settext .click ->
        $ \#pastebox .addClass \pb-active
        $ \#nowset .removeClass \hiddenbutton

    $ \#nowset .click ->
        set-speed 0
        orig-text := $(\#pastebox).val!
        reload!
        $ \#pastebox .val ''
        $ \#pastebox .removeClass \pb-active
        $ \#nowset .addClass \hiddenbutton

    $ \#slower .click ->
        set-default-speed(default-speed + 0.05)

    $ \#flower .click ->
        set-default-speed(default-speed - 0.05)
