/*  Sample SLOW Running Program  */

#include<stdio.h>
#include<time.h>

main ()
   {
   int i=0;    // Declare/Initialize Variable 
   FILE *f;    // File Handle for Writing 
   
   f = fopen("SlowWriting.txt", "w");  // Open File for WRITING
   
   for (i=1; i<= 100; i++)
      {
      fprintf(f, "Printing line %i\n", i);   // Print to FILE  
      fflush(f);   // Commit WRITES to file
      sleep(1);    // Sleep for 1 Second
      }
   }
   
/*  END of SLOW Running Program  */

