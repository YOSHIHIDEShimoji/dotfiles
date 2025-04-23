#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

#If GetKeyState("F13", "P")
l::Send, {Blind}{Right}
j::Send, {Blind}{Left}
i::Send, {Blind}{Up}
k::Send, {Blind}{Down}

u::Send, {Home}
o::Send, {End}

h::Send, {Enter}
n::Send, {Backspace}
m::Send, {Delete}
y::Send, {Escape}
p::Send, -

a::Send, +a
b::Send, +b
c::Send, +c
d::Send, +d
e::Send, +e
f::Send, +f
g::Send, +g
q::Send, +q
r::Send, +r
s::Send, +s
t::Send, +t
v::Send, +v
w::Send, +w
x::Send, +x
z::Send, +z

1::Send, +1
2::Send, +2
3::Send, +3
4::Send, +4
5::Send, +5
6::Send, +6
7::Send, +7
8::Send, +8
9::Send, +9
0::Send, +0

=::Send, +{=}
[::Send, +[
]::Send, +]
'::Send, +"
,::Send, +<
.::Send, +>
/::Send, +?

SC00D::Send, ~
SC07D::Send, |
SC073::Send, _

-::Send, =  ; ← F13 + - を押したら「=」を送る

`;::Send, {+}     ; F13＋セミコロンで「+」を送信  
SC028::Send, *   ; F13＋Shift＋;（:）で"*"を送信

#If


; 単体を無効化
F13::Return

return
