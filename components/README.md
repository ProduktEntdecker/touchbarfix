# TouchBarFix Website Components

This directory contains reusable components for the TouchBarFix website.

## Footer Component

### Overview
Centralized footer component that automatically detects the page's CSS framework and renders appropriately.

### Features
- **Auto-detection**: Automatically uses Tailwind CSS or inline CSS styling
- **Single source of truth**: All footer content managed in one place
- **Easy integration**: Just add two lines to any HTML page
- **Consistent styling**: Maintains visual consistency across all pages
- **Responsive**: Works on all screen sizes

### Usage

#### Step 1: Add Footer Container
Add this div where you want the footer to appear:
```html
<div id="touchbarfix-footer"></div>
```

#### Step 2: Include Footer Script
Add this script before the closing `</body>` tag:
```html
<script src="/components/footer.js"></script>
```

#### Complete Example
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Your Page</title>
    <!-- Your other head content -->
</head>
<body>
    <!-- Your page content -->
    
    <!-- Footer Component -->
    <div id="touchbarfix-footer"></div>
    
    <!-- Footer Component Script -->
    <script src="/components/footer.js"></script>
</body>
</html>
```

### Automatic Styling Detection

The component automatically detects:
- **Tailwind CSS pages**: Uses Tailwind utility classes
- **Non-Tailwind pages**: Uses inline CSS with hover effects

Detection methods:
1. Looks for Tailwind CSS link/script tags
2. Scans for common Tailwind classes in the DOM
3. Falls back to inline CSS if no Tailwind detected

### Footer Content

The footer includes:
- **Title**: TouchBarFix
- **Description**: Simple automation for Touch Bar software restarts
- **Navigation links**: Support, Terms, Privacy, Imprint
- **Copyright**: © 2025 TouchBarFix • Created by Dr. Florian Steiner

### Customization

To update footer content, edit `footer.js`:
```javascript
const footerData = {
    title: 'TouchBarFix',
    description: 'Simple automation for Touch Bar software restarts',
    links: [
        { href: '/support.html', text: 'Support' },
        { href: '/terms.html', text: 'Terms' },
        { href: '/privacy.html', text: 'Privacy' },
        { href: '/imprint.html', text: 'Imprint' }
    ],
    copyright: '© 2025 TouchBarFix • Created by Dr. Florian Steiner, AI Product Manager • Co-created with Claude Code'
};
```

### Files Updated

The following pages now use the centralized footer component:
- `index.html` (Tailwind CSS version)
- `imprint.html` (Tailwind CSS version)  
- `support.html` (Inline CSS version)
- `terms.html` (Inline CSS version)
- `privacy.html` (Inline CSS version)

### Benefits Achieved

1. **Single Source of Truth**: Footer content managed in one file
2. **Consistency**: All pages show identical footer information
3. **Easy Maintenance**: Change footer once, updates everywhere
4. **Reduced Duplication**: No more copy-paste footer HTML
5. **Future-Proof**: Easy to add new pages with consistent footer

### Troubleshooting

#### Footer Not Showing
- Check that `id="touchbarfix-footer"` exists in your HTML
- Verify the footer script is loaded before `</body>`
- Check browser console for JavaScript errors

#### Wrong Styling
- Verify Tailwind CSS detection is working correctly
- Check browser console for footer type: `Tailwind CSS` or `Simple CSS`
- Manually test with `window.TouchBarFixFooter.init()`

#### Content Updates Not Showing
- Clear browser cache
- Check that `footer.js` is loading the latest version
- Verify no local caching on CDN/server

### Debugging

The footer component logs initialization information:
```javascript
console.log(`TouchBarFix Footer initialized: ${useTailwind ? 'Tailwind CSS' : 'Simple CSS'} version`);
```

You can also check the footer metadata:
```javascript
const footer = document.getElementById('touchbarfix-footer');
console.log(footer.dataset.footerType);    // 'tailwind' or 'simple'
console.log(footer.dataset.footerVersion); // '1.0.0'
```

### Manual Initialization

If needed, you can manually initialize the footer:
```javascript
window.TouchBarFixFooter.init();
```

Or access the footer data:
```javascript
console.log(window.TouchBarFixFooter.data);
```

---

**Component Version**: 1.0.0  
**Last Updated**: August 23, 2025  
**Maintainer**: Dr. Florian Steiner via Claude Code