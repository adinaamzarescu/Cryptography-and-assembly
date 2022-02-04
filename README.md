# Cryptography and assembly
### Copyright 2021 Adina-Maria Amzarescu 321CA
This is a project that focuses on the understanding of Assembly, low-level memory
management as well as basic cryptography ideas.

It contains 4 independent programs:
___________________________________________________________________________________________

### Reversed One Time Pad

  The one-time pad is a long sequence of random letters. These letters are combined with
  the plaintext message to produce the ciphertext. In **ROTP** the key is
  reversed.
  
___________________________________________________________________________________________
```   
### Ages
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
   
  There is also a special case, in which a person has already been born, but
  they are only few months/days old. In this case, age will still be stored, but as 0.
___________________________________________________________________________________________
```  
### Columnar Transposition
```
  This program works more with the memory than the other 2.
  
  In a columnar transposition cipher, the message is written in a grid of equal length
  rows, and then read out column by column. The columns are chosen in a scrambled order, 
  decided by the encryption key.
  
  I decided to only use the available registers, without global variables. The program
  has 2 main loops, one for rows and one for columns. It starts by calculating the index
  of the haystack. Then it tests if the index is greater than the max haystack length,
  in which case it will jump to the next row. If the index is lower the encrypted column
  will be stored in **ebx** (ciphertext). 
  
  To store it I chose to use the stack by adding eax and [ebp + 12]. This way the _esi_
  register can be used to count. After the column is stored, I incremented ebx and ecx.
  
  The **move_to_next** label is used to increment the rows and test if the program will
  end.
___________________________________________________________________________________________

```  
### Cache Load Simulation
```
  Basic simulation of how the cache memory works.
  
  When the processor needs a certain RAM adress, it searches in cache first. If the
  adress is there, it will gp to CACHE_HIT which means it can acces it from there
  without interacting with the main memory. This is much faster. 
  If the adress is not already in the cache, this means CACHE_MISS. Now the data
  must me moved from RAM to cache and then transferred to the registers. 
  
  Even if in the case of CACHE_MISS there is a delay, the next time the data 
  will be searched for, it will be faster. 
  
  The structure of the cache of this program:
  
  * A matrix with 100 lines, each having 8 octets
  * char cache [ CACHE_LINES ][ CACHE_LINE_SIZE ]
  * Each line of this matrix has a tag
      * If that line is empty, teh tag is 0
      * The value of the tag = the first 29 bits.
        This happens because the last 3 bits are 0
      * The tag is used to search for data

**Loading**

This algorithm works with reg, tags, cache, teh adress and to_replace.
The *adress* is the octet that has to be moved in reg, *to_replace* is
the index of the line of the cache matrix.

Steps:

* Calculating the tag
* Iterating through the tags of each line. If the line is found,
  the program then calculates the offset. Then that octet will be
  moved to cache
* If the tag was not found, 8 octets must be moved to cache, one
  of them being the one it was seached for. This line has the index to_replace
  
___________________________________________________________________________________________
