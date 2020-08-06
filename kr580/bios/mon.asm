
aa:
        ld      a, h
        add     8
        ld      h, a
        cp      $58
        jp      nz, aa
