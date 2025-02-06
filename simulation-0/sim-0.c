/* Implementation of a 32-bit adder in C. */

#include "sim1.h"

void execute_add(Sim1Data *obj)
{
    int result = 0;
    int carry = obj->isSubtraction; 
    
    obj->aNonNeg = !(obj->a & (1 << 31));
    obj->bNonNeg = !(obj->b & (1 << 31));

    for (int i = 0; i < 32; i++)
    {
        int bitA = (obj->a >> i) & 1;
        int bitB = (obj->b >> i) & 1;
        
        // Negate if subtracting
        if (obj->isSubtraction)
            bitB = !bitB;
            
        // Calculate current bit and next carry
        int sumBit = bitA ^ bitB ^ carry;
        int newCarry = (bitA & bitB) | (carry & (bitA ^ bitB));
        
        // Set current bit in result
        result |= (sumBit << i);
        
        carry = newCarry;
    }
    
    obj->sum = result;
    obj->carryOut = carry;
    obj->sumNonNeg = !(result & (1 << 31));
    
    // Overflow if the result sign differs
    int signA = (obj->a >> 31) & 1;
    int signB = obj->isSubtraction ? !((obj->b >> 31) & 1) : ((obj->b >> 31) & 1);
    int signResult = (result >> 31) & 1;
    obj->overflow = (signA == signB) && (signA != signResult);
}
