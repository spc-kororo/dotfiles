local FZF_THEME_DRACULA = "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
local FZF_PREVIEW_TREE_COMMAND = "tree.exe -CN {}"
local FZF_PREVIEW_BAT_COMMAND = "bat --plain --color=always"

os.setenv("FZF_DEFAULT_OPTS", "--height=90% --reverse " .. FZF_THEME_DRACULA)
os.setenv("FZF_CTRL_R_OPTS", "--preview-window=down,40%,wrap --preview=\"echo {}\"")
os.setenv("FZF_CTRL_T_OPTS", "--preview-window=down,40%,wrap --preview=\"((where bat > nul) && " .. FZF_PREVIEW_BAT_COMMAND .. " {}) || type {}\"")
os.setenv("FZF_ALT_C_OPTS", "--preview-window=right --preview=\"" .. FZF_PREVIEW_TREE_COMMAND .. "\"")
