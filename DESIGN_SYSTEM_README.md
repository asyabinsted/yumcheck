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
  background: var(--color-primary-background);
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

#### Primary Colors
- `--color-primary-background`: #FFFFFF
- `--color-primary-surface`: #F8F9FA
- `--color-primary-card-background`: #FFFFFF

#### Accent Colors
- `--color-accent-primary-blue`: #007AFF

#### Semantic Colors
- `--color-semantic-success`: #34C759
- `--color-semantic-warning`: #FFD60A
- `--color-semantic-error`: #FF3B30

#### Status Indicators
- `--color-status-good`: #34C759
- `--color-status-bad`: #FF3B30
- `--color-status-warning`: #FFD60A

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
- `.card` - Default white background
- `.card-subtle` - Subtle background with light border

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
- `.bg-primary` - Primary background
- `.bg-surface` - Surface background
- `.bg-success` - Success background
- `.bg-warning` - Warning background
- `.bg-error` - Error background
- `.bg-primary-blue` - Primary blue background

### Text Colors
- `.text-black` - Black text
- `.text-dark-gray` - Dark gray text
- `.text-medium-gray` - Medium gray text
- `.text-light-gray` - Light gray text

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
    primary: {
      background: string;
      surface: string;
      cardBackground: string;
    };
    accent: {
      blue: string;
      green: string;
      yellow: string;
      orange: string;
      red: string;
      purple: string;
      pink: string;
    };
    semantic: {
      success: string;
      warning: string;
      error: string;
      info: string;
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
