      subroutine ispec(tp,xlum,epi,ncn2,zremsz,lpri,lun11) 
!                                                                       
!                                                                       
!     this subroutine generates the initial spectrum.                   
!     brems stores the flux to be used                                  
!     author:  T. Kallman                                               
!                                                                       
      use globaldata
      implicit none 
!                                                                       
!                                                                       
      real(8) zremsz(ncn),epi(ncn) 
      integer ncn2,lpri,lun11 
      real(8) zremsi(ncn),ergsev,const,xlum 
      real(8) sum,ekt,tp 
      integer i,numcon,lprisv 
      real(8) expo 
!                                                                       
      data ergsev/1.602197e-12/ 
!                                                                       
      numcon=ncn2 
      ekt=1000.*(0.861707)*tp 
      sum=0. 
      lprisv=lpri 
      if (lpri.ge.1) write (lun11,*)'in ispec',tp,xlum 
      do i=1,numcon 
         zremsi(i)=expo(-epi(i)/ekt) 
         if (lpri.gt.1) write (lun11,*)i,epi(i),zremsi(i) 
         if (.not.((epi(i).lt.13.6).or.(epi(i).gt.1.36e+4)              &
     &        .or.(i.le.1)))                                            &
     &    sum=sum+(zremsi(i)+zremsi(i-1))*(epi(i)-epi(i-1))/2.          
         enddo 
!                                                                       
      const=xlum/sum/ergsev 
      do i=1,numcon 
         zremsz(i)=zremsi(i)*const 
         if (lpri.ge.1)                                                 &
     &        write (lun11,*)i,epi(i),zremsi(i),const,zremsz(i)         
         enddo 
      lpri=lprisv 
!                                                                       
      return 
      end                                           
