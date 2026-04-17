# Wax Frame

## General Description

The **Wax Frame** is an internal gameplay item used for honey production inside a beehive.

For the current scope, a wax frame is **not** a standalone world object. It can only exist inside one of the supported containers:

- Frame Box
- Beehive
- Honey Extractor

Durability is intentionally removed for now. A frame only tracks its current state.

---

## Core Properties

Each Wax Frame has:

- **State:**
    - `Empty`
    - `Full`
- **Physical form:**
    - no loose carriable object
    - stored only as internal container state

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

1. Empty frame is inserted into beehive from a Frame Box
2. Bees fill it and it becomes Full
3. Player removes it into a Frame Box
4. Frame goes into extractor
5. Extractor turns it back into Empty
6. Empty frame returns to a Frame Box or another storage

---

## Player Interaction

The player cannot pick up a single frame directly.

The player interacts with frames through:

- Frame Box
- Beehive trigger or interaction
- Honey Extractor trigger or interaction

---

## Storage & Usage Locations

Wax Frames can exist in:

### 1. Beehive

- stored internally
- used for production

### 2. Frame Box

- main transport method
- holds up to 15 frames

### 3. Honey Extractor

- processes Full into Empty

---

## State Transitions

- Empty -> Full, inside beehive
- Full -> Empty, inside extractor

---

## Visual Representation

- Empty -> light frame
- Full -> capped honey frame

Visuals are driven by the container that currently holds the frames.

---

## Scope Boundary

Wax Frame is responsible for:

- representing frame state
- participating in the production cycle

Not responsible for:

- world pickup
- transport logic, handled by Frame Box
- honey production, handled by Beehive
- extraction, handled by Honey Extractor
