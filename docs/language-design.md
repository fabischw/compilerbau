# Language Specification: 
name: "think"
file extension: ".think"


# Code Example

**! OUTDATED !**

```


int a = 7
float x = 2.3
bool flag = True
str mystring = "hello world"

char letter = 'k'

const float pi = 3.1415


# comment

int add = 5 + 4
float mult = pi * 5
float div = pi / 2
float exp = 5^2
int mod = 10 % 2

int compound = (5 + 7) * 4 * 8


bool logic = (True || False) && flag && !flag

if (flag) {
    a = a + 7
} elif (logic) {
    a = a + 8
} else {
    print(mystring)
}

while (a > 0) {
    print(int(a))   # typecast necessary here, no implicit type casts
    if (a > 10) { break }
    elif (a > 20) { continue }
    a--
}

# arrays
int[10] prims = [3, 5, 7]
prims[3] = 11


# standard library

print("string")
error("error name")
input("query string")

int(any)
float(any)
str(any)
char(any)
bool(any)


# Multiple statements per line
print("first"); print("second")


# function definition (optional)

int addition(int a, int b) {
    return a + b
}

```

- manual type casting is mandatory

# Ideas
- optional ";"
- "+=" and "++"