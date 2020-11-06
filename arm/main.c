int main() {

    char* m = (char*) 0x10000;

    int i, pc = 0, ext = 0, sg = 0, rn = 1;

    while (rn) {
	
	switch (m[pc++]) {

	    case 0x0F: ext = 1; break;
	    case 0x2e: sg = 1; break;
	    default: rn = 0; break;

	}
    }

    m[1] = ext;
    m[2] = sg;

    return 0;
}