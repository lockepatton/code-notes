#!/bin/bash
#
# WSW 02/06/2015 Create Script to Check Ports on Certain Machines
#
# PURPOSE:   This Script uses the Unix nc (or netcat) utility to test PORTS
#            on a machine/system.  If a PORT in the list does NOT respond
#            after  "n" tries the system is considered DOWN.  If AFTER being
#            DOWN and we get "n" good responses the system is considered
#            back UP and running.  
#
# PRE-REQS:   nmap, 


# ------------------------------------------------------------------
#  The following Variables can be changed as needed.
#
#    NOTE:  PollIntervalSeconds * MaxErrorCount = time system has to 
#           be down BEFORE Email notification will be sent.
#
# EXAMPLE:  PollIntervalSeconds = 60 (seconds)
#           MaxErrorCount       =  5 (times)
#
#           Email would be sent AFTER (5 * 60) = 300 SECONDS 
# ------------------------------------------------------------------
PollIntervalSeconds=6    # Number of Seconds to Poll Devices, recommend 60 or higher
MaxErrorCount=5          # Sets the number of GOOD or BAD responses before determining if a 
                         # machine is UP or DOWN.
#
# ------------------------------------------------------------------
# Create Array of IP Addresses or DNS Names
# ------------------------------------------------------------------
IPs=()   # Creat Empty Array
IPs+=("www.phys.washington.edu")      # Wilson TEST Server
IPs+=("128.95.237.203")               # Lee's TEST Box



iComputers=${#IPs[@]}
echo ""
echo ""
echo "Program starting up!!"
echo "We have " $iComputers " computers in our Array"
echo ""

# ------------------------------------------------------------------
# Create a LIST of ports to check
#     Add ALL of the ports you want to scan inside PARENTHESIS
#
#     NOTE:  ALL of these PORTS Must be UP otherwise we assume System is DOWN
#            Port   22   - ssh for Linux/Media Devices
#            Port   8009 - some Media Device port?? Not sure what??
#            Port   8080 - HTTP
#      
# ------------------------------------------------------------------
#
PORTS=(22 8009 8080)
#


# Create a LIST to hold Error COUNTS for each IP/Machine Above
ERRORS=()

# Create a LIST to hold GOOD_RESPONSES for each IP/Machine Above
GOOD_RESPONSES=()



# Create a LIST to hold Current STATE of each IP/Machine Above
STATE=()


# Initialize ERRORS and STATE Array
for ((i=0;  i < iComputers;  i++)); do
   ERRORS+=(0)          # Set Device Error Count = 0 
   GOOD_RESPONSES+=(0)  # Set Device Good Count = 0  
   STATE+=("up")        # Assume All Devices are UP
done


# TESTING ONLY!!
#for ((i=0;  i < iComputers;  i++)); do
#   echo "ERRORS [" $i "] = " ${ERRORS[$i]}
#   echo "STATE [" $i "] = " ${STATE[$i]}
#done

#echo "Items in Array " ${IPs[0]}
#echo "Items in Array " ${IPs[1]}


iStartHour=7      # Hour of Day to START Script
iStopHour=20      # Hour of Day to STOP  Script
#   (0=Sun, 1=Mon, 2=Tue, ... 6=Sat)
iStartDay=1       # Day of Week to START Script  
iStopDay=6        # Day of Week to STOP  Script


#sleep 60          # Sleep long enough for Pi to get Network TIME


# ------------------------------------------------------
#  FUNCTION:  Check IP/Port
#         
#      NOTE:  Any 1 (or more) PORTs NOT Responding will
#             count as a single Error   
# ------------------------------------------------------
function CheckPort {
	
    # nc command Checks Status of a Port
    #nc -vz  $1  $2  < /dev/null
    for port in ${PORTS[@]}; do
        echo "   Checking Server " $1 " Port " $port
        nc -z  $1  $port  < /dev/null
        # CHECK Error Code
        if [ $? -ne 0 ] ;
           then
           return 1   # Error Scanning a Port - No need to check all of them
        fi
    done    
	
    return 0   # Passed ALL Checks Things are OK on this server
}



NOW=$(date)
#echo BEFORE While Loop Time:  $NOW


while true  :
   do

   NOW=$(date)

   # Set Current HOUR and DAY.  Note Pi needs a TIME Source (NTP Server)
   iCurrentHour=$(date +"%k")
   iCurrentDay=$(date +"%w")


   if [ $iCurrentHour -ge $iStartHour ] && [ $iCurrentHour -lt $iStopHour ] &&  [ $iCurrentDay -ge $iStartDay ] && [ $iCurrentDay -lt $iStopDay ] ; 
      then

      echo "I'm Here .. Time to Poll my devices.    Hour = " $iCurrentHour
      echo ""

      for ((i=0;  i < iComputers;  i++)); do
         #echo "Checking Array Item:  " $i
         
         CheckPort ${IPs[$i]}
         ReturnValue=$?
         ##echo "ReturnValue=" $ReturnValue
           
         # CHECK Error Code and Current STATE
         if  [ $ReturnValue == 1 ] ;
             then
             ((ERRORS[$i] = ERRORS[$i] + 1))
             ((GOOD_RESPONSES[$i]=0))             
         else
             ((GOOD_RESPONSES[$i] = GOOD_RESPONSES[$i] + 1))
             ((ERRORS[$i]=0))
         fi
         
         #Device is UP, but n Errors in a ROW SEND Email Message, set STATE to down
         if [ ${ERRORS[$i]} == $MaxErrorCount ] &&  [ "${STATE[$i]}"=="up"  ] ;
            then
            echo "Encountered n ERRORS... Set STATE to down.... Send Email"
            STATE[$i]="down"
         fi
         
         #Device is DOWN, but n Good_Messages in a ROW SEND Email Message, set STATE to up
         if [ ${GOOD_RESPONSES[$i]} == $MaxErrorCount ] &&  [ "${STATE[$i]}"=="down"  ] ;
            then
            echo "Encountered n GOOD Statuses... Set STATE to up.... Send Email"
            STATE[$i]="up"
         fi
         
             
         echo ""
         echo  "Errors for Server " ${IPs[$i]} " = " ${ERRORS[$i]} " State = " ${STATE[$i]}
         echo "-----------------------------------------------------------------------------------"
             
             #STATE[$i]="down"    # Set STATE to DOWN and INCREMENT ERROR Counter
             # INCREMENT EROR Counter for Specific Computer
             #echo  "Errors for Server " ${IPs[$i]} " = " ${ERRORS[$i]}
             #["${STATE[$i]}" == "up"  ] 

             # Check to see if Server STATUS=UP and Error Count GOING UP

      done
      

      echo ""      
      echo ""      
      echo "Pausing for a few Seconds"
      sleep $PollIntervalSeconds
      echo ""      
      echo ""      
      
      
    else
       # Not Running NOW
       echo "NOT Running Now, goto Sleep"
       sleep 600 # Sleep for 600 seconds
    fi


done


