<?php

use App\Models\MenuItem;
use App\Models\Page;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        //

        // Create the Main Menu page
        $mainMenu = Page::create([
            'hashtag' => 'main',
            'menu_title' => 'Menu principal',
            'header_text' => 'Bem-vindo à aplicação Relief Inventory',
            'content' => 'Este é o menu principal, de onde você navega pelas várias partes da aplicação.',
        ]);

        // Add menu items for the Main Menu
        MenuItem::create([
            'page_id' => $mainMenu->id,
            'link_text' => 'Entrada de pedidos',
            'link_url' => '/order-entry',
            'graphic_url' => '/img/order-entry-icon.webp',
            'order' => 10,
        ]);

        MenuItem::create([
            'page_id' => $mainMenu->id,
            'link_text' => 'Atendimento de pedidos',
            'link_url' => '/order-filling',
            'graphic_url' => '/img/order-filling-icon.webp',
            'order' => 20,
        ]);

        MenuItem::create([
            'page_id' => $mainMenu->id,
            'link_text' => 'Triagem de doações',
            'link_url' => '/donation-sorting',
            'graphic_url' => '/img/donation-sorting-icon.webp',
            'order' => 30,
        ]);

        MenuItem::create([
            'page_id' => $mainMenu->id,
            'link_text' => 'Movimentação de estoque',
            'link_url' => '/inventory-movement',
            'graphic_url' => '/img/inventory-movement-icon.webp',
            'order' => 40,
        ]);

        MenuItem::create([
            'page_id' => $mainMenu->id,
            'link_text' => 'Menu de relatórios',
            'link_url' => '#reports',
            'graphic_url' => '/img/printing-reports.webp',
            'order' => 80,
        ]);

        MenuItem::create([
            'page_id' => $mainMenu->id,
            'link_text' => 'Menu de configurações',
            'link_url' => '#setup',
            'graphic_url' => '/img/settings-icon.webp',
            'order' => 90,
        ]);

        // Create the Report Menu page
        $reportMenu = Page::create([
            'hashtag' => 'reports',
            'menu_title' => 'Menu de relatórios',
            'header_text' => 'Relatórios da aplicação',
            'content' => 'Use este menu para configurar status, itens e usuários.',
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Etiquetas de impressão',
            'link_url' => '/reports/labels',
            'graphic_url' => '/img/barcode-printer.webp',
            'order' => 10,
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Pedidos pendentes',
            'link_url' => '/reports/orders',
            'graphic_url' => '/img/printing-reports.webp',
            'order' => 20,
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Relatório de estoque',
            'link_url' => '/reports/inventory',
            'graphic_url' => '/img/reports.webp',
            'order' => 30,
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Relatórios de fluxo',
            'link_url' => '/reports/flow',
            'graphic_url' => '/img/reports.webp',
            'order' => 40,
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Relatório de doadores',
            'link_url' => '/reports/donors',
            'graphic_url' => '/img/reports.webp',
            'order' => 50,
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Relatório de clientes',
            'link_url' => '/reports/customers',
            'graphic_url' => '/img/reports.webp',
            'order' => 60,
        ]);

        MenuItem::create([
            'page_id' => $reportMenu->id,
            'link_text' => 'Voltar',
            'link_url' => '#main',
            'graphic_url' => '/img/back-arrow.webp',
            'order' => 99,
        ]);

        // Create the Setup Menu page
        $setupMenu = Page::create([
            'hashtag' => 'setup',
            'menu_title' => 'Menu de configurações',
            'header_text' => 'Opções de configuração da aplicação',
            'content' => 'Use este menu para configurar itens, categorias, usuários etc.',
        ]);

        // Add menu items for the Setup Menu
        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Informações de clientes e doadores',
            'link_url' => '/setup/people',
            'graphic_url' => '/img/donation-entry-icon.webp',
            'order' => 10,
        ]);

        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Editar lista mestra de itens',
            'link_url' => '/setup/items',
            'graphic_url' => '/img/edit-items-icon.webp',
            'order' => 20,
        ]);

        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Editar categorias de itens',
            'link_url' => '/setup/categories',
            'graphic_url' => '/img/edit-statuses-icon.webp',
            'order' => 30,
        ]);

        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Editar usuários',
            'link_url' => '/setup/users',
            'graphic_url' => '/img/edit-users-icon.webp',
            'order' => 50,
        ]);

        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Voltar',
            'link_url' => '#main',
            'graphic_url' => '/img/back-arrow.webp',
            'order' => 99,
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
        Schema::disableForeignKeyConstraints();
        DB::table('menu_items')->truncate();
        DB::table('pages')->truncate();
        Schema::enableForeignKeyConstraints();
    }
};
