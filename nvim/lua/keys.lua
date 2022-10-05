-- Vimspector
vim.cmd([[
nmap <F9> <cmd>call vimspector#Launch()<cr>
nmap <F5> <cmd>call vimspector#StepOver()<cr>
nmap <F8> <cmd>call vimspector#Reset()<cr>
nmap <F11> <cmd>call vimspector#StepOver()<cr>")
nmap <F12> <cmd>call vimspector#StepOut()<cr>")
nmap <F10> <cmd>call vimspector#StepInto()<cr>")
]])
map('n', "<leader>Db", ":call vimspector#ToggleBreakpoint()<cr>")
map('n', "<leader>Dw", ":call vimspector#AddWatch()<cr>")
map('n', "<leader>De", ":call vimspector#Evaluate()<cr>")


