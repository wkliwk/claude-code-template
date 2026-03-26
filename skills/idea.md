# /idea — Evaluate an Idea

Single entry point for all ideas — features for existing products or entirely new product concepts.

## Usage

```
/idea <description>
```

## What This Does

1. **Auto-classifies** — feature for existing product vs new standalone product
2. **CEO evaluates** — build / backlog / reject + rationale
3. **PM challenges** — especially on scope/complexity
4. **Final decision** — PM wins on scope disputes; CEO wins on strategy
5. **Creates issue or board item** — on the right board automatically
6. **Reports back** with full context

## Examples

```
/idea add dark mode to my-app
/idea an AI wardrobe recommendation app
/idea receipt scanning
```

## When to Use

- You have any idea — feature or product — and want structured evaluation
- You're not sure if it's a feature or a new product (it will ask)

## Notes

- Replaces both the old `/idea` and `/new-product` commands
- `/new-product` still works but redirects here
- For quick tasks that don't need evaluation, use `/add-task`
- For bugs, use `/issue`
- After a new product is approved, use `/launch-product` to set up repos and board
