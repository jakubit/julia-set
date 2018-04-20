;------------------JuliaSet--------------------------

; Argumenty przekazane z c:
; img->line     --  rdi -> r10
; img->w        --  rsi -> r11
; img->h        --  rdx -> r12


; cX        --  xmm0
; cY        --  xmm1
; zoom      --  xmm2
; moveX     --  xmm3
; moveY     --  xmm4

; colors    --  rcx -> r9

;---------------------------------------------------

; Zmienne 'lokalne':
; double zx        -- xmm5
; double zy        -- xmm6
; double tmp       -- xmm7
; int i            -- r13
; int x            -- r14
; int y            -- r15

;----------------TEXT----------------------------

section .text
global assembler

assembler:
  push  rbp
  mov   rbp, rsp

;------------------------------------------------

  ; Przeniose sobie pare rzeczy:
  mov r10, [rdi]
  mov r11, rsi
  mov r12, rdx
  mov r9, rcx

  mov r13, 0        ; i = 0
  mov r14, 0        ; x = 0 (chyba mozna usunac)
  mov r15, 0        ; y = 0

  mov rbx, 0      ; rbx = 0

;--------------------JULIA-----------------------

loopX:
  mov r15, 0      ; y = 0

loopY:
  mov r13, 100      ; i = maxiter

  ;/.cosik robie./:
  ; zx = 3,0 * (x - img->w/2) / (zoom * img->w) + moveX;

  ; 3 * (x - img->w/2)
  mov rsp, r11   ; rsp = img->w
  shr rsp, 1     ; rsp/2
  mov rcx, r14
  sub rcx, rsp   ; rcx = x - img->w/2

  mov rax, 3
  mul rcx        ; rax = 3 * (x - img->w/2)
  mov rcx, rax   ; rcx = 3 * (x - img->w/2)

  ; (zoom * img->w)
  mov rax, r11          ; rax = img->w
  cvtsd2si rdi, xmm2    ; zoom convert to int
  mul rdi               ; img->w * zoom
  mov rdi, rax          ; rdi = zoom * img->w

  cvtsi2sd xmm14, rcx   ; xmm14 <- rcx = 3 * (x - img->w/2)
  cvtsi2sd xmm13, rdi   ; xmm13 <- rdi = zoom * img->w

  vdivsd xmm12, xmm14, xmm13    ; xmm12 = xmm14/xmm13
  addsd xmm12, xmm3             ; xmm12 = 3,0 * (x - img->w/2) / (zoom * img->w) + moveX;

  movsd xmm5, xmm12             ; zx = xmm15 = 3,0 * (x - img->w/2) / (zoom * img->w) + moveX;

  ; zy = 2,0 * (y - img->h/2) / (zoom * img->h) + moveY;

  ; (y - img->h/2)
  mov rsp, r12           ; rsp = img->h
  shr rsp, 1             ; rsp/2
  mov rcx, r15
  sub rcx, rsp           ; rcx = y - img->h/2

  add rcx, rcx           ; rcx = 2 * (y - img->h/2)

  ; (zoom * img->h)
  mov rax, r12           ; rax = img->h
  cvtsd2si  rdi, xmm2    ; zoom convert to int
  mul rdi                ; img->h * zoom
  mov rdi, rax           ; rdi = zoom * img->h

  cvtsi2sd xmm14, rcx    ; xmm14 <- rcx = 2 * (y - img->h/2)
  cvtsi2sd xmm13, rdi    ; xmm13 <- rdi = zoom * img->h

  vdivsd xmm12, xmm14, xmm13    ; xmm12 = xmm14/xmm13
  addsd xmm12, xmm4             ; xmm12 = 2,0 * (y - img->h/2) / (zoom * img->h) + moveY;

  movsd xmm6, xmm12             ; zy = xmm6 = 2,0 * (y - img->h/2) / (zoom * img->h) + moveY;


loopWhile:

  ;/ cosik robie /
  ; (zx*zx + zy*zy < 4 && i > 1)
  vmulsd xmm8, xmm5, xmm5   ; xmm8 = zx*zx
  vmulsd xmm9, xmm6, xmm6   ; xmm9 = zy*zy

  vaddsd xmm10, xmm8, xmm9  ; xmm10 = zx*zx + zy*zy

  ;/ warunek 1
  mov rsp, 4
  cvtsi2sd xmm15, rsp       ; xmm15 <-- rsp = 4

  comisd xmm10, xmm15      ; zx*zx + zy*zy < 4
  jle color

  ;/ warunek 2
  mov rbx, 0
  dec r13         ; i--
  cmp r13, 0
  je color    ; i < maxiter

  ;/obliczenia
  vsubsd xmm7, xmm8, xmm9   ; xmm7 = tmp = zx*zx - zy*zy
  addsd xmm7, xmm0          ; xmm7 += cX

  vmulsd xmm6, xmm6, xmm5   ; xmm6 = zy = zy * zx
  addsd xmm6, xmm6
  addsd xmm6, xmm1          ; xmm6 += cY

  movsd xmm5, xmm7          ; zx = tmp

  jmp loopWhile

color:

  ;/ indeks piksela
  mov rax, r15        ; rax = y
  mul r11             ; rax = y * img->w

  add rax, r14        ; rax = y * img->w + x
  mov rbx, 3

  mul rbx             ; rax = (y * img->w + x) * 3
  mov rsp, rax        ; rsp = (y * img->w + x) * 3

  mov rax, [r9+r13]
  mov rcx, [r9+r13+1]
  mov rsi, [r9+r13+2]

  mov [r10+rsp], rax
  mov [r10+rsp+1], rcx
  mov [r10+rsp+2], rsi

  ;/ koniec loopY
  inc r15         ; y++
  cmp r15, r12
  jl loopY        ; y < img->h

  ; koniec loopX
  inc r14         ; x++
  cmp r14, r11    ; x < img->w
  jl loopX;

;------------------END--------------------------
end:
  mov rsp, rbp
  pop rbp
  ret
;-----------------------------------------------
