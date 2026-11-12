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
            // Tema Planck Tech — NOMES NOVOS apenas (bg-planck-base,
            // text-planck-brand, font-display, font-tech...), aditivo: sans/mono
            // e cores stock ficam intactos para não afetar as demais telas.
            // Mecanismo opt-in, tokens e guardrails: Agents/PLANCK_UI_THEMER.md.
            colors: {
                planck: {
                    base: '#060B14',
                    secondary: '#0D1525',
                    surface: '#121D33',
                    'surface-hover': '#182642',
                    brand: '#0EA5E9',
                    'brand-hover': '#0284C7',
                    accent: '#10B981',
                    'text-primary': '#F8FAFC',
                    'text-secondary': '#94A3B8',
                    muted: '#64748B',
                    line: 'rgba(148, 163, 184, 0.14)',
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
