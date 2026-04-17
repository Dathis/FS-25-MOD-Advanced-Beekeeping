# Honey House

## General Description

The **Honey House** is a production building that processes wax frames into liquid honey and then into packaged honey products.

It consists of two automated systems:

- **Honey Extractor** — converts Full Frames into liquid honey
- **Honey Filling Machine** — converts liquid honey into packaged products

The building must be purchased via the **construction menu** and placed on the player’s farm.

---

# ⚙️ 1. Honey Extractor (Stage 1)

## Description

The **Honey Extractor** processes Full Wax Frames into:

- liquid honey (stored internally)
- empty frames (returned to the player)

The process is **automatic after manual activation**.

---

## Input

- accepts **Full Wax Frames**
- frames can be inserted via:
    - Box for Wax Frames

---

## Activation Conditions

The extractor can be started only if:

- it contains at least **1 Full Frame**

---

## Processing Cycle

- **Cycle duration:** 10 seconds
- one cycle processes **all inserted Full Frames**

---

## Processing Logic

When the player starts the extractor:

1. the extractor begins an automatic cycle
2. player cannot interact with it during the cycle
3. after 10 seconds:
    - all Full Frames become **Empty Frames**
    - liquid honey is added to internal storage

---

## Restrictions

- cannot start without Full Frames
- cannot insert or remove frames while running
- cannot extract honey while running

---

## Output — Frames

### Conditions:

- extractor is not running
- player places an **empty Box for Frames** in the output trigger

### Result:

- Empty Frames are transferred into the box
- continues until:
    - box is full, or
    - no frames remain

---

## Honey Storage

- honey is stored internally as a **liquid resource**
- accumulates over multiple cycles

---

## Manual Honey Output

The player can manually extract honey into a container.

### Conditions:

- extractor is not running
- a valid container is placed under the tap (trigger zone)

### Action:

- player presses **“Pour Honey”**

### Result:

- honey is transferred into the container
- internal honey storage decreases

---

# 🏭 2. Honey Filling Machine (Stage 2)

## Description

The **Honey Filling Machine** processes liquid honey and produces packaged honey products.

---

## Inputs

- liquid honey (from containers)
- empty packaging units (via input trigger)

---

## Loading Honey

- player places a honey container into the input trigger
- container is automatically emptied
- honey is stored internally

---

## Internal Storage

The filling machine maintains:

- stored honey
- stored empty packaging units

---

## Activation Conditions

The filling machine can be started only if:

- honey is available
- packaging units are available

---

## Production Cycle

- **1 container unit (3 liters) = 1 second**
- **1 full pallet (12 units) = 12 seconds**

---

## Production Logic

When activated:

- the machine runs automatically
- every **1 second**:
    - consumes 3 liters of honey
    - consumes 1 empty unit
    - produces 1 filled unit
- after 12 seconds:
    - a **full pallet** is completed

---

## Output

- finished products are spawned as **pallets**
- pallets appear in the output area

---

## Automation Behavior

- production continues automatically until:
    - honey runs out, or
    - packaging units run out

---

# 🔄 Full Production Workflow

### Stage 1 — Extraction

1. insert Full Frames
2. start extractor
3. wait 10 seconds
4. receive:
    - Empty Frames
    - stored honey

---

### Stage 2 — Honey Transfer

1. place container under extractor
2. pour honey into container

---

### Stage 3 — Packaging

1. place container into filling machine
2. load packaging units
3. start filling machine
4. wait:
- 1 sec per unit
- 12 sec per pallet
1. collect finished pallets

---

# ⚠️ System Rules

- extractor = **manual start + fixed 10s cycle**
- filling machine = **continuous automated production**
- both systems operate independently
- no parallel interaction during active cycles

---

# Scope Boundary

The Honey House is responsible for:

- extracting honey from frames
- storing honey as a resource
- converting honey into packaged products

It is not responsible for:

- producing frames (Beehive)
- transporting frames (Frame Box)
- managing bee colonies
