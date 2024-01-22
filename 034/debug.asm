		TITLE 'DEBUG'

		ORG	100H
		PUT	100H

		; System Equates
		BUFLEN:	EQU	80		;Maximum length of line input buffer
		BPMAX:	EQU	10		;Maximum number of breakpoints
		BPLEN:	EQU	BPMAX+BPMAX	;Length of breakpoint table
		REGTABLEN:EQU	14		;Number of registers
		SEGDIF:	EQU	800H		;-0FF800H (ROM address)
		BACKSP	EQU	8
		PROMPT	EQU	">"
		CAN	EQU	"@"

		; INT21 functions
		STDIN	EQU	1
		STDOUT	EQU	2
		PSTR	EQU	9
		LINEIN	EQU	0ah
		OPNFIL	EQU	0FH
		CLOSFIL	EQU	10h
		CREATE	EQU	16h
		SETDTA	EQU	1Ah
		CTRLC	EQU	23h
		NEWPSP	EQU	26h
		RNDRD	EQU	27h
		RNDWR	EQU	28h
		
		; Field definition for FCBs
		FNAME   EQU     0       ;Drive code and name
		EXTENT  EQU     9	; extension
		BLOCKS	EQU	0Ch	;block size
		RECSIZ  EQU     0Eh	;Size of record (user settable)
		FILSIZ  EQU     10h	;Size of file in bytes dw
		;DRVBP   EQU     18      ;BP for SEARCH FIRST and SEARCH NEXT
		;FDATE   EQU     20      ;Date of last writing
		;FTIME   EQU     22      ;Time of last writing
		;DEVID   EQU     22      ;Device ID number, bits 0-5
					;bit 7=0 for file, bit 7=1 for I/O device
					;If file, bit 6=0 if dirty
					;If I/O device, bit 6=0 if EOF (input)
		;FIRCLUS EQU     24      ;First cluster of file
		;LSTCLUS EQU     26      ;Last cluster accessed
		;CLUSPOS EQU     28      ;Position of last cluster accessed
		NR      EQU     20h	;Next record in block
		RR      EQU     21h	;Random record number
		;ends at 24h
		FILDIRENT       EQU 16h	;22 Used only by SEARCH FIRST and SEARCH NEXT

		;PSP offsets
		B_INT20		EQU	0	; W INT20
		B_ENDMEM	EQU	2	; W first unavailale segment
		B_RSVD1		EQU	4	; B 04 reserved
		B_LONGCALL	EQU	5	; B opcode for loncall
		B_ENTRYL	EQU	6	; W farptr DOS entry LSB
		B_ENTRYH	EQU	8	; W farptr DOS entry MSB
		B_EXIT		EQU	0AH	; dd exit address (int 22h)
		B_CTRLC		EQU	0EH 	; dd ctrl-c address (int 23h)
		B_FATAL		EQU	12H 	; dd fatal error address (int 24h)
		B_PARENT	EQU	16H 	; dw parent PSP
		B_OPENF		EQU	18H	; b open files (FF=unused)
		;19H  19 BYTES    reserved
		;2CH  WORD        segment of environment block
		;2EH  DWORD       old stack address
		;32H  BYTE        maximum open files
		;34H  DWORD       old file address
		;36H  25 BYTES    reserved
		;50H  WORD        long call address to DOS INT 21H handler
		B_FCB1		EQU	5CH	;16 BYTES    default FCB #1
		B_FCB2		EQU	6CH	;16 BYTES    default FCB #2
		B_RSVD1		EQU	7CH	;4 bytes
		B_DTA		EQU	80H	;128 BYTES   command tail and default DTA

		; RAM area needed for stack, line buffer, registers, BPs

		START:
046F:0100 BAC808        MOV     DX,BANNER	;08C8
046F:0103 B409          MOV     AH,PSTR		;09 print the banner   
046F:0105 CD21          INT     21                      

046F:0107 B82225        MOV     AX,2522		; grab INT22 (termination)...
046F:010A BA6A01        MOV     DX,NEW22	;016A                 
046F:010D CD21          INT     21                      
046F:010F B023          MOV     AL,CTRLC	;23...and INT23 (Cntl-C)
046F:0111 BA6F01        MOV     DX,NEW23	;016F                 
046F:0114 CD21          INT     21                      

046F:0116 8CC8          MOV     AX,CS                   
046F:0118 BA720A        MOV     DX,0A72                 
046F:011B B104          MOV     CL,04                   
046F:011D D3EA          SHR     DX,CL                   
046F:011F 03D0          ADD     DX,AX                   
046F:0121 42            INC     DX                      
046F:0122 B426          MOV     AH,NEWPSP	;26 create PSP          
046F:0124 CD21          INT     21                      
046F:0126 8BC2          MOV     AX,DX                   
046F:0128 BF660A        MOV     DI,0A66                 
046F:012B FC            UP                              
046F:012C AB            STOW                            
046F:012D AB            STOW                            
046F:012E AB            STOW                            
046F:012F AB            STOW                            
046F:0130 C606670901    MOV     B,[FLG1],01     ;967
046F:0135 E88406        CALL    07BC

		COMMAND:
046F:0138 FC            UP                              
046F:0139 8CC8          MOV     AX,CS                   
046F:013B 8ED8          MOV     DS,AX                   
046F:013D 8EC0          MOV     ES,AX                   
046F:013F 8ED0          MOV     SS,AX                   
046F:0141 BC560A        MOV     SP,STACK	;0A56 stack              
046F:0144 B03E          MOV     AL,PROMPT	;3E                   
046F:0146 E8D300        CALL    COUT                    
046F:0149 E83500        CALL    INBUF                  
046F:014C E85C00        CALL    SCANB		;scanb  
046F:014F 74E7          JZ      COMMAND                    
046F:0151 8A05          MOV     AL,[DI] 
		;prepare char for table lookup
046F:0153 2C41          SUB     AL,41                   
046F:0155 7210          JC      CERR		;0167                    
046F:0157 3C19          CMP     AL,19                   
046F:0159 770C          JA      CERR		;0167                    
046F:015B 47            INC     DI                      
046F:015C D0E0          SHL     AL                      
046F:015E 98            CBW                             
046F:015F 93            XCHG    BX,AX                   
046F:0160 2E            SEG     CS                      
046F:0161 FF973102      CALL    [BX+COMTAB]     ;231
046F:0165 EBD1          JP      COMMAND
		CERR:
046F:0167 E9C102        JMP     ERROR

		NEW22:
046F:016A BAE208        MOV     DX,MSG1		;08E2 prog term normallu
046F:016D EB03          JP      PRTSTR		;0172                    

		NEW23:
046F:016F BAFD08        MOV     DX,CRLF2	;08FD  

		PRTSTR:
046F:0172 8CC8          MOV     AX,CS                   
046F:0174 8ED8          MOV     DS,AX                   
046F:0176 8ED0          MOV     SS,AX                   
046F:0178 BC560A        MOV     SP,STACK	;0A56                 
046F:017B B409          MOV     AH,PSTR		; print string                  
046F:017D CD21          INT     21                      
046F:017F EBB7          JP      COMMAND                    

		INBUF:
046F:0181 B40A          MOV     AH,LINEIN	;0A buffered in        
046F:0183 BAD009        MOV     DX,09D0		;buffer 
046F:0186 CD21          INT     21                      
046F:0188 BFD209        MOV     DI,09D2
		
		CRLF:
046F:018B B00D          MOV     AL,0D 		; CR
046F:018D E88C00        CALL    COUT		;021C                    
046F:0190 B00A          MOV     AL,0A  		; LF                  
046F:0192 E98700        JMP     COUT		;021C 

		BACKUP:
046F:0195 BE6509        MOV     SI,BACMENS	;0965 blank-bs

		;print ASCII message. Last char has bit 7 set
		PRINTMES:
046F:0198 2E            SEG     CS                      
046F:0199 AC            LODB                            
046F:019A E87F00        CALL    COUT                    
046F:019D D0E0          SHL     AL                      
046F:019F 73F7          JNC     PRINTMES                    
046F:01A1 C3            RET 

		SCANP:
046F:01A2 E80600        CALL    SCANB                    
046F:01A5 823D2C        CMP     B,[DI],","	;2C               
046F:01A8 750A          JNZ     01B4                    
046F:01AA 47            INC     DI
		SCANB:
046F:01AB B020          MOV     AL," "		;20                   
046F:01AD 51            PUSH    CX                      
046F:01AE B1FF          MOV     CL,-1		;FF                   
046F:01B0 F3            REPZ                            
046F:01B1 AE            SCAB                            
046F:01B2 4F            DEC     DI                      
046F:01B3 59            POP     CX
		EOLCHK:
046F:01B4 823D0D        CMP     B,[DI],0D
046F:01B7 C3            RET 

		;01b8
		HEX:
046F:01B8 B90500        MOV     CX,0005                 
046F:01BB E8EE01        CALL    GETHEX                    
046F:01BE 8BF2          MOV     SI,DX                   
046F:01C0 8AFC          MOV     BH,AH                   
046F:01C2 B90500        MOV     CX,0005                 
046F:01C5 E8E401        CALL    GETHEX                    
046F:01C8 50            PUSH    AX                      
046F:01C9 52            PUSH    DX                      
046F:01CA 03D6          ADD     DX,SI                   
046F:01CC 12E7          ADC     AH,BH                   
046F:01CE E82C00        CALL    01FD                    
046F:01D1 E85300        CALL    BLANK                    
046F:01D4 E85000        CALL    BLANK                    
046F:01D7 5A            POP     DX                      
046F:01D8 58            POP     AX                      
046F:01D9 2BF2          SUB     SI,DX                   
046F:01DB 1AFC          SBB     BH,AH                   
046F:01DD 8BD6          MOV     DX,SI                   
046F:01DF 8AE7          MOV     AH,BH                   
046F:01E1 E81900        CALL    01FD                    
046F:01E4 EBA5          JP      CRLF                    

		OUTSI:
046F:01E6 8CDA          MOV     DX,DS                   
046F:01E8 B400          MOV     AH,00                   
046F:01EA E88600        CALL    SHIFT4                    
046F:01ED 03D6          ADD     DX,SI                   
046F:01EF EB09          JP      OUTADD

		;Print 5-digit hex address of DI and ES
		;Same as OUTSI above
		OUTDI:
046F:01F1 8CC2          MOV     DX,ES                   
046F:01F3 B400          MOV     AH,00                   
046F:01F5 E87B00        CALL    SHIFT4                    
046F:01F8 03D7          ADD     DX,DI 
		OUTADD:
046F:01FA 82D400        ADC     AH,00                   
046F:01FD E81200        CALL    HIDIG                    
		OUT16:
046F:0200 8AC6          MOV     AL,DH                   
046F:0202 E80200        CALL    HEX                    
046F:0205 8AC2          MOV     AL,DL          
		HEX:
046F:0207 8AE0          MOV     AH,AL                   
046F:0209 51            PUSH    CX                      
046F:020A B104          MOV     CL,04                   
046F:020C D2E8          SHR     AL,CL                   
046F:020E 59            POP     CX                      
046F:020F E80200        CALL    DIGIT                    
		HIDIG:
046F:0212 8AC4          MOV     AL,AH                   
		DIGIT:
046F:0214 240F          AND     AL,0F                   
046F:0216 0490          ADD     AL,90                   
046F:0218 27            DAA  
046F:0219 1440          ADC     AL,40                   
046F:021B 27            DAA
		COUT:
046F:021C 86C2          XCHG    AL,DL
		COUT1:
046F:021E 50            PUSH    AX                      
046F:021F B402          MOV     AH,STDOUT	;02                   
046F:0221 CD21          INT     21                      
046F:0223 58            POP     AX                      
046F:0224 86C2          XCHG    AL,DL                   
046F:0226 C3            RET 

		BLANK:
046F:0227 B020          MOV     AL," "		;20                   
046F:0229 EBF1          JP      COUT

		TAB:
046F:022B E8F9FF        CALL    BLANK                    
046F:022E E2FB          LOOP    TAB                    
046F:0230 C3            RET

		;Command Table. Command letter indexes into table to get
		;address of command. PERR prints error for no such command.
		; valid commands are D-E-F-G-H-I-L-M-N-O-Q-R-S-T-W
		;0231
		COMTAB:
046F:0231 2A04		dw	PERR		; A               
046F:0233 2A04		dw	PERR 		; B
046F:0235 2A04		dw	PERR 		; C
046F:0237 CF02		dw	DUMP		; D
046F:0239 4A04		DW	CENTER		; E
046F:023B 5903 		DW	FILL		; F
046F:023d 3907		DW	GO		; G
046F:023F B801		DW	HEX		; H
046F:0242 1507		DW	INPUT		; I
046F:0243 2A04		dw	PERR 		; J                 
046F:0245 2A04 		dw	PERR 		; K
046F:0247 B507		DW	LOAD		; L
046F:0249 2C03		DW	MOVE		; M
046F:024B 8A07		DW	NAME		; N
046F:024D 2507		DW	OUTPUT		; O
046F:024F 2a04		dw	PERR 		; P
046F:0251 0000 		dw	0 		; Q jumps to exit address in PSP
046F:0253 fb04 		DW	REG		; R
046F:0255 7c03		DW	SEARCH		; S
	  3606		DW	TRACE		; T
	  2A04		dw	PERR 		; U
046F:025B 2A04		dw	PERR 		; V
046F:025D 2508 		DW	WRITE		; W
046F:025F 2A04		dw	PERR 		; X
046F:0261 2A04		dw	PERR 		; Y
046F:0263 2A04		dw	PERR 		; Z

		;Given 20-bit address in AH:DX, breaks it down to a segment
		;number in AX and a displacement in DX. Displacement is 
		;always zero except for least significant 4 bits.
		;0264
		GETSEG:
046F:0265 8AC2		MOV	AL,DL               
046F:0267 240F		AND	AL,0FH
046F:0269 E80700        CALL    SHIFT4                    
046F:026C 8AD0          MOV     DL,AL                   
046F:026E 8AC6          MOV     AL,DH                   
046F:0270 32F6          XOR     DH,DH                   
046F:0272 C3            RET 

		; shift ah:dx left 4 bits 
		SHIFT4:
046F:0273 D1E2          SHL     DX                      
046F:0275 D0D4          RCL     AH                      
046F:0277 D1E2          SHL     DX                      
046F:0279 D0D4          RCL     AH                      
046F:027B D1E2          SHL     DX                      
046F:027D D0D4          RCL     AH                      
046F:027F D1E2          SHL     DX                      
046F:0281 D0D4          RCL     AH                      
046F:0283 C3            RET

		RANGE:
046F:0284 B90500        MOV     CX,0005                 
046F:0287 E82201        CALL    GETHEX                    
046F:028A 50            PUSH    AX                      
046F:028B 52            PUSH    DX                      
046F:028C E813FF        CALL    SCANP                    
046F:028F 823D4C        CMP     B,[DI],"L"	;4C               
046F:0292 741C          JZ      GETLEN		;02B0                    
046F:0294 BA8000        MOV     DX,0080                 
046F:0297 E83001        CALL    HEXIN                    
046F:029A 721B          JC      RNGRET		;02B7                    
046F:029C B90500        MOV     CX,0005                 
046F:029F E80A01        CALL    GETHEX                    
046F:02A2 8BCA          MOV     CX,DX                   
046F:02A4 5A            POP     DX                      
046F:02A5 5B            POP     BX                      
046F:02A6 2BCA          SUB     CX,DX                   
046F:02A8 1AE7          SBB     AH,BH                   
046F:02AA 751D          JNZ     RNGERR		;02C9                    
046F:02AC 93            XCHG    BX,AX                   
046F:02AD 41            INC     CX                      
046F:02AE EB0B          JP      RNGCHK		;02BB
		GETLEN:
046F:02B0 47            INC     DI                      
046F:02B1 B90400        MOV     CX,0004                 
046F:02B4 E8F500        CALL    GETHEX
		RNGRET:
046F:02B7 8BCA          MOV     CX,DX                   
046F:02B9 5A            POP     DX                      
046F:02BA 58            POP     AX                      
		RNGCHK:
046F:02BB 8BDA          MOV     BX,DX                   
046F:02BD 81E30F00      AND     BX,000F                 
046F:02C1 E304          JCXZ    MAXRNG		;02C7                    
046F:02C3 03D9          ADD     BX,CX                   
046F:02C5 739E          JNC     GETSEG                    
		MAXRNG:
046F:02C7 749C          JZ      GETSEG                    
		RNGERR:
046F:02C9 B85247        MOV     AX,4700h+"R"	;4752                 
046F:02CC E92903        JMP     ERR

		DUMP:
046F:02CF E8B2FF        CALL    RANGE                    
046F:02D2 50            PUSH    AX                      
046F:02D3 E84E01        CALL    GETEOL                    
046F:02D6 1F            POP     DS                      
046F:02D7 8BF2          MOV     SI,DX 
		ROW:
046F:02D9 E80AFF        CALL    OUTSI                    
046F:02DC 56            PUSH    SI                      
		BYTE:
046F:02DD E847FF        CALL    BLANK                    
		BYTE1:
046F:02E0 AC            LODB           
046F:02E1 E823FF        CALL    HEX                    
046F:02E4 5A            POP     DX                      
046F:02E5 49            DEC     CX                      
046F:02E6 7417          JZ      ASCII                    
046F:02E8 8BC6          MOV     AX,SI                   
046F:02EA A80F          TEST    AL,0F                   
046F:02EC 740C          JZ      ENDROW                    
046F:02EE 52            PUSH    DX                      
046F:02EF A807          TEST    AL,07                   
046F:02F1 75EA          JNZ     02DD                    
046F:02F3 B02D          MOV     AL,"-"                   
046F:02F5 E824FF        CALL    COUT                    
046F:02F8 EBE6          JP      BYTE1 
		ENDROW:
046F:02FA E80200        CALL    ASCII                    
046F:02FD EBDA          JP      02D9

		ASCII:
046F:02FF 51            PUSH    CX                      
046F:0300 8BC6          MOV     AX,SI                   
046F:0302 8BF2          MOV     SI,DX                   
046F:0304 2BC2          SUB     AX,DX                   
046F:0306 8BD8          MOV     BX,AX                   
046F:0308 D1E0          SHL     AX                      
046F:030A 03C3          ADD     AX,BX                   
046F:030C B93300        MOV     CX,0033                 
046F:030F 2BC8          SUB     CX,AX                   
046F:0311 E817FF        CALL    TAB                    
046F:0314 8BCB          MOV     CX,BX 
		ASCDMP:
046F:0316 AC            LODB                            
046F:0317 247F          AND     AL,7F                   
046F:0319 3C7F          CMP     AL,7F                   
046F:031B 7404          JZ      NOPRT	;0321                    
046F:031D 3C20          CMP     AL,20                   
046F:031F 7302          JNC     PRIN	;0323                    
		NOPRT:
046F:0321 B02E          MOV     AL,"."	;2E                   
		PRIN:
046F:0323 E8F6FE        CALL    COUT                    
046F:0326 E2EE          LOOP    ASCDMP		;0316                    
046F:0328 59            POP     CX                      
046F:0329 E95FFE        JMP     CRLF

		MOVE:
046F:032C E855FF        CALL    RANGE                    
046F:032F 51            PUSH    CX                      
046F:0330 50            PUSH    AX                      
046F:0331 8BF2          MOV     SI,DX                   
046F:0333 B90500        MOV     CX,0005                 
046F:0336 E87300        CALL    GETHEX                    
046F:0339 E8E800        CALL    GETEOL                    
046F:033C E826FF        CALL    GETSEG                    
046F:033F 8BFA          MOV     DI,DX                   
046F:0341 5B            POP     BX                      
046F:0342 8EDB          MOV     DS,BX                   
046F:0344 8EC0          MOV     ES,AX                   
046F:0346 59            POP     CX                      
046F:0347 3BFE          CMP     DI,SI                   
046F:0349 1BC3          SBB     AX,BX                   
046F:034B 7207          JC      COPYLIST	;0354                    
046F:034D 49            DEC     CX                      
046F:034E 03F1          ADD     SI,CX                   
046F:0350 03F9          ADD     DI,CX                   
046F:0352 FD            DOWN                            
046F:0353 41            INC     CX                      
		COPYLIST:
046F:0354 A4            MOVB                            
046F:0355 49            DEC     CX                      
046F:0356 F3            REPZ                            
046F:0357 A4            MOVB 
		RET2:
046F:0358 C3            RET

		FILL:
046F:0359 E828FF        CALL    RANGE                    
046F:035C 51            PUSH    CX                      
046F:035D 50            PUSH    AX                      
046F:035E 52            PUSH    DX                      
046F:035F E8B400        CALL    LIST                    
046F:0362 5F            POP     DI                      
046F:0363 07            POP     ES                      
046F:0364 59            POP     CX                      
046F:0365 3BD9          CMP     BX,CX                   
046F:0367 BE8009        MOV     SI,LINEBUF		;LINEBUF
046F:036A E302          JCXZ    BIGRNG		;036E                    
046F:036C 73E6          JNC     COPYLIST	;0354                    
		BIGRNG:
046F:036E 2BCB          SUB     CX,BX                   
046F:0370 87D9          XCHG    BX,CX                   
046F:0372 57            PUSH    DI                      
046F:0373 F3            REPZ                            
046F:0374 A4            MOVB                            
046F:0375 5E            POP     SI                      
046F:0376 8BCB          MOV     CX,BX                   
046F:0378 06            PUSH    ES                      
046F:0379 1F            POP     DS                      
046F:037A EBD8          JP      COPYLIST	;0354

		SEARCH:
046F:037C E805FF        CALL    RANGE                    
046F:037F 51            PUSH    CX                      
046F:0380 50            PUSH    AX                      
046F:0381 52            PUSH    DX                      
046F:0382 E89100        CALL    LIST                    
046F:0385 4B            DEC     BX                      
046F:0386 5F            POP     DI                      
046F:0387 07            POP     ES                      
046F:0388 59            POP     CX                      
046F:0389 2BCB          SUB     CX,BX  
		SCAN:
046F:038B BE8009        MOV     SI,LINEBUF		;LINEBUF
046F:038E AC            LODB
		DOSCAN:
046F:038F AE            SCAB                            
046F:0390 E0FD          LOOPNZ  DOSCAN		;038F                    
046F:0392 75C4          JNZ     RET2		;0358                    
046F:0394 53            PUSH    BX                      
046F:0395 87CB          XCHG    CX,BX                   
046F:0397 57            PUSH    DI                      
046F:0398 F3            REPZ                            
046F:0399 A6            CMPB                            
046F:039A 8BCB          MOV     CX,BX                   
046F:039C 5F            POP     DI                      
046F:039D 5B            POP     BX                      
046F:039E 7508          JNZ     TEST		;03A8                    
046F:03A0 4F            DEC     DI                      
046F:03A1 E84DFE        CALL    OUTDI                    
046F:03A4 47            INC     DI                      
046F:03A5 E8E3FD        CALL    CRLF
		TEST:
046F:03A8 E3AE          JCXZ    RET2		;0358                    
046F:03AA EBDF          JP      SCAN		;038B

		GETHEX:
046F:03AC E8F3FD        CALL    SCANP    
		GETHEX1:
046F:03AF 33D2          XOR     DX,DX                   
046F:03B1 8AE6          MOV     AH,DH                   
046F:03B3 E81400        CALL    HEXIN                    
046F:03B6 7273          JC      ERROR                    
046F:03B8 8AD0          MOV     DL,AL   
		GETLP:
046F:03BA 47            INC     DI                      
046F:03BB 49            DEC     CX                      
046F:03BC E80B00        CALL    HEXIN                    
046F:03BF 7297          JC      RET2                    
046F:03C1 E368          JCXZ    ERROR                    
046F:03C3 E8ADFE        CALL    SHIFT4                    
046F:03C6 0AD0          OR      DL,AL                   
046F:03C8 EBF0          JP      GETLP	;03BA

		HEXIN:
046F:03CA 8A05          MOV     AL,[DI]  
		HEXCHK:
046F:03CC 2C30          SUB     AL,"0"
046F:03CE 7288          JC      RET2     ;0358               
046F:03D0 3C0A          CMP     AL,10                   
046F:03D2 F5            CMC                             
046F:03D3 7383          JNC     RET2     ;0358          
046F:03D5 2C07          SUB     AL,07                   
046F:03D7 3C0A          CMP     AL,10                  
046F:03D9 7203          JC      RET3	;03DE            
046F:03DB 3C10          CMP     AL,16
046F:03DD F5            CMC
		RET3:
046F:03DE C3            RET

		LISTITEM:
046F:03DF E8C0FD        CALL    SCANP                    
046F:03E2 E8E5FF        CALL    HEXIN                    
046F:03E5 720B          JC      STRINGCHK	;03F2                    
046F:03E7 B90200        MOV     CX,0002                 
046F:03EA E8BFFF        CALL    GETHEX                    
046F:03ED 8817          MOV     [BX],DL                 
046F:03EF 43            INC     BX   
		GRET:
046F:03F0 F8            CLC                             
046F:03F1 C3            RET

		STRINGCHK:
046F:03F2 8A05          MOV     AL,[DI]                 
046F:03F4 3C27          CMP     AL,"'"
046F:03F6 7406          JZ      03FE                    
046F:03F8 3C22          CMP     AL,22                   
046F:03FA 7402          JZ      03FE                    
046F:03FC F9            STC                             
046F:03FD C3            RET

		STRING:
046F:03FE 8AE0          MOV     AH,AL                   
046F:0400 47            INC     DI                      
		STRNGLP:
046F:0401 8A05          MOV     AL,[DI]                 
046F:0403 47            INC     DI                      
046F:0404 3C0D          CMP     AL,0D                   
046F:0406 7423          JZ      ERROR                    
046F:0408 3AC4          CMP     AL,AH                   
046F:040A 7505          JNZ     STOSTRG		;0411                    
046F:040C 3A25          CMP     AH,[DI]                 
046F:040E 75E0          JNZ     GRET		;03F0                    
046F:0410 47            INC     DI
		STOSTRG:
046F:0411 8807          MOV     [BX],AL                 
046F:0413 43            INC     BX                      
046F:0414 EBEB          JP      STRNGLP		;0401

		LIST:
046F:0416 BB8009        MOV     BX,LINEBUF		;LINEBUF
		LISTLP:
046F:0419 E8C3FF        CALL    LISTITEM                    
046F:041C 73FB          JNC     LISTLP		;0419                    
046F:041E 81EB8009      SUB     BX,LINEBUF		;LINEBUF       
046F:0422 7407          JZ      ERROR 
		
		GETEOL:
046F:0424 E884FD        CALL    SCANB                    
046F:0427 7502          JNZ     ERROR                    
046F:0429 C3            RET

		PERR:
046F:042A 4F            DEC     DI
		ERROR:
046F:042B 81EFD109      SUB     DI,09D1		;LINEBUF-1          
046F:042F 8BCF          MOV     CX,DI                   
046F:0431 E8F7FD        CALL    TAB                    
046F:0434 BE5C09        MOV     SI,SYNERR	;095C  error
		PRINT:
046F:0437 E85EFD        CALL    PRINTMES                    
046F:043A E9FBFC        JMP     COMMAND 

		GETLIST:
046F:043D E8D6FF        CALL    LIST                    
046F:0440 5F            POP     DI                      
046F:0441 07            POP     ES                      
046F:0442 BE8009        MOV     SI,LINEBUF    	; LINEBUF             
046F:0445 8BCB          MOV     CX,BX                   
046F:0447 F3            REPZ                            
046F:0448 A4            MOVB                            
046F:0449 C3            RET 

		CENTER:
046F:044A B90500        MOV     CX,0005                 
046F:044D E85CFF        CALL    GETHEX                    
046F:0450 E812FE        CALL    GETSEG                    
046F:0453 82EC08        SUB     AH,08                   
046F:0456 80C680        ADD     DH,80                   
046F:0459 50            PUSH    AX                      
046F:045A 52            PUSH    DX                      
046F:045B E84DFD        CALL    SCANB                    
046F:045E 75DD          JNZ     GETLIST		;043D                    
046F:0460 5F            POP     DI                      
046F:0461 07            POP     ES                      
		GETROW:
046F:0462 E88CFD        CALL    OUTDI                    
046F:0465 E8BFFD        CALL    BLANK                    
		GETBYTE:
046F:0468 26            SEG     ES                      
046F:0469 8A05          MOV     AL,[DI]                 
046F:046B E899FD        CALL    HEX
		GETBYT2:
046F:046E B02E          MOV     AL,"."		;2E                   
046F:0470 E8A9FD        CALL    COUT                    
046F:0473 B90200        MOV     CX,0002                 
046F:0476 BA0000        MOV     DX,0000
		GETDIG:
046F:0479 E87A00        CALL    CIN                    
046F:047C 8AE0          MOV     AH,AL                   
046F:047E E84BFF        CALL    HEXCHK                    
046F:0481 86E0          XCHG    AH,AL                   
046F:0483 7209          JC      NOHEX	;048E                    
046F:0485 8AF2          MOV     DH,DL                   
046F:0487 8AD4          MOV     DL,AH                   
046F:0489 E2EE          LOOP    GETDIG	;0479  
		WAIT:
046F:048B E86800        CALL    CIN                    
		NOHEX:
046F:048E 3C08          CMP     AL,BACKSP		;08                   
046F:0490 7421          JZ      BS		;04B3                    
046F:0492 3C7F          CMP     AL,7F                   
046F:0494 7418          JZ      DOBS		;04AE                    
046F:0496 3C2D          CMP     AL,"-"		;2D                   
046F:0498 744F          JZ      PREV		;04E9
046F:049A 3C0D          CMP     AL,0D                   
046F:049C 7452          JZ	EOL		;04F0               
046F:049E 3C20          CMP     AL," "		;20                   
046F:04A0 7433          JZ      NEXT		;04D5          
046F:04A2 B008          MOV     AL,BACKSP	;08                   
046F:04A4 E875FD        CALL    COUT                    
046F:04A7 E8EBFC        CALL    BACKUP		;0195                    
046F:04AA E3DF          JCXZ    WAIT		;048B                    
046F:04AC EBCB          JP      GETDIG		;0479

		DOBS:
046F:04AE B008          MOV     AL,BACKSP		;08                   
046F:04B0 E869FD        CALL    COUT                    
		BS:
046F:04B3 82F902        CMP     CL,02                   
046F:04B6 74B6          JZ      GETBYT2		;046E                    
046F:04B8 FEC1          INC     CL                      
046F:04BA 8AD6          MOV     DL,DH                   
046F:04BC 8AF5          MOV     DH,CH                   
046F:04BE E8D4FC        CALL    BACKUP		;0195                    
046F:04C1 EBB6          JP      GETDIG		;0479

		STORE:
046F:04C3 82F902        CMP     CL,02                   
046F:04C6 740B          JZ      NOSTO		;04D3                    
046F:04C8 51            PUSH    CX                      
046F:04C9 B104          MOV     CL,04                   
046F:04CB D2E6          SHL     DH,CL                   
046F:04CD 59            POP     CX                      
046F:04CE 0AD6          OR      DL,DH                   
046F:04D0 26            SEG     ES                      
046F:04D1 8815          MOV     [DI],DL                 
		NOSTO:
046F:04D3 47            INC     DI                      
046F:04D4 C3            RET

		NEXT:
046F:04D5 E8EBFF        CALL    STORE                    
046F:04D8 41            INC     CX                      
046F:04D9 41            INC     CX                      
046F:04DA E84EFD        CALL    TAB                    
046F:04DD 8BC7          MOV     AX,DI                   
046F:04DF 2407          AND     AL,07                   
046F:04E1 7585          JNZ     GETBYTE		;0468                    
		NEWROW:
046F:04E3 E8A5FC        CALL    CRLF                    
046F:04E6 E979FF        JMP     GETROW		;0462

		PREV:
046F:04E9 E8D7FF        CALL    STORE                    
046F:04EC 4F            DEC     DI                      
046F:04ED 4F            DEC     DI                      
046F:04EE EBF3          JP      NEWROW		;04E3 

		EOL:
046F:04F0 E8D0FF        CALL    STORE                    
046F:04F3 E995FC        JMP     CRLF

		CIN:
046F:04F6 B401          MOV     AH,STDIN	;01                   
046F:04F8 CD21          INT     21                      
046F:04FA C3            RET 

		REG:
046F:04FB E8A4FC        CALL    SCANP                    
046F:04FE 7462          JZ      DISPREG		;0562                    
046F:0500 8A15          MOV     DL,[DI]                 
046F:0502 47            INC     DI                      
046F:0503 8A35          MOV     DH,[DI]                 
046F:0505 82FE0D        CMP     DH,0D                   
046F:0508 7476          JZ      FLAG		;0580                    
046F:050A 47            INC     DI                      
046F:050B E816FF        CALL    GETEOL                    
046F:050E 82FE20        CMP     DH," "                   
046F:0511 746D          JZ	FLAG		; 0580                    
046F:0513 BF6C08        MOV     DI,REGTAB	;086C                 
046F:0516 92            XCHG    DX,AX                   
046F:0517 0E            PUSH    CS                      
046F:0518 07            POP     ES                      
046F:0519 B90E00        MOV     CX,REGTABLEN	;000E                 
046F:051C F2            REPNZ                           
046F:051D AF            SCAW                            
046F:051E 753C          JNZ     BADREG		;055C                    
046F:0520 0BC9          OR      CX,CX                   
046F:0522 7506          JNZ     NOTPC		;052A                    
046F:0524 4F            DEC     DI                      
046F:0525 4F            DEC     DI                      
046F:0526 2E            SEG     CS                      
046F:0527 8B45FE        MOV     AX,[DI-02] 
		NOTPC:
046F:052A E8EFFC        CALL    COUT                    
046F:052D 8AC4          MOV     AL,AH                   
046F:052F E8EAFC        CALL    COUT                    
046F:0532 E8F2FC        CALL    BLANK                    
046F:0535 1E            PUSH    DS                      
046F:0536 07            POP     ES                      
046F:0537 8D9DE801      LEA     BX,[DI+REGDIF-2]	;01E8]            
046F:053B 8B17          MOV     DX,[BX]                 
046F:053D E8C0FC        CALL    OUT16                    
046F:0540 E848FC        CALL    CRLF                    
046F:0543 B03A          MOV     AL,":"		;3A                   
046F:0545 E8D4FC        CALL    COUT                    
046F:0548 E836FC        CALL    INBUF                    
046F:054B E85DFC        CALL    SCANB                    
046F:054E 740B          JZ      RET4		;055B                    
046F:0550 B90400        MOV     CX,0004                 
046F:0553 E859FE        CALL    03AF                    
046F:0556 E8CBFE        CALL    GETEOL                    
046F:0559 8917          MOV     [BX],DX 
		RET4:
046F:055B C3            RET 

		BADREG:
046F:055C B84252        MOV     AX,5200H+"B"	;5242                 
046F:055F E99600        JMP     ERR

		DISPREG:
046F:0562 BE6C08        MOV     SI,REGTAB	;086C                 
046F:0565 BB560A        MOV     BX,AXSAVE	;0A56                 
046F:0568 B90800        MOV     CX,0008                 
046F:056B E86500        CALL    DISPREGLINE	;05D3                    
046F:056E E81AFC        CALL    CRLF                    
046F:0571 B90500        MOV     CX,0005                 
046F:0574 E85C00        CALL    DISPREGLINE	;05D3                    
046F:0577 E8ADFC        CALL    BLANK                    
046F:057A E89300        CALL    DISPFLAGS	;0610                    
046F:057D E90BFC        JMP     CRLF

		FLAG:
046F:0580 82FA46        CMP     DL,"F"                   
046F:0583 75D7          JNZ     BADREG                    
046F:0585 E88800        CALL    DISPFLAGS                    
046F:0588 B02D          MOV     AL,"-"		;2D                   
046F:058A E88FFC        CALL    COUT                    
046F:058D E8F1FB        CALL    INBUF                    
046F:0590 E818FC        CALL    SCANB                    
046F:0593 33DB          XOR     BX,BX                   
046F:0595 8B16700A      MOV     DX,[FSAVE]	;[0A70] 
		GETFLG:
046F:0599 8BF7          MOV     SI,DI                   
046F:059B AD            LODW                            
046F:059C 3C0D          CMP     AL,0D                   
046F:059E 7466          JZ      SAVCHG	;0606                    
046F:05A0 82FC0D        CMP     AH,0D                   
046F:05A3 7466          JZ      060B                    
046F:05A5 BF8808        MOV     DI,0888                 
046F:05A8 B92000        MOV     CX,0020                 
046F:05AB 0E            PUSH    CS                      
046F:05AC 07            POP     ES                      
046F:05AD F2            REPNZ                           
046F:05AE AF            SCAW                            
046F:05AF 755A          JNZ     060B                    
046F:05B1 8AE9          MOV     CH,CL                   
046F:05B3 80E10F        AND     CL,0F                   
046F:05B6 B80100        MOV     AX,0001                 
046F:05B9 D3C0          ROL     AX,CL                   
046F:05BB 85C3          TEST    AX,BX                   
046F:05BD 7533          JNZ     05F2                    
046F:05BF 0BD8          OR      BX,AX                   
046F:05C1 0BD0          OR      DX,AX                   
046F:05C3 F6C510        TEST    CH,10                   
046F:05C6 7502          JNZ     05CA                    
046F:05C8 33D0          XOR     DX,AX                   
046F:05CA 8BFE          MOV     DI,SI                   
046F:05CC 1E            PUSH    DS                      
046F:05CD 07            POP     ES                      
046F:05CE E8D1FB        CALL    SCANP                    
046F:05D1 EBC6          JP      0599

		DISPREGLINE:
046F:05D3 2E            SEG     CS                      
046F:05D4 AD            LODW                            
046F:05D5 E844FC        CALL    COUT                    
046F:05D8 8AC4          MOV     AL,AH                   
046F:05DA E83FFC        CALL    COUT                    
046F:05DD B03D          MOV     AL,"="		;3D                   
046F:05DF E83AFC        CALL    COUT                    
046F:05E2 8B17          MOV     DX,[BX]                 
046F:05E4 43            INC     BX                      
046F:05E5 43            INC     BX                      
046F:05E6 E817FC        CALL    OUT16                    
046F:05E9 E83BFC        CALL    BLANK                    
046F:05EC E838FC        CALL    BLANK                    
046F:05EF E2E2          LOOP    DISPREGLINE	;05D3                    
046F:05F1 C3            RET

		REPFLG:
046F:05F2 B84446        MOV     AX,4600H+"D"	;4644                 
		FERR:
046F:05F5 E80E00        CALL    SAVCHG		;0606
		ERR:
046F:05F8 E821FC        CALL    COUT                    
046F:05FB 8AC4          MOV     AL,AH                   
046F:05FD E81CFC        CALL    COUT                    
046F:0600 BE5D09        MOV     SI,ERRMES	;095D                 
046F:0603 E931FE        JMP     PRINT

		SAVCHG:
046F:0606 8916700A      MOV     [FSAVE],DX            ;a70
046F:060A C3            RET
		FLGERR:
046F:060B B84246        MOV     AX,4600H+"B"	;4642                 
046F:060E EBE5          JP      FERR		;05F5

		DISPFLAGS:
046F:0610 BE8808        MOV     SI,FLAGTAB	;0888                 
046F:0613 B91000        MOV     CX,0010       
046F:0616 8B16700A      MOV     DX,[FSAVE]       ;a70
		DFLAGS:
046F:061A 2E            SEG     CS                      
046F:061B AD            LODW                            
046F:061C D1E2          SHL     DX                      
046F:061E 7204          JC      0624                    
046F:0620 2E            SEG     CS                      
046F:0621 8B441E        MOV     AX,[SI+1E]              
		FLAGSET:
046F:0624 0BC0          OR      AX,AX                   
046F:0626 740B          JZ      NEXTFLG		;0633                    
046F:0628 E8F1FB        CALL    COUT                    
046F:062B 8AC4          MOV     AL,AH                   
046F:062D E8ECFB        CALL    COUT                    
046F:0630 E8F4FB        CALL    BLANK                    
		NEXTFLG:
046F:0633 E2E5          LOOP    DFLAGS		;061A                    
046F:0635 C3            RET

		TRACE:
046F:0636 E869FB        CALL    SCANP                    
046F:0639 E88EFD        CALL    HEXIN                    
046F:063C BA0100        MOV     DX,0001                 
046F:063F 7206          JC      STOCNT		;0647                    
046F:0641 B90400        MOV     CX,0004                 
046F:0644 E865FD        CALL    GETHEX                    
		STOCNT:
046F:0647 89166A09      MOV     [TCOUNT],DX    	;96a           
046F:064B E8D6FD        CALL    GETEOL                    
		STEP:
046F:064E C70668090000  MOV     W,[BRKCNT],0000     ;968      
046F:0654 800E710A01    OR      B,[FSAVE+1],01      ;a71
		EXIT:
046F:0659 33C0          XOR     AX,AX                   
046F:065B 8ED8          MOV     DS,AX                   
046F:065D C7060C00A506  MOV     W,[000C],BREAKFIX	;06A5 INT22?
046F:0663 8C0E0E00      MOV     [000E],CS               
046F:0667 C7060400AC06  MOV     W,[0004],REENTER	;06AC RESVD
046F:066D 8C0E0600      MOV     [0006],CS		;DOS segment
046F:0671 FA            DI                              
046F:0672 C7066400AC06  MOV     W,[0064],REENTER	;06AC           
046F:0678 8C0E6600      MOV     [0066],CS               
046F:067C BC560A        MOV     SP,STACK		;0A56                 
046F:067F 8CC8          MOV     AX,CS                   
046F:0681 8ED8          MOV     DS,AX                   
046F:0683 58            POP     AX                      
046F:0684 5B            POP     BX                      
046F:0685 59            POP     CX                      
046F:0686 5A            POP     DX                      
046F:0687 5D            POP     BP                      
046F:0688 5D            POP     BP                      
046F:0689 5E            POP     SI                      
046F:068A 5F            POP     DI                      
046F:068B 07            POP     ES                      
046F:068C 07            POP     ES                      
046F:068D 17            POP     SS                      
046F:068E 8B265E0A      MOV     SP,[SPSAVE]	;[0A5E]               
046F:0692 FF36700A      PUSH    [FSAVE]		;[0A70]                  
046F:0696 FF366C0A      PUSH    [CSSAVE]	;[0A6C]                  
046F:069A FF366E0A      PUSH    [IPSAVE]	;[0A6E]                  
046F:069E 8E1E660A      MOV     DS,[DSSAVE]	;[0A66]               
046F:06A2 CF            IRET 
		STEP1:
046F:06A3 EBA9          JP      STEP		;064E

		BREAKFIX:
046F:06A5 87EC          XCHG    BP,SP                   
046F:06A7 FF4E00        DEC     W,[BP+00]               
046F:06AA 87EC          XCHG    BP,SP
		REENTER:
046F:06AC 2E            SEG     CS                      
046F:06AD 89265E0A      MOV     [SPSAVE+SEGDIF],SP	;[0A5E],SP               
046F:06B1 2E            SEG     CS                      
046F:06B2 8C166A0A      MOV     [SSSAVE+SEGDIF],SS	;[0A6A],SS               
046F:06B6 8CCC          MOV     SP,CS                   
046F:06B8 8ED4          MOV     SS,SP                   
046F:06BA BC6A0A        MOV     SP,RSTACK		;0A6A                 
046F:06BD 06            PUSH    ES                      
046F:06BE 1E            PUSH    DS                      
046F:06BF 57            PUSH    DI                      
046F:06C0 56            PUSH    SI                      
046F:06C1 55            PUSH    BP                      
046F:06C2 4C            DEC     SP                      
046F:06C3 4C            DEC     SP                      
046F:06C4 52            PUSH    DX                      
046F:06C5 51            PUSH    CX                      
046F:06C6 53            PUSH    BX                      
046F:06C7 50            PUSH    AX                      
046F:06C8 16            PUSH    SS                      
046F:06C9 1F            POP     DS                      
046F:06CA 8B265E0A      MOV     SP,[SPSAVE]	;[0A5E]               
046F:06CE 8E166A0A      MOV     SS,[SSSAVE]	;[0A6A]               
046F:06D2 8F066E0A      POP     [IPSAVE]	;[0A6E]                  
046F:06D6 8F066C0A      POP     [CSSAVE]	;[0A6C]                  
046F:06DA 58            POP     AX                      
046F:06DB 80E4FE        AND     AH,FE                   
046F:06DE A3700A        MOV     [FSAVE],AX      ;a70
046F:06E1 89265E0A      MOV     [SPSAVE],SP     ;a5e
046F:06E5 1E            PUSH    DS                      
046F:06E6 07            POP     ES                      
046F:06E7 1E            PUSH    DS                      
046F:06E8 17            POP     SS                      
046F:06E9 BC560A        MOV     SP,STACK	;0A56                 
046F:06EC FC            UP                              
046F:06ED E89BFA        CALL    CRLF                    
046F:06F0 E86FFE        CALL    DISPREG		;0562                    
046F:06F3 FF0E6A09      DEC     W,[TCOUNT]	;[096A]                
046F:06F7 75AA          JNZ     STEP1		;06A3                    
		ENDGO:
046F:06F9 BE6C09        MOV     SI,BPTAB	;096C                 
046F:06FC 8B0E6809      MOV     CX,[BRKCNT]	;[0968]               
046F:0700 E310          JCXZ    COMJMP		;0712  
		CLEARBP:
046F:0702 8B5414        MOV     DX,[SI+BPLEN]   :+14
046F:0705 AD            LODW                            
046F:0706 50            PUSH    AX                      
046F:0707 E85BFB        CALL    GETSEG                    
046F:070A 8EC0          MOV     ES,AX                   
046F:070C 8BFA          MOV     DI,DX                   
046F:070E 58            POP     AX                      
046F:070F AA            STOB                            
046F:0710 E2F0          LOOP    CLEARBP		;0702                    
		COMJMP:
046F:0712 E923FA        JMP     COMMAND

		INPUT:
046F:0715 B90400        MOV     CX,0004                 
046F:0718 E891FC        CALL    GETHEX                    
046F:071B E806FD        CALL    GETEOL                    
046F:071E EC            INB     DX                      
046F:071F E8E5FA        CALL    HEX                    
046F:0722 E966FA        JMP     CRLF

		OUTPUT:
046F:0725 B90400        MOV     CX,0004                 
046F:0728 E881FC        CALL    GETHEX                    
046F:072B 52            PUSH    DX                      
046F:072C B90200        MOV     CX,0002                 
046F:072F E87AFC        CALL    GETHEX                    
046F:0732 E8EFFC        CALL    GETEOL                    
046F:0735 92            XCHG    DX,AX                   
046F:0736 5A            POP     DX                      
046F:0737 EE            OUTB    DX                      
046F:0738 C3            RET 

		GO:
046F:0739 BB8009        MOV     BX,LINEBUF	;0980                 
046F:073C 33F6          XOR     SI,SI                   
		GO1:
046F:073E E861FA        CALL    SCANP                    
046F:0741 7419          JZ      EXEC		;075C                    
046F:0743 B90500        MOV     CX,0005
046F:0746 E863FC        CALL    GETHEX                    
046F:0749 8917          MOV     [BX],DX                 
046F:074B 8867ED        MOV     [BX-BPLEN-1],AH              
046F:074E 43            INC     BX                      
046F:074F 43            INC     BX                      
046F:0750 46            INC     SI                      
046F:0751 83FE0B        CMP     SI,BPMAX+1	;+0B                  
046F:0754 75E8          JNZ     GO1		;073E                    
046F:0756 B84250        MOV     AX,5000H+"B"	;5042 BP error                 
046F:0759 E99CFE        JMP     ERR 

		EXEC:
046F:075C 89366809      MOV     [BRKCNT],SI         ;0968      
046F:0760 E8C1FC        CALL    GETEOL                    
046F:0763 8BCE          MOV     CX,SI                   
046F:0765 E31A          JCXZ    NOBP		;0781                    
046F:0767 BE6C09        MOV     SI,BPTAB	;096C     
		SETBP:
046F:076A 8B5414        MOV     DX,[SI+BPLEN]              
046F:076D AD            LODW                            
046F:076E E8F4FA        CALL    GETSEG                    
046F:0771 8ED8          MOV     DS,AX                   
046F:0773 8BFA          MOV     DI,DX                   
046F:0775 8A05          MOV     AL,[DI]                 
046F:0777 C605CC        MOV     B,[DI],CC               
046F:077A 06            PUSH    ES                      
046F:077B 1F            POP     DS                      
046F:077C 8844FE        MOV     [SI-02],AL              
046F:077F E2E9          LOOP    SETBP		;076A         
		NOBP:
046F:0781 C7066A090100  MOV     W,[TCOUNT],0001           
046F:0787 E9CFFE        JMP     EXIT		;0659

		; the following were not included in the monitor program
		; because they weren't needed
		;078A - define file name for use with load/write
		NAME:
046F:078A 8BF7          MOV     SI,DI                   
046F:078C 8E066C0A      MOV     ES,[CSSAVE]               
046F:0790 56            PUSH    SI                      
046F:0791 BF8100        MOV     DI,BUFLEN+1	;0081                 
		NAME1:
046F:0794 AC            LODB                            
046F:0795 AA            STOB                            
046F:0796 3C0D          CMP     AL,0D                   
046F:0798 75FA          JNZ     NAME1		;0794                    
046F:079A 81EF8200      SUB     DI,0082                 
046F:079E 8BC7          MOV     AX,DI                   
046F:07A0 26            SEG     ES                      
046F:07A1 A28000        MOV     [B_DTA],AL	;0080
046F:07A4 5E            POP     SI                      
046F:07A5 BF5C00        MOV     DI,B_FCB1	;005C                 
046F:07A8 B80129        MOV     AX,2901		;parse filename
046F:07AB CD21          INT     21                      
046F:07AD B001          MOV     AL,01                   
046F:07AF BF6C00        MOV     DI,B_FCB2	;006C                 
046F:07B2 CD21          INT     21     
		RET5:
046F:07B4 C3            RET 

		;07B5 - load file
		LOAD:
046F:07B5 C606670901    MOV     B,[FLG1],01      ;0967
046F:07BA EB6E          JP      DISKOPS		;082A 
		LOAD2:
046F:07BC 8E1E6C0A      MOV     DS,[CSSAVE]               
046F:07C0 823E5D0020    CMP     B,[B_FCB1+1],20	;005D
046F:07C5 74ED          JZ      RET5		;07B4                    
046F:07C7 BA0001        MOV     DX,0100                 
046F:07CA B41A          MOV     AH,SETDTA	;1A                   
046F:07CC CD21          INT     21                      
046F:07CE BA5C00        MOV     DX,B_FCB1	;005C                 
046F:07D1 C7067D000000  MOV     W,[B_RSVD1+1],0000 	;7D
046F:07D7 C6067F0000    MOV     B,[B_RSVD1+3],00	;7F
046F:07DC 2E            SEG     CS                      
046F:07DD F6066709FF    TEST    B,[FLG1],FF             
046F:07E2 741B          JZ      NEWFILE		;07FF                    
046F:07E4 B40F          MOV     AH,OPNFIL	;0F                   
046F:07E6 CD21          INT     21                      
046F:07E8 0AC0          OR      AL,AL                   
046F:07EA 750D          JNZ     LOADFNF		;07F9                    
046F:07EC B9FFFF        MOV     CX,FFFF                 
046F:07EF B427          MOV     AH,RNDRD	;27                   
046F:07F1 CD21          INT     21                      
046F:07F3 2E            SEG     CS                      
046F:07F4 890E5A0A      MOV     [CXSAVE],CX    ;a5a
046F:07F8 C3            RET 
		LOADFNF:
046F:07F9 BA0009        MOV     DX,MSG3		;0900  FNF
		ERR2:
046F:07FC E973F9        JMP     PRTSTR		;0172

		NEWFILE:
046F:07FF B416          MOV     AH,CREATE	;16                   
046F:0801 CD21          INT     21                      
046F:0803 FEC0          INC     AL                      
046F:0805 BA1109        MOV     DX,MSG4		;0911 no room in dir
046F:0808 74F2          JZ      ERR2		;07FC                    
046F:080A 2E            SEG     CS                      
046F:080B 8B0E5A0A      MOV     CX,[CXSAVE]    	;a5a
046F:080F B428          MOV     AH,RNDWR	;28                   
046F:0811 BA5C00        MOV     DX,B_FCB1	;005C                 
046F:0814 CD21          INT     21                      
046F:0816 0AC0          OR      AL,AL                   
046F:0818 BA2D09        MOV     DX,MSG5		;092D no space
046F:081B 75DF          JNZ     ERR2		;07FC                    
046F:081D B410          MOV     AH,CLOSFIL	;10                   
046F:081F BA5C00        MOV     DX,B_FCB1	;005C                 
046F:0822 CD21          INT     21                      
046F:0824 C3            RET 

		WRITE:
046F:0825 C606670900    MOV     B,[FLG1],00	;0967

		DISKOPS:
046F:082A E87EF9        CALL    SCANB                    
046F:082D 748D          JZ      LOAD2		;07BC                    
046F:082F B90500        MOV     CX,0005                 
046F:0832 E877FB        CALL    GETHEX                    
046F:0835 E82DFA        CALL    GETSEG                    
046F:0838 50            PUSH    AX                      
046F:0839 8BDA          MOV     BX,DX                   
046F:083B B90100        MOV     CX,0001                 
046F:083E E86BFB        CALL    GETHEX                    
046F:0841 52            PUSH    DX                      
046F:0842 B90300        MOV     CX,0003                 
046F:0845 E864FB        CALL    GETHEX                    
046F:0848 52            PUSH    DX                      
046F:0849 B90300        MOV     CX,0003                 
046F:084C E85DFB        CALL    GETHEX                    
046F:084F E8D2FB        CALL    GETEOL                    
046F:0852 8BCA          MOV     CX,DX                   
046F:0854 5A            POP     DX                      
046F:0855 58            POP     AX                      
046F:0856 1F            POP     DS                      
046F:0857 2E            SEG     CS                      
046F:0858 F6066709FF    TEST    B,[FLG1],FF             
046F:085D 7404          JZ      BIOSDW		;0863
		; absolute disk read al=drive cx=#sectors dx=start ds:bx=buffer
046F:085F CD25          INT     25                      
046F:0861 EB02          JP      HDERR		;0865
		; absolute disk write al=drive cx=#sectors dx=start ds:bx=buffer
		BIOSDW:
046F:0863 CD26          INT     26          

		HDERR:
046F:0865 BA4A09        MOV     DX,MSG6		;094A  hd disk err
046F:0868 7292          JC      ERR2		;07FC                    
046F:086A 9D            POPF                            
046F:086B C3            RET

		; Data area
		; register names & flags
		;86C
		REGTAB:
			db	"AXBXCXDXSPBPSIDIDSESSSCSIPPC"
		REGDIF:	EQU	AXSAVE-REGTAB
		;0888
		FLAGTAB:
			DW	0,0,0,0
		;0890
			db	"OV"
			db	"DN"
			db	"EI"
			DW	0
		;0898
			db	"NG"
			db	"ZR"
			DW	0
		;089E
			db	"AC"
			DW	0
		;08A2
			db	"PE"
			DW	0
		;08A6
			db	"CY"
			DW	0
		;08AA
			DW	0,0,0
		;08B0
			db	"NV"
			db	"UP"
			db	"DI"
			DW	0
		;08B8
			db 	"PL"
			db	"NZ"
			DW	0
		;08BE
			db	"NA"
			DW	0
		;08C2
			db	"PO"
			DW	0
		;08C6
			db	"NC"
		;08c8
		BANNER:
			db	13,10,"DEBUG-86  version 0.2",13,10,"$"
		;08e2
		MSG1:
			db	"Program terminated normally"
		;08fd
		CRLF2:	db	13,10,"$"

		;0900
		MSG3:
			db	"File not found",13,10,"$"
		;0911
		MSG4:
			db	"No room in disk directory",13,10,"$"
		;092d
		MSG5:
			db	"Insufient space on disk",13,10,"$"
		;094a
		MSG6:
			db	"Hard Disk Error",13,10,"$"
		;095c
		SYNERR:
			db	"^"
		ERRMES:	; note use of MSB for string end
			db	" Error",13,0x8a
		;0965
		BACMES:
			db	20h,88h		;space-backspace

		;RAM area
		;0967
		FLG1:	db	0		; file op flag 1=read
		;0968	
		BRKCNT:	DS	2		;Number of breakpoints
		;96a
		TCOUNT:	DS	2		;Number of steps to trace
		;96c
		BPTAB:	DS	BPLEN		;Breakpoint table 20??
		;0980 LINEBUF
		LINEBUF:DS	BUFLEN+1	;Line input buffer
			ALIGN
			DS	50		;Working stack area
		
		; should be at a56h
		STACK:
		;org 0A56H
		;Register save area
		AXSAVE:	DS	2	;a56
		BXSAVE:	DS	2	;a58
		CXSAVE:	DS	2	;a5a
		DXSAVE:	DS	2	;a5c
		SPSAVE:	DS	2	;a5e
		BPSAVE:	DS	2	;a60
		SISAVE:	DS	2	;a62
		DISAVE:	DS	2	;a64
		DSSAVE:	DS	2	;a66
		ESSAVE:	DS	2	;a68
		RSTACK:		;Stack set here so registers can be saved by pushing
		SSSAVE:	DS	2	;a6a
		CSSAVE:	DS	2	;a6c
		IPSAVE:	DS	2	;a6e
		FSAVE:	DS	2	;a70-71
