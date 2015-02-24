
        SUBROUTINE INTG2REAL( SIZE, INTG, GRID )

C***********************************************************************
C Version "$Id: intg2real.f 164 2015-02-24 06:50:01Z coats $"
C EDSS/Models-3 I/O API.
C Copyright (C) 1992-2002 MCNC and Carlie J. Coats, Jr.,
C (C) 2003-2010 by Baron Advanced Meteorological Systems.
C Distributed under the GNU LESSER GENERAL PUBLIC LICENSE version 2.1
C See file "LGPL.txt" for conditions of use.
C.........................................................................
C  subroutine INTG2REAL body starts at line  44
C  subroutine INT82REAL body starts at line  44
C
C  FUNCTION:
C       convert INTEGER input array INTG( SIZE ) to REAL
C
C  PRECONDITIONS REQUIRED:
C       none
C
C  SUBROUTINES AND FUNCTIONS CALLED: none
C
C  REVISION  HISTORY:
C       prototype 6/95 by CJC
C       Modified 03/2010 by CJC: F9x changes for I/O API v3.1
C       Modified 02/2015 by CJC for I/O API 3.2: support for M3INT8 variables
C***********************************************************************

        IMPLICIT NONE

C...........   ARGUMENTS and their descriptions:
        
        INTEGER, INTENT(IN   ) :: SIZE          !  array dimension
        INTEGER, INTENT(IN   ) :: INTG( SIZE )  !  input integer array
        REAL   , INTENT(  OUT) :: GRID( SIZE )  ! output real array

C...........   SCRATCH LOCAL VARIABLES and their descriptions:
        
        INTEGER     I


C***********************************************************************
C   begin body of subroutine  INT2REAL

        DO  I = 1, SIZE
            GRID( I ) = FLOAT( INTG( I ) )
        END DO

        RETURN
        END SUBROUTINE INTG2REAL


!!-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


        SUBROUTINE INT82REAL( SIZE, INT8, GRID )

        IMPLICIT NONE

C...........   ARGUMENTS and their descriptions:
        
        INTEGER  , INTENT(IN   ) :: SIZE          !  array dimension
        INTEGER*8, INTENT(IN   ) :: INT8( SIZE )  !  input integer array
        REAL     , INTENT(  OUT) :: GRID( SIZE )  ! output real array

C...........   SCRATCH LOCAL VARIABLES and their descriptions:
        
        INTEGER     I


C***********************************************************************
C   begin body of subroutine  INT2REAL

        DO  I = 1, SIZE
            GRID( I ) = FLOAT( INT8( I ) )
        END DO

        RETURN
        END SUBROUTINE INT82REAL


