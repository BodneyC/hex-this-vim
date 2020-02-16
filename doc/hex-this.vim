*HexThis* *Hex-This* - In-vim hex editor


                                       ,----,                              ~
         ,--,                        ,/   .`|                              ~
       ,--.'|                      ,`   .'  : ,---,                        ~
    ,--,  | :                    ;    ;     ,--.' |     ,--,               ~
 ,---.'|  : '                  .'___,/    ,'|  |  :   ,--.'|               ~
 |   | : _' |         ,--,  ,--|    :     | :  :  :   |  |,     .--.--.    ~
 :   : |.'  |  ,---.  |'. \/ .`;    |.';  ; :  |  |,--`--'_    /  /    '   ~
 |   ' '  ; : /     \ '  \/  / `----'  |  | |  :  '   ,' ,'|  |  :  /`./   ~
 '   |  .'. |/    /  | \  \.' /    '   :  ; |  |   /' '  | |  |  :  ;_     ~
 |   | :  | .    ' / |  \  ;  ;    |   |  ' '  :  | | |  | :   \  \    `.  ~
 '   : |  : '   ;   /| / \  \  \   '   :  | |  |  ' | '  : |__  `----.   \ ~
 |   | '  ,/'   |  / ./__;   ;  \  ;   |.'  |  :  :_:,|  | '.'|/  /`--'  / ~
 ;   : ;--' |   :    |   :/\  \ ;  '---'    |  | ,'   ;  :    '--'.     /  ~
 |   ,/      \   \  /`---'  `--`            `--''     |  ,   /  `--'---'   ~
 '---'        `----'                                   ---`-'              ~
 


==========================================================================
CONTENTS                                                    *HexThisContents*


  1. Usage ....................................... |HexThisUsage|
  2. Commands .................................... |HexThisCommands|
  3. Editing ..................................... |HexThisEditing|
  4. Configuration ............................... |HexThisConfiguration|
    a. Formatting ................................ |HexThisFormatting|
    b. Dependencies .............................. |HexThisDependencies|
    c. Others .................................... |HexThisOthers|
  5. TODOs ....................................... |HexThisTODOs|
  6. Bugs ........................................ |HexThisBugs|
  7. License ..................................... |HexThisLicense|


==========================================================================
USAGE                                                         *HexThisUsage*


I've tried to keep/emulate as much of the standard Vim as possible, i.e. 
  movement. However it should be noted that each of the movement keys have
  been mapped to a function which keeps you within the boundaries of the 
  hex.

Normal commands mapped as best I could (movement):

    `<Esc>`, `<C-c>`, `<LeftMouse>`,
    `h`, `j, k`, `l`, `H`, `J`, `K`, `L`, 
    `w`, `W`, `b`, `B`, `e`, `E`, `ge`, `gE`,
    `_`, `0`, `g0`, `^`, `$`,
    `gg`, `G`

Normal commands mapped as best I could (edit):

    `r`, `s`, `i`, `I`, `a`, `A`, `R`, `S`

Normal commands mapped to `<Nop>`:

    `cc`, `dd`, `v`, `V`, `<C-v>`, `J`, `K`, `o`, `O`, `D`, `cc`, `p`, `P` 

Insert commands mapped to `<Nop>`:

     `<BS>`, `<Left>`, `<Right>`, `<Up>`, `<Down>`


==========================================================================
COMMANDS                                                   *HexThisCommands*


   *HexThis*                       Params: `[cols [, bytes [, upper ]]]`

  `HexThis` takes the current file (`expand('%')`), runs it through XXD 
    with either the default formatting (see below) or with the argument-
    specified formatting

  From the output of XXD, a new file is created in the 
    |g:hex_this_cache_dir| directory, which, by default, is 
    `$HOME/.cache/vim/hex-this`


   *HexReset*                      Params: `[cols [, bytes [, upper ]]]`

  By default, if you return to a file for which a hex-this file exists, 
    the plugin will just open that same file with whatever changes/
    settings you made last time. If this is not the desired behaviour, 
    then you can reset the file with `HexReset`; formatting options as 
    `HexThis`


   *HexWrite*                     Params: `[cols [, bytes [, upper ]]]`

  This is the command used to write the contents of a hex-this file back 
    to the original. It uses XXD's `-r` option, so formatting is important 
    here

  One can either specify the formatting as with the other commands, or 
    simply let Hex-This figure it out; the formatting options are quite 
    simplistic so Hex-This should do a good job in figuring out the format

    *HexAddLines*

  In case you want to add data to the file, this command will append blank
    lines, either |g:hex_this_n_lines| number or the number specified.


==========================================================================
CONFIGURATION                                         *HexThisConfiguration*


The following section specifies the global variables in use by |HexThis|
  and their defaults


--------------------------------------------------------------------------
FORMATTING                                               *HexThisFormatting*


  *g:hex_this_cols*              Default: `16`

                                 Desc: It is the number of bytes to show 
                                       for each line


  *g:hex_this_byte_space*        Default: `2`

                                 Desc: It is the number of bytes in each 
                                       group


  *g:hex_this_upper*             Default: `v:false`

                                 Desc: Specifies if the output should be 
                                       in uppercase


--------------------------------------------------------------------------
DEPENDENCIES                                           *HexThisDependencies*


  *g:hex_this_xxd_path*          Default: Output of `command -v xxd`

                                 Desc: Path to XXD binary


  *g:hex_this_base64_path*       Default: Output of `command -v base64`

                                 Desc: Path to Base64 binary


--------------------------------------------------------------------------
OTHERS                                                       *HexThisOthers*


  *g:hex_this_cache_dir*         Default: `$HOME/.cache/vim/hex-this`

                                 Desc: Default location to store hex-this
                                       files

  *g:hex_this_n_lines*           Default: `16`

                                 Desc: Number of line to append when using
                                       |HexAddLines|


==========================================================================
TODOS                                                         *HexThisTODOs*


- Use the thing and test it, find issues, test them
- `DeleteFromCursor`
- `AppendOne`


==========================================================================
BUGS                                                           *HexThisBugs*


- Likely to be plenty but it's not well tested, feel free to let me know 
  `https://github.com/bodneyc/hex-this-vim/issues`


==========================================================================
LICENSE                                                     *HexThisLicense*


This plugin is distributed and can be redistributed under the GPL v2.0.
  
  See `$(git rev-parse --show-toplevel)/LICENSE`


