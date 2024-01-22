			TITLE command.asm
			;
			;* This was extracted from a disk image provided by
			;* Gene Buckle on 12/29/23. The disk label is:
			;* 86-DOS_v0.34_#221_-_81-02-20.imd

			ORG 0
		CODSTRT EQU $
		START:
046F:0100 EB13          JP      START2		;0115                    

		HEADER: 
			DB      13,10,'Command v. 0.2',13,10,'$'

		START2:
046F:0115 BCDC04        MOV     SP,04DC                 
046F:0118 BA0201        MOV     DX,HEADER	;0102                 
046F:011B B409          MOV     AH,09                   
046F:011D CD21          INT     21

046F:011F B200          MOV     DL,00                   
046F:0121 B40E          MOV     AH,0E                   
046F:0123 CD21          INT     21                      

		INTXX:
046F:0125 BCDC04        MOV     SP,04DC                 
046F:0128 FC            UP                              
046F:0129 8CC8          MOV     AX,CS                   
046F:012B 8ED0          MOV     SS,AX                   
046F:012D 8EC0          MOV     ES,AX                   
046F:012F 8ED8          MOV     DS,AX                   
046F:0131 8B0E0600      MOV     CX,[0006]               
046F:0135 81E9C606      SUB     CX,06C6                 
046F:0139 80E180        AND     CL,80                   
046F:013C D1C1          ROL     CX                      
046F:013E 86E9          XCHG    CH,CL                   
046F:0140 890EB205      MOV     [05B2],CX               
046F:0144 BAF404        MOV     DX,04F4                 
046F:0147 B409          MOV     AH,09                   
046F:0149 CD21          INT     21                      

046F:014B BA2501        MOV     DX,0125                 
046F:014E B82225        MOV     AX,2522 	; INT22 termination
046F:0151 CD21          INT     21                      

046F:0153 B82325        MOV     AX,2523 	; INT23 Cntl-C
046F:0156 CD21          INT     21                      

046F:0158 B419          MOV     AH,19		; get default drive
046F:015A CD21          INT     21                      

046F:015C 0441          ADD     AL,41		; make drive# ASCII
046F:015E B402          MOV     AH,02                   
046F:0160 8AD0          MOV     DL,AL           ; write to STDOUT
046F:0162 CD21          INT     21                      

046F:0164 B23A          MOV     DL,3A                   
046F:0166 B402          MOV     AH,02		; write ":" to stdout
046F:0168 CD21          INT     21                      

046F:016A BAF105        MOV     DX,05F1        ; input buffer         
046F:016D B40A          MOV     AH,0A                   
046F:016F CD21          INT     21                      

046F:0171 B20A          MOV     DL,0A                   
046F:0173 B402          MOV     AH,02 		; write CR to stdout
046F:0175 CD21          INT     21                      

046F:0177 BEF305        MOV     SI,05F3		; parse filename to FCB     
046F:017A BFB605        MOV     DI,05B6         ;ds:si=filename es:di=FCB
046F:017D B80129        MOV     AX,2901		; skip leading seps
046F:0180 CD21          INT     21                      

046F:0182 8A05          MOV     AL,[DI]                 
046F:0184 A2B105        MOV     [05B1],AL               
046F:0187 B020          MOV     AL,20                   
046F:0189 B90900        MOV     CX,0009                 
046F:018C 47            INC     DI                      
046F:018D F2            REPNZ                           
046F:018E AE            SCAB                            
046F:018F B009          MOV     AL,09                   
046F:0191 2AC1          SUB     AL,CL                   
046F:0193 A2B605        MOV     [05B6],AL               
046F:0196 BF8100        MOV     DI,0081                 
046F:0199 B90000        MOV     CX,0000                 
046F:019C 56            PUSH    SI                      
046F:019D AC            LODB                            
046F:019E AA            STOB                            
046F:019F 3C0D          CMP     AL,0D                   
046F:01A1 E0FA          LOOPNZ  019D                    
046F:01A3 F6D1          NOT     CL                      
046F:01A5 880E8000      MOV     [0080],CL               
046F:01A9 5E            POP     SI                      
046F:01AA BF5C00        MOV     DI,005C                 
046F:01AD B001          MOV     AL,01                   
046F:01AF CD21          INT     21                      

046F:01B1 BF6C00        MOV     DI,006C                 
046F:01B4 B001          MOV     AL,01                   
046F:01B6 CD21          INT     21                      

046F:01B8 A0B605        MOV     AL,[05B6]               
046F:01BB 8A16B105      MOV     DL,[05B1]               
046F:01BF 0AD2          OR      DL,DL                   
046F:01C1 7521          JNZ     01E4                    
046F:01C3 FEC8          DEC     AL                      
046F:01C5 7491          JZ      0158                    
046F:01C7 BE9806        MOV     SI,0698                 
046F:01CA B500          MOV     CH,00                   
046F:01CC BFB605        MOV     DI,05B6                 
046F:01CF 8A0C          MOV     CL,[SI]                 
046F:01D1 E317          JCXZ    01EA                    
046F:01D3 F3            REPZ                            
046F:01D4 A6            CMPB                            
046F:01D5 9F            LAHF                            
046F:01D6 03F1          ADD     SI,CX                   
046F:01D8 9E            SAHF                            
046F:01D9 AD            LODW                            
046F:01DA 75F0          JNZ     01CC                    
046F:01DC FFD0          CALL    AX                      
046F:01DE E944FF        JMP     0125                    
046F:01E1 E93DFF        JMP     0121                    
046F:01E4 FECA          DEC     DL                      
046F:01E6 FEC8          DEC     AL                      
046F:01E8 74F7          JZ      01E1                    
046F:01EA A0B105        MOV     AL,[05B1]               
046F:01ED A2B605        MOV     [05B6],AL               
046F:01F0 C706BF05434F  MOV     W,[05BF],4F43           
046F:01F6 C606C1054D    MOV     B,[05C1],4D             
046F:01FB 1E            PUSH    DS                      
046F:01FC BAC606        MOV     DX,06C6                 
046F:01FF 83C20F        ADD     DX,+0F                  
046F:0202 D1EA          SHR     DX                      
046F:0204 D1EA          SHR     DX                      
046F:0206 D1EA          SHR     DX                      
046F:0208 D1EA          SHR     DX                      
046F:020A 8CC9          MOV     CX,CS                   
046F:020C 03D1          ADD     DX,CX                   
046F:020E 8EDA          MOV     DS,DX                   
046F:0210 B426          MOV     AH,26                   
046F:0212 CD21          INT     21                      
046F:0214 BA0001        MOV     DX,0100                 
046F:0217 B41A          MOV     AH,1A                   
046F:0219 CD21          INT     21                      

046F:021B 8CDB          MOV     BX,DS                   
046F:021D 1F            POP     DS                      
046F:021E BAB605        MOV     DX,05B6                 
046F:0221 B40F          MOV     AH,0F                   
046F:0223 CD21          INT     21                      

046F:0225 0AC0          OR      AL,AL                   
046F:0227 7534          JNZ     025D                    
046F:0229 C706D7050000  MOV     W,[05D7],0000           
046F:022F C606D90500    MOV     B,[05D9],00             
046F:0234 8B0EB205      MOV     CX,[05B2]               
046F:0238 B427          MOV     AH,27                   
046F:023A CD21          INT     21                      

046F:023C FEC8          DEC     AL                      
046F:023E BA5105        MOV     DX,0551                 
046F:0241 751D          JNZ     0260                    
046F:0243 8EDB          MOV     DS,BX                   
046F:0245 8EC3          MOV     ES,BX                   
046F:0247 8ED3          MOV     SS,BX                   
046F:0249 BC4000        MOV     SP,0040                 
046F:024C B80000        MOV     AX,0000                 
046F:024F 50            PUSH    AX                      
046F:0250 B80001        MOV     AX,0100                 
046F:0253 53            PUSH    BX                      
046F:0254 50            PUSH    AX                      
046F:0255 B41A          MOV     AH,1A                   
046F:0257 BA8000        MOV     DX,0080                 
046F:025A CD21          INT     21                      
046F:025C CB            RET     L                       

		BADCMD:
046F:025D BADC04        MOV     DX,04DC 	; bad command
		STROUT:
046F:0260 B409          MOV     AH,09 		; string to STDOUT
046F:0262 CD21          INT     21                      
046F:0264 E9BEFE        JMP     0125      

		DIR:
046F:0267 823E5D0020    CMP     B,[005D],20          ;5c is FCB1  
046F:026C 750B          JNZ     0279                    
046F:026E BEA605        MOV     SI,05A6		; file name buffer[11]
046F:0271 BF5D00        MOV     DI,005D                 
046F:0274 B90B00        MOV     CX,000B                 
046F:0277 F3            REPZ                            
046F:0278 A4            MOVB                            
046F:0279 BA7406        MOV     DX,0674                 
046F:027C B41A          MOV     AH,1A 		; set DTA     
046F:027E CD21          INT     21                      

046F:0280 B411          MOV     AH,11                   
046F:0282 BA5C00        MOV     DX,005C 	; find first matching file
046F:0285 CD21          INT     21                      

046F:0287 FEC0          INC     AL                      
046F:0289 7436          JZ      02C1                    
046F:028B BE7506        MOV     SI,0675         ; print the filename
046F:028E B90800        MOV     CX,0008                 
046F:0291 E82400        CALL    02B8                    
046F:0294 B402          MOV     AH,02		; print 2 spaces
046F:0296 B220          MOV     DL,20                   
046F:0298 CD21          INT     21                      
046F:029A CD21          INT     21                      

046F:029C B90300        MOV     CX,0003  	; print the extension
046F:029F E81600        CALL    02B8                    
046F:02A2 8B369106      MOV     SI,[0691]               
046F:02A6 8B3E9306      MOV     DI,[0693]               
046F:02AA E81500        CALL    02C2                    
046F:02AD BAF404        MOV     DX,04F4           ; print CRLF      
046F:02B0 B409          MOV     AH,09                   
046F:02B2 CD21          INT     21                      

046F:02B4 B412          MOV     AH,12                   
046F:02B6 EBCA          JP      0282          	; next file 

046F:02B8 B402          MOV     AH,02                   
046F:02BA AC            LODB                            
046F:02BB 8AD0          MOV     DL,AL                   
046F:02BD CD21          INT     21                      
046F:02BF E2F9          LOOP    02BA                    
046F:02C1 C3            RET                             

		; print filesize dw->ascii
		PSIZE:
046F:02C2 33C0          XOR     AX,AX                   
046F:02C4 8BD8          MOV     BX,AX                   
046F:02C6 8BE8          MOV     BP,AX                   
046F:02C8 B92000        MOV     CX,0020                 
046F:02CB D1E6          SHL     SI                      
046F:02CD D1D7          RCL     DI                      
046F:02CF 95            XCHG    BP,AX                   
046F:02D0 E84200        CALL    0315                    
046F:02D3 95            XCHG    BP,AX                   
046F:02D4 93            XCHG    BX,AX                   
046F:02D5 E83D00        CALL    0315                    
046F:02D8 93            XCHG    BX,AX                   
046F:02D9 1400          ADC     AL,00                   
046F:02DB E2EE          LOOP    02CB                    
046F:02DD B9101B        MOV     CX,1B10                 
046F:02E0 E80700        CALL    02EA                    
046F:02E3 8BC3          MOV     AX,BX                   
046F:02E5 E80200        CALL    02EA                    
046F:02E8 8BC5          MOV     AX,BP                   
046F:02EA 50            PUSH    AX                      
046F:02EB 8AD4          MOV     DL,AH                   
046F:02ED E80100        CALL    02F1                    
046F:02F0 5A            POP     DX                      
046F:02F1 8AF2          MOV     DH,DL                   
046F:02F3 D0EA          SHR     DL                      
046F:02F5 D0EA          SHR     DL                      
046F:02F7 D0EA          SHR     DL                      
046F:02F9 D0EA          SHR     DL                      
046F:02FB E80200        CALL    0300                    
046F:02FE 8AD6          MOV     DL,DH                   
046F:0300 80E20F        AND     DL,0F                   
046F:0303 7402          JZ      0307                    
046F:0305 B100          MOV     CL,00                   
046F:0307 FECD          DEC     CH                      
046F:0309 22CD          AND     CL,CH                   
046F:030B 80CA30        OR      DL,30                   
046F:030E 2AD1          SUB     DL,CL                   
046F:0310 B402          MOV     AH,02                   
046F:0312 CD21          INT     21                      
046F:0314 C3            RET                             
046F:0315 12C0          ADC     AL,AL                   
046F:0317 27            DAA                             
046F:0318 86C4          XCHG    AL,AH                   
046F:031A 12C0          ADC     AL,AL                   
046F:031C 27            DAA                             
046F:031D 86C4          XCHG    AL,AH                   
046F:031F C3            RET              

		RENAME:
046F:0320 B417          MOV     AH,17                   
046F:0322 BA5C00        MOV     DX,005C		;rename file using FCB
046F:0325 CD21          INT     21                      
046F:0327 C3            RET                   

		ERASE:
046F:0328 B413          MOV     AH,13                   
046F:032A BA5C00        MOV     DX,005C		;delete file using FCB
046F:032D CD21          INT     21                      
046F:032F C3            RET            
		
046F:0330 E92DFF        JMP     STROUT		;0260                    

		TTYPE:
046F:0333 BAC606        MOV     DX,06C6                 
046F:0336 B41A          MOV     AH,1A                   
046F:0338 CD21          INT     21                      
046F:033A BA5C00        MOV     DX,005C                 
046F:033D B40F          MOV     AH,0F                   
046F:033F CD21          INT     21                      
046F:0341 0AC0          OR      AL,AL                   
046F:0343 BA1A05        MOV     DX,051A                 
046F:0346 75E8          JNZ     0330                    
046F:0348 C7067D000000  MOV     W,[007D],0000           
046F:034E C6067F0000    MOV     B,[007F],00             
046F:0353 BA5C00        MOV     DX,005C                 
046F:0356 8B0EB205      MOV     CX,[05B2]               
046F:035A B427          MOV     AH,27                   
046F:035C CD21          INT     21                      
046F:035E E3CF          JCXZ    032F                    
046F:0360 8BC1          MOV     AX,CX                   
046F:0362 B107          MOV     CL,07                   
046F:0364 D3E0          SHL     AX,CL                   
046F:0366 8BC8          MOV     CX,AX                   
046F:0368 BEC606        MOV     SI,06C6                 
046F:036B AC            LODB                            
046F:036C 3C1A          CMP     AL,1A                   
046F:036E 74BF          JZ      032F                    
046F:0370 B402          MOV     AH,02                   
046F:0372 8AD0          MOV     DL,AL                   
046F:0374 CD21          INT     21                      
046F:0376 E2F3          LOOP    036B                    
046F:0378 EBD9          JP      0353

		CLEAR:
046F:037A B40E          MOV     AH,0E                   
046F:037C B2FF          MOV     DL,FF                   
046F:037E CD21          INT     21                      
046F:0380 8AE0          MOV     AH,AL                   
046F:0382 A05C00        MOV     AL,[005C]               
046F:0385 0AC0          OR      AL,AL                   
046F:0387 BA8005        MOV     DX,0580                 
046F:038A 74A4          JZ      0330                    
046F:038C 3AC4          CMP     AL,AH                   
046F:038E BA7205        MOV     DX,0572                 
046F:0391 779D          JA      0330                    
046F:0393 0440          ADD     AL,40                   
046F:0395 A21005        MOV     [0510],AL               
046F:0398 BAF704        MOV     DX,04F7                 
046F:039B B409          MOV     AH,09                   
046F:039D CD21          INT     21                      
046F:039F B401          MOV     AH,01                   
046F:03A1 CD21          INT     21                      
046F:03A3 3C59          CMP     AL,59                   
046F:03A5 7405          JZ      03AC                    
046F:03A7 3C79          CMP     AL,79                   
046F:03A9 7401          JZ      03AC                    
046F:03AB C3            RET                             
046F:03AC B419          MOV     AH,19                   
046F:03AE CD21          INT     21                      
046F:03B0 A2B105        MOV     [05B1],AL               
046F:03B3 8A165C00      MOV     DL,[005C]               
046F:03B7 FECA          DEC     DL                      
046F:03B9 B40E          MOV     AH,0E                   
046F:03BB CD21          INT     21                      
046F:03BD B41B          MOV     AH,1B                   
046F:03BF CD21          INT     21                      
046F:03C1 8BCA          MOV     CX,DX                   
046F:03C3 42            INC     DX                      
046F:03C4 D1EA          SHR     DX                      
046F:03C6 03CA          ADD     CX,DX                   
046F:03C8 8CD8          MOV     AX,DS                   
046F:03CA 8EC0          MOV     ES,AX                   
046F:03CC 8BFB          MOV     DI,BX                   
046F:03CE B8FFFF        MOV     AX,FFFF                 
046F:03D1 AB            STOW                            
046F:03D2 AA            STOB                            
046F:03D3 40            INC     AX                      
046F:03D4 D1E9          SHR     CX                      
046F:03D6 7301          JNC     03D9                    
046F:03D8 AA            STOB                            
046F:03D9 F3            REPZ                            
046F:03DA AB            STOW                            
046F:03DB 8CC8          MOV     AX,CS                   
046F:03DD 8ED8          MOV     DS,AX                   
046F:03DF 8EC0          MOV     ES,AX                   
046F:03E1 BAA505        MOV     DX,05A5                 
046F:03E4 B413          MOV     AH,13                   
046F:03E6 CD21          INT     21                      
046F:03E8 8A16B105      MOV     DL,[05B1]               
046F:03EC E932FD        JMP     0121  

		COPY:
046F:03EF BE6C00        MOV     SI,006C                 
046F:03F2 BFC205        MOV     DI,05C2                 
046F:03F5 A4            MOVB                            
046F:03F6 BFE605        MOV     DI,05E6                 
046F:03F9 823C20        CMP     B,[SI],20               
046F:03FC 7503          JNZ     0401                    
046F:03FE BE5D00        MOV     SI,005D                 
046F:0401 A4            MOVB                            
046F:0402 B90500        MOV     CX,0005                 
046F:0405 F3            REPZ                            
046F:0406 A5            MOVW                            
046F:0407 C706B4050000  MOV     W,[05B4],0000           
046F:040D BA7406        MOV     DX,0674                 
046F:0410 B41A          MOV     AH,1A                   
046F:0412 CD21          INT     21                         
046F:0414 B411          MOV     AH,11                   
046F:0416 BA5C00        MOV     DX,005C                 
046F:0419 CD21          INT     21                      
046F:041B 0AC0          OR      AL,AL                   
046F:041D 7411          JZ      0430                    
046F:041F 8B36B405      MOV     SI,[05B4]               
046F:0423 33FF          XOR     DI,DI                   
046F:0425 E89AFE        CALL    02C2                    
046F:0428 BA4105        MOV     DX,0541                 
046F:042B B409          MOV     AH,09                   
046F:042D CD21          INT     21                      
046F:042F C3            RET                             
046F:0430 BB7506        MOV     BX,0675                 
046F:0433 BFC305        MOV     DI,05C3                 
046F:0436 BEE605        MOV     SI,05E6                 
046F:0439 B90B00        MOV     CX,000B                 
046F:043C AC            LODB                            
046F:043D 3C3F          CMP     AL,3F                   
046F:043F 7502          JNZ     0443                    
046F:0441 8A07          MOV     AL,[BX]                 
046F:0443 AA            STOB                            
046F:0444 43            INC     BX                      
046F:0445 E2F5          LOOP    043C                    
046F:0447 BA7406        MOV     DX,0674                 
046F:044A B40F          MOV     AH,0F                   
046F:044C CD21          INT     21                      
046F:044E BAC205        MOV     DX,05C2                 
046F:0451 B413          MOV     AH,13                   
046F:0453 CD21          INT     21                      
046F:0455 B416          MOV     AH,16                   
046F:0457 CD21          INT     21                      
046F:0459 BAC606        MOV     DX,06C6                 
046F:045C B41A          MOV     AH,1A                   
046F:045E CD21          INT     21                      
046F:0460 C70695060000  MOV     W,[0695],0000           
046F:0466 C606970600    MOV     B,[0697],00             
046F:046B C706E3050000  MOV     W,[05E3],0000           
046F:0471 C606E50500    MOV     B,[05E5],00             
046F:0476 BA7406        MOV     DX,0674                 
046F:0479 8B0EB205      MOV     CX,[05B2]               
046F:047D B427          MOV     AH,27                   
046F:047F CD21          INT     21                      
046F:0481 E31A          JCXZ    049D                    
046F:0483 BAC205        MOV     DX,05C2                 
046F:0486 B428          MOV     AH,28                   
046F:0488 CD21          INT     21                      
046F:048A 0AC0          OR      AL,AL                   
046F:048C 74E8          JZ      0476                    
046F:048E BA2905        MOV     DX,0529                 
046F:0491 B409          MOV     AH,09                   
046F:0493 CD21          INT     21                      
046F:0495 BAC205        MOV     DX,05C2                 
046F:0498 B410          MOV     AH,10                   
046F:049A CD21          INT     21                      
046F:049C C3            RET                             
046F:049D BAC205        MOV     DX,05C2                 
046F:04A0 B410          MOV     AH,10                   
046F:04A2 CD21          INT     21                      
046F:04A4 FF06B405      INC     W,[05B4]                
046F:04A8 B41A          MOV     AH,1A                   
046F:04AA BA7406        MOV     DX,0674                 
046F:04AD CD21          INT     21                      
046F:04AF B412          MOV     AH,12                   
046F:04B1 E962FF        JMP     0416

		;04b4

		; 04dc stack top
		STACK:
		;04dc
		MSG01	db 'Bad command or filename'
		;04F4
		CRLF	db 13,10,'$'
		;04f7
		MSG02	db 'Erase all file on drive A (Y/N)? $'
		;0520
		MSG03	db 'File not found $'
		;0529
		MSG04	db 'Insufficient disk space $'
		;0541
		MSG05	db ' File(s) copied $'
		;0551
		MSG06	db 'Program too big to fit in memory$'
		;0572
		MSG07	db 'No such drive$'
		;0580
		MSG08	db 'Drive must be specified (e.g., "B:")$'
		;05a5
			db 0
		;05a6
		FNAME1:	ds 11

		;05B1
			ds 5
		;05B6
		FCB1:	ds 59

		;05F1 - input buffer
		BUFFR:	db 80,01,0D	; max_chars,last_char#,last_char
		;05F3
		FNP:	ds 125

		;0672
			ds 2

		;0674 - default disk transfer buffer
		DDTA:	ds 28

		;0691
			ds 2
		;0693
			ds 6

		;0698 - internal command table
		CTABLE:
			db 4,'DIR', 0267
			db 7,'RENAME', 0320
			db 6,'ERASE', 0328
			db 5,"TYPE", 0333
			db 6,'CLEAR', 037A
			db 5,'COPY', 03EF
			db 0

		MEMSTRT:
		END
