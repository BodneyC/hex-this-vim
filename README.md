Hex This, Vim
=============

Hex-This is a hex editor for Vim, I've found a couple around on the web and [Vim-scripts](https://www.vim.org/scripts/) but they have either been a little destructive, or a little lack-luster.

Hopefully, this one is neither.

## Commands

There are three commands that Hex-This provides:

1. **HexThis**

`HexThis [cols [, bytes [, upper ]]]`

`HexThis` takes the current file (`expand('%')`), runs it through XXD with either the default formatting (see below) or with the argument-specified formatting.

From the output of XXD, a new file is created in the `g:hex_this_cache_dir` directory, which, by default, is `$HOME/.cache/vim/hex-this`.


2. **HexReset**

`HexReset [cols [, bytes [, upper ]]]`

By default, if you return to a file for which a hex-this file exists, the plugin will just open that same file with whatever changes/settings you made last time. If this is not the desired behaviour, then you can reset the file with `HexReset`; formatting options as `HexThis`.


3. **HexWrite**

`HexWrite [cols [, bytes [, upper ]]]`

This is the command used to write the contents of a hex-this file back to the original. It uses XXD's `-r` option, so formatting is important here.

One can either specify the formatting as with the other commands, or simply let Hex-This figure it out; the formatting options are quite simplistic so Hex-This should do a good job in figuring out the format.


## Formatting

There are really only three formatting options provided by XXD and so only three by Hex-This, these are:

1. **Columns**

Specified by `g:hex_this_cols`, it is the number of bytes to show for each line; default of `16`.

2. **Byte Groups**

Specified by `g:hex_this_byte_space`, it is the number of byte in each group; default of `2`.

3. **Uppercase**

Specified by `g:hex_this_upper`, specifies if the output should be in uppercase; default of `v:false`.


## Usage

I've tried to keep/emulate as much of the standard Vim as possible, i.e. movement. However it should be noted that each of the movement keys have been mapped to a function which keeps you within the boundaries of the hex.

Normal commands mapped as best I could (movement):

    <Esc>, <C-c>, <LeftMouse>, 
    h, j, k, l, H, J, K, L, 
    w, W, b, B, e, E, ge, gE,
    _, 0, g0, ^, $,
    gg, G

Normal commands mapped as best I could (edit):

    r, s, i, I, a, A, R, S

Normal commands mapped to `<Nop>`:

    cc, dd, v, V, <C-v>, J, K, o, O, D, cc, p, P 

Insert commands mapped to `<Nop>`:

     <BS>, <Left>, <Right>, <Up>, <Down> 


### Editing

Editing is restricted compared to normal Vim, there are three flavours of input (with a secret fourth and fifth), these are:

1. Hex, `aa` - `ff` (case irrelevant)
2. Dec, `0` - `255` (leading zeroes irrelevant)
3. ASCII, `<char>`

4. Any, as above and Hex-This will guess
5. Pick, gives a choice of the three above

- `r`, `s`, `a`, give option **4**
- `i`, gives options **5**
- `I` moves to start of line and `i`
- `A` moves to end of line and `a`
- `R` repeatedly `r` and `l`
- `S` moves to start of line and repeatedly `r` and `l`


## Other Defaults

```
g:hex_this_cache_dir   : expand('$HOME/.cache/vim/hex-this'))

g:hex_this_xxd_path    : 'list('command -v xxd')[0]
g:hex_this_base64_path : systemlist('command -v base64')[0]

g:hex_this_cols        : 16
g:hex_this_byte_space  : 2
g:hex_this_upper       : v:false

hi HexThisAsciiEq ctermbg=darkred ctermfg=white guibg='#882342' guifg='#ffffff'
hi HexThisHexEq   ctermbg=blue    ctermfg=white guibg='#2233ee' guifg='#ffffff'
```

## Disclaimer

This is not particularly well tested, feel free to create an issue if you find any.
