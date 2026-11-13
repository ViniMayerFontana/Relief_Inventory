import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.vue',
    ],

    theme: {
        extend: {
            // Tema Planck Tech v2 CLARO — NOMES NOVOS apenas (bg-planck-base,
            // text-planck-brand, font-display, font-tech...), aditivo: sans/mono
            // e cores stock ficam intactos para não afetar as demais telas.
            // Principal verde (#10B981), letras/símbolos ciano (#0EA5E9/#0284C7).
            // Mecanismo opt-in, tokens e guardrails: Agents/PLANCK_UI_THEMER.md.
            colors: {
                planck: {
                    base: '#F1F7F4',
                    secondary: '#E6F4EC',
                    surface: '#FFFFFF',
                    'surface-hover': '#EFF7F2',
                    brand: '#10B981',
                    'brand-hover': '#059669',
                    accent: '#0EA5E9',
                    'text-primary': '#0EA5E9',
                    'text-secondary': '#0284C7',
                    muted: '#64A3CC',
                    line: 'rgba(16, 185, 129, 0.45)',
                },
            },
            fontFamily: {
                sans: ['Figtree', 'RI Emoji', ...defaultTheme.fontFamily.sans],
                mono: ['RI Emoji', ...defaultTheme.fontFamily.mono],
                display: ['Inter', 'Plus Jakarta Sans', ...defaultTheme.fontFamily.sans],
                tech: ['JetBrains Mono', 'RI Emoji', ...defaultTheme.fontFamily.mono],
            },
        },
    },

    plugins: [forms],
};
