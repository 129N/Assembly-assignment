section .data

    Window_Width dw 320    ;tHE width of the window 300pixel 140h
    Window_Height dw 200   ;the height fo the window 200pixel 0c8H
    Window_Bounds dw 1      ; the variable to check collisins early 

    Time_AUX db 0      ;variable used when checking if the time has changed

    ball_abs_x dw  0A0h      ;ball_original_x 110
    ball_abs_y dw  64h     ;ball_original_y 100

    Ball_X dw 110       ; position of columun of the ball 0A0h
    Ball_Y dw 110       ; position of line of the ball 64h

    ball_size dw 08h    ; size of the ball width and height 


    initial_velocity_X dw 3
    initial_velocity_Y dw 2

    ball_velocity_X dw -3    ;X(horizontal) velocity of the ball
    ball_velocity_Y dw -2  ;Y(vertical) velocity of the ball

    PADDLE_LEFT_X   dw 0Ah
    PADDLE_LEFT_Y   dw 0Ah

    PADDLE_RIGHT_X   dw 130h
    PADDLE_RIGHT_Y   dw 0Ah


    PADDLE_WIDTH dw 05h
    PADDLE_HEIGHT dw 1Fh
    
    

section .bss 
    stack resb 64

section .text 
    org 0x100       ; Set origin for DOS .COM file
    global _start


_start:
    ;push ds         ;Save current DS on the stack
    ;xor ax,ax       ; clean ax
    ;push ax         ; Push 0 onto the stack
    mov ax, cs      ; Load the Code Segment (CS) into AX
    mov ds, ax      ;; Set DS to the same value as CS


    ; set the video screen
    mov ah, 00h        ; Set video mode
    mov al, 13h        ; Mode 13h: 320x200, 256 colors
    int 10h            ; Call BIOS video interrupt to set the mode

    ; forgot the set 
    mov ah, 0Bh     ;set the configuration   
    mov bh, 00h     ;to the background color
    mov bl, 00h     ;black
    int 10h

    call Check_time

    ; Wait for key press (pause until a key is pressed)
    ;mov ah, 00h        ; BIOS function to wait for key press
    ;int 16h            ; Call BIOS keyboard interrupt

    ret


Check_time:

    ; Get the system time 
    mov ah, 2ch         ; get the system time
    int 21h             ; ch = hour cl = minute dh = second dl = 1/100 seconds

    cmp dl, [Time_AUX]   ; is the current time = to the previous one (Time_AUX)
    je Check_time        ; if equal, loop again

    mov [Time_AUX], dl   ; update time

    call Clear_Screen    ; clear the screen
    call draw_ball       ; draw the ball
    call Move_ball       ; move the ball

    call MOVE_PADDLE_LEFT
    ; call MOVE_PADDLE_RIGHT

    call DRAW_PADDLES_LEFT
    call DRAW_PADDLES_RIGHT

    jmp Check_time           ; loop again

    ret


draw_ball:

    mov cx, [Ball_X]      ;set the initial column X
    mov dx, [Ball_Y]      ;set the initila line Y

    mov di, 0           ; Counter for rows (vertical size)
    
draw_ball_horizontal:
        ; Start horizontal loop
        
    ;draw pixel ; write grpahic pixel
    mov ah, 0Ch        ; Set function for writing pixel
    mov al, 0Fh        ; Choose white color for the pixel (0Fh)
    mov bh, 00h        ; Set page number (00h for the primary page)
    int 10h            ; Call BIOS interrupt to draw the pixel

    ; Move to the next pixel horizontally
    inc cx
    mov ax, cx
    sub ax, [Ball_X]
    cmp ax, [ball_size]
    jng draw_ball_horizontal

    ; Move to the next row
    mov cx, [Ball_X]      ; Reset X position to start of the row
    inc dx                ; Move to the next row (increment Y position)
    inc di                ; Increment row counter
    cmp di, [ball_size]   ; Check if we've drawn all rows
    jng draw_ball_horizontal

    
    ret


DRAW_PADDLES_LEFT:
    mov cx, [PADDLE_LEFT_X]       ; set the initila column(x)
    mov dx, [PADDLE_LEFT_Y]       ; set the initial line(Y)


    xor di, di                    ; Row counter

DRAW_PADDLES_LEFT_HORIZONTAL:

    ;draw pixel ; write grpahic pixel
    mov ah, 0Ch        ; Set function for writing pixel
    mov al, 0Fh        ; Choose white color for the pixel (0Fh)
    mov bh, 00h        ; Set page number (00h for the primary page)
    int 10h            ; Call BIOS interrupt to draw the pixel

    ; Move to the next pixel horizontally
    inc cx          ; cx = cx + 1
    mov ax, cx      ; cx - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> next line -> continue to the next column) 
    sub ax, [PADDLE_LEFT_X]
    cmp ax, [PADDLE_WIDTH]
    jng DRAW_PADDLES_LEFT_HORIZONTAL
    

    ; Move to the next row
    mov cx, [PADDLE_LEFT_X]      ; Reset X position to start of the row
    inc dx                      ; Move to the next row (increment Y position)
    mov ax, dx
    sub ax, [PADDLE_LEFT_Y]       ; Calculate vertical offset
    inc di                  ; Increment row counter
    cmp di, [PADDLE_HEIGHT]   ; Check if we've drawn all rows
    jng DRAW_PADDLES_LEFT_HORIZONTAL        ;dx - PADDLE_LEFT_Y > PADDLE_WIPADDLE_HEIGHTDTH (Y -> next line -> continue to the next column) 

    ret


;right side paddle
DRAW_PADDLES_RIGHT:
    mov cx, [PADDLE_RIGHT_X]       ; set the initila column(x)
    mov dx, [PADDLE_RIGHT_Y]       ; set the initial line(Y)
    xor di, di                    ; Row counter

DRAW_PADDLES_RIGHT_HORIZONTAL:

    ;draw pixel ; write grpahic pixel
    mov ah, 0Ch        ; Set function for writing pixel
    mov al, 0Fh        ; Choose white color for the pixel (0Fh)
    mov bh, 00h        ; Set page number (00h for the primary page)
    int 10h            ; Call BIOS interrupt to draw the pixel

    ; Move to the next pixel horizontally
    inc cx          ; cx = cx + 1
    mov ax, cx      ; cx - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> next line -> continue to the next column) 
    sub ax, [PADDLE_RIGHT_X]
    cmp ax, [PADDLE_WIDTH]
    jng DRAW_PADDLES_RIGHT_HORIZONTAL
    

    ; Move to the next row
    mov cx, [PADDLE_RIGHT_X]      ; Reset X position to start of the row
    inc dx                      ; Move to the next row (increment Y position)
    mov ax, dx
    sub ax, [PADDLE_RIGHT_Y]       ; Calculate vertical offset
    inc di                  ; Increment row counter
    cmp di, [PADDLE_HEIGHT]   ; Check if we've drawn all rows
    jng DRAW_PADDLES_RIGHT_HORIZONTAL        ;dx - PADDLE_LEFT_Y > PADDLE_WIPADDLE_HEIGHTDTH (Y -> next line -> continue to the next column) 

    ret


Clear_Screen:
    mov ax, 0A000h         ; Video memory base address in mode 13h
    mov es, ax

    xor di, di             ; Start from the top-left corner
    mov cx, 320 * 200 / 2     ; Clear the entire screen (320x200 pixels, 2 pixels per word)
    xor ax, ax             ; Black color
   
Clear_Screen_Loop:
    stosw                  ; Write a word (2 pixels) to video memory
    loop Clear_Screen_Loop

    ret
;end 
Move_ball:
    ; Move the ball horizontally
    mov ax, [Ball_X]
    add ax, [ball_velocity_X] ; Apply velocity


    call Ball_Collision_Right
    ;call check_collision_Left_paddle          ; Update position

    mov [Ball_X], ax
    
    ; Check for collision with right edge
    mov bx, [Window_Width]
    sub bx, [ball_size]
    cmp ax, bx
    jg Clamp_X_Right
    ; Check for collision with left edge
    cmp ax, [ball_size]
    jl Clamp_X_Left
    ; If no collision, update position
    

    jmp Move_Y
; end here



Ball_Collision_Right:
    ; Calculate the ball's right edge
    mov bx, [Ball_X]
    add bx, [ball_size]      ; Ball's right edge
    cmp bx, [PADDLE_RIGHT_X]
    jng check_collision_Left_paddle   ; No collision if ball is left of paddle

    ; Check if the ball is within the paddle's width
    mov cx, [PADDLE_RIGHT_X]
    add cx, [PADDLE_WIDTH]   ; Paddle's right edge
    cmp [Ball_X], cx
    jnl check_collision_Left_paddle   ; No collision if ball is right of paddle

    ; Check if the ball is within the paddle's height
    mov bx, [Ball_Y]
    add bx, [ball_size]      ; Ball's bottom edge
    cmp bx, [PADDLE_RIGHT_Y]
    jng check_collision_Left_paddle   ; No collision if ball is above paddle

    mov bx, [PADDLE_RIGHT_Y]
    add bx, [PADDLE_HEIGHT]  ; Paddle's bottom edge
    cmp [Ball_Y], bx
    jnl check_collision_Left_paddle   ; No collision if ball is below paddle

    ; Collision detected: Reverse horizontal velocity
    mov ax, [ball_velocity_X]
    neg ax
    mov [ball_velocity_X], ax

    ; Adjust ball's position to avoid sticking
    mov ax, [PADDLE_RIGHT_X]
    sub ax, [ball_size]
    ret


; end

check_collision_Left_paddle:
    ; Calculate the ball's left edge
    mov bx, [Ball_X]
    add bx, [ball_size]      ; Ball's left edge
    cmp bx, [PADDLE_LEFT_X]
    jl EXIT_PADDLE_MOVEMENT   ; No collision if ball is left of paddle

    ; Check if the ball is within the paddle's width
    mov cx, [PADDLE_LEFT_X]
    add cx, [PADDLE_WIDTH]   ; Paddle's right edge
    cmp [Ball_X], cx
    jg EXIT_PADDLE_MOVEMENT   ; No collision if ball is right of paddle

    ; Check if the ball is within the paddle's height
    mov bx, [Ball_Y]
    add bx, [ball_size]      ; Ball's bottom edge
    cmp bx, [PADDLE_LEFT_Y]
    jl EXIT_PADDLE_MOVEMENT   ; No collision if ball is above paddle

    mov bx, [PADDLE_LEFT_Y]
    add bx, [PADDLE_HEIGHT]  ; Paddle's bottom edge
    cmp [Ball_Y], bx
    jg EXIT_PADDLE_MOVEMENT   ; No collision if ball is below paddle

    ; Collision detected: Reverse horizontal velocity
    mov ax, [ball_velocity_X]
    neg ax
    mov [ball_velocity_X], ax

    ; Adjust ball's position to avoid sticking
    mov ax, [PADDLE_LEFT_X]
    add ax, [ball_size]
    mov [Ball_X], ax


    ret

;end
Clamp_X_Right:
    ; Place the ball just inside the right boundary
    mov ax, [Window_Width]
    add ax, [ball_size]
    cmp ax, [Window_Width]
    jle Skip_Resets

    ; Place the ball just inside the right boundary
    mov ax, [Window_Width]
    sub ax, [ball_size]
    mov [Ball_X], ax
    
    ; Ball is out of bounds, reset position
    jg Reset_Position

    ret

Clamp_X_Left:
    ; Check if the ball's horizontal position is less than the boundary
    mov ax, [Ball_X]
    cmp ax, 0 
    jnl Skip_Resets  ; Skip if within bounds

    ; Clamp the ball just inside the left boundary
    mov ax, [ball_size]
    mov [Ball_X], ax

    jmp Reset_Position

    ret

Skip_Resets:
    ret


;reset 
Reset_Position:
    mov ax, [ball_abs_x]
    mov [Ball_X], ax

    mov ax, [ball_abs_y]
    mov [Ball_Y], ax

    ; Optionally reset velocity if needed
    mov ax, [initial_velocity_X]
    mov [ball_velocity_X], ax
    mov ax, [initial_velocity_Y]
    mov [ball_velocity_Y], ax

    ret

;blank    

   

;end
Move_Y:
    ; Move the ball vertically
    mov ax, [Ball_Y]
    add ax, [ball_velocity_Y]


    ; Check for collision with bottom edge
    mov bx, [Window_Height]
    sub bx, [ball_size]
    cmp ax, bx
    jg Clamp_Y_Bottom
    
    ; Check for collision with top edge
    cmp ax, [ball_size]
    jl Clamp_Y_Top
    ; If no collision, update position
    mov [Ball_Y], ax
    ret
Clamp_Y_Bottom:
    ; Calculate the bottom edge of the ball
    mov ax, [Ball_Y]
    add ax, [ball_size]          ; Ball's bottom edge
    cmp ax, [Window_Height]      ; Compare to window height
    jg No_Correction_Bottom      ; If bottom edge is within bounds, skip correction
    
    ; If the ball is beyond the bottom, adjust its position
    mov ax, [Window_Height]
    sub ax, [ball_size]          ; Place ball just inside the bottom boundary
    mov [Ball_Y], ax

     
    
    ; Reverse vertical velocity to simulate bouncing
    mov ax, [ball_velocity_Y]
    neg ax
    mov [ball_velocity_Y], ax


No_Correction_Bottom:
    ret


Clamp_Y_Top:
    ; Check if Ball_Y is less than ball_size (i.e., has crossed the top boundary)
    mov ax, [Ball_Y]        ; Load Ball_Y into AX
    cmp ax, [ball_size]     ; Compare Ball_Y with ball_size
    jl No_Correction_Top    ; If Ball_Y is greater or equal to ball_size, no correction needed

    ; Adjust Ball_Y to be just inside the top boundary
    mov ax, [ball_size]     ; Set Ball_Y to ball_size (top boundary)
    mov [Ball_Y], ax        ; Place the ball at the top boundary
    
    ; Reverse vertical velocity to simulate bouncing
    mov ax, [ball_velocity_Y]
    neg ax
    mov [ball_velocity_Y], ax

No_Correction_Top:
    ret
;Ball end 




MOVE_PADDLE_LEFT:
    ; left paddle movement

    ; check if any is being pressed.(if not check other paddle)
    mov ah, 01h
    int 16h     ; wait the key until the keyboard pressed
    jz check_R_paddle_move      ;zf = 1, jz -> jump if 0

    ; check which key is being pressed.
    mov ah, 00h
    int 16h

    ;use ASCII table
    ;keyboard w,W: move
    cmp al, 'w' ;lower w
    je MOVE_LEFT_PADDLE_UP

    cmp al, 'W' ;capital W
    je MOVE_LEFT_PADDLE_UP

    ;keyboard s,S:down
    cmp al, 's' ;lower s
    je MOVE_LEFT_PADDLE_DOWN

    cmp al, 'S' ;capital S
    je MOVE_LEFT_PADDLE_DOWN
    jmp check_R_paddle_move


MOVE_LEFT_PADDLE_UP:
    mov ax, [PADDLE_LEFT_Y]
    sub ax, 5  ; Adjust the movement speed (decrease by 2 pixels)
    cmp ax, [Window_Bounds]  ; Check if the paddle would go above the top boundary
    jge Update_Paddle_Y_Left
    mov ax, [Window_Bounds]  ; Clamp the paddle to the top boundary

Update_Paddle_Y_Left:
    mov [PADDLE_LEFT_Y], ax
    jmp check_R_paddle_move

Set_Top_Boundary_LEFT:
    mov ax, [Window_Bounds]; Load the value 0 into AX
    mov [PADDLE_LEFT_Y], ax  ; Store the value of AX into PADDLE_LEFT_Y
    jmp check_R_paddle_move  ; Jump to continue checking the right paddle


MOVE_LEFT_PADDLE_DOWN:
    ; Move the left paddle down
    mov ax, [PADDLE_LEFT_Y]
    add ax, 5  ; Adjust the movement speed (increase by 2 pixels)
    mov bx, [Window_Height]
    sub bx, [Window_Bounds]
    sub bx, [PADDLE_HEIGHT]  ; Calculate the bottom boundary
    cmp ax, bx  ; Check if the paddle would go below the bottom boundary
    jle Update_Paddle_Y_Left
    mov ax, bx  ; Clamp the paddle to the bottom boundary


Set_Bottom_Boundary_LEFT:
    ;mov [PADDLE_LEFT_Y], ax ; Update paddle position
    ;jmp check_R_paddle_move  ; Jump to continue checking the right paddle

    mov ax, [Window_Height]
    sub ax, [Window_Bounds]
    sub ax, [PADDLE_HEIGHT]
    mov [PADDLE_LEFT_Y], ax  ; Clamp to bottom boundary
    jmp check_R_paddle_move

check_R_paddle_move:
    ; Use the ASCII table to check key presses for the right paddle
    ; 'l' or 'L': move up
    cmp al, 'l' ; lowercase 'l'
    je MOVE_RIGHT_PADDLE_DOWN
    cmp al, 'L' ; uppercase 'L'
    je MOVE_RIGHT_PADDLE_DOWN

    ; 'o' or 'O': move down
    cmp al, 'o' ; lowercase 'o'
    je MOVE_RIGHT_PADDLE_UP
    cmp al, 'O' ; uppercase 'O'
    je MOVE_RIGHT_PADDLE_UP
    jmp EXIT_PADDLE_MOVEMENT   ; If no recognized key, jump to the next paddle check

MOVE_RIGHT_PADDLE_UP:
    mov ax, [PADDLE_RIGHT_Y]
    sub ax, 5  ; Adjust the movement speed (decrease by 2 pixels)
    cmp ax, [Window_Bounds]  ; Check if the paddle would go above the top boundary
    jge Update_Paddle_Y_Right
    mov ax, [Window_Bounds]  ; Clamp the paddle to the top boundary


Update_Paddle_Y_Right:
    mov [PADDLE_RIGHT_Y], ax
    jmp EXIT_PADDLE_MOVEMENT

MOVE_RIGHT_PADDLE_DOWN:

    ; Move the left paddle down
    mov ax, [PADDLE_RIGHT_Y]
    add ax, 5  ; Adjust the movement speed (increase by 2 pixels)
    mov bx, [Window_Height]
    sub bx, [Window_Bounds]
    sub bx, [PADDLE_HEIGHT]  ; Calculate the bottom boundary
    cmp ax, bx  ; Check if the paddle would go below the bottom boundary
    jle Update_Paddle_Y_Right
    mov ax, bx  ; Clamp the paddle to the bottom boundary



EXIT_PADDLE_MOVEMENT:

    ret



    