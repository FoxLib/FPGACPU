
        ldir

        ld      a, ($0001)
        ldir
        res     3, a
        ld      i, a
        ld      a, r
        di
        
        out     (c), a 
        in      b, (c)

        exx
        ld      (ix-2), a

aa:
        ex      af, af'
        djnz    aa
        ld      a, h
        add     8
        ld      h, a
        cp      $58
        jp      nz, aa
