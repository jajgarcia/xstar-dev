       subroutine calt67(temp,np1r,gamma) 
!                                                                       
!   Takes coefficients in data type 67 and returns effective collision  
!    strenghts for He-like ions according to Keenan, McCann, & Kingston 
!    (1987) eq. (2)                                                     
!      author: M. Bautista                                              
!                                                                       
      use globaldata
       implicit none 
!                                                                       
!                                                                       
       real(8) gamma,temp,tp 
       integer np1r 
!                                                                       
       tp=log10(temp) 
       gamma=masterdata%rdat1(np1r-1+1)+masterdata%rdat1(np1r-1+2)*tp   &
     &       +masterdata%rdat1(np1r-1+3)*tp*tp 
!                                                                       
       return 
      END                                           
