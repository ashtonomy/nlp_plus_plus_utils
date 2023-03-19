# NLP Engine

This directory contains both the NLP++ engine exectuable (`nlp`) as well as an example script to set up from scratch on Palmetto (`install.sh`).


## Command Line

You can get help on nlp.exe:

      [command arg: --help]

      usage: nlp [--version] [--help]
                 [-INTERP][-COMPILED] INTERP is the default
                 [-ANA analyzer] name or path to NLP++ analyzer folder
                 [-IN infile] input text file path
                 [-OUT outdir] output directory
                 [-WORK workdir] working directory
                 [-DEV][-SILENT] -DEV generates logs, -SILENT (default) does not
                 [infile [outfile]] when no /IN or -OUT specified

      Directories in the nlp.exe files:
         data        nlp engine bootstrap grammar
         analyzers   default location for nlp++ analyzer folders
         visualtext  common files for the VisualText IDE

### Switches

Switch | Function
------------ | -------------
-INTERP / -COMPILED | Runs NLP++ code interpreted or compiled
-ANA | name of the analyzer or path to the analyzer folder
-IN | Input file
-OUT | Output directory
-WORK | Working director where the library and executable files are
-DEV / -SILENT | -DEV generates logs, -SILENT (default) does not
[infile [outfile]] | when no -IN or -OUT specified
