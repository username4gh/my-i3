# Guidelines
+ Don't put any lines in your config files that you don't understand!(Just to reminder myself, I once had done a terrible job to resist the temptation to import third party stuffs that i do not understand)

+ Keep necessary notes
 1. <small>meaning full name</small>
 2. <small>comment & reference</small>

+ Compatibility & Lightweight (So i had to ditch my beloved emacs) & Cut-dependency
 1. <small>darwin & ubuntu</small>
 2. <small>zsh & bash</small>
 3. <small>local & ssh</small>
 4. <small>prefer pre-installed software(intersection of BSD and GNU)</small>
 	> <small>eg: use curl rather than wget</small>

# Pre-arrangement
+ bash script loading-sequence(also the dependency chain): internal -> path -> mechanism -> (function - alias) -> module -> completion -> custom
 1. <small>internal (shell-builtin command & pre-installed program(as less as i can, BSD vs GNU))</small>
 2. <small>path (package-manager specific & custom-defined 'PATH')</small>
    	- try Sub-Shell when ```export PATH``` is needed, only keep necessary 'PATH' exported([Global Variables Are Bad](http://c2.com/cgi/wiki?GlobalVariablesAreBad))
 3. <small>mechanism (basic setup for downstream stuff)</small>
 4. <small>module (least dependence between each other, dependency autonomy)</small>
 5. <small>no external dependence for executable script</small>

+ functions with prefix '_' are used either internally or cautiously


# TODO & Question & Reference
+ backup shell-command-history to github with encryption
 1. <small>[How to write a new git protocol](https://rovaughn.github.io/2015-2-9.html)</small>
 2. <small>[blackbox](https://github.com/StackExchange/blackbox)</small>

+ add security check for SCM(personal or other sensitive info)

+ backup browser history
 1. <small>easy to search</small>
 2. <small>pre or post process</small>

+ bootstrap-mechanism for the whole setup process
 1. <small>more automation</small>
 2. <small>clean and easy to use</small>
 3. <small>easy to extend</small>

+ coding style
 1. <small>[cleansing code](http://bencane.com/2014/06/06/8-tips-for-creating-better-bash-scripts/)</small>

+ Legal-Stuff
