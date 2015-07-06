module bitstream;

import std.array;
import std.math : log2, ceil;
import std.experimental.logger;

import helper;


/**
 * Implementation of a bitstream that is accessed through chunks
*/
struct Bitstream {
    private ushort[] stream;
    private ulong cursor;
    private uint bitdepth;

    /**
     * Convert a string to an array of bits, 0s and 1s
     *
     * Parameters:
     *      s           the string to convert
     *
     * Returns:
     *      an array of bits representing the string
     *
     * Postcondition:
     *      The resulting stream should have a length that is a multiple of 8
    */
    private ushort[] toStream(in string s) @safe
    out(stream) {
        fatal(!(stream.length % 8 == 0), "Error occured when converting string to a bit stream");
    }
    body {
        ushort[] stream = [];
        foreach(char c; s) {
            stream ~= dec2binarr(c, 8);
        }
        return stream;
    }

    /**
     * Constructor from a string
     *
     * Parameters:
     *      s           the bitstream whose origin is the string s
     *      bitdepth    the size of the chunks that the stream will output > 0
     *
     * Precondition:
     *      the string must not have a length of 0
    */
    this(in string s, in uint bitdepth) @safe
    in {
        warning(!(s.length > 0), "The string passed is empty");
    }
    body {
        this.stream = this.toStream(s);
        this.bitdepth = bitdepth;
        this.cursor = 0;
    }

    /**
     * Constructor from an array of bits
     *
     * Parameters:
     *      arr         an array of 0s and 1s to convert into a bitstream
     *      bitdepth    the size of the chunks that the stream will output > 0
     *
     * Precondition:
     *      the array must not have a length of 0
    */
    this(in ushort[] arr, in uint bitdepth) @safe
    in {
        warning(!(arr.length > 0), "The length of the array passed is empty");
    }
    body {
        this.stream = arr.dup;
        this.bitdepth = bitdepth;
        this.cursor = 0;
    }

    /**
     * At all the time the following invariants must always hold:
     *
     * - the bitdepth is a strict positive number
     * - all the numbers in the stream must be either 0 or 1
    */
    invariant {
        fatalf(!(this.bitdepth > 0), "The bitdepth of the bitstream must be larger than 0");
        int i=0;
        foreach(ushort c; stream) {
            fatalf(!(c == 0 || c == 1), "Bit #%d of the stream should be a 0 or a 1, %d given", i, c);
            i++;
        }
    }

    /**
     * Whether the stream is empty or not
     *
     * Returns:
     *      if the stream is empty
    */
    @property pure bool empty() const {
        return cursor >= stream.length;
    }

    /**
     * The front of the stream
     *
     * Returns:
     *      A chunk of bits whose size is predetermined by the constructor
    */
    @property ushort[] front()
    out(result) {
        criticalf(!(result.length == this.bitdepth), "The length of the chunck is not %d", this.bitdepth);
    }
    body {
        ushort[] result = this.stream[this.cursor..min($,this.cursor+this.bitdepth)];
        if(result.length < this.bitdepth) {
            result ~= [cast(ushort) 0].replicate(this.bitdepth-result.length);
        }
        return result;
    }

    /**
     * The length of the constructor, the number of times to iterate over
     * the stream to exhaust all of its input
     *
     * Returns:
     *      Ditto
    */
    @property pure ulong length() const {
        return cast(ulong) ceil(1.0*(this.stream.length-this.cursor)/this.bitdepth);
    }

    /**
     * pops the front of the stream, i.e. advances the cursor.
     * Must be called after each iteration if one wishes to advance
    */
    pure void popFront() @safe {
        this.cursor += this.bitdepth;
    }

    /**
     * Create a string representation of the bitstream from its start to its
     * begining, regardless of the position of the cursor
     *
     * Returns:
     *      Ditto
    */
    string toString() const
    body {
        string s = "";

        for(int i=0;i<this.stream.length;i+=8) {
            const ushort[] byt = this.stream[i..min($, i+8)];
            char c = cast(char) binarr2dec(byt);
            if(c == '\0') break;
            s ~= c;
        }

        return s;
    }
    
}


unittest {
    Bitstream stream = Bitstream("testing", 3);
    foreach(ushort[] chunk; stream) {
        assert(chunk.length == 3);
    }

    stream = Bitstream(dec2binarr(10, 9), 3);
    for(int i=0;i<3;i++) {
        ushort[] chunk = stream.front();
        stream.popFront();
        assert(chunk == dec2binarr(i, 3));
    }
    assert(stream.empty());

    stream = Bitstream("Hello, World!", 8);
    assert(stream.length == 13);
    for(int i=0;i<4;i++) stream.popFront();
    assert(stream.toString == "Hello, World!");
    assert(cast(char) stream.front().binarr2dec == 'o');
    assert(stream.length == 9);
    foreach(c; stream) { stream.popFront(); }
    assert(stream.length == 0);
}
