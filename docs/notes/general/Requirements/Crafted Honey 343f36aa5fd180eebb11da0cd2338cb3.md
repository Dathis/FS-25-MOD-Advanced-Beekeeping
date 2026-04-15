# Crafted Honey

## General Description

**Crafted Honey** is the final production product of the *Advanced Beekeeping* system.

It represents packaged honey stored in **glass jars on a pallet** and is the main sellable output of the production chain.

The product can only be obtained through the **Honey Filling Machine**.

---

## Core Properties

- **Type:** sellable pallet product
- **Packaging:** glass jars on pallet
- **Capacity:**
    - minimum: 1 jar (3 liters)
    - maximum: 12 jars (36 liters)
- **Volume per jar:** 3 liters

---

## Product Variants

The pallet size is dynamic depending on production output:

| Jars | Total Volume |
| --- | --- |
| 1 | 3 L |
| 6 | 18 L |
| 12 | 36 L |

---

## Creation

Crafted Honey can only be produced via:

- **Honey Filling Machine**

### Production Rules:

- 1 jar = 3 liters of honey
- jars are filled one by one
- output pallet size depends on completed units

---

## Output Behavior

- pallets are spawned in the **output area** of the Honey House
- pallet size reflects the number of filled jars

---

## Player Interaction

The player must be able to:

- pick up and carry the pallet
- transport it
- store it
- sell it

---

## Selling

Crafted Honey is a **sellable product**.

### Selling Locations (initial concept):

- supermarkets
- farm shops
- production sell points
- other logical locations (to be defined later)

---

## Economy

### Pricing Model

The value of the pallet depends on total honey volume:

- **Price formula:**
    
    `Price = 50 × liters of honey`
    

---

### Examples

| Volume | Price |
| --- | --- |
| 3 L | 150 € |
| 18 L | 900 € |
| 36 L | 1800 € |

---

## Value Characteristics

- high-value product
- requires multi-step production
- reflects effort and time investment

---

## Restrictions

- cannot be crafted manually
- cannot exist without processing
- cannot be unpacked back into honey or jars

---

## Storage Rules

Crafted Honey exists only as:

- pallet in the world
- sellable inventory item

---

## Scope Boundary

Crafted Honey is responsible for:

- representing final processed honey
- being the main economic output
- interacting with selling systems

It is not responsible for:

- honey production
- packaging logic
- intermediate storage

---

## Summary

Crafted Honey is:

- the **final product** of the beekeeping system
- produced from liquid honey + jars
- scalable in size (3–36 liters)
- directly tied to player profit