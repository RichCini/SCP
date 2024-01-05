
			TITLE 86dos.asm
			;
			;* This was extracted from a disk image provided by
			;* Gene Buckle on 12/29/23. The disk label is:
			;* 86-DOS_v0.34_#221_-_81-02-20.imd
			;
			;* This file is a raw disassembly from the sectors
			;* loaded from the disk using the debug "L" command
			;* to load the sectors. The monitor loads BOOT to 
			;* 200H. BOOT then loads DOSIO/86DOS to 400h. 86DOS
			;* begins at 800H. Later versions have the BIOSSEG @600H
			;
			;* The boot code loads 51 contiguous sectors which is 
			;* 6528 bytes. The layout is:
			;*
			;*	DOSIO	400h - 6FFh (767)	 5 sectors
			;*	slack	700h - 7ffh (128)	 1
			;*	86DOS	800h - 1600h (3584)	28  
			;*	slack  1600h - 1700h (256)	 2
			;*
			;*	This results in an even number of allocation
			;*	clusters 36/4=9.
			;
			;* The text strings in the slack area is curious because they
			;* are x86 nemonics which don't appear in the 1.0 or
			;* 1.14 sources.
			;
			;* DOSINIT is at the end of the source but is re-ORGed
			;* so that it overlaps and relocates the code down by
			;* 800H.
			;*
			;* In the later code, there are compilation switches:
			;*	LOOKS LIKE DEFS ARE 	IBM=FALSE
			;*				DSKTEST=FALSE
			;*				HIGHMEM=FALSE
			;*				ZEROEXT=TRUE
			FALSE	EQU	0
			TRUE	EQU	1

			BKSPACE EQU	8
			HTAB	EQU	9
			ESCCH   EQU     1BH
			CANCEL  EQU     "X"-"@"         ;Cancel with Ctrl-X

			MAXCALL EQU     36
			MAXCOM  EQU     41
			INTBASE EQU     80H
			INTTAB  EQU     20H
			ENTRYPOINTSEG   EQU     0CH
			ENTRYPOINT      EQU     INTBASE+40H
			CONTC   EQU     INTTAB+3
			EXIT    EQU     INTBASE+8
			LONGJUMP EQU    0EAH
			LONGCALL EQU    9AH
			MAXDIF  EQU     0FFFH
			SAVEXIT EQU     10

			; Field definition for FCBs

			FNAME   EQU     0       ;Drive code and name
			EXTENT  EQU     12	;0C
			;RECSIZ  EQU     14      ;Size of record (user settable)
			;14
			FILSIZ  EQU     16      ;10 Size of file in bytes
			RECSIZ	EQU	18	;12
			;FILSIZ  EQU     16      ;10 Size of file in bytes
			;DRVBP   EQU     18      ;12 BP for SEARCH FIRST and SEARCH NEXT
			;FDATE   EQU     20      ;14 Date of last writing
			;FTIME   EQU     22      ;16 Time of last writing
			;DEVID   EQU     22      ; 16 Device ID number, bits 0-5
						;bit 7=0 for file, bit 7=1 for I/O device
						;If file, bit 6=0 if dirty
						;If I/O device, bit 6=0 if EOF (input)
			;FIRCLUS EQU     24      ;18 First cluster of file
			FIRCLUS	EQU	20	;14
			;LSTCLUS EQU     26      ;1a Last cluster accessed
			LSTCLUS	EQU	22	;16
			;CLUSPOS EQU     28      ;1c Position of last cluster accessed
			FILSIZ	EQU	24	;18
			CLUSPOS	EQU	26	;1a
			;		28	;1c
			;		29	;1d
			NR      EQU     32      ;20 Next record
			RR      EQU     33      ;21 Random record
			FILDIRENT EQU	20	;Used only by SEARCH FIRST and SEARCH NEXT

			; Field definition for Drive Parameter Block
			; ***BUGBUG - these need to be checked
			DEVNUM  EQU     0       ;I/O driver number
			DRVNUM  EQU     0       ;Physical Unit number
			SECSIZ  EQU     1       ;Size of physical sector in bytes
			CLUSMSK EQU     3       ;Sectors/cluster - 1
			;CLUSSHFT EQU    4       ;Log2 of sectors/cluster
			FIRFAT  EQU     4       ;Starting record of FATs
			FATCNT  EQU     7       ;Number of FATs for this drive
			MAXENT  EQU     8       ;Number of directory entries
			;FIRREC  EQU     10      ;First sector of first cluster
			;MAXCLUS EQU     12      ;Number of clusters on drive + 1
			FATSIZ  EQU     6      ;Number of records occupied by FAT
			FIRDIR  EQU     8      ;Starting record of directory
			FAT     EQU     10      ;Pointer to start of FAT
			MAXDRV	EQU	11
			;DPBSIZ  EQU     20      ;Size of the structure in bytes

			; BOIS entry point definitions
			BIOSSEG EQU     40H
			BIOSINIT        EQU     0       ;Reserve room for jump to init code
			BIOSSTAT        EQU     3       ;Console input status check
			BIOSIN          EQU     6       ;Get console character
			BIOSOUT         EQU     9       ;Output console character
			BIOSPRINT       EQU     12      ;0C Output to printer
			BIOSAUXIN       EQU     15      ;0F Get byte from auxilliary
			BIOSAUXOUT      EQU     18      ;12 Output byte to auxilliary
			BIOSREAD        EQU     21      ;15 Disk read
			BIOSWRITE       EQU     24      ;18 Disk write
			BIOSRETL	EQU	27	;1b ??

			; Location of user registers relative user stack pointer
			; ***BUGBUG - these need to be fixed
			AXSAVE  EQU     0
			BXSAVE  EQU     2
			CXSAVE  EQU     4
			DXSAVE  EQU     6
			SISAVE  EQU     8
			DISAVE  EQU     10
			BPSAVE  EQU     12
			DSSAVE  EQU     14
			ESSAVE  EQU     16
			IPSAVE  EQU     18
			CSSAVE  EQU     20
			FSSAVE  EQU     22

			; Directory entry - 16 bytes in this version
			; ***BUGBUG - need to reconcile this to the fields in the code
			; In MSDOS, attributes is followed by zeros and the FAT pointer
			; is at offset 1Ah.
			FNAME	EQU	0	;00-07	filename
			FEXT	EQU	8	;08-0A	extension
			FATTR	EQU	11	;0B	attributes
			FPTR 	EQU	12	;0C-0D	pointer to the FAT chain
			FRESV	EQU	14	;0E-0F	reserved, 0

			ORG 0
		CODSTRT EQU $
046F:0800 E96000        JMP     DOSINIT		;0863

		; 0803
		ESCTAB:
			DB      "SC"     ;Copy one character from template
			DB      "VN"     ;Skip over one character in template
			DB      "TA"     ;Copy up to specified character
			DB      "WB"     ;Skip up to specified character
			DB      "UH"     ;Copy rest of template
			DB      "HH"     ;Kill line with no change in template (Ctrl-X)
			DB      "RM"     ;Cancel line and update template
			DB      "DD"     ;Backspace (same as Ctrl-H)
			DB      "P@"     ;Enter Insert mode
			DB      "QL"     ;Exit Insert mode
			DB      1BH,1BH  ;Escape sequence to represent escape character
			DB      ESCCH,ESCCH
		ESCTABLEN EQU   $-ESCTAB

		; 81bb
		HEADER: DB      13,10,"86-DOS version 0.34"
        		DB      13,10
        		DB      "Copyright 1980 Seattle Computer Products, Inc.",13,10,"$"

		; DOSINIT code in v114 is at the end of the source file and is ORGed
		; to overlay the data area at the end of the object file.
		DOSINIT:
046F:0863 FA            DI                              
046F:0864 FC            UP                              
046F:0865 8CC8          MOV     AX,CS                   
046F:0867 8EC0          MOV     ES,AX                   
046F:0869 AC            LODB                            
046F:086A 98            CBW                             
046F:086B 8BC8          MOV     CX,AX                   
046F:086D 2E            SEG     CS                      
046F:086E A2920F        MOV     [0F92],AL 	;numio
046F:0871 8BF8          MOV     DI,AX                   
046F:0873 D1E7          SHL     DI                      
046F:0875 B412          MOV     AH,12                   
046F:0877 F6E4          MUL     AL,AH                   
046F:0879 BB0610        MOV     BX,1006 	;drvtab
046F:087C 03FB          ADD     DI,BX                   
046F:087E 03C7          ADD     AX,DI                   
046F:0880 8BE8          MOV     BP,AX                   
046F:0882 2E            SEG     CS                      
046F:0883 A3110E        MOV     [0E11],AX

		LAB200:
046F:0886 2E            SEG     CS                      
046F:0887 893F          MOV     [BX],DI                 
046F:0889 43            INC     BX                      
046F:088A 43            INC     BX                      
046F:088B 8AC5          MOV     AL,CH        ;CH=drive count           
046F:088D AA            STOB                            
046F:088E AD            LODW                            
046F:088F 56            PUSH    SI                      
046F:0890 8BF0          MOV     SI,AX

		NOTMAX:
046F:0892 A4            MOVB                            
046F:0893 AC            LODB                            
046F:0894 FEC8          DEC     AL                      
046F:0896 AA            STOB                            
046F:0897 98            CBW

		FIGSHFT:
046F:0898 FEC4          INC     AH                      
046F:089A D0F8          SAR     AL                      
046F:089C 75FA          JNZ     FIGSHFT		;0898
046F:089E 8AC4          MOV     AL,AH

		HAVSHFT:
046F:08A0 AA            STOB                            
046F:08A1 AD            LODW                            
046F:08A2 AB            STOW                            
046F:08A3 8BD0          MOV     DX,AX                   
046F:08A5 AC            LODB                            
046F:08A6 AA            STOB                            
046F:08A7 8AE0          MOV     AH,AL                   
046F:08A9 50            PUSH    AX                      
046F:08AA AC            LODB                            
046F:08AB AA            STOB                            
046F:08AC F6E4          MUL     AL,AH                   
046F:08AE 03C2          ADD     AX,DX                   
046F:08B0 AB            STOW                            
046F:08B1 8BD0          MOV     DX,AX                   
046F:08B3 AC            LODB                            
046F:08B4 AA            STOB                            
046F:08B5 98            CBW                             
046F:08B6 03C2          ADD     AX,DX                   
046F:08B8 AB            STOW                            
046F:08B9 5A            POP     DX                      
046F:08BA AD            LODW                            
046F:08BB 40            INC     AX                      
046F:08BC AB            STOW                            
046F:08BD 32C0          XOR     AL,AL                   
046F:08BF AA            STOB                            
046F:08C0 5E            POP     SI                      
046F:08C1 AD            LODW                            
046F:08C2 2E            SEG     CS                      
046F:08C3 0306110E      ADD     AX,[0E11]               
046F:08C7 AB            STOW                            
046F:08C8 B200          MOV     DL,00                   
046F:08CA D1EA          SHR     DX                      
046F:08CC 03C2          ADD     AX,DX                   
046F:08CE 3BC5          CMP     AX,BP                   
046F:08D0 7602          JBE     LAB201		;08D4                    
046F:08D2 8BE8          MOV     BP,AX
		LAB201:
046F:08D4 FEC5          INC     CH                      
046F:08D6 FEC9          DEC     CL                      
046F:08D8 75AC          JNZ     LAB200	;0886

		; this is within LAB210 in the v.114 code
		LAB210:
046F:08DA 83C50F        ADD     BP,+0F                  
046F:08DD B104          MOV     CL,04                   
046F:08DF D3ED          SHR     BP,CL                   
046F:08E1 33C0          XOR     AX,AX                   
046F:08E3 8ED8          MOV     DS,AX                   
046F:08E5 8EC0          MOV     ES,AX                   
046F:08E7 BF8000        MOV     DI,INITBASE	;0080          
046F:08EA B87001        MOV     AX,QUIT		;0170
046F:08ED AB            STOW                            
046F:08EE 8CC8          MOV     AX,CS                   
046F:08F0 C606C000EA    MOV     B,[ENTRYPOINT],LONGJUMP	;c0
046F:08F5 C706C1007C01  MOV     W,[ENTRYPOINT+1],ENTRY	;c1,017C
046F:08FB 8C0EC300      MOV     [ENTRYPOINT+3],CS	;c3    
046F:08FF AB            STOW                            
046F:0900 AB            STOW                            
046F:0901 AB            STOW                            
046F:0902 C70684007401  MOV     W,[INTBASE+4],COMMAND	;0174 0084
046F:0908 BF9400        MOV     DI,0094                 ; BASE+20??
046F:090B B81500        MOV     AX,BIOSREAD		;0015                 
046F:090E AB            STOW                            
046F:090F B84000        MOV     AX,BIOSSEG	;0040
046F:0912 AB            STOW                            
046F:0913 AB            STOW                            
046F:0914 AB            STOW                            
046F:0915 C70698001800  MOV     W,[INTBASE+24],BIOSWRITE	;0018	0098
046F:091B 8CCA          MOV     DX,CS                   
046F:091D 8EDA          MOV     DS,DX                   
046F:091F 03D5          ADD     DX,BP                   
046F:0921 C706A90F8000  MOV     W,[0FA9],0080 	;DMAADD
046F:0927 8916AB0F      MOV     [0FAB],DX       ;DMA+2
046F:092B A10610        MOV     AX,[1006]	; DRVTAB 
046F:092E A30410        MOV     [1004],AX	; CURDRV
046F:0931 8BCA          MOV     CX,DX                   
046F:0933 BB0F00        MOV     BX,000F                 

		LAB220:
046F:0936 41            INC     CX                      
046F:0937 7410          JZ      LAB230	;0949                    
046F:0939 8ED9          MOV     DS,CX                   
046F:093B 8A07          MOV     AL,[BX]                 
046F:093D F6D0          NOT     AL                      
046F:093F 8807          MOV     [BX],AL                 
046F:0941 3A07          CMP     AL,[BX]                 
046F:0943 F6D0          NOT     AL                      
046F:0945 8807          MOV     [BX],AL                 
046F:0947 74ED          JZ      LAB220	;0936  

		LAB230:
046F:0949 2E            SEG     CS                      
046F:094A 890E0F0E      MOV     [ENDMEM],CX        ;0E0F       
046F:094E 33C9          XOR     CX,CX                   
046F:0950 8ED9          MOV     DS,CX                   
046F:0952 C70688000001  MOV     W,[EXIT],0100	;EXIT 0088
046F:0958 89168A00      MOV     [EXIT+2],DX	;EXIT+2   
046F:095C C7068C000001  MOV     W,[008C],0100	;EXIT+4           
046F:0962 89168E00      MOV     [008E],DX	;EXIT+6  
046F:0966 E8EF0B        CALL	SETMEM		;1558                    
046F:0969 BE1B00        MOV     SI,HEADER	;001B
046F:096C E8320B        CALL    OUTMES                    
046F:096F CB            RET     L       

		;8970
		QUIT:
046F:0970 B400          MOV     AH,00                   
046F:0972 EB1E          JP	SAVREGS		;0992
		;974h
		COMMAND:
046F:0974 82FC29        CMP     AH,MAXCOM	;29 
046F:0977 7619          JBE     SAVREGS		;0992                
		BADCALL:
046F:0979 B000          MOV     AL,00
046F:097B CF    IRETT:	IRET             

		;97ch
		ENTRY:
046F:097C 58            POP     AX                      
046F:097D 58            POP     AX                      
046F:097E 2E            SEG     CS                      
046F:097F 8F06AD0F      POP     [0FAD]		;TEMP
046F:0983 9C            PUSHF                           
046F:0984 FA            DI                              
046F:0985 50            PUSH    AX                      
046F:0986 2E            SEG     CS                      
046F:0987 FF36AD0F      PUSH    [0FAD]		;TEMP
046F:098B 82F924        CMP     CL,MAXCALL	;24                  
046F:098E 77E9          JA      BADCALL		;0979                    
046F:0990 8AE1          MOV     AH,CL
		;992h
		SAVREGS:		;switch to separate stack
046F:0992 2E            SEG     CS                      
046F:0993 89260210      MOV     [1002],SP	;SPSAVE
046F:0997 2E            SEG     CS                      
046F:0998 8C160010      MOV     [1000],SS	;SSSAVE       
046F:099C 44            INC     SP                      
046F:099D 44            INC     SP                      
046F:099E 2E            SEG     CS                      
046F:099F 8F06AD0F      POP     [0FAD]		;TEMP
046F:09A3 8CCC          MOV     SP,CS                   
046F:09A5 8ED4          MOV     SS,SP
		;9a7h
		REDISP:
046F:09A7 BC0010        MOV     SP,IOSTACK	;1000
046F:09AA 06            PUSH    ES                      
046F:09AB 1E            PUSH    DS                      
046F:09AC 55            PUSH    BP                      
046F:09AD 57            PUSH    DI                      
046F:09AE 56            PUSH    SI                      
046F:09AF 52            PUSH    DX                      
046F:09B0 51            PUSH    CX                      
046F:09B1 53            PUSH    BX                      
046F:09B2 50            PUSH    AX                      
046F:09B3 8ADC          MOV     BL,AH                   
046F:09B5 B700          MOV     BH,00                   
046F:09B7 D1E3          SHL     BX                      
046F:09B9 FC            UP                              
046F:09BA 2E            SEG     CS                      
046F:09BB FF97D301      CALL    [BX+DISPATCH]	;1d3
		;9bfh
		LLEAVE:
046F:09BF 2E            SEG     CS                      
046F:09C0 A2EE0F        MOV     [0FEE],AL	;REGSAVE+AXSAVE
046F:09C3 58            POP     AX                      
046F:09C4 5B            POP     BX                      
046F:09C5 59            POP     CX                      
046F:09C6 5A            POP     DX                      
046F:09C7 5E            POP     SI                      
046F:09C8 5F            POP     DI                      
046F:09C9 5D            POP     BP                      
046F:09CA 1F            POP     DS                      
046F:09CB 07            POP     ES                      
046F:09CC 17            POP     SS                      
046F:09CD 2E            SEG     CS                      
046F:09CE 8B260210      MOV     SP,[1002]	;SPSAVE
046F:09D2 CF            IRET

		;9d3h
		DISPATCH: 
			DW      ABORT           ;0
        		DW      CONIN
        		DW      CONOUT
        		DW      READER
        		DW      PUNCH
        		DW      LIST            ;5
        		DW      RAWIO
        		DW      RAWINP
        		DW      B_IN
        		DW      PRTBUF
			DW      BUFIN           ;10
        		DW      CONSTAT
       			DW      FLUSHKB
			DW      DSKRESET
			DW      SELDSK
			DW      OPEN            ;15
			DW      CLOSE
			DW      SRCHFRST
			DW      SRCHNXT
			DW      DELETE
			DW      SEQRD           ;20
			DW      SEQWRT
			DW      CREATE
			DW      RENAME
			DW      INUSE
			DW      GETDRV          ;25
			DW      SETDMA
			DW      GETFATPT
			DW      GETFATPTDL
			DW      GETRDONLY
			DW      SETATTRIB       ;30
			DW      GETDSKPT
			DW      USERCODE
			DW      RNDRD
			DW      RNDWRT
			DW      FILESIZE        ;35
			DW      SETRNDREC
			; Extended Functions
			DW      SETVECT
			DW      NEWBASE
			DW      BLKRD
			DW      BLKWRT          ;40
			DW      MAKEFCB

		; Unimplemented calls return 0
		;System call
		RAWINP:
		B_IN:
		FLUSHKB:
		GETFATPTDL:
		GETRDONLY:
		SETATTRIB:
		USERCODE:
0A27 B0 00		MOV	AL,0
0A92			RET

		;System call
		READER:
046F:0A2A 9A0F004000    CALL    BIOSAUXIN,BIOSSEG	;BIOSAUXIN
046F:0A2F C3            RET

		;a30h
		;System call
		PUNCH:
046F:0A30 8AC2          MOV     AL,DL                   
046F:0A32 9A12004000    CALL    BIOSAUXOUT,BIOSSEG       ;BIOSAUXOUT 
046F:0A37 C3            RET                             

		;a38h
		UNPACK:
046F:0A38 3B5E0D        CMP     BX,[BP+0D]              
046F:0A3B 7718          JA      HURTFAT		;0A55                    
046F:0A3D 8D38          LEA     DI,[BX+SI]              
046F:0A3F D1EB          SHR     BX                      
046F:0A41 8B39          MOV     DI,[BX+DI]              
046F:0A43 7309          JNC     HAVCLUS		;0A4E                    
046F:0A45 D1EF          SHR     DI                      
046F:0A47 D1EF          SHR     DI                      
046F:0A49 D1EF          SHR     DI                      
046F:0A4B D1EF          SHR     DI                      
046F:0A4D F9            STC              
		;a4eh
		HAVCLUS:
046F:0A4E D1D3          RCL     BX                      
046F:0A50 81E7FF0F      AND     DI,0FFF                 
046F:0A54 C3            RET

		;a55h
		HURTFAT:
046F:0A55 BEAF0D        MOV     SI,BADFAT 	;0DAF      ;error BADFAT ***
046F:0A58 E8460A        CALL    OUTMES	;14A1
046F:0A5B E91303        JMP     ERROR	;0D71

		;a5eh
		PACK:
046F:0A5E 8BFB          MOV     DI,BX                   
046F:0A60 D1EB          SHR     BX                      
046F:0A62 03DE          ADD     BX,SI                   
046F:0A64 03DF          ADD     BX,DI                   
046F:0A66 D1EF          SHR     DI                      
046F:0A68 8B3F          MOV     DI,[BX]                 
046F:0A6A 730E          JNC     ALIGNED		;0A7A                    
046F:0A6C D1E2          SHL     DX                      
046F:0A6E D1E2          SHL     DX                      
046F:0A70 D1E2          SHL     DX                      
046F:0A72 D1E2          SHL     DX                      
046F:0A74 81E70F00      AND     DI,000F                 
046F:0A78 EB04          JP      PACKIN		;0A7E

		;a7ah
		ALIGNED:
046F:0A7A 81E700F0      AND     DI,F000
		PACKIN:
046F:0A7E 0BFA          OR      DI,DX                   
046F:0A80 893F          MOV     [BX],DI
		RET2:
046F:0A82 C3            RET                             

		; 3-letter device name code is missing here.
		;a83h. Slightly different than GETFILE
		GETNAME:
046F:0A83 E8BA00        CALL    MOVNAME	;0B40                    
046F:0A86 72FA          JC      RET2	;0A82      

		;a88
		FINDNAME:
046F:0A88 8CC8          MOV     AX,CS                   
046F:0A8A 8ED8          MOV     DS,AX                   
046F:0A8C B000          MOV     AL,00
		FND1:
046F:0A8E BB020F        MOV     BX,0F02 	;*** absolute
		FND1A:
046F:0A91 53            PUSH    BX                      
046F:0A92 50            PUSH    AX                      
046F:0A93 E85802        CALL    DSKREAD		;0CEE                    
046F:0A96 58            POP     AX                      
046F:0A97 5B            POP     BX 
		CONTSRCH:
046F:0A98 E80B00        CALL    GETENTRY	;0AA6                    
046F:0A9B 74E5          JZ      RET2	;0A82    
		FND2:
046F:0A9D FEC0          INC     AL                      
046F:0A9F 3A460A        CMP     AL,[BP+0A]              
046F:0AA2 72EA          JC      FND1	;0A8E                    
046F:0AA4 F9            STC
		RET3:
046F:0AA5 C3            RET

		;aa6h
		GETENTRY:
046F:0AA6 83C310        ADD     BX,+10         ; FAT entry is 16 bytes         
046F:0AA9 81FB910F      CMP     BX,0F91                 
046F:0AAD 77F6          JA      RET3		;0AA5 

046F:0AAF 803FE5        CMP     B,[BX],E5	;free entry?         
046F:0AB2 74F2          JZ      GETENTRY		;0AA6                    
046F:0AB4 8BF3          MOV     SI,BX                   
046F:0AB6 BF930F        MOV     DI,0F93		;*** absolute
046F:0AB9 B90B00        MOV     CX,000B
		WILDCRD:
046F:0ABC F3            REPZ                            
046F:0ABD A6            CMPB                            
046F:0ABE 74E5          JZ      RET3		;0AA5                    
046F:0AC0 827DFF3F      CMP     B,[DI-01],"?"	;3F            
046F:0AC4 74F6          JZ      WILDCRD		;0ABC                    
046F:0AC6 EBDE          JP      GETENTRY		;0AA6

		;ac8
		;System call
		DELETE:
046F:0AC8 E8B8FF        CALL    GETNAME		;0A83                    
046F:0ACB 7270          JC      ERRET		;0B3D                    
046F:0ACD 50            PUSH    AX                      
046F:0ACE 53            PUSH    BX                      
046F:0ACF E8D200        CALL    LOC40		;0BA4                    
046F:0AD2 5B            POP     BX 
		DELFILE:
046F:0AD3 C607E5        MOV     B,[BX],E5   	; delete marker            
046F:0AD6 53            PUSH    BX                      
046F:0AD7 8B5F0B        MOV     BX,[BX+0B]              
046F:0ADA 8B7610        MOV     SI,[BP+10]              
046F:0ADD 0BDB          OR      BX,BX                   
046F:0ADF 7408          JZ      DELNXT		;0AE9                    
046F:0AE1 3B5E0D        CMP     BX,[BP+0D]              
046F:0AE4 7703          JA      DELNXT		;0AE9                    
046F:0AE6 E8BC05        CALL    10A5
		DELNXT:
046F:0AE9 5B            POP     BX                      
046F:0AEA E8B9FF        CALL    GETENTRY		;0AA6                    
046F:0AED 74E4          JZ      DELFILE		;0AD3                    
046F:0AEF 58            POP     AX                      
046F:0AF0 50            PUSH    AX                      
046F:0AF1 E81A02        CALL    DIRWRITE	;0D0E                    
046F:0AF4 58            POP     AX                      
046F:0AF5 E8A5FF        CALL    FND2		;0A9D                    
046F:0AF8 50            PUSH    AX                      
046F:0AF9 73D8          JNC     DELFILE		;0AD3                    
046F:0AFB 58            POP     AX                      
046F:0AFC E82901        CALL    FATWRT		;0C28                    
046F:0AFF 32C0          XOR     AL,AL                   
046F:0B01 C3            RET    

		;b02h
		;System call
		RENAME:
046F:0B02 E83B00        CALL    MOVNAME		;0B40                    
046F:0B05 7236          JC      ERRET		;0B3D                    
046F:0B07 83C605        ADD     SI,+05                  
046F:0B0A BF9E0F        MOV     DI,0F9E		;*** absolute
046F:0B0D E84900        CALL    LODNAME		;0B59                    
046F:0B10 E875FF        CALL    FINDNAME	;0A88                    
046F:0B13 7228          JC      ERRET		;0B3D
		REN0:
046F:0B15 8AE0          MOV     AH,AL
		REN1:
046F:0B17 8BFB          MOV     DI,BX                   
046F:0B19 BE9E0F        MOV     SI,0F9E		;*** absolute
046F:0B1C B90B00        MOV     CX,000B         ; 11 chars      
		NEWNAM:
046F:0B1F AC            LODB                            
046F:0B20 3C3F          CMP     AL"?"		;3F
046F:0B22 7402          JZ      NOCHG		;0B26
046F:0B24 8805          MOV     [DI],AL
		;b26
		NOCHG:
046F:0B26 47            INC     DI                      
046F:0B27 E2F6          LOOP    NEWNAM		;0B1F                    
046F:0B29 E87AFF        CALL    GETENTRY		;0AA6                    
046F:0B2C 74E9          JZ      REN1		;0B17                    
046F:0B2E 8AC4          MOV     AL,AH                   
046F:0B30 50            PUSH    AX                      
046F:0B31 E8DA01        CALL    DIRWRITE	;0D0E                    
046F:0B34 58            POP     AX                      
046F:0B35 E865FF        CALL    FND2		;0A9D                    
046F:0B38 73DB          JNC     REN0		;0B15                    
046F:0B3A 32C0          XOR     AL,AL                   
046F:0B3C C3            RET                             
		ERRET:
046F:0B3D B0FF          MOV     AL,FF
		RET5:
046F:0B3F C3            RET

		;b40
		MOVNAME:
046F:0B40 8CC8          MOV     AX,CS                   
046F:0B42 8EC0          MOV     ES,AX                   
046F:0B44 BF930F        MOV     DI,0F93 		;*** absolute
046F:0B47 8BF2          MOV     SI,DX                   
046F:0B49 AC            LODB                            
046F:0B4A 26            SEG     ES                      
046F:0B4B 3806920F      CMP     [0F92],AL		;*** absolute
046F:0B4F 72EE          JC      RET5		;0B3F                    
046F:0B51 98            CBW                             
046F:0B52 95            XCHG    BP,AX                   
046F:0B53 D1E5          SHL     BP                      
046F:0B55 8BAE0410      MOV     BP,[BP+1004]
		LODNAME:
046F:0B59 B90B00        MOV     CX,000B        ;11     
		MOVE2:
046F:0B5C AC            LODB                            
046F:0B5D 247F          AND     AL,7F                   
046F:0B5F 3C60          CMP     AL,60                   
046F:0B61 7E02          JLE     STOLET		;0B65
046F:0B63 245F          AND     AL,5F          
		;b65
		STOLET:
046F:0B65 3C20          CMP     AL," "		;20                   
046F:0B67 72D6          JC      RET5		;0B3F                    
046F:0B69 AA            STOB                            
046F:0B6A E2F0          LOOP    MOVE2		;0B5C    
		RET6:
046F:0B6C C3            RET                             

		;b6d
		;System call
		OPEN:
046F:0B6D 52            PUSH    DX                      
046F:0B6E 1E            PUSH    DS                      
046F:0B6F E811FF        CALL    GETNAME		;0A83 
		DOOPEN:
046F:0B72 07            POP     ES                      
046F:0B73 5F            POP     DI                      
046F:0B74 72C7          JC      ERRET		;0B3D                    
046F:0B76 8A6600        MOV     AH,[BP+00]              
046F:0B79 FEC4          INC     AH                      
046F:0B7B 26            SEG     ES                      
046F:0B7C 8825          MOV     [DI],AH                 
046F:0B7E 26            SEG     ES                      
046F:0B7F C7450C0000    MOV     W,[DI+0C],0000          
046F:0B84 83C710        ADD     DI,+10                  
046F:0B87 8BCB          MOV     CX,BX                   
046F:0B89 81E9120F      SUB     CX,0F12                 
046F:0B8D 8AE1          MOV     AH,CL                   
046F:0B8F AB            STOW                            
046F:0B90 8BC5          MOV     AX,BP                   
046F:0B92 AB            STOW                            
046F:0B93 8D770B        LEA     SI,[BX+0B]              
046F:0B96 AD            LODW                            
046F:0B97 AB            STOW                            
046F:0B98 AB            STOW                            
046F:0B99 AC            LODB                            
046F:0B9A D0E0          SHL     AL                      
046F:0B9C AD            LODW                            
046F:0B9D D1D0          RCL     AX                      
046F:0B9F AB            STOW                            
046F:0BA0 33C0          XOR     AX,AX                   
046F:0BA2 AB            STOW                            
046F:0BA3 AB            STOW
		LOC40:
046F:0BA4 F6460FFF      TEST    B,[BP+0F],FF            
046F:0BA8 75C2          JNZ     RET6		;0B6C                    
046F:0BAA E89D00        CALL    FIGFAT		;0C4A
		LOC41:
046F:0BAD 52            PUSH    DX                      
046F:0BAE 51            PUSH    CX                      
046F:0BAF 53            PUSH    BX                      
046F:0BB0 50            PUSH    AX                      
046F:0BB1 E83D01        CALL    REREAD		;0CF1                    
046F:0BB4 0AC0          OR      AL,AL                   
046F:0BB6 58            POP     AX                      
046F:0BB7 5B            POP     BX                      
046F:0BB8 59            POP     CX                      
046F:0BB9 5A            POP     DX                      
046F:0BBA 7509          JNZ     LOC42		;0BC5                    
046F:0BBC 2A4607        SUB     AL,[BP+07]              
046F:0BBF 74AB          JZ      RET6		;0B6C                    
046F:0BC1 F6D8          NEG     AL                      
046F:0BC3 EB63          JP      FATWRT		;0C28
		LOC42:
046F:0BC5 03D1          ADD     DX,CX                   
046F:0BC7 FEC8          DEC     AL                      
046F:0BC9 75E2          JNZ     LOC41		;0BAD                    
046F:0BCB 5D            POP     BP                      
046F:0BCC BEBB0D        MOV     SI,BADFATS 	;0DBB 15BB - BADFATS ***
046F:0BCF E86301        CALL    ERRARF		;0D35                    
046F:0BD2 EBD0          JP      LOC40		;0BA4    

		;bd4
		;System call
		CLOSE:
046F:0BD4 8BFA          MOV     DI,DX                   
046F:0BD6 F6451CFF      TEST    B,[DI+1C],FF            
046F:0BDA 740D          JZ      NORMFCB3	;0BE9                    
046F:0BDC 57            PUSH    DI                      
046F:0BDD 8B6D12        MOV     BP,[DI+12]              
046F:0BE0 8A4600        MOV     AL,[BP+00]              
046F:0BE3 9A1B004000    CALL    BIOSRETL,BIOSSEG	; BIOSRETL
046F:0BE8 5F            POP     DI

		;be9
		NORMFCB3:
046F:0BE9 F6451DFF      TEST    B,[DI+1D],FF            
046F:0BED 7451          JZ      OKRET		;0C40                    
046F:0BEF 8BD7          MOV     DX,DI                   
046F:0BF1 52            PUSH    DX                      
046F:0BF2 1E            PUSH    DS                      
046F:0BF3 E88DFE        CALL    GETNAME		;0A83                    
046F:0BF6 07            POP     ES                      
046F:0BF7 5F            POP     DI                      
046F:0BF8 7249          JC      BADCLOSE	;0C43                    
046F:0BFA 8BCB          MOV     CX,BX                   
046F:0BFC 81E9120F      SUB     CX,0F12		;*** absolute
046F:0C00 8AE1          MOV     AH,CL                   
046F:0C02 26            SEG     ES                      
046F:0C03 3B4510        CMP     AX,[DI+10]              
046F:0C06 753B          JNZ     BADCLOSE	;0C43                    
046F:0C08 26            SEG     ES                      
046F:0C09 8B4D14        MOV     CX,[DI+14]              
046F:0C0C 894F0B        MOV     [BX+0B],CX              
046F:0C0F 26            SEG     ES                      
046F:0C10 8B5518        MOV     DX,[DI+18]              
046F:0C13 D1EA          SHR     DX                      
046F:0C15 89570E        MOV     [BX+0E],DX              
046F:0C18 B200          MOV     DL,00                   
046F:0C1A D0DA          RCR     DL                      
046F:0C1C 88570D        MOV     [BX+0D],DL              
046F:0C1F E8EC00        CALL    DIRWRITE		;0D0E

		CHKFATWRT:
		; Do FATWRT only if FAT is dirty and uses same I/O driver
046F:0C22 F6460FFF      TEST    B,[BP+0F],FF            
046F:0C26 7418          JZ      OKRET		;0C40            

		;c28
		FATWRT:
046F:0C28 C6460F00      MOV     B,[BP+0F],00            
046F:0C2C E81B00        CALL    FIGFAT		;0C4A   
		;c2f
		EACHFAT:
046F:0C2F 52            PUSH    DX                      
046F:0C30 51            PUSH    CX                      
046F:0C31 53            PUSH    BX                      
046F:0C32 50            PUSH    AX 
		FINDDIR:
046F:0C33 E8DB00        CALL    DWRITE		;0D11          
046F:0C36 58            POP     AX                      
046F:0C37 5B            POP     BX                      
046F:0C38 59            POP     CX                      
046F:0C39 5A            POP     DX                      
046F:0C3A 03D1          ADD     DX,CX                   
046F:0C3C FEC8          DEC     AL                      
046F:0C3E 75EF          JNZ	EACHFAT		;0C2F
		;c40
		OKRET:
046F:0C40 B000          MOV     AL,00                   
046F:0C42 C3            RET

		;c43
		BADCLOSE:
046F:0C43 C6460F00      MOV     B,[BP+0F],00            
046F:0C47 B0FF          MOV     AL,FF                   
046F:0C49 C3            RET                             

		;c4a
		FIGFAT:
046F:0C4A 8A4607        MOV     AL,[BP+FATCNT]		;07
046F:0C4D 8B5E10        MOV     BX,[BP+FAT]		;10
046F:0C50 8A4E06        MOV     CL,[BP+FATSIZ]		;06
046F:0C53 B500          MOV     CH,00                   
046F:0C55 8B5604        MOV     DX,[BP+FIRFAT]		;04
046F:0C58 C3            RET

		;c59
		DIRCOMP:
046F:0C59 8A6600        MOV     AH,[BP+00]	;DEVNUM?
046F:0C5C A3090E        MOV     [0E09],AX	;*** absolute
046F:0C5F 98            CBW                             
046F:0C60 034608        ADD     AX,[BP+DIRDIR]	;08
046F:0C63 8BD0          MOV     DX,AX                   
046F:0C65 BB120F        MOV     BX,0F12		;*** absolute DIRBUF
046F:0C68 B90100        MOV     CX,0001                 
046F:0C6B C3            RET                             

		;c6c
		;System call
		CREATE:
046F:0C6C E8D1FE        CALL    MOVNAME		;B40                    
046F:0C6F 7237          JC      ERRET3		;0CA8                    
046F:0C71 BF930F        MOV     DI,0F93		;NAME1 		;*** absolute
046F:0C74 B90B00        MOV     CX,000B		;11  
046F:0C77 B03F          MOV     AL,"?"		;3F     
046F:0C79 F2            REPNZ                           
046F:0C7A AE            SCAB                            
046F:0C7B 742B          JZ      ERRET3		;0CA8                    
046F:0C7D 52            PUSH    DX                      
046F:0C7E 1E            PUSH    DS                      
046F:0C7F E806FE        CALL    FINDNAME	;0A88                    
046F:0C82 7327          JNC	EXISTENT	;0CAB                    
046F:0C84 8CC8          MOV     AX,CS                   
046F:0C86 8ED8          MOV     DS,AX                   
046F:0C88 33C0          XOR     AX,AX  
		CRE01:
046F:0C8A 50            PUSH    AX                      
046F:0C8B E86000        CALL    DSKREAD		;0CEE                    
046F:0C8E 58            POP     AX                      
046F:0C8F BF020F        MOV     DI,0F02		;*** absolute
046F:0C92 B90800        MOV     CX,0008
		FREESPOT:
046F:0C95 83C710        ADD     DI,+10		;DIRENT size?

		;c98
		LAB090:
046F:0C98 803DE5        CMP     B,[DI],E5	; empty?    
046F:0C9B E0F8          LOOPNZ	FREESPOT	;0C95                    
046F:0C9D 7432          JZ      FREESPOT		;0CD1                    
046F:0C9F FEC0          INC     AL                      
046F:0CA1 3A460A        CMP     AL,[BP+0A]              
046F:0CA4 72E4          JC      CRE01		;0C8A
		ERRPOP:
046F:0CA6 1F            POP     DS                      
046F:0CA7 5A            POP     DX
		ERRET3:
046F:0CA8 B0FF          MOV     AL,FF                   
046F:0CAA C3            RET                             

		;cab
		EXISTENT:
046F:0CAB 33C9          XOR     CX,CX                   
046F:0CAD 894F0D        MOV     [BX+0D],CX              
046F:0CB0 884F0F        MOV     [BX+0F],CL              
046F:0CB3 874F0B        XCHG    CX,[BX+0B]              
046F:0CB6 E333          JCXZ    OPENJMP		;0CEB                    
046F:0CB8 53            PUSH    BX                      
046F:0CB9 50            PUSH    AX                      
046F:0CBA 3B4E0D        CMP     CX,[BP+0D]	;MAXCLUS=11?
046F:0CBD 7727          JA      SMALLENT		;0CE6                    
046F:0CBF 51            PUSH    CX                      
046F:0CC0 E8E1FE        CALL    LOC40		;0BA4                    
046F:0CC3 5B            POP     BX                      
046F:0CC4 8B7610        MOV     SI,[BP+10]              
046F:0CC7 E8DB03        CALL    10A5                    
046F:0CCA E85BFF        CALL    FATWRT		;0C28                    
046F:0CCD 58            POP     AX                      
046F:0CCE 50            PUSH    AX                      
046F:0CCF EB15          JP      SMALLENT		;0CE6

		FREESPOT:
046F:0CD1 8BDF          MOV     BX,DI                   
046F:0CD3 BE930F        MOV     SI,0F93		;1793 BP+FAT 		;*** absolute
046F:0CD6 B90500        MOV     CX,0005                 
046F:0CD9 A4            MOVB                            
046F:0CDA F3            REPZ                            
046F:0CDB A5            MOVW                            
046F:0CDC 86C4          XCHG    AL,AH                   
046F:0CDE B105          MOV     CL,05                   
046F:0CE0 F3            REPZ                            
046F:0CE1 AA            STOB                            
046F:0CE2 86C4          XCHG    AL,AH                   
046F:0CE4 53            PUSH    BX                      
046F:0CE5 50            PUSH    AX 
		SMALLENT:
046F:0CE6 E82500        CALL    DIRWRITE	;0D0E                    
046F:0CE9 58            POP     AX                      
046F:0CEA 5B            POP     BX
		OPENJMP:
046F:0CEB E984FE        JMP     DOOPEN		;0B72

		;cee
		DSKREAD:
046F:0CEE E868FF        CALL	DIRCOMP		;0C59
		REREAD:
046F:0CF1 8A4600        MOV     AL,[BP+DEVNUM]	;0
046F:0CF4 55            PUSH    BP                      
046F:0CF5 53            PUSH    BX                      
046F:0CF6 51            PUSH    CX                      
046F:0CF7 52            PUSH    DX                      
046F:0CF8 9A15004000    CALL    BIOSREAD,BIOSSEG	;BIOSREAD
046F:0CFD 5A            POP     DX                      
046F:0CFE 5F            POP     DI                      
046F:0CFF 5B            POP     BX                      
046F:0D00 5D            POP     BP
046F:0D01 7203          JC      DSKRDERR	;0D06                    
046F:0D03 32C0          XOR     AL,AL                   
046F:0D05 C3            RET                             

		;d06
		DSKRDERR:
046F:0D06 BED80D        MOV     SI,RDERR		;0DD8 error RDERR		;*** absolute
046F:0D09 E82900        CALL	ERRARF			;0D35                    
046F:0D0C EBE3          JP      REREAD			;0CF1 

		;d0e
		DIRWRITE:
046F:0D0E E848FF        CALL    DIRCOMP		;0C59
		DWRITE:
046F:0D11 8A4600        MOV     AL,[BP+DEVNUM]	;0
046F:0D14 B400          MOV     AH,00                   
046F:0D16 3B560B        CMP     DX,[BP+MAXDRV]	;B
046F:0D19 D0DC          RCR     AH                      
046F:0D1B 55            PUSH    BP                      
046F:0D1C 53            PUSH    BX                      
046F:0D1D 51            PUSH    CX                      
046F:0D1E 52            PUSH    DX                      
046F:0D1F 9A18004000    CALL    BIOSWRITE,BIOSSEG	;BIOSWRITE
046F:0D24 5A            POP     DX                      
046F:0D25 5F            POP     DI                      
046F:0D26 5B            POP     BX                      
046F:0D27 5D            POP     BP                      
046F:0D28 7203          JC      DSKWRERR	;0D2D                    
046F:0D2A 32C0          XOR     AL,AL
		RET9A:
046F:0D2C C3            RET                             

		;d2d
		DSKWRERR:
046F:0D2D BEEC0D        MOV     SI,WRTERR	;0DEC error WRTERR		;*** absolute
046F:0D30 E80200        CALL    ERRARF			;0D35                    
046F:0D33 EBDC          JP      DWRITE			;0D11

		;d35
		; Abort, retry, continue, ignore?
		ERRARF:
046F:0D35 2BF9          SUB     DI,CX                   
046F:0D37 03D7          ADD     DX,DI                   
046F:0D39 E86408        CALL    SHIFTDI		;15A0                    
046F:0D3C 03DF          ADD     BX,DI                   
046F:0D3E E86007        CALL    OUTMES
		;d41
		RETRY:
046F:0D41 E82A07        CALL    B_IN		;146E                    
046F:0D44 0C20          OR      AL,20                   
046F:0D46 3C61          CMP     AL,'a'		;61                   
046F:0D48 7427          JZ      ERROR		;0D71                    
046F:0D4A 3C72          CMP     AL,'r'		;72                   
046F:0D4C 74DE          JZ      RET9A		;0D2C                    
046F:0D4E 3C69          CMP     AL,'i'		;69                   
046F:0D50 7408          JZ      DIGNORE		;0D5A                    
046F:0D52 3C63          CMP     AL,'c'		;63                   
046F:0D54 75EB          JNZ     RETRY		;0D41                    
046F:0D56 58            POP     AX                      
046F:0D57 B001          MOV     AL,01                   
046F:0D59 C3            RET                             

		;d5a
		DIGNORE:
046F:0D5A 58            POP     AX                      
046F:0D5B B000          MOV     AL,00                   
046F:0D5D C3            RET                             

		;d5e
		;System call
		ABORT:
046F:0D5E 2E            SEG     CS                      
046F:0D5F 8E1EAD0F      MOV     DS,[0FAD]	;cssave		;*** absolute
046F:0D63 33C0          XOR     AX,AX                   
046F:0D65 8EC0          MOV     ES,AX                   
046F:0D67 BE0A00        MOV     SI,SAVEXIT	;000A
046F:0D6A BF8800        MOV     DI,EXIT		;0088
046F:0D6D A5            MOVW                            
046F:0D6E A5            MOVW                            
046F:0D6F A5            MOVW                            
046F:0D70 A5            MOVW
		;d71
		ERROR:
046F:0D71 BCFA0F        MOV     SP,0FFA		;*** absolute bpsave?
046F:0D74 8CC8          MOV     AX,CS                   
046F:0D76 8ED8          MOV     DS,AX                   
046F:0D78 8EC0          MOV     ES,AX                   
046F:0D7A E82104        CALL	DSKRST01	;119E
046F:0D7D 33C0          XOR     AX,AX                   
046F:0D7F 8ED8          MOV     DS,AX                   
046F:0D81 BE8800        MOV     SI,EXIT		;0088
046F:0D84 BF0B0E        MOV     DI,EXITHOLD	;0E0B 	;exithold
046F:0D87 A5            MOVW                            
046F:0D88 A5            MOVW                            
046F:0D89 5D            POP     BP                      
046F:0D8A 07            POP     ES                      
046F:0D8B 07            POP     ES                      
046F:0D8C 1F            POP     DS                      
046F:0D8D 17            POP     SS                      
046F:0D8E 8B260210      MOV     SP,[1002]		;*** absolute
046F:0D92 8E1EFC0F      MOV     DS,[0FFC]		;*** absolute
046F:0D96 2E            SEG     CS                      
046F:0D97 FF2E0B0E      JMP     L,[EXITHOLD]		;*** absolute

		;d9b
		;System call
		SEQRD:
046F:0D9B E87F02        CALL	GETREC		;101D  
046F:0D9E B90100        MOV     CX,0001                 
046F:0DA1 E8E300        CALL	LOAD		;0E87
046F:0DA4 E348          JCXZ    SETNREX		;0DEE                    
046F:0DA6 40            INC     AX                      
046F:0DA7 EB45          JP      SETNREX		;0DEE    

		;da9
		;System call
		SEQWRT:
046F:0DA9 E87102        CALL	GETREC		;101D  
046F:0DAC B90100        MOV     CX,0001                 
046F:0DAF E87601        CALL	STORE		;0F28
046F:0DB2 E33A          JCXZ    SETNREX		;0DEE                    
046F:0DB4 40            INC     AX                      
046F:0DB5 EB37          JP      SETNREX		;0DEE

		;db7
		;System call
		RNDRD:
046F:0DB7 B90100        MOV     CX,0001                 
046F:0DBA 8BFA          MOV     DI,DX                   
046F:0DBC 8B4521        MOV     AX,[DI+RR]       ;21
046F:0DBF E8C500        CALL	LOAD		;0E87
046F:0DC2 EB26          JP      FINRND		;0DEA    

		;dc4
		;System call
		RNDWRT:
046F:0DC4 B90100        MOV     CX,0001                 
046F:0DC7 8BFA          MOV     DI,DX                   
046F:0DC9 8B4521        MOV     AX,[DI+RR]	; record position
046F:0DCC E85901        CALL	STORE 		;0F28          
046F:0DCF EB19          JP      FINRND		;0DEA   

		;dd1
		;System call
		BLKRD:
046F:0DD1 8BFA          MOV     DI,DX                   
046F:0DD3 8B4521        MOV     AX,[DI+RR]	; record position
046F:0DD6 E8AE00        CALL 	LOAD		;0E87                    
046F:0DD9 EB08          JP      FINBLK		;0DE3  

		;ddb
		;System call
		BLKWRT:
046F:0DDB 8BFA          MOV     DI,DX                   
046F:0DDD 8B4521        MOV     AX,[DI+RR]	; record position
046F:0DE0 E84501        CALL	STORE 		;0F28 
		FINBLK:
046F:0DE3 890EF20F      MOV     [0FF2],CX 	;*** absolute cx save
046F:0DE7 E301          JCXZ    FINRND		;0DEA                    
046F:0DE9 40            INC     AX                      
		FINRND:
046F:0DEA 26            SEG     ES                      
046F:0DEB 894521        MOV     [DI+RR],AX	;save record positon
		;dee
		SETNREX:
046F:0DEE 8BC8          MOV     CX,AX                   
046F:0DF0 247F          AND     AL,7F                   
046F:0DF2 26            SEG     ES                      
046F:0DF3 884520        MOV     [DI+NR],AL	;20
046F:0DF6 80E180        AND     CL,80                   
046F:0DF9 D1C1          ROL     CX                      
046F:0DFB 86CD          XCHG    CL,CH                   
046F:0DFD 26            SEG     ES                      
046F:0DFE 894D0C        MOV     [DI+EXTENT],CX 	;0c
046F:0E01 A0AF0F        MOV     AL,[0FAF]		;*** absolute
		RET7:
046F:0E04 C3            RET                             

		;e05
		SETUP:
046F:0E05 8B6D12        MOV     BP,[DI+RECSIZ]		;12h RECSIZ
		HAVRECSIZ:
046F:0E08 8CDB          MOV     BX,DS                   
046F:0E0A 8EC3          MOV     ES,BX                   
046F:0E0C 8CCB          MOV     BX,CS                   
046F:0E0E 8EDB          MOV     DS,BX                   
046F:0E10 A3B20F        MOV     [0FB2],AX 		;*** absolute
046F:0E13 8916B00F      MOV     [0FB0],DX 		;*** absolute
046F:0E17 8B1EA90F      MOV     BX,[0FA9]		;*** absolute
046F:0E1B 891EB40F      MOV     [0FB4],BX		;*** absolute
046F:0E1F C606AF0F00    MOV     B,[0FAF],00		;*** absolute
046F:0E24 C706BA0F0000  MOV     W,[0FBA],0000		;*** absolute
046F:0E2A 8B7610        MOV     SI,[BP+10]              
046F:0E2D E3D5          JCXZ    RET7		;0E04                    
046F:0E2F 83C37F        ADD     BX,+7F                  
046F:0E32 721D          JC      TRIMM		;0E51                    
046F:0E34 80E380        AND     BL,80                   
046F:0E37 F7DB          NEG     BX                      
046F:0E39 D1C3          ROL     BX                      
046F:0E3B 86DF          XCHG    BL,BH                   
046F:0E3D 7502          JNZ     EOFERR		;0E41                    
046F:0E3F B702          MOV     BH,02
		EOFERR:
046F:0E41 3BCB          CMP     CX,BX                   
046F:0E43 7607          JBE     NOROOM		;0E4C                    
046F:0E45 8BCB          MOV     CX,BX                   
046F:0E47 C606AF0F02    MOV     B,[0FAF],02		;*** absolute
		NOROOM:
046F:0E4C 890EB60F      MOV     [0FB6],CX		;*** absolute
046F:0E50 C3            RET                             
		;e51
		TRIMM:
046F:0E51 C606AF0F02    MOV     B,[0FAF],02 		;*** absolute
046F:0E56 B90000        MOV     CX,0000                 
046F:0E59 5B            POP     BX                      
		RET8:
046F:0E5A C3            RET

		FNDCLUS:
046F:0E5B 26            SEG     ES                      
046F:0E5C 8B5D16        MOV     BX,[DI+LSTCLUS]	;16         
046F:0E5F 26            SEG     ES                      
046F:0E60 8B551A        MOV     DX,[DI+CLUSPOS]	;1A      
046F:0E63 0BDB          OR      BX,BX                   
046F:0E65 741D          JZ      LOCE84		;0E84                    
046F:0E67 2BCA          SUB     CX,DX                   
046F:0E69 7308          JNC     LOCE73		;0E73                    
046F:0E6B 03CA          ADD     CX,DX                   
046F:0E6D 33D2          XOR     DX,DX                   
046F:0E6F 26            SEG     ES                      
046F:0E70 8B5D14        MOV     BX,[DI+FIRCLUS]	;14
		LOCE73:
046F:0E73 E3E5          JCXZ    RET8		;0E5A
		LOOPE75:
046F:0E75 E8C0FB        CALL    UNPACK		;0A38                    
046F:0E78 81FFFF0F      CMP     DI,0FFF                 
046F:0E7C 74DC          JZ      RET8		;0E5A                    
046F:0E7E 87FB          XCHG    DI,BX                   
046F:0E80 42            INC     DX                      
046F:0E81 E2F2          LOOP    LOOPE75		;0E75                    
046F:0E83 C3            RET                             

		LOCE84:
046F:0E84 41            INC     CX                      
046F:0E85 4A            DEC     DX                      
046F:0E86 C3            RET

		;e87
		LOAD:
046F:0E87 E87BFF        CALL    SETUP		;0E05                    
046F:0E8A 26            SEG     ES                      
046F:0E8B 8B5D18        MOV     BX,[DI+18]       ;FileSize+2=recsize?
046F:0E8E 2BD8          SUB     BX,AX                   
046F:0E90 7677          JBE     LOCF09		;0F09                    
046F:0E92 3BD9          CMP     BX,CX                   
046F:0E94 7309          JNC     LOAD01		;0E9F                    
046F:0E96 C606AF0F01    MOV     B,[0FAF],01 		;*** absolute
046F:0E9B 891EB60F      MOV     [0FB6],BX		;*** absolute
		LOAD01:
046F:0E9F 8A4E03        MOV     CL,[BP+03]              
046F:0EA2 D3E8          SHR     AX,CL                   
046F:0EA4 8BC8          MOV     CX,AX                   
046F:0EA6 E8B2FF        CALL    FNDCLUS		;0E5B                    
046F:0EA9 0BC9          OR      CX,CX                   
046F:0EAB 755C          JNZ     LOCF09		;0F09                    
046F:0EAD 8A16B20F      MOV     DL,[0FB2]		;*** absolute
046F:0EB1 225602        AND     DL,[BP+02]              
046F:0EB4 8B0EB60F      MOV     CX,[0FB6]		;*** absolute
		RDLP:
046F:0EB8 E80801        CALL    OPTIMIZE		;0FC3
046F:0EBB 57            PUSH    DI                      
046F:0EBC 50            PUSH    AX                      
046F:0EBD 1E            PUSH    DS                      
046F:0EBE 8E1EAB0F      MOV     DS,[0FAB]		;*** absolute
046F:0EC2 E82CFE        CALL    REREAD		;0CF1                    
046F:0EC5 1F            POP     DS                      
046F:0EC6 59            POP     CX                      
046F:0EC7 5B            POP     BX                      
046F:0EC8 E30D          JCXZ    LOAD03		;0ED7                    
046F:0ECA B200          MOV     DL,00                   
046F:0ECC 81FBFF0F      CMP     BX,0FFF                 
046F:0ED0 75E6          JNZ     RDLP		;0EB8                    
046F:0ED2 C606AF0F01    MOV     B,[0FAF],01		;*** absolute
		;ed7
		LOAD03:
046F:0ED7 A1B80F        MOV     AX,[0FB8]		;*** absolute
046F:0EDA 8B3EB00F      MOV     DI,[0FB0]		;*** absolute
046F:0EDE 26            SEG     ES                      
046F:0EDF 894516        MOV     [DI+16],AX              
046F:0EE2 A1B20F        MOV     AX,[0FB2]		;*** absolute
046F:0EE5 8B1EBA0F      MOV     BX,[0FBA]		;*** absolute
046F:0EE9 03C3          ADD     AX,BX                   
046F:0EEB 26            SEG     ES                      
046F:0EEC 3B4518        CMP     AX,[DI+18]              
046F:0EEF 7609          JBE     LOAD04		;0EFA                    
046F:0EF1 26            SEG     ES                      
046F:0EF2 894518        MOV     [DI+18],AX              
046F:0EF5 26            SEG     ES                      
046F:0EF6 C6451DFF      MOV     B,[DI+1D],FF
		LOAD04:
046F:0EFA 48            DEC     AX                      
046F:0EFB 8BD0          MOV     DX,AX                   
046F:0EFD 8A4E03        MOV     CL,[BP+03]              
046F:0F00 D3EA          SHR     DX,CL                   
046F:0F02 26            SEG     ES                      
046F:0F03 89551A        MOV     [DI+1A],DX              
046F:0F06 8BCB          MOV     CX,BX                   
046F:0F08 C3            RET                             

		;f09
		LOCF09:
046F:0F09 33C9          XOR     CX,CX                   
046F:0F0B EB0E          JP      WRTERRJ		;0F1B
		LOCF0D:
046F:0F0D 8BC8          MOV     CX,AX                   
046F:0F0F 53            PUSH    BX                      
046F:0F10 E862FF        CALL    LOOPE75		;0E75                    
046F:0F13 E343          JCXZ    LOCF58		;0F58                    
046F:0F15 E81601        CALL    ALLOCATE	;102E                    
046F:0F18 5B            POP     BX                      
046F:0F19 733E          JNC     LOCF59		;0F59
		WRTERRJ:
046F:0F1B C606AF0F01    MOV     B,[0FAF],01 		;*** absolute
046F:0F20 A1B20F        MOV     AX,[0FB2]		;*** absolute
046F:0F23 8B3EB00F      MOV     DI,[0FB0]		;*** absolute
046F:0F27 C3            RET                             

		;f28
		; No date stuff
		STORE:
046F:0F28 E8DAFE        CALL    SETUP		;0E05                    
046F:0F2B E356          JCXZ    WRTEOF		;0F83                    
046F:0F2D 8BD9          MOV     BX,CX                   
046F:0F2F 03D8          ADD     BX,AX                   
046F:0F31 4B            DEC     BX                      
046F:0F32 8A4E03        MOV     CL,[BP+03]              
046F:0F35 D3E8          SHR     AX,CL                   
046F:0F37 D3EB          SHR     BX,CL                   
046F:0F39 8BC8          MOV     CX,AX                   
046F:0F3B 8BC3          MOV     AX,BX                   
046F:0F3D E81BFF        CALL    FNDCLUS		;0E5B                    
046F:0F40 2BC2          SUB     AX,DX                  
046F:0F42 7415          JZ      LOCF59		;0F59                    
046F:0F44 E3C7          JCXZ    LOCF0D		;0F0D                    
046F:0F46 51            PUSH    CX                      
046F:0F47 8BC8          MOV     CX,AX                   
046F:0F49 E8E200        CALL    ALLOCATE	;102E                    
046F:0F4C 58            POP     AX                      
046F:0F4D 72CC          JC      WRTERRJ		;0F1B                    
046F:0F4F 8BC8          MOV     CX,AX                   
046F:0F51 49            DEC     CX                      
046F:0F52 7405          JZ      LOCF59		;0F59                    
046F:0F54 E81EFF        CALL    LOOPE75		;0E75                    
046F:0F57 53            PUSH    BX
		LOCF58:
046F:0F58 5B
		LOCF59:
046F:0F59 8A16B20F      MOV     DL,[0FB2]		;*** absolute
046F:0F5D 225602        AND     DL,[BP+02]              
046F:0F60 8B0EB60F      MOV     CX,[0FB6]		;*** absolute
		NOTINBUF:
046F:0F64 E85C00        CALL    OPTIMIZE		;0FC3                    
046F:0F67 57            PUSH    DI                      
046F:0F68 50            PUSH    AX                      
046F:0F69 1E            PUSH    DS                      
046F:0F6A 8E1EAB0F      MOV     DS,[0FAB]		;*** absolute DMAADD
046F:0F6E E8A0FD        CALL    DWRITE		;0D11                    
046F:0F71 1F            POP     DS                      
046F:0F72 59            POP     CX                      
046F:0F73 5B            POP     BX                      
046F:0F74 B200          MOV     DL,00                   
046F:0F76 0BC9          OR      CX,CX                   
046F:0F78 75EA          JNZ     NOTINBUF	;0F64                    
046F:0F7A E85AFF        CALL    LOAD03		;0ED7                    
046F:0F7D 26            SEG     ES                      
046F:0F7E C6451CFF      MOV     B,[DI+1C],FF            
046F:0F82 C3            RET                             

		WRTEOF:
046F:0F83 0BC0          OR      AX,AX                   
046F:0F85 7431          JZ      KILLFIL		;0FB8                    
046F:0F87 48            DEC     AX                      
046F:0F88 8A4E03        MOV     CL,[BP+03]              
046F:0F8B D3E8          SHR     AX,CL                   
046F:0F8D 8BC8          MOV     CX,AX                   
046F:0F8F E8C9FE        CALL    FNDCLUS		;0E5B                    
046F:0F92 E318          JCXZ    RELFILE		;0FAC                    
046F:0F94 E89700        CALL    ALLOCATE	;102E                    
046F:0F97 7282          JC      WRTERRJ		;0F1B
		UPDATE:
046F:0F99 8B3EB00F      MOV     DI,[0FB0]		;*** absolute FCB
046F:0F9D A1B20F        MOV     AX,[0FB2]		;*** absolute BYTPOS
046F:0FA0 26            SEG     ES                      
046F:0FA1 894518        MOV     [DI+18],AX              ;filesiz
046F:0FA4 26            SEG     ES                      
046F:0FA5 C6451DFF      MOV     B,[DI+1D],FF            
046F:0FA9 33C9          XOR     CX,CX                   
046F:0FAB C3            RET

		RELFILE:
046F:0FAC BAFF0F        MOV     DX,0FFF                 
046F:0FAF E8F500        CALL    RELBLKS		;10A7
		SETDIRT:
046F:0FB2 C6460FFF      MOV     B,[BP+0F],FF            
046F:0FB6 EBE1          JP      UPDATE		;0F99

		KILLFIL:
046F:0FB8 33DB          XOR     BX,BX                   
046F:0FBA 26            SEG     ES                      
046F:0FBB 875D14        XCHG    BX,[DI+14]      ;firclus   
046F:0FBE E8E400        CALL    RELEASE		;10A5                    
046F:0FC1 EBEF          JP      SETDIRT		;0FB2

		;fc3
		OPTIMIZE:
046F:0FC3 52            PUSH    DX                      
046F:0FC4 53            PUSH    BX                      
046F:0FC5 8A4602        MOV     AL,[BP+02]           ;clusmsk   
046F:0FC8 FEC0          INC     AL                      
046F:0FCA 8AE0          MOV     AH,AL                   
046F:0FCC 2AC2          SUB     AL,DL                   
046F:0FCE 8BD1          MOV     DX,CX                   
046F:0FD0 8B7610        MOV     SI,[BP+10]        ;fat      
046F:0FD3 B90000        MOV     CX,0000

		OPTCLUS:
046F:0FD6 E85FFA        CALL    UNPACK                    
046F:0FD9 02C8          ADD     CL,AL                   
046F:0FDB 82D500        ADC     CH,00                   
046F:0FDE 3BCA          CMP     CX,DX                   
046F:0FE0 7337          JNC     BLKDON		;1019                    
046F:0FE2 8AC4          MOV     AL,AH                   
046F:0FE4 43            INC     BX                      
046F:0FE5 3BFB          CMP     DI,BX                   
046F:0FE7 74ED          JZ      OPTCLUS		;0FD6                    
046F:0FE9 4B            DEC     BX
		FINCLUS:
046F:0FEA 891EB80F      MOV     [0FB8],BX 		;*** absolute CLUSNUM
046F:0FEE 2BD1          SUB     DX,CX                   
046F:0FF0 8BC2          MOV     AX,DX                   
046F:0FF2 8BD9          MOV     BX,CX                   
046F:0FF4 86DF          XCHG    BL,BH                   
046F:0FF6 D1CB          ROR     BX                      
046F:0FF8 8B36B40F      MOV     SI,[0FB4]		;*** absolute NEXTADD
046F:0FFC 03DE          ADD     BX,SI                   
046F:0FFE 891EB40F      MOV     [0FB4],BX 		;*** absolute LASTPOS?
046F:1002 010EBA0F      ADD     [0FBA],CX		;*** absolute
046F:1006 5A            POP     DX                      
046F:1007 5B            POP     BX                      
046F:1008 51            PUSH    CX                      
046F:1009 8A4E03        MOV     CL,[BP+03]              
046F:100C 4A            DEC     DX                      
046F:100D 4A            DEC     DX                      
046F:100E D3E2          SHL     DX,CL                   
046F:1010 0AD3          OR      DL,BL                   
046F:1012 03560B        ADD     DX,[BP+0B]              
046F:1015 59            POP     CX                      
046F:1016 8BDE          MOV     BX,SI                   
046F:1018 C3            RET                             
		BLKDON:
046F:1019 8BCA          MOV     CX,DX                   
046F:101B EBCD          JP      FINCLUS		;0FEA

		;101D
		GETREC:
		; no check for extended FCB
046F:101D 8BFA          MOV     DI,DX                   
046F:101F 8A4520        MOV     AL,[DI+NR]        ;NR      
046F:1022 8B5D0C        MOV     BX,[DI+EXTENT]        ;EXT   
046F:1025 D0E0          SHL     AL                      
046F:1027 D1EB          SHR     BX                      
046F:1029 D0D8          RCR     AL                      
046F:102B 8AE3          MOV     AH,BL                   
046F:102D C3            RET                             

		;102E
		ALLOCATE:
046F:102E 52            PUSH    DX                      
046F:102F 51            PUSH    CX                      
046F:1030 53            PUSH    BX                      
046F:1031 8BC3          MOV     AX,BX
		ALLOC:
046F:1033 8BD3          MOV     DX,BX
		FINDFRE:
046F:1035 43            INC     BX                      
046F:1036 3B5E0D        CMP     BX,[BP+0D]              
046F:1039 7E2B          JLE     TRYOUT		;1066                    
046F:103B 3D0100        CMP     AX,0001                 
046F:103E 7F2B          JG      TRYIN		;106B                    
046F:1040 5B            POP     BX                      
046F:1041 BAFF0F        MOV     DX,0FFF                 
046F:1044 E86000        CALL    RELBLKS		;10A7                    
046F:1047 810CFF0F      OR      W,[SI],0FFF             
046F:104B 58            POP     AX                      
046F:104C 2BC1          SUB     AX,CX                   
046F:104E 5A            POP     DX                      
046F:104F 42            INC     DX                      
046F:1050 03C2          ADD     AX,DX                   
046F:1052 8A5602        MOV     DL,[BP+02]              
046F:1055 B600          MOV     DH,00                   
046F:1057 42            INC     DX                      
046F:1058 F7E2          MUL     AX,DX                   
046F:105A 8BC8          MOV     CX,AX                   
046F:105C 2B0EB20F      SUB     CX,[0FB2] 		;*** absolute
046F:1060 7702          JA      MAXREC		;1064                    
046F:1062 33C9          XOR     CX,CX
		MAXREC:
046F:1064 F9            STC
		RET11:
046F:1065 C3            RET                             

		;1066
		TRYOUT:
046F:1066 E8CFF9        CALL    UNPACK                    
046F:1069 740C          JZ      HAVFRE		;1077
		TRYIN:
046F:106B 48            DEC     AX
046F:106C 7EC7          JLE     FINDFRE		;1035                    
046F:106E 93            XCHG    BX,AX                   
046F:106F E8C6F9        CALL    UNPACK                    
046F:1072 7403          JZ      HAVFRE		;1077                    
046F:1074 93            XCHG    BX,AX                   
046F:1075 EBBE          JP      FINDFRE		;1035

		;1077
		HAVFRE:
046F:1077 87D3          XCHG    DX,BX                   
046F:1079 8BC2          MOV     AX,DX                   
046F:107B E8E0F9        CALL    PACK		;0A5E                    
046F:107E 8BD8          MOV     BX,AX                   
046F:1080 E2B1          LOOP    ALLOC		;1033                    
046F:1082 BAFF0F        MOV     DX,0FFF                 
046F:1085 E8D6F9        CALL    PACK		;0A5E                    
046F:1088 C6460FFF      MOV     B,[BP+0F],FF            
046F:108C 5B            POP     BX                      
046F:108D 59            POP     CX                      
046F:108E 5A            POP     DX                      
046F:108F E8A6F9        CALL    UNPACK                    
046F:1092 87FB          XCHG    DI,BX                   
046F:1094 0BFF          OR      DI,DI                   
046F:1096 75CD          JNZ     RET11		;1065                    
046F:1098 8B3EB00F      MOV     DI,[0FB0]		;*** absolute
046F:109C 26            SEG     ES                      
046F:109D 895D14        MOV     [DI+14],BX              
046F:10A0 810CFF0F      OR      W,[SI],0FFF
		RET12:
046F:10A4 C3            RET         

		;10A5
		RELEASE:
046F:10A5 33D2          XOR     DX,DX
		RELBLKS:
046F:10A7 E88EF9        CALL    UNPACK                    
046F:10AA 74F8          JZ      RET12		;10A4                    
046F:10AC 8BC7          MOV     AX,DI                   
046F:10AE E8ADF9        CALL    PACK		;0A5E                    
046F:10B1 3DFF0F        CMP     AX,0FFF                 
046F:10B4 8BD8          MOV     BX,AX                   
046F:10B6 75ED          JNZ     RELEASE		;10A5
		RET13:
046F:10B8 C3            RET                             

		;10B9
		GETEOF:
046F:10B9 E87CF9        CALL    UNPACK                    
046F:10BC 81FFFF0F      CMP     DI,0FFF                 
046F:10C0 74F6          JZ      RET13		;10B8                    
046F:10C2 8BDF          MOV     BX,DI                   
046F:10C4 EBF3          JP      GETEOF		;10B9        

		;System call
		SRCHFRST:
046F:10C6 E8BAF9        CALL    GETNAME		;0A83
		SAVPLCE:
046F:10C9 722A          JC      KILLSRCH	;10F5                    
046F:10CB A2040E        MOV     [0E04],AL 		;*** absolute
046F:10CE 891E050E      MOV     [0E05],BX 		;*** absolute
046F:10D2 892E070E      MOV     [0E07],BP		;*** absolute
046F:10D6 8BF3          MOV     SI,BX                   
046F:10D8 C43EA90F      LES     DI,[0FA9] 		;*** absolute
046F:10DC 8A4600        MOV     AL,[BP+00]              
046F:10DF FEC0          INC     AL                      
046F:10E1 AA            STOB                            
046F:10E2 A4            MOVB                            
046F:10E3 B90500        MOV     CX,0005                 
046F:10E6 F3            REPZ                            
046F:10E7 A5            MOVW                            
046F:10E8 B000          MOV     AL,00                   
046F:10EA AA            STOB                            
046F:10EB B90700        MOV     CX,0007                 
046F:10EE F3            REPZ                            
046F:10EF AB            STOW                            
046F:10F0 A5            MOVW                            
046F:10F1 A5            MOVW                            
046F:10F2 A4            MOVB                            
046F:10F3 AA            STOB                            
046F:10F4 C3            RET                             

		KILLSRCH:
046F:10F5 B0FF          MOV     AL,FF                   
046F:10F7 A2040E        MOV     [0E04],AL		;*** absolute
		RET14:
046F:10FA C3            RET                             

		;System call
		SRCHNXT:
046F:10FB E842FA        CALL    MOVNAME		;0B40                    
046F:10FE 72F5          JC      KILLSRCH	;10F5                    
046F:1100 8CC8          MOV     AX,CS                   
046F:1102 8ED8          MOV     DS,AX                   
046F:1104 A0040E        MOV     AL,[0E04]		;*** absolute
046F:1107 3CFF          CMP     AL,FF                   
046F:1109 74EF          JZ      RET14		;10FA                    
046F:110B 8A6600        MOV     AH,[BP+00]              
046F:110E 8B1E050E      MOV     BX,[0E05]		;*** absolute
046F:1112 8B2E070E      MOV     BP,[0E07]		;*** absolute
046F:1116 3B06090E      CMP     AX,[0E09]		;*** absolute
046F:111A 7505          JNZ     1121                    
046F:111C E879F9        CALL    CONTSRCH	;0A98                    
046F:111F EBA8          JP      SAVPLCE		;10C9

046F:1121 E86DF9        CALL    FND1A		;0A91                    
046F:1124 EBA3          JP      SRCHFRST	;10C9       

		;System call
		FILESIZE:
046F:1126 1E            PUSH    DS                      
046F:1127 52            PUSH    DX                      
046F:1128 E858F9        CALL    GETNAME		;0A83                    
046F:112B 5F            POP     DI                      
046F:112C 07            POP     ES                      
046F:112D B0FF          MOV     AL,FF                   
046F:112F 72C9          JC      RET14		;10FA                    
046F:1131 83C721        ADD     DI,+21                  
046F:1134 8D770D        LEA     SI,[BX+0D]              
046F:1137 AC            LODB                            
046F:1138 D0E0          SHL     AL                      
046F:113A AD            LODW                            
046F:113B D1D0          RCL     AX                      
046F:113D AB            STOW                            
046F:113E B000          MOV     AL,00                   
046F:1140 D0D0          RCL     AL                      
046F:1142 AA            STOB                            
046F:1143 B000          MOV     AL,00                   
046F:1145 C3            RET                             

		;System call
		SETDMA:
046F:1146 2E            SEG     CS                      
046F:1147 8916A90F      MOV     [0FA9],DX 		;*** absolute DMAADD
046F:114B 2E            SEG     CS                      
046F:114C 8C1EAB0F      MOV     [0FAB],DS		;*** absolute DMAADD+2
046F:1150 C3            RET  

		;System call
		GETFATPT:
046F:1151 8CC8          MOV     AX,CS                   
046F:1153 8ED8          MOV     DS,AX                   
046F:1155 8C0EFC0F      MOV     [0FFC],CS 		;*** absolute
046F:1159 8B2E0410      MOV     BP,[1004] 		;*** absolute CURDRV
046F:115D E844FA        CALL    0BA4                    
046F:1160 8B5E10        MOV     BX,[BP+10]              
046F:1163 8A4602        MOV     AL,[BP+02]              
046F:1166 FEC0          INC     AL                      
046F:1168 8B560D        MOV     DX,[BP+0D]              
046F:116B 4A            DEC     DX                      
046F:116C C6460FFF      MOV     B,[BP+0F],FF            
046F:1170 891EF00F      MOV     [0FF0],BX 		;*** absolute
046F:1174 8916F40F      MOV     [0FF4],DX		;*** absolute
046F:1178 C3            RET                

		;System call
		GETDSKPT:
046F:1179 2E            SEG     CS                      
046F:117A 8C0EFC0F      MOV     [0FFC],CS		;*** absolute
046F:117E 2E            SEG     CS                      
046F:117F 8B1E0410      MOV     BX,[1004] 		;*** absolute curdrv
046F:1183 2E            SEG     CS                      
046F:1184 891EF00F      MOV     [0FF0],BX 		;*** absolute
046F:1188 C3            RET                             

		;System call
		DSKRESET:
046F:1189 2E            SEG     CS                      
046F:118A 8C1EAB0F      MOV     [0FAB],DS 		;*** absolute
046F:118E 8CC8          MOV     AX,CS                   
046F:1190 8ED8          MOV     DS,AX                   
046F:1192 C706A90F8000  MOV     W,[0FA9],0080 		;*** absolute
046F:1198 A10610        MOV     AX,[1006]		;*** absolute
046F:119B A30410        MOV     [1004],AX		;*** absolute
		DSKRST01:
046F:119E 8A0E920F      MOV     CL,[0F92]		;*** absolute
046F:11A2 B500          MOV     CH,00                   
046F:11A4 BE0610        MOV     SI,1006
		WRTFAT:
046F:11A7 AD            LODW                            
046F:11A8 51            PUSH    CX                      
046F:11A9 56            PUSH    SI                      
046F:11AA 8BE8          MOV     BP,AX                   
046F:11AC E873FA        CALL    CHKFATWRT	;0C22                    
046F:11AF 5E            POP     SI                      
046F:11B0 59            POP     CX                      
046F:11B1 E2F4          LOOP    WRTFAT		;11A7                    
046F:11B3 B0FF          MOV     AL,FF                   
046F:11B5 9A1B004000    CALL    001B,BIOSSEG	;BIOSRETL
046F:11BA C3            RET

		;System call
		GETDRV:
046F:11BB 2E            SEG     CS                      
046F:11BC 8B2E0410      MOV     BP,[1004]		;*** absolute
046F:11C0 8A4600        MOV     AL,[BP+00]              
046F:11C3 C3            RET                             

		;System call
		; Depreciated in 034
		INUSE:
046F:11C4 8CC8          MOV     AX,CS                   
046F:11C6 8ED8          MOV     DS,AX                   
046F:11C8 8A0E920F      MOV     CL,[0F92]		;*** absolute
046F:11CC B500          MOV     CH,00                   
046F:11CE 8BF1          MOV     SI,CX                   
046F:11D0 D1E6          SHL     SI                      
046F:11D2 81C60410      ADD     SI,1004		;*** absolute
046F:11D6 BB0000        MOV     BX,0000                 
046F:11D9 FD            DOWN                            
		IULOOP:
046F:11DA AD            LODW                            
046F:11DB 8BE8          MOV     BP,AX                   
046F:11DD F6460FFF      TEST    B,[BP+0F],FF    ; in use?
046F:11E1 7401          JZ      IU01		;11E4                    
046F:11E3 F9            STC
		IU01:
046F:11E4 D1D3          RCL     BX                      
046F:11E6 E2F2          LOOP    IULOOP		;11DA                    
046F:11E8 8AC3          MOV     AL,BL                   
046F:11EA C3            RET     

		;System call
		SETRNDREC:
046F:11EB E82FFE        CALL    GETREC		;101D                    
046F:11EE 894521        MOV     [DI+21],AX              
046F:11F1 B000          MOV     AL,00                   
046F:11F3 7402          JZ      RET15		;11F7                    
046F:11F5 FEC0          INC     AL
		RET15:
046F:11F7 884523        MOV     [DI+23],AL
		RET16:
046F:11FA C3            RET                             

		;System call
		SELDSK:
046F:11FB B600          MOV     DH,00                   
046F:11FD 8BDA          MOV     BX,DX                   
046F:11FF 0E            PUSH    CS                      
046F:1200 1F            POP     DS                      
046F:1201 A0920F        MOV     AL,[0F92]		;*** absolute
046F:1204 3AD8          CMP     BL,AL                   
046F:1206 73F2          JNC	RET16		;11FA                    
046F:1208 D1E3          SHL     BX                      
046F:120A 8B970610      MOV     DX,[BX+1006]            
046F:120E 89160410      MOV     [1004],DX		;*** absolute
		RET17:
046F:1212 C3            RET                             

		;System call
		BUFIN:
046F:1213 8CC8          MOV     AX,CS                   
046F:1215 8EC0          MOV     ES,AX                   
046F:1217 8BF2          MOV     SI,DX                   
046F:1219 B500          MOV     CH,00                   
046F:121B AD            LODW                            
046F:121C 0AC0          OR      AL,AL                   
046F:121E 74F2          JZ      RET17		;1212                    
046F:1220 8ADC          MOV     BL,AH                   
046F:1222 8AFD          MOV     BH,CH                   
046F:1224 3AC3          CMP     AL,BL                   
046F:1226 7605          JBE     NOEDIT		;122D                    
046F:1228 82380D        CMP     B,[BX+SI],0D            
046F:122B 7402          JZ      EDITON		;122F
		NOEDIT:
046F:122D 8ADD          MOV     BL,CH                   
		EDITON:
046F:122F 8AD0          MOV     DL,AL                   
046F:1231 4A            DEC     DX                      
		NEWLIN:
046F:1232 2E            SEG     CS                      
046F:1233 A0010E        MOV     AL,[0E01]		;*** absolute
046F:1236 2E            SEG     CS                      
046F:1237 A2020E        MOV     [0E02],AL		;*** absolute
046F:123A 56            PUSH    SI                      
046F:123B BF130E        MOV     DI,INBUF		;*** absolute
046F:123E 8AE5          MOV     AH,CH                   
046F:1240 8AFD          MOV     BH,CH                   
046F:1242 8AF5          MOV     DH,CH
		GETCH:
046F:1244 E82702        CALL    B_IN		;146E                    
046F:1247 3C7F          CMP     AL,7F                   
046F:1249 747C          JZ      BACKSP		;12C7                    
046F:124B 3C08          CMP     AL,08                   
046F:124D 7478          JZ      BACKSP		;12C7                    
046F:124F 3C0D          CMP     AL,0D                   
046F:1251 7438          JZ      ENDLIN		;128B                    
046F:1253 3C0A          CMP     AL,0A                   
046F:1255 7458          JZ      PHYCRLF		;12AF                    
046F:1257 3C18          CMP     AL,18                   
046F:1259 7459          JZ      KILNEW		;12B4                    
046F:125B 3C1B          CMP     AL,1B                   
046F:125D 7417          JZ      ESC		;1276
		SAVCH:
046F:125F 3AF2          CMP     DH,DL                   
046F:1261 73E1          JNC     GETCH		;1244                    
046F:1263 AA            STOB                            
046F:1264 FEC6          INC     DH                      
046F:1266 E85B01        CALL    BUFOUT		;13C4                    
046F:1269 0AE4          OR      AH,AH                   
046F:126B 75D7          JNZ     GETCH		;1244                    
046F:126D 3AFB          CMP     BH,BL                   
046F:126F 73D3          JNC     GETCH		;1244                    
046F:1271 46            INC     SI                      
046F:1272 FEC7          INC     BH                      
046F:1274 EBCE          JP      GETCH		;1244

		ESC:
046F:1276 E8F501        CALL    B_IN		;146E                    
046F:1279 B118          MOV     CL,18		;ESCTABLEN
046F:127B 57            PUSH    DI                      
046F:127C BF0300        MOV     DI,0003         ;ESCTAB
046F:127F F2            REPNZ                           
046F:1280 AE            SCAB                            
046F:1281 5F            POP     DI                      
046F:1282 80E1FE        AND     CL,FE                   
046F:1285 8BE9          MOV     BP,CX                   
046F:1287 FFA6AC0B      JMP     [BP+0BAC]	;*** absolute ESCFUNC

		ENDLIN:
046F:128B AA            STOB                            
046F:128C E84A01        CALL    B_OUT		;13D9                    
046F:128F 5F            POP     DI                      
046F:1290 8875FF        MOV     [DI-01],DH              
046F:1293 FEC6          INC     DH
		COPYNEW:
046F:1295 8CC5          MOV     BP,ES                   
046F:1297 8CDB          MOV     BX,DS                   
046F:1299 8EC3          MOV     ES,BX                   
046F:129B 8EDD          MOV     DS,BP                   
046F:129D BE130E        MOV     SI,INBUF		;*** absolute INBUF
046F:12A0 8ACE          MOV     CL,DH                   
046F:12A2 F3            REPZ                            
046F:12A3 A4            MOVB                            
046F:12A4 C3            RET                             

		CRLF:
046F:12A5 B00D          MOV     AL,0D                   
046F:12A7 E82F01        CALL    B_OUT		;13D9                    
046F:12AA B00A          MOV     AL,0A                   
046F:12AC E92A01        JMP     B_OUT		;13D9                    

		PHYCRLF:
046F:12AF E8F3FF        CALL    CRLF		;12A5                    
046F:12B2 EB90          JP      GETCH		;1244

		KILNEW:
046F:12B4 B05C          MOV     AL,"\"		;5C                   
046F:12B6 E82001        CALL    B_OUT		;13D9                    
046F:12B9 5E            POP     SI
		PUTNEW:
046F:12BA E8E8FF        CALL    CRLF		;12A5                    
046F:12BD 2E            SEG     CS                      
046F:12BE A0020E        MOV     AL,[0E02]		;*** absolute
046F:12C1 E87A01        CALL    TAB		;143E                    
046F:12C4 E96BFF        JMP     NEWLIN		;1232                    

		BACKSP:
046F:12C7 0AF6          OR      DH,DH                   
046F:12C9 7411          JZ      OLDBAK		;12DC                    
046F:12CB E84E00        CALL    BACKUP		;131C                    
046F:12CE 26            SEG     ES                      
046F:12CF 8A05          MOV     AL,[DI]                 
046F:12D1 3C20          CMP     AL,20                   
046F:12D3 7307          JNC     OLDBAK		;12DC                    
046F:12D5 3C09          CMP     AL,09                   
046F:12D7 7411          JZ      BAKTAB		;12EA                    
046F:12D9 E84300        CALL    BACKMES		;131F
		OLDBAK:
046F:12DC 0AE4          OR      AH,AH                   
046F:12DE 7507          JNZ     GETCH1		;12E7                    
046F:12E0 0AFF          OR      BH,BH                   
046F:12E2 7403          JZ      GETCH1		;12E7                    
046F:12E4 FECF          DEC     BH                      
046F:12E6 4E            DEC     SI
		GETCH1:
046F:12E7 E95AFF        JMP     GETCH		;1244                    

		BAKTAB:
046F:12EA 57            PUSH    DI                      
046F:12EB 4F            DEC     DI                      
046F:12EC FD            DOWN                            
046F:12ED 8ACE          MOV     CL,DH                   
046F:12EF B020          MOV     AL,20                   
046F:12F1 53            PUSH    BX                      
046F:12F2 B307          MOV     BL,07                   
046F:12F4 E30E          JCXZ    FIGTAB		;1304
		FNDPOS:
046F:12F6 AE            SCAB                            
046F:12F7 7609          JBE     CHKCNT		;1302                    
046F:12F9 26            SEG     ES                      
046F:12FA 827D0109      CMP     B,[DI+01],09            
046F:12FE 7409          JZ      HAVTAB		;1309                    
046F:1300 FECB          DEC     BL
		CHKCNT:
046F:1302 E2F2          LOOP    FNDPOS		;12F6
		FIGTAB:
046F:1304 2E            SEG     CS                      
046F:1305 2A1E020E      SUB     BL,[0E02]		;*** absolute STARTPOS
		HAVTAB:
046F:1309 2ADE          SUB     BL,DH                   
046F:130B 02CB          ADD     CL,BL                   
046F:130D 80E107        AND     CL,07                   
046F:1310 FC            UP                              
046F:1311 5B            POP     BX                      
046F:1312 5F            POP     DI                      
046F:1313 74C7          JZ      OLDBAK		;12DC
		TABBAK:
046F:1315 E80700        CALL    BACKMES		;131F                    
046F:1318 E2FB          LOOP    TABBAK		;1315                    
046F:131A EBC0          JP      OLDBAK		;12DC    
		BACKUP:
046F:131C FECE          DEC     DH                      
046F:131E 4F            DEC     DI
		BACKMES:
046F:131F B008          MOV     AL,08		;backspace
046F:1321 E8B500        CALL    B_OUT		;13D9                    
046F:1324 B020          MOV     AL,20 		;space
046F:1326 E8B000        CALL    B_OUT		;13D9                    
046F:1329 B008          MOV     AL,08		;backspace
046F:132B E9AB00        JMP     B_OUT		;13D9                    

		TWOESC:
046F:132E B01B          MOV     AL,1B 		;ESC
046F:1330 E92CFF        JMP     SAVCH		;125F                    

		COPYLIN:
046F:1333 8ACB          MOV     CL,BL                   
046F:1335 2ACF          SUB     CL,BH                   
046F:1337 EB07          JP      COPYEACH	;1340

		COPYSTR:
046F:1339 E82E00        CALL    FINDOLD		;136A                    
046F:133C EB02          JP      COPYEACH	;1340                    

		COPYONE:
046F:133E B101          MOV     CL,01                   
		COPYEACH:
046F:1340 3AF2          CMP     DH,DL                   
046F:1342 740F          JZ      GETCH2		;1353                    
046F:1344 3AFB          CMP     BH,BL                   
046F:1346 740B          JZ      GETCH2		;1353                    
046F:1348 AC            LODB                            
046F:1349 AA            STOB                            
046F:134A E87700        CALL    BUFOUT		;13C4                    
046F:134D FEC7          INC     BH                      
046F:134F FEC6          INC     DH                      
046F:1351 E2ED          LOOP    COPYEACH	;1340

		GETCH2:
046F:1353 E9EEFE        JMP     GETCH		;1244                    
		SKIPONE:
046F:1356 3AFB          CMP     BH,BL                   
046F:1358 74F9          JZ      GETCH2		;1353                    
046F:135A FEC7          INC     BH                      
046F:135C 46            INC     SI                      
046F:135D E9E4FE        JMP     GETCH		;1244                    
046F:1360 E80700        CALL    FINDOLD		;136A                    
046F:1363 03F1          ADD     SI,CX                   
046F:1365 02F9          ADD     BH,CL                   
046F:1367 E9DAFE        JMP     GETCH		;1244                    

		FINDOLD:
046F:136A E80101        CALL    B_IN		;146E                    
046F:136D 8ACB          MOV     CL,BL                   
046F:136F 2ACF          SUB     CL,BH                   
046F:1371 7417          JZ      NOTFND		;138A                    
046F:1373 49            DEC     CX                      
046F:1374 7414          JZ      NOTFND		;138A                    
046F:1376 06            PUSH    ES                      
046F:1377 1E            PUSH    DS                      
046F:1378 07            POP     ES                      
046F:1379 57            PUSH    DI                      
046F:137A 8BFE          MOV     DI,SI                   
046F:137C 47            INC     DI                      
046F:137D F2            REPNZ                           
046F:137E AE            SCAB                            
046F:137F 5F            POP     DI                      
046F:1380 07            POP     ES                      
046F:1381 7507          JNZ     NOTFND		;138A                    
046F:1383 F6D1          NOT     CL                      
046F:1385 02CB          ADD     CL,BL                   
046F:1387 2ACF          SUB     CL,BH
		RET18:
046F:1389 C3            RET                             

		NOTFND:
046F:138A 5D            POP     BP                      
046F:138B E9B6FE        JMP     GETCH		;1244                    

		REEDIT:
046F:138E B040          MOV     AL,"@"		;40                   
046F:1390 E84600        CALL    B_OUT		;13D9                    
046F:1393 5F            POP     DI                      
046F:1394 57            PUSH    DI                      
046F:1395 06            PUSH    ES                      
046F:1396 1E            PUSH    DS                      
046F:1397 E8FBFE        CALL    COPYNEW:	;1295                    
046F:139A 1F            POP     DS                      
046F:139B 07            POP     ES                      
046F:139C 5E            POP     SI                      
046F:139D 8ADE          MOV     BL,DH                   
046F:139F E918FF        JMP     PUTNEW		;12BA 

		ENTERINS:
046F:13A2 B4FF          MOV     AH,FF                   
046F:13A4 E99DFE        JMP     GETCH		;1244

		EXITINS:
046F:13A7 B400          MOV     AH,00                   
046F:13A9 E998FE        JMP     GETCH		;1244                    

		;13ac
		; ESCape function data table - 24
		ESCFUNC:
			DW      GETCH ;0a44
			DW      TWOESC	;0b2e
			DW      EXITINS	;0ba7
			DW      ENTERINS ;0ba2
			DW      BACKSP	;0ac7
			DW      REEDIT	;0be8
			DW      KILNEW	;0ab4
			DW      COPYLIN	;0b33
			DW      SKIPSTR	;0b60
			DW      COPYSTR	;0b39
			DW      SKIPONE	;0b56
			DW      COPYONE	;0be3

		;13c4
		BUFOUT:
			CMP     AL," "
		        JAE     OUT
046F:13C8 3C09          CMP     AL,HTAB		;09
046F:13CA 740D          JZ      B_OUT		;13D9                    
046F:13CC 50            PUSH    AX                      
046F:13CD B05E          MOV     AL,"^"		;5E
046F:13CF E80700        CALL    B_OUT		;13D9                    
046F:13D2 58            POP     AX                      
046F:13D3 0C40          OR      AL,40
046F:13D5 EB02          JP      B_OUT		;13D9

		;13d7
		;System call
		CONOUT:
046F:13D7 8AC2          MOV     AL,DL
		B_OUT:
046F:13D9 3C20          CMP     AL,20                   
046F:13DB 724D          JC      CTRLOUT		;142A                    
046F:13DD 3C7F          CMP     AL,7F                   
046F:13DF 7405          JZ      OUTCH		;13E6                    
046F:13E1 2E            SEG     CS                      
046F:13E2 FE06010E      INC     B,[0E01]		;*** absolute CARPOS
		OUTCH:
046F:13E6 9A09004000    CALL    BIOSOUT,BIOSSEG	;BIOSOUTP
046F:13EB 2E            SEG     CS                      
046F:13EC F606030EFF    TEST    B,[0E03],FF		;*** absolute
046F:13F1 7405          JZ      BOUT2		;13F8                    
046F:13F3 9A0C004000    CALL    BIOSPRINT,BIOSSEG	;BIOSPRINT
		BOUT2:
046F:13F8 9A03004000    CALL    0003,BIOSSEG	;BIOSSTAT
046F:13FD 748A          JZ      RET18		;1389
		INCHK:
046F:13FF 9A06004000    CALL    BIOSIN,BIOSSEG	;BIOSINP
046F:1404 3C13          CMP     AL,13		;DC3
046F:1406 7505          JNZ     BOUT4		;140D                    
046F:1408 9A06004000    CALL    BIOSIN,BIOSSEG	;BIOSINP
		BOUT4:
046F:140D 3C10          CMP     AL,10		;DLE   
046F:140F 740B          JZ      PRINTON		;141C                    
046F:1411 3C0E          CMP     AL,0E		;SO
046F:1413 740E          JZ      PRINTOFF	;1423                    
046F:1415 3C03          CMP     AL,03		;EXT
046F:1417 7502          JNZ     RET19		;141B                    
046F:1419 CD23          INT     23		;INT23 Ctrl-C handler
		RET19:
046F:141B C3            RET                             

		PRINTON:
046F:141C 2E            SEG     CS                      
046F:141D C606030E01    MOV     B,[0E03],01		;*** absolute PFFLAG
046F:1422 C3            RET

		PRINTOFF:
046F:1423 2E            SEG     CS                      
046F:1424 C606030E00    MOV     B,[0E03],00		;*** absolute
046F:1429 C3            RET

		CTRLOUT:
046F:142A 3C0D          CMP     AL,0D                   
046F:142C 741E          JZ      ZERPOS			;144C                    
046F:142E 3C08          CMP     AL,08                   
046F:1430 7422          JZ      BACKPOS			;1454                    
046F:1432 3C09          CMP     AL,09                   
046F:1434 75B0          JNZ     OUTCH			;13E6                    
046F:1436 2E            SEG     CS                      
046F:1437 A0010E        MOV     AL,[0E01]		;*** absolute
046F:143A 0CF8          OR      AL,F8                   
046F:143C F6D8          NEG     AL
		TAB:
046F:143E 51            PUSH    CX
046F:143F 8AC8          MOV     CL,AL                   
046F:1441 B500          MOV     CH,00                   
046F:1443 B020          MOV     AL," " 
		TABLP:
046F:1445 E891FF        CALL    B_OUT		;13D9                    
046F:1448 E2F9          LOOP    TABLP		;1443                    
046F:144A 59            POP     CX
		RET20:
046F:144B C3            RET                             

		ZERPOS:
046F:144C 2E            SEG     CS                      
046F:144D C606010E00    MOV     B,[0E01],00		;*** absolute
046F:1452 EB92          JP      OUTCH		;13E6 

		BACKPOS:
046F:1454 2E            SEG     CS                      
046F:1455 FE0E010E      DEC     B,[0E01] 		;*** absolute
046F:1459 EB8B          JP      OUTCH		;13E6                    

		;System call
		CONSTAT:
046F:145B 9A03004000    CALL    BIOSSTAT,BIOSSEG	;far ptr BIOSSTATUS
046F:1460 74E9          JZ      RET20		';144B                    
046F:1462 0CFF          OR      AL,FF                   
046F:1464 C3            RET                             

		;System call
		CONIN:
046F:1465 E897FF        CALL    INCHK		;13FF                    
046F:1468 50            PUSH    AX                      
046F:1469 E86DFF        CALL	B_OUT		;13D9                    
046F:146C 58            POP     AX                      
046F:146D C3            RET

		;System call
		B_IN:
046F:146E E88EFF        CALL    INCHK		;13FF                    
046F:1471 74FB          JZ      B_IN		;146E
		RET22:
046F:1473 C3            RET                             

		;System call
		RAWIO:
046F:1474 8AC2          MOV     AL,DL                   
046F:1476 3CFF          CMP     AL,FF                   
046F:1478 750D          JNZ     RAWOUT		;1487                    
046F:147A 9A03004000    CALL    BIOSSTAT,BIOSSEG	;BIOSSTATUS
046F:147F 74F2          JZ      RET22		;1473                    

		RAWINP:
046F:1481 9A06004000    CALL    BIOSIN,BIOSSEG	;BIOSINP
046F:1486 C3            RET                             

		RAWOUT:
046F:1487 9A09004000    CALL    BIOSOUT,BIOSSEG 	;BIOSOUTP
046F:148C C3            RET                             

		;System call
		LIST:
046F:148D 8AC2          MOV     AL,DL                   
046F:148F 9A0C004000    CALL    BIOSPRINT,BIOSSEG 	;BIOSPRINT
		INCHK:
046F:1494 C3            RET                             

		;System call
		PRTBUF:
046F:1495 8BF2          MOV     SI,DX
		OUTSTR:
046F:1497 AC            LODB                            
046F:1498 3C24          CMP     AL,"$"		;+24                   
046F:149A 74F8          JZ	INCHK		;1494                    
046F:149C E83AFF        CALL    B_OUT		;13D9                    
046F:149F EBF6          JP      OUTSTR		;1497

		;14a1
		OUTMES:
046F:14A1 2E            SEG     CS                      
046F:14A2 AC            LODB                            
046F:14A3 3C24          CMP     AL,"$"                   
046F:14A5 74ED          JZ      INCHK		;1494                    
046F:14A7 E82FFF        CALL    B_OUT		;13D9                    
046F:14AA EBF5          JP      OUTMES  

		;System call
		MAKEFCB:
046F:14AC B200          MOV     DL,00		;Flag--not ambiguous file name
046F:14AE 0AC0          OR      AL,AL                   
046F:14B0 7406          JZ      MKFCB1		;14B8 
		FCBLP1:
046F:14B2 E85B00        CALL    GETLET		;1510                    
046F:14B5 74FB          JZ      FCBLP1		;14B2                    
046F:14B7 4E            DEC     SI
		MKFCB1:
046F:14B8 827C013A      CMP     B,[SI+01],":"	;3A
046F:14BC 750E          JNZ     HAVDRV		;14CC
046F:14BE E84F00        CALL    GETLET		;1510                    
046F:14C1 2C40          SUB     AL,40                   
046F:14C3 7406          JZ      BADDRV		;14CB                    
046F:14C5 46            INC     SI                      
046F:14C6 3C0F          CMP     AL,0F                   
046F:14C8 7604          JBE     HAVDRV2		;14CE                    
046F:14CA 4E            DEC     SI
		BADDRV:
046F:14CB 4E            DEC     SI
		HAVDRV:
046F:14CC 32C0          XOR     AL,AL
		HAVDRV2:
046F:14CE AA            STOB                            
046F:14CF B90800        MOV     CX,0008                 
046F:14D2 E81800        CALL    GETWORD		;14ED                    
046F:14D5 823C2E        CMP     B,[SI],"."	;2E               
046F:14D8 7501          JNZ     NODOT		;14DB                    
046F:14DA 46            INC     SI		; skip dot if present
		NODOT:
046F:14DB B90300        MOV     CX,0003                 
046F:14DE E80C00        CALL    GETWORD		;14ED                    
046F:14E1 2E            SEG     CS                      
046F:14E2 8936F60F      MOV     [0FF6],SI		;*** absolute sisave
046F:14E6 33C0          XOR     AX,AX                   
046F:14E8 AB            STOW                            
046F:14E9 AB            STOW                            
046F:14EA 8AC2          MOV     AL,DL                   
046F:14EC C3            RET                             

		;14ed
		GETWORD:
046F:14ED E82000        CALL    GETLET	;1510                    
046F:14F0 7418          JZ      FILLNAM	;150A                    
046F:14F2 3C20          CMP     AL," "	;20                   
046F:14F4 7614          JBE     FILLNAM	;150A                    
046F:14F6 3C2A          CMP     AL,"*"	;2A                   
046F:14F8 7506          JNZ     NOSTAR	;1500                    
046F:14FA B03F          MOV     AL,"?"	;3F                   
046F:14FC 49            DEC     CX                      
046F:14FD F3            REPZ                            
046F:14FE AA            STOB                            
046F:14FF 41            INC     CX
		;1500
		NOSTAR:
046F:1500 AA            STOB                            
046F:1501 3C3F          CMP     AL,"?"	;3F                   
046F:1503 7502          JNZ     LAB160	;1507                    
046F:1505 B201          MOV     DL,01
		LAB160:
046F:1507 E2E4          LOOP    GETWORD	;14ED                    
046F:1509 46            INC     SI
		FILLNAM:
046F:150A B020          MOV     AL," "		;20                   
046F:150C F3            REPZ                            
046F:150D AA            STOB                            
046F:150E 4E            DEC     SI
		RET21:
046F:150F C3            RET                             

		;1510
		GETLET:
		;Get a byte from [SI], convert it to upper case, and compare for delimiter.
		;ZF set if a delimiter, CY set if a control character (other than TAB).
046F:1510 AC            LODB                            
046F:1511 3C61          CMP     AL,'a'	;61                   
046F:1513 7206          JC      MAKEUC                    
046F:1515 3C7A          CMP     AL,'z'	;7A                   
046F:1517 7702          JA      MAKEUC                    
046F:1519 2C20          SUB     AL,20
		MAKEUC:
046F:151B 3C20          CMP     AL,20	;space?              
046F:151D 74F0          JZ      RET21

		;151f
		DELIM:
046F:151F 3C3D          CMP     AL,"="	;3D                   
046F:1521 74EC          JZ      RET21                    
046F:1523 3C2C          CMP     AL,","	;2C                   
046F:1525 74E8          JZ      RET21                    
046F:1527 3C3B          CMP     AL,";"	;3B
046F:1529 74E4          JZ      RET21                    
046F:152B 3C2E          CMP     AL,"."	;2E                   
046F:152D 74E0          JZ      RET21                    
046F:152F 3C3A          CMP     AL,":"	;3A                   
046F:1531 74DC          JZ      RET21                    
046F:1533 3C09          CMP     AL,09	;TAB               
046F:1535 C3            RET                             

		;1536
		;System call
		SETVECT:
046F:1536 33DB          XOR     BX,BX                   
046F:1538 8EC3          MOV     ES,BX                   
046F:153A 8AD8          MOV     BL,AL                   
046F:153C D1E3          SHL     BX                      
046F:153E D1E3          SHL     BX                      
046F:1540 26            SEG     ES                      
046F:1541 8917          MOV     [BX],DX                 
046F:1543 26            SEG     ES                      
046F:1544 8C5F02        MOV     [BX+02],DS              
046F:1547 C3            RET                             

		;1548
		;System call
		NEWBASE:
046F:1548 8EC2          MOV     ES,DX                   
046F:154A 2E            SEG     CS                      
046F:154B 8E1EAD0F      MOV     DS,[0FAD]		;*** absolute
046F:154F 33F6          XOR     SI,SI                   
046F:1551 8BFE          MOV     DI,SI                   
046F:1553 B98000        MOV     CX,0080                 
046F:1556 F3            REPZ                            
046F:1557 A5            MOVW

		;1558
		SETMEM:
		; Inputs:
		;       AX = Size of memory in paragraphs
		;       DX = Segment
		; Function:
		;       Completely prepares a program base at the 
		;       specified segment.
		; Outputs:
		;       DS = DX
		;       ES = DX
		;       [0] has INT 20H
		;       [2] = First unavailable segment ([ENDMEM])
		;       [5] to [9] form a long call to the entry point
		;       [10] to [13] have exit address (from INT 22H)
		;       [14] to [17] have ctrl-C exit address (from INT 23H)
		;       [18] to [21] have fatal error address (from INT 24H)
		; DX,BP unchanged. All other registers destroyed.
046F:1558 33C9          XOR     CX,CX                   
046F:155A 8ED9          MOV     DS,CX                   
046F:155C 8EC2          MOV     ES,DX                   
046F:155E BE8800        MOV     SI,0088		;exit
046F:1561 BF0A00        MOV     DI,000A		;saveexit
046F:1564 A5            MOVW                            
046F:1565 A5            MOVW                            
046F:1566 A5            MOVW                            
046F:1567 A5            MOVW                            
046F:1568 2E            SEG     CS                      
046F:1569 8B0E0F0E      MOV     CX,[0E0F] 		;*** absolute endmem
046F:156D 26            SEG     ES                      
046F:156E 890E0200      MOV     [0002],CX               
046F:1572 2BCA          SUB     CX,DX                   
046F:1574 81F9FF0F      CMP     CX,0FFF                 
046F:1578 7603          JBE     HAVDIF	;157D                    
046F:157A B9FF0F        MOV     CX,0FFF

		;157d
		HAVDIF:
046F:157D BB0C00        MOV     BX,000C 	;ENTRYPOINTSEG
046F:1580 2BD9          SUB     BX,CX                   
046F:1582 D1E1          SHL     CX                      
046F:1584 D1E1          SHL     CX                      
046F:1586 D1E1          SHL     CX                      
046F:1588 D1E1          SHL     CX                      
046F:158A 8EDA          MOV     DS,DX                   
046F:158C 890E0600      MOV     [0006],CX               
046F:1590 891E0800      MOV     [0008],BX               
046F:1594 C7060000CD20  MOV     W,[0000],20CD		;INT 20 INT INTTAB
046F:159A C60605009A    MOV     B,[0005],LONGCALL	;9A             
046F:159F C3            RET

		;15a0
		SHIFTDI:
046F:15A0 D1E7          SHL     DI                      
046F:15A2 D1E7          SHL     DI                      
046F:15A4 D1E7          SHL     DI                      
046F:15A6 D1E7          SHL     DI                      
046F:15A8 D1E7          SHL     DI                      
046F:15AA D1E7          SHL     DI                      
046F:15AC D1E7          SHL     DI                      
046F:15AE C3            RET                             
		
		CODSIZ  EQU     $-CODSTRT       ;Size of code segment

		;***** DATA AREA *****
			;ORG	0
		CONSTRT	EQU	$		;Start of initialized data
		; 15AF
		BADFAT: DB	0DH, 0AH, 'Bad FAT', 0DH, 0AH, '$'
		; 15B8
		FATSBAD: DB	0DH, 0AH, 'All FATs on disk are bad', 0DH, 0AH, '$'
		; 15D8
		RDERR:	DB	0DH, 0AH, 'Disk read error', 0DH, 0AH, '$'
		; 15EC
		WRTERR:	DB	0DH, 0AH, 'Disk write error', 0DH, 0AH, '$'
		;***** ends at E00h
		;
		; 1601/E01. E01-E04 are initialized in the object file. But,
		; starting at E05h, the data retrieved from the disk looks like
		; Intel HEX strings to E80h, so likely sector overhang. The HEX
		; EOF marker is ":00000001FF". Will leave anything beyond E04h
		; as uninitialized data for now.
		;
		UE01	db	0
		UE02	db	0
		UE03	db	0
		UE04	db	0ffh
		UE05	ds	2
		UE07	ds	2
		UE09	ds	2
		EXITHOLD DS     4	; jump address
		ENDMEM	ds	2
		UE0F	ds	2
		UE11	ds	2	; ends at 0E12

		DOSLEN  EQU     CODSIZ+($-CONSTRT)      ;Size of CODE + CONSTANTS segments

		; Init code overlaps with data area below

        		ORG     DOSLEN
        		PUT     DOSLEN+100H	;??
		;FCB	DW	0	;address of user FCB

		; register saves
		;UFA9 dx
		;UFAB ds
		;UFAD
		TEMP	ds	2	;FAD
		;
		REGSAVE	ds 	24	;FEE register save area
		
		;UFF0 bx -ok
		;UFF4 dx -ok
		;UFF8 di?
		;UFFA sp -bp?
		;UFFC cs -ds?

		;1000h
		IOSTACK ds	3Ch
		;U1000
		SSSAVE	DW	0
		;U1002
		SPSAVE	DW	0
		
		;In 86DOS 100, uninitialized data starts here.
		INBUF	ds	128	;80h
		CONBUF	ds	131	;83h

		
		

		;U1004	
		CURDRV	DW	0
		;U1006 -- this is the highest address referenced in the code and 
		; is right before the start of free memory.
		DRVTAB	DW	0
		MEMSTRT:
		END
