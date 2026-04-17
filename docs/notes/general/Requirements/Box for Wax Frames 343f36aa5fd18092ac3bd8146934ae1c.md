# Box for Wax Frames

## General Description

The **Box for Wax Frames** is a portable container used to transport and manage wax frames between systems such as the **Beehive** and the **Honey Extractor**.

It supports bulk interaction (up to 15 frames), making it the primary tool for efficient beekeeping workflow.

---

## Core Properties

The Box for Wax Frames must have the following attributes:

- **Capacity:** max 15 frames
- **Weight:** 5 kg (base weight, optional scaling with content)
- **Type:** portable item
- **Variants:**
    - Empty box
    - Pre-filled box (with empty frames)

---

## Content Rules

The box can contain:

- Empty frames
- Full frames

### Mixed Content

- The box **can contain a mix** of empty and full frames
- Frames are tracked as internal counts by state
- Durability is not tracked in the current scope

---

## Purchase & Availability

The player can buy:

- a **box pre-filled with empty frames (15)**

Both are available in the shop as items (not placeables).

---

## Player Interaction

The player must be able to:

- pick up and carry the box
- place it in the world
- use it in interaction trigger zones
- transfer frames through supported storage interactions

---

## Automatic Interaction (Trigger-Based)

The box interacts automatically with systems when placed in a valid **trigger zone**.

---

## Interaction with Beehive

### 1. Filling the Box (Collecting Frames)

**Conditions:**

- box is placed in beehive trigger area
- box has free capacity
- hive contains frames (usually Full frames)

**Result:**

- frames are transferred from hive → box
- priority: **Full frames first**
- transfer continues until:
    - box is full, or
    - hive has no more frames to give

---

### 2. Emptying the Box (Inserting Frames)

**Conditions:**

- box is placed in beehive trigger area
- hive has free capacity
- box contains frames

**Result:**

- frames are transferred from box → hive
- priority:
    - Empty frames first (preferred for production)
    - Full frames (optional: allow or block, design choice)

---

## Interaction with Honey Extractor

### Emptying Full Frames

**Conditions:**

- box is placed in extractor trigger area
- box contains Full frames

**Result:**

- Full frames are transferred into extractor
- box loses those frames
- extractor processes them

---

### Receiving Empty Frames (Post-Processing)

**Conditions:**

- box is placed in extractor output trigger
- extractor has processed frames

**Result:**

- Empty frames are transferred into the box

---

## Transfer Rules

- Transfers are **automatic** when conditions are satisfied
- No manual UI menu required (interaction-based system)
- Transfer stops when:
    - box is full
    - source is empty
    - target is full

---

## Capacity Rules

- Maximum: **15 frames**
- Cannot exceed capacity
- Each frame occupies 1 slot

---

## Visual Representation (Optional but recommended)

- Box changes appearance based on content:
    - empty → clean box
    - partially filled → visible frames
    - full → visibly packed
- Optional:
    - different visuals for empty vs full frames inside

---

## Scope Boundary

The Box for Wax Frames is responsible for:

- storing frames
- transporting frames
- enabling bulk transfer between systems

It is **not responsible** for:

- honey production (Beehive)
- honey extraction (Extractor)
- frame state changes (handled by systems)
