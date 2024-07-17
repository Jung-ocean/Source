     SUBROUTINE spline(x,y,n,yp1,ypn,y2)

!# include "size.h"

     INTEGER,intent(in):: n
     REAL,intent(in) :: yp1,ypn
     REAL, dimension(km+1),intent(in) :: x,y
     REAL, dimension(km+1),intent(out) :: y2
!	Given arrays x(1:n) and y(1:n) containing a tabulated function, i.e., y_i = f(x_i), with
!	x1 < x2 < .. . < x_N, and given values yp1 and ypn for the first derivative of the interpolating
!	function at points 1 and n, respectively, this routine returns an array y2(1:n) of
!	length n which contains the second derivatives of the interpolating function at the tabulated
!	points x_i. If yp1 and/or ypn are equal to 10^30 or larger, the routine is signaled to set
!	the corresponding boundary condition for a natural spline, with zero second derivative on
!	that boundary.
!	Parameter: NMAX is the largest anticipated value of n.
     INTEGER 	:: i,k
     REAL 	:: p,qn,sig,un,u(n)
     
     if (yp1.gt..99e30) then 	!The lower boundary condition is set either to be
          y2(1)=0. 		!¡°natural¡±
          u(1)=0.
     else 			!or else to have a specified first derivative.
     	y2(1)=-0.5
     	u(1)=(3./(x(2)-x(1)))*((y(2)-y(1))/(x(2)-x(1))-yp1)
     endif
     
     do i=2,n-1 		!This is the decomposition loop of the tridiagonal
     				!algorithm. y2 and u are used for temporary
     				!storage of the decomposed factors.
     	sig=(x(i)-x(i-1))/(x(i+1)-x(i-1))
     	p=sig*y2(i-1)+2.
     	y2(i)=(sig-1.)/p
     	u(i)=(6.*((y(i+1)-y(i))/(x(i+1)-x(i))-(y(i)-y(i-1)) &
     	      /(x(i)-x(i-1)))/(x(i+1)-x(i-1))-sig*u(i-1))/p
     enddo
     
     if (ypn.gt..99e30) then 	!The upper boundary condition is set either to be
     	qn=0. 			!¡°natural¡±
     	un=0.
     else 			!or else to have a specified first derivative.
     	qn=0.5
	un=(3./(x(n)-x(n-1)))*(ypn-(y(n)-y(n-1))/(x(n)-x(n-1)))
     endif
     
     y2(n)=(un-qn*u(n-1))/(qn*y2(n-1)+1.)
     
     do k=n-1,1,-1 		!This is the backsubstitution loop of the tridiagoy2(
     	y2(k)=y2(k)*y2(k+1)+u(k) 	!nal algorithm.
     enddo
     
     return
     END
     
     SUBROUTINE splint(xa,ya,y2a,n,x,y,nnew)

!# include "size.h"

     INTEGER,intent(in) :: n,nnew
     REAL,dimension(km+1),intent(in)  :: xa,y2a,ya
     REAL,dimension(km),intent(out) :: x,y
!     Given the arrays xa(1:n) and ya(1:n) of length n, which tabulate a function (with the
!     xa_i¡¯s in order), and given the array y2a(1:n), which is the output from spline above,
!     and given a value of x, this routine returns a cubic-spline interpolated value y.
     INTEGER 	:: k,khi,klo
     REAL 	:: a,b,h
 				!We will find the right place in the table by means of bisection.
     				!This is optimal if sequential calls to this routine are at random
				!values of x. If sequential calls are in order, and closely
     				!spaced, one would do better to store previous values of
     				!klo and khi and test if they remain appropriate on the
     				!next call.
     do i=1,nnew
     	klo=1
     	khi=n
     	do while (khi-klo.gt.1)
     		k=(khi+klo)/2
     		if(xa(k).gt.x(i)) then
     			khi=k
     		else
     			klo=k
     		endif
     	enddo 			!klo and khi now bracket the input value of x.
     
     	h=xa(khi)-xa(klo)
     
     	if (h.eq.0.) pause 'bad xa input in splint' !The xa¡¯s must be distinct.

     	a=(xa(khi)-x(i))/h 		!Cubic spline polynomial is now evaluated.
     	b=(x(i)-xa(klo))/h
     	y(i)=a*ya(klo)+b*ya(khi)+ &
     	  ((a**3-a)*y2a(klo)+(b**3-b)*y2a(khi))*(h**2)/6.
     enddo
       
     return
     END
