set EDITOR nvim
set -U fish_user_paths /usr/local/include /usr/local/sbin /usr/local/go/bin /usr/local/bin /usr/bin /bin ~/.cargo ~/.cargo/bin ~/go/bin
set fish_greeting
status --is-interactive; and source (jump shell fish | psub)

abbr -a ls exa --long --header --git
abbr -a find fd
abbr -a grep rg
abbr -a du dust
abbr -a time hyperfine
abbr -a ps procs
abbr -a top btm
abbr -a vim nvim
abbr -a code code-insiders .
abbr -a cat bat --paging=never
abbr -a sed sd

function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color blue
	echo -n (whoami)
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

function fish_user_key_bindings
        bind \cZ 'fg>/dev/null ^/dev/null' 
        if functions -q fzf_key_bindings
                fzf_key_bindings
        end
end

