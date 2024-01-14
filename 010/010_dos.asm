
			TITLE 86dos.asm
			;
			;* This was extracted from a disk image provided by
			;* Gene Buckle on 12/29/23. The disk label is:
			;* 86-DOS Version 0.11-C - Serial #11 (ORIGINAL DISK).imd

			FALSE	EQU	0
			TRUE	EQU	1

			BKSPACE EQU	8
			HTAB	EQU	9
			ESCCH   EQU     1BH
			CANCEL  EQU     "X"-"@"         ;Cancel with Ctrl-X

			; although ORGed at 0, it's located at 800h
			ORG 0
		CODSTRT EQU $
046F:0000 E96000        JMP     DOSINIT      
		;0003
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

		;001B
		HEADER: DB      13,10,"86-DOS version 0.11"
        		DB      13,10
        		DB      "Copyright 1980 Seattle Computer Products, Inc.",13,10,"$"

		DOSINIT:
046F:0063 FA            DI                              
046F:0064 FC            UP                              
046F:0065 8CC8          MOV     AX,CS                   
046F:0067 8EC0          MOV     ES,AX                   
046F:0069 AC            LODB                            
046F:006A 98            CBW                             
046F:006B 8BC8          MOV     CX,AX                   
046F:006D 2E            SEG     CS                      
046F:006E A2680E        MOV     [0E68],AL               
046F:0071 8BF8          MOV     DI,AX                   
046F:0073 D1E7          SHL     DI                      
046F:0075 B412          MOV     AH,12                   
046F:0077 F6E4          MUL     AL,AH                   
046F:0079 BBDC0E        MOV     BX,0EDC                 
046F:007C 03FB          ADD     DI,BX                   
046F:007E 03C7          ADD     AX,DI                   
046F:0080 8BE8          MOV     BP,AX                   
046F:0082 2E            SEG     CS                      
046F:0083 A3E70C        MOV     [0CE7],AX  

		LAB200:
046F:0086 2E            SEG     CS                      
046F:0087 893F          MOV     [BX],DI                 
046F:0089 43            INC     BX                      
046F:008A 43            INC     BX                      
046F:008B 8AC5          MOV     AL,CH                   
046F:008D AA            STOB                            
046F:008E AD            LODW                            
046F:008F 56            PUSH    SI                      
046F:0090 8BF0          MOV     SI,AX   

		NOTMAX:
046F:0092 A4            MOVB                            
046F:0093 AC            LODB                            
046F:0094 FEC8          DEC     AL                      
046F:0096 AA            STOB                            
046F:0097 98            CBW                        
		FIGSHFT:
046F:0098 FEC4          INC     AH                      
046F:009A D0F8          SAR     AL                      
046F:009C 75FA          JNZ     0098                    
046F:009E 8AC4          MOV     AL,AH    
		HAVSHFT:
046F:00A0 AA            STOB                            
046F:00A1 AD            LODW                            
046F:00A2 AB            STOW                            
046F:00A3 8BD0          MOV     DX,AX                   
046F:00A5 AC            LODB                            
046F:00A6 AA            STOB                            
046F:00A7 8AE0          MOV     AH,AL                   
046F:00A9 50            PUSH    AX                      
046F:00AA AC            LODB                            
046F:00AB AA            STOB                            
046F:00AC F6E4          MUL     AL,AH                   
046F:00AE 03C2          ADD     AX,DX                   
046F:00B0 AB            STOW                            
046F:00B1 8BD0          MOV     DX,AX                   
046F:00B3 AC            LODB                            
046F:00B4 AA            STOB                            
046F:00B5 98            CBW                             
046F:00B6 03C2          ADD     AX,DX                   
046F:00B8 AB            STOW                            
046F:00B9 5A            POP     DX                      
046F:00BA AD            LODW                            
046F:00BB 40            INC     AX                      
046F:00BC AB            STOW                            
046F:00BD 32C0          XOR     AL,AL                   
046F:00BF AA            STOB                            
046F:00C0 5E            POP     SI                      
046F:00C1 AD            LODW                            
046F:00C2 2E            SEG     CS                      
046F:00C3 0306E70C      ADD     AX,[0CE7]               
046F:00C7 AB            STOW                            
046F:00C8 B200          MOV     DL,00                   
046F:00CA D1EA          SHR     DX                      
046F:00CC 03C2          ADD     AX,DX                   
046F:00CE 3BC5          CMP     AX,BP                   
046F:00D0 7602          JBE     00D4                    
046F:00D2 8BE8          MOV     BP,AX  
		LAB201:
046F:00D4 FEC5          INC     CH                      
046F:00D6 FEC9          DEC     CL                      
046F:00D8 75AC          JNZ     0086  
		LAB210:
046F:00DA 83C50F        ADD     BP,+0F                  
046F:00DD B104          MOV     CL,04                   
046F:00DF D3ED          SHR     BP,CL                   
046F:00E1 33C0          XOR     AX,AX                   
046F:00E3 8ED8          MOV     DS,AX                   
046F:00E5 8EC0          MOV     ES,AX                   
046F:00E7 BF8000        MOV     DI,0080                 
046F:00EA B87001        MOV     AX,0170                 
046F:00ED AB            STOW                            
046F:00EE 8CC8          MOV     AX,CS                   
046F:00F0 C606C000EA    MOV     B,[00C0],EA             
046F:00F5 C706C1007C01  MOV     W,[00C1],017C           
046F:00FB 8C0EC300      MOV     [00C3],CS               
046F:00FF AB            STOW                            
046F:0100 AB            STOW                            
046F:0101 AB            STOW                            
046F:0102 C70684007401  MOV     W,[0084],0174           
046F:0108 BF9400        MOV     DI,0094                 
046F:010B B81500        MOV     AX,0015                 
046F:010E AB            STOW                            
046F:010F B84000        MOV     AX,0040                 
046F:0112 AB            STOW                            
046F:0113 AB            STOW                            
046F:0114 AB            STOW                            
046F:0115 C70698001800  MOV     W,[0098],0018           
046F:011B 8CCA          MOV     DX,CS                   
046F:011D 8EDA          MOV     DS,DX                   
046F:011F 03D5          ADD     DX,BP                   
046F:0121 C7067F0E8000  MOV     W,[0E7F],0080           
046F:0127 8916810E      MOV     [0E81],DX               
046F:012B A1DC0E        MOV     AX,[0EDC]               
046F:012E A3DA0E        MOV     [0EDA],AX               
046F:0131 8BCA          MOV     CX,DX                   
046F:0133 BB0F00        MOV     BX,000F    
		LAB220:
046F:0136 41            INC     CX                      
046F:0137 7410          JZ      0149                    
046F:0139 8ED9          MOV     DS,CX                   
046F:013B 8A07          MOV     AL,[BX]                 
046F:013D F6D0          NOT     AL                      
046F:013F 8807          MOV     [BX],AL                 
046F:0141 3A07          CMP     AL,[BX]                 
046F:0143 F6D0          NOT     AL                      
046F:0145 8807          MOV     [BX],AL                 
046F:0147 74ED          JZ      0136   
		LAB230:
046F:0149 2E            SEG     CS                      
046F:014A 890EE50C      MOV     [0CE5],CX               
046F:014E 33C9          XOR     CX,CX                   
046F:0150 8ED9          MOV     DS,CX                   
046F:0152 C70688000001  MOV     W,[0088],0100           
046F:0158 89168A00      MOV     [008A],DX               
046F:015C C7068C000001  MOV     W,[008C],0100           
046F:0162 89168E00      MOV     [008E],DX               
046F:0166 E8C70A        CALL    0C30                    
046F:0169 BE1B00        MOV     SI,001B                 
046F:016C E8940A        CALL    0C03                    
046F:016F CB            RET     L         

		QUIT:
046F:0170 B400          MOV     AH,00                   
046F:0172 EB1E          JP      0192                    

		COMMAND:
046F:0174 82FC28        CMP     AH,28                   
046F:0177 7619          JBE     0192                    
		BADCALL:
046F:0179 B000          MOV     AL,00                   
046F:017B CF            IRET          

		ENTRY:
046F:017C 58            POP     AX                      
046F:017D 58            POP     AX                      
046F:017E 2E            SEG     CS                      
046F:017F 8F06830E      POP     [0E83]                  
046F:0183 9C            PUSHF                           
046F:0184 FA            DI                              
046F:0185 50            PUSH    AX                      
046F:0186 2E            SEG     CS                      
046F:0187 FF36830E      PUSH    [0E83]                  
046F:018B 82F924        CMP     CL,24                   
046F:018E 77E9          JA      0179                    
046F:0190 8AE1          MOV     AH,CL    

		SAVEREGS:	; switch to internal stack
046F:0192 2E            SEG     CS                      
046F:0193 8926D80E      MOV     [0ED8],SP               
046F:0197 2E            SEG     CS                      
046F:0198 8C16D60E      MOV     [0ED6],SS               
046F:019C 44            INC     SP                      
046F:019D 44            INC     SP                      
046F:019E 2E            SEG     CS                      
046F:019F 8F06830E      POP     [0E83]                  
046F:01A3 8CCC          MOV     SP,CS                   
046F:01A5 8ED4          MOV     SS,SP    

		REDISP:
046F:01A7 BCD60E        MOV     SP,0ED6                 
046F:01AA 06            PUSH    ES                      
046F:01AB 1E            PUSH    DS                      
046F:01AC 55            PUSH    BP                      
046F:01AD 57            PUSH    DI                      
046F:01AE 56            PUSH    SI                      
046F:01AF 52            PUSH    DX                      
046F:01B0 51            PUSH    CX                      
046F:01B1 53            PUSH    BX                      
046F:01B2 50            PUSH    AX                      
046F:01B3 8ADC          MOV     BL,AH                   
046F:01B5 B700          MOV     BH,00                   
046F:01B7 D1E3          SHL     BX                      
046F:01B9 FC            UP                              
046F:01BA 2E            SEG     CS                      
046F:01BB FF97D301      CALL    [BX+01D3]

		LLEAVE:
046F:01BF 2E            SEG     CS                      
046F:01C0 A2C40E        MOV     [0EC4],AL               
046F:01C3 58            POP     AX                      
046F:01C4 5B            POP     BX                      
046F:01C5 59            POP     CX                      
046F:01C6 5A            POP     DX                      
046F:01C7 5E            POP     SI                      
046F:01C8 5F            POP     DI                      
046F:01C9 5D            POP     BP                      
046F:01CA 1F            POP     DS                      
046F:01CB 07            POP     ES                      
046F:01CC 17            POP     SS                      
046F:01CD 2E            SEG     CS                      
046F:01CE 8B26D80E      MOV     SP,[0ED8]               
046F:01D2 CF            IRET

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

		;unimplemented/stub
		RAWINP:		;07
		B_IN:		;08
		FLUSHKB:	;12
		GETFATPTDL:	;28
		GETRDONLY:	;29
		SETATTRIB:	;30
		USERCODE:	;32
046F:0225 B000          MOV     AL,00                   
046F:0227 C3            RET        

		READER:
046F:0228 9A0F004000    CALL    000F,0040               
046F:022D C3            RET                             

		PUNCH:
046F:022E 8AC2          MOV     AL,DL                   
046F:0230 9A12004000    CALL    0012,0040               
046F:0235 C3            RET                             

		UNPACK:
046F:0236 3B5E0D        CMP     BX,[BP+0D]              
046F:0239 7718          JA      0253                    
046F:023B 8D38          LEA     DI,[BX+SI]              
046F:023D D1EB          SHR     BX                      
046F:023F 8B39          MOV     DI,[BX+DI]              
046F:0241 7309          JNC     024C                    
046F:0243 D1EF          SHR     DI                      
046F:0245 D1EF          SHR     DI                      
046F:0247 D1EF          SHR     DI                      
046F:0249 D1EF          SHR     DI                      
046F:024B F9            STC                             
		HAVCLUS:
046F:024C D1D3          RCL     BX                      
046F:024E 81E7FF0F      AND     DI,0FFF                 
046F:0252 C3            RET                             

		HURTFAT:
046F:0253 BE870C        MOV     SI,0C87                 
046F:0256 E8AA09        CALL    0C03                    
046F:0259 E9E002        JMP     053C                    

		PACK:
046F:025C 8BFB          MOV     DI,BX                   
046F:025E D1EB          SHR     BX                      
046F:0260 03DE          ADD     BX,SI                   
046F:0262 03DF          ADD     BX,DI                   
046F:0264 D1EF          SHR     DI                      
046F:0266 8B3F          MOV     DI,[BX]                 
046F:0268 730E          JNC     0278                    
046F:026A D1E2          SHL     DX                      
046F:026C D1E2          SHL     DX                      
046F:026E D1E2          SHL     DX                      
046F:0270 D1E2          SHL     DX                      
046F:0272 81E70F00      AND     DI,000F                 
046F:0276 EB04          JP      027C       

		ALIGNED:
046F:0278 81E700F0      AND     DI,F000                 
		PACKIN:
046F:027C 0BFA          OR      DI,DX                   
046F:027E 893F          MOV     [BX],DI                 
		RET2:
046F:0280 C3            RET                             

		GETNAME:
046F:0281 E8B800        CALL    033C                    
046F:0284 72FA          JC      0280                    

		FINDNAME:
046F:0286 8CC8          MOV     AX,CS                   
046F:0288 8ED8          MOV     DS,AX                   
046F:028A B000          MOV     AL,00                   
046F:028C 50            PUSH    AX                      
046F:028D E82902        CALL    04B9                    
046F:0290 58            POP     AX                      
046F:0291 BBD80D        MOV     BX,0DD8                 
046F:0294 E80B00        CALL    02A2                    
046F:0297 74E7          JZ      0280   
		FND2:
046F:0299 FEC0          INC     AL                      
046F:029B 3A460A        CMP     AL,[BP+0A]              
046F:029E 72EC          JC      028C                    
046F:02A0 F9            STC         
		RET3:
046F:02A1 C3            RET                             

		GETENTRY:
046F:02A2 83C310        ADD     BX,+10                  
046F:02A5 81FB670E      CMP     BX,0E67                 
046F:02A9 77F6          JA      02A1                    
046F:02AB 803FE5        CMP     B,[BX],E5               
046F:02AE 74F2          JZ      02A2                    
046F:02B0 8BF3          MOV     SI,BX                   
046F:02B2 BF690E        MOV     DI,0E69                 
046F:02B5 B90B00        MOV     CX,000B                 
		WILDCRD:
046F:02B8 F3            REPZ                            
046F:02B9 A6            CMPB                            
046F:02BA 74E5          JZ      02A1                    
046F:02BC 827DFF3F      CMP     B,[DI-01],3F            
046F:02C0 74F6          JZ      02B8                    
046F:02C2 EBDE          JP      02A2                    

		DELETE:
046F:02C4 E8BAFF        CALL    0281                    
046F:02C7 7270          JC      0339                    
046F:02C9 50            PUSH    AX                      
046F:02CA 53            PUSH    BX                      
046F:02CB E8D200        CALL    03A0                    
046F:02CE 5B            POP     BX                      
		DELFILE:
046F:02CF C607E5        MOV     B,[BX],E5               
046F:02D2 53            PUSH    BX                      
046F:02D3 8B5F0B        MOV     BX,[BX+0B]              
046F:02D6 8B7610        MOV     SI,[BP+10]              
046F:02D9 0BDB          OR      BX,BX                   
046F:02DB 7408          JZ      02E5                    
046F:02DD 3B5E0D        CMP     BX,[BP+0D]              
046F:02E0 7703          JA      02E5                    
046F:02E2 E85005        CALL    0835                    
		DELNXT:
046F:02E5 5B            POP     BX                      
046F:02E6 E8B9FF        CALL    02A2                    
046F:02E9 74E4          JZ      02CF                    
046F:02EB 58            POP     AX                      
046F:02EC 50            PUSH    AX                      
046F:02ED E8E901        CALL    04D9                    
046F:02F0 58            POP     AX                      
046F:02F1 E8A5FF        CALL    0299                    
046F:02F4 50            PUSH    AX                      
046F:02F5 73D8          JNC     02CF                    
046F:02F7 58            POP     AX                      
046F:02F8 E82901        CALL    0424                    
046F:02FB 32C0          XOR     AL,AL                   
046F:02FD C3            RET                             

		RENAME:
046F:02FE E83B00        CALL    033C                    
046F:0301 7236          JC      0339                    
046F:0303 83C605        ADD     SI,+05                  
046F:0306 BF740E        MOV     DI,0E74                 
046F:0309 E84900        CALL    0355                    
046F:030C E877FF        CALL    0286                    
046F:030F 7228          JC      0339                    
		REN0:
046F:0311 8AE0          MOV     AH,AL                   
		REN1:
046F:0313 8BFB          MOV     DI,BX                   
046F:0315 BE740E        MOV     SI,0E74                 
046F:0318 B90B00        MOV     CX,000B                 
		NEWNAM:
046F:031B AC            LODB                            
046F:031C 3C3F          CMP     AL,3F                   
046F:031E 7402          JZ      0322                    
046F:0320 8805          MOV     [DI],AL                 
		NOCHG:
046F:0322 47            INC     DI                      
046F:0323 E2F6          LOOP    031B                    
046F:0325 E87AFF        CALL    02A2                    
046F:0328 74E9          JZ      0313                    
046F:032A 8AC4          MOV     AL,AH                   
046F:032C 50            PUSH    AX                      
046F:032D E8A901        CALL    04D9                    
046F:0330 58            POP     AX                      
046F:0331 E865FF        CALL    0299                    
046F:0334 73DB          JNC     0311                    
046F:0336 32C0          XOR     AL,AL                   
046F:0338 C3            RET                             
		ERRET:
046F:0339 B0FF          MOV     AL,FF                   
		RET5:
046F:033B C3            RET                             

		MOVNAME:
046F:033C 8CC8          MOV     AX,CS                   
046F:033E 8EC0          MOV     ES,AX                   
046F:0340 BF690E        MOV     DI,0E69                 
046F:0343 8BF2          MOV     SI,DX                   
046F:0345 AC            LODB                            
046F:0346 26            SEG     ES                      
046F:0347 3806680E      CMP     [0E68],AL               
046F:034B 72EE          JC      033B                    
046F:034D 98            CBW                             
046F:034E 95            XCHG    BP,AX                   
046F:034F D1E5          SHL     BP                      
046F:0351 8BAEDA0E      MOV     BP,[BP+0EDA]            
		LODNAME:
046F:0355 B90B00        MOV     CX,000B                 
		MOVE2:
046F:0358 AC            LODB                            
046F:0359 247F          AND     AL,7F                   
046F:035B 3C60          CMP     AL,60                   
046F:035D 7E02          JLE     0361                    
046F:035F 245F          AND     AL,5F                   
		STOLET:
046F:0361 3C20          CMP     AL,20                   
046F:0363 72D6          JC      033B                    
046F:0365 AA            STOB                            
046F:0366 E2F0          LOOP    0358                    
		RET6:
046F:0368 C3            RET                             

		OPEN:
046F:0369 52            PUSH    DX                      
046F:036A 1E            PUSH    DS                      
046F:036B E813FF        CALL    0281            
		DOOPEN:
046F:036E 07            POP     ES                      
046F:036F 5F            POP     DI                      
046F:0370 72C7          JC      0339                    
046F:0372 8A6600        MOV     AH,[BP+00]              
046F:0375 FEC4          INC     AH                      
046F:0377 26            SEG     ES                      
046F:0378 8825          MOV     [DI],AH                 
046F:037A 26            SEG     ES                      
046F:037B C7450C0000    MOV     W,[DI+0C],0000          
046F:0380 83C710        ADD     DI,+10                  
046F:0383 8BCB          MOV     CX,BX                   
046F:0385 81E9E80D      SUB     CX,0DE8                 
046F:0389 8AE1          MOV     AH,CL                   
046F:038B AB            STOW                            
046F:038C 8BC5          MOV     AX,BP                   
046F:038E AB            STOW                            
046F:038F 8D770B        LEA     SI,[BX+0B]              
046F:0392 AD            LODW                            
046F:0393 AB            STOW                            
046F:0394 AB            STOW                            
046F:0395 AC            LODB                            
046F:0396 D0E0          SHL     AL                      
046F:0398 AD            LODW                            
046F:0399 D1D0          RCL     AX                      
046F:039B AB            STOW                            
046F:039C 33C0          XOR     AX,AX                   
046F:039E AB            STOW                            
046F:039F AB            STOW          
		LOC40:
046F:03A0 F6460FFF      TEST    B,[BP+0F],FF            
046F:03A4 75C2          JNZ     0368                    
046F:03A6 E89D00        CALL    0446                    
		LOC41:
046F:03A9 52            PUSH    DX                      
046F:03AA 51            PUSH    CX                      
046F:03AB 53            PUSH    BX                      
046F:03AC 50            PUSH    AX                      
046F:03AD E80C01        CALL    04BC                    
046F:03B0 0AC0          OR      AL,AL                   
046F:03B2 58            POP     AX                      
046F:03B3 5B            POP     BX                      
046F:03B4 59            POP     CX                      
046F:03B5 5A            POP     DX                      
046F:03B6 7509          JNZ     03C1                    
046F:03B8 2A4607        SUB     AL,[BP+07]              
046F:03BB 74AB          JZ      0368                    
046F:03BD F6D8          NEG     AL                      
046F:03BF EB63          JP      0424                    

		LOC42:
046F:03C1 03D1          ADD     DX,CX                   
046F:03C3 FEC8          DEC     AL                      
046F:03C5 75E2          JNZ     03A9                    
046F:03C7 5D            POP     BP                      
046F:03C8 BE930C        MOV     SI,0C93                 
046F:03CB E83201        CALL    0500                    
046F:03CE EBD0          JP      03A0                    

		CLOSE:
046F:03D0 8BFA          MOV     DI,DX                   
046F:03D2 F6451CFF      TEST    B,[DI+1C],FF            
046F:03D6 740D          JZ      03E5                    
046F:03D8 57            PUSH    DI                      
046F:03D9 8B6D12        MOV     BP,[DI+12]              
046F:03DC 8A4600        MOV     AL,[BP+00]              
046F:03DF 9A1B004000    CALL    001B,0040               
046F:03E4 5F            POP     DI                      
		NORMFCB3:
046F:03E5 F6451DFF      TEST    B,[DI+1D],FF            
046F:03E9 7451          JZ      043C                    
046F:03EB 8BD7          MOV     DX,DI                   
046F:03ED 52            PUSH    DX                      
046F:03EE 1E            PUSH    DS                      
046F:03EF E88FFE        CALL    0281                    
046F:03F2 07            POP     ES                      
046F:03F3 5F            POP     DI                      
046F:03F4 7249          JC      043F                    
046F:03F6 8BCB          MOV     CX,BX                   
046F:03F8 81E9E80D      SUB     CX,0DE8                 
046F:03FC 8AE1          MOV     AH,CL                   
046F:03FE 26            SEG     ES                      
046F:03FF 3B4510        CMP     AX,[DI+10]              
046F:0402 753B          JNZ     043F                    
046F:0404 26            SEG     ES                      
046F:0405 8B4D14        MOV     CX,[DI+14]              
046F:0408 894F0B        MOV     [BX+0B],CX              
046F:040B 26            SEG     ES                      
046F:040C 8B5518        MOV     DX,[DI+18]              
046F:040F D1EA          SHR     DX                      
046F:0411 89570E        MOV     [BX+0E],DX              
046F:0414 B200          MOV     DL,00                   
046F:0416 D0DA          RCR     DL                      
046F:0418 88570D        MOV     [BX+0D],DL              
046F:041B E8BB00        CALL    04D9     
		CHKFATWRT:
046F:041E F6460FFF      TEST    B,[BP+0F],FF            
046F:0422 7418          JZ      043C                    
		FATWRT:
046F:0424 C6460F00      MOV     B,[BP+0F],00            
046F:0428 E81B00        CALL    0446                    
		EACHFAT:
046F:042B 52            PUSH    DX                      
046F:042C 51            PUSH    CX                      
046F:042D 53            PUSH    BX                      
046F:042E 50            PUSH    AX      
		FINDDIR:
046F:042F E8AA00        CALL    04DC                    
046F:0432 58            POP     AX                      
046F:0433 5B            POP     BX                      
046F:0434 59            POP     CX                      
046F:0435 5A            POP     DX                      
046F:0436 03D1          ADD     DX,CX                   
046F:0438 FEC8          DEC     AL                      
046F:043A 75EF          JNZ     042B                    
		OKRET:
046F:043C B000          MOV     AL,00                   
046F:043E C3            RET                             

		BADCLOSE:
046F:043F C6460F00      MOV     B,[BP+0F],00            
046F:0443 B0FF          MOV     AL,FF                   
046F:0445 C3            RET                             

		FIGFAT:
046F:0446 8A4607        MOV     AL,[BP+07]              
046F:0449 8B5E10        MOV     BX,[BP+10]              
046F:044C 8A4E06        MOV     CL,[BP+06]              
046F:044F B500          MOV     CH,00                   
046F:0451 8B5604        MOV     DX,[BP+04]              
046F:0454 C3            RET                             

		DIRCOMP:
046F:0455 98            CBW                             
046F:0456 034608        ADD     AX,[BP+08]              
046F:0459 8BD0          MOV     DX,AX                   
046F:045B BBE80D        MOV     BX,0DE8                 
046F:045E B90100        MOV     CX,0001                 
046F:0461 C3            RET                             

		CREATE:
046F:0462 E8D7FE        CALL    033C                    
046F:0465 7232          JC      0499                    
046F:0467 BF690E        MOV     DI,0E69                 
046F:046A B90B00        MOV     CX,000B                 
046F:046D B03F          MOV     AL,3F                   
046F:046F F2            REPNZ                           
046F:0470 AE            SCAB                            
046F:0471 7426          JZ      0499                    
046F:0473 52            PUSH    DX                      
046F:0474 1E            PUSH    DS                      
046F:0475 8CC8          MOV     AX,CS                   
046F:0477 8ED8          MOV     DS,AX                   
046F:0479 33C0          XOR     AX,AX                   
		CRE01:
046F:047B 50            PUSH    AX                      
046F:047C E83A00        CALL    04B9                    
046F:047F 58            POP     AX                      
046F:0480 BFD80D        MOV     DI,0DD8                 
046F:0483 B90800        MOV     CX,0008                 
		FREESPOT:
046F:0486 83C710        ADD     DI,+10                  
		LAB090:
046F:0489 803DE5        CMP     B,[DI],E5               
046F:048C E0F8          LOOPNZ  0486                    
046F:048E 740C          JZ      049C                    
046F:0490 FEC0          INC     AL                      
046F:0492 3A460A        CMP     AL,[BP+0A]              
046F:0495 72E4          JC      047B                    
		ERRPOP:
046F:0497 1F            POP     DS                      
046F:0498 5A            POP     DX                      
		ERRET3:
046F:0499 B0FF          MOV     AL,FF                   
046F:049B C3            RET                             

		;
		; whole routine EXISTENT is missing
		;
		FREESPOT:
046F:049C 8BDF          MOV     BX,DI                   
046F:049E BE690E        MOV     SI,0E69                 
046F:04A1 B90500        MOV     CX,0005                 
046F:04A4 A4            MOVB                            
046F:04A5 F3            REPZ                            
046F:04A6 A5            MOVW                            
046F:04A7 86C4          XCHG    AL,AH                   
046F:04A9 B105          MOV     CL,05                   
046F:04AB F3            REPZ                            
046F:04AC AA            STOB                            
046F:04AD 86C4          XCHG    AL,AH                   
046F:04AF 50            PUSH    AX                      
046F:04B0 53            PUSH    BX                      
		SMALLENT:
046F:04B1 E82500        CALL    04D9                    
046F:04B4 5B            POP     BX                      
046F:04B5 58            POP     AX                      
		OPENJMP:
046F:04B6 E9B5FE        JMP     036E                    

		DSKREAD:
046F:04B9 E899FF        CALL    0455                    
		REREAD:
046F:04BC 8A4600        MOV     AL,[BP+00]              
046F:04BF 55            PUSH    BP                      
046F:04C0 53            PUSH    BX                      
046F:04C1 51            PUSH    CX                      
046F:04C2 52            PUSH    DX                      
046F:04C3 9A15004000    CALL    0015,0040               
046F:04C8 5A            POP     DX                      
046F:04C9 5F            POP     DI                      
046F:04CA 5B            POP     BX                      
046F:04CB 5D            POP     BP                      
046F:04CC 7203          JC      04D1                    
046F:04CE 32C0          XOR     AL,AL                   
046F:04D0 C3            RET                             

		DSKRDERR:
046F:04D1 BEB00C        MOV     SI,0CB0                 
046F:04D4 E82900        CALL    0500                    
046F:04D7 EBE3          JP      04BC                    

		DIRWRITE:
046F:04D9 E879FF        CALL    0455                    
		DWRITE:
046F:04DC 8A4600        MOV     AL,[BP+00]              
046F:04DF B400          MOV     AH,00                   
046F:04E1 3B560B        CMP     DX,[BP+0B]              
046F:04E4 D0DC          RCR     AH                      
046F:04E6 55            PUSH    BP                      
046F:04E7 53            PUSH    BX                      
046F:04E8 51            PUSH    CX                      
046F:04E9 52            PUSH    DX                      
046F:04EA 9A18004000    CALL    0018,0040               
046F:04EF 5A            POP     DX                      
046F:04F0 5F            POP     DI                      
046F:04F1 5B            POP     BX                      
046F:04F2 5D            POP     BP                      
046F:04F3 7203          JC      04F8                    
046F:04F5 32C0          XOR     AL,AL                   
		RET9A:
046F:04F7 C3            RET                             

		DSKWRERR:
046F:04F8 BEC40C        MOV     SI,0CC4                 
046F:04FB E80200        CALL    0500                    
046F:04FE EBDC          JP      04DC                    

		ERRARF:
046F:0500 2BF9          SUB     DI,CX                   
046F:0502 03D7          ADD     DX,DI                   
046F:0504 E87107        CALL    0C78                    
046F:0507 03DF          ADD     BX,DI                   
046F:0509 E8F706        CALL    0C03                    

		RETRY:
046F:050C E8C106        CALL    0BD0                    
046F:050F 0C20          OR      AL,20                   
046F:0511 3C61          CMP     AL,61                   
046F:0513 7427          JZ      053C                    
046F:0515 3C72          CMP     AL,72                   
046F:0517 74DE          JZ      04F7                    
046F:0519 3C69          CMP     AL,69                   
046F:051B 7408          JZ      0525                    
046F:051D 3C63          CMP     AL,63                   
046F:051F 75EB          JNZ     050C                    
046F:0521 58            POP     AX                      
046F:0522 B001          MOV     AL,01                   
046F:0524 C3            RET                             

		DIGNORE:
046F:0525 58            POP     AX                      
046F:0526 B000          MOV     AL,00                   
046F:0528 C3            RET                

		ABORT:
046F:0529 2E            SEG     CS                      
046F:052A 8E1E830E      MOV     DS,[0E83]               
046F:052E 33C0          XOR     AX,AX                   
046F:0530 8EC0          MOV     ES,AX                   
046F:0532 BE0A00        MOV     SI,000A                 
046F:0535 BF8800        MOV     DI,0088                 
046F:0538 A5            MOVW                            
046F:0539 A5            MOVW                            
046F:053A A5            MOVW                            
046F:053B A5            MOVW                            
		ERROR:
046F:053C BCD00E        MOV     SP,0ED0                 
046F:053F 8CC8          MOV     AX,CS                   
046F:0541 8ED8          MOV     DS,AX                   
046F:0543 8EC0          MOV     ES,AX                   
046F:0545 E8C203        CALL    090A                    
046F:0548 33C0          XOR     AX,AX                   
046F:054A 8ED8          MOV     DS,AX                   
046F:054C BE8800        MOV     SI,0088                 
046F:054F BFE10C        MOV     DI,0CE1                 
046F:0552 A5            MOVW                            
046F:0553 A5            MOVW                            
046F:0554 5D            POP     BP                      
046F:0555 07            POP     ES                      
046F:0556 07            POP     ES                      
046F:0557 1F            POP     DS                      
046F:0558 17            POP     SS                      
046F:0559 8B26D80E      MOV     SP,[0ED8]               
046F:055D 8E1ED20E      MOV     DS,[0ED2]               
046F:0561 2E            SEG     CS                      
046F:0562 FF2EE10C      JMP     L,[0CE1]                

		SEQRD:
046F:0566 E86102        CALL    07CA                    
046F:0569 B90100        MOV     CX,0001                 
046F:056C E8E100        CALL    0650                    
046F:056F E348          JCXZ    05B9                    
046F:0571 40            INC     AX                      
046F:0572 EB45          JP      05B9                    

		SEQWRT:
046F:0574 E85302        CALL    07CA                    
046F:0577 B90100        MOV     CX,0001                 
046F:057A E89C01        CALL    0719                    
046F:057D E33A          JCXZ    05B9                    
046F:057F 40            INC     AX                      
046F:0580 EB37          JP      05B9                    

		RNDRD:
046F:0582 B90100        MOV     CX,0001                 
046F:0585 8BFA          MOV     DI,DX                   
046F:0587 8B4521        MOV     AX,[DI+21]              
046F:058A E8C300        CALL    0650                    
046F:058D EB26          JP      05B5                    

		RNDWRT:
046F:058F B90100        MOV     CX,0001                 
046F:0592 8BFA          MOV     DI,DX                   
046F:0594 8B4521        MOV     AX,[DI+21]              
046F:0597 E87F01        CALL    0719                    
046F:059A EB19          JP      05B5                    

		BLKRD:
046F:059C 8BFA          MOV     DI,DX                   
046F:059E 8B4521        MOV     AX,[DI+21]              
046F:05A1 E8AC00        CALL    0650                    
046F:05A4 EB08          JP      05AE                    

		BLKWRT:
046F:05A6 8BFA          MOV     DI,DX                   
046F:05A8 8B4521        MOV     AX,[DI+21]              
046F:05AB E86B01        CALL    0719       
		FINBLK:
046F:05AE 890EC80E      MOV     [0EC8],CX               
046F:05B2 E301          JCXZ    05B5                    
046F:05B4 40            INC     AX                      
		FINRND:
046F:05B5 26            SEG     ES                      
046F:05B6 894521        MOV     [DI+21],AX              
		SETNREX:
046F:05B9 8BC8          MOV     CX,AX                   
046F:05BB 247F          AND     AL,7F                   
046F:05BD 26            SEG     ES                      
046F:05BE 884520        MOV     [DI+20],AL              
046F:05C1 80E180        AND     CL,80                   
046F:05C4 D1C1          ROL     CX                      
046F:05C6 86CD          XCHG    CL,CH                   
046F:05C8 26            SEG     ES                      
046F:05C9 894D0C        MOV     [DI+0C],CX              
046F:05CC A0850E        MOV     AL,[0E85]               
		RET7:
046F:05CF C3            RET                             

		SETUP:
046F:05D0 8B6D12        MOV     BP,[DI+12]            
		HAVRECSIZE:
046F:05D3 8CDB          MOV     BX,DS                   
046F:05D5 8EC3          MOV     ES,BX                   
046F:05D7 8CCB          MOV     BX,CS                   
046F:05D9 8EDB          MOV     DS,BX                   
046F:05DB A3880E        MOV     [0E88],AX               
046F:05DE 8916860E      MOV     [0E86],DX               
046F:05E2 8B1E7F0E      MOV     BX,[0E7F]               
046F:05E6 891E8A0E      MOV     [0E8A],BX               
046F:05EA C606850E00    MOV     B,[0E85],00             
046F:05EF C706900E0000  MOV     W,[0E90],0000           
046F:05F5 8B7610        MOV     SI,[BP+10]              
046F:05F8 83C37F        ADD     BX,+7F                  
046F:05FB 721D          JC      061A                    
046F:05FD 80E380        AND     BL,80                   
046F:0600 F7DB          NEG     BX                      
046F:0602 D1C3          ROL     BX                      
046F:0604 86DF          XCHG    BL,BH                   
046F:0606 7502          JNZ     060A                    
046F:0608 B702          MOV     BH,02                   
		EOFERR:
046F:060A 3BCB          CMP     CX,BX                   
046F:060C 7607          JBE     0615                    
046F:060E 8BCB          MOV     CX,BX                   
046F:0610 C606850E02    MOV     B,[0E85],02             
		NOROOM:
046F:0615 890E8C0E      MOV     [0E8C],CX               
046F:0619 C3            RET                             
		
		TRIMM:
046F:061A C606850E02    MOV     B,[0E85],02             
046F:061F B90000        MOV     CX,0000                 
046F:0622 5B            POP     BX                      
		RET8:
046F:0623 C3            RET                             

		FNDCLUS:
046F:0624 26            SEG     ES                      
046F:0625 8B5D16        MOV     BX,[DI+16]              
046F:0628 26            SEG     ES                      
046F:0629 8B551A        MOV     DX,[DI+1A]              
046F:062C 0BDB          OR      BX,BX                   
046F:062E 741D          JZ      064D                    
046F:0630 2BCA          SUB     CX,DX                   
046F:0632 7308          JNC     063C                    
046F:0634 03CA          ADD     CX,DX                   
046F:0636 33D2          XOR     DX,DX                   
046F:0638 26            SEG     ES                      
046F:0639 8B5D14        MOV     BX,[DI+14]              
		LOCE73:
046F:063C E3E5          JCXZ    0623                    
		LOOPE75:
046F:063E E8F5FB        CALL    0236                    
046F:0641 81FFFF0F      CMP     DI,0FFF                 
046F:0645 74DC          JZ      0623                    
046F:0647 87FB          XCHG    DI,BX                   
046F:0649 42            INC     DX                      
046F:064A E2F2          LOOP    063E                    
046F:064C C3            RET                             

		LOCE84:
046F:064D 41            INC     CX                      
046F:064E 4A            DEC     DX                      
046F:064F C3            RET                             

		LOAD:
046F:0650 E87DFF        CALL    05D0                    
046F:0653 26            SEG     ES                      
046F:0654 8B5D18        MOV     BX,[DI+18]              
046F:0657 2BD8          SUB     BX,AX                   
046F:0659 7677          JBE     06D2                    
046F:065B 3BD9          CMP     BX,CX                   
046F:065D 7309          JNC     0668                    
046F:065F C606850E01    MOV     B,[0E85],01             
046F:0664 891E8C0E      MOV     [0E8C],BX               
		LOAD01:
046F:0668 8A4E03        MOV     CL,[BP+03]              
046F:066B D3E8          SHR     AX,CL                   
046F:066D 8BC8          MOV     CX,AX                   
046F:066F E8B2FF        CALL    0624                    
046F:0672 0BC9          OR      CX,CX                   
046F:0674 756C          JNZ     06E2                    
046F:0676 8A16880E      MOV     DL,[0E88]               
046F:067A 225602        AND     DL,[BP+02]              
046F:067D 8B0E8C0E      MOV     CX,[0E8C]               
		RDLP:
046F:0681 E8EC00        CALL    0770                    
046F:0684 57            PUSH    DI                      
046F:0685 50            PUSH    AX                      
046F:0686 1E            PUSH    DS                      
046F:0687 8E1E810E      MOV     DS,[0E81]               
046F:068B E82EFE        CALL    04BC                    
046F:068E 1F            POP     DS                      
046F:068F 59            POP     CX                      
046F:0690 5B            POP     BX                      
046F:0691 E30D          JCXZ    06A0                    
046F:0693 B200          MOV     DL,00                   
046F:0695 81FBFF0F      CMP     BX,0FFF                 
046F:0699 75E6          JNZ     0681                    
046F:069B C606850E01    MOV     B,[0E85],01             
		LOAD03:
046F:06A0 A18E0E        MOV     AX,[0E8E]               
046F:06A3 8B3E860E      MOV     DI,[0E86]               
046F:06A7 26            SEG     ES                      
046F:06A8 894516        MOV     [DI+16],AX              
046F:06AB A1880E        MOV     AX,[0E88]               
046F:06AE 8B1E900E      MOV     BX,[0E90]               
046F:06B2 03C3          ADD     AX,BX                   
046F:06B4 26            SEG     ES                      
046F:06B5 3B4518        CMP     AX,[DI+18]              
046F:06B8 7609          JBE     06C3                    
046F:06BA 26            SEG     ES                      
046F:06BB 894518        MOV     [DI+18],AX              
046F:06BE 26            SEG     ES                      
046F:06BF C6451DFF      MOV     B,[DI+1D],FF            
		LOAD04:
046F:06C3 48            DEC     AX                      
046F:06C4 8BD0          MOV     DX,AX                   
046F:06C6 8A4E03        MOV     CL,[BP+03]              
046F:06C9 D3EA          SHR     DX,CL                   
046F:06CB 26            SEG     ES                      
046F:06CC 89551A        MOV     [DI+1A],DX              
046F:06CF 8BCB          MOV     CX,BX                   
046F:06D1 C3            RET                             

		LOCF09:
046F:06D2 EB0E          JP      06E2                    

		LOFF0D:
046F:06D4 8BC8          MOV     CX,AX                   
046F:06D6 53            PUSH    BX                      
046F:06D7 E84AFF        CALL    0624                    
046F:06DA E369          JCXZ    0745                    
046F:06DC E8FC00        CALL    07DB                    
046F:06DF 5B            POP     BX                      
046F:06E0 7364          JNC     0746                    
		WRTERRJ:
046F:06E2 C606850E01    MOV     B,[0E85],01             
046F:06E7 A1880E        MOV     AX,[0E88]               
046F:06EA 33C9          XOR     CX,CX                   
046F:06EC 8B3E860E      MOV     DI,[0E86]               
046F:06F0 C3            RET                             

		; unsure what this is for but based on where it's
		; called from, it's WRTEOF.
		WRTEOF:
046F:06F1 8A4E03        MOV     CL,[BP+03]              
046F:06F4 D3E8          SHR     AX,CL                   
046F:06F6 8BC8          MOV     CX,AX                   
046F:06F8 E829FF        CALL    0624                    
046F:06FB 0BC9          OR      CX,CX                   
046F:06FD 75E8          JNZ     06E7                    
046F:06FF BAFF0F        MOV     DX,0FFF                 
046F:0702 C6460FFF      MOV     B,[BP+0F],FF    
		UPDATE:
046F:0706 8B3E860E      MOV     DI,[0E86]               
046F:070A A1880E        MOV     AX,[0E88]               
046F:070D 26            SEG     ES                      
046F:070E 894518        MOV     [DI+18],AX              
046F:0711 26            SEG     ES                      
046F:0712 C6451DFF      MOV     B,[DI+1D],FF            
046F:0716 33C9          XOR     CX,CX                   
046F:0718 C3            RET                             

		STORE:
046F:0719 E8B4FE        CALL    05D0                    
046F:071C E3D3          JCXZ    06F1                    
046F:071E 8BD9          MOV     BX,CX                   
046F:0720 03D8          ADD     BX,AX                   
046F:0722 4B            DEC     BX                      
046F:0723 8A4E03        MOV     CL,[BP+03]              
046F:0726 D3E8          SHR     AX,CL                   
046F:0728 D3EB          SHR     BX,CL                   
046F:072A 8BC8          MOV     CX,AX                   
046F:072C 8BC3          MOV     AX,BX                   
046F:072E E8F3FE        CALL    0624                    
046F:0731 2BC2          SUB     AX,DX                   
046F:0733 E39F          JCXZ    06D4                    
046F:0735 51            PUSH    CX                      
046F:0736 8BC8          MOV     CX,AX                   
046F:0738 E8A000        CALL    07DB                    
046F:073B 59            POP     CX                      
046F:073C 72A4          JC      06E2                    
046F:073E 49            DEC     CX                      
046F:073F 7405          JZ      0746                    
046F:0741 E8FAFE        CALL    063E                    
046F:0744 53            PUSH    BX                      
		LOCF58:
046F:0745 5B            POP     BX                      
		LOCF59:
046F:0746 8A16880E      MOV     DL,[0E88]               
046F:074A 225602        AND     DL,[BP+02]              
046F:074D 8B0E8C0E      MOV     CX,[0E8C]               
		NOTINBUF:
046F:0751 E81C00        CALL    0770                    
046F:0754 57            PUSH    DI                      
046F:0755 50            PUSH    AX                      
046F:0756 1E            PUSH    DS                      
046F:0757 8E1E810E      MOV     DS,[0E81]               
046F:075B E87EFD        CALL    04DC                    
046F:075E 1F            POP     DS                      
046F:075F 59            POP     CX                      
046F:0760 5B            POP     BX                      
046F:0761 B200          MOV     DL,00                   
046F:0763 0BC9          OR      CX,CX                   
046F:0765 75EA          JNZ     0751                    
046F:0767 E836FF        CALL    06A0                    
046F:076A 26            SEG     ES                      
046F:076B C6451CFF      MOV     B,[DI+1C],FF            
046F:076F C3            RET                             

		OPTIMIZE:
046F:0770 52            PUSH    DX                      
046F:0771 53            PUSH    BX                      
046F:0772 8A4602        MOV     AL,[BP+02]              
046F:0775 FEC0          INC     AL                      
046F:0777 8AE0          MOV     AH,AL                   
046F:0779 2AC2          SUB     AL,DL                   
046F:077B 8BD1          MOV     DX,CX                   
046F:077D 8B7610        MOV     SI,[BP+10]              
046F:0780 B90000        MOV     CX,0000                 

		OPTCLUS:
046F:0783 E8B0FA        CALL    0236                    
046F:0786 02C8          ADD     CL,AL                   
046F:0788 82D500        ADC     CH,00                   
046F:078B 3BCA          CMP     CX,DX                   
046F:078D 7337          JNC     07C6                    
046F:078F 8AC4          MOV     AL,AH                   
046F:0791 43            INC     BX                      
046F:0792 3BFB          CMP     DI,BX                   
046F:0794 74ED          JZ      0783                    
046F:0796 4B            DEC     BX                      

		FINCLUS:
046F:0797 891E8E0E      MOV     [0E8E],BX               
046F:079B 2BD1          SUB     DX,CX                   
046F:079D 8BC2          MOV     AX,DX                   
046F:079F 8BD9          MOV     BX,CX                   
046F:07A1 86DF          XCHG    BL,BH                   
046F:07A3 D1CB          ROR     BX                      
046F:07A5 8B368A0E      MOV     SI,[0E8A]               
046F:07A9 03DE          ADD     BX,SI                   
046F:07AB 891E8A0E      MOV     [0E8A],BX               
046F:07AF 010E900E      ADD     [0E90],CX               
046F:07B3 5A            POP     DX                      
046F:07B4 5B            POP     BX                      
046F:07B5 51            PUSH    CX                      
046F:07B6 8A4E03        MOV     CL,[BP+03]              
046F:07B9 4A            DEC     DX                      
046F:07BA 4A            DEC     DX                      
046F:07BB D3E2          SHL     DX,CL                   
046F:07BD 0AD3          OR      DL,BL                   
046F:07BF 03560B        ADD     DX,[BP+0B]              
046F:07C2 59            POP     CX                      
046F:07C3 8BDE          MOV     BX,SI                   
046F:07C5 C3            RET                             

		BLKDON:
046F:07C6 8BCA          MOV     CX,DX                   
046F:07C8 EBCD          JP      0797                    

		GETREC:
046F:07CA 8BFA          MOV     DI,DX                   
046F:07CC 8A4520        MOV     AL,[DI+20]              
046F:07CF 8B5D0C        MOV     BX,[DI+0C]              
046F:07D2 D0E0          SHL     AL                      
046F:07D4 D1EB          SHR     BX                      
046F:07D6 D0D8          RCR     AL                      
046F:07D8 8AE3          MOV     AH,BL                   
046F:07DA C3            RET                             

		ALLOCATE:
046F:07DB 53            PUSH    BX                      
046F:07DC 8BC3          MOV     AX,BX                   
		ALLOC:
046F:07DE 8BD3          MOV     DX,BX                   
		FINDFRE:
046F:07E0 43            INC     BX                      
046F:07E1 3B5E0D        CMP     BX,[BP+0D]              
046F:07E4 7C12          JL      07F8                    
046F:07E6 3D0100        CMP     AX,0001                 
046F:07E9 7F12          JG      07FD                    
046F:07EB 5B            POP     BX                      
046F:07EC BAFF0F        MOV     DX,0FFF                 
046F:07EF E84500        CALL    0837                    
046F:07F2 810CFF0F      OR      W,[SI],0FFF             
		MAXREC:
046F:07F6 F9            STC                             
		RET11:
046F:07F7 C3            RET                             

		TRYOUT:
046F:07F8 E83BFA        CALL    0236                    
046F:07FB 740C          JZ      0809                    
		TRYIN:
046F:07FD 48            DEC     AX                      
046F:07FE 7EE0          JLE     07E0                    
046F:0800 93            XCHG    BX,AX                   
046F:0801 E832FA        CALL    0236                    
046F:0804 7403          JZ      0809                    
046F:0806 93            XCHG    BX,AX                   
046F:0807 EBD7          JP      07E0                    

		HAVFRE:
046F:0809 87D3          XCHG    DX,BX                   
046F:080B 8BC2          MOV     AX,DX                   
046F:080D E84CFA        CALL    025C                    
046F:0810 8BD8          MOV     BX,AX                   
046F:0812 E2CA          LOOP    07DE                    
046F:0814 BAFF0F        MOV     DX,0FFF                 
046F:0817 E842FA        CALL    025C                    
046F:081A C6460FFF      MOV     B,[BP+0F],FF            
046F:081E 5B            POP     BX                      
046F:081F E814FA        CALL    0236                    
046F:0822 87FB          XCHG    DI,BX                   
046F:0824 0BFF          OR      DI,DI                   
046F:0826 75CF          JNZ     07F7                    
046F:0828 8B3E860E      MOV     DI,[0E86]               
046F:082C 26            SEG     ES                      
046F:082D 895D14        MOV     [DI+14],BX              
046F:0830 810CFF0F      OR      W,[SI],0FFF             
		RET12:
046F:0834 C3            RET                             

		RELEASE:
046F:0835 33D2          XOR     DX,DX                   
		RELBLKS:
046F:0837 E8FCF9        CALL    0236                    
046F:083A 74F8          JZ      0834                    
046F:083C 8BC7          MOV     AX,DI                   
046F:083E E81BFA        CALL    025C                    
046F:0841 3DFF0F        CMP     AX,0FFF                 
046F:0844 8BD8          MOV     BX,AX                   
046F:0846 75ED          JNZ     0835                    
		RET13:
046F:0848 C3            RET                             

		GETOF:
046F:0849 E8EAF9        CALL    0236                    
046F:084C 81FFFF0F      CMP     DI,0FFF                 
046F:0850 74F6          JZ      0848                    
046F:0852 8BDF          MOV     BX,DI                   
046F:0854 EBF3          JP      0849                    

		SRCHFRST:
046F:0856 E828FA        CALL    0281                
		SAVPLCE:
046F:0859 7219          JC      0874                    
046F:085B A2DC0C        MOV     [0CDC],AL               
046F:085E 891EDD0C      MOV     [0CDD],BX               
046F:0862 892EDF0C      MOV     [0CDF],BP               
046F:0866 8BF3          MOV     SI,BX                   
046F:0868 C43E7F0E      LES     DI,[0E7F]               
		NORMFCB:
046F:086C B90800        MOV     CX,0008                 
046F:086F F3            REPZ                            
046F:0870 A5            MOVW                            
046F:0871 B000          MOV     AL,00                   
046F:0873 C3            RET                             

		KILLSRCH
046F:0874 B0FF          MOV     AL,FF                   
046F:0876 A2DC0C        MOV     [0CDC],AL               
		RET14:
046F:0879 C3            RET                             

		SRCHNXT:
046F:087A 8CC8          MOV     AX,CS                   
046F:087C 8EC0          MOV     ES,AX                   
046F:087E 8ED8          MOV     DS,AX                   
046F:0880 A0DC0C        MOV     AL,[0CDC]               
046F:0883 3CFF          CMP     AL,FF                   
046F:0885 74F2          JZ      0879                    
046F:0887 8B1EDD0C      MOV     BX,[0CDD]               
046F:088B 8B2EDF0C      MOV     BP,[0CDF]               
046F:088F E802FA        CALL    0294                    
046F:0892 EBC5          JP      0859     

		FILESIZE:
046F:0894 57            PUSH    DI                      
046F:0895 52            PUSH    DX                      
046F:0896 E8E8F9        CALL    0281                    
046F:0899 5F            POP     DI                      
046F:089A 07            POP     ES                      
046F:089B B0FF          MOV     AL,FF                   
046F:089D 72DA          JC      0879                    
046F:089F 83C721        ADD     DI,+21                  
046F:08A2 8D770D        LEA     SI,[BX+0D]              
046F:08A5 AC            LODB                            
046F:08A6 D0E0          SHL     AL                      
046F:08A8 AD            LODW                            
046F:08A9 D1D0          RCL     AX                      
046F:08AB AB            STOW                            
046F:08AC B000          MOV     AL,00                   
046F:08AE D0D0          RCL     AL                      
046F:08B0 AA            STOB                            
046F:08B1 C3            RET                             

		SETDMA:
046F:08B2 2E            SEG     CS                      
046F:08B3 89167F0E      MOV     [0E7F],DX               
046F:08B7 2E            SEG     CS                      
046F:08B8 8C1E810E      MOV     [0E81],DS               
046F:08BC C3            RET                             

		GETFATPT:
046F:08BD 8CC8          MOV     AX,CS                   
046F:08BF 8ED8          MOV     DS,AX                   
046F:08C1 8C0ED20E      MOV     [0ED2],CS               
046F:08C5 8B2EDA0E      MOV     BP,[0EDA]               
046F:08C9 E8D4FA        CALL    03A0                    
046F:08CC 8B5E10        MOV     BX,[BP+10]              
046F:08CF 8A4602        MOV     AL,[BP+02]              
046F:08D2 FEC0          INC     AL                      
046F:08D4 8B560D        MOV     DX,[BP+0D]              
046F:08D7 4A            DEC     DX                      
046F:08D8 C6460FFF      MOV     B,[BP+0F],FF            
046F:08DC 891EC60E      MOV     [0EC6],BX               
046F:08E0 8916CA0E      MOV     [0ECA],DX               
046F:08E4 C3            RET                             

		GETDSKPT:
046F:08E5 2E            SEG     CS                      
046F:08E6 8C0ED20E      MOV     [0ED2],CS               
046F:08EA 2E            SEG     CS                      
046F:08EB 8B1EDA0E      MOV     BX,[0EDA]               
046F:08EF 2E            SEG     CS                      
046F:08F0 891EC60E      MOV     [0EC6],BX               
046F:08F4 C3            RET                

		DSKRESET:
046F:08F5 2E            SEG     CS                      
046F:08F6 8C1E810E      MOV     [0E81],DS               
046F:08FA 8CC8          MOV     AX,CS                   
046F:08FC 8ED8          MOV     DS,AX                   
046F:08FE C7067F0E8000  MOV     W,[0E7F],0080           
046F:0904 A1DC0E        MOV     AX,[0EDC]               
046F:0907 A3DA0E        MOV     [0EDA],AX               
		DSKRST01:
046F:090A 8A0E680E      MOV     CL,[0E68]               
046F:090E B500          MOV     CH,00                   
046F:0910 BEDC0E        MOV     SI,0EDC                 
		WRTFAT:
046F:0913 AD            LODW                            
046F:0914 51            PUSH    CX                      
046F:0915 56            PUSH    SI                      
046F:0916 8BE8          MOV     BP,AX                   
046F:0918 E803FB        CALL    041E                    
046F:091B 5E            POP     SI                      
046F:091C 59            POP     CX                      
046F:091D E2F4          LOOP    0913                    
046F:091F B0FF          MOV     AL,FF                   
046F:0921 9A1B004000    CALL    001B,0040               
046F:0926 C3            RET                             

		GETDRV:
046F:0927 2E            SEG     CS                      
046F:0928 8B2EDA0E      MOV     BP,[0EDA]               
046F:092C 8A4600        MOV     AL,[BP+00]              
046F:092F C3            RET                             

		INUSE:
046F:0930 8CC8          MOV     AX,CS                   
046F:0932 8ED8          MOV     DS,AX                   
046F:0934 8A0E680E      MOV     CL,[0E68]               
046F:0938 B500          MOV     CH,00                   
046F:093A 8BF1          MOV     SI,CX                   
046F:093C D1E6          SHL     SI                      
046F:093E 81C6DA0E      ADD     SI,0EDA                 
046F:0942 BB0000        MOV     BX,0000                 
046F:0945 FD            DOWN                            
		IULOOP:
046F:0946 AD            LODW                            
046F:0947 8BE8          MOV     BP,AX                   
046F:0949 F6460FFF      TEST    B,[BP+0F],FF            
046F:094D 7401          JZ      0950                    
046F:094F F9            STC                             
		IU01:
046F:0950 D1D3          RCL     BX                      
046F:0952 E2F2          LOOP    0946                    
046F:0954 8AC3          MOV     AL,BL                   
046F:0956 C3            RET                             

		SETRNDREC:
046F:0957 E870FE        CALL    07CA                    
046F:095A 894521        MOV     [DI+21],AX              
046F:095D B000          MOV     AL,00                   
046F:095F 7402          JZ      0963                    
046F:0961 FEC0          INC     AL                      
		RET15:
046F:0963 884523        MOV     [DI+23],AL              
		RET16:
046F:0966 C3            RET                             

		SELDSK:
046F:0967 B600          MOV     DH,00                   
046F:0969 8BDA          MOV     BX,DX                   
046F:096B 0E            PUSH    CS                      
046F:096C 1F            POP     DS                      
046F:096D 3A1E680E      CMP     BL,[0E68]               
046F:0971 7DF3          JGE     0966                    
046F:0973 D1E3          SHL     BX                      
046F:0975 8B87DC0E      MOV     AX,[BX+0EDC]            
046F:0979 A3DA0E        MOV     [0EDA],AX               
		RET17:
046F:097C C3            RET 

		BUFIN:
046F:097D 8CC8          MOV     AX,CS                   
046F:097F 8EC0          MOV     ES,AX                   
046F:0981 8BF2          MOV     SI,DX                   
046F:0983 B500          MOV     CH,00                   
046F:0985 AD            LODW                            
046F:0986 0AC0          OR      AL,AL                   
046F:0988 74F2          JZ      097C                    
046F:098A 8ADC          MOV     BL,AH                   
046F:098C 8AFD          MOV     BH,CH                   
046F:098E 3AC3          CMP     AL,BL                   
046F:0990 7605          JBE     0997                    
046F:0992 82380D        CMP     B,[BX+SI],0D            
046F:0995 7402          JZ      0999                    
		NOEDIT:
046F:0997 8ADD          MOV     BL,CH                   
		EDITON:
046F:0999 8AD0          MOV     DL,AL                   
046F:099B 4A            DEC     DX                      
		NEWLIN:
046F:099C 2E            SEG     CS                      
046F:099D A0D90C        MOV     AL,[0CD9]               
046F:09A0 2E            SEG     CS                      
046F:09A1 A2DA0C        MOV     [0CDA],AL               
046F:09A4 56            PUSH    SI                      
046F:09A5 BFE90C        MOV     DI,0CE9                 
046F:09A8 8AE5          MOV     AH,CH                   
046F:09AA 8AFD          MOV     BH,CH                   
046F:09AC 8AF5          MOV     DH,CH                   
		GETCH:
046F:09AE E81F02        CALL    0BD0                    
046F:09B1 3C7F          CMP     AL,7F                   
046F:09B3 7475          JZ      0A2A                    
046F:09B5 3C08          CMP     AL,08                   
046F:09B7 7471          JZ      0A2A                    
046F:09B9 3C0D          CMP     AL,0D                   
046F:09BB 7438          JZ      09F5                    
046F:09BD 3C0A          CMP     AL,0A                   
046F:09BF 7458          JZ      0A19                    
046F:09C1 3C18          CMP     AL,18                   
046F:09C3 7459          JZ      0A1E                    
046F:09C5 3C1B          CMP     AL,1B                   
046F:09C7 7417          JZ      09E0                    
		SAVCH:
046F:09C9 3AF2          CMP     DH,DL                   
046F:09CB 73E1          JNC     09AE                    
046F:09CD AA            STOB                            
046F:09CE FEC6          INC     DH                      
046F:09D0 E85601        CALL    0B29                    
046F:09D3 0AE4          OR      AH,AH                   
046F:09D5 75D7          JNZ     09AE                    
046F:09D7 3AFB          CMP     BH,BL                   
046F:09D9 73D3          JNC     09AE                    
046F:09DB 46            INC     SI                      
046F:09DC FEC7          INC     BH                      
046F:09DE EBCE          JP      09AE                    

		ESC:
046F:09E0 E8ED01        CALL    0BD0                    
046F:09E3 B118          MOV     CL,18                   
046F:09E5 57            PUSH    DI                      
046F:09E6 BF0300        MOV     DI,0003                 
046F:09E9 F2            REPNZ                           
046F:09EA AE            SCAB                            
046F:09EB 5F            POP     DI                      
046F:09EC 80E1FE        AND     CL,FE                   
046F:09EF 8BE9          MOV     BP,CX                   
046F:09F1 FFA60F0B      JMP     [BP+0B0F]               

		ENDLIN:
046F:09F5 AA            STOB                            
046F:09F6 E83001        CALL    0B29                    
046F:09F9 5F            POP     DI                      
046F:09FA 8875FF        MOV     [DI-01],DH              
046F:09FD FEC6          INC     DH                      
		COPYNEW:
046F:09FF 8CC5          MOV     BP,ES                   
046F:0A01 8CDB          MOV     BX,DS                   
046F:0A03 8EC3          MOV     ES,BX                   
046F:0A05 8EDD          MOV     DS,BP                   
046F:0A07 BEE90C        MOV     SI,0CE9                 
046F:0A0A 8ACE          MOV     CL,DH                   
046F:0A0C F3            REPZ                            
046F:0A0D A4            MOVB                            
046F:0A0E C3            RET                             

		CRLF:
046F:0A0F B00D          MOV     AL,0D                   
046F:0A11 E81501        CALL    0B29                    
046F:0A14 B00A          MOV     AL,0A                   
046F:0A16 E91001        JMP     0B29                    

		PHYCRLF:
046F:0A19 E8F3FF        CALL    0A0F                    
046F:0A1C EB90          JP      09AE                    

		KILLNEW:
046F:0A1E B05C          MOV     AL,5C                   
046F:0A20 E80601        CALL    0B29                    
046F:0A23 5E            POP     SI                      
		PUTNEW:
046F:0A24 E8E8FF        CALL    0A0F                    
046F:0A27 E972FF        JMP     099C                    

		BACKSP:
046F:0A2A 0AF6          OR      DH,DH                   
046F:0A2C 7411          JZ      0A3F                    
046F:0A2E E84E00        CALL    0A7F                    
046F:0A31 26            SEG     ES                      
046F:0A32 8A05          MOV     AL,[DI]                 
046F:0A34 3C20          CMP     AL,20                   
046F:0A36 7307          JNC     0A3F                    
046F:0A38 3C09          CMP     AL,09                   
046F:0A3A 7411          JZ      0A4D                    
046F:0A3C E84300        CALL    0A82                    

		OLDBAK:
046F:0A3F 0AE4          OR      AH,AH                   
046F:0A41 7507          JNZ     0A4A                    
046F:0A43 0AFF          OR      BH,BH                   
046F:0A45 7403          JZ      0A4A                    
046F:0A47 FECF          DEC     BH                      
046F:0A49 4E            DEC     SI                      
		GETCH1:
046F:0A4A E961FF        JMP     09AE                    

		BAKTAB:
046F:0A4D 57            PUSH    DI                      
046F:0A4E 4F            DEC     DI                      
046F:0A4F FD            DOWN                            
046F:0A50 8ACE          MOV     CL,DH                   
046F:0A52 B020          MOV     AL,20                   
046F:0A54 53            PUSH    BX                      
046F:0A55 B307          MOV     BL,07                   
046F:0A57 E30E          JCXZ    0A67                    
		FNDPOS:
046F:0A59 AE            SCAB                            
046F:0A5A 7609          JBE     0A65                    
046F:0A5C 26            SEG     ES                      
046F:0A5D 827D0109      CMP     B,[DI+01],09            
046F:0A61 7409          JZ      0A6C                    
046F:0A63 FECB          DEC     BL                      
		CHKCNT:
046F:0A65 E2F2          LOOP    0A59                    
		FIGTAB:
046F:0A67 2E            SEG     CS                      
046F:0A68 2A1EDA0C      SUB     BL,[0CDA]               
		HAVTAB:
046F:0A6C 2ADE          SUB     BL,DH                   
046F:0A6E 02CB          ADD     CL,BL                   
046F:0A70 80E107        AND     CL,07                   
046F:0A73 FC            UP                              
046F:0A74 5B            POP     BX                      
046F:0A75 5F            POP     DI                      
046F:0A76 74C7          JZ      0A3F                    
		TABBAK:
046F:0A78 E80700        CALL    0A82                    
046F:0A7B E2FB          LOOP    0A78                    
046F:0A7D EBC0          JP      0A3F                    
		BACKUP:
046F:0A7F FECE          DEC     DH                      
046F:0A81 4F            DEC     DI                      
		BACKMES:
046F:0A82 B008          MOV     AL,08                   
046F:0A84 E8A200        CALL    0B29                    
046F:0A87 B020          MOV     AL,20                   
046F:0A89 E8AA00        CALL    0B36                    
046F:0A8C B008          MOV     AL,08                   
046F:0A8E E9A500        JMP     0B36                    

		TWOESC:
046F:0A91 B01B          MOV     AL,1B                   
046F:0A93 E933FF        JMP     09C9                    

		COPYLIN:
046F:0A96 8ACB          MOV     CL,BL                   
046F:0A98 2ACF          SUB     CL,BH                   
046F:0A9A EB07          JP      0AA3                    

		COPYSTR:
046F:0A9C E82E00        CALL    0ACD                    
046F:0A9F EB02          JP      0AA3                    

		COPYONE:
046F:0AA1 B101          MOV     CL,01                   
		COPYEACH:
046F:0AA3 3AF2          CMP     DH,DL                   
046F:0AA5 740F          JZ      0AB6                    
046F:0AA7 3AFB          CMP     BH,BL                   
046F:0AA9 740B          JZ      0AB6                    
046F:0AAB AC            LODB                            
046F:0AAC AA            STOB                            
046F:0AAD E87900        CALL    0B29                    
046F:0AB0 FEC7          INC     BH                      
046F:0AB2 FEC6          INC     DH                      
046F:0AB4 E2ED          LOOP    0AA3                    
		GETCH2:
046F:0AB6 E9F5FE        JMP     09AE                    
		SKIPONE:
046F:0AB9 3AFB          CMP     BH,BL                   
046F:0ABB 74F9          JZ      0AB6                    
046F:0ABD FEC7          INC     BH                      
046F:0ABF 46            INC     SI                      
046F:0AC0 E9EBFE        JMP     09AE                    
046F:0AC3 E80700        CALL    0ACD                    
046F:0AC6 03F1          ADD     SI,CX                   
046F:0AC8 02F9          ADD     BH,CL                   
046F:0ACA E9E1FE        JMP     09AE                    

		FINDOLD:
046F:0ACD E80001        CALL    0BD0                    
046F:0AD0 8ACB          MOV     CL,BL                   
046F:0AD2 2ACF          SUB     CL,BH                   
046F:0AD4 7417          JZ      0AED                    
046F:0AD6 49            DEC     CX                      
046F:0AD7 7414          JZ      0AED                    
046F:0AD9 06            PUSH    ES                      
046F:0ADA 1E            PUSH    DS                      
046F:0ADB 07            POP     ES                      
046F:0ADC 57            PUSH    DI                      
046F:0ADD 8BFE          MOV     DI,SI                   
046F:0ADF 47            INC     DI                      
046F:0AE0 F2            REPNZ                           
046F:0AE1 AE            SCAB                            
046F:0AE2 5F            POP     DI                      
046F:0AE3 07            POP     ES                      
046F:0AE4 7507          JNZ     0AED                    
046F:0AE6 F6D1          NOT     CL                      
046F:0AE8 02CB          ADD     CL,BL                   
046F:0AEA 2ACF          SUB     CL,BH                   
		RET18:
046F:0AEC C3            RET                             

		NOTFND:
046F:0AED 5D            POP     BP                      
046F:0AEE E9BDFE        JMP     09AE                    

		REEDIT:
046F:0AF1 B040          MOV     AL,40                   
046F:0AF3 E83300        CALL    0B29                    
046F:0AF6 5F            POP     DI                      
046F:0AF7 57            PUSH    DI                      
046F:0AF8 06            PUSH    ES                      
046F:0AF9 1E            PUSH    DS                      
046F:0AFA E802FF        CALL    09FF                    
046F:0AFD 1F            POP     DS                      
046F:0AFE 07            POP     ES                      
046F:0AFF 5E            POP     SI                      
046F:0B00 8ADE          MOV     BL,DH                   
046F:0B02 E91FFF        JMP     0A24  

		ENTERINS:
046F:0B05 B4FF          MOV     AH,FF                   
046F:0B07 E9A4FE        JMP     09AE                    

		EXITINS:
046F:0B0A B400          MOV     AH,00                   
046F:0B0C E99FFE        JMP     09AE                    

		ESCFUNC:
;046F:0B0F AE            SCAB                            
;046F:0B10 09910A0A      OR      [BX+DI+0A0A],DX         
;046F:0B14 0B05          OR      AX,[DI]                 
;046F:0B16 0B2A          OR      BP,[BP+SI]              
;046F:0B18 0AF1          OR      DH,CL                   
;046F:0B1A 0A1E0A96      OR      BL,[960A]               
;046F:0B1E 0AC3          OR      AL,BL                   
;046F:0B20 0A9C0AB9      OR      BL,[SI+B90A]            
;046F:0B24 0AA10A
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
		;
		;BUFOUT is missing
		;
		;0B27
		CONOUT
			MOV	AL,DL
		B_OUT:
			CMP	AL," "
046F:0B2B 724D          JC      0B7A                    
046F:0B2D 3C7F          CMP     AL,7F                   
046F:0B2F 7405          JZ      0B36                    
046F:0B31 2E            SEG     CS                      
046F:0B32 FE06D90C      INC     B,[0CD9]                
		OUTCH:
046F:0B36 9A09004000    CALL    0009,0040               
046F:0B3B 2E            SEG     CS                      
046F:0B3C F606DB0CFF    TEST    B,[0CDB],FF             
046F:0B41 7405          JZ      0B48                    
046F:0B43 9A0C004000    CALL    000C,0040               
		BOUT2:
046F:0B48 9A03004000    CALL    0003,0040               
046F:0B4D 749D          JZ      0AEC                    
		INCHK:
046F:0B4F 9A06004000    CALL    0006,0040               
046F:0B54 3C13          CMP     AL,13                   
046F:0B56 7505          JNZ     0B5D                    
046F:0B58 9A06004000    CALL    0006,0040               
		BOUT4:
046F:0B5D 3C10          CMP     AL,10                   
046F:0B5F 740B          JZ      0B6C                    
046F:0B61 3C0E          CMP     AL,0E                   
046F:0B63 740E          JZ      0B73                    
046F:0B65 3C03          CMP     AL,03                   
046F:0B67 7583          JNZ     0AEC                    
046F:0B69 CD23          INT     23                      
		RET19:
046F:0B6B C3            RET                             

		PRINTON:
046F:0B6C 2E            SEG     CS                      
046F:0B6D C606DB0C01    MOV     B,[0CDB],01             
046F:0B72 C3            RET                             

		PRINTOFF:
046F:0B73 2E            SEG     CS                      
046F:0B74 C606DB0C00    MOV     B,[0CDB],00             
046F:0B79 C3            RET                             

		CTRLOUT:
046F:0B7A 3C0A          CMP     AL,0A                   
046F:0B7C 74B8          JZ      0B36                    
046F:0B7E 3C0D          CMP     AL,0D                   
046F:0B80 7413          JZ      0B95                    
046F:0B82 3C08          CMP     AL,08                   
046F:0B84 7417          JZ      0B9D                    
046F:0B86 3C09          CMP     AL,09                   
046F:0B88 741A          JZ      0BA4                    
046F:0B8A 50            PUSH    AX                      
046F:0B8B B05E          MOV     AL,5E                   
046F:0B8D E899FF        CALL    0B29                    
046F:0B90 58            POP     AX                      
046F:0B91 0C40          OR      AL,40                   
046F:0B93 EB94          JP      0B29                    

		ZEROPOS:
046F:0B95 2E            SEG     CS                      
046F:0B96 C606D90C00    MOV     B,[0CD9],00             
046F:0B9B EB99          JP      0B36                    

		BACKPOS:
046F:0B9D 2E            SEG     CS                      
046F:0B9E FE0ED90C      DEC     B,[0CD9]                
046F:0BA2 EB92          JP      0B36                    

046F:0BA4 B000          MOV     AL,00                   
046F:0BA6 2E            SEG     CS                      
046F:0BA7 8606D90C      XCHG    AL,[0CD9]               
046F:0BAB 0CF8          OR      AL,F8                   
046F:0BAD F6D8          NEG     AL                      
		TAB:
046F:0BAF 51            PUSH    CX                      
046F:0BB0 8AC8          MOV     CL,AL                   
046F:0BB2 B500          MOV     CH,00                   
		TABLP:
046F:0BB4 B020          MOV     AL,20                   
046F:0BB6 E87DFF        CALL    0B36                    
046F:0BB9 E2F9          LOOP    0BB4                    
046F:0BBB 59            POP     CX                      
046F:0BBC C3            RET                             

		CONSTAT:
046F:0BBD 9A03004000    CALL    0003,0040               
046F:0BC2 74F8          JZ      0BBC                    
046F:0BC4 0CFF          OR      AL,FF                   
046F:0BC6 C3            RET

		CONIN:
046F:0BC7 E885FF        CALL    0B4F                    
046F:0BCA 50            PUSH    AX                      
046F:0BCB E85BFF        CALL    0B29                    
046F:0BCE 58            POP     AX                      
046F:0BCF C3            RET                             

		B_IN:
046F:0BD0 E87CFF        CALL    0B4F                    
046F:0BD3 74FB          JZ      0BD0                    
		RET22:
046F:0BD5 C3            RET                             

		RAWIO:
046F:0BD6 8AC2          MOV     AL,DL                   
046F:0BD8 3CFF          CMP     AL,FF                   
046F:0BDA 750D          JNZ     0BE9                    
046F:0BDC 9A03004000    CALL    0003,0040               
046F:0BE1 74F2          JZ      0BD5

		RAWOUT:
046F:0BE3 9A06004000    CALL    0006,0040               
046F:0BE8 C3            RET                             

		RAWINP:
046F:0BE9 9A09004000    CALL    0009,0040               
046F:0BEE C3            RET                             

		LIST:
046F:0BEF 8AC2          MOV     AL,DL                   
046F:0BF1 9A0C004000    CALL    000C,0040               
046F:0BF6 C3            RET                             

		PRTBUF:
046F:0BF7 8BF2          MOV     SI,DX                   
		OUTSTR:
046F:0BF9 AC            LODB                            
046F:0BFA 3C24          CMP     AL,24                   
046F:0BFC 74F8          JZ      0BF6                    
046F:0BFE E828FF        CALL    0B29                    
046F:0C01 EBF6          JP      0BF9                    

		OUTMES:
046F:0C03 2E            SEG     CS                      
046F:0C04 AC            LODB                            
046F:0C05 3C24          CMP     AL,24                   
046F:0C07 74ED          JZ      0BF6                    
046F:0C09 E81DFF        CALL    0B29                    
046F:0C0C EBF5          JP      0C03                    

		;
		; MAKEFCB and related routines missing
		;
		SETVECT:
046F:0C0E 33DB          XOR     BX,BX                   
046F:0C10 8EC3          MOV     ES,BX                   
046F:0C12 8AD8          MOV     BL,AL                   
046F:0C14 D1E3          SHL     BX                      
046F:0C16 D1E3          SHL     BX                      
046F:0C18 26            SEG     ES                      
046F:0C19 8917          MOV     [BX],DX                 
046F:0C1B 26            SEG     ES                      
046F:0C1C 8C5F02        MOV     [BX+02],DS              
046F:0C1F C3            RET                             

		NEWBASE:
046F:0C20 8EC2          MOV     ES,DX                   
046F:0C22 2E            SEG     CS                      
046F:0C23 8E1E830E      MOV     DS,[0E83]               
046F:0C27 33F6          XOR     SI,SI                   
046F:0C29 8BFE          MOV     DI,SI                   
046F:0C2B B98000        MOV     CX,0080                 
046F:0C2E F3            REPZ                            
046F:0C2F A5            MOVW                            

		SETMEM:
046F:0C30 33C9          XOR     CX,CX                   
046F:0C32 8ED9          MOV     DS,CX                   
046F:0C34 8EC2          MOV     ES,DX                   
046F:0C36 BE8800        MOV     SI,0088                 
046F:0C39 BF0A00        MOV     DI,000A                 
046F:0C3C A5            MOVW                            
046F:0C3D A5            MOVW                            
046F:0C3E A5            MOVW                            
046F:0C3F A5            MOVW                            
046F:0C40 2E            SEG     CS                      
046F:0C41 8B0EE50C      MOV     CX,[0CE5]               
046F:0C45 26            SEG     ES                      
046F:0C46 890E0200      MOV     [0002],CX               
046F:0C4A 2BCA          SUB     CX,DX                   
046F:0C4C 81F9FF0F      CMP     CX,0FFF                 
046F:0C50 7603          JBE     0C55                    
046F:0C52 B9FF0F        MOV     CX,0FFF                 

		HAVDIF:
046F:0C55 BB0C00        MOV     BX,000C                 
046F:0C58 2BD9          SUB     BX,CX                   
046F:0C5A D1E1          SHL     CX                      
046F:0C5C D1E1          SHL     CX                      
046F:0C5E D1E1          SHL     CX                      
046F:0C60 D1E1          SHL     CX                      
046F:0C62 8EDA          MOV     DS,DX                   
046F:0C64 890E0600      MOV     [0006],CX               
046F:0C68 891E0800      MOV     [0008],BX               
046F:0C6C C7060000CD20  MOV     W,[0000],20CD           
046F:0C72 C60605009A    MOV     B,[0005],9A             
046F:0C77 C3            RET                             

		SHIFTDI:
046F:0C78 D1E7          SHL     DI                      
046F:0C7A D1E7          SHL     DI                      
046F:0C7C D1E7          SHL     DI                      
046F:0C7E D1E7          SHL     DI                      
046F:0C80 D1E7          SHL     DI                      
046F:0C82 D1E7          SHL     DI                      
046F:0C84 D1E7          SHL     DI                      
046F:0C86 C3            RET                             

		;***** DATA AREA *****
			;ORG	0
		;0C87 - 0CD8
		CONSTRT	EQU	$		;Start of initialized data
		BADFAT: DB	0DH, 0AH, 'Bad FAT', 0DH, 0AH, '$'
		FATSBAD: DB	0DH, 0AH, 'All FATs on disk are bad', 0DH, 0AH, '$'
		RDERR:	DB	0DH, 0AH, 'Disk read error', 0DH, 0AH, '$'
		WRTERR:	DB	0DH, 0AH, 'Disk write error', 0DH, 0AH, '$'
		;this is the same as 034.
046F:0CD9 0000          dw	0         
046F:0CDB 00FF          dw	0xff00
		DOSLEN  EQU     CODSIZ+($-CONSTRT)      ;Size of CODE + CONSTANTS segments
		;this is the same as 034.

		;0CDD - 157F
		; In 010, this is all 0's on the disk image so maybe they were statically
		; initialzied in 010 and unitialzied in 034. A totally blank disk would 
		; have a fill byte of 0xE5. In v034, the total uninitialized area is ~772
		; bytes.
		buffer	db	2213 dup (0)

		; The Programmer's Guide notes that the system tracks are 52 sectors long, 
		; sort of like CP/M which "hides" the whole system within the system 
		; tracks and they're not part of the files accessed by the directory.
		; Assuming 0-start, here is a layout with absolute memory references:
		;	  BOOT: C0/H0/S1
		;	DOSIO is loaded to 400H by the loader
		;	 DOSIO: C0/H0/S2 to C0/H0/S9 (8*128) (0400-07FF) has 100h buffer
		;	 86DOS: C0/H0/S10 to C1/H0/S9 (26*128) (0800-14FF)
		;	buffer: C1/H0/S10 to C1/H0/S26 (17*128) (1500-1D80)
		;	  FAT1: C2/H0/S1 - S6
		;	  FAT2: C2/H0/S7 - S12
		;	   DIR: C2/H0/S13 - S20 8 sectors, 64 names, 16 bytes per entry.
		;	  DATA: C2/H0/S21
		;
		; As it applied to 8" MS-DOS, doc notes that logical_sector = 
		; alloc_unit * 4 + 22 (4 sectors per allocation unit). First allocation unit
		; is 2 (2-494 for 8" disk, 2002 total sectors). Start is Sector 30, 30-22/4 = 2
		; because the system files sat within the data area and referenced in the 
		; directory and FAT, while earlier versions were not.
		; Standard 8: LSN is 0-2001 with SPT=26 and T=77 and 128b
		;
		; Note that 010 directory program doesn't print the file size. 034 does show
		; the file size, so decimal sizes are shown below and they match the sizes.
		;
		; sample directory:
		;  NAME    EXT -FAT- size  ??
		;  ======= === ===== ===== ==
		;  COMMAND COM 02 00 00 05 00	1280
		;  RDCPM   COM 05 00 80 03 00	 896
		;  HEX2BIN COM 07 00 80 01 00	 384
		;  ASM     COM 08 00 00 1A 00	6656
		;  TRANS   COM 15 00 80 0C 00	3200
		;  SYS     COM 1C 00 00 01 00	 256
		;  EDLIN   COM 1D 00 00 05 00	1280
		;  CHESS   COM 1d 00 00 19 00	6400
		;  CHESS   DOC 2D 00 80 03 00	 896

		; Attributes in MS-DOS
		; Bit 7-6 Reserved
		;   5  Archive
		;   4  Reserved (DOS=Subdirectory)
		;   3  Reserved (DOS=Volume label)
		;   2  System file
		;   1  Hidden file
		;   0  Read only

		;1580-15C6 - this matches cylinder 2, sector 1 which is the FAT. Since 
		; code is 0-offset, add 800H (=1D80) which is the absolute byte in the 
		; disk image.
046F:1580 FF                   
046F:1581 FFFF          ???     DI                      
046F:1583 034000        ADD     AX,[BX+SI+00]           
046F:1586 FF6F00        JMP     L,[BX+00]               
046F:1589 FFFF          ???     DI                      
046F:158B FF09          DEC     W,[BX+DI]               
046F:158D A0000B        MOV     AL,[0B00]               
046F:1590 C0            DB      C0                      
046F:1591 000D          ADD     [DI],CL                 
046F:1593 E000          LOOPNZ  1595                    
046F:1595 0F            POP     CS                      
046F:1596 0001          ADD     [BX+DI],AL              
046F:1598 1120          ADC     [BX+SI],SP              
046F:159A 0113          ADD     [BP+DI],DX              
046F:159C 40            INC     AX                      
046F:159D 01FF          ADD     DI,DI                   
046F:159F 6F            DB      6F                      
046F:15A0 0117          ADD     [BX],DX                 
046F:15A2 800119        ADD     B,[BX+DI],19            
046F:15A5 A0011B        MOV     AL,[1B01]               
046F:15A8 F0            LOCK                            
046F:15A9 FFFF          ???     DI                      
046F:15AB EF            OUTW    DX                      
046F:15AC 011F          ADD     [BX],BX                 
046F:15AE F0            LOCK                            
046F:15AF FF21          JMP     [BX+DI]                 
046F:15B1 2002          AND     [BP+SI],AL              
046F:15B3 234002        AND     AX,[BX+SI+02]           
046F:15B6 256002        AND     AX,0260                 
046F:15B9 27            DAA                             
046F:15BA 800229        ADD     B,[BP+SI],29            
046F:15BD A0022B        MOV     AL,[2B02]               
046F:15C0 C0            DB      C0                      
046F:15C1 02FF          ADD     BH,BH                   
046F:15C3 EF            OUTW    DX                      
046F:15C4 02FF          ADD     BH,BH                   
046F:15C6 0F            POP     CS          
		;15C7 - 1855: all zeros
		MEMSTRT:
		END
