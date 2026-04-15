# Glass Jar

## General Description

**Glass Jars** are packaging items used to store and sell honey.

They are purchased from the shop and always exist as a **pallet unit** containing multiple jars.

Glass jars are used exclusively in the **Honey Filling Machine** to produce final honey products.

---

## Core Properties

- **Type:** portable pallet item
- **Unit size:** 1 pallet = 12 jars
- **Volume per jar:** 3 liters
- **Total pallet capacity:** 36 liters
- **State:**
    - Empty (purchased)
    - Full (after filling, produced by system)

---

## Economy (Initial Values)

- **Price (empty pallet):** 25 € *(placeholder, can be balanced later)*
- **Weight (empty pallet):** 8 kg *(symbolic value)*

---

## Purchase & Availability

- Glass Jars can be purchased in the **shop**
- They are always bought as a **full pallet (12 empty jars)**
- Individual jars cannot be purchased separately

---

## Player Interaction

The player must be able to:

- pick up and carry the pallet
- place it in the world
- transport it manually or via vehicles (optional extension)

---

## Usage

Glass Jars are used in the **Honey Filling Machine**.

---

## Interaction with Honey Filling Machine

### Input Behavior

When a pallet of **empty jars** is placed in the input trigger:

- jars are automatically transferred into the machine
- pallet is consumed (removed)
- internal storage of empty jars increases

---

### Processing Role

During production:

- each jar:
    - consumes **3 liters of honey**
    - is converted into a **filled jar**
- after 12 jars:
    - a **full pallet of honey jars** is produced

---

## Output

- filled jars are not handled individually
- they are output as a **finished pallet (12 filled jars)**

---

## Restrictions

- only **empty jars** are accepted as input
- filled jars cannot be reused
- jars cannot be partially filled (always 3L per unit)

---

## Storage Rules

- jars exist either:
    - as pallet items (world object)
    - inside filling machine (internal storage)
    - as finished pallets (output)

---

## Scope Boundary

Glass Jars are responsible for:

- acting as packaging units
- defining the final product size (3L per unit)
- enabling honey to be converted into sellable goods

They are not responsible for:

- honey production
- honey storage (liquid form)
- transport logic beyond pallet form

---

## Summary

Glass Jars are:

- a **consumable packaging resource**
- purchased in pallets of 12
- required for honey production output
- directly tied to the filling process