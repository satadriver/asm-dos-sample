  ; ===========================================
  ; mcd32.inc copyright MASM32 1998 - 2005
  ; ===========================================

IFNDEF MCD32_INC
MCD32_INC equ <1>

MCDAddState PROTO :DWORD,:DWORD,:DWORD
MCDAddStateStruct PROTO :DWORD,:DWORD,:DWORD,:DWORD
MCDAlloc PROTO :DWORD,:DWORD,:DWORD,:DWORD
MCDAllocBuffers PROTO :DWORD,:DWORD
MCDBeginState PROTO :DWORD,:DWORD
MCDBindContext PROTO :DWORD,:DWORD,:DWORD
MCDClear PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDCopyPixels PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDCreateContext PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDCreateTexture PROTO :DWORD,:DWORD,:DWORD,:DWORD
MCDDeleteContext PROTO :DWORD
MCDDeleteTexture PROTO :DWORD,:DWORD
MCDDescribeLayerPlane PROTO :DWORD,:DWORD,:DWORD,:DWORD
MCDDescribeMcdLayerPlane PROTO :DWORD,:DWORD,:DWORD,:DWORD
MCDDescribeMcdPixelFormat PROTO :DWORD,:DWORD,:DWORD
MCDDescribePixelFormat PROTO :DWORD,:DWORD,:DWORD
MCDDestroyWindow PROTO :DWORD,:DWORD
MCDDrawPixels PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDFlushState PROTO :DWORD
MCDFree PROTO :DWORD,:DWORD
MCDGetBuffers PROTO :DWORD,:DWORD
MCDGetDriverInfo PROTO :DWORD,:DWORD
MCDGetTextureFormats PROTO :DWORD,:DWORD,:DWORD
MCDLock PROTO :DWORD
MCDPixelMap PROTO :DWORD,:DWORD,:DWORD,:DWORD
MCDProcessBatch2 PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDProcessBatch PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDQueryMemStatus PROTO :DWORD
MCDReadPixels PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDReadSpan PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDSetLayerPalette PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDSetScissorRect PROTO :DWORD,:DWORD,:DWORD
MCDSetViewport PROTO :DWORD,:DWORD,:DWORD
MCDSwap PROTO :DWORD,:DWORD
MCDSwapMultiple PROTO :DWORD,:DWORD,:DWORD
MCDSync PROTO :DWORD
MCDTextureKey PROTO :DWORD,:DWORD
MCDTextureStatus PROTO :DWORD,:DWORD
MCDUnlock PROTO :DWORD
MCDUpdateSubTexture PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDUpdateTexturePalette PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MCDUpdateTexturePriority PROTO :DWORD,:DWORD,:DWORD
MCDUpdateTextureState PROTO :DWORD,:DWORD,:DWORD
MCDWriteSpan PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

ELSE
echo -----------------------------------------
echo WARNING Duplicate include file mcd32.inc
echo -----------------------------------------
ENDIF