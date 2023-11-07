if [[ "$OSTYPE" == "darwin"* ]]; then
    alias c='pbcopy'
    alias p='pbpaste'
else
    alias c='xclip -selection clipboard'
    alias p='xclip -selection clipboard -o'
fi

