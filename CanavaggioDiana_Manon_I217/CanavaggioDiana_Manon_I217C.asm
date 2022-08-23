;************************************************************************
;* Nom de fichier: Examen B2Q1 *
;* Date: 14/01/2022 *
;* *
;* Auteur:  Manon Canavaggio-Diana
;* Haute Ecole Louvain en Hainaut *
;************************************************************************
;* Fichiers nécessaires: aucun *
;************************************************************************
;* Notes: *
;************************************************************************
    list p=16F84, f=INHX8M		; directive pour definir le processeur
    list c=90, n=60			; directives pour le listing
    #include <p16F84a.inc>		; incorporation variables spécifiques
    errorlevel -302			; pas d'avertissements de bank
    errorlevel -305			; pas d'avertissements de fdest

    __config _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC	; configuration du pic, cf. documentation

;************************************************************************
;* Définitions et Variables *
    #DEFINE EXAMPLE b'000000000'	; Define c'est comme déclarer des constantes
					; Quand y'a un # (devant include et define) c'est une directive de 
					; précompilation càd que c'est pas le programme qui fait la commande, c'est 
					; une commande pour le compilateur
;************************************************************************
    cblock 0x020
; déclaration de variables
    d1,
    d2,
    NB_BUTTON_CHECK,
    BUTTON_SELECTOR,
    RIGHT_OPERAND,
    LEFT_OPERAND,
    RESULT,
    endc   
;************************************************************************
;* Programme principal *
;************************************************************************
;    cpu equates (memory map)
    ;myPortB    equ    0x06		; Definit l'addresse du portB quelque soit la bank 
					; dans laquelle je me trouve j'ai le droit d'utiliser PORTB
    ;myPortA    equ    0x05		; Definit l'addresse du portA
    ORG 0x000 ; vecteur reset
    
START  
;************************************************************************ 
; START - PORTS INITIALISATION
;************************************************************************
    BCF STATUS, RP0		; on clear le bit 5 de STATUS, ce qui permet de selectionner bank0
    CLRF PORTB			; initialise portB avec un clear des outputs
    CLRF PORTA			; initialise portA avec un clear des outputs
    BSF STATUS, RP0		; On set le bit 5 de STATUS à 1, donc bank1 est selectionnée    
;************************************************************************ 
; START - I/O SETUP
;************************************************************************
    MOVLW 0x00			; 0x00 = hexa / b'0' = binaire / 0 = decimal on doit préciser le système de numération
    MOVWF TRISB			; on met 0x00 dans TRISB, ce qui met PORTB en output
    MOVLW b'00011111'		; 1=input -> ici RA0 à RA4
    MOVWF TRISA			; on met 1 dans trisA : input
;************************************************************************ 
; START - BANK SELECTION TO USE PORTA / PORTB
;************************************************************************    
    BCF STATUS, RP0		; On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs à la ligne 40
;************************************************************************ 
; MAIN AREA - MAIN LOOP OF THE PROGRAM
; Le bouton RA0 permet d'incrémenter l'opérande de gauche de l'opération et le stocke dans une variable
; Le bouton RA1 permet d'incrémenter l'opérande de droite de l'opération et le stocke dans une seconde variable
; Le bouton RA2 permet de faire " - " entre les deux opérandes et le met dans une variable result pour ensuite afficher le résultat
; Le bouton RA3 permet de faire " + " entre les deux opérandes et le met dans une variable result pour ensuite afficher le résultat
; Le bouton RA4 permet de reset toutes les variables et les affichages
;************************************************************************ 
MAIN
    CALL CHECK_BUTTONS		; on appelle la routine qui check tous les boutons un à un
    CALL START_ACTIONS		; on appelle la routine qui check si une action doit être lancée
    GOTO MAIN			; on boucle
;************************************************************************ 
; MAIN SUBROUTINES AGGREGATION
;************************************************************************ 
CHECK_BUTTONS			; on appelle les routines qui check si les boutons sont enfoncés, un par un, à chaque boucle du main
    CALL CHECK_RA0		; on appelle la routine qui check le bouton mappé sur RA0
    CALL CHECK_RA1		; on appelle la routine qui check le bouton mappé sur RA1
    CALL CHECK_RA2		; on appelle la routine qui check le bouton mappé sur RA2
    CALL CHECK_RA3		; on appelle la routine qui check le bouton mappé sur RA3
    CALL CHECK_RA4		; on appelle la routine qui check le bouton mappé sur RA4
    RETURN
START_ACTIONS			; on appelle les routines qui check si les actions doivent être appellées, une par une
    CALL INCR_LEFT_OPERAND	
    CALL INCR_RIGHT_OPERAND	
    CALL SUB_OPERATION		
    CALL ADD_OPERATION
    CALL RESET_OPERATION	
    RETURN			
;************************************************************************ 
; BUTTONS: TRIGGERS
;************************************************************************   
CHECK_RA0			
    BTFSS PORTA,RA0	    ; On teste RA0, s'il est =1 (donc si le bouton est appuyé), on skip l'instruction suivante		
    RETURN		    ; Si le bouton n'est pas appuyé, on retourne là où la subroutine est call
    BTFSC PORTA,RA0	    ; ANTI-REBOND -> On teste RA0 de PORTA, s'il est =0 (donc si le bouton n'est pas appuyé), on skip l'instruction suivante			
    GOTO $-1		    ; Si RA0=1 on revient une ligne avant (donc tant qu'on reste appuyé sur le bouton)
    CALL ACTION_RA0	    ; Si RA0 = 0, donc une fois le bouton relâché, on appelle la subroutine ACTION_RA0
    GOTO MAIN		    ; On retourne au MAIN
CHECK_RA1
    BTFSS PORTA,RA1	    ; On teste RA1 de PORTA, s'il est =1 (donc si le bouton est appuyé), on skip l'instruction suivante		
    RETURN		    ; On retourne là où la sub est call
    BTFSC PORTA,RA1	    ; ANTI-REBOND -> On teste RA1 de PORTA, s'il est =0 (donc si le bouton n'est pas appuyé), on skip l'instruction suivante			
    GOTO $-1		    ; Si RA1=1 on revient une ligne avant (donc tant qu'on reste appuyé sur le bouton) 
    CALL ACTION_RA1	    ; Si RA1 = 0, donc une fois le bouton relâché, on appelle la subroutine ACTION_RA1
    GOTO MAIN		    ; On retourne au MAIN
CHECK_RA2
    BTFSS PORTA, RA2	    ; On teste RA2, s'il est =1 (donc si le bouton est appuyé), on skip l'instruction suivante
    RETURN		    ; Si le bouton n'est pas appuyé, on retourne là où la subroutine est call
    BTFSC PORTA,RA2	    ; ANTI-REBOND -> On teste RA2 de PORTA, s'il est =0 (donc si le bouton n'est pas appuyé), on skip l'instruction suivante	
    GOTO $-1		    ; Si RA2=1 on revient une ligne avant (donc tant qu'on reste appuyé sur le bouton)
    CALL ACTION_RA2	    ; Si RA2 = 0, donc une fois le bouton relâché, on appelle la subroutine ACTION_RA2
    GOTO MAIN		    ; On retourne au MAIN
CHECK_RA3
    BTFSS PORTA, RA3	    ; On teste RA3, s'il est =1 (donc si le bouton est appuyé), on skip l'instruction suivante
    RETURN		    ; Si le bouton n'est pas appuyé, on retourne là où la subroutine est call
    BTFSC PORTA,RA3	    ; ANTI-REBOND -> On teste RA3 de PORTA, s'il est =0 (donc si le bouton n'est pas appuyé), on skip l'instruction suivante		
    GOTO $-1		    ; Si RA3=1 on revient une ligne avant (donc tant qu'on reste appuyé sur le bouton)
    CALL ACTION_RA3	    ; Si RA3 = 0, donc une fois le bouton relâché, on appelle la subroutine ACTION_RA3
    GOTO MAIN		    ; On retourne au MAIN
CHECK_RA4
    BTFSS PORTA, RA4	    ; On teste RA4, s'il est =1 (donc si le bouton est appuyé), on skip l'instruction suivante
    RETURN		    ; Si le bouton n'est pas appuyé, on retourne là où la subroutine est call
    BTFSC PORTA,RA4	    ; ANTI-REBOND -> On teste RA4 de PORTA, s'il est =0 (donc si le bouton n'est pas appuyé), on skip l'instruction suivante		
    GOTO $-1		    ; Si RA3=1 on revient une ligne avant (donc tant qu'on reste appuyé sur le bouton)
    CALL ACTION_RA4	    ; Si RA4 = 0, donc une fois le bouton relâché, on appelle la subroutine ACTION_RA4
    GOTO MAIN		    ; On retourne au MAIN
;************************************************************************ 
; BUTTONS: ACTIONS
;************************************************************************  
ACTION_RA0 		    ; routine appellée par l'appui du bouton RA0
    MOVLW b'00000001'	    ; on met le 1er bit de W à 1
    MOVWF BUTTON_SELECTOR   ; on met W dans button_selector pour mémoriser la valeur de l'action à exécuter
    RETURN		
ACTION_RA1		    ; routine appellée par l'appui du bouton RA1		
    MOVLW b'00000010'	    ; on met le 2eme bit de W à 1
    MOVWF BUTTON_SELECTOR   ; on met W dans button_selector pour mémoriser la valeur de l'action à exécuter
    RETURN		  
ACTION_RA2		    ; routine appellée par l'appui du bouton RA2
    MOVLW b'00000100'	    ; on met le 3eme bit de W à 1
    MOVWF BUTTON_SELECTOR   ; on met W dans button_selector pour mémoriser la valeur de l'action à exécuter
    RETURN		 
ACTION_RA3		    ; routine appellée par l'appui du bouton RA3
    MOVLW b'00001000'	    ; on met le 4eme bit de W à 1
    MOVWF BUTTON_SELECTOR   ; on met W dans button_selector pour mémoriser la valeur de l'action à exécuter
    RETURN		 
ACTION_RA4		    ; routine appellée par l'appui du bouton RA4
    MOVLW b'00010000'	    ; on met le 5eme bit de W à 1
    MOVWF BUTTON_SELECTOR   ; on met W dans button_selector pour mémoriser la valeur de l'action à exécuter
    RETURN
;************************************************************************ 
; CLEARS
;************************************************************************
CLEAR_BUTTON_SELECTOR	   
    CLRF BUTTON_SELECTOR    ; on clear les bits de la variable BUTTON_SELECTOR
    RETURN
CLEAR_LEFT_OPERAND	   
    CLRF LEFT_OPERAND	    ; on clear les bits de la variable LEFT_OPERAND   
    RETURN
CLEAR_RIGHT_OPERAND		   
    CLRF RIGHT_OPERAND	    ; on clear les bits de la variable RIGHT_OPERAND   
    RETURN
CLEAR_RESULT		   
    CLRF RESULT		    ; on clear les bits de la variable RESULT   
    RETURN
CLEAR_PORTB		   
    CLRF PORTB		    ; on clear les bits de PORTB (donc les leds)
    RETURN
;************************************************************************ 
; ACTIONS TRIGGERS WITH OPERATION SELECTOR
;************************************************************************ 
    ; ces routines sont appellées à chaque tour dans le main
    ; elles contiennent un check sur le button_selector
    ; si on vient d'appuyer sur le bouton qui leur est associé
    ; on call la routine qui lancera le mini programme souhaité
INCR_LEFT_OPERAND
    BTFSC BUTTON_SELECTOR, 0		; on check le bit en position 0 ( 0000 000x ). BTFSC prend en compte ce bit, si c'est un 0 il skip l'instruction suivante (donc va au RETURN), sinon il exécute l'instruction suivante.
    CALL INCR_LEFT_OPERAND_ROUTINE	; on call le mini programme associé
    RETURN
INCR_RIGHT_OPERAND
    BTFSC BUTTON_SELECTOR, 1		; on check le bit en position 1 ( 0000 00x0 ). si c'est un 0 il skip l'instruction suivante (donc va au RETURN), sinon il exécute l'instruction suivante.
    CALL INCR_RIGHT_OPERAND_ROUTINE	; on call le mini programme associé
    RETURN
SUB_OPERATION
    BTFSC BUTTON_SELECTOR, 2		; on check le bit en position 2 ( 0000 0x00 ). si c'est un 0 il skip l'instruction suivante (donc va au RETURN), sinon il exécute l'instruction suivante.
    CALL SUB_OPERATION_ROUTINE		; on call le mini programme associé
    RETURN
ADD_OPERATION
    BTFSC BUTTON_SELECTOR, 3		; on check le bit en position 3 ( 0000 x000 ). si c'est un 0 il skip l'instruction suivante (donc va au RETURN), sinon il exécute l'instruction suivante.
    CALL ADD_OPERATION_ROUTINE		; on call le mini programme associé
    RETURN
RESET_OPERATION
    BTFSC BUTTON_SELECTOR, 4		; on check le bit en position 4 ( 000x 0000 ). si c'est un 0 il skip l'instruction suivante (donc va au RETURN), sinon il exécute l'instruction suivante.
    CALL RESET_ROUTINE			; on call le mini programme associé
    RETURN
;************************************************************************ 
; PORTB STATE REGISTER MODIFICATIONS AND OPERATIONS
;************************************************************************ 
INCR_LEFT_OPERAND_ROUTINE	    ; c'est la routine qui permet d'incrémenter la variable LEFT_OPERAND
    CALL CLEAR_BUTTON_SELECTOR	    ; on commence par call CLEAR_BUTTON_SELECTOR pour repasser en mode d'attente du programme
    INCF LEFT_OPERAND		    ; on incrémente LEFT_OPERAND
    CALL SHOW_LEFT_OPERAND	    ; on appelle la subroutine qui permet d'afficher la valeur en bits de l'opérande sur les leds
    RETURN
INCR_RIGHT_OPERAND_ROUTINE	    ; c'est la routine qui permet d'incrémenter la variable RIGHT_OPERAND
    CALL CLEAR_BUTTON_SELECTOR	    ; on commence par call CLEAR_BUTTON_SELECTOR pour repasser en mode d'attente du programme
    INCF RIGHT_OPERAND		    ; on incrémente RIGHT_OPERAND
    CALL SHOW_RIGHT_OPERAND	    ; on appelle la subroutine qui permet d'afficher la valeur en bits de l'opérande sur les leds
    RETURN
SUB_OPERATION_ROUTINE
    CALL CLEAR_BUTTON_SELECTOR	; on clear le button selector pour éviter de repasser dans la routine
    MOVFW RIGHT_OPERAND		; on met RIGHT_OPERAND dans W
    SUBWF LEFT_OPERAND, W	; W = LEFT_OPERAND - RIGHT_OPERAND
    BTFSS STATUS, Z		; (Z = zero)RIGHT_OPERAND = LEFT_OPERAND. Si zero est set, on skip la ligne suivante
    BTFSS STATUS, C		; (C = carry)RIGHT_OPERAND < LEFT_OPERAND. Si carry est set, on skip la ligne suivante
    CALL IS_NEGATIVE
    MOVWF RESULT		; On ajoute W à RESULT
    CALL SHOW_RESULT		; on appelle la subroutine qui permet d'afficher la valeur en bits du résultat sur les leds
    RETURN
    ; zero = set(1 btfsS pour set) et carry = set quand LEFT et RIGHT sont EGAUX
    ; zero = clear (0 btfsC pour clear) et carry = set quand LEFT est plus GRAND que RIGHT -> ici c'est le cas qu'on recherche, pour ne pas descendre dans les négatifs
    ; zero = clear et carry = clear -> quand LEFT est plus PETIT que RIGHT
ADD_OPERATION_ROUTINE		; c'est la routine qui permet de faire une addition
    CALL CLEAR_BUTTON_SELECTOR	; on commence par call CLEAR_BUTTON_SELECTOR pour repasser en mode d'attente du programme
    MOVFW LEFT_OPERAND		; on met LEFT_OPERAND dans le W
    ADDWF RIGHT_OPERAND, W	; W = RIGHT_OPERAND + LEFT_OPERAND
    MOVWF RESULT		; on met la valeur de W dans la variable RESULT
    CALL SHOW_RESULT		; on appelle la subroutine qui permet d'afficher la valeur en bits de l'opérande sur les leds
    RETURN
RESET_ROUTINE			; c'est la subroutine qui permet de remettre à 0 des variables de la calculatrice
    CALL CLEAR_BUTTON_SELECTOR	; on call la subroutine qui clear la variable BUTTON_SELECTOR
    CALL CLEAR_PORTB		; on call la subroutine qui clear le PORTB (donc éteint les leds)
    CALL CLEAR_LEFT_OPERAND	; on call la subroutine qui clear la variable LEFT_OPERAND
    CALL CLEAR_RIGHT_OPERAND	; on call la subroutine qui clear la variable RIGHT_OPERAND
    CALL CLEAR_RESULT		; on call la subroutine qui clear la variable RESULT
    RETURN
IS_NEGATIVE
    CALL LEDS_BLINKING
    CLRW			; Puisque left_operand > que right_operand, on clear W
    RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEDS_BLINKING
    MOVLW b'11111111'	
    MOVWF PORTB
    CALL DELAY_WITH_CHECK_BUTTON
    MOVLW b'00000000'	
    MOVWF PORTB	
    CALL DELAY_WITH_CHECK_BUTTON
    GOTO LEDS_BLINKING
;************************************************************************ 
; SHOW
;************************************************************************
SHOW_LEFT_OPERAND	    ; subroutine permettant d'afficher les valeurs des variables avec les leds
    CALL CLEAR_PORTB	    ; on clear d'abord les leds pour éviter les résidus
    MOVFW LEFT_OPERAND	    ; on met la variable LEFT_OPERAND dans le W
    MOVWF PORTB		    ; on met ce qu'il y a dans le W dans le F, donc dans PORTB, qui affiche les bits contenus dans le F via les leds
    RETURN
SHOW_RIGHT_OPERAND
    CALL CLEAR_PORTB	    ; on clear d'abord les leds pour éviter les résidus
    MOVFW RIGHT_OPERAND	    ; on met la variable RIGHT_OPERAND dans le W
    MOVWF PORTB		    ; on met ce qu'il y a dans le W dans le F, donc dans PORTB, qui affiche les bits contenus dans le F via les leds
    RETURN
SHOW_RESULT
    CALL CLEAR_PORTB	    ; on clear d'abord les leds pour éviter les résidus
    MOVFW RESULT	    ; on met la variable RESULT dans le W
    MOVWF PORTB		    ; on met ce qu'il y a dans le W dans le F, donc dans PORTB, qui affiche les bits contenus dans le F via les leds
    RETURN

;************************************************************************ 
; DELAYS
;************************************************************************ 
DELAY_WITH_CHECK_BUTTON
    MOVLW 0x20
    MOVWF NB_BUTTON_CHECK
DELAY_WITH_CHECK_BUTTON_0		    
    DECFSZ NB_BUTTON_CHECK,f
    GOTO DELAY_WITH_CHECK_BUTTON_CHECK
    RETURN
DELAY_WITH_CHECK_BUTTON_CHECK
    CALL DELAY
    CALL CHECK_BUTTONS
    GOTO DELAY_WITH_CHECK_BUTTON_0
DELAY
    MOVLW	0xE7
    MOVWF	d1
    MOVLW	0x04
    MOVWF	d2
DELAY_0
    DECFSZ	d1, f
    GOTO	$+2
    DECFSZ	d2, f
    GOTO	DELAY_0
    GOTO	$+1
    RETURN
END