# The Mathematics of CRC

The idea of validating messages using cyclic redundancy checks (CRCs) goes back to an invention of W. Wesley Petersen in 1961[^1].   
It is based on cyclic codes which themselves are based on polynomial ring arithmetic. Let's see what this is all about.

## Polynomials and their arithmetic

Mathematians define entities with operations on them and then study the general properties of the resulting structures. For example, they do this extensively with natural numbers in number theory where the existence of prime numbers and the representation of any number as a unique product of prime numbers is an important result that has applications e.g. in todays cryptography. Among the structures mathematians study are *fields*, *groups* and *rings*. Here we will look at rings.

Rings are general structures of entities along with two operations called *addition* and *multiplication* that have to satisfy certain laws such as associativity of operation or the existence of inverse elements. A ring is called commutative if your can exchange the order of operands for the addition and still gain the same result.  
Based on theses laws mathematicians deduce additional common properties.
All rings dispite their elements share these common properties. 

There are rings with infinite many members such as the ring of integers.

There are also rings with a finite number of members. If you take a number n you can consider all numbers that have the same remainder divided by n to be equivalent. This leads to quotient rings having the elements 0 to n-1. Addition and multiplication wrap around `mod p`.  
If n is a prime number the rings have additional beneficial properties. They are fields and there is always a unique factorization of any ring member into prime factors. On important prime quotient ring is W<sub>2</sub> = { 0, 1 } that is suitable to represent single bits. 

Computer scientists are interested in rings that have 2^n (for some n, e.g. 16 or 32) elements as typical computer memory cells hold n bits.

Quotient rings based on *polynomials* indeed have 2^n members and are thus good for giving memory cells a mathematical interpretion and making use of their mathematical properties. Again polynomial rings with "prime" polynomials, so called *irreducible* polynoms, have the unique factorization property.

So let's look at polynomials. We will concentrate on a special kind of polynomials that is well suited for our application area.

A polynomial is an entity with the following definition:

### Polynomials

Assume we have a single symbol `x` a so called *generator variable*.  
Assume we have a set of coefficients `C` which itself is a commutative ring with appropriate addition and multiplication. For our purpose assume that C is the quotient ring W<sub>2</sub> based on the prime `2` with the members `0` and `1`. 

A polynomial over W<sub>2</sub> with generator `x` has the form:

a<sub>n</sub>x^n + a<sub>n-1</sub>x<sup>n-1</sup> + … + a<sub>1</sub>x + a<sub>0</sub>

where a<sub>i</sub> ∈ W<sub>2</sub> so can only be `0` or `1`.

The *degree* of the polynomial is the exponent i of the largest x^i with a non zero coefficient a<sub>i</sub>.

The set of polynomials over W<sub>2</sub> with generator `x` is infinite.

Note that different from high school the variable `x` never gets a value when we think of polynomials this way. We're not interested in evaluating polynomials but only in their properties as entities. We use them as self contained atomic elements, as values of their own for computation.


### Polynomial Multipication and Division

We can add and multiply polynomials and similar to integers we can think of division of polynomials.

As an example let's add (x^2 + 1) and (x^2). With integer coefficients this would lead to 2x^2 + 1 but as our coefficients are from W<sub>2</sub> the calculation 1 + 1 equals 0 and so (x^2 + 1) + (x^2) = 1.

We can multiply (x^2 + 1) by (x^2) and get x^4+x^2. And we can divide (x^4+x^2) by (x^2 + 1) giving x^2.

Similar to prime numbers some polynomials cannot be expressed as a product of two other polynomials. For example there are no proper factors for x^2 + x + 1. Such polymials are called *irreducible*. (Note that x^2+1 is not irreducible over W<sub>2</sub> as (x+1) * (x+1) = x^2 + x + x + 1 = x^2 + 1 with coefficients from W<sub>2</sub>).

If you divide polynomials you get - similar to the notion of remainders in integer division - *remainder polynomials*. 

### Polynomial Quotient Rings with respect to an Irreducible Polynomial

If we take an irreducible polynomial `p` and we look at the quotient ring R<sub>p</sub> with respect to `p` then this ring has all the polynomial remainders of `p` as its members. If `p` is of degree n then R<sub>p</sub> has 2^n members.
`p` is called the *generator polynomial*.

Every larger polynomial can be mapped into one of the polynomials in R<sub>p</sub> by dividing it by `p` and determining its remainder.

## Cyclic Redundancy Check

The idea of a cyclic redundancy check is to consider the message to be checked as a huge polynomial over W<sub>2</sub> and divide it by the generator polynomial p. As the coefficients are from W<sub>2</sub> each bit of the message can represent one coefficient. 
The resulting remainder, the CRC value, (a polynomial represented as a sequence of degree(p) bits) is appended to the message. The receiver can re-calculate the remainder and compare it with the supplied one. If they differ, then the sent and the received message are not identical.

## Implementating CRC

Implementations differ in the way they consider the message to be a large polynomial. They also differ in their generator polynomial.

As an example let's consider CRC-16-CCITT that uses the generator polynomial

x<sup>16</sup> + x<sup>12</sup> + x<sup>5</sup> + 1

Assuming the first coefficient is always 1 this polynomial can be represented as the combination of the 16 bits

    (1) 0001 0000 0010 0001 = $1021
    16  1  1 1 98 7654 3210
        5  2 1

Similar to paper and pencil division with numbers we divide by the generator polynomial by subtraction according to place. As the coefficients are from W<sub>2</sub> adding and subtracting can be implemented by the bit-wise-`xor`-operation.

The bits of the message are inspected one after the other and if possible the generator polynomial is subtracted at the inspected position. 

At the end of this procedure we gain the remainder of the division by the generator polynomial encoded as a 16-bit-number.

*DISCUSS THE CONCRETE ALGORITHM AND THE EXAMPLE CALCULATION*


[^1]: W. W. Peterson: Cyclic Codes for Error Detection. In: Proceedings of the IRE, Vol. 49, No. 1, 1961, S. 228–235


uh 2022-05-16


