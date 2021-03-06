
        INTEGER  FUNCTION GCDI( P , Q )

C***********************************************************************
C Version "$Id: gcd.f 188 2020-10-03 15:08:47Z coats $"
C EDSS/Models-3 I/O API.
C Copyright (C) 1992-2002 MCNC and Carlie J. Coats, Jr.,
C (C) 2003-2010 by Baron Advanced Meteorological Systems.
C Distributed under the GNU LESSER GENERAL PUBLIC LICENSE version 2.1
C See file "LGPL.txt" for conditions of use.
C.........................................................................
C  GCD function body starts at line 44
C  LCM function body starts at line 77
C
C  FUNCTION:
C       GCD computes greatest common divisors, and LCM computes
C       the least common multiple of integers P,Q
C
C  PRECONDITIONS REQUIRED:  none
C
C  REVISION  HISTORY:
C       prototype 3/1991 by CJC
C
C       Bugfix    9/2004 by CJC: handle case that P=0 or Q=0
C
C       Modified 03/2010 by CJC: F9x changes for I/O API v3.1
C
C       Modified 10/2020 by CJC: add GCDI,GCDL, LCMI, LCML for generics
C***********************************************************************

            IMPLICIT NONE

C...........   Arguments:

            INTEGER, INTENT(IN   ) :: P , Q


C.......   Local Variables:

            INTEGER 	X, Y


C***********************************************************************
C   begin body of program  GCD2

            IF ( P .EQ. 0 ) THEN
                GCDI = 0
                RETURN
            ELSE IF ( Q .EQ. 0 ) THEN
                GCDI = 0
                RETURN
            END IF

            X = ABS ( P )
            Y = ABS ( Q )

111         CONTINUE

                IF ( X .GT. Y ) THEN
                    X = MOD ( X , Y )
                    IF ( X .NE. 0 ) GO TO 111
                ELSE IF ( X .LT. Y ) THEN
                    Y = MOD ( Y , X )
                    IF ( Y .NE. 0 ) GO TO 111
                END IF

            GCDI = MAX ( X , Y )

            RETURN

        END FUNCTION GCDI



        ! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


        INTEGER(8)  FUNCTION GCDL( P , Q )

            IMPLICIT NONE

            INTEGER(8), INTENT(IN   ) :: P , Q

            INTEGER(8) 	X, Y

            IF ( P .EQ. 0 ) THEN
                GCDL = 0
                RETURN
            ELSE IF ( Q .EQ. 0 ) THEN
                GCDL = 0
                RETURN
            END IF

            X = ABS ( P )
            Y = ABS ( Q )

111         CONTINUE

                IF ( X .GT. Y ) THEN
                    X = MOD ( X , Y )
                    IF ( X .NE. 0 ) GO TO 111
                ELSE IF ( X .LT. Y ) THEN
                    Y = MOD ( Y , X )
                    IF ( Y .NE. 0 ) GO TO 111
                END IF

            GCDL = MAX ( X , Y )

            RETURN

        END FUNCTION GCDL



        ! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


        INTEGER  FUNCTION GCD( P , Q )
            IMPLICIT NONE
            INTEGER, INTENT(IN   ) :: P , Q
            INTEGER, EXTERNAL :: GCDI            
            GCD = GCDI( P, Q )
            RETURN
        END FUNCTION GCD



        ! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-



        INTEGER FUNCTION LCMI( I, J )
            INTEGER, INTENT( IN ) :: I, J
            INTEGER(8), EXTERNAL  :: GCDL
            INTEGER(8) 	X, Y, Z
            X = I
            Y = J
            Z = ( X * Y ) / GCDL( X,Y )
            LCMI = Z
            RETURN
        END FUNCTION LCMI



        ! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-



        INTEGER(8) FUNCTION LCML( I, J )
            INTEGER(8), INTENT( IN ) :: I, J
            INTEGER(8), EXTERNAL     :: GCDL
            LCML = ( I * J ) / GCDL( I, J )
            RETURN
        END FUNCTION LCML



        ! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-



        INTEGER FUNCTION LCM( I, J )
            INTEGER, INTENT( IN ) :: I, J
            LCM = LCMI( I, J )
            RETURN
        END FUNCTION LCM
