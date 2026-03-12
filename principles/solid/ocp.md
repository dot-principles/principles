# SOLID-OCP — Open/Closed Principle

**Layer:** 1 (universal)
**Categories:** software-design, extensibility, maintainability
**Applies-to:** all

## Principle

Software entities — classes, modules, functions — should be open for extension but closed for modification. New behaviour should be addable by writing new code, not by changing existing, proven code.

## Why it matters

Every time existing code is modified to add new behaviour, previously working functionality is at risk of regression. Systems that require source changes to accommodate new requirements accumulate risk with each change and resist safe deployment.

## Violations to detect

- A long `if/else` or `switch` chain on a type discriminator that grows with every new type
- A function that is modified directly every time a new case is added instead of dispatching to a strategy
- Business logic mixed with variant-specific handling, making extension require editing a shared core
- Hard-coded conditionals on feature flags or entity types that should be polymorphic

## Good practice

- Introduce abstractions (interfaces, abstract classes) at the points most likely to vary
- Use the strategy or template-method pattern to allow new behaviour via new implementations
- Apply the principle selectively — not all variation is worth abstracting; wait for the second change request

## Sources

- Meyer, Bertrand. *Object-Oriented Software Construction*. 2nd ed. Prentice Hall, 1997. ISBN 978-0-13-629155-8. Chapter 23.
- Martin, Robert C. *Agile Software Development: Principles, Patterns, and Practices*. Pearson, 2003. ISBN 978-0-13-597444-5. Chapter 9.
