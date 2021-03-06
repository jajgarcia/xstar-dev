      subroutine bremem(lpri,lun11,xee,xpx,t,epi,ncn2,brcems,opakc) 
!                                                                       
!     this routine computes emissivities due to thermal bremsstrahlung. 
!     author:  T. Kallman (from xstar1)                                 
!                                                                       
      use globaldata
      implicit none 
!                                                                       
!                                                                       
      real(8) epi(ncn),brcems(ncn),xpx,t,xee,opakc(ncn) 
      integer lpri,lun11,ncn2,numcon,kl,kk 
      real(8) cc,xnx,enz2,zz,temp,gam,gau,brtmp,ekt,t6 
      integer lskp,lprisv 
      real(8) bbee 
!                                                                       
!      data cc/8.223e-15/                                               
      data cc/1.032e-13/ 
!                                                                       
      lskp=1 
!                                                                       
      ekt = t*(0.861707) 
      t6 = t/100. 
!                                                                       
      lprisv=lpri 
      if (lpri.gt.0) write (lun11,*)'in bremem',t 
!                    
!                                                   
      numcon=ncn2 
      do kl = 1,numcon,lskp 
         brcems(kl) = 0. 
         enddo 
!                                                                       
      xnx=xpx*xee 
      enz2=(1.4)*xnx 
      zz=1. 
      do kk = 1,numcon,lskp 
         temp = epi(kk)/ekt 
         gam = zz*zz*(0.158)/t6 
         gau = 1. 
!         if ( temp.lt.30. ) gau = fbg(temp,gam) 
         brtmp = cc*xnx*enz2*gau*exp(-temp)/sqrt(t) 
         brcems(kk) = brcems(kk) + brtmp 
         bbee=0. 
!         if ((brtmp.gt.1.d-36).and.(temp.lt.50.)) then                 
!           bbee=2.*(epi(kk)/3.99836e-8)**3/(exp(temp)-1.+1.e-24)       
!           opakc(kk)=opakc(kk)+brtmp/(1.e-24+bbee)                     
!           endif                                                       
         if ( lpri.gt.0 ) write (lun11,99001) kk,                       &
     &                zz,enz2,gam,temp,gau,brtmp,bbee,opakc(kk)         
         enddo 
!                                                                       
      lpri=lprisv 
!                                                                       
      return 
99001 format (' ',i6,8e12.4) 
      END                                           
