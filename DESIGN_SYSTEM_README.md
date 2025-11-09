# Modern Mobile App Design System

A comprehensive design system for the YumCheck project, providing consistent styling, components, and patterns for modern mobile applications.

## 📁 File Structure

```
yumcheck/
├── design-system.json          # Complete design system specification
├── design-tokens.css           # CSS custom properties and utilities
├── example-components.css      # Component implementations
├── example-usage.html          # Live examples and demos
├── .cursorrules               # AI assistant rules for design system usage
└── DESIGN_SYSTEM_README.md    # This documentation
```

## 🚀 Quick Start

### 1. Import Design Tokens

Add the design tokens to your main CSS file:

```css
@import url('./design-tokens.css');
```

### 2. Use CSS Custom Properties

```css
.my-component {
  background: var(--surface-card);
  color: var(--surface-card-foreground);
  border: 1px solid hsl(var(--color-border) / 0.35);
  padding: var(--spacing-4);
  border-radius: var(--border-radius-lg);
  box-shadow: var(--shadow-card);
  font-family: var(--font-family-primary);
}
```

### 3. Apply Utility Classes

```html
<div class="card p-4 rounded-lg shadow-card">
  <h2 class="text-heading">My Title</h2>
  <p class="text-body">My content</p>
</div>
```

## 🎨 Design Tokens

### Colors

#### Base Color Primitives (HSL components)
- Greys: `--grey-100` … `--grey-900`
- Blues: `--blue-100` … `--blue-800`
- Limes: `--lime-100` … `--lime-800`
- Corals: `--coral-100` … `--coral-800`
- Pinks: `--pink-100` … `--pink-800`
- Greens: `--green-100` … `--green-800`
- Reds: `--red-100` … `--red-800`

Use these primitives with `hsl(var(--token-name))` when you need direct palette access.

#### Semantic Tokens (light mode defaults)
- Backgrounds: `--color-background`, `--color-card`, `--color-foreground`, `--color-card-foreground`
- Actions: `--color-primary`, `--color-primary-foreground`, `--color-secondary`, `--color-secondary-foreground`
- Feedback: `--color-muted`, `--color-muted-foreground`, `--color-accent`, `--color-accent-foreground`
- Status: `--color-success`, `--color-success-foreground`, `--color-destructive`, `--color-destructive-foreground`
- Structural: `--color-border`, `--color-input`
- Data viz: `--color-chart-1` … `--color-chart-5`

Dark mode overrides are defined under `[data-theme="dark"]`, so all semantic tokens adapt automatically.

| Token | Light Mode | Dark Mode | Usage |
| --- | --- | --- | --- |
| `--color-background` | `--grey-200` | `--grey-900` | Main application background |
| `--color-foreground` | `--grey-900` | `--grey-100` | Primary text color |
| `--color-card` | `--grey-100` | `--grey-800` | Card component background |
| `--color-card-foreground` | `--grey-900` | `--grey-100` | Text within cards |
| `--color-primary` | `--blue-500` | `--blue-400` | Primary actions (buttons, highlights) |
| `--color-primary-foreground` | `--grey-100` | `--grey-100` | Text on primary elements |
| `--color-secondary` | `--grey-300` | `--grey-700` | Less prominent actions |
| `--color-secondary-foreground` | `--grey-900` | `--grey-100` | Text on secondary elements |
| `--color-muted` | `--grey-200` | `--grey-700` | Subdued backgrounds |
| `--color-muted-foreground` | `--grey-600` | `--grey-500` | De-emphasized text |
| `--color-accent` | `--grey-100` | `--grey-800` | Highlight for active/focused elements |
| `--color-accent-foreground` | `--grey-900` | `--grey-100` | Text on accent elements |
| `--color-destructive` | `--red-500` | `--red-500` | Error and destructive actions |
| `--color-destructive-foreground` | `--red-400` | `--red-400` | Text/icons on destructive elements |
| `--color-success` | `--green-500` | `--green-500` | Success messages and icons |
| `--color-success-foreground` | `--green-500` | `--green-500` | Text/icons on success elements |
| `--color-border` | `--grey-300` | `--grey-700` | Default border color |
| `--color-input` | `--grey-300` | `--grey-700` | Form input borders |
| `--color-chart-1` … `--color-chart-5` | `--lime-500`, `--coral-500`, `--pink-500`, `--blue-200`, `--blue-400` | Same | Data visualization colors |

#### Surface Helpers (ready-to-use CSS vars)
- `--surface-background`, `--surface-card`, `--surface-muted`, `--surface-secondary`, `--surface-primary`, `--surface-success`, `--surface-destructive`
- Each helper has a matching `*-foreground` counterpart for readable text/icon colors.
- Border and input helpers: `--surface-border`, `--surface-input`
- Chart helpers: `--chart-color-1` … `--chart-color-5`

Prefer surface helpers inside component styles to keep contrast and theming consistent.

### Typography

#### Font Sizes
- `--font-size-xs`: 12px
- `--font-size-sm`: 14px
- `--font-size-base`: 16px
- `--font-size-lg`: 18px
- `--font-size-xl`: 20px
- `--font-size-2xl`: 24px
- `--font-size-3xl`: 32px

#### Typography Hierarchy Classes
- `.text-title` - Large titles (32px, bold)
- `.text-heading` - Section headings (20px, semibold)
- `.text-subheading` - Subsection headings (18px, medium)
- `.text-body` - Body text (16px, regular)
- `.text-caption` - Captions (14px, regular)
- `.text-label` - Labels (12px, medium)

### Spacing

Based on a 4px scale:
- `--spacing-1`: 4px
- `--spacing-2`: 8px
- `--spacing-3`: 12px
- `--spacing-4`: 16px
- `--spacing-5`: 20px
- `--spacing-6`: 24px
- `--spacing-8`: 32px

### Border Radius

- `--border-radius-sm`: 4px
- `--border-radius-base`: 8px
- `--border-radius-lg`: 12px
- `--border-radius-xl`: 16px
- `--border-radius-2xl`: 24px
- `--border-radius-full`: 50%

### Shadows

- `--shadow-sm`: Subtle shadow
- `--shadow-base`: Standard shadow
- `--shadow-md`: Medium shadow
- `--shadow-lg`: Large shadow
- `--shadow-card`: Card-specific shadow

## 🧩 Components

### Card Component

```html
<div class="card">
  <h3 class="text-heading">Card Title</h3>
  <p class="text-body">Card content</p>
</div>
```

**Variants:**
- `.card` - Uses `--surface-card` background and shadow tokens
- `.card-subtle` - Uses `--surface-muted` background with a subtle border

### Button Component

```html
<button class="btn btn-primary">Primary Button</button>
<button class="btn btn-secondary">Secondary Button</button>
<button class="btn btn-ghost">Ghost Button</button>
```

**Features:**
- Minimum 44px touch target
- Hover and active states
- Consistent padding and typography
- Semantic color mapping via button token variables

### List Item Component

```html
<div class="list-item">
  <div class="list-item-icon">📱</div>
  <div class="list-item-content">
    <h4 class="list-item-title">Item Title</h4>
    <p class="list-item-subtitle">Item description</p>
  </div>
  <div class="status-indicator status-indicator-success"></div>
</div>
```

**Elements:**
- `.list-item-icon` - 40px icon container
- `.list-item-content` - Flexible content area
- `.list-item-badge` - Status badges (good, warning, bad)
- `.status-indicator` - Small status dots (good, warning, bad, neutral)

### Navigation Components

#### Navigation Bar
```html
<nav class="nav-bar">
  <h1 class="nav-bar-title">App Title</h1>
  <div class="nav-bar-actions">
    <button class="btn btn-ghost">Action</button>
  </div>
</nav>
```

#### Tab Bar
```html
<div class="tab-bar">
  <div class="tab-item tab-item-active">
    <div class="tab-item-icon">🏠</div>
    <span class="tab-item-label">Home</span>
  </div>
</div>
```

### Card Variants

```html
<div class="card-subtle">
  <h4 class="text-subheading">Subtle Card</h4>
  <p class="text-body">This card variant uses a subtle background with a light border.</p>
</div>
```

**Variants:**
- `.card` - Default white background with shadow
- `.card-subtle` - Light background with subtle border

## 📐 Layout Patterns

### Container
```html
<div class="container">
  <!-- Content with consistent padding and max-width -->
</div>
```

### Grid Layout
```html
<div class="grid grid-2">
  <div class="card">Item 1</div>
  <div class="card">Item 2</div>
</div>
```

**Grid Options:**
- `.grid-2` - 2 columns
- `.grid-3` - 3 columns
- Responsive: Stacks to 1 column on mobile

### List View
```html
<div class="list-view">
  <div class="list-item">Item 1</div>
  <div class="list-item">Item 2</div>
</div>
```

### Card Collection
```html
<div class="card-collection">
  <div class="card">Card 1</div>
  <div class="card">Card 2</div>
</div>
```

## 🎯 Utility Classes

### Spacing
- `.p-0` to `.p-8` - Padding utilities
- `.m-0` to `.m-8` - Margin utilities

### Border Radius
- `.rounded-none` - No border radius
- `.rounded-sm` - Small border radius
- `.rounded-base` - Base border radius
- `.rounded-lg` - Large border radius
- `.rounded-xl` - Extra large border radius
- `.rounded-2xl` - 2x large border radius
- `.rounded-full` - Fully rounded

### Shadows
- `.shadow-none` - No shadow
- `.shadow-sm` - Small shadow
- `.shadow-base` - Base shadow
- `.shadow-md` - Medium shadow
- `.shadow-lg` - Large shadow
- `.shadow-card` - Card shadow

### Colors
- `.bg-primary` - Primary action background
- `.bg-surface` - Page background
- `.bg-success` - Success background
- `.bg-warning` - Warning background
- `.bg-error` - Destructive background
- `.bg-primary-blue` - Alias of primary action background

### Text Colors
- `.text-black` - High-contrast foreground text
- `.text-dark-gray` - Alias of foreground text
- `.text-medium-gray` - Muted foreground
- `.text-light-gray` - Low-emphasis foreground

### Transitions
- `.transition-fast` - 150ms transition
- `.transition-normal` - 250ms transition
- `.transition-slow` - 350ms transition

## 🎬 Animations

### Animation Classes
- `.fade-in` - Fade in animation
- `.slide-in` - Slide in from bottom
- `.scale-in` - Scale in animation

### Transition Variables
- `--transition-fast`: 150ms ease-out
- `--transition-normal`: 250ms ease-out
- `--transition-slow`: 350ms ease-out

## 📱 Responsive Design

The design system includes responsive utilities:

```css
@media (max-width: 768px) {
  .grid-2 { grid-template-columns: 1fr; }
  .grid-3 { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 480px) {
  .grid-3 { grid-template-columns: 1fr; }
  .container { padding: var(--spacing-3); }
}
```

## 🎨 Design Principles

### Visual Hierarchy
- **Whitespace**: Generous spacing between elements
- **Typography**: Clear size and weight distinctions
- **Color**: Subtle use of color for categorization and status

### Consistency
- **Card Pattern**: Consistent rounded corners and shadows
- **Spacing**: Uniform padding and margins throughout
- **Iconography**: Consistent icon style and sizing

### Usability
- **Touch Targets**: Minimum 44px for interactive elements
- **Feedback**: Clear visual feedback for interactions
- **Readability**: High contrast text on backgrounds

### Aesthetics
- **Clean Design**: Minimal, uncluttered interfaces
- **Soft Colors**: Muted, pleasant color palette
- **Modern Layout**: Card-based, grid-oriented layouts

## 🔧 Integration with React/TypeScript

### TypeScript Definitions

Create a `design-tokens.d.ts` file:

```typescript
declare module '*.css' {
  const content: { [className: string]: string };
  export default content;
}

// Design token types
export interface DesignTokens {
  colors: {
    primitives: {
      grey: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800' | '900', string>;
      blue: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800', string>;
      lime: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800', string>;
      coral: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800', string>;
      pink: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800', string>;
      green: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800', string>;
      red: Record<'100' | '200' | '300' | '400' | '500' | '600' | '700' | '800', string>;
    };
    semantic: {
      mode: 'light' | 'dark';
      background: string;
      foreground: string;
      card: string;
      cardForeground: string;
      primary: string;
      primaryForeground: string;
      secondary: string;
      secondaryForeground: string;
      muted: string;
      mutedForeground: string;
      accent: string;
      accentForeground: string;
      success: string;
      successForeground: string;
      destructive: string;
      destructiveForeground: string;
      border: string;
      input: string;
      chart1: string;
      chart2: string;
      chart3: string;
      chart4: string;
      chart5: string;
    };
  };
  spacing: {
    [key: string]: string;
  };
  typography: {
    fontSizes: {
      [key: string]: string;
    };
    fontWeights: {
      [key: string]: number;
    };
  };
}
```

### React Component Example

```tsx
import React from 'react';
import './design-tokens.css';
import './example-components.css';

interface CardProps {
  title: string;
  children: React.ReactNode;
  variant?: 'default' | 'colored';
}

export const Card: React.FC<CardProps> = ({ 
  title, 
  children, 
  variant = 'default' 
}) => {
  return (
    <div className={`card ${variant === 'colored' ? 'card-colored' : ''}`}>
      <h3 className="text-heading">{title}</h3>
      {children}
    </div>
  );
};
```

## 🧪 Testing

Open `example-usage.html` in your browser to see all components and patterns in action. This file demonstrates:

- All typography styles
- Button variants and states
- Card layouts
- List items with different states
- Navigation components
- Note interface with color picker
- Grid layouts
- Utility classes
- Interactive elements

## 📚 Best Practices

1. **Always use design tokens** instead of hardcoded values
2. **Follow the spacing scale** for consistent layouts
3. **Use semantic color names** for better maintainability
4. **Apply utility classes** for common styling needs
5. **Maintain touch target sizes** (minimum 44px)
6. **Test on multiple devices** to ensure responsive behavior
7. **Use the component patterns** for consistent UI structure

## 🔄 Updates and Maintenance

When updating the design system:

1. Update `design-system.json` with new tokens
2. Regenerate `design-tokens.css` with new custom properties
3. Update component examples in `example-components.css`
4. Test changes in `example-usage.html`
5. Update this documentation

## 📞 Support

For questions about the design system or implementation, refer to:
- `design-system.json` - Complete specification
- `example-usage.html` - Live examples
- `.cursorrules` - AI assistant guidelines

---

*This design system follows modern best practices for maintainable, scalable, and consistent UI development.*
