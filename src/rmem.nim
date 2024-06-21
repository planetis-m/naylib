# ****************************************************************************************
#
#  rmem v1.3 - memory pool and objects pool
#
#  DESCRIPTION:
#      A quick, efficient, and minimal free list and arena-based allocator
#
#  POURPOSE:
#      - A quicker, efficient memory allocator alternative to 'malloc()' and friends.
#      - Reduce the possibilities of memory leaks for beginner developers using raylib.
#      - Being able to flexibly range check memory if necessary.
#
#  CONFIGURATION:
#      #define RMEM_IMPLEMENTATION
#          Generates the implementation of the library into the included file.
#          If not defined, the library is in header only mode and can be included in other headers
#          or source files without problems. But only ONE file should hold the implementation.
#
#  DOCUMENTATION:
#      Repo Readme: https://github.com/raylib-extras/rmem
#      Usage example with raylib: https://github.com/raysan5/raylib/issues/1329
#
#  VERSIONS HISTORY:
#      1.3     Several changes:
#              Optimizations of allocators
#              Renamed 'Stack' to 'Arena'
#              Replaced certain define constants with an anonymous enum
#              Refactored MemPool to no longer require active or deferred defragging
#      1.2     Addition of bidirectional arena
#      1.1     Bug patches for the mempool and addition of object pool
#      1.0     First version
#
#
#  LICENSE: zlib/libpng
#
#  Copyright (c) 2019 Kevin 'Assyrianic' Yonan (@assyrianic) and reviewed by Ramon Santamaria (@raysan5)
#
#  This software is provided "as-is", without any express or implied warranty. In no event
#  will the authors be held liable for any damages arising from the use of this software.
#
#  Permission is granted to anyone to use this software for any purpose, including commercial
#  applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#    1. The origin of this software must not be misrepresented; you must not claim that you
#    wrote the original software. If you use this software in a product, an acknowledgment
#    in the product documentation would be appreciated but is not required.
#
#    2. Altered source versions must be plainly marked as such, and must not be misrepresented
#    as being the original software.
#
#    3. This notice may not be removed or altered from any source distribution.
#
# ****************************************************************************************

runnableExamples:
  # Example 1: MemPool

  # Create a memory pool with 1024 bytes
  var mp = createMemPool(size = 1024)
  # Allocate memory
  let ptr1 = mp.alloc(100)
  let ptr2 = mp.alloc(200)
  # Check free memory
  echo "Free memory: ", mp.getFreeMemory()
  # Reallocate
  let ptr3 = mp.realloc(ptr1, 150)
  # Free memory
  mp.free(ptr2)
  # Reset the pool
  mp.reset()
  echo "Free memory after reset: ", mp.getFreeMemory()

  # Example 2: ObjPool
  type
    MyObject = object
      x, y: int
      data: array[20, char]

  # Create an object pool with 10 MyObject slots
  const Size = alignSize(sizeof(MyObject), sizeof(int)) * 10 # each element should be aligned
  var buffer {.align(sizeof(int)).}: array[Size, byte] # variable is also aligned
  var op = createObjPoolFromBuffer[MyObject](addr buffer, size = buffer.len)
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

  # Create a BiStack with 1000 bytes
  var bs = createBiStack(size = 1000)
  # Choose between front and back allocations based on the lifetimes and
  # usage patterns of your data.
  let front1 = cast[ptr int](bs.allocFront(sizeof(int))) # Memory is not cleared!
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

import system/ansi_c

# Global Variables Definition

const
  MEMPOOL_BUCKET_SIZE = 8
  MEMPOOL_BUCKET_BITS = (sizeof(uint) div 2) + 1
  MEM_SPLIT_THRESHOLD = sizeof(uint) * 4

# Types and Structures Definition

type
  MemNode = object # Memory pool node
    size: int
    next, prev: ptr MemNode

  AllocList = object # Freelist implementation
    head, tail: ptr MemNode
    len: int

  Arena = object # Arena allocator
    mem, offs: uint
    size: int

  MemPool*[Owned: static[bool]] = object # Memory pool
    large: AllocList
    buckets: array[MEMPOOL_BUCKET_SIZE, AllocList]
    arena: Arena

  ObjPool*[T; Owned: static[bool]] = object # Object pool
    mem, offs: uint
    objSize, freeBlocks, memSize: int

  BiStack*[Owned: static[bool]] = object # Double-ended stack (aka Deque)
    mem, front, back: uint
    size: int

# Destructors

proc `=destroy`*[Owned](mempool: MemPool[Owned]) =
  if Owned and mempool.arena.mem != 0:
    let `ptr` {.noalias.} = cast[pointer](mempool.arena.mem)
    c_free(`ptr`)

proc `=dup`*[O](source: MemPool[O]): MemPool[O] {.error.}
proc `=copy`*[O](dest: var MemPool[O]; source: MemPool[O]) {.error.}

proc `=destroy`*[T, Owned](objpool: ObjPool[T, Owned]) =
  if Owned and objpool.mem != 0:
    let `ptr` {.noalias.} = cast[pointer](objpool.mem)
    c_free(`ptr`)

proc `=dup`*[T, O](source: ObjPool[T, O]): ObjPool[T, O] {.error.}
proc `=copy`*[T, O](dest: var ObjPool[T, O]; source: ObjPool[T, O]) {.error.}

proc `=destroy`*[Owned](destack: BiStack[Owned]) =
  if Owned and destack.mem != 0:
    let `ptr` {.noalias.} = cast[pointer](destack.mem)
    c_free(`ptr`)

proc `=dup`*[O](source: BiStack[O]): BiStack[O] {.error.}
proc `=copy`*[O](dest: var BiStack[O]; source: BiStack[O]) {.error.}

# Module specific Functions Declaration

proc alignSize*(size, align: int): int {.inline.} =
  result = (size + (align - 1)) and not (align - 1)

proc splitMemNode(node: ptr MemNode, bytes: int): ptr MemNode =
  let n = cast[uint](node)
  result = cast[ptr MemNode](n + uint(node.size - bytes))
  node.size -= bytes
  result.size = bytes

proc insertMemNodeBefore(list: var AllocList, insert, curr: ptr MemNode) =
  insert.next = curr
  if curr.prev == nil:
    list.head = insert
  else:
    insert.prev = curr.prev
    curr.prev.next = insert
  curr.prev = insert

proc replaceMemNode(old, replace: ptr MemNode) =
  replace.prev = old.prev
  replace.next = old.next
  if old.prev != nil: old.prev.next = replace
  if old.next != nil: old.next.prev = replace

proc removeMemNode(list: var AllocList, node: ptr MemNode): ptr MemNode =
  if node.prev != nil:
    node.prev.next = node.next
  else:
    list.head = node.next
    if list.head != nil:
      list.head.prev = nil
    else:
      list.tail = nil
  if node.next != nil:
    node.next.prev = node.prev
  else:
    list.tail = node.prev
    if list.tail != nil:
      list.tail.next = nil
    else:
      list.head = nil
  dec list.len
  result = node

proc findMemNode(list: var AllocList, bytes: int): ptr MemNode =
  var node = list.head
  while node != nil:
    if node.size < bytes:
      node = node.next
      continue
    # Close in size - reduce fragmentation by not splitting
    elif node.size <= bytes + MEM_SPLIT_THRESHOLD:
      return removeMemNode(list, node)
    else:
      return splitMemNode(node, bytes)
  return nil

proc insertMemNode(mempool: var MemPool, list: var AllocList, node: ptr MemNode, isBucket: bool) =
  if list.head == nil:
    list.head = node
    inc(list.len)
  else:
    var iter = list.head
    while iter != nil:
      if cast[uint](iter) == mempool.arena.offs:
        mempool.arena.offs += uint(iter.size)
        discard removeMemNode(list, iter)
        iter = list.head
        if iter == nil:
          list.head = node
          return
      let
        inode = cast[uint](node)
        iiter = cast[uint](iter)
        iterEnd = iiter + uint(iter.size)
        nodeEnd = inode + uint(node.size)
      if iter == node:
        return
      elif iter < node:
        # node was coalesced prior.
        if iterEnd > inode:
          return
        elif (iterEnd == inode) and not isBucket:
          # if we can coalesce, do so.
          iter.size += node.size
          return
        elif iter.next == nil:
          # we reached the end of the free list -> append the node
          iter.next = node
          node.prev = iter
          inc(list.len)
          return
      elif iter > node:
        # Address sort, lowest to highest aka ascending order.
        if iiter < nodeEnd:
          return
        elif (iter == list.head) and not isBucket:
          if iterEnd == inode:
            iter.size += node.size
          elif nodeEnd == iiter:
            node.size += list.head.size
            node.next = list.head.next
            node.prev = nil
            list.head = node
          else:
            node.next = iter
            node.prev = nil
            iter.prev = node
            list.head = node
            inc(list.len)
          return
        elif (iterEnd == inode) and not isBucket:
          # if we can coalesce, do so.
          iter.size += node.size
          return
        else:
          insertMemNodeBefore(list, node, iter)
          inc(list.len)
          return
      iter = iter.next

# Module Functions Definition - Memory Pool

proc createMemPool*(size: Natural): MemPool[true] =
  result = MemPool[true]()
  if size == 0:
    return
  # Align the mempool size to at least the size of an alloc node.
  let buf {.noalias.} = c_malloc(size.csize_t)
  if buf == nil:
    return
  result.arena.size = size
  result.arena.mem = cast[uint](buf)
  result.arena.offs = result.arena.mem + uint(result.arena.size)

proc createMemPoolFromBuffer*(buf {.noalias.}: pointer, size: Natural): MemPool[false] =
  result = MemPool[false]()
  if size == 0 or buf == nil or size <= sizeof(MemNode):
    return
  result.arena.size = size
  result.arena.mem = cast[uint](buf)
  result.arena.offs = result.arena.mem + uint(result.arena.size)

proc alloc*(mempool: var MemPool, size: Natural): pointer =
  if size == 0 or size > mempool.arena.size:
    return nil
  var newMem: ptr MemNode = nil
  let allocSize = alignSize(size + sizeof(MemNode), sizeof(int))
  let bucketSlot = (allocSize shr MEMPOOL_BUCKET_BITS) - 1
  # If the size is small enough, let's check if our buckets has a fitting memory block.
  if bucketSlot < MEMPOOL_BUCKET_SIZE:
    newMem = findMemNode(mempool.buckets[bucketSlot], allocSize)
  elif mempool.large.head != nil:
    newMem = findMemNode(mempool.large, allocSize)
  if newMem == nil:
    # not enough memory to support the size!
    if (mempool.arena.offs - uint(allocSize)) < mempool.arena.mem:
      return nil
    # Couldn't allocate from a freelist, allocate from available mempool.
    # Subtract allocation size from the mempool.
    mempool.arena.offs -= uint(allocSize)
    # Use the available mempool space as the new node.
    newMem = cast[ptr MemNode](mempool.arena.offs)
    newMem.size = allocSize
  # Visual of the allocation block.
  # --------------
  # | mem size   | lowest addr of block
  # | next node  | 12 byte (32-bit) header
  # | prev node  | 24 byte (64-bit) header
  # |------------|
  # |   alloc'd  |
  # |   memory   |
  # |   space    | highest addr of block
  # --------------
  newMem.next = nil
  newMem.prev = nil
  let finalMem {.noalias.} = cast[pointer](cast[uint](newMem) + uint(sizeof(MemNode)))
  result = finalMem
  zeroMem(result, newMem.size - sizeof(MemNode))

proc free*(mempool: var MemPool, `ptr`: pointer) =
  if `ptr` == nil:
    return
  let p = cast[uint](`ptr`)
  if p - uint(sizeof(MemNode)) < mempool.arena.mem:
    return
  # Behind the actual pointer data is the allocation info.
  let `block` = p - uint(sizeof(MemNode))
  let memNode = cast[ptr MemNode](`block`)
  let bucketSlot = (memNode.size shr MEMPOOL_BUCKET_BITS) - 1
  # Make sure the pointer data is valid.
  if `block` < mempool.arena.offs or
     (`block` - mempool.arena.mem) > uint(mempool.arena.size) or
     memNode.size == 0 or
     memNode.size > mempool.arena.size:
    return
  # If the memNode is right at the arena offs, then merge it back to the arena.
  elif `block` == mempool.arena.offs:
    mempool.arena.offs += uint(memNode.size)
  else:
    # try to place it into bucket or large freelist.
    if bucketSlot < MEMPOOL_BUCKET_SIZE:
      insertMemNode(mempool, mempool.buckets[bucketSlot], memNode, isBucket = true)
    else:
      insertMemNode(mempool, mempool.large, memNode, isBucket = false)

proc realloc*(mempool: var MemPool, `ptr`: pointer, size: Natural): pointer =
  if size > mempool.arena.size:
    return nil
  # NULL ptr should make this work like regular Allocation
  elif `ptr` == nil:
    return alloc(mempool, size)
  elif cast[uint](`ptr`) - uint(sizeof(MemNode)) < mempool.arena.mem:
    return nil
  else:
    let node = cast[ptr MemNode](cast[uint](`ptr`) - uint(sizeof(MemNode)))
    let resizedBlock = alloc(mempool, size)
    if resizedBlock == nil:
      return nil
    else:
      let resized = cast[ptr MemNode](cast[uint](resizedBlock) - uint(sizeof(MemNode)))
      let copySize = min(node.size, resized.size) - sizeof(MemNode)
      copyMem(resizedBlock, `ptr`, copySize)
      free(mempool, `ptr`)
      return resizedBlock

proc getFreeMemory*(mempool: MemPool): int =
  result = int(mempool.arena.offs - mempool.arena.mem)
  var n = mempool.large.head
  while n != nil:
    result += n.size
    n = n.next
  for i in 0..<MEMPOOL_BUCKET_SIZE:
    n = mempool.buckets[i].head
    while n != nil:
      result += n.size
      n = n.next

proc reset*(mempool: var MemPool) =
  mempool.large.head = nil
  mempool.large.tail = nil
  mempool.large.len = 0
  for i in 0..<MEMPOOL_BUCKET_SIZE:
    mempool.buckets[i].head = nil
    mempool.buckets[i].tail = nil
    mempool.buckets[i].len = 0
  mempool.arena.offs = mempool.arena.mem + uint(mempool.arena.size)

# Module Functions Definition - Object Pool

proc createObjPool*[T](len: Natural): ObjPool[T, true] =
  result = ObjPool[T, true]()
  if len == 0 or sizeof(T) == 0:
    return
  let alignedSize = alignSize(sizeof(T), sizeof(int))
  let buf {.noalias.} = c_calloc(csize_t(len), csize_t(alignedSize))
  if buf == nil:
    return
  result.objSize = alignedSize
  result.memSize = len
  result.freeBlocks = len
  result.mem = cast[uint](buf)
  for i in 0..<result.freeBlocks:
    let index {.noalias.} = cast[ptr int](result.mem + uint(i * alignedSize))
    index[] = i + 1
  result.offs = result.mem

proc createObjPoolFromBuffer*[T](buf {.noalias.}: pointer, size: Natural): ObjPool[T, false] =
  result = ObjPool[T, false]()
  # If the object size isn't large enough to align to a size_t, then we can't use it
  if sizeof(T) < sizeof(int):
    return
  let alignedSize = alignSize(sizeof(T), sizeof(int))
  let len = size div alignedSize
  if buf == nil or len == 0 or size != len * alignedSize:
    return
  result.objSize = alignedSize
  result.memSize = len
  result.freeBlocks = len
  result.mem = cast[uint](buf)
  for i in 0..<result.freeBlocks:
    let index {.noalias.} = cast[ptr int](result.mem + uint(i * alignedSize))
    index[] = i + 1
  result.offs = result.mem

proc alloc*[T, O](objpool: var ObjPool[T, O]): ptr T =
  if objpool.freeBlocks > 0:
    # For first allocation, head points to the very first index.
    # Head = &pool[0];
    # ret = Head == ret = &pool[0];
    let `block` {.noalias.} = cast[ptr int](objpool.offs)
    dec(objpool.freeBlocks)
    # After allocating, we set head to the address of the index that *Head holds.
    # Head = &pool[*Head * pool.objsize];
    objpool.offs = if objpool.freeBlocks != 0: objpool.mem + uint(`block`[] * objpool.objSize) else: 0
    result = cast[ptr T](`block`)
    zeroMem(result, objpool.objSize)
  else:
    result = nil

proc free*[T, O](objpool: var ObjPool[T, O], `ptr`: ptr T) =
  let `block` = cast[uint](`ptr`)
  if `ptr` == nil or `block` < objpool.mem or `block` > objpool.mem + uint(objpool.memSize * objpool.objSize):
    return
  else:
    # When we free our pointer, we recycle the pointer space to store the previous index and then we push it as our new head.
    # *p = index of Head in relation to the buffer;
    # Head = p;
    let index {.noalias.} = cast[ptr int](`block`)
    index[] = if objpool.offs != 0: int((objpool.offs - objpool.mem) div uint(objpool.objSize))
              else: objpool.memSize
    objpool.offs = `block`
    inc(objpool.freeBlocks)

# Module Functions Definition - Double-Ended Stack

proc createBiStack*(size: Natural): BiStack[true] =
  result = BiStack[true]()
  if size == 0:
    return
  let buf = c_malloc(csize_t(size))
  if buf == nil:
    return
  result.size = size
  result.mem = cast[uint](buf)
  result.front = result.mem
  result.back = result.mem + uint(size)

proc createBiStackFromBuffer*(buf {.noalias.}: pointer, size: Natural): BiStack[false] =
  result = BiStack[false]()
  if size == 0 or buf == nil:
    return
  else:
    result.size = size
    result.mem = cast[uint](buf)
    result.front = result.mem
    result.back = result.mem + uint(size)

proc allocFront*(destack: var BiStack, size: Natural): pointer =
  if destack.mem == 0:
    return nil
  else:
    let alignedLen = alignSize(size, sizeof(uint))
    # front end arena is too high!
    if destack.front + uint(alignedLen) >= destack.back:
      return nil
    else:
      let `ptr` {.noalias.} = cast[pointer](destack.front)
      destack.front += uint(alignedLen)
      return `ptr`

proc allocBack*(destack: var BiStack, size: Natural): pointer =
  if destack.mem == 0:
    return nil
  else:
    let alignedLen = alignSize(size, sizeof(uint))
    # back end arena is too low
    if destack.back - uint(alignedLen) <= destack.front:
      return nil
    else:
      destack.back -= uint(alignedLen)
      let `ptr` {.noalias.} = cast[pointer](destack.back)
      return `ptr`

proc resetFront*(destack: var BiStack) =
  if destack.mem == 0:
    return
  else:
    destack.front = destack.mem

proc resetBack*(destack: var BiStack) =
  if destack.mem == 0:
    return
  else:
    destack.back = destack.mem + uint(destack.size)

proc resetAll*(destack: var BiStack) =
  resetBack(destack)
  resetFront(destack)

proc margins*(destack: BiStack): int {.inline.} =
  result = int(destack.back - destack.front)
