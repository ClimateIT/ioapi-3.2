
      INTEGER FUNCTION GETNUM ( LO , HI , DEFAULT , PROMPT )

C********************************************************************
C Version "$Id: getnum.f 190 2020-10-20 14:41:34Z coats $"
C EDSS/Models-3 I/O API.
C Copyright (C) 1992-2002 MCNC and Carlie J. Coats, Jr.,
C (c) 2004-2007 Baron Advanced Meteorological Systems,
C (c) 2007-2013 Carlie J. Coats, Jr., and (C) 2014 UNC Institute
C for the Environment.
C Distributed under the GNU LESSER GENERAL PUBLIC LICENSE version 2.1
C See file "LGPL.txt" for conditions of use.
C.........................................................................
C       function GETNUM()   body starts at line  94
C       entry    GETNUM1()       starts at line 190
C       function GETINT8()       starts at line 232
C       entry    GETINT81()      starts at line 364
C
C       CALLS:      ENVYN, M3EXIT
C
C  FUNCTION:
C
C       Display the  PROMPT  for an integer between  LO  and  HI,
C       get the user's response and check that it is within range.
C       Return DEFAULT if the user hits <RET>.  Re-prompts on error
C       for up to 5 attempts.
C
C  REVISION HISTORY:
C
C       Created 3/1989 by CJC.
C       Revised 5/1990 by CJC:  error abort is via EXWST.
C       Revised 8/1990 by CJC:  TEMP.LET; treat CONTROL-Z as exit signal.
C       Revised 2/1993 by CJC:  CRAY version using DECODE.
C       Revised 8/1996 by CJC:  treats "!" as a delimiter
C       Revised 1/1997 by CJC:  logs result
C       Revised 5/2003 by CJC:  factor through M3MSG2 to ensure flush()
C       of log-messages
C       Revised 6/2003 by CJC:  factor through M3PROMPT to ensure flush()
C       of PROMPT for IRIX F90v7.4  
C       Modified 03/2010 by CJC: F9x changes for I/O API v3.1
C       Modified 02/2014 by CJC: ENTRY GETNUM1() does not have bounds LO, HI;
C       Fix MH violation of coding-standards:  check status IOS from  ENVYN()!!
C       Version 10/2020 by CJC:  GETINT8, GETINT81
C       Version 10/2020 by CJC:  Fix ADJUSTL calls
C
C  ARGUMENT LIST DESCRIPTION:
C
C    Input arguments:
C
C        LO       Minimum allowed return value
C        HI       Maximum allowed return value
C        DEFAULT  Default return value
C        PROMPT   Prompt for user
C
C    Output arguments:  none
C
C  RETURNS   user response after checking its range; or default.
C
C********************************************************************

        IMPLICIT NONE

C.......   ARGUMENTS:

        INTEGER      , INTENT(IN   ) :: LO , HI , DEFAULT
        CHARACTER*(*), INTENT(IN   ) :: PROMPT

        INTEGER     GETNUM1

C.......   EXTERNAL FUNCTIONS:

        LOGICAL, EXTERNAL :: ENVYN
        INTEGER, EXTERNAL :: LBLANK          ! # of leading blanks


C.......   LOCAL VARIABLES:

        INTEGER         MODE                !!  mode=1 for getnum(), mode=0 for getnum1()
        INTEGER         J
        INTEGER         LLO , LHI , LDF
        INTEGER         ANSWER
        INTEGER         ERRCNT
        INTEGER         IOS
        CHARACTER*32    BUFFER , DEFSTR
        CHARACTER*256   MESG

        LOGICAL, SAVE :: PROMPTON
        LOGICAL, SAVE :: FIRSTIME = .TRUE.

        CHARACTER*16, PARAMETER :: PNAME = 'GETNUM'

C......................................................................
C       begin GETNUM

        MODE = 1

        LLO  =  MIN ( LO , HI )
        LHI  =  MAX ( LO , HI )
        LDF  =  MIN ( LHI , MAX ( LLO , DEFAULT ) )

11      CONTINUE        !!  target of entry getdble1()

        IF( FIRSTIME ) THEN

            PROMPTON = ENVYN( 'PROMPTFLAG', 'Prompt for input flag',
     &                      .TRUE., IOS )
            IF ( IOS .GT. 0 ) THEN
                CALL M3EXIT( PNAME,0,0,'Bad env vble "PROMPTFLAG"', 2 )
            END IF
            FIRSTIME = .FALSE.
 
        END IF

         WRITE ( DEFSTR , '( I31 )' ) LDF
         DEFSTR = ADJUSTL( DEFSTR )

        IF( .NOT. PROMPTON ) THEN
            MESG   = 'Using default ' // DEFSTR
            CALL M3MSG2( MESG )
            IF ( MODE .EQ. 0 ) THEN
                ANSWER = DEFAULT
                GO TO 999
            END IF
            GETNUM = DEFAULT
            RETURN
        END IF

        ERRCNT =  0

        WRITE ( DEFSTR , '( I15 )' ) LDF
        DEFSTR = ADJUSTL( DEFSTR )

100     CONTINUE
        MESG = TRIM( PROMPT ) // ' [' // TRIM( DEFSTR ) // '] >> '
        CALL M3PROMPT( MESG, BUFFER, IOS )

        IF ( IOS .NE. 0 ) THEN
            GO TO  900
        ELSE IF ( BUFFER  .EQ. ' ' )  THEN
            ANSWER  =  LDF
            MESG    = 'Using default ' // DEFSTR
        ELSE

            READ( BUFFER, *, IOSTAT=IOS, ERR=400 )  ANSWER

            IF ( ANSWER .LT. LLO  .OR.  ANSWER .GT. LHI )  THEN
                ERRCNT  =  ERRCNT + 1
                WRITE ( 6,92100 ) ANSWER , LLO , LHI , ERRCNT
                IF ( ERRCNT .LT. 5 )  GO TO  100

                GO TO  900      !  max error count exceeded

            END IF

            WRITE ( DEFSTR , '( I31 )' ) ANSWER
            DEFSTR = ADJUSTL( DEFSTR )
            MESG = 'Using response ' // DEFSTR

        END IF

        CALL M3MSG2( MESG )

        IF ( MODE .EQ. 0 )  GO TO 999
        
        GETNUM = ANSWER

        RETURN


400     CONTINUE        !  error in read from BUFFER

        ERRCNT  =  ERRCNT + 1
        WRITE ( 6,92200 )  ERRCNT
        CALL M3FLUSH( 6 )
        IF ( ERRCNT .LT. 5 )  GO TO  100

900     CONTINUE        !  error in read from terminal, or more than 5 errors

        ERRCNT  =  ERRCNT + 1
        IF ( ERRCNT .LT. 5 ) THEN
            WRITE ( 6,92000 ) IOS , ERRCNT
            CALL M3FLUSH( 6 )
            GO TO  100
        ELSE
            CALL M3EXIT( 'GETNUM', 0, 0, 
     &                   'Maximum error count exceeded', 1 )
        END IF

C................   end body of GETNUM  .......................................

        ENTRY GETNUM1( DEFAULT , PROMPT )   !!  no "lo" nor "hi" bounds for result
        
        MODE = 0
        LLO  = -2**30
        LHI  =  2**30
        LDF  =  MIN ( LHI , MAX ( LLO , DEFAULT ) )
        GO TO 11

999     CONTINUE        !  error in read from terminal, or more than 5 errors
        GETNUM1 = ANSWER
        RETURN

C................   end body of GETNUM1  .......................................


92000   FORMAT ( /5X , '>>> ERROR IN ROUTINE GETNUM <<< ' ,
     &         //10X , 'Error reading response'               ,
     &         /10X  , 'I/O error status number = ' , I3                 ,
     &         /10X  , 'This is error ' , I1 , ' of 5 errors allowed ' ,
     &         /10X  , 'Please try again.'
     &         )

92100   FORMAT ( /5X , '>>>  RESPONSE ERROR  <<<'      ,
     &         //10X , 'Your response '           , I7 ,
     &                 ' not in the range '       , I7 ,
     &                 ' ... ' , I7 ,
     &         /10X  , 'This is error ' , I1 , ' of 5 errors allowed ' ,
     &         /10X  , 'Please try again.'            , /
     &         )

92200   FORMAT ( /5X , '>>>  RESPONSE ERROR  <<<'         ,
     &         //10X , 'Did not understand your response' ,
     &         /10X  , 'This is error ' , I1 , ' of 5 errors allowed ' ,
     &         /10X  , 'Please try again.'                , /
     &         )

      END FUNCTION GETNUM


!!-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


      INTEGER(8) FUNCTION GETINT8 ( LO , HI , DEFAULT , PROMPT )

        IMPLICIT NONE

        !.......   ARGUMENTS:

        INTEGER(8)   , INTENT(IN   ) :: LO , HI , DEFAULT
        CHARACTER*(*), INTENT(IN   ) :: PROMPT

        INTEGER(8)  GETINT81

        !.......   EXTERNAL FUNCTIONS:

        LOGICAL, EXTERNAL :: ENVYN
        INTEGER, EXTERNAL :: LBLANK          ! # of leading blanks


        !.......   LOCAL VARIABLES:

        INTEGER         MODE                !!  mode=1 for GETINT8(), mode=0 for GETINT81()
        INTEGER         J
        INTEGER(8)      LLO , LHI , LDF
        INTEGER         ANSWER
        INTEGER         ERRCNT
        INTEGER         IOS
        CHARACTER*32    BUFFER , DEFSTR
        CHARACTER*256   MESG

        LOGICAL, SAVE :: PROMPTON
        LOGICAL, SAVE :: FIRSTIME = .TRUE.

        CHARACTER*16, PARAMETER :: PNAME = 'GETINT8'

        !......................................................................
        !       begin GETINT8

        MODE = 1

        LLO  =  MIN ( LO , HI )
        LHI  =  MAX ( LO , HI )
        LDF  =  MIN ( LHI , MAX ( LLO , DEFAULT ) )

11      CONTINUE        !!  target of entry getdble1()

        IF( FIRSTIME ) THEN

            PROMPTON = ENVYN( 'PROMPTFLAG', 'Prompt for input flag',
     &                        .TRUE., IOS )
            IF ( IOS .GT. 0 ) THEN
                CALL M3EXIT( PNAME,0,0,'Bad env vble "PROMPTFLAG"', 2 )
            END IF
            FIRSTIME = .FALSE.

        END IF

        WRITE ( DEFSTR , '( I31 )' ) LDF
        DEFSTR = ADJUSTL( DEFSTR )

        IF( .NOT. PROMPTON ) THEN
            MESG    = 'Using default ' // DEFSTR
            CALL M3MSG2( MESG )
            IF ( MODE .EQ. 0 ) THEN
                ANSWER = DEFAULT
                GO TO  999
            END IF
            GETINT8 = DEFAULT
            RETURN
        END IF

        ERRCNT =  0

        WRITE ( DEFSTR , '( I31 )' ) LDF
        DEFSTR = ADJUSTL( DEFSTR )


100     CONTINUE
        MESG = TRIM( PROMPT ) // ' [' // TRIM( DEFSTR ) // '] >> '
        CALL M3PROMPT( MESG, BUFFER, IOS )

        IF ( IOS .NE. 0 ) THEN
            GO TO  900
        ELSE IF ( BUFFER  .EQ. ' ' )  THEN
            ANSWER  =  LDF
            MESG    = 'Using default ' // DEFSTR
        ELSE

            READ( BUFFER, *, IOSTAT=IOS, ERR=400 )  ANSWER

            IF ( ANSWER .LT. LLO  .OR.  ANSWER .GT. LHI )  THEN
                ERRCNT  =  ERRCNT + 1
                WRITE ( 6,92100 ) ANSWER , LLO , LHI , ERRCNT
                IF ( ERRCNT .LT. 5 )  GO TO  100

                GO TO  900      !  max error count exceeded

            END IF

            WRITE ( DEFSTR , '( I31 )' ) ANSWER
            DEFSTR = ADJUSTL( DEFSTR )
            MESG = 'Using response ' // DEFSTR

        END IF

        CALL M3MSG2( MESG )
        IF ( MODE .EQ. 0 )  GO TO 999

        GETINT8 = ANSWER

        RETURN


400     CONTINUE        !  error in read from BUFFER

        ERRCNT  =  ERRCNT + 1
        WRITE ( 6,92200 )  ERRCNT
        CALL M3FLUSH( 6 )
        IF ( ERRCNT .LT. 5 )  GO TO  100

900     CONTINUE        !  error in read from terminal, or more than 5 errors

        ERRCNT  =  ERRCNT + 1
        IF ( ERRCNT .LT. 5 ) THEN
            WRITE ( 6,92000 ) IOS , ERRCNT
            CALL M3FLUSH( 6 )
            GO TO  100
        ELSE
            CALL M3EXIT( 'GETINT8', 0, 0,
     &                   'Maximum error count exceeded', 1 )
        END IF

        !................   end body of GETINT8  .......................................

      ENTRY GETINT81( DEFAULT , PROMPT )   !!  no "lo" nor "hi" bounds for result

        MODE = 0
        LLO  = -2_8**62
        LHI  =  2_8**62
        LDF  =  MIN ( LHI , MAX ( LLO , DEFAULT ) )
        GO TO 11

999     CONTINUE        !  error in read from terminal, or more than 5 errors
        GETINT81 = ANSWER
        RETURN

    !................   end body of GETINT81  .......................................


92000 FORMAT ( /5X , '>>> ERROR IN ROUTINE GETINT8 <<<' ,
     &     //10X , 'Error reading response'          , 
     &     /10X  , 'I/O error status number = ' , I3 , 
     &     /10X  , 'This is error ' , I1 , ' of 5 errors allowed ' ,
     &     /10X  , 'Please try again.' 
     &     )

92100 FORMAT ( /5X , '>>>  RESPONSE ERROR  <<<'      ,
     &     //10X , 'Your response '    , I24, 
     &     ' not in the range ', I24, ' ... ' , I24,
     &     /10X  , 'This is error ' , I1 , ' of 5 errors allowed ',
     &     /10X  , 'Please try again.'            , /
     &     )

92200 FORMAT ( /5X , '>>>  RESPONSE ERROR  <<<'       ,
     &     //10X , 'Did not understand your response' ,
     &     /10X  , 'This is error ' , I1 , ' of 5 errors allowed ',
     &     /10X  , 'Please try again.'                , /
     &     )

      END FUNCTION GETINT8
