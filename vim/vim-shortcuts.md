
11.08.2021

# learning VIM



commands I learned and useful


zz -> centers your cursor to the middle
; -> if you search something with f or t, it will search for the next one 
gg -> start and G -> end
w -> goes one word and W goes further, same for back with b and B
b -> goes one word back
e -> move to the end of your word
% -> toggles between parentese forth and back if your inside one
* -> toggles through all your variable or word on in your text
o -> will insert a new line and put you into insert mode directly. O will due it above 
C -> puts you into insert and replace until end of line
a -> Insert text after the cursor
A -> will put you into i mode and jump to end of line
I -> Insert mode at the beginning of the line
i -> go into insert mode before the cursor
x -> will delete one character where your cursor is
~ -> will toggle the case
ZZ : closes file same as :wq except it will not write anything to disk if nothing has changed. :x does the same

f -> find a character, with ; next. with F you find backward
t -> find to a character. with ; next. With T you find backward

## More Navigation
^U: move up half a screen
^D: move down half a screen
L: puts cursor into lowest part of your code
M: puts cursor in the middle part of your code
H: puts cursort to the top (high?) part of your code
Ctrl-i: jump to your previous navigation location
ctrl-r : replace  
Ctrl-o: jump back to where you were
J: join the current line with the next one (delete what's between)

## visual mode
v -> visual mode (characters)
V -> line mode
ctrl + v -> column mode!
ctrl+v and any command after hit ESC -> will do it on all selected lines of columns

## recording macros
q -> record macros! after you need to say where to save. e.g. safe on a character. you can applay it with @ and that character. hit q to stop/save the recording.


. -> redo any cmd you did before !!

## text-objects or nouns
p -> change paragraph
w -> word
s -> sentense

[ ( { <	   -> A [], (), or {} block
t -> tag
b -> block B-> block in 
R -> Insert mode -> replaces existing text
r -> replace one character

# Learnings
Ctrl+r" - Insert the contents of the " register, aka the last yank/delete. e.g. if you want to replace single quotes with double: ciw'Ctrl+r"'
