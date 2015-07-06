# Steg v1.0
`steg` is a text-to-text steganography tool written in the D programming language. Steganography is the process of concealing information, often meant to be secret, inside a harmless cover usually an image or a video or an audio file. In this case this program hides information represented as ASCII text inside a cover that is also an ASCII text.

![XKCD Comic #538: Security](https://imgs.xkcd.com/comics/security.png)

Source: [XKCD Comic #538: Security](https://xkcd.com/538/)

For example this program might be used to send credit card information inside an email by hiding it inside a lengthy email (for example an email updating your wife, who needs your credit card information, with great detail about your son's singing competition).

# Compiling and Using

## Compilation
Clone this repository and run the following command in your shell:
```
> make
```

To run the tests run the following command:
```
> make test; make clean
```

In order to compile you will need a D compiler. The one assumed you have is `dmd`. If you have another compiler then run the above commands with `CC=<compiler>` command line option.

After successfully compiling the project the executable will be found in the `bin/` directory.

## Usage
Bellow is a dump of the help page of the tool
```
USAGE: steg [options]... message

OPTIONS:

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

Hide the message "Hello, World!" in redridinghood.txt file and output the
result to the standard output:
> steg -c redridinghood.txt "Hello, World!"

Hide the content of the file ssh_keys in the access.log file and output
the result to access.log.1 file:
> steg -m ssh_keys -c access.log -o access.log.1

Retrieve the information hidden in the previous example and output the result
to the command line:
> steg -d -s access.log.1
```

# How does it work?
In unicode there are many characters that look a lot like a single space. We have found 8. Each space will thus encode 3 bits of the information to hide by replacing the original space in the cover. If there are not enough spaces in the cover then a warning will pop up and the file will be appended with as many spaces as needed.

# License
The following code and program are licensed under the GPLv3 license. Refer to the `LICENSE` file for more information.
