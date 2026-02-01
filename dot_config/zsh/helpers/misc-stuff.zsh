
# the fuck no longer work in Python 3.12
# if hash thefuck 2> /dev/null; then;
  # eval $(thefuck --alias)
# fi

# Fix default editor, for systems without nvim installed
if ! hash nvim 2> /dev/null; then
  alias nvim='vim'
fi
