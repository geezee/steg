import std.stdio;
import std.experimental.logger;
import std.getopt;
import std.string;
import std.file;
import std.c.process;

import encode : encode;
import decode : decode;


enum string VERSION = "1.0";


void main(string[] args) {
    string coverfile   = "";
    string msgfile     = "";
    string outputfile  = "";
    string stegfile    = "";
    bool   toDecode    = false;
    bool   showHelp    = false;
    bool   showVersion = false;

    getopt(args, "cover-file|c", &coverfile,
                 "msg-file|i", &msgfile,
                 "steg-file|s", &stegfile,
                 "output|o", &outputfile,
                 "decode|d", &toDecode,
                 "help|h", &showHelp,
                 "version|v", &showVersion);

    if(showHelp) {
        usage();
        writeln();
        help();
        exit(0);
    } else if(showVersion) {
        displayVersion();
    } else if(toDecode) {
        string content;

        if(stegfile.length == 0) {
            critical("Missing steg file");
            usage();
            exit(-1);
        } else {
            try {
                content = File(stegfile).readln('\0');
                content.decode.toString.writeln;
            } catch(Exception e) {
                critical(e.msg);
                exit(-1);
            }
        }
    } else {
        string message;
        string cover;
        string concealed;

        if(msgfile.length == 0) {
            message = args[1..$].join(" ");
        } else {
            try {
                message = File(msgfile).readln('\0');
            } catch(Exception e) {
                critical(e.msg);
                exit(-1);
            }
        }

        try {
            if(coverfile.length == 0) {
                critical("Missing Cover File");
                usage();
                exit(-1);
            } else {
                cover = File(coverfile).readln('\0');
            }
        } catch(Exception e) {
            critical(e.msg);
            exit(-1);
        }

        concealed = message.encode(cover);

        if(outputfile.length == 0) {
            concealed.writeln();
        } else {
            try {
                File(outputfile, "w+").write(concealed);
            } catch(Exception e) {
                critical(e.msg);
                exit(-1);
            }
        }
    }

}


void usage() {
"USAGE: steg [options]... message".writeln;
}


void help() {
"OPTIONS:

  -d, --decode          If this flag is provided then the program will behave
                        to extract the information concealed in the input file.
  -c, --cover-file      The file, encoded in ASCII, to use as cover when
                        concealing the message.
  -m, --message-file    The file, encoded in ASCII, that contains the message
                        to conceal in the cover. If no message file is provided
                        then the rest of the arguments will be treated as the
                        message. Refer to the examples section.
  -s, --steg-file       The file, encoded in UTF-8, that contains the concealed
                        message that must be removed.
  -o, --output          The output file to write to.
  -h, --help            Display this help dialog.
  -v, --version         Display the version information.
  

EXAMPLES:

Hide the message \"Hello, World!\" in redridinghood.txt file and output the
result to the standard output:
> steg -c redridinghood.txt \"Hello, World!\"

Hide the content of the file ssh_keys in the access.log file and output
the result to access.log.1 file:
> steg -m ssh_keys -c access.log -o access.log.1

Retrieve the information hidden in the previous example and output the result
to the command line:
> steg -d -s access.log.1".writeln;
}


void displayVersion() {
    "steg version: %s".writefln(VERSION);
}


unittest {
    import std.random;
    import std.ascii;
    import std.range;
    import std.conv;
    import std.string;
    import std.algorithm;

    auto asciiLetters = to!(char[])(letters);
    auto asciiDigits = to!(char[])(digits);
    string[] characters = [];
    foreach(c; chain(asciiLetters, asciiDigits))
        characters ~= format("%c", (cast(char) c));

    string randomWord() {
        string s = "";
        foreach(e; randomSample(characters, uniform(3, 7)))
            s ~= e;
        return s;
    }
    string randomSentence(int n) {
        string[] words = [0].repeat(n).map!(x => randomWord()).array;
        return words.join(" ");
    }

    foreach(n; 0..100) {
        string msg = randomSentence(uniform(1, 10));
        string cover = randomSentence(uniform(200, 1000));
        assert(msg == msg.encode(cover).decode.toString);
    }

    assert(encode("bit", "abc")[0..3] == "abc");
}
