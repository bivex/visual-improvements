// ==UserScript==
// @name         Tongue Twister WCAG 2.2 AAA Accessible CSS
// @namespace    http://tampermonkey.net/
// @version      2.0
// @description  Modernize tongue-twister.net with WCAG 2.2 AAA accessibility compliance
// @author       You
// @match        https://www.tongue-twister.net/*
// @match        http://www.tongue-twister.net/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    
    // Create and inject WCAG 2.2 AAA compliant CSS
    const accessibleCSS = `
        /* WCAG 2.2 AAA Compliant CSS for Tongue Twister */
        
        /* Root variables for consistent theming */
        :root {
            --primary-text: #000000;
            --secondary-text: #262626;
            --background-primary: #ffffff;
            --background-secondary: #f8f9fa;
            --accent-color: #0066cc;
            --accent-hover: #004499;
            --border-color: #767676;
            --error-color: #cc0000;
            --success-color: #006600;
            --focus-color: #0066cc;
            --shadow-subtle: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        /* Base styles with high contrast */
        body {
            color: var(--primary-text) !important;
            background-color: var(--background-primary) !important;
            background-image: none !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 18px !important; /* Minimum 18px for AAA */
            line-height: 1.6 !important; /* Minimum 1.5 for AAA */
            margin: 0 !important;
            padding: 24px !important; /* Minimum 24px for touch targets */
            font-weight: 400 !important;
            word-spacing: 0.16em !important; /* AAA spacing requirement */
            letter-spacing: 0.12em !important;
        }

        /* Skip navigation link for screen readers */
        .skip-nav {
            position: absolute;
            top: -40px;
            left: 6px;
            background: var(--primary-text);
            color: var(--background-primary);
            padding: 8px;
            text-decoration: none;
            border-radius: 4px;
            z-index: 1000;
            font-size: 18px;
        }

        .skip-nav:focus {
            top: 6px;
        }

        /* Content container with proper spacing */
        body > * {
            max-width: 1200px;
            margin: 0 auto 24px auto;
            background: var(--background-primary);
            padding: 32px;
            border: 2px solid var(--border-color);
            border-radius: 8px;
            box-shadow: var(--shadow-subtle);
        }

        /* Text elements with AAA contrast */
        p, dl, ul, ol, li, td, th, blockquote, tr {
            color: var(--primary-text) !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 18px !important;
            line-height: 1.6 !important;
            margin-bottom: 16px !important;
            word-spacing: 0.16em !important;
            letter-spacing: 0.12em !important;
        }

        /* List improvements */
        ul, ol {
            padding-left: 32px !important;
        }

        li {
            margin-bottom: 8px !important;
            padding-left: 8px !important;
        }

        /* Links with AAA contrast and clear focus */
        a:link, a:visited {
            color: var(--accent-color) !important;
            text-decoration: underline !important;
            text-decoration-thickness: 2px !important;
            text-underline-offset: 3px !important;
            transition: none !important; /* Remove animations for accessibility */
            font-weight: 500 !important;
        }

        a:hover {
            color: var(--accent-hover) !important;
            text-decoration: underline !important;
            text-decoration-thickness: 3px !important;
            background-color: rgba(0, 102, 204, 0.1) !important;
            padding: 2px 4px !important;
            border-radius: 3px !important;
        }

        a:focus {
            outline: 3px solid var(--focus-color) !important;
            outline-offset: 2px !important;
            background-color: rgba(0, 102, 204, 0.1) !important;
            padding: 2px 4px !important;
            border-radius: 3px !important;
        }

        a:active {
            color: var(--accent-hover) !important;
            background-color: rgba(0, 102, 204, 0.2) !important;
        }

        /* Minimum touch target size 44x44px */
        a, button, input, select, textarea {
            min-height: 44px !important;
            min-width: 44px !important;
            padding: 12px 16px !important;
            display: inline-block !important;
            box-sizing: border-box !important;
        }

        a.P:link, a.P:visited, a.P:active, a.P:hover {
            color: var(--primary-text) !important;
            text-decoration: none !important;
            cursor: default !important;
        }

        /* Table styles with high contrast */
        .TX {
            background-color: var(--background-secondary) !important;
            padding: 20px !important;
            border: 2px solid var(--border-color) !important;
            border-radius: 8px !important;
            text-align: left !important;
            margin: 16px 0 !important;
        }

        td.PAD {
            padding: 16px 20px !important;
        }

        .TW {
            background-color: var(--background-primary) !important;
            padding: 20px !important;
            border: 2px solid var(--border-color) !important;
            border-radius: 8px !important;
            text-align: center !important;
            margin: 16px 0 !important;
        }

        /* Headings with proper hierarchy and spacing */
        h1 {
            color: var(--primary-text) !important;
            font-weight: 700 !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 2.5rem !important; /* 40px minimum */
            line-height: 1.2 !important;
            text-align: center !important;
            margin: 32px 0 24px 0 !important;
            padding: 16px 0 !important;
            border-bottom: 3px solid var(--border-color) !important;
            word-spacing: 0.16em !important;
            letter-spacing: 0.05em !important;
        }

        h2 {
            color: var(--primary-text) !important;
            font-weight: 600 !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 2rem !important; /* 32px minimum */
            line-height: 1.3 !important;
            text-align: center !important;
            margin: 28px 0 20px 0 !important;
            padding: 12px 0 !important;
            border-bottom: 2px solid var(--border-color) !important;
            word-spacing: 0.16em !important;
            letter-spacing: 0.05em !important;
        }

        h2.RD {
            color: var(--error-color) !important;
            border-bottom-color: var(--error-color) !important;
        }

        h3 {
            color: var(--primary-text) !important;
            font-weight: 600 !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 1.5rem !important; /* 24px minimum */
            line-height: 1.4 !important;
            text-align: center !important;
            margin: 24px 0 16px 0 !important;
            padding: 8px 0 !important;
            word-spacing: 0.16em !important;
            letter-spacing: 0.05em !important;
        }

        h4, h5, h6 {
            color: var(--primary-text) !important;
            font-weight: 600 !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 1.25rem !important; /* 20px minimum */
            line-height: 1.4 !important;
            margin: 20px 0 12px 0 !important;
            word-spacing: 0.16em !important;
            letter-spacing: 0.05em !important;
        }

        /* Specific text classes with AAA contrast */
        .LANLIST {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif !important;
            font-size: 18px !important;
            background-color: var(--background-secondary) !important;
            padding: 16px !important;
            border: 2px solid var(--border-color) !important;
            border-radius: 8px !important;
            border-left: 4px solid var(--accent-color) !important;
            margin: 16px 0 !important;
            line-height: 1.6 !important;
        }

        .TXT {
            font-size: 18px !important;
            text-align: center !important;
            font-weight: 500 !important;
            color: var(--primary-text) !important;
            line-height: 1.6 !important;
            margin: 16px 0 !important;
            padding: 12px !important;
        }

        .SLL, .TRA {
            font-size: 18px !important;
            text-align: left !important;
            color: var(--primary-text) !important;
            padding: 12px !important;
            line-height: 1.6 !important;
            margin: 8px 0 !important;
        }

        .SLC, .LAT {
            font-size: 18px !important;
            text-align: center !important;
            color: var(--primary-text) !important;
            padding: 12px !important;
            line-height: 1.6 !important;
            margin: 8px 0 !important;
        }

        .COM {
            font-size: 18px !important;
            text-align: center !important;
            font-style: italic !important;
            color: var(--secondary-text) !important;
            background-color: var(--background-secondary) !important;
            padding: 16px !important;
            border: 2px solid var(--border-color) !important;
            border-radius: 8px !important;
            margin: 16px 0 !important;
            line-height: 1.6 !important;
        }

        small {
            font-size: 16px !important; /* Minimum readable size */
            color: var(--secondary-text) !important;
            line-height: 1.6 !important;
        }

        /* Tables with proper structure */
        table {
            border-collapse: collapse !important;
            width: 100% !important;
            margin: 24px 0 !important;
            background-color: var(--background-primary) !important;
            border: 2px solid var(--border-color) !important;
            border-radius: 8px !important;
            overflow: hidden !important;
        }

        caption {
            font-size: 18px !important;
            font-weight: 600 !important;
            color: var(--primary-text) !important;
            padding: 16px !important;
            text-align: left !important;
            background-color: var(--background-secondary) !important;
            border-bottom: 2px solid var(--border-color) !important;
        }

        th, td {
            padding: 16px 20px !important;
            border: 1px solid var(--border-color) !important;
            text-align: left !important;
            vertical-align: top !important;
        }

        th {
            background-color: var(--background-secondary) !important;
            color: var(--primary-text) !important;
            font-weight: 600 !important;
            font-size: 18px !important;
        }

        tr:nth-child(even) {
            background-color: rgba(0, 0, 0, 0.02) !important;
        }

        tr:hover, tr:focus-within {
            background-color: rgba(0, 102, 204, 0.05) !important;
            outline: 2px solid var(--focus-color) !important;
            outline-offset: -2px !important;
        }

        /* Form elements */
        input, select, textarea, button {
            font-size: 18px !important;
            line-height: 1.6 !important;
            padding: 12px 16px !important;
            border: 2px solid var(--border-color) !important;
            border-radius: 4px !important;
            background-color: var(--background-primary) !important;
            color: var(--primary-text) !important;
            font-family: inherit !important;
        }

        input:focus, select:focus, textarea:focus, button:focus {
            outline: 3px solid var(--focus-color) !important;
            outline-offset: 2px !important;
            border-color: var(--focus-color) !important;
        }

        button {
            background-color: var(--accent-color) !important;
            color: var(--background-primary) !important;
            font-weight: 600 !important;
            cursor: pointer !important;
        }

        button:hover {
            background-color: var(--accent-hover) !important;
        }

        button:disabled {
            background-color: var(--border-color) !important;
            cursor: not-allowed !important;
            opacity: 0.7 !important;
        }

        /* Responsive design with proper breakpoints */
        @media (max-width: 768px) {
            body {
                font-size: 18px !important; /* Maintain minimum size */
                padding: 16px !important;
            }
            
            body > * {
                padding: 24px !important;
            }
            
            h1 {
                font-size: 2rem !important; /* 32px minimum */
            }
            
            h2 {
                font-size: 1.75rem !important; /* 28px minimum */
            }
            
            h3 {
                font-size: 1.5rem !important; /* 24px minimum */
            }

            table {
                font-size: 16px !important;
            }

            th, td {
                padding: 12px 8px !important;
            }
        }

        @media (max-width: 480px) {
            body {
                padding: 12px !important;
            }
            
            body > * {
                padding: 16px !important;
            }
            
            table, thead, tbody, th, td, tr {
                display: block !important;
            }
            
            thead tr {
                position: absolute !important;
                top: -9999px !important;
                left: -9999px !important;
            }
            
            tr {
                border: 2px solid var(--border-color) !important;
                margin-bottom: 16px !important;
                padding: 16px !important;
                border-radius: 8px !important;
            }
            
            td {
                border: none !important;
                position: relative !important;
                padding-left: 50% !important;
                text-align: left !important;
            }
            
            td:before {
                content: attr(data-label) !important;
                position: absolute !important;
                left: 16px !important;
                width: 45% !important;
                padding-right: 10px !important;
                white-space: nowrap !important;
                font-weight: 600 !important;
            }
        }

        /* High contrast mode support */
        @media (prefers-contrast: high) {
            :root {
                --primary-text: #000000;
                --secondary-text: #000000;
                --background-primary: #ffffff;
                --background-secondary: #ffffff;
                --accent-color: #0000ff;
                --accent-hover: #000080;
                --border-color: #000000;
                --focus-color: #0000ff;
            }
            
            * {
                border-color: #000000 !important;
            }
        }

        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            * {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
                scroll-behavior: auto !important;
            }
        }

        /* Print styles */
        @media print {
            * {
                background: transparent !important;
                color: #000000 !important;
                box-shadow: none !important;
                text-shadow: none !important;
            }
            
            a, a:visited {
                text-decoration: underline !important;
            }
            
            a[href]:after {
                content: " (" attr(href) ")" !important;
            }
            
            thead {
                display: table-header-group !important;
            }
            
            tr, img {
                page-break-inside: avoid !important;
            }
            
            img {
                max-width: 100% !important;
            }
            
            p, h2, h3 {
                orphans: 3 !important;
                widows: 3 !important;
            }
            
            h2, h3 {
                page-break-after: avoid !important;
            }
        }

        /* Screen reader only content */
        .sr-only {
            position: absolute !important;
            width: 1px !important;
            height: 1px !important;
            padding: 0 !important;
            margin: -1px !important;
            overflow: hidden !important;
            clip: rect(0, 0, 0, 0) !important;
            border: 0 !important;
        }

        /* Focus management */
        [tabindex="-1"]:focus {
            outline: 0 !important;
        }

        /* Ensure focus is visible */
        *:focus {
            outline: 3px solid var(--focus-color) !important;
            outline-offset: 2px !important;
        }

        /* Smooth scrolling for those who can handle it */
        @media (prefers-reduced-motion: no-preference) {
            html {
                scroll-behavior: smooth !important;
            }
        }
    `;

    // Create style element and add to head
    const styleElement = document.createElement('style');
    styleElement.type = 'text/css';
    styleElement.innerHTML = accessibleCSS;
    document.head.appendChild(styleElement);

    // Add skip navigation link
    const skipNav = document.createElement('a');
    skipNav.href = '#main-content';
    skipNav.className = 'skip-nav';
    skipNav.textContent = 'Skip to main content';
    document.body.insertBefore(skipNav, document.body.firstChild);

    // Add main content wrapper if it doesn't exist
    if (!document.getElementById('main-content')) {
        const mainContent = document.createElement('main');
        mainContent.id = 'main-content';
        mainContent.setAttribute('tabindex', '-1');
        
        // Move all body content to main
        while (document.body.children.length > 1) {
            mainContent.appendChild(document.body.children[1]);
        }
        document.body.appendChild(mainContent);
    }

    // Add table headers and captions where missing
    const tables = document.querySelectorAll('table');
    tables.forEach((table, index) => {
        if (!table.querySelector('caption')) {
            const caption = document.createElement('caption');
            caption.textContent = `Table ${index + 1}`;
            table.insertBefore(caption, table.firstChild);
        }
        
        // Add scope attributes to headers
        const headers = table.querySelectorAll('th');
        headers.forEach(header => {
            if (!header.hasAttribute('scope')) {
                header.setAttribute('scope', 'col');
            }
        });
    });

    // Add aria-labels to links without descriptive text
    const links = document.querySelectorAll('a');
    links.forEach(link => {
        if (link.textContent.trim().length < 3 && !link.hasAttribute('aria-label')) {
            link.setAttribute('aria-label', 'Link: ' + (link.href || 'undefined'));
        }
    });

})();
