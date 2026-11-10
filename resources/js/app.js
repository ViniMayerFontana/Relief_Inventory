// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details


import '../css/app.css';
import { setWarehouse, withWarehouse } from './bootstrap';
import { i18n, setLocale } from './i18n';

import { createInertiaApp, router } from '@inertiajs/vue3';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { createApp, h } from 'vue';
import { ZiggyVue } from '../../vendor/tightenco/ziggy';

const appName = import.meta.env.VITE_APP_NAME || 'Relief Inventory';

createInertiaApp({
    title: (title) => `${title} - ${appName}`,
    resolve: (name) =>
        resolvePageComponent(
            `./Pages/${name}.vue`,
            import.meta.glob('./Pages/**/*.vue'),
        ),
    setup({ el, App, props, plugin }) {
        setWarehouse(props.initialPage.props.warehouse);
        router.on('navigate', (event) => setWarehouse(event.detail.page.props.warehouse));
        // App locale from the backend (APP_LOCALE via HandleInertiaRequests);
        // no-op for unknown locales, which keeps the 'en' fallback.
        setLocale(props.initialPage.props.locale);
        const app = createApp({ render: () => h(App, props) });
        // Templates: `:href="$withWarehouse('/report/x.csv')"` — every plain download link names its warehouse.
        app.config.globalProperties.$withWarehouse = withWarehouse;
        return app
            .use(plugin)
            .use(i18n)
            .use(ZiggyVue)
            .mount(el);
    },
    progress: {
        color: '#4B5563',
    },
});
