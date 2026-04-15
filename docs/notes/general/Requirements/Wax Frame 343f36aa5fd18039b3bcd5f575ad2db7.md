# Wax Frame

## General Description

The **Wax Frame** is a reusable item used for honey production inside a beehive.

It can exist as an **individual object** or as part of a **container (frame box)**.

Wax frames have two states (Empty / Full) and a limited durability, after which they are destroyed.

---

## Core Properties

Each Wax Frame must have:

- **State:**
    - `Empty`
    - `Full`
- **Durability:**
    - max uses: **10**
    - decreases after each extraction
    - destroyed at 0
- **Physical form:**
    - can exist as a **single carriable object**
    - can be stored in containers

---

## States

### Empty Frame

- ready to be inserted into a hive
- no honey

### Full Frame

- filled with honey
- must be processed in extractor

---

## Lifecycle

1. Empty frame → inserted into beehive
2. Bees fill it → becomes Full
3. Player removes it (single or via box)
4. Frame goes into extractor
5. Becomes Empty again
6. Durability -1
7. Repeat until destroyed

---

## Durability System

- Each extraction reduces durability by 1
- After **10 uses → frame is destroyed**
- Destruction happens automatically (disappears)

---

## Player Interaction

### The player CAN:

- pick up a single frame
- carry it manually
- insert it into:
    - beehive
    - frame box
    - extractor

---

### The player CANNOT:

- split durability
- repair frames (for now)

---

## Storage & Usage Locations

Wax Frames can exist in:

### 1. Beehive

- stored internally
- used for production

### 2. Frame Box

- main transport method
- holds multiple frames (e.g. 12)

### 3. Honey Extractor

- processes Full → Empty

### 4. World (loose object)

- can be dropped on ground
- can be picked up again

---

## Insertion Rules

### Into Beehive

- accepts both:
    - single frames
    - frames from box
- cannot exceed capacity

---

### Into Frame Box

- player can:
    - insert single frame
    - auto-fill from hive (bulk)

---

### Into Extractor

- accepts:
    - single frames
    - frames from box

---

## State Transitions

- Empty → Full (in beehive)
- Full → Empty (in extractor)
- Any → Destroyed (durability = 0)

---

## Visual Representation

- Empty → светлая рамка
- Full → золотая / запечатанная
- Low durability (optional) → изношенный вид

---

## Scope Boundary

Wax Frame is responsible for

- Storing honey
- participate in the production cycle

Not responsible for:

- transport logi(its box)
- honey production (its hive)
- extracting (its extractor)