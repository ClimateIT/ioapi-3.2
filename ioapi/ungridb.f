
      SUBROUTINE  UNGRIDBS1( NCOLS1, NROWS1, XORIG, YORIG, XCELL, YCELL,
     &                       NPTS, XLOC, YLOC, NU, CU )

      !!***********************************************************************
      !! Version "$Id: ungridb.f 100 2015-01-16 16:52:16Z coats $"
      !! EDSS/Models-3 I/O API.
      !! Copyright (C) 1992-2002 MCNC and Carlie J. Coats, Jr.,
      !! (C) 2003-2010 by Baron Advanced Meteorological Systems, and
      !! (C) 2014 UNC Institute for the Environment.
      !! Distributed under the GNU LESSER GENERAL PUBLIC LICENSE version 2.1
      !! See file "LGPL.txt" for conditions of use.
      !!.........................................................................
      !!  subroutine UNGRIDBS1 body starts at line   72:  single-precision 1D inputs
      !!  subroutine UNGRIDBS2 body starts at line  141:  single-precision 2D inputs
      !!  subroutine UNGRIDBD1 body starts at line  245:  double-precision 1D inputs
      !!  subroutine UNGRIDBD2 body starts at line  345:  double-precision 2D inputs
      !!
      !!  FUNCTION:
      !! 	computes "ungridding" matrices to be used by BMATVEC() and BILIN(),
      !!	for program LAYPOINT, etc., to perform bilinear interpolation
      !!	from a grid to a set of locations { <XLOC(S),YLOC(S)>, S=1:NPTS }
      !!    Uses "closest boundary-value" beyond the input-grid boundary
      !!
      !!  SEE ALSO:
      !!       BILIN()   which performs combined interpolate-only,
      !!                 preserving the subscript-order.
      !!       BMATVEC() which performs combined interpolate-and-transpose,
      !!                 e.g., for SMOKE program LAYPOINT, changing LAYER
      !!                 from an outermost subscript to an innermost
      !!
      !!  PRECONDITIONS REQUIRED:  none
      !!
      !!  SUBROUTINES AND FUNCTIONS CALLED:  none
      !!
      !!  REVISION  HISTORY:
      !!    prototype 12/95 by CJC
      !!    Modified 03/2010 by CJC: F9x changes for I/O API v3.1
      !!    Version   9/2014 by CJC:  modifications for OpenMP parallel
      !!    Version  12/2014 by CJC for I/O API v3.2:  multiple versions
      !!        with M3UTILIO generic interface UNGRIDB()
      !!***********************************************************************

      IMPLICIT NONE

        !!...........   ARGUMENTS and their descriptions:

        INTEGER, INTENT(IN   ) :: NCOLS1, NROWS1    !  number of grid columns, rows
        REAL*8 , INTENT(IN   ) :: XORIG, YORIG	    !  X,Y coords of LL grid corner
        REAL*8 , INTENT(IN   ) :: XCELL, YCELL	    !  X,Y direction cell size
        INTEGER, INTENT(IN   ) :: NPTS	            !  number of (point-source) locations
        REAL   , INTENT(IN   ) :: XLOC( NPTS ) 	    !  X point coordinates
        REAL   , INTENT(IN   ) :: YLOC( NPTS ) 	    !  Y point coordinates
        INTEGER, INTENT(  OUT) :: NU( 4,NPTS )      !  single-indexed subscripts into grid
        REAL   , INTENT(  OUT) :: CU( 4,NPTS )      !  coefficients

        !!...........   SCRATCH LOCAL VARIABLES and their descriptions:

        INTEGER		S           !  source counter
        INTEGER		C, R        !  subscripts into doubly-indexed grid
        INTEGER		K           !  subscript  into singly-indexed grid
        REAL		DDX, DDY    !  inverse cell size
        REAL		XD0, YD0    !  center of LL cell
        REAL		X, Y        !  grid-normal coords of point
        REAL		P, Q        !  linear-interpolation coeffs
        REAL		XN, YN


        !!***********************************************************************
        !!   begin body of subroutine  UNGRIDBS1

        DDX = 1.0 / XCELL
        DDY = 1.0 / YCELL

        XD0 = XORIG + 0.5D0 * XCELL
        YD0 = YORIG + 0.5D0 * YCELL

        XN = DBLE( NCOLS1-1 )
        YN = DBLE( NROWS1-1 )

!$OMP   PARALLEL DO
!$OMP&    DEFAULT( NONE ),
!$OMP&     SHARED( DDX, DDY, XD0, YD0, XN, YN, NPTS, NU, CU,
!$OMP&             XLOC, YLOC, NCOLS1, NROWS1 ),
!$OMP&    PRIVATE( S, X, Y, C, R, K, P, Q )

        DO  S = 1, NPTS

            !!  Hacks to fix this up to deal with the fact
            !!  that computer languages do the WRONG THING
            !!  for negative-number integer conversions and remainders:

            X = DDX * ( XLOC( S ) - XD0 )	!  normalized grid coords
            IF ( X .LE. 0.0 ) THEN
                C = 1
                X = 0.0
                P = 1.0
            ELSE IF ( X .GE. XN ) THEN
                C = NCOLS1-1
                X = 1.0
                P = 0.0
            ELSE
                C = 1 + INT( X )          ! truncated to integer
                X = MOD( X, 1.0 )         ! trapped between 0 and 1
                P = 1.0 - X
            END IF

            Y = DDY * ( YLOC( S ) - YD0 )	!  normalized grid coords
            IF ( Y .LE. 0.0 ) THEN
                R = 1
                P = 0.0
                Q = 1.0
            ELSE IF ( Y .GE. YN ) THEN
                R = NROWS1-1
                Y = 1.0
                Q = 0.0
            ELSE
                R = 1 + INT( Y )                ! truncated to integer
                Y = MOD( Y, 1.0 )               ! trapped between 0 and 1
                Q = 1.0 - Y
            END IF

             K = ( R - 1 ) * NCOLS1  +  C
             NU( 1,S ) = K                      !!  single-index for (C,R)
             NU( 2,S ) = K + 1                  !!  ... (C+1,R  )
             NU( 3,S ) = K + NCOLS1              !!  ... (C  ,R+1)
             NU( 4,S ) = K + NCOLS1 + 1          !!  ... (C+1,R+1)
             CU( 1,S ) =  P * Q
             CU( 2,S ) =  X * Q
             CU( 3,S ) =  P * Y

        END DO          !  end matrix computation loop on point sources

        RETURN
        END  SUBROUTINE  UNGRIDBS1


!!-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


      SUBROUTINE  UNGRIDBS2( NCOLS1, NROWS1, XORIG, YORIG, XCELL, YCELL,
     &                       NCOLS2, NROWS2, XLOC, YLOC, NU, CU )


        IMPLICIT NONE

        !!...........   ARGUMENTS and their descriptions:

        INTEGER, INTENT(IN   ) :: NCOLS1, NROWS1        !  number of grid columns, rows
        REAL*8 , INTENT(IN   ) :: XORIG, YORIG	        !  X,Y coords of LL grid corner
        REAL*8 , INTENT(IN   ) :: XCELL, YCELL	        !  X,Y direction cell size
        INTEGER, INTENT(IN   ) :: NCOLS2, NROWS2        !  number of input-grid locations
        REAL   , INTENT(IN   ) :: XLOC( NCOLS2,NROWS2 ) !  X point coordinates
        REAL   , INTENT(IN   ) :: YLOC( NCOLS2,NROWS2 ) !  Y point coordinates
        INTEGER, INTENT(  OUT) :: NU( 4,NCOLS2*NROWS2 ) !  single-indexed subscripts into grid
        REAL   , INTENT(  OUT) :: CU( 4,NCOLS2*NROWS2 ) !  coefficients

        !!...........   SCRATCH LOCAL VARIABLES and their descriptions:

        INTEGER		C, R        !  subscripts into doubly-indexed output grid
        INTEGER		CC, RR      !  subscripts into doubly-indexed  input grid
        INTEGER		K, S        !  subscripts  into singly-indexed grids
        REAL		DDX, DDY    !  inverse cell size
        REAL		XD0, YD0    !  center of LL cell
        REAL		X, Y        !  grid-normal coords of point
        REAL		P, Q        !  linear-interpolation coeffs
        REAL		XN, YN


        !!***********************************************************************
        !!   begin body of subroutine  UNGRIDBS2

        DDX = 1.0 / XCELL
        DDY = 1.0 / YCELL

        XD0 = XORIG + 0.5D0 * XCELL
        YD0 = YORIG + 0.5D0 * YCELL

        XN = DBLE( NCOLS1-1 )
        YN = DBLE( NROWS1-1 )

!$OMP   PARALLEL DO
!$OMP&    DEFAULT( NONE ),
!$OMP&     SHARED( DDX, DDY, XD0, YD0, XN, YN, NCOLS2, NROWS2, NU, CU,
!$OMP&             XLOC, YLOC, NCOLS1, NROWS1 ),
!$OMP&    PRIVATE( X, Y, C, R, CC, RR, S, K, P, Q )

        DO  RR = 1, NROWS2
        DO  CC = 1, NCOLS2

            !!  Hacks to fix this up to deal with the fact
            !!  that computer languages do the WRONG THING
            !!  for negative-number integer conversions and remainders:

            X = DDX * ( XLOC( CC,RR ) - XD0 )	!  normalized grid coords
            IF ( X .LE. 0.0 ) THEN
                C = 1
                X = 0.0
                P = 1.0
            ELSE IF ( X .GE. XN ) THEN
                C = NCOLS1-1
                X = 1.0
                P = 0.0
            ELSE
                C = 1 + INT( X )          ! truncated to integer
                X = MOD( X, 1.0 )         ! trapped between 0 and 1
                P = 1.0 - X
            END IF

            Y = DDY * ( YLOC( CC,RR ) - YD0 )	!  normalized grid coords
            IF ( Y .LE. 0.0 ) THEN
                R = 1
                P = 0.0
                Q = 1.0
            ELSE IF ( Y .GE. YN ) THEN
                R = NROWS1-1
                Y = 1.0
                Q = 0.0
            ELSE
                R = 1 + INT( Y )                ! truncated to integer
                Y = MOD( Y, 1.0 )               ! trapped between 0 and 1
                Q = 1.0 - Y
            END IF

             S = ( RR - 1 ) * NCOLS2  +  CC
             K = ( R  - 1 ) * NCOLS1  +  C
             NU( 1,S ) = K                      !!  single-index for (C,R)
             NU( 2,S ) = K + 1                  !!  ... (C+1,R  )
             NU( 3,S ) = K + NCOLS1              !!  ... (C  ,R+1)
             NU( 4,S ) = K + NCOLS1 + 1          !!  ... (C+1,R+1)
             CU( 1,S ) =  P * Q
             CU( 2,S ) =  X * Q
             CU( 3,S ) =  P * Y

        END DO          !  end matrix computation loop on point sources
        END DO          !  end matrix computation loop on point sources

        RETURN
        END  SUBROUTINE  UNGRIDBS2


!!-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


      SUBROUTINE  UNGRIDBD1( NCOLS1, NROWS1, XORIG, YORIG, XCELL, YCELL,
     &                       NPTS, XLOC, YLOC, NU, CU )

      IMPLICIT NONE

        !!...........   ARGUMENTS and their descriptions:

        INTEGER, INTENT(IN   ) :: NCOLS1, NROWS1    !  number of grid columns, rows
        REAL*8 , INTENT(IN   ) :: XORIG, YORIG	    !  X,Y coords of LL grid corner
        REAL*8 , INTENT(IN   ) :: XCELL, YCELL	    !  X,Y direction cell size
        INTEGER, INTENT(IN   ) :: NPTS	            !  number of (point-source) locations
        REAL*8 , INTENT(IN   ) :: XLOC( NPTS ) 	    !  X point coordinates
        REAL*8 , INTENT(IN   ) :: YLOC( NPTS ) 	    !  Y point coordinates
        INTEGER, INTENT(  OUT) :: NU( 4,NPTS )      !  single-indexed subscripts into grid
        REAL   , INTENT(  OUT) :: CU( 4,NPTS )      !  coefficients

        !!...........   SCRATCH LOCAL VARIABLES and their descriptions:

        INTEGER		S           !  source counter
        INTEGER		C, R        !  subscripts into doubly-indexed grid
        INTEGER		K           !  subscript  into singly-indexed grid
        REAL*8		DDX, DDY    !  inverse cell size
        REAL*8		XD0, YD0    !  center of LL cell
        REAL*8		XN, YN
        REAL		X, Y        !  grid-normal coords of point
        REAL		P, Q        !  linear-interpolation coeffs


        !!***********************************************************************
        !!   begin body of subroutine  UNGRIDBD1

        DDX = 1.0D0 / XCELL
        DDY = 1.0D0 / YCELL

        XD0 = XORIG + 0.5D0 * XCELL
        YD0 = YORIG + 0.5D0 * YCELL

        XN = DBLE( NCOLS1-1 )
        YN = DBLE( NROWS1-1 )

!$OMP   PARALLEL DO
!$OMP&    DEFAULT( NONE ),
!$OMP&     SHARED( DDX, DDY, XD0, YD0, XN, YN, NPTS, NU, CU,
!$OMP&             XLOC, YLOC, NCOLS1, NROWS1 ),
!$OMP&    PRIVATE( S, X, Y, C, R, K, P, Q )

        DO  S = 1, NPTS

            !!  Hacks to fix this up to deal with the fact
            !!  that computer languages do the WRONG THING
            !!  for negative-number integer conversions and remainders:

            X = DDX * ( XLOC( S ) - XD0 )	!  normalized grid coords
            IF ( X .LE. 0.0 ) THEN
                C = 1
                X = 0.0
                P = 1.0
            ELSE IF ( X .GE. XN ) THEN
                C = NCOLS1-1
                X = 1.0
                P = 0.0
            ELSE
                C = 1 + INT( X )          ! truncated to integer
                X = MOD( X, 1.0 )         ! trapped between 0 and 1
                P = 1.0 - X
            END IF

            Y = DDY * ( YLOC( S ) - YD0 )	!  normalized grid coords
            IF ( Y .LE. 0.0 ) THEN
                R = 1
                P = 0.0
                Q = 1.0
            ELSE IF ( Y .GE. YN ) THEN
                R = NROWS1-1
                Y = 1.0
                Q = 0.0
            ELSE
                R = 1 + INT( Y )                ! truncated to integer
                Y = MOD( Y, 1.0 )               ! trapped between 0 and 1
                Q = 1.0 - Y
            END IF

             K = ( R - 1 ) * NCOLS1  +  C
             NU( 1,S ) = K                      !!  single-index for (C,R)
             NU( 2,S ) = K + 1                  !!  ... (C+1,R  )
             NU( 3,S ) = K + NCOLS1              !!  ... (C  ,R+1)
             NU( 4,S ) = K + NCOLS1 + 1          !!  ... (C+1,R+1)
             CU( 1,S ) =  P * Q
             CU( 2,S ) =  X * Q
             CU( 3,S ) =  P * Y

        END DO          !  end matrix computation loop on point sources

        RETURN
        END  SUBROUTINE  UNGRIDBD1


!!-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


      SUBROUTINE  UNGRIDBD2( NCOLS1, NROWS1, XORIG, YORIG, XCELL, YCELL,
     &                       NCOLS2, NROWS2, XLOC, YLOC, NU, CU )


        IMPLICIT NONE

        !!...........   ARGUMENTS and their descriptions:

        INTEGER, INTENT(IN   ) :: NCOLS1, NROWS1        !  number of grid columns, rows
        REAL*8 , INTENT(IN   ) :: XORIG, YORIG	        !  X,Y coords of LL grid corner
        REAL*8 , INTENT(IN   ) :: XCELL, YCELL	        !  X,Y direction cell size
        INTEGER, INTENT(IN   ) :: NCOLS2, NROWS2        !  number of input-grid locations
        REAL*8 , INTENT(IN   ) :: XLOC( NCOLS2,NROWS2 ) !  X point coordinates
        REAL*8 , INTENT(IN   ) :: YLOC( NCOLS2,NROWS2 ) !  Y point coordinates
        INTEGER, INTENT(  OUT) :: NU( 4,NCOLS2*NROWS2 ) !  single-indexed subscripts into grid
        REAL   , INTENT(  OUT) :: CU( 4,NCOLS2*NROWS2 ) !  coefficients

        !!...........   SCRATCH LOCAL VARIABLES and their descriptions:

        INTEGER		C, R,  S    !  subscripts into doubly-indexed output grid
        INTEGER		CC, RR      !  subscripts into doubly-indexed  input grid
        INTEGER		K           !  subscript  into singly-indexed grid
        REAL*8		DDX, DDY    !  inverse cell size
        REAL*8		XD0, YD0    !  center of LL cell
        REAL*8		XN, YN
        REAL		X, Y        !  grid-normal coords of point
        REAL		P, Q        !  linear-interpolation coeffs


        !!***********************************************************************
        !!   begin body of subroutine  UNGRIDBD2

        DDX = 1.0D0 / XCELL
        DDY = 1.0D0 / YCELL

        XD0 = XORIG + 0.5D0 * XCELL
        YD0 = YORIG + 0.5D0 * YCELL

        XN = DBLE( NCOLS1-1 )
        YN = DBLE( NROWS1-1 )

!$OMP   PARALLEL DO
!$OMP&    DEFAULT( NONE ),
!$OMP&     SHARED( DDX, DDY, XD0, YD0, XN, YN, NCOLS2, NROWS2, NU, CU,
!$OMP&             XLOC, YLOC, NCOLS1, NROWS1 ),
!$OMP&    PRIVATE( S, X, Y, C, R, CC, RR, K, P, Q )

        DO  RR = 1, NROWS2
        DO  CC = 1, NCOLS2

            !!  Hacks to fix this up to deal with the fact
            !!  that computer languages do the WRONG THING
            !!  for negative-number integer conversions and remainders:

            X = DDX * ( XLOC( CC,RR ) - XD0 )	!  normalized grid coords
            IF ( X .LE. 0.0 ) THEN
                C = 1
                X = 0.0
                P = 1.0
            ELSE IF ( X .GE. XN ) THEN
                C = NCOLS1-1
                X = 1.0
                P = 0.0
            ELSE
                C = 1 + INT( X )          ! truncated to integer
                X = MOD( X, 1.0 )         ! trapped between 0 and 1
                P = 1.0 - X
            END IF

            Y = DDY * ( YLOC( CC,RR ) - YD0 )	!  normalized grid coords
            IF ( Y .LE. 0.0 ) THEN
                R = 1
                P = 0.0
                Q = 1.0
            ELSE IF ( Y .GE. YN ) THEN
                R = NROWS1-1
                Y = 1.0
                Q = 0.0
            ELSE
                R = 1 + INT( Y )                ! truncated to integer
                Y = MOD( Y, 1.0 )               ! trapped between 0 and 1
                Q = 1.0 - Y
            END IF

             S = ( RR - 1 ) * NCOLS2  +  CC
             K = ( R  - 1 ) * NCOLS1  +  C
             NU( 1,S ) = K                      !!  single-index for (C,R)
             NU( 2,S ) = K + 1                  !!  ... (C+1,R  )
             NU( 3,S ) = K + NCOLS1              !!  ... (C  ,R+1)
             NU( 4,S ) = K + NCOLS1 + 1          !!  ... (C+1,R+1)
             CU( 1,S ) =  P * Q
             CU( 2,S ) =  X * Q
             CU( 3,S ) =  P * Y

        END DO          !  end matrix computation loop on point sources
        END DO          !  end matrix computation loop on point sources

        RETURN
        END  SUBROUTINE  UNGRIDBD2



