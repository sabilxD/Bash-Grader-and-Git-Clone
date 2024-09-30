#!/usr/bin/bash

analyze() {

#This function generates a text based stats of each exams of a given student along with the overall percentile of the student

roll_student=$1

file=main.csv
#checks whether the main.csv file is been made yet or not
if [ -f main.csv ]
then 
    #checks whether the given roll number is present in the main.csv file or not
    if  grep -q "^$roll_student" "$file"
    then 
        python3 script.py student_stats $roll_student
   else
       echo "Enter a valid Roll Number"
       exit 1

   fi
else
   echo "Please run the combine function first,and create a main.csv file"
   exit 1
fi 

}



grade_class() {
   #This function calls the python script fucntion which relatively grades the class based on a guassian distribution of marks
   #It assigns grades on a fixed parameter of relative values which functions of the mean and standard deviation of the marks
   #It generates a file called grades.csv which is ordered in ascending order of grades from AP to FF and a pie chart grades.png whcih shows the distribution of grades.

   
   #checks for the existence of the main.csv file if it exists it goes ahead , else exits 
   if [ -f main.csv ]   
   then
   if [ -f grades.csv ]
   then
   rm grades.csv
   fi

    python3 script.py grade
   else
    echo "Please run the combine function first,and create a main.csv file"
    exit 1
   fi 

}




report_card() {

#This function creates the report card of the student in the form of an html file which shows all the marks of the student in each exam 
#In the form of a website compared agains mean, median , max , min marks of the exam and also the overall performance chart of the student over time in the form of a line chart


#checks for the existence of the main.csv file if it exists it goes ahead , if it is not made it exits
if [ -f main.csv ]
then
    rolll=$1
    file=main.csv
    #checks whether the given roll number is present in the main.csv file or not
    if  grep -q "^$rolll" "$file" 
    then
        python3 script.py report $rolll

    else
    echo "Enter a valid Roll Number"
    exit 1

    fi
else
    echo "Please run the combine function first,and create a main.csv file"
    exit 1

fi

}



visualize() {
   #This function shows the overall marks distribution of the whole class using a bar graph

  #checks for the existence of the main.csv file if it exists it goes ahead , if it is not made it exits
   if [ -f main.csv ]
   then
    python3 script.py visualize
 
   else
    echo "Please run the combine function first,and create a main.csv file"
    
    exit 1


   fi 

}

stats() {

   #This function shows the stats of each exams and their mean , median , std deviation and the total head count of the exam

   #checks for the existence of the main.csv file if it exists it goes ahead , if it is not made it exits
  
   if [ -f main.csv ]
   then
    python3 script.py stats
   else
    echo "Please run the combine function first,and create a main.csv file"
    
    exit 1
   
   fi 
 
}


git_init() {
    #This function initializes a new git repository of the files , it marks a directory as the remote repository for storing the commits,git log and other git functionalitiese
    
    dir=$1
    
    #Throws an error if the directory given is an empty string
    if [ "$dir" == "" ]
    then
    echo "ERROR: give the address of the remote directory"
    exit 1
    fi
    #creates the directory structure if it not already present and stores the address of the remote repository in the .git_init.csv hidden located in the current working directory
    mkdir -p $dir
    touch .git_init.csv
    echo $dir > .git_init.csv
    touch "$dir/.git_log" 
}

git_commit(){
  #Checks whether git_init has been called yet,if yes then proceeds else throws an error
  if [ ! -f .git_init.csv ]
  then
  echo "git_init not initialized yet"
  exit 1
  fi
  #gets the ID,time and message of the commit made and stores it in a data and creates the directory for the commit
  message=${@:1}
  repo=$(cat .git_init.csv)
  hash=$(shuf -i 1000000000000000-9999999999999999 -n 1)
  current_time=$(date)  
  mkdir -p $repo/$hash

    
  #Now we see in which version of files we are in using the number of files present in the current directory
  numm=$( ls *.csv | wc -l )
  #Now if this is a new version of files,that is a new file has been added after the previous commit we store these orginail files in a seperate folder
  if [ ! -d "$repo/original/$numm" ]
  
  then
    #creates a base version of files from where we would be patching the data from
    
    mkdir -p $repo/original/$numm
    
    cp *.csv $repo/original/$numm
    
    #now it stores all the diff-patch files of this commit in the directory of that commit
  
  for file in *.csv
  do
    diff -u $repo/original/$numm/$file ./$file > $repo/$hash/$file.patch
  
  done
  
  else 
  #if this version of files,has been already copied we just create the diff-patch files and store them in the commit directory
  
  for file in *.csv
  do
    diff -u $repo/original/$numm/$file ./$file > $repo/$hash/$file.patch
  done

  fi
  
  
  #Add info of the commit into the git_log
  
  echo "Commit Made At: $current_time"  >> "$repo/.git_log"
  echo  "$message|$hash|$numm" >> "$repo/.git_log"
  echo "" >> "$repo/.git_log"
  
  #If this was the First commit we made , we dont have to show any information on wheter a file has been modified or not
  fff="${repo}/.git_log"
  lines=$(wc -l "$fff" | awk '{print $1}' )
  
  if [ "$lines" -eq 3 ] 
  then
  
  echo "Congrats!,you have made your first commit"
  exit 0
  fi
  
#Now we check whether files have been modified or whether some extra file has been added
folder_current="${repo}/${hash}"

#get the id of the previous commit
hash2=$(tail -n 5 $repo/.git_log | head -n 1 | awk -F'|' '{print $2}')
  folder1="${repo}/${hash2}"
  
#Iterate through the files in the current commits folder and check whether they are any different from the previous commit's files by comparing their patch files itself
for file2 in "$folder_current"/*; do
    file1="${folder1}/${file2##*/}"
    if [[ -f "$file1" ]]; then
        #creates the files by comparing their diff files and re patching them to create original files and then deleting them as they're not needed
        
        #creates the first file to be compared
        num_files2=$(grep  "|$hash" $repo/.git_log | cut -d '|' -f 3)
        file_name2=$(basename "$file2")
        file_name2="${file_name2%.patch}"
        patch -f -s -o "./$file_name2.temp" "$repo/original/$num_files2/$file_name2" "$repo/$hash/$file_name2.patch" 
    
        #creates the second file to be compared
        num_files1=$(grep  "|$hash2" $repo/.git_log | cut -d '|' -f 3)
        file_name1=$(basename "$file1")
        file_name1="${file_name1%.patch}"
        
        patch -f -s -o "./$file_name1.tempp" "$repo/original/$num_files1/$file_name1" "$repo/$hash2/$file_name1.patch" 
        
        if cmp -s "$file_name1.tempp" "$file_name2.temp" ; then
        :
        else
    
    # Remove .patch extension and print whether a new file has been added or modified
    file_name="${file2%.patch}"  
    echo "$(basename "$file_name")" ": This file has been modified"

        fi
    
    #delete the temnporarily created files after comparing both of them
    rm "$file_name2.temp" "$file_name1.tempp"
    else
    file_name="${file2%.patch}"  

        echo "$(basename "$file_name")" ": This is a new file"
    fi
done

  
}

git_checkout_m() { 
  # Here we extract the commit_id by searching it through the message given to us in git_checkout -m and call the git_checkout function through the extracted id

  #normal flag checks for git initialization
  if [ ! -f .git_init.csv ]
  then
  
  echo "git_init not initialized yet"
  exit 1
  
  fi
    
    #gets the comment message, ie takes all the arguments from the 1st position
    
    message=${@:1}
    repo=$(cat .git_init.csv)
    
    #searched through the git_log file using an awk line by matching messages and getting the corresponding id
    
    idd=$(awk -F '|' -v message="$message" '$1 == message { id = $2 } END { print id }' ${repo}/.git_log)
    
    #if the given message doesn't match with any ID throws an error
    if [ "$idd" == "" ]
    then
    
    echo "The given message doesn't match any commit ;("
    exit 1
    
    else
    
    #if it does match it calls the git_checkout function with the extracted ID
    git_checkout $idd
    
    fi

}

git_checkout() {
  
  # this function implements the git checkout functionality to our code using very efficient diff-patch mechanism 
  # what it does is that it doesnt stories each version of files in every commit but only stores the differences that were made with respect to the intial commit in all the files
  # and when we want to revert it just patches the initial files with the stored diff files of each commit in their respective commit folders
  # The commit id may not be provided exactly but only the prefix of the commit id provided works, if the prefix matches multiple ids it throws an error 
  


  #normal flag checks for git initialization
  if [ ! -f .git_init.csv ]
  then
  
  echo "git_init not initialized yet"
  exit 1
  
  fi
    #gets the id throug which the function was called
    
    id=$1
    #gets the location of the remote repository which is stored in the .git_init.csv file in the current repositiory
    
    repo=$(cat .git_init.csv)

    #this is used to check whether the prefix given matches multiple/any commit IDs in the git log file
    line=$(grep "|$id" $repo/.git_log | wc -l )    
    #if it matches multiple IDs it throws an error
    if [ "$line" -gt 1 ]
    then
    
        echo "ERROR: The given prefix matches multiple lines"
        exit 1
        
    #if it matches only one ID it proceeds normaly and doesn't throw any error and proceeds to get the diff files and patch them to get the then version of files   
    
    elif [ "$line" -eq 1 ]
    then
    
        id=$(grep  "|$id" $repo/.git_log | cut -d '|' -f 2)
        num_files=$(grep  "|$id" $repo/.git_log | cut -d '|' -f 3)

    elif [ "$line" -eq 0 ]
    then
        echo "ERROR: The given prefix matches no commit id"
    exit 1
    
    fi
    #now to implement our git_checkout we delete the files in our directory,and patch the difference files stored in that commit's directory and store the new versions in our current directory
    rm -f *.csv
    
    for files in $repo/original/$num_files/*
    do
    
        file_name=$(basename "$files")
        patch -f -s -o "./$file_name" "$files" "$repo/$id/$file_name.patch" 
    
    done
}








get_students() { 
    declare -A students

# Iterate over each CSV file in the array
for files in "${exam_files[@]}"; do
        # Read each line in the CSV file
        while IFS=, read -r roll_number name _; do
        #converts lower case letter to upper-case to ensure uniformity
        roll_number=$(echo "$roll_number" | tr '[:lower:]' '[:upper:]')
        if [[ "$name" == "Name" ]]; then
            continue
        fi
            # Check if the roll number is already present in the associative array
             # The -z option checks whether the value associated with the roll number is empty or not
            if [ -z "${students[$roll_number]}" ]; then
                # Add the roll number and name to the associative array
                students[$roll_number]=$name
            fi
        done <  $files
done
#Iterating through the keys of the associative array
for roll_number in "${!students[@]}"; do
    echo "$roll_number,${students[$roll_number]}" >> main.csv
done


}

fill_marks() {
   
    for exam_file in "${exam_files[@]}"; do

    # check if the exam file exists
        # extract the exam name from the file name (assuming the file format is examname.csv)
        exam_name="${exam_file%.csv}"

        # get the column index of the current exam in main.csv
        col_index=$(awk -F',' -v exam_name="$exam_name" 'NR==1 { for (i=1; i<=NF; i++) if ($i == exam_name) { print i; break } }' main.csv)
        # echo $col_index
        # iterate through each line in the exam file
        while IFS=',' read -r roll_number name marks; do
        #converts lower case letter to upper-case to ensure uniformity
        roll_number=$(echo "$roll_number" | tr '[:lower:]' '[:upper:]')
            # Skip the header line
            if [[ "$name" == "Name" ]]; then
                continue
            fi

        # Search for the student in main.csv and update their marks for the exam under given exam's column
        
        sed -i -E "/^$roll_number/s/^(([^,]*,){$((col_index - 1))})([^,]*)/\1$marks/" main.csv

        done < "$exam_file"
        done
}




combine() {

#checks whether the main.csv presesnt and whether it has the total column in it is already present
#If it has a total column already done then after we combine we run the total command again so to get,
#the total column back in the main.csv file

if [ -f main.csv ]; then

#detect whether the total has been done or not
total_done=$(awk -F "," ' NR==1 { var = $NF ; if ( var == "total" ){ print "true" } else{ print "false" } }' main.csv)


#delete the original main.csv as we are making a new one from scratch
rm main.csv

fi

#just in case remove any carriage return character if they're present,to prevent any annoying errors
for file in *.csv
do
cat $file | sed 's/\r//g' > temp.csv && mv temp.csv $file
done

# Get CSV file names using ls and grep into the array exam_files
exam_files=()

while IFS= read -r file 
do  
    #IF grades.csv is present in the directory ignore the file as it is not included in the main.csv file
    if [ $file == "grades.csv" ]
    then
        continue
    else 
        exam_files+=("$file")
    fi
done < <(ls | grep -E ".csv")

 
#Adding the header to the main.csv file
echo -n "Roll_Number,Name" >> main.csv

for file in ${exam_files[@]} ;

do 
    #remove the extension(.csv) from the file names stored in the array 
    name_without_extension="${file%.csv}"   
    echo -n ",$name_without_extension" >> main.csv 
done

echo "" >> main.csv

#add the roll_number and name of each from all the .csv files present into the main.csv
get_students

#intialize the csv file with all absents , we will add the marks later as we iterate through the files again

num_exams=${#exam_files[@]}

awk -v num_exams="$num_exams" -F',' 'BEGIN {OFS=","} {if (NR == 1) print; else {printf "%s,%s", $1, $2; for (i=0; i<num_exams; i++) printf ",a" ; printf "\n"}}' main.csv > temp.csv && mv temp.csv main.csv

#now We will be filling the marks of the students by calling the fucntion fill marks 
fill_marks

#IF there was a field called total in the previously made main.csv we know add the total field back
if [ "$total_done" == "true" ]
then
total
fi


}




upload() {

    #this function simply uploads/copies an exam.csv file into our current working directory 

    file=$1
    name=$(basename "$file")
    
    #check whether a file with the same name already exists in the current directory,if yes then exits 
    for examss in *.csv
    do
    if [ "$name" == "$examss" ]
    then
    echo "An exam file with the same name already exists, hence it can't be added."
    exit 1
    fi
    done
    
    if [ -f "$file" ]
    then 
    cp "$file" .
    echo "$name has been uploaded succesfully!"
    else
    echo "The given file doesn't exist."
    exit 1
    fi 

}





  
total() {
#this function calculates the total marks and add a new column to main.csv with a header

#add a flag here so that if the total field is already present to give a prompt


#checks for the existence of the main.csv file if it exists it goes ahead , else exits 
if [ -f main.csv ]
then
total_done=$(awk -F "," ' NR==1 { var = $NF ; if ( var == "total" ){ print "true" } else{ print "false" } }' main.csv)

if [ "$total_done" == "false" ]
then

#the awk script which calculates the total marks obtained by a student in the exam and adds it under the total column field in the main.csv

awk -F',' 'BEGIN { OFS = "," } NR == 1 { print $0, "total"; next } { total = 0; for (i = 3; i <= NF; i++) {  total += $i }
            print $0, total }'< <(cat  main.csv | sed 's/\r//g') > temp.csv && mv temp.csv main.csv
fi

else

echo "ERROR: Combine all the files and create a main.csv first before running total."
exit 1

fi


}


update() { 
    
    #this function updates the marks of a student in a particular exam and updates the marks for the student in the particular exam as well as in the main.csv file 
    
    
    #reads in the roll number and the exam name for which the marks have to be updated for the student
    read -p "roll no: " roll
    read -p "name: " name    
    read -p "exam_name: " exam_name
    
    
    #flag to check whether the given exam name's .csv file is present or not in the current working directory
    if [ -f ${exam_name}.csv ]
    then 
       
        #to check whether the given roll number was present in the gicen exam or not
        found=$( grep -i -E "^$roll," ${exam_name}.csv | wc -l )
        found_name_roll=$( grep -i -E "^$roll,$name," ${exam_name}.csv | wc -l )

    
    #if student is found then updates their marks else throws an error
    if [ $found -gt 0 ]
    then
     if [ $found_name_roll -gt 0 ]
     then
        read -p "updated marks: " marks
    else
    echo "The given name and roll number don't match"
    exit 1
     fi 
    else
        echo "The given student wasn't present in the exam,marks cant be updated"
        exit 1
    fi
    else
        echo "Given exam not done yet"
        exit 1

    fi   
    
    #if there exists a main.csv already present we also update the marks of the student in that exam in the main.csv,else we only update the marks in the given exams's file
    if [ -f main.csv ]
    then  
        
        #get the col number of that given exam so we can simply just substitute the updated marks in place of the old marks
        col_index=$(awk -F',' -v exam_name="$exam_name" 'NR==1 { for (i=1; i<=NF; i++) if ($i == exam_name) { print i; break } }' main.csv)
        
        sed -i -E " s/^($roll),(([^,]*,){$((col_index - 2))})([^,]*)/\1,\2"$marks"/gI" main.csv
    
    fi
        sed -i -E   " s/^($roll),(([^,]*,){1})([^,]*)/\1,\2"$marks"/gI" "${exam_name}.csv"

    
        #ask if the user wants to change more marks of students if yes then call the function again else let it combine total
        read -p "do you want to update more marks (yes/no): " continue
    if [ "$continue" == "yes" ]; then
        update
    fi
    
    #we again combine to get a fresh main.csv with the updated marks and total of all the students whose marks have been updated
    if [ -f main.csv ] 
    then
    combine    
    fi
    
}


welcome() {
  cat << "EOF"

 __          ________ _                          
 \ \        / /  ____| |                         
  \ \  /\  / /| |__  | | ___ ___  _ __ ___   ___ 
   \ \/  \/ / |  __| | |/ __/ _ \| '_ ` _ \ / _ \
    \  /\  /  | |____| | (_| (_) | | | | | |  __/
     \/  \/   |______|_|\___\___/|_| |_| |_|\___|
                                                 
                                                 
EOF
 echo "Let's know a little about the functionalities of our script before starting to execute it"
 echo ""

 echo "1.Combine"
 echo "Creates a main.csv which is a data base of the marks of all the students obtained by iterating through all the exam's files in the directory."
 echo ""

 echo "2.Total"
 echo "Does the totalling of all the marks in main.csv and adds the total column to it." 
 echo ""

 echo "3.Upload"
 echo "Used to add a new exam file if say a new exam happened and we would like to add it."
 echo ""

 echo "4.Update"
 echo "If some students mark's have to be changed it updates their marks for the respective exams for which marks have to be changed and in the main.csv."
 echo ""

 echo "5.Git Init"
 echo "Basic git functionaliy intitialized a git repository for the current working directory."
 echo ""

 echo "6.Git Commit"
 echo "Commits the Current version of files to the remote repository in the form of their diff-files with respect to the previos commit,also shows the files which have been added or modified with respect to the previos commit."
 echo ""

 echo "7.Git Checkout"
 echo "Checks out to a particular commit using it's message with the -m flag or theough the provided prefix numbers of the commit."
 echo ""

 echo "8.Git Log"
 echo "Additional Functionality to show the Git log file which contains all the information about the commits along with their messages and changes along withh the Date and Time."
 echo ""

 echo "9.Stats"
 echo "Additional Functionality to show the stats of the complete class for all the exams with additional option to generate a bar graph showing visual distribution of marks."
 echo ""

 echo "10.Grade"
 echo "Additional Functionality to Grade the realatively grade the whole class based on a guassian distribution and generate a grades.csv with grades in ascending order from AP to FF , also generates a grades.png to show grade distribution."
 echo ""

 echo "11.Analyze"
 echo "Additionl Functionality to analyze a particular student's performance in each exam and to calculate the overall percentile in the class of the student based on his total marks."
 echo ""

 echo "12.Generate Report Card"
 echo "Additional Functionality to generate a report card of a student in a .html file comparing student's marks in each exam with various stats in a table and showing the performance line chart of the student over time."
 echo ""

    





} 





function=$1



if [ "$function" == "welcome" ]
then

welcome

fi



if [ "$function" == "combine" ]
then

combine

fi



if [ "$function" == "total" ]
then 

total 

fi


if [ "$function" == "upload" ]
then 

upload $2

fi




if [ "$function" == "update" ]
then 
update

fi


if [ "$function" == "git_init" ]
then 
git_init $2

fi




if [ "$function" == "git_commit" ]
then 

git_commit ${@:3}

fi




if [ "$function" == "git_checkout" ]
then 

if [ "$2" == "-m" ]
then
#takes the comand line arguement from the third element onwards , so that we can cover the whole message
git_checkout_m ${@:3} 
else
git_checkout $2 
fi

fi




if [ "$function" == "git_log" ]
then
if [ -f .git_init.csv ]

then

echo "Here's your Git log file :) "

echo ""

repo=$(cat .git_init.csv)

cat $repo/.git_log

else

echo "Git not initialized yet , please run the command git init to view the git log"

fi
fi





if [ "$function" == "stats" ]

then

stats

echo -n "Do you want to visualize the stats(yes/no)? "

read vis

if [ "$vis" == "yes" ]
then

visualize

fi
fi



if [ "$function" == "grade" ]
then 

grade_class

fi


if [ "$function" == "analyze" ] 
then
roll=$(echo "$2" | tr '[:lower:]' '[:upper:]')
analyze $roll

fi


if [ "$function" == "report_card" ]
then 
roll=$(echo "$2" | tr '[:lower:]' '[:upper:]')
report_card $roll

fi