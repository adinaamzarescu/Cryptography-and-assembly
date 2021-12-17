# Cryptography and assembly
### Copyright 2021 Adina-Maria Amzarescu 321CA
This is a project that helped me understand more about Assembly and low-level memory
management.

It contains 4 independent programs:
___________________________________________________________________________________________
```
* Reversed One Time Pad
```
  The one-time pad is a long sequence of random letters. These letters are combined with
  the plaintext message to produce the ciphertext. In **ROTP** the key is
  reversed.
  
___________________________________________________________________________________________
```   
* Ages
```
  This program uses a structure to calculate how old each person is.
  
  * In _edx_ is stored the number of people
  * In _esi_ is stored the present day (day month year)
  * In _edi_ are stored the birthdays.
  
  The program starts by substracting *birth year* from the *present year*.
  
  If the birth year is greater, 0 is returned and the program stops.
  Else, if the birth year is lower, it will test for **month**.
  
  Here there are 3 possibilities:
  
  * The birth month is lower than the present month 
      * ==> age = _present year_ - _birth year_
  
  * The birth month is greater than the present month 
      * ==> age = (_present year_ - _birth year_) - 1
   
  * The birth month and the present month are equal
      * ==> another test is necessarily and the program will jump to **day**

  For day there are only 2 possibilities:
  
  * If the birth day is greater, this means there are only a few days untill
    the birthday, so age = (_present year_ - _birth year_) - 1
    
  * If the birth day is less or equal than the present day,
    age = _present year_ - _birth year_
___________________________________________________________________________________________
```  
* ls
```
  This function will list all the directories and then all the files in the
  current directory.
  You can find this function in _list.c_.
  
  * Extra functions: ls_file()  ls_dir()
  
    Those 2 functions are used to list them separately.
___________________________________________________________________________________________
```
* rm
```
   This removes a file. If no file can be found, it will print
   the "Could not find the file" message.
   You can find this function in _remove.c_.
   After removing the file from the list, it will free
   the memory that has been allocated for it.
___________________________________________________________________________________________
```
* rmdir
```
   This removes a directory. If no directory can be found, it will print
   the "Could not find the directory" message.
   You can find this function in _remove.c_.
   After removing the directory from the list, it will free
   the memory that has been allocated for it.
     
   * Extra functions : free_directory()  free_file()
     
        You can find these functions in _free_mem.c_.
        The rmdir command removes the content of the directory
        as well, so in order to free all the memory for the directories
        and the files, the function free_directory will recursively
        delete all the directories and files.
___________________________________________________________________________________________
```
* cd
```

   This changes the current directory in the one with the given name from
   the directory list of the current one. If the name is ".." then the
   directory will become the parent of the current one. 
   You can find this function in _paths.c_.
   Since it will be changes, the function will be called with the adress
   of the target parameter.
___________________________________________________________________________________________
```
* tree
```
   This function will show the content of the current directory in an
   arborescent form. Firstly it will show the directories and after that
   the files.
   You can find this function in _list.c_.
   This is a recursive function so at first level will be 0. Then level
   will be incremented by 1 for every directory found inside. The spacing
   consists of 4 spaces.
___________________________________________________________________________________________
```
* pwd
```
   This function shows the path of the current directory, staring with home.
   After the path is printed, the program will free the memory allocated
   for the string.
    
   * Extra function : find_path()
   
       Since it is a recursive function, find path will create a
       string from the parent to teh current directory by concatenating
       the names, followed by "/". Every path will start with "/home" because
       this is the first directory of the system.
___________________________________________________________________________________________
```
* mv
```
  This function changes the name of the "oldname" file/directory into "newname".
  You can find it in _move.c_.
  This is where the returns for the **_check_existance()_** come into use.
  
   * dir will be used to iterate through all the directories, changed_dir will be the one
    whose name will be changed, prev_dir will be the previous directory(in order to link the
    directories from the list). Same goes for file, changed file and prev_file.
   * checker_new will be used to check if there already is a file/directory with the same
    name already, in which case it will print ("File/Director already exists").
   * checker_old will see if the function will rename a file(returns 1) or a directory
    (returns 2).
    
  First, it will link the **next** of the previous file/directory to the one that succeded
  the changed one. Then it will add the changed one at the end of the list. In order to
  rename it, the memory for its name will be reallocated.
  
___________________________________________________________________________________________
```
* stop
```
  This function stops the program.
  You can find it in _free_mem.c_.
  In main it will be called with the first directory, home.
  Then it will free the memory of all the directories and files in the system.
  After the memory is free, since the loop in main is infinite, this will
  be where the **break** command will be.
  ___________________________________________________________________________________________
  
## Important mentions
  
  * Since I decided to create separate .c file for the functions, i also changed the Makefile.
  * I also added a header file
  * I usually don't use **goto** but I thought i could integrate them in the program because
    they were learned in the second laboratory.
