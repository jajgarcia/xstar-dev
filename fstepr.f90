      subroutine fstepr(unit,hdunum,radin,radout,rdel,t,pres,abel,      &
     &                xcol,xee,xpx,xi,                                  &
     &                np2,ncsvn,nlsvn,                                  &
     &                xilev,rnist,                                      &
     &                lun11,lpri,status)                                
!                                                                       
!                                                                       
!     Write Data for each radial zone to an individual extension        
!     author: T. Bridgman                                               
!                                                                       
!     Append a FITS extension binary table containing                   
!     nrhs columns and at most nrhdimj rows                             
!                                                                       
!     Parameters:                                                       
!        unit    integer            File unit number                    
!        hdunum  integer            Number of last HDU written          
!        radin   real(8)               inner radius of shell             
!        radout  real(8)               outer radius of shell             
!                                   nb but now it is delr in the call   
!        temp    real(8)               temperature of shell              
!        pres    real(8)               pressure in shell                 
!        nrhdimj  integer            Maximum number of rows             
!        idat1   integer(nidat1)    Needed by the atomic database       
!        rdat1   real(nidat1)       Needed by the atomic database       
!        kdat1   char*nidat1        Needed by the atomic database       
!        nptrs                      Needed by the atomic database       
!        npnxt                      Needed by the atomic database       
!        npfi                       Needed by the atomic database       
!        npfirst                    Needed by the atomic database       
!        npcon                      Needed by the atomic database       
!        npconi                     Needed by the atomic database       
!        npcon2                     Needed by the atomic database       
!        xilev   real(nrhdimj)       Fractional level population array  
!        cemab   real(2,nrhdimj)     Recombination emission             
!        opakab  real(nrhdimj)       Opacity                            
!        tauc    real(2,nrhdimj)     Optical depth                      
!        poptol  real(8)               Tolerance for population level    
!        nzone   integer            Pass number through iteration proces
!        status  integer            Returned status code                
!                                                                       
      use globaldata
      implicit none 
!                                                                       
!     Allocation for passed parameters                                  
      real(8) xilev(nnml),rnist(nnml)
      real(8) radin, radout,rdel, t, pres, xcol,xee,xpx,xi 
      real(4) rtmp 
      integer unit,hdunum, nrows, status
      real(8) abel(nl) 
                                                                        
      real(4) rwrk1(nnml),rwrk2(nnml), elev(nnml) 
      integer ntptr(nnml) 
      integer natomic(nnml), mllev(nnml),nupper(nnml) 
      character(10) kion(nnml) 
      character(20) klevt(nnml) 
      integer tfields,varidat 
      character(16) ttype(9),tform(9),tunit(9) 
      integer colnum,frow,felem,hdutype, klel, mlel, jk, ltyp 
      integer lrtyp, lcon, nrdt, nidt, mmlv, mm, lun11, lpril,lpri 
      integer mllel, klion, mlion, jkk, kl, nlsvn, ncsvn
      integer mt2, mlleltp, nnz, nions 
      character(43) extname 
!     Database manipulation quantities                                  
      real(8)  xeltp 
      integer  nkdt 
      real(8) rniss(nd),rnisse(nd)
      integer j,nkdti,np1ki 
      integer nlev 
      integer mm2,mmtmp,kkkl,lk,mlm 
      integer np1i,np1r,np1k,np2
      real(8) eth 
      character(10) kdtmp 
                                                                        
      data tform/'1J','1I','1E','8A','1I','20A','1E','1E','1I'/ 
      data ttype/'index','ion_index','e_excitation','ion',              &
     & 'atomic_number','ion_level','population','lte',                  &
     &  'upper index'/                                                  
      data tunit/' ',' ','eV',' ',' ',' ',' ',' ',' '/ 
!                                                                       
      lpril=lpri 
      varidat=0 
!                                                                       
      status=0 
!                                                                       
!     Move to the last HDU (hdunum) in the file                         
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Moving to end-of-FITS file'               
      call ftmahd(unit,hdunum,hdutype,status) 
      if (status .gt. 0)call printerror(lun11,status) 
!                                                                       
!                                                                       
!     append a new empty extension after the last HDU                   
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Create the new extension'                 
      call ftcrhd(unit,status) 
      if (status .gt. 0)call printerror(lun11,status) 
!                                                                       
!     Extracting data from the Atomic Database here                     
!                                                                       
!                                                                       
!     lpril is flag for printing debug information                      
       nions=0 
      if (lpril.ne.0) then 
        write (lun11,*)'raw data' 
        do j=1,nnml 
          if (xilev(j).gt.1.e-37)                                       &
     &     write (lun11,*)j,xilev(j)                                    
          enddo 
        endif 
!                                                                       
!     initialize line counter                                           
      mmlv=0 
!     First look for element data (jk is element index)                 
      klel=11 
      mlel=derivedpointers%npfirst(klel) 
      jkk=0 
      jk=0 
      do while (mlel.ne.0) 
!                                                                       
!       get element data                                                
       jk=jk+1 
        mt2=mlel-1 
        call drd(ltyp,lrtyp,lcon,                                       &
     &     nrdt,np1r,nidt,np1i,nkdt,np1k,mt2,                           &
     &     0,lun11)                                               
        mllel=masterdata%idat1(np1i+nidt-1) 
        xeltp=masterdata%rdat1(np1r) 
        nnz=masterdata%idat1(np1i) 
        if (lpril.ne.0)                                                 &
     &    write (lun11,*)'element:',jk,mlel,mllel,nnz,                  &
     &    (masterdata%kdat1(np1k-1+mm),mm=1,nkdt),xeltp              
!       ignore if the abundance is small                                
        if (xeltp.lt.1.e-10) then 
            jkk=jkk+nnz 
          else 
!                                                                       
!           now step thru ions (jkk is ion index)                       
            klion=12 
            mlion=derivedpointers%npfirst(klion) 
            jkk=0 
            kl=0 
            do while ((mlion.ne.0).and.(kl.lt.nnz)) 
!                                                                       
              jkk=jkk+1 
!             retrieve ion name from kdati                              
              mlm=mlion-1 
              call drd(ltyp,lrtyp,lcon,                                 &
     &            nrdt,np1r,nidt,np1i,nkdti,np1ki,mlm,                  &
     &            0,lun11)                                        
                                                                        
!             if not accessing the same element, skip to the next elemen
              mlleltp=masterdata%idat1(np1i+nidt-2) 
              if (mlleltp.eq.mllel) then 
!                                                                       
                kl=kl+1 
                if (lpril.ne.0)                                         &
     &              write (lun11,*)'  ion:',kl,jkk,mlion,mlleltp,       &
     &                 (masterdata%kdat1(np1ki-1+mm),mm=1,nkdti)          
!                                                                       
!               get level data                                          
                call func2l(jkk,lpril,lun11,t,xee,xpx,                  &
     &              rniss,rnisse,nlev)
!                                                                       
!               step thru levels                                        
                do mm2=1,nlev 
!                                                                       
!                 get level pointer                                     
                  mmtmp=derivedpointers%npilev(mm2,jkk) 
                  if (mmtmp.ne.0) then 
                    kkkl=mmtmp 
                    mmlv=mmtmp 
!                                                                       
!                   test for level pop                                  
                    if (xilev(kkkl).gt.1.d-34) then 
!                                                                       
!                     get data                                          
                      eth=leveltemp%rlev(1,mm2) 
                      nions=nions+1 
                      mllev(nions)=masterdata%idat1(np1i+nidt-2) 
!                     Note that rwrk1 must be written to the file before
!                     it is overwritten in subsequent columns           
                      rwrk1(nions)=xilev(mmlv) 
                      rwrk2(nions)=rnist(mmlv) 
                      elev(nions)=eth 
                      ntptr(nions)=kkkl 
                      natomic(nions)=nnz 
                      nupper(nions)=mm2 
                      do mm=1,nkdti 
                         write (kdtmp(mm:mm),'(a1)')                     &
     &                         masterdata%kdat1(np1ki-1+mm) 
                        enddo 
                      do mm=nkdti+1,9 
                        write (kdtmp(mm:mm),'(a1)')' ' 
                        enddo 
                      kion(nions)=kdtmp 
                      write(klevt(nions),'(20a1)')                      &
     &                     (leveltemp%klev(mm,mm2),mm=1,20)                    
                      if (lpri.ne.0) then 
                        write (lun11,*)nions,xilev(mmlv),               &
     &                       masterdata%rdat1(np1r),nnz,mmlv,kkkl            
                        write (lun11,9296)kkkl,                         &
     &                      (masterdata%kdat1(np1i-1+mm),mm=1,20),      &
     &                      (leveltemp%klev(lk,mm2),lk=1,20),           &
     &                      eth,xilev(kkkl),rnist(kkkl)
 9296                   format (1x,i6,1x,(40a1),7(1pe13.5)) 
                        endif 
!                                                                       
!                     end of test for level pop                         
                      endif 
!                                                                       
!                   end of test for level pointer                       
                    endif 
!                                                                       
!                 end of step thru levels                               
                  enddo 
!                                                                       
!               end of test for element                                 
                endif 
!                                                                       
!             Go to next ion                                            
              mlion=derivedpointers%npnxt(mlion) 
              enddo 
!                                                                       
!           end of test for abundance                                   
            endif 
!                                                                       
        mlel=derivedpointers%npnxt(mlel) 
!       Go to next element                                              
        enddo 
                                                                        
!                                                                       
                                                                        
!     End of atomic database extraction                                 
!----------------------------------------------------------------       
!     define parameters for the binary table (see the above data stateme
      nrows=nions 
      tfields=9 
!     Build extension name                                              
      extname='XSTAR_RADIAL' 
                                                                        
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Write table headers'                      
!     write the required header parameters for the binary table         
      call ftphbn(unit,nrows,tfields,ttype,tform,tunit,extname,         &
     &              varidat,status)                                     
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Add some more keywords'                   
                                                                        
!     Write some model parameters in the extension header               
      call ftpcom(unit,'***********************************',status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      call ftpcom(unit,'Model Keywords',status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
!     Write values to 3 decimal places                                  
      rtmp=radin 
      call ftpkye(unit,'RINNER',rtmp,3,'[cm] Inner shell radius',       &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      rtmp=radout 
      call ftpkye(unit,'ROUTER',rtmp,3,'[cm] Outer shell radius',       &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      rtmp=rdel 
      call ftpkye(unit,'RDEL',rtmp,3,'[cm] distance from face',         &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      rtmp=t 
      call ftpkye(unit,'TEMPERAT',rtmp,3,'[10**4K] Shell Temperature',  &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      rtmp=pres 
      call ftpkye(unit,'PRESSURE',rtmp,3,'[dynes/cm**2] Shell Pressure',&
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
!                                                                       
      rtmp=xcol 
      call ftpkye(unit,'COLUMN',rtmp,3,'[/cm**2] Column ',              &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      rtmp=xee 
      call ftpkye(unit,'XEE',rtmp,3,'electron fraction',                &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
!                                                                       
      rtmp=xpx 
      call ftpkye(unit,'DENSITY',rtmp,3,'[/cm**3] Density',             &
     & status)                                                          
      if (status .gt. 0)call printerror(lun11,status) 
!                                                                       
      rtmp=xi 
      call ftpkye(unit,'LOGXI',rtmp,3,                                  &
     & '[erg cm/s] log(ionization parameter)',status)                   
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
!-------------------------------------------------------------------    
!     Step through the columns and write them to the file               
!                                                                       
!     set 'global' parameters for writing FITS columns                  
      frow=1 
      felem=1 
                                                                        
!     column  1  (Line number)                                          
      colnum=1 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpclj(unit,colnum,frow,felem,nions,ntptr,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
!     column  2 (Level number of this ion)                              
      colnum=2 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpclj(unit,colnum,frow,felem,nions,mllev,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
!     column  3  (Energy)                                               
      colnum=3 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpcle(unit,colnum,frow,felem,nions,elev,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
                                                                        
!     column  4  (Ion)                                                  
      colnum=4 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpcls(unit,colnum,frow,felem,nions,kion,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
                                                                        
!     column  5  (Atomic Number)                                        
      colnum=5 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpclj(unit,colnum,frow,felem,nions,natomic,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
                                                                        
!     column  6 (Level Designation)                                     
      colnum=6 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpcls(unit,colnum,frow,felem,nions,klevt,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
!----------------------------------------------------------------       
!     column 7 (Level population)                                       
!     rwrk1 can be safely overwritten after this step                   
                                                                        
      colnum=7 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpcle(unit,colnum,frow,felem,nions,rwrk1,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
                                                                        
      colnum=8 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpcle(unit,colnum,frow,felem,nions,rwrk2,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
                                                                        
!     column  9 (upper level index)                                     
      colnum=9 
      if (lpri.ne.0)                                                    &
     & write(lun11,*)'fstepr: Writing Column ',colnum                   
      call ftpclj(unit,colnum,frow,felem,nions,nupper,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
!----------------------------------------------------------------       
!     Compute checksums                                                 
      call ftpcks(unit,status) 
      if (status .gt. 0)call printerror(lun11,status) 
                                                                        
      return 
      end                                           
