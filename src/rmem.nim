# ****************************************************************************************
#
#  rmem v1.0 - memory pool and objects pool - nim version
#
#  DESCRIPTION:
#      A quick, efficient, and minimal free list and arena-based allocator
#
#  POURPOSE:
#      - A quicker, efficient memory allocator alternative to 'malloc()' and friends.
#      - Reduce the possibilities of memory leaks for beginner developers using raylib.
#      - Being able to flexibly range check memory if necessary.
#
# The MemPool implementation is built upon the O(1) heap, inspired by Pavel Kirienko's work
# available on GitHub (https://github.com/pavel-kirienko/o1heap). This dependency is licensed
# under the permissive MIT license, Copyright (c) 2020 Pavel Kirienko.
#
# Copyright (c) 2024 Antonis (planetis-m) Geralis
#
# ****************************************************************************************

runnableExamples:
  # Example 1: MemPool

  var buffer {.align(sizeof(int)).}: array[1024, byte] # variable buffer is aligned
  # Create a memory pool with 1024 bytes
  var mp = createMemPool(buffer)
  # Allocate memory
  let ptr1 = mp.alloc(100)
  let ptr2 = mp.alloc(200)
  # Check free memory
  echo "Free memory: ", mp.getFreeMemory()
  # Reallocate
  let ptr3 = mp.realloc(ptr1, 150)
  # Free memory
  mp.free(ptr2)
  echo "Free memory after free: ", mp.getFreeMemory()

  # Example 2: ObjPool
  type
    MyObject = object
      x, y: int
      data: array[20, char]

  # Create an object pool
  var op = createObjPool[MyObject](buffer)
  # Reset the pool
  var objects: array[5, ptr MyObject]
  for i in 0..4:
    objects[i] = op.alloc()
    objects[i].x = i
    objects[i].y = i * 2
  # Free some objects
  op.free(objects[1])
  op.free(objects[3])
  let newObj = op.alloc() # Reuses a slot, preventing fragmentation
  echo "Allocated a new object, x = ", newObj.x # Memory is cleared

  # Example 3: BiStack

  # Create a BiStack with 1024 bytes
  var bs = createBiStack(buffer)
  # Choose between front and back allocations based on the lifetimes and
  # usage patterns of your data.
  let front1 = cast[ptr int](bs.allocFront(sizeof(int)))
  let back1 = cast[ptr int](bs.allocBack(sizeof(int)))
  front1[] = 10
  back1[] = 20
  # Check that the back portion doesn't collide with the front
  echo "Margins: ", bs.margins()
  # A number of 0 or less means that one of the portions has reached the other
  # and a reset is necessary.
  bs.resetFront()
  echo "Margins after front reset: ", bs.margins()
  # Reset all
  bs.resetAll()

from std/bitops import countLeadingZeroBits

proc log2Floor(x: int): int {.inline.} =
  # Undefined for zero argument
  result = sizeof(int)*8 - 1 - countLeadingZeroBits(x)

proc log2Ceil(x: int): int {.inline.} =
  # Special case: if the argument is zero, returns zero.
  if x <= 1:
    result = 0
  else:
    result = sizeof(int)*8 - countLeadingZeroBits(x - 1)

proc pow2(power: int): int {.inline.} =
  # Raise 2 into the specified power.
  result = 1 shl power

proc nextPowerOfTwo(x: int): int {.inline.} =
  # This is equivalent to pow2(log2Ceil(x)).
  result = pow2(log2Ceil(x))

proc alignUp(n: uint, align: int): uint {.inline.} =
  (n + align.uint - 1) and not (align.uint - 1)

proc alignUp(p: pointer, align: int): pointer {.inline.} =
  cast[pointer](alignUp(cast[uint](p), align))

proc alignDown(n: uint, align: int): uint {.inline.} =
  result = n and not (align.uint - 1)

const
  MaxBins = when sizeof(int) > 2: 32 else: 20 # should've been 36 for i386
  MemAlign = sizeof(pointer) * 4 # isPowerOfTwo
  MinChunkSize = MemAlign * 2 # isPowerOfTwo
  MaxChunkSize = high(int) shr 1 + 1 # isPowerOfTwo

type
  Chunk = object
    header: ChunkHeader
    nextFree: ptr Chunk
    prevFree: ptr Chunk

  ChunkHeader = object
    next: ptr Chunk
    prev: ptr Chunk
    size: int
    used: bool

  MemPool* = object
    bins: array[MaxBins, ptr Chunk]
    nonEmptyBinMask: uint
    capacity, occupied: int

proc interlink(left, right: ptr Chunk) =
  ## Links two blocks so that their next/prev pointers point to each other; left goes before right.
  if left != nil:
    left.header.next = right
  if right != nil:
    right.header.prev = left

proc rebin(x: var MemPool, b: ptr Chunk) =
  ## Adds a new block into the appropriate bin and updates the lookup mask.
  let idx = log2Floor(b.header.size div MinChunkSize)
  # Add the new block to the beginning of the bin list
  b.nextFree = x.bins[idx]
  b.prevFree = nil
  if x.bins[idx] != nil:
    x.bins[idx].prevFree = b
  x.bins[idx] = b
  x.nonEmptyBinMask = x.nonEmptyBinMask or pow2(idx).uint

proc unbin(x: var MemPool, b: ptr Chunk) =
  ## Removes the specified block from its bin.
  let idx = log2Floor(b.header.size div MinChunkSize)
  # Remove the bin from the free block list
  if b.nextFree != nil:
    b.nextFree.prevFree = b.prevFree
  if b.prevFree != nil:
    b.prevFree.nextFree = b.nextFree
  # Update the bin header
  if x.bins[idx] == b:
    x.bins[idx] = b.nextFree
    if x.bins[idx] == nil:
      x.nonEmptyBinMask = x.nonEmptyBinMask and not pow2(idx).uint

proc createMemPool*(buffer: openarray[byte]): MemPool =
  result = MemPool()
  let base = alignUp(cast[pointer](buffer), MemAlign)
  let padding = cast[uint](base) - cast[uint](buffer)
  let size = buffer.len - padding.int
  if base != nil and size >= MinChunkSize:
    # Limit and align the capacity
    var capacity = min(size, MaxChunkSize)
    capacity = alignDown(capacity.uint, MinChunkSize).int
    # Initialize the root block
    let b = cast[ptr Chunk](base)
    b.header.next = nil
    b.header.prev = nil
    b.header.size = capacity
    b.header.used = false
    b.nextFree = nil
    b.prevFree = nil
    rebin(result, b)
    assert result.nonEmptyBinMask != 0
    result.capacity = capacity

proc alloc*(x: var MemPool, size: Natural): pointer =
  result = nil
  if size > 0 and size <= x.capacity - MemAlign:
    let chunkSize = nextPowerOfTwo(size + MemAlign)
    let optimalBinIndex = log2Ceil(chunkSize div MinChunkSize) # Use ceil when fetching
    let candidateBinMask = not (pow2(optimalBinIndex) - 1)
    let suitableBins = x.nonEmptyBinMask and candidateBinMask.uint
    let smallestBinMask = suitableBins and not (suitableBins - 1) # Clear all bits but the lowest
    if smallestBinMask != 0:
      let binIndex = log2Floor(smallestBinMask.int)
      let b = x.bins[binIndex]
      assert not b.header.used
      unbin(x, b)
      let leftover = b.header.size - chunkSize
      b.header.size = chunkSize
      assert leftover < x.capacity # Overflow check
      if leftover >= MinChunkSize:
        let newBlock = cast[ptr Chunk](cast[uint](b) + chunkSize.uint)
        newBlock.header.size = leftover
        newBlock.header.used = false
        interlink(newBlock, b.header.next)
        interlink(b, newBlock)
        rebin(x, newBlock)
        inc x.occupied, chunkSize
        assert b.header.size >= size + MemAlign
        b.header.used = true
      result = cast[pointer](cast[uint](b) + MemAlign)

proc free*(x: var MemPool, p: pointer) =
  if p != nil: # nil pointer is a no-op.
    let b = cast[ptr Chunk](cast[uint](p) - MemAlign)
    assert b.header.used # Catch double-free
    # Even if we're going to drop the block later, mark it free anyway to prevent double-free
    b.header.used = false
    # Update the diagnostics. It must be done before merging because it invalidates the block size information.
    assert x.occupied >= b.header.size # Heap corruption check
    dec x.occupied, b.header.size
    # Merge with siblings and insert the returned block into the appropriate bin and update metadata.
    let prev = b.header.prev
    let next = b.header.next
    let joinLeft = prev != nil and not prev.header.used
    let joinRight = next != nil and not next.header.used
    if joinLeft and joinRight: # [ prev ][ this ][ next ] => [ ------- prev ------- ]
      unbin(x, prev)
      unbin(x, next)
      inc prev.header.size, b.header.size + next.header.size
      b.header.size = 0 # Invalidate the dropped block headers to prevent double-free.
      next.header.size = 0
      interlink(prev, next.header.next)
      rebin(x, prev)
    elif joinLeft: # [ prev ][ this ][ next ] => [ --- prev --- ][ next ]
      unbin(x, prev)
      inc prev.header.size, b.header.size
      b.header.size = 0
      interlink(prev, next)
      rebin(x, prev)
    elif joinRight: # [ prev ][ this ][ next ] => [ prev ][ --- this --- ]
      unbin(x, next)
      inc b.header.size, next.header.size
      next.header.size = 0
      interlink(b, next.header.next)
      rebin(x, b)
    else:
      rebin(x, b)

proc ptrSize(p: pointer): int {.inline.} =
  let b = cast[ptr Chunk](cast[uint](p) - MemAlign)
  assert b.header.used
  result = b.header.size

proc realloc*(x: var MemPool, p: pointer, newSize: Natural): pointer =
  result = nil
  if newSize > 0:
    result = alloc(x, newSize)
    if p != nil:
      copyMem(result, p, min(ptrSize(p), newSize))
      free(x, p)
  elif p != nil:
    free(x, p)

proc getFreeMemory*(x: MemPool): int {.inline.} =
  result = x.capacity - x.occupied

const
  DefaultAlignment = when sizeof(int) <= 4: 8 else: 16

type
  FreeNode = object
    next: ptr FreeNode

  ObjPool*[T] = object
    chunkSize: int
    head: ptr FreeNode # Free List Head
    bufLen: int
    buf: ptr UncheckedArray[byte]

proc freeAll*(x: var ObjPool)

proc createObjPool*[T](buffer: openarray[byte]): ObjPool[T] =
  result = ObjPool[T]()
  if buffer.len > 0:
    let start = cast[uint](buffer)
    let alignedStart = alignUp(start, alignof(T))
    let alignedLen = buffer.len - int(alignedStart - start)
    # Align chunk size up to the required chunkAlignment
    let alignedSize = alignUp(sizeof(T).uint, alignof(T)).int
    # Assert that the parameters passed are valid
    assert alignedSize >= sizeof(FreeNode), "Chunk size is too small"
    assert alignedLen >= alignedSize, "Backing buffer length is smaller than the chunk size"
    # Store the adjusted parameters
    result.buf = cast[ptr UncheckedArray[byte]](alignedStart)
    result.bufLen = alignedLen
    result.chunkSize = alignedSize
    result.head = nil # Free List Head
    # Set up the free list for free chunks
    freeAll(result)

proc alloc*[T](x: var ObjPool[T]): ptr T =
  # Get latest free node
  let node = x.head
  # assert node != nil, "FixedPool allocator has no free memory"
  if node != nil:
    # Pop free node
    x.head = node.next
    # Zero memory by default
    zeroMem(node, x.chunkSize)
    result = cast[ptr T](node)

proc free*[T](x: var ObjPool[T], p: ptr T) =
  # Ignore NULL pointers
  if p != nil:
    let start = cast[uint](x.buf)
    let endAddr = start + uint(x.bufLen)
    # assert start > cast[uint](p) or cast[uint](p) >= endAddr, "Memory is out of bounds"
    if start <= cast[uint](p) and cast[uint](p) < endAddr:
      # Push free node
      let node = cast[ptr FreeNode](p)
      node.next = x.head
      x.head = node

proc freeAll*(x: var ObjPool) =
  let chunkCount = x.bufLen div x.chunkSize
  # Set all chunks to be free
  for i in 0 ..< chunkCount:
    let p = cast[pointer](cast[uint](x.buf) + uint(i * x.chunkSize))
    let node = cast[ptr FreeNode](p)
    # Push free node onto the free list
    node.next = x.head
    x.head = node

type
  BiStack* = object # Double-ended stack (aka Deque)
    front, back: int
    bufLen: int
    buf: ptr UncheckedArray[byte]

proc createBiStack*(buffer: openarray[byte]): BiStack =
  result = BiStack(
    buf: if buffer.len == 0: nil else: cast[ptr UncheckedArray[byte]](buffer),
    bufLen: buffer.len,
    front: 0,
    back: buffer.len
  )

proc alignedAllocFront*(s: var BiStack, size, align: Natural): pointer =
  result = nil
  let
    currAddr = cast[uint](s.buf) + s.front.uint
    alignedAddr = alignUp(currAddr, align)
    padding = int(alignedAddr - currAddr)
  if s.front + padding + size <= s.back:
    # Stack allocator is out of memory
    s.front = s.front + size + padding
    result = cast[pointer](alignedAddr)
    zeroMem(result, size)

proc allocFront*(s: var BiStack; size: Natural): pointer {.inline.} =
  alignedAllocFront(s, size, DefaultAlignment)

proc alignedAllocBack*(s: var BiStack, size, align: Natural): pointer =
  result = nil
  let
    currAddr = cast[uint](s.buf) + s.front.uint
    alignedAddr = alignUp(currAddr, align)
    padding = int(alignedAddr - currAddr)
  if s.back - padding - size >= s.front:
    # Stack allocator is out of memory
    s.back = s.back - size - padding
    result = cast[pointer](alignedAddr)
    zeroMem(result, size)

proc allocBack*(s: var BiStack; size: Natural): pointer {.inline.} =
  alignedAllocBack(s, size, DefaultAlignment)

proc resetFront*(s: var BiStack) {.inline.} =
  s.front = 0

proc resetBack*(s: var BiStack) {.inline.} =
  s.back = s.bufLen

proc resetAll*(s: var BiStack) {.inline.} =
  resetBack(s)
  resetFront(s)

proc margins*(s: BiStack): int {.inline.} =
  result = s.back - s.front
