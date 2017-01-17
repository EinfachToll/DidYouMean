DidYouMean
==========

Vim plugin which asks for the right file to open

Demo:

[![asciicast](https://asciinema.org/a/15372.png)](https://asciinema.org/a/15372)

If you're like me and you want to edit a specific file with Vim, say, `test.py`, you type `vim te` into the terminal, then you hit `<Tab>` and `<Enter>` immediately because you think your shell expands the characters to the right file name. But if there's another file starting with `te`, Vim fires up with an empty file called `te`, laughing at you. That's annoying. This simple plugin makes Vim ask for the right file to open.

Installation
------------

Just drop DidYouMean.vim into .vim/plugin/ or use a plugin manager like Pathogen or Vundle.
