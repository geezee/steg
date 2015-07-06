module encode;

import std.stdio;
import std.math;
import std.string;
import std.experimental.logger;

import bitstream;
import helper;


/**
 * Given a message and a cover, encode the message inside the cover
 *
 * Parameters:
 *      message         the secret message to hide
 *      cover           the cover message
 *      ignoreWarning   whether to throw an exception if the cover's capacity
 *                      is lower than the needed
 *
 * Returns:
 *      the new version of the cover that embeds the secret message as UTF-8
 *      string
 *
 * Throws:
 *      Exception, if ignoreWarning is false and the capacity of the cover is
 *      smaller than the length of the message as a bitstream. The capacity of
 *      the cover is defined to be the number of characters that can be substituted
 *      times how much information this character can encode.
*/
string encode(in string message, in string cover, in bool ignoreWarning=true) {
    Bitstream s = Bitstream(message, cast(uint) ceil(log2(EQUIV_DCHAR.length)));

    // make sure that the cover has enough space
    ulong coverCapacity = 0,
          messageLength = s.length;
    foreach(char c; cover) {
        if(c.isSpace) coverCapacity++;
    }
    if(coverCapacity < messageLength) {
        warning("[WARNING]: The cover does not contain enough information");
        warningf("           Cover capacity: %d", coverCapacity);
        warningf("           Required:       %d", messageLength);
    }

    // Construct the concealed message
    string concealed;
    foreach(i, char c; cover) {
        if(c.isSpace) {
            if(s.empty) {
                concealed ~= EQUIV_DCHAR[0];
            } else {
                concealed ~= EQUIV_DCHAR[binarr2dec(s.front)];
                s.popFront();
            }
        } else {
            concealed ~= c;
        }
    }

    foreach(ushort[] arr; s) {
        concealed ~= EQUIV_DCHAR[binarr2dec(arr)];
    }

    return concealed;
}
