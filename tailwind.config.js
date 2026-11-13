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
            // Tema Planck Tech — verde exclusivo, sem ciano/azul — NOMES NOVOS
            // apenas (bg-planck-base, text-planck-brand, font-display,
            // font-tech...), aditivo: sans/mono e cores stock ficam intactos
            // para não afetar as demais telas. Letras em verde-escuro
            // (#065F46/#047857); v5: barras/rodapé escuros + esmeralda
            // brilhante (--glow). Mecanismo opt-in, tokens e guardrails:
            // Agents/PLANCK_UI_THEMER.md.
            colors: {
                planck: {
                    base: '#E9F4EE',
                    secondary: '#D7EEE1',
                    surface: '#FFFFFF',
                    'surface-hover': '#E2F1E8',
                    brand: '#10B981',
                    'brand-hover': '#059669',
                    deep: '#065F46',
                    glow: '#34D399',
                    'text-primary': '#065F46',
                    'text-secondary': '#047857',
                    muted: '#6E9C8B',
                    line: 'rgba(4, 120, 87, 0.45)',
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
