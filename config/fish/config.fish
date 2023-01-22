if status is-interactive
    # Commands to run in interactive sessions can go here
test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
end
