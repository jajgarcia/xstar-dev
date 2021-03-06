      subroutine drd(ltyp,lrtyp,lcon,lrdat,np1r,lidat,np1i,lkdat,np1k,  &
     &                 np2,lpri,lun11)                            
!                                                                       
!     this routine reads one element from the database                  
!     author:  T. Kallman                                               
!                                                                       
      use globaldata
      implicit none 
!                                                                       
!                                                                       
!                                                                       
      integer nrd,lcon,ltyp,lrtyp,lrdat,lidat,                          &
     &        lkdat,np2,lpri,lun11,np1,np1r,np1i,np1k
!                                                                       
      if ( lpri.ne.0 ) write (lun11,*) 'in drd, np2=' , np2,            &
     &                                  ntyp                            
!      if ((ltyp.le.0).or.(ltyp.gt.ntyp))                               
!     $    stop 'data typing error'                                     
      nrd = 0 
      lcon=1 
        np2 = np2 + 1 
        nrd = nrd + 1 
        np1 = masterdata%nptrs(1,np2) 
        ltyp = masterdata%nptrs(2,np2) 
        lrdat = masterdata%nptrs(5,np2) 
        lidat = masterdata%nptrs(6,np2) 
        lkdat = masterdata%nptrs(7,np2) 
        lrtyp = masterdata%nptrs(3,np2) 
        lcon = masterdata%nptrs(4,np2) 
        np1r = masterdata%nptrs(8,np2) 
        np1i = masterdata%nptrs(9,np2) 
        np1k = masterdata%nptrs(10,np2) 
        if ( lpri.ne.0 ) write (lun11,*) 'in dread:' , np2 , np1 ,ltyp, &
     &                                 lrtyp , lrdat , lidat            
        if ( lpri.ne.0 ) write (lun11,99001) lkdat , lcon , np1r ,np1i, &
     &                        np1k                                      
      lcon = 0 
      if ( lpri.ne.0 ) write (lun11,*) 'leaving drd' , np2 
!                                                                       
      return 
99001 format (8x,5i8) 
      END                                           
