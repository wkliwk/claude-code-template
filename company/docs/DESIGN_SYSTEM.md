# Design System

> Customize this file for your product's design system. Below is an example using MUI v5 defaults.

## Stack
MUI v5 (Material UI) — design system provided by MUI defaults.
Customizations are minimal for Phase 1 MVP.

## Tokens

### Colors
| Token | Value | Usage |
|---|---|---|
| Primary | #1976d2 | Buttons, links, active states |
| Primary dark | #115293 | Hover states |
| Error | #d32f2f | Errors, destructive actions |
| Success | #2e7d32 | Success messages |
| Warning | #ed6c02 | Warnings |
| Text primary | rgba(0,0,0,0.87) | Body text |
| Text secondary | rgba(0,0,0,0.60) | Labels, captions |
| Background | #f5f5f5 | Page background |
| Surface | #ffffff | Cards, panels |

### Typography
| Variant | Size | Weight | Usage |
|---|---|---|---|
| h4 | 2.125rem | 400 | Page titles |
| h6 | 1.25rem | 500 | Section headers |
| body1 | 1rem | 400 | Body text |
| body2 | 0.875rem | 400 | Secondary text |
| caption | 0.75rem | 400 | Labels, hints |

Font family: Roboto, sans-serif

### Spacing
Base unit: 8px
```
spacing(1) = 8px
spacing(2) = 16px
spacing(3) = 24px
spacing(4) = 32px
```

### Breakpoints
```
xs: 0px       (mobile)
sm: 600px     (tablet)
md: 900px     (small desktop)
lg: 1200px    (desktop)
xl: 1536px    (wide)
```

## Components

### Buttons
- Primary actions: `variant="contained" color="primary"`
- Secondary actions: `variant="outlined"`
- Destructive: `variant="contained" color="error"`
- Never use custom button colors

### Forms
- All inputs: MUI TextField with `fullWidth`
- Labels: always use `label` prop, not just placeholder
- Validation: show error via `error` + `helperText` props

### Data Display
- Tables: MUI DataGrid (`@mui/x-data-grid`)
- Date inputs: MUI DatePicker (`@mui/x-date-pickers`)
- Icons: MUI Icons only (`@mui/icons-material`)

### Feedback
- Success/error messages: MUI Snackbar + Alert
- Loading: MUI CircularProgress or Skeleton
- Empty states: MUI Typography + icon, centered

## Phase 1 Rules
- Work within MUI defaults — no custom themes yet
- No custom CSS unless absolutely necessary
- No third-party UI libraries (already have MUI)
- Mobile-first but desktop is primary target for MVP

## Future (Phase 2)
- Custom MUI theme (brand colors, typography scale)
- Dark mode support
- Figma design file linked here
