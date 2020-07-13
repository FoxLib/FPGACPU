if (z80asm mon.asm -o mon.bin) then

    hexdump -ve '/1 "%02x \n"' < mon.bin > mon.hex
    
    php initram.php > ../ram.mif
    
    cd .. && sh make.sh

fi
