macro   brk { xchg bx, bx }

macro invoke proc {
    call proc
}

macro invoke proc, [arg] {

    reverse
        push arg
    common
        call proc
}

