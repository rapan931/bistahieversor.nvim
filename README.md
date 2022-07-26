# bistahieversor.nvim
Echo search count.

The [vim-anzu](https://github.com/osyo-manga/vim-anzu) is great plugin. This plugin is written in lua and provides several features of vim-anzu.

## Install

[packer.nvim](https://github.com/wbthomason/packer.nvim)  
[vim-jetpack](https://github.com/tani/vim-jetpack)

```lua
use 'rapan931/bistahieversor.nvim'
```

## Usage

```lua
local bistahieversor = require('bistahieversor')

bistahieversor.setup({ maxcount = 1000, echo_wrapscan = true })
map('n', bistahieversor.n_and_echo)
map('N', bistahieversor.N_and_echo)
```

use [lasterisk.nvim](https://github.com/rapan931/lasterisk.nvim)

```lua
nmap('*',  function() require("lasterisk").search() bistahieversor.echo() end)
nmap('g*', function() require("lasterisk").search({ is_whole = false }) bistahieversor.echo() end)
xmap('g*', function() require("lasterisk").search({ is_whole = false }) bistahieversor.echo() end)
```

## Options

```lua
require('bistahieversor').setup({
  maxcount = 500, -- Max count of matched search, see ":h searchcount"
  timeout = 0, -- Timeout milliseconds recomputing the search result, see ":h searchcount"
  echo_wrapscan = 0, -- Echo wrapscan messages, see ":h shortmess" and 's' flag
  search_hit_bottom_msg = {'search hit BOTTOM, continuing at TOP', 'ErrorMsg'}, -- hit bottom message and highlight group
  search_hit_top_msg = {'search hit TOP, continuing at BOTTOM', 'ErrorMsg'}, -- hit top message and highlight group
})
```


## Why is the plugin named `bistahieversor.nvim` ?

My kids love [this dinosaur](https://en.wikipedia.org/wiki/Bistahieversor) so much I used it as the name of the plugin! sorry long name!
