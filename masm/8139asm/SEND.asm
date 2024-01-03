//********************** Start of Code in Segment: 1 **************

:0001.0100 B802B1                 mov ax, B102
:0001.0103 B93981                 mov cx, 8139
:0001.0106 BAEC10                 mov dx, 10EC
:0001.0109 BE0000                 mov si, 0000
:0001.010C CD1A                   int 1A
:0001.010E B809B1                 mov ax, B109
:0001.0111 BF3C00                 mov di, 003C
:0001.0114 CD1A                   int 1A
:0001.0116 80F908                 cmp cl, 08
:0001.0119 7605                   jbe 0120
:0001.011B 80C168                 add cl, 68
:0001.011E EB03                   jmp 0123



* Referenced by a (U)nconditional or (C)onditional Jump at Address:
|:0001.0119(C)
|
:0001.0120 80C108                 add cl, 08

* Referenced by a (U)nconditional or (C)onditional Jump at Address:
|:0001.011E(U)
|
:0001.0123 33C0                   xor ax, ax
:0001.0125 8AC1                   mov al , cl 
:0001.0127 B304                   mov bl, 04
:0001.0129 F6E3                   mul bl
:0001.012B 33C9                   xor cx, cx
:0001.012D 8EC1                   mov es, cx
:0001.012F 8BD8                   mov bx, ax
:0001.0131 268B4702               mov ax, es:[bx+02]
:0001.0135 8ED8                   mov ds, ax
:0001.0137 C6061220FF             mov byte ptr [2012], FF
:0001.013C B40A                   mov ah, 0A
:0001.013E BA1220                 mov dx, 2012
:0001.0141 CD21                   int 21
:0001.0143 8B160301               mov dx, [0103]
:0001.0147 66ED                   in ax, dx
:0001.0149 6689060A20             mov [200A], eax
:0001.014E 83C204                 add dx, 0004
:0001.0151 ED                     in ax, dx
:0001.0152 89060E20               mov [200E], ax
:0001.0156 66B8FFFFFFFF           mov eax, FFFFFFFF
:0001.015C 6689060420             mov [2004], eax
:0001.0161 89060820               mov [2008], ax
:0001.0165 C70610200806           mov word ptr [2010], 55aa
:0001.016B B90000                 mov cx, 0000
:0001.016E 8A0E1320               mov cl , [2013]
:0001.0172 890E1220               mov [2012], cx
:0001.0176 8B160301               mov dx, [0103]
:0001.017A 83C220                 add dx, 0020

* Referenced by a (U)nconditional or (C)onditional Jump at Address:
|:0001.0195(U)
|
:0001.017D 8A0E0E01               mov cl , [010E]
:0001.0181 80F903                 cmp cl, 03
:0001.0184 7F0A                   jg 0190
:0001.0186 88C8                   mov al , cl 
:0001.0188 B304                   mov bl, 04
:0001.018A 8BC1                   mov ax, cx
:0001.018C F6E3                   mul bl
:0001.018E EB07                   jmp 0197



* Referenced by a (U)nconditional or (C)onditional Jump at Address:
|:0001.0184(C)
|
:0001.0190 C6060E0100             mov byte ptr [010E], 00
:0001.0195 EBE6                   jmp 017D



* Referenced by a (U)nconditional or (C)onditional Jump at Address:
|:0001.018E(U)
|
:0001.0197 03D0                   add dx, ax
:0001.0199 6633C0                 xor eax, eax
:0001.019C 8CD8                   mov ax, ds
:0001.019E 66C1E004               shl eax, 04
:0001.01A2 660504200000           add eax, 00002004
:0001.01A8 66EF                   out dx, ax
:0001.01AA B80007                 mov ax, 0700
:0001.01AD 83EA10                 sub dx, 0010
:0001.01B0 EF                     out dx, ax
:0001.01B1 8A060E01               mov al , [010E]
:0001.01B5 FEC0                   inc al
:0001.01B7 88060E01               mov [010E], al 
:0001.01BB B44C                   mov ah, 4C
:0001.01BD CD21                   int 21

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
