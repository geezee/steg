module decode;

import std.math : ceil, log2;
import std.algorithm;
import std.experimental.logger;

import bitstream;
import helper;


/**
 * Given a concealed message, this function returns the hidden message inside it
 *
 * Parameters:
 *      concealed       the message in utf-8 containing the hidden message
 *
 * Returns:
 *      a bitstream that contains the bits of the concealed message
*/
Bitstream decode(in string concealed) @safe {
    ushort[] stream = [];
    uint bitdepth = cast(uint) ceil(log2(EQUIV_DCHAR.length));

    foreach(dchar c; concealed) {
        if(c.isSpace) {
            uint n = cast(uint) EQUIV_DCHAR.countUntil(c);
            stream ~= n.dec2binarr(bitdepth);
        }
    }

    return Bitstream(stream, bitdepth);
}
