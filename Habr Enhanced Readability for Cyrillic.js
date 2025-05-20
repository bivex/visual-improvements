/**
 * Copyright (c) 2025 [Your Name], Individual Entrepreneur
 * INN: [Your Tax ID Number]
 * Created: 2025-05-20 05:01
 * Last Updated: 2025-05-20 05:04
 * All rights reserved. Unauthorized copying, modification,
 * distribution, or use is strictly prohibited.
 */

// ==UserScript==
// @name         Habr Enhanced Readability for Cyrillic
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Enhances readability of Cyrillic text on Habr.com by improving font rendering, spacing, and contrast
// @author       You
// @match        https://habr.com/*
// @match        https://*.habr.com/*
// @grant        GM_addStyle
// @grant        GM_setValue
// @grant        GM_getValue
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';
    
    // User preferences with default values
    const prefs = {
        fontSize: GM_getValue('fontSize', 18),
        lineHeight: GM_getValue('lineHeight', 1.7),
        fontFamily: GM_getValue('fontFamily', 'PT Serif'),
        letterSpacing: GM_getValue('letterSpacing', 0.01),
        paragraphSpacing: GM_getValue('paragraphSpacing', 1.5),
        focusModeActive: GM_getValue('focusModeActive', false),
        lineHighlighting: GM_getValue('lineHighlighting', false),
        highContrast: GM_getValue('highContrast', false)
    };
    
    // Available Cyrillic-optimized fonts
    const cyrillicFonts = [
        // Serif fonts
        'PT Serif',
        'Noto Serif',
        'Lora',
        'Literata',
        // Sans-serif fonts
        'PT Sans',
        'Roboto',
        'Open Sans',
        'Fira Sans',
        'Ubuntu',
        'Source Sans Pro',
        'Nunito',
        'Inter',
        'Montserrat',
        'Noto Sans'
    ];
    
    // Font categories for the dropdown
    const fontCategories = {
        serif: ['PT Serif', 'Noto Serif', 'Lora', 'Literata'],
        sansSerif: ['PT Sans', 'Roboto', 'Open Sans', 'Fira Sans', 'Ubuntu', 'Source Sans Pro', 'Nunito', 'Inter', 'Montserrat', 'Noto Sans']
    };
    
    // Add custom stylesheet to improve Cyrillic readability
    GM_addStyle(`
        /* Improve font rendering for Cyrillic */
        body {
            -webkit-font-smoothing: antialiased !important;
            -moz-osx-font-smoothing: grayscale !important;
            text-rendering: optimizeLegibility !important;
        }
        
        /* Enhance readability of article content */
        .tm-article-body, .article-formatted-body {
            font-family: '${prefs.fontFamily}', 'Georgia', serif !important;
            font-size: ${prefs.fontSize}px !important;
            line-height: ${prefs.lineHeight} !important;
            letter-spacing: ${prefs.letterSpacing}em !important;
            max-width: 760px !important;
            margin: 0 auto !important;
            color: ${prefs.highContrast ? '#000' : '#222'} !important;
            font-feature-settings: "kern" 1, "liga" 1 !important;
            word-wrap: break-word !important;
            overflow-wrap: break-word !important;
            hyphens: auto !important;
        }
        
        /* Improve paragraph spacing */
        .tm-article-body p, .article-formatted-body p {
            margin-bottom: ${prefs.paragraphSpacing}em !important;
        }
        
        /* Dark mode improvements */
        @media (prefers-color-scheme: dark) {
            body.high-contrast-active .tm-article-body,
            body.high-contrast-active .article-formatted-body {
                color: #ffffff !important;
                background-color: #121212 !important;
            }
            
            .tm-article-body, .article-formatted-body {
                color: ${prefs.highContrast ? '#fff' : '#e8e8e8'} !important;
                background-color: ${prefs.highContrast ? '#121212' : '#1f1f1f'} !important;
            }
            
            body, body.high-contrast-active {
                background-color: ${prefs.highContrast ? '#121212' : '#1f1f1f'} !important;
            }
            
            .tm-page-article__body, body.high-contrast-active .tm-page-article__body {
                background-color: ${prefs.highContrast ? '#121212' : '#1f1f1f'} !important;
            }
            
            a, body.high-contrast-active a {
                color: ${prefs.highContrast ? '#90caf9' : '#7db9e8'} !important;
            }
        }
        
        /* Improve headings */
        .tm-article-body h1, .tm-article-body h2, .tm-article-body h3,
        .article-formatted-body h1, .article-formatted-body h2, .article-formatted-body h3 {
            font-family: '${prefs.fontFamily}', 'Arial', sans-serif !important;
            font-weight: 700 !important;
            margin-top: 1.5em !important;
            margin-bottom: 0.8em !important;
            line-height: 1.3 !important;
            letter-spacing: -0.01em !important;
        }
        
        /* Add wider container for better reading */
        .tm-article-presenter__content_narrow {
            max-width: 820px !important;
        }
        
        /* Add focus mode toggle */
        body.focus-mode-active .tm-layout__wrapper > *:not(.tm-layout),
        body.focus-mode-active .tm-layout > *:not(.tm-page),
        body.focus-mode-active .tm-page__wrapper > *:not(.tm-page__main),
        body.focus-mode-active .tm-page__main > *:not(.tm-article-presenter),
        body.focus-mode-active .tm-article-presenter > *:not(.tm-article-presenter__body),
        body.focus-mode-active .tm-layout__container > *:not(main) {
            display: none !important;
        }
        
        body.focus-mode-active .tm-article-presenter {
            margin-top: 20px !important;
        }
        
        /* Add reading progress bar */
        .reading-progress-bar {
            position: fixed;
            top: 0;
            left: 0;
            width: 0%;
            height: 4px;
            background-color: #4096ff;
            z-index: 9999;
            transition: width 0.1s;
        }
        
        /* Line highlighting effect */
        body.line-highlighting-active p:hover,
        body.line-highlighting-active li:hover {
            background-color: rgba(255, 255, 0, 0.1) !important;
            transition: background-color 0.2s ease-in-out;
            border-radius: 2px;
        }
        
        @media (prefers-color-scheme: dark) {
            body.line-highlighting-active p:hover,
            body.line-highlighting-active li:hover {
                background-color: rgba(100, 149, 237, 0.1) !important;
            }
        }
        
        /* Reading tools container */
        .reading-tools {
            position: fixed;
            right: 20px;
            top: 20px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            z-index: 9999;
        }
        
        .reading-tool-btn {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: rgba(255, 255, 255, 0.8);
            border: 1px solid #ccc;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            transition: all 0.2s;
        }
        
        .reading-tool-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 3px 7px rgba(0, 0, 0, 0.15);
        }
        
        .reading-tool-btn.active {
            background-color: #e6f7ff;
            border-color: #91d5ff;
        }
        
        /* Dark mode readability improvements */
        @media (prefers-color-scheme: dark) {
            .reading-tool-btn {
                background-color: rgba(40, 40, 40, 0.8);
                border-color: #444;
                color: #ddd;
            }
            
            .reading-tool-btn.active {
                background-color: #001529;
                border-color: #177ddc;
                color: #fff;
            }
        }
        
        /* Settings panel */
        .readability-settings {
            position: fixed;
            right: 70px;
            top: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.15);
            padding: 15px;
            width: 300px;
            z-index: 9998;
            display: none;
        }
        
        @media (prefers-color-scheme: dark) {
            .readability-settings {
                background-color: #292929;
                color: #e0e0e0;
                border: 1px solid #444;
            }
        }
        
        .readability-settings h3 {
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 16px;
            border-bottom: 1px solid #eee;
            padding-bottom: 8px;
        }
        
        @media (prefers-color-scheme: dark) {
            .readability-settings h3 {
                border-color: #444;
            }
        }
        
        .settings-group {
            margin-bottom: 15px;
        }
        
        .settings-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .settings-row label {
            flex: 1;
        }
        
        .settings-row select,
        .settings-row input[type="range"] {
            flex: 1;
        }
        
        .settings-row input[type="checkbox"] {
            width: 18px;
            height: 18px;
        }
        
        .settings-close-btn {
            background: none;
            border: none;
            position: absolute;
            right: 10px;
            top: 10px;
            cursor: pointer;
            font-size: 16px;
            color: #666;
        }
        
        @media (prefers-color-scheme: dark) {
            .settings-close-btn {
                color: #aaa;
            }
        }
    `);

    // Wait for document to be fully loaded
    window.addEventListener('DOMContentLoaded', function() {
        // Apply saved settings
        if (prefs.focusModeActive) {
            document.body.classList.add('focus-mode-active');
        }
        
        if (prefs.lineHighlighting) {
            document.body.classList.add('line-highlighting-active');
        }
        
        if (prefs.highContrast) {
            document.body.classList.add('high-contrast-active');
        }
        
        // Create and add reading progress bar
        const progressBar = document.createElement('div');
        progressBar.className = 'reading-progress-bar';
        document.body.appendChild(progressBar);
        
        // Create reading tools container
        const toolsContainer = document.createElement('div');
        toolsContainer.className = 'reading-tools';
        
        // Focus mode button
        const focusBtn = document.createElement('button');
        focusBtn.className = 'reading-tool-btn focus-mode-btn' + (prefs.focusModeActive ? ' active' : '');
        focusBtn.innerHTML = '👁️';
        focusBtn.title = 'Фокус-режим';
        focusBtn.addEventListener('click', toggleFocusMode);
        
        // Font size increase button
        const fontIncreaseBtn = document.createElement('button');
        fontIncreaseBtn.className = 'reading-tool-btn font-increase-btn';
        fontIncreaseBtn.innerHTML = 'A+';
        fontIncreaseBtn.title = 'Увеличить шрифт';
        fontIncreaseBtn.addEventListener('click', increaseFontSize);
        
        // Font size decrease button
        const fontDecreaseBtn = document.createElement('button');
        fontDecreaseBtn.className = 'reading-tool-btn font-decrease-btn';
        fontDecreaseBtn.innerHTML = 'A-';
        fontDecreaseBtn.title = 'Уменьшить шрифт';
        fontDecreaseBtn.addEventListener('click', decreaseFontSize);
        
        // Line highlighting button
        const lineHighlightBtn = document.createElement('button');
        lineHighlightBtn.className = 'reading-tool-btn line-highlight-btn' + (prefs.lineHighlighting ? ' active' : '');
        lineHighlightBtn.innerHTML = '¶';
        lineHighlightBtn.title = 'Подсветка строк';
        lineHighlightBtn.addEventListener('click', toggleLineHighlighting);
        
        // High contrast button
        const contrastBtn = document.createElement('button');
        contrastBtn.className = 'reading-tool-btn contrast-btn' + (prefs.highContrast ? ' active' : '');
        contrastBtn.innerHTML = '◐';
        contrastBtn.title = 'Высокая контрастность';
        contrastBtn.addEventListener('click', toggleHighContrast);
        
        // Settings button
        const settingsBtn = document.createElement('button');
        settingsBtn.className = 'reading-tool-btn settings-btn';
        settingsBtn.innerHTML = '⚙️';
        settingsBtn.title = 'Настройки';
        settingsBtn.addEventListener('click', toggleSettings);
        
        // Add buttons to container
        toolsContainer.appendChild(focusBtn);
        toolsContainer.appendChild(fontIncreaseBtn);
        toolsContainer.appendChild(fontDecreaseBtn);
        toolsContainer.appendChild(lineHighlightBtn);
        toolsContainer.appendChild(contrastBtn);
        toolsContainer.appendChild(settingsBtn);
        
        // Add container to body
        document.body.appendChild(toolsContainer);
        
        // Create settings panel
        createSettingsPanel();
        
        // Update progress bar as user scrolls
        window.addEventListener('scroll', updateProgressBar);
        
        // Initialize
        updateProgressBar();
    });
    
    // Toggle focus mode
    function toggleFocusMode() {
        document.body.classList.toggle('focus-mode-active');
        prefs.focusModeActive = document.body.classList.contains('focus-mode-active');
        GM_setValue('focusModeActive', prefs.focusModeActive);
        
        const focusBtn = document.querySelector('.focus-mode-btn');
        if (focusBtn) {
            focusBtn.classList.toggle('active', prefs.focusModeActive);
        }
    }
    
    // Toggle line highlighting
    function toggleLineHighlighting() {
        document.body.classList.toggle('line-highlighting-active');
        prefs.lineHighlighting = document.body.classList.contains('line-highlighting-active');
        GM_setValue('lineHighlighting', prefs.lineHighlighting);
        
        const lineHighlightBtn = document.querySelector('.line-highlight-btn');
        if (lineHighlightBtn) {
            lineHighlightBtn.classList.toggle('active', prefs.lineHighlighting);
        }
    }
    
    // Toggle high contrast
    function toggleHighContrast() {
        document.body.classList.toggle('high-contrast-active');
        prefs.highContrast = document.body.classList.contains('high-contrast-active');
        GM_setValue('highContrast', prefs.highContrast);
        
        const contrastBtn = document.querySelector('.contrast-btn');
        if (contrastBtn) {
            contrastBtn.classList.toggle('active', prefs.highContrast);
        }
    }
    
    // Font size controls
    function increaseFontSize() {
        if (prefs.fontSize < 28) {
            prefs.fontSize += 1;
            updateFontSize();
            GM_setValue('fontSize', prefs.fontSize);
        }
    }
    
    function decreaseFontSize() {
        if (prefs.fontSize > 14) {
            prefs.fontSize -= 1;
            updateFontSize();
            GM_setValue('fontSize', prefs.fontSize);
        }
    }
    
    function updateFontSize() {
        const contentElements = document.querySelectorAll('.tm-article-body, .article-formatted-body');
        contentElements.forEach(element => {
            element.style.fontSize = `${prefs.fontSize}px`;
        });
        
        // Update font size in settings panel if it exists
        const fontSizeValue = document.querySelector('#font-size-value');
        if (fontSizeValue) {
            fontSizeValue.textContent = prefs.fontSize + 'px';
        }
        
        const fontSizeRange = document.querySelector('#font-size-range');
        if (fontSizeRange) {
            fontSizeRange.value = prefs.fontSize;
        }
    }
    
    // Update reading progress bar
    function updateProgressBar() {
        const windowHeight = window.innerHeight;
        const fullHeight = document.documentElement.scrollHeight - windowHeight;
        const scrolled = window.scrollY;
        
        const progressBar = document.querySelector('.reading-progress-bar');
        if (progressBar) {
            const width = (scrolled / fullHeight) * 100;
            progressBar.style.width = `${width}%`;
        }
    }
    
    // Toggle settings panel
    function toggleSettings() {
        const settingsPanel = document.querySelector('.readability-settings');
        if (settingsPanel) {
            const isVisible = settingsPanel.style.display === 'block';
            settingsPanel.style.display = isVisible ? 'none' : 'block';
        }
    }
    
    // Create settings panel
    function createSettingsPanel() {
        const settingsPanel = document.createElement('div');
        settingsPanel.className = 'readability-settings';
        
        settingsPanel.innerHTML = `
            <h3>Настройки читаемости</h3>
            <div class="settings-group">
                <div class="settings-row">
                    <label for="font-family">Шрифт:</label>
                    <select id="font-family">
                        <optgroup label="Шрифты с засечками (Serif)">
                            ${fontCategories.serif.map(font => `<option value="${font}" ${prefs.fontFamily === font ? 'selected' : ''}>${font}</option>`).join('')}
                        </optgroup>
                        <optgroup label="Шрифты без засечек (Sans-serif)">
                            ${fontCategories.sansSerif.map(font => `<option value="${font}" ${prefs.fontFamily === font ? 'selected' : ''}>${font}</option>`).join('')}
                        </optgroup>
                    </select>
                </div>
                <div class="settings-row">
                    <label for="font-size-range">Размер шрифта: <span id="font-size-value">${prefs.fontSize}px</span></label>
                    <input type="range" id="font-size-range" min="14" max="28" step="1" value="${prefs.fontSize}">
                </div>
                <div class="settings-row">
                    <label for="line-height-range">Интервал строк: <span id="line-height-value">${prefs.lineHeight}</span></label>
                    <input type="range" id="line-height-range" min="1.2" max="2.2" step="0.1" value="${prefs.lineHeight}">
                </div>
                <div class="settings-row">
                    <label for="letter-spacing-range">Интервал букв: <span id="letter-spacing-value">${prefs.letterSpacing}em</span></label>
                    <input type="range" id="letter-spacing-range" min="0" max="0.05" step="0.01" value="${prefs.letterSpacing}">
                </div>
                <div class="settings-row">
                    <label for="paragraph-spacing-range">Отступ параграфов: <span id="paragraph-spacing-value">${prefs.paragraphSpacing}em</span></label>
                    <input type="range" id="paragraph-spacing-range" min="0.8" max="2.5" step="0.1" value="${prefs.paragraphSpacing}">
                </div>
            </div>
            <button class="settings-close-btn">✕</button>
        `;
        
        document.body.appendChild(settingsPanel);
        
        // Set up event listeners for settings controls
        const fontFamilySelect = document.querySelector('#font-family');
        const fontSizeRange = document.querySelector('#font-size-range');
        const lineHeightRange = document.querySelector('#line-height-range');
        const letterSpacingRange = document.querySelector('#letter-spacing-range');
        const paragraphSpacingRange = document.querySelector('#paragraph-spacing-range');
        const closeButton = document.querySelector('.settings-close-btn');
        
        fontFamilySelect.addEventListener('change', function() {
            prefs.fontFamily = this.value;
            GM_setValue('fontFamily', prefs.fontFamily);
            updateFontStyle();
        });
        
        fontSizeRange.addEventListener('input', function() {
            prefs.fontSize = parseFloat(this.value);
            document.querySelector('#font-size-value').textContent = prefs.fontSize + 'px';
            updateFontStyle();
        });
        
        fontSizeRange.addEventListener('change', function() {
            GM_setValue('fontSize', prefs.fontSize);
        });
        
        lineHeightRange.addEventListener('input', function() {
            prefs.lineHeight = parseFloat(this.value);
            document.querySelector('#line-height-value').textContent = prefs.lineHeight;
            updateFontStyle();
        });
        
        lineHeightRange.addEventListener('change', function() {
            GM_setValue('lineHeight', prefs.lineHeight);
        });
        
        letterSpacingRange.addEventListener('input', function() {
            prefs.letterSpacing = parseFloat(this.value);
            document.querySelector('#letter-spacing-value').textContent = prefs.letterSpacing + 'em';
            updateFontStyle();
        });
        
        letterSpacingRange.addEventListener('change', function() {
            GM_setValue('letterSpacing', prefs.letterSpacing);
        });
        
        paragraphSpacingRange.addEventListener('input', function() {
            prefs.paragraphSpacing = parseFloat(this.value);
            document.querySelector('#paragraph-spacing-value').textContent = prefs.paragraphSpacing + 'em';
            updateFontStyle();
        });
        
        paragraphSpacingRange.addEventListener('change', function() {
            GM_setValue('paragraphSpacing', prefs.paragraphSpacing);
        });
        
        closeButton.addEventListener('click', function() {
            settingsPanel.style.display = 'none';
        });
    }
    
    // Update font style based on settings
    function updateFontStyle() {
        const contentElements = document.querySelectorAll('.tm-article-body, .article-formatted-body');
        contentElements.forEach(element => {
            element.style.fontFamily = `'${prefs.fontFamily}', 'Georgia', serif`;
            element.style.fontSize = `${prefs.fontSize}px`;
            element.style.lineHeight = prefs.lineHeight;
            element.style.letterSpacing = `${prefs.letterSpacing}em`;
        });
        
        const paragraphs = document.querySelectorAll('.tm-article-body p, .article-formatted-body p');
        paragraphs.forEach(paragraph => {
            paragraph.style.marginBottom = `${prefs.paragraphSpacing}em`;
        });
    }
    
    // Load custom fonts if needed
    function loadCustomFonts() {
        const fontLink = document.createElement('link');
        fontLink.rel = 'stylesheet';
        fontLink.href = 'https://fonts.googleapis.com/css2?family=PT+Serif:wght@400;700&family=PT+Sans:wght@400;700&family=Roboto:wght@400;700&family=Open+Sans:wght@400;700&family=Noto+Serif:wght@400;700&family=Noto+Sans:wght@400;700&family=Lora:wght@400;700&family=Fira+Sans:wght@400;700&family=Literata:wght@400;700&family=Ubuntu:wght@400;700&family=Source+Sans+Pro:wght@400;700&family=Nunito:wght@400;700&family=Inter:wght@400;700&family=Montserrat:wght@400;700&display=swap';
        document.head.appendChild(fontLink);
    }
    
    // Load fonts
    loadCustomFonts();
})(); 
