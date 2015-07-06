module helper;

import std.algorithm;
import std.array;
import std.experimental.logger;

/**
 * The map of characters that are all equivalent in UTF-8
 * all of these are single spaces (or look like one)
*/
immutable enum dchar[] EQUIV_DCHAR = [
    cast(dchar) 32,   cast(dchar) 160,  cast(dchar) 8195, cast(dchar) 8194,
    cast(dchar) 8192, cast(dchar) 8196, cast(dchar) 8197, cast(dchar) 8200
];

/**
 * Given a character, check whether this character is a single space, i.e.
 * if it's in MAP
 *
 * Parameters:
 *      c       the character to check
 *
 * Returns:
 *      c \in MAP
*/
pure bool isSpace(in dchar c) @safe {
    return EQUIV_DCHAR.canFind(c);
}

unittest {
    import std.random;

    foreach(c; EQUIV_DCHAR) {
        assert(c.isSpace);
    }
    
    foreach(d; 0..100) {
        dchar c = cast(dchar) uniform(0, 100000);
        bool found = false;
        for(int i=0;i<EQUIV_DCHAR.length;i++) {
            found = found || (EQUIV_DCHAR[i] == c);
            if(found) break;
        }
        assert(c.isSpace == found);
    }
}

/**
 * Given an array of numbers, assuming these are 0s and 1s, it finds their
 * decimal number representation
 *
 * Parameters:
 *      arr         the array of 0s and 1s
 *
 * Returns:
 *      \sum_i arr[i]*2^(arr.length-i-1)
*/
uint binarr2dec(in ushort[] arr) @safe
in {
    warning(!(arr.length <= 32), "There might be an overflow");
}
body {
    uint n = 0;
    foreach(ushort i; arr) {
        n = n*2 + i;
    }
    return n;
}

/**
 * Given a number in decimal, assuming it is positive, and a bitdepth, this
 * function will find the least bitdepth significant bits of the binary expansion
 * of the number
 *
 * Parameters:
 *      n           the number to find its binary digits
 *      bitdepth    the number of bits to find
 *
 * Returns:
 *      [a_n, ..., a_0] where a_n*2^n + ... +a_0 = n % 2^bitdepth
*/
pure ushort[] dec2binarr(in uint n, in uint bitdepth) @safe {
    ushort[] binarr = [cast(ushort) 0].replicate(bitdepth);
    for(int i=0;i<bitdepth;i++) {
        binarr[$-i-1] = (n >> i) % 2;
    }
    return binarr;
}

unittest {
    import std.random;

    foreach(_; 0..100000) {
        uint c = uniform(0, uint.max);
        assert(c.dec2binarr(32).binarr2dec == c);
    }
}

/**
 * Find the minimum of two longs
 *
 * Returns:
 *      a if a < b, else b
*/
pure ulong min(in ulong a, in ulong b) @safe {
    return (a < b)*(a - b) + b;
}

unittest {
    import std.random;

    foreach(_; 0..100000) {
        ulong a = uniform(0, ulong.max);
        ulong b = uniform(0, ulong.max);
        assert(min(a, b) == ((a > b) ? b : a));
    }
}
