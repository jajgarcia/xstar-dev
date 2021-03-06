      subroutine impactn(n,m,temp,ic,amn,cmm,lun11,lpri) 
!                                                                       
! impact parameter collision cross-sections using the method of seaton. 
! impactn.ftn calculates the electron collisional excitation rate for   
! transitions between principal quantum number n and m in hydrogenic    
! atoms with ionic charge ic.  it is assumed that rm=1 and z1=1.        
! cmm is the symmetrical quantity used in the models.                   
!     author:  M. Bautista                                              
!                                                                       
      implicit none 
!                                                                       
      real(8) temp,ecm,psi,cr,amn,cmm 
      integer n,m,lun11,lpri,ic 
!                                                                       
      real(8)  b,xsi,phi,bo,xsw,phw,del 
      real(8) xm,rm,z1,tk,ecm3,po,fi,wo,ev,wi,w,ff,crinc 
      integer inc,jm,j 
!                                                                       
!                                                                       
      if (lpri.ne.0)                                                    &
     & write (lun11,*)'in impactn:',n,m,temp,ic,amn                     
      cmm=0. 
      xm=157888.*float(ic*ic)/temp/float(m*m) 
      if(xm.gt.60) return 
      rm=1. 
      z1=1. 
      tk=8.617e-5*temp 
      inc=1 
      jm=90*inc 
!                                                                       
      ecm=109737.*float(ic*ic)*(1./float(n*n)-1./float(m*m)) 
      ecm3=ecm**3 
      ecm=-ecm 
      psi=1.644e+5*amn/ecm3 
       po=(5.*float(n*n)+1)/4./float(ic) 
!                                                                       
      cr=0. 
      fi=0. 
      wo=0. 
      b=10. 
      ev=abs(ecm)/8065.48 
!                                                                       
      if (lpri.ne.0)                                                    &
     & write (lun11,*)xm,tk,ecm,ecm3,psi,po,ev                          
!                                                                       
! strong coupling                                                       
!                                                                       
   21  del=b/100./dfloat(inc) 
      do 20 j=1,jm 
      b=b-del 
      call impcfn(b,xsi,phi) 
      w=float(ic)*rm*ev/(b)*sqrt(2.*(xsi)*psi) 
      wi=w+ecm/8065.48/2. 
      if (lpri.ne.0)                                                    &
     & write (lun11,*)'in 20 loop:',j,b,xsi,phi,w,wi                    
      if(wi/tk.ge.100.) go to 13 
      if(wi.le.0.) go to 20 
!                                                                       
!c weak coupling                                                        
!c                                                                      
       bo=dble(po*ev/2./w*sqrt(wi*rm/13.60)) 
       call impcfn(bo,xsw,phw) 
!c                                                                      
!c the minimum of the weak and strong coupling x-sections is used       
       ff=min((xsi/2.+phi),(phw)) 
!                                                                       
! only the strong coupling calculation is used                          
      ff=(xsi/2.+phi) 
      ff=ff*exp(-wi/tk) 
!                                                                       
      crinc=(fi+ff)/2.*(wi-wo) 
      cr=crinc+cr 
      if(cr.lt.1.e-20) go to 20 
      fi=ff 
      wo=wi 
      if (lpri.ne.0)                                                    &
     & write (lun11,*)'weak coupling:',bo,xsw,phw,ff,crinc,cr           
      if((crinc/cr.lt.1.e-5).and.(crinc.gt.1.e-7)) go to 13 
!                                                                       
   20  continue 
      go to 21 
   13     cr=6.900e-5*z1*z1*sqrt(rm/temp)*psi*cr/tk 
      cmm=cr*m*m*exp(xm) 
!                                                                       
      if (lpri.ne.0)                                                    &
     & write (lun11,*)'done with impactn:',cr,cmm                       
!                                                                       
      return 
      END                                           
