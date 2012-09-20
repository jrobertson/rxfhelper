#Introducing the Leetpassword gem

This gem is for people like myself who have trouble remembering their long highly secure password, and need something a little simpler to remember.

    # by default, the characters e, i, and o are replaced 
    #   with their leet equivalanet

    LeetPassword.generate #=> f1sh3agl3
    LeetPassword.generate #=> st3n0p3lmatus
    LeetPassword.generate #=> n1mravus


    # generate a password with a maximum of 8 characters
    LeetPassword.generate(8) #=> p3rus1ng
    LeetPassword.generate(8) #=> vagab0nd
    LeetPassword.generate(8) #=> sulaw3s1


    # generate a password with a maximum of 8 characters and
    #   use a custom leet character map

    LeetPassword.generate(12, {o: '0', a: '4'}) #=> ur0ch0rd
    LeetPassword.generate(12, {o: '0', a: '4'}) #=> s4rc0ph4g4
    LeetPassword.generate(12, {o: '0', a: '4'}) #=> b4udel4ire

## Resources   

* [pezra/random-word ?? GitHub](https://github.com/pezra/random-word)
* [leetpassword](http://rubygems.org/gems/leetpassword)

