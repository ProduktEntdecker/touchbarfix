/**
 * TouchBarFix Footer Component
 * Centralized footer for all pages with automatic styling detection
 * Usage: Add <script src="/components/footer.js"></script> before </body>
 * Then add <div id="touchbarfix-footer"></div> where footer should appear
 */

(function() {
    'use strict';
    
    // Footer content data
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
    
    // Detect if page has Tailwind CSS
    function hasTailwindCSS() {
        // Check for Tailwind CSS link tags
        const tailwindLinks = document.querySelectorAll('link[href*="tailwind"]');
        if (tailwindLinks.length > 0) return true;
        
        // Check for Tailwind script tags
        const tailwindScripts = document.querySelectorAll('script[src*="tailwind"]');
        if (tailwindScripts.length > 0) return true;
        
        // Check for common Tailwind classes in DOM
        const commonTailwindClasses = ['bg-gray-', 'text-white', 'py-12', 'px-4', 'max-w-'];
        for (const className of commonTailwindClasses) {
            if (document.querySelector(`[class*="${className}"]`)) return true;
        }
        
        return false;
    }
    
    // Generate Tailwind CSS footer HTML
    function generateTailwindFooter() {
        const linksHTML = footerData.links.map(link => 
            `<a href="${link.href}" class="text-gray-400 hover:text-white transition-colors">${link.text}</a>`
        ).join('\n                ');
        
        return `
            <footer class="bg-gray-900 text-white py-12">
                <div class="max-w-4xl mx-auto text-center px-4">
                    <h3 class="text-2xl font-bold mb-4">${footerData.title}</h3>
                    <p class="text-gray-400 mb-6">${footerData.description}</p>
                    
                    <div class="flex justify-center space-x-6 mb-6">
                        ${linksHTML}
                    </div>
                    
                    <p class="text-gray-500 text-sm">
                        ${footerData.copyright}
                    </p>
                </div>
            </footer>
        `;
    }
    
    // Generate inline CSS footer HTML
    function generateSimpleFooter() {
        const linksHTML = footerData.links.map(link => 
            `<a href="${link.href}" style="color: #9ca3af; text-decoration: none; margin: 0 12px; font-size: 16px;" 
               onmouseover="this.style.color='white'" onmouseout="this.style.color='#9ca3af'">${link.text}</a>`
        ).join('\n            ');
        
        return `
            <footer style="background: #111827; color: white; padding: 48px 0; text-align: center;">
                <div style="max-width: 1024px; margin: 0 auto; padding: 0 16px;">
                    <h3 style="font-size: 24px; font-weight: bold; margin-bottom: 16px; color: white;">${footerData.title}</h3>
                    <p style="color: #9ca3af; margin-bottom: 24px; font-size: 16px;">${footerData.description}</p>
                    
                    <div style="margin-bottom: 24px;">
                        ${linksHTML}
                    </div>
                    
                    <p style="color: #6b7280; font-size: 14px; margin: 0;">
                        ${footerData.copyright}
                    </p>
                </div>
            </footer>
        `;
    }
    
    // Initialize footer component
    function initFooter() {
        const footerContainer = document.getElementById('touchbarfix-footer');
        if (!footerContainer) {
            console.warn('TouchBarFix Footer: No element with id="touchbarfix-footer" found');
            return;
        }
        
        const useTailwind = hasTailwindCSS();
        const footerHTML = useTailwind ? generateTailwindFooter() : generateSimpleFooter();
        
        footerContainer.innerHTML = footerHTML;
        
        // Add metadata for debugging
        footerContainer.dataset.footerType = useTailwind ? 'tailwind' : 'simple';
        footerContainer.dataset.footerVersion = '1.0.0';
        
        console.log(`TouchBarFix Footer initialized: ${useTailwind ? 'Tailwind CSS' : 'Simple CSS'} version`);
    }
    
    // Auto-initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initFooter);
    } else {
        initFooter();
    }
    
    // Export for manual initialization if needed
    window.TouchBarFixFooter = {
        init: initFooter,
        data: footerData
    };
    
})();