;* This was extracted from a disk image provided by
;* Gene Buckle on 12/29/23. The disk label is:
;* 86-DOS_v0.34_#221_-_81-02-20.imd
;
;* The boot loader is loaded @ 200h and it loads the
;* combined dosio + 86dos starting @ 400h. In v034,
;* DOSIO ends around 6C3h (2C3h/707) bytes. There is
;* an additional 3Ch bytes of unknown (slack?). As a
;* marker, the conditional "IF COMBCRO" starts at 6B0h.
;
TITLE dosio.asm

; I/O System for 86-DOS.

; Assumes a CPU Support card at F0 hex for character I/O,
; with disk drivers for Tarbell or Cromemco controllers.

; Select disk controller here
TARBELL:EQU     0
CROMEMCO:EQU    1

; For either disk controller, a custom drive table may be defined
CUSTOM: EQU     0

; If Tarbell disk controller, select one-sided or two-sided drives
; and single or double density controller
DOUB1SIDE:EQU   0
DOUB2SIDE:EQU   0
SNGL1SIDE:EQU   0

; If Cromemco disk controller, select drive configuration
SMALLCRO:EQU    0               ;3 small drives
COMBCRO:EQU     1               ;2 large drives and 1 small one
LARGECRO:EQU    0               ;4 large drives

;Use table below to select head step speed. Step times for 5" drives are double
;that shown in the table. Times for Fast Seek mode (Cromemco controller with
;PerSci drives) is very small - 200-400 microseconds.

; Step value    1771    1791

;     0          6ms     3ms
;     1          6ms     6ms
;     2         10ms    10ms
;     3         20ms    15ms

STPSPD: EQU     2


;Some drives require a delay between writing and stepping so that the tunnel
;erase operation does not smear across data. If needed, set ERASE to 1 and
;set WRTDLY for the amount of the delay (software loop). For a given delay in
;microseconds, WRTDLY = (delay * 8) / 18.

ERASE:  EQU     0
WRTDLY: EQU     236     ;530 microseconds


;Some disk drives cannot be driven at full speed (6 tracks/sec), even if the
;full head step delay is used. To slow them down, a "verify" can be performed
;after each head step during a continuous read or write operation. Select by
;setting VERIFY to VERON, disable with VEROFF.

VERON:  EQU     STPSPD+4
VEROFF: EQU     0

VERIFY: EQU     VEROFF

;****************************************************************************

WD1791: EQU     DOUB1SIDE+DOUB2SIDE
WD1771: EQU     CROMEMCO+SNGL1SIDE

        IF      WD1791
READCOM:EQU     80H
WRITECOM:EQU    0A0H
        ENDIF

        IF      WD1771
READCOM:EQU     88H
WRITECOM:EQU    0A8H
        ENDIF

        IF      TARBELL
DONEBIT:EQU     80H
DISK:   EQU     78H
        ENDIF

        IF      CROMEMCO
DONEBIT:EQU     1
DISK:   EQU     30H
        ENDIF

DOSSEG: EQU     80H

        ORG     0
        PUT     100H

BASE:   EQU     0F0H
STAT:   EQU     BASE+7
DAV:    EQU     2
TBMT:   EQU     1
DATA:   EQU     BASE+6
PSTAT:  EQU     BASE+0DH
PDATA:  EQU     BASE+0CH

        JMP     INIT    ;0
        JMP     STATUS  ;3
        JMP     INP     ;6
        JMP     OUTP    ;9
        JMP     PRINT   ;c
        JMP     AUXIN   ;f
        JMP     AUXOUT  ;12
        JMP     READ    ;15
        JMP     WRITE   ;18
        JMP     RETL    ;1b

INIT:
        MOV     AX,CS           ;Get current segment
        MOV     DS,AX
        MOV     SS,AX
        MOV     SP,STACK
        MOV     SI,INITTAB
        CALL    0,DOSSEG
        MOV     DX,100H
        MOV     AH,26           ;Set DMA address
        INT     21H
        MOV     BX,DS           ;Save segment for later
;DS must be set to CS so we can point to the FCB
        MOV     AX,CS
        MOV     DS,AX
        MOV     DX,FCB          ;File Control Block for COMMAND.COM
        MOV     AH,15
        INT     21H             ;Open COMMAND.COM
        OR      AL,AL
        JNZ     COMERR          ;Error if file not found
        MOV     [FCB+33],0      ;Set 3-byte Random Record field to
        MOV     B,[FCB+35],0    ;   beginning of file
        MOV     CX,200H         ;Load maximum records
        MOV     AH,39           ;Block read
        INT     21H
        JCXZ    COMERR          ;Error if no records read
        CMP     AL,1
        JNZ     COMERR          ;Error if not end-of-file
;Make all segment registers the same
        MOV     DS,BX
        MOV     ES,BX
        MOV     SS,BX
        MOV     SP,5CH          ;Set stack to standard value
        XOR     AX,AX
        PUSH    AX              ;Put zero on top of stack for return
        MOV     DX,80H
        MOV     AH,26
        INT     21H             ;Set default transfer address (DS:0080)
        PUSH    BX              ;Put segment on stack
        MOV     AX,100H
        PUSH    AX              ;Put address to execute within segment on stack
        RET     L               ;Jump to COMMAND

COMERR:
        MOV     DX,BADCOM
        MOV     AH,9            ;Print string
        INT     21H
        EI
STALL:  JP      STALL

BADCOM: DB      13,10,"Bad or missing Command Interpreter",13,10,"$"
FCB:    DB      1,"COMMAND COM"
        DS      24

STATUS:
        IN      STAT
        AND     AL,DAV
        RET     L

AUXIN:
INP:
        IN      STAT
        AND     AL,DAV
        JZ      INP
        IN      DATA
        AND     AL,7FH
        RET     L

AUXOUT:
OUTP:
        PUSH    AX
OUTLP:
        IN      STAT
        AND     AL,TBMT
        JZ      OUTLP
        POP     AX
        OUT     DATA
        RET     L

PRINT:
        PUSH    AX
PRINLP:
        IN      PSTAT
        AND     AL,TBMT
        JZ      PRINLP
        POP     AX
        OUT     PDATA
        RET     L

READ:
        CALL    SEEK            ;Position head
        JC      ERROR
RDLP:
        PUSH    CX
        CALL    READSECT        ;Perform sector read
        POP     CX
        JC      ERROR
        INC     DH              ;Next sector number
        ADD     SI,128          ;Bump address for next sector
        LOOP    RDLP            ;Read each sector requested
        OR      AL,AL
RETL:   RET     L

WRITE:
        CALL    SEEK            ;Position head
        JC      ERROR
WRTLP:
        PUSH    CX
        CALL    WRITESECT       ;Perform sector write
        POP     CX
        JC      ERROR
        INC     DH              ;Bump sector counter
        ADD     SI,128          ;Bump address
        LOOP    WRTLP           ;Write CX sectors
        OR      AL,AL
        RET     L

ERROR:
        SEG     CS
        MOV     B,[DI],-1
        RET     L

SEEK:

; Inputs:
;       AL = Drive number
;       BX = Disk transfer address in DS
;       CX = Number of sectors to transfer
;       DX = Logical record number of transfer
; Function:
;       Seeks to proper track.
; Outputs:
;       AH = Drive select byte
;       DL = Track number
;       DH = Sector number
;       SI = Disk transfer address in DS
;       DI = pointer to drive's track counter in CS
; CX unchanged.

        MOV     AH,AL
        SEG     CS
        XCHG    AL,[CURDRV]
        CMP     AL,AH           ;Changing drives?
        JZ      SAMDRV
;If changing drives, unload head so the head load delay one-shot
;will fire again. Do it by seeking to same track the H bit reset.
        IN      DISK+1          ;Get current track number
        OUT     DISK+3          ;Make it the track to seek to
        MOV     AL,10H          ;Seek and unload head
        CALL    DCOM
        MOV     AL,AH           ;Restore current drive number
SAMDRV:
        MOV     SI,BX           ; Save transfer address
        CBW
        MOV     BX,AX           ; Prepare to index on drive number
        SEG     CS
        MOV     AL,[BX+DRVTAB]
        OUT     DISK+4          ; Select drive

        IF      CROMEMCO
        OR      AL,80H          ;Set auto-wait bit
        ENDIF

        MOV     AH,AL           ;Save for later
        XCHG    AX,DX
        MOV     DL,26           ;26 sectors per track

        IF      CROMEMCO
        TEST    DH,10H          ;Check if small disk
        JNZ     BIGONE
        MOV     DL,18           ;18 sectors on small disk track
BIGONE:
        ENDIF

        DIV     AL,DL           ;Compute track and sector
        XCHG    AX,DX
        INC     DH              ;First sector is 1, not zero
        SEG     CS
        MOV     BL,[BX+TRKPT]   ;Get this drive's displacement into track table
        ADD     BX,TRKTAB       ;BX now points to track counter for this drive
        MOV     DI,BX
        MOV     AL,DL
        SEG     CS
        XCHG    AL,[DI]         ;Xchange current track with desired track
        OUT     DISK+1          ;Inform controller chip of current track
        CMP     AL,DL
        JZ      ONTRK
        MOV     BH,3            ;Seek retry count
        CMP     AL,-1           ;Head position known?
        JNZ     NOHOME          ;If not, home head
TRYSK:
        CALL    HOME
NOHOME:
        MOV     AL,DL
        OUT     DISK+3
        MOV     AL,1CH+STPSPD
        CALL    MOVHEAD
        AND     AL,98H
        JZ      ONTRK
        DEC     BH
        JNZ     TRYSK
        STC
ONTRK:
        RET

SETUP:
        MOV     AL,0D0H         ;Force Interrupt command
        OUT     DISK            ;so Type I status will be available
        PUSH    AX
        AAM                     ;Pause 10 microseconds
        POP     AX

        IF      CROMEMCO
        TEST    AH,10H          ;Check for small disk
        JNZ     CHKSTP
        CMP     DH,18           ;Only 18 sectors/track on small ones
        JA      STEP
CHKSTP:
        ENDIF

        CMP     DH,26           ;Check for overflow onto next track
        JBE     PUTSEC
STEP:
        INC     DL
        MOV     DH,1
        MOV     AL,58H+VERIFY   ;Step in with update
        CALL    STPHEAD
        SEG     CS
        INC     B,[DI]          ;Update track counter
PUTSEC:
        MOV     AL,DH
        OUT     DISK+2

        IF      CROMEMCO
        MOV     AL,AH
        OUT     DISK+4          ;Turn on auto-wait
        ENDIF

        IN      DISK            ;Get head load bit
        NOT     AL
        AND     AL,20H          ;Check head load status
        JZ      RET
        MOV     AL,4
        RET

READSECT:
        CALL    SETUP
        MOV     BL,10
RDAGN:
        OR      AL,READCOM
        OUT     DISK
        MOV     CX,80H
        PUSH    SI
RLOOP:
        IN      DISK+4
        TEST    AL,DONEBIT

        IF      TARBELL
        JZ      RDONE
        ENDIF

        IF      CROMEMCO
        JNZ     RDONE
        ENDIF

        IN      DISK+3
        MOV     [SI],AL
        INC     SI
        LOOP    RLOOP
RDONE:
        POP     SI
        CALL    GETSTAT
        AND     AL,9CH
        JZ      RET
        MOV     AL,0
        DEC     BL
        JNZ     RDAGN
        STC
        RET

WRITESECT:
        CALL    SETUP
        MOV     BL,10
WRTAGN:
        OR      AL,WRITECOM
        OUT     DISK
        MOV     CX,80H
        PUSH    SI
WRLOOP:
        IN      DISK+4
        TEST    AL,DONEBIT
        
        IF      TARBELL
        JZ      WRDONE
        ENDIF

        IF      CROMEMCO
        JNZ     WRDONE
        ENDIF

        LODB
        OUT     DISK+3
        LOOP    WRLOOP
WRDONE:
        POP     SI
        CALL    GETSTAT
        AND     AL,0FCH
        JZ      RET
        MOV     AL,0
        DEC     BL
        JNZ     WRTAGN
        STC
        RET

HOME:
        IF      CROMEMCO
        TEST    AH,40H          ;Check seek speed bit
        JNZ     RESTORE
        ENDIF

        MOV     BL,3
TRYHOM:
        MOV     AL,0CH+STPSPD
        CALL    STPHEAD
        AND     AL,98H
        JZ      RET
        MOV     AL,58H+STPSPD   ;Step in with update
        CALL    DCOM
        DEC     BL
        JNZ     TRYHOM
        RET

MOVHEAD:
        IF      CROMEMCO
        TEST    AH,40H          ;Check seek speed bit
        JNZ     FASTSK
        ENDIF

STPHEAD:
        IF      ERASE
        PUSH    AX
        MOV     AX,WRTDLY
DLYLP:
        DEC     AX
        JNZ     DLYLP
        POP     AX
        ENDIF

DCOM:
        OUT     DISK
        PUSH    AX
        AAM                     ;Delay 10 microseconds
        POP     AX
GETSTAT:
        IN      DISK+4
        TEST    AL,DONEBIT

        IF      TARBELL
        JNZ     GETSTAT
        ENDIF

        IF      CROMEMCO
        JZ      GETSTAT
        ENDIF

        IN      DISK
        RET

        IF      CROMEMCO
RESTORE:
        MOV     AL,0C4H         ;READ ADDRESS command to keep head loaded
        OUT     DISK
        MOV     AL,77H
        OUT     4
CHKRES:
        IN      4
        AND     AL,40H
        JZ      RESDONE
        IN      DISK+4
        TEST    AL,DONEBIT
        JZ      CHKRES
        IN      DISK
        JP      RESTORE         ;Reload head
RESDONE:
        MOV     AL,7FH
        OUT     4
        CALL    GETSTAT
        MOV     AL,0
        OUT     DISK+1          ;Tell 1771 we're now on track 0
        RET

FASTSK:
        MOV     AL,6FH
        OUT     4
        MOV     AL,18H
        CALL    DCOM
SKWAIT:
        IN      4
        TEST    AL,40H
        JNZ     SKWAIT
        MOV     AL,7FH
        OUT     4
        MOV     AL,0
        RET
        ENDIF

        DS      20H
STACK:

LFAT:   EQU     300H
SFAT:   EQU     200H

CURDRV: DS      1

LDRIVE:
        DB      1       ;Records/sector
        DB      4       ;Records/cluster
        DW      52      ;Reserved records
        DB      6       ;FAT size (records)
        DB      2       ;Number of FATs
        DB      8       ;Number of directory records
        DW      482     ;Number of clusters on drive

SDRIVE:
        DB      1
        DB      2
        DW      54
        DB      4
        DB      2
        DB      8
        DW      325

        IF      DOUB1SIDE
DRVTAB: DB      0,10H,20H,30H
TRKPT:  DB      0,1,2,3
TRKTAB: DB      -1,-1,-1,-1
        ENDIF

        IF      DOUB2SIDE
DRVTAB: DB      0,40H,10H,50H
TRKPT:  DB      0,0,1,1
TRKTAB: DB      -1,-1
        ENDIF

        IF      SNGL1SIDE
DRVTAB: DB      0F2H,0E2H,0D2H,0C0H
TRKPT:  DB      0,1,2,3
TRKTAB: DB      -1,-1,-1,-1
        ENDIF

        IF      TARBELL
INITTAB:DB      4       ;Number of drives
        DW      LDRIVE
        DW      FAT0
        DW      LDRIVE
        DW      FAT1
        DW      LDRIVE
        DW      FAT2
        DW      LDRIVE
        DW      FAT3

        ORG     0
FAT0:   DS      LFAT
FAT1:   DS      LFAT
FAT2:   DS      LFAT
FAT3:   DS      LFAT
        ENDIF

; Cromemco drive select byte is derived as follows:
;       Bit 7 = 0
;       Bit 6 = 1 if fast seek (PerSci)
;       Bit 5 = 1 (motor on)
;       Bit 4 = 0 for 5", 1 for 8" drives
;       Bit 3 = 1 for drive 3
;       Bit 2 = 1 for drive 2
;       Bit 1 = 1 for drive 1
;       Bit 0 = 1 for drive 0

        IF      LARGECRO
; Table for four large drives
DRVTAB: DB      71H,72H,74H,78H
TRKPT:  DB      0,0,1,1
TRKTAB: DB      -1,-1
INITTAB:DB      4       ;Number of drives
        DW      LDRIVE
        DW      FAT0
        DW      LDRIVE
        DW      FAT1
        DW      LDRIVE
        DW      FAT2
        DW      LDRIVE
        DW      FAT3

        ORG     0
FAT0:   DS      LFAT
FAT1:   DS      LFAT
FAT2:   DS      LFAT
FAT3:   DS      LFAT
        ENDIF

        IF      COMBCRO
; Table for two large drives and one small one
DRVTAB: DB      71H,72H,24H
TRKPT:  DB      0,0,1
TRKTAB: DB      -1,-1
INITTAB:DB      3       ;Number of drives
        DW      LDRIVE
        DW      FAT0
        DW      LDRIVE
        DW      FAT1
        DW      SDRIVE
        DW      FAT2

        ORG     0
FAT0:   DS      LFAT
FAT1:   DS      LFAT
FAT2:   DS      SFAT
        ENDIF

        IF      SMALLCRO
; Table for 3 small drives
DRVTAB: DB      21H,22H,24H
TRKPT:  DB      0,1,2
TRKTAB: DB      -1,-1,-1
INITTAB:DB      3d
        DW      SDRIVE
        DW      FAT0
        DW      SDRIVE
        DW      FAT1
        DW      SDRIVE
        DW      FAT2

        ORG     0
FAT0:   DS      SFAT
FAT1:   DS      SFAT
FAT2:   DS      SFAT
        ENDIF

        IF      CUSTOM
; Table for 2 large drives without fast seek
DRVTAB: DB      31H,32H
TRKPT:  DB      0,1
TRKTAB: DB      -1,-1

INITTAB:DB      2
        DW      LDRIVE
        DW      FAT0
        DW      LDRIVE
        DW      FAT1

        ORG     0
FAT0:   DS      LFAT
FAT1:   DS      LFAT
        ENDIF
