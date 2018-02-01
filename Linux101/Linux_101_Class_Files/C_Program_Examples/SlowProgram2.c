

/*  Sample SLOW Running Program  */


#include<stdio.h>
#include<time.h>

main ()
   {
   int i=0;
   FILE *f;
   
   f = fopen("SlowPrint2.txt", "w");
   
   printf("\n");                            /*  PRINT Single Blank Line  */
   for (i=0; i<= 100; i++)
      {   
      //printf("Printing line %i\n", i);      /* Print to SCREEN */ 
      fprintf(f, "Printing line %i\n", i);  /* Print to FILE   */
      fflush(f);
      sleep(1);
      }
   }



