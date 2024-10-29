  subroutine DISTANCE(DIS, ANG, RAT1, RON1, RAT2, RON2)

!
! calculate distance 
! subroutine distance(dis, ang, rat1, ron1, rat2, ron2)
! Input : rat1 - latitude of initial point      
!         ron1 - longitude of initial point      
!         rat2 - latitude of depature point      
!         ron2 - longitude of depature point      
! Output : dis - distance between two points
!          ang - cyclonic angle from eastward
!

  real(kind=8), intent(in) :: RAT1, RON1, RAT2, RON2
  real(kind=8), intent(out) :: DIS, ANG

  real, parameter :: PI = 3.141592654
  real(kind=8) :: RON,AAA,DISR
  real(kind=8) :: THETA1,THETA2,PI1,PI2
  real(kind=8) :: R11,R12,R13,R21,R22,R23,P1,P2,P3

  THETA1=(90.-RAT1)*PI/180.
  THETA2=(90.-RAT2)*PI/180.
  RON=(RON2-RON1)*PI/180.
      
  AAA=COS(THETA1)*COS(THETA2)+SIN(THETA1)*SIN(THETA2)*COS(RON)
  DISR=ACOS(AAA)
      
  DIS=DISR*6371000.
      
  IF (RON1.EQ.RON2) THEN
     IF (RAT2.EQ.RAT1) THEN
         ANG=999.
        ELSEIF (RAT2.GT.RAT1) THEN
         ANG=90.
        ELSE
         ANG=270.
     ENDIF   
     return
  ENDIF
  IF (RAT2.EQ.RAT1) THEN
     IF (RON2.EQ.RON1) THEN
      ANG=999.
     ELSEIF (RON2.GT.RON1) THEN
      ANG=0.
     ELSE 
      ANG=180.
     ENDIF
     return
   ENDIF 
      
  PI1 = RON1*PI/180.
  PI2 = RON2*PI/180.
            
  R11 = SIN(THETA1)*SIN(PI1)*COS(THETA2)- &
                     COS(THETA1)*SIN(THETA2)*SIN(PI2)
  R12 = COS(THETA1)*SIN(THETA2)*COS(PI2)- &
                     SIN(THETA1)*COS(PI1)*COS(THETA2)
  R13 = SIN(THETA1)*COS(PI1)*SIN(THETA2)*SIN(PI2)- &
            SIN(THETA1)*SIN(PI1)*SIN(THETA2)*COS(PI2)
  R21 = -SIN(THETA1)*SIN(PI1)
  R22 = SIN(THETA1)*COS(PI1)
  R23 = 0.
      
  P1 = R12*R23-R13*R22
  P2 = R13*R21-R11*R23
  P3 = R11*R22-R12*R21
      
  ANG = SQRT(P1*P1+P2*P2+P3*P3)/(SQRT(R11*R11+ &
        R12*R12+R13*R13)*SQRT(R21*R21+R22*R22+R23*R23))
  ANG = 90. - ASIN(ANG)*180./PI
      
  IF(RON2.LT.RON1) ANG = 180. - ANG

  IF(RAT2.LT.RAT1) ANG = -ANG

  RETURN
  END subroutine
