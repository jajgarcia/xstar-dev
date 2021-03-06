      subroutine dsec(lnerr,nlim,                                       &
     &       lpri,lppri,lun11,tinf,vturbi,critf,                        &
     &       t,trad,r,delr,xee,xpx,abel,cfrac,p,lcdd,                   &
     &       epi,ncn2,bremsa,bremsint,                                  &
     &       tau0,tauc,                                                 &
     &       np2,ncsvn,nlsvn,                                           &
     &       ntotit,                                                    &
     &       xii,rrrt,pirt,htt,cll,httot,cltot,hmctot,elcter,           &
     &       cllines,clcont,htcomp,clcomp,clbrems,                      &
     &       xilev,bilev,rnist,                                         &
     &       rcem,oplin,rccemis,brcems,opakc,opakcont,cemab,            &
     &       cabab,opakab,fline,flinel)                            
!                                                                       
!     this routine solves for temperature and electron density by the   
!     double secant method                                              
!     author:  T. Kallman                                               
!                                                                       
      use globaldata
      implicit none 
!                                                                       
!     line emissivities                                                 
      real(8) rcem(2,nnnl) 
!     line opacities                                                    
      real(8) oplin(nnnl) 
      real(8) fline(2,nnnl),flinel(ncn) 
!     line optical depths                                               
      real(8) tau0(2,nnnl) 
!     energy bins                                                       
      real(8) epi(ncn) 
!     continuum flux                                                    
      real(8) bremsa(ncn),bremsint(ncn) 
!     continuum emissivities                                            
      real(8) rccemis(2,ncn),brcems(ncn) 
!     continuum opacities                                               
      real(8) opakc(ncn),opakcont(ncn)
!     level populations                                                 
      real(8) xilev(nnml),bilev(nnml),rnist(nnml)
      real(8) cemab(2,nnml),cabab(nnml),opakab(nnml) 
      real(8) tauc(2,nnml) 
!     ion abundances                                                    
      real(8) xii(nni) 
!     heating and cooling                                               
      real(8) htt(nni),cll(nni) 
      real(8) rrrt(nni),pirt(nni) 
!     element abundances                                                
      real(8) abel(nl) 
!     state variables                                                   
      real(8) p,r,t,xpx,delr 
!     heating-cooling variables                                         
      real(8) httot,cltot,htcomp,clcomp,clbrems,elcter,cllines,          &
     &     clcont,hmctot                                                
!     input parameters                                                  
      real(8) trad,tinf 
      real(8) cfrac,critf,vturbi,xee 
      integer lcdd,ncn2,lpri,lun11,np2,nlim 
!     variables associated with thermal equilibrium solution            
      integer ntotit 
!     temporary for xwrite                                              
      character(133) tmpst 
      integer nlsvn,ncsvn 
!                                                                       
!     local variables                                                   
      integer nnt,nntt,lnerr,lppri0,lppri,nlimt,nlimx,nnxx,             &
     &        nlimtt,nlimxx,iht,ilt,iuht,iult,ihx,ilx,nnx               
      real(8) crite,crith,critt,fact,facx,epst,epsx,epstt,to,            &
     &     tl,th,xeel,xeeh,elctrl,elctrh,hmctth,hmcttl,tst,             &
     &     testt                                                        
!                                                                       
!                                                                       
      if (lpri.ne.0) write (lun11,*)'in dsec' 
!                                                                       
      crite=1.e-03 
!      crite=1.e-06                                                     
      crith=1.e-02 
!      crith=5.e-03                                                     
!      crith=1.e-05                                                     
      critt=2.e-09 
!                                                                       
      ntotit=0 
      nnt = 0 
      nntt=0 
      lnerr = 0 
      lppri0 = lppri 
      nlimt =max(nlim,0) 
      nlimx=abs(nlim) 
      nlimtt=max0(nlimt,1) 
      nlimxx=max0(nlimx,1) 
      if (lpri.ne.0)                                                    &
     & write (lun11,*)'nlimtt,nlimxx,lppri--',nlimtt,nlimxx,lppri       
      fact = 1.2 
      facx = 1.2 
      epst = crith 
      epsx = crite 
      epstt = critt 
      to = 1.e+30 
      tl = 0. 
      th = 0. 
      xeel = 0. 
      xeeh = 1. 
      elctrl = 1. 
      elctrh = -1. 
      hmctth = 0. 
      hmcttl = 0. 
!                                                                       
      iht = 0 
      ilt = 0 
      iuht = 0 
      iult = 0 
!                                                                       
  100 nnx = 0 
      t=max(t,tinf) 
      if (t.lt.tinf*1.01) then 
          nlimt=0 
          nlimtt=0 
          nlimx=0 
          nlimxx=0 
        else 
          nlimt =max(nlim,0) 
          nlimx=abs(nlim) 
          nlimxx=nlimx 
        endif 
!      if (t.lt.tinf) return                                            
      nnxx=0 
      ihx = 0 
      ilx = 0 
  200 continue 
      if ( lppri.ne.0 ) then 
        write (lun11,99001)                                             &
     &   nnx,xee,xeel,xeeh,elcter,elctrl,elctrh,                        &
     &   nnt,t,tl,th,hmctot,hmcttl,hmctth                               
        write (tmpst,99001)                                             &
     &   nnx,xee,xeel,xeeh,elcter,elctrl,elctrh,                        &
     &   nnt,t,tl,th,hmctot,hmcttl,hmctth                               
        call xwrite(tmpst,10) 
        endif 
      call func(lpri,lun11,vturbi,critf,                                &
     &       t,trad,r,delr,xee,xpx,abel,cfrac,p,lcdd,                   &
     &       epi,ncn2,bremsa,bremsint,                                  &
     &       tau0,tauc,                                                 &
     &       np2,ncsvn,nlsvn,                                           &
     &       xii,rrrt,pirt,htt,cll,httot,cltot,hmctot,elcter,           &
     &       cllines,clcont,htcomp,clcomp,clbrems,                      &
     &       xilev,bilev,rnist,                                         &
     &       rcem,oplin,rccemis,brcems,opakc,opakcont,cemab,            &
     &       cabab,opakab,fline,flinel)                       
      if ( lppri.ne.0 ) then 
        write (lun11,99001)                                             &
     &   nnx,xee,xeel,xeeh,elcter,elctrl,elctrh,                        &
     &   nnt,t,tl,th,hmctot,hmcttl,hmctth                               
        write (tmpst,99001)                                             &
     &   nnx,xee,xeel,xeeh,elcter,elctrl,elctrh,                        &
     &   nnt,t,tl,th,hmctot,hmcttl,hmctth                               
        call xwrite(tmpst,10) 
99001   format (' in dsec -- ',i4,6(1pe9.2),i4,6(1pe9.2)) 
        endif 
      ntotit=ntotit+1 
      nnx = nnx + 1 
      nnxx=nnxx+1 
      if (nnxx.ge.nlimxx) go to 300 
      tst=abs(elcter)/max(1.e-10,xee) 
      if (tst.lt.epsx) go to 300 
      if ( elcter.lt.0 ) then 
            ihx = 1 
            xeeh = xee 
            elctrh = elcter 
            if ( ilx.ne.1 ) then 
               xee = xee*facx 
               goto 200 
               endif 
         else 
            ilx = 1 
            xeel = xee 
            elctrl = elcter 
            if ( ihx.ne.1 ) then 
               xee = xee/facx 
               goto 200 
               endif 
         endif 
         xee = (xeel*elctrh-xeeh*elctrl)/(elctrh-elctrl) 
         goto 200 
!                                                                       
!                                                                       
  300 continue 
      nntt=nntt+1 
      nnt = nnt + 1 
      if ( abs(hmctot).le.epst )  goto 500 
      if (nntt.ge.nlimtt) go to 500 
      if ( nnt.lt.nlimt ) then 
         if ( hmctot.lt.0 ) then 
            iht = 1 
            th = t 
            hmctth = hmctot 
            iuht = 1 
            if ( iult.eq.0 ) hmcttl = hmcttl/2. 
            iult = 0 
            if ( ilt.ne.1 ) then 
               t = t/fact
!              doubling the step for far from equilibrium
               if (abs(hmctot).gt.0.9) t=t/fact 
               goto 100 
            endif 
         else 
            ilt = 1 
            tl = t 
            hmcttl = hmctot 
            iult = 1 
            if ( iuht.eq.0 ) hmctth = hmctth/2. 
            iuht = 0 
            if ( iht.ne.1 ) then 
               t = t*fact 
!              doubling the step for far from equilibrium
               if (abs(hmctot).gt.0.9) t=t*fact 
               goto 100 
            endif 
         endif 
         testt = abs(1.-t/to) 
         if ( testt.lt.epstt ) then 
            lnerr = -2 
            if ( lppri.ne.0 ) then 
               write (lun11,99004) 
               write (lun11,99006) nnt,t,tl,th,hmctot,hmcttl,           &
     &                         hmctth                                   
            endif 
            goto 500 
         else 
            to = t 
            t = (tl*hmctth-th*hmcttl)/(hmctth-hmcttl) 
            goto 100 
         endif 
      endif 
!                                                                       
      lnerr = 2 
      write (lun11,99002) 
      write (lun11,99006) nnt,t,tl,th,hmctot,hmcttl,hmctth 
!                                                                       
  500 if ( lppri.ne.0 ) write (lun11,99007) testt,epst,hmctot 
      lppri = lppri0 
!                                                                       
      return 
99002 format (' ','**** note: in dsec --  too many iterations **** ') 
99004 format (' ',' warrning -- dsec not converging ') 
99006 format (' ',' temperature ',i4,6(1pe16.8)) 
99007 format (' ',' finishing dsec -- test,epst,hmctot',3(1pe16.8)) 
      end                                           
