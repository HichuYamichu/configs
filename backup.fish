#! /usr/bin/fish

cp ~/.config/nvim/init.vim ./editor/nvim/init.vim
cp ~/.config/nvim/filetype.vim ./editor/nvim/filetype.vim
cp ~/.config/nvim/colors/froob.vim ./editor/nvim/colors/froob.vim

cp ~/.config/fish/config.fish ./shell/fish/config.fish
cp ~/.config/fish/conf.d/theme.fish ./shell/fish/conf.d/theme.fish
cp ~/.config/alacritty/alacritty.yml ./terminal/alacritty/alacritty.yml
cp ~/.xmonad/xmonad.hs ./wm/xmonad/xmonad.hs
cp -r ~/.config/polybar/* ./bar/polybar/

