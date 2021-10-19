# noForth version of a circular buffer

Barebone circular buffer example for noForth, this version runs fine on systems with separated Flash & RAM memory.
Note that, before the contents are valid the buffer must be filled completely!  

![CB2](https://user-images.githubusercontent.com/11397265/125295098-2f317e80-e325-11eb-9801-3cb88c6810fc.jpg)

| Name | Other data structures |  
| ------------------- | ---------- |  
| `PTR`   | Pointer to oldest data |  
| `#SIZE` | Constant with length of buffer |  
  
The example file contains three examples; Byte wide, char wide & cell wide buffers. Replace `VALUE` by `VARIABLE` when you test it on systems without a noForth style `VALUE`, also `TO PTR` must be replaced by `PTR !` and `PTR` by `PTR @`.
