<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PackageTypesSeeder extends Seeder
{
    // pt-BR (2026-11-24): importadores Flowtrac casam por singular EN
    // (3 importadores) — risco aceito pelo usuário. "Box" permanece EN
    // (colisão de singular com Case→"Caixa"; decisão pendente do lead).
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Sample data for the `items` table
        $pkg = [
            [
                'singular' => 'Unidade',
                'plural' => 'Unidades',
            ],
            [
                'singular' => 'Caixa',
                'plural' => 'Caixas',

            ],
            [
                'singular' => 'Saco',
                'plural' => 'Sacos',

            ],
            [
                'singular' => 'Pallet',
                'plural' => 'Pallets',
            ],
            [
                'singular' => 'Unidade',
                'plural' => 'Unidade',
            ],
            [
                'singular' => 'Gaylord',
                'plural' => 'Gaylords',
            ],
            [
                'singular' => 'Rolo',
                'plural' => 'Rolos',
            ],
            [
                'singular' => 'Galão',
                'plural' => 'Galões',
            ],
            [
                'singular' => 'Tonelada',
                'plural' => 'Toneladas',
            ],
            [
                'singular' => 'Contêiner de expedição',
                'plural' => 'Contêineres de expedição',
            ],
            [
                'singular' => 'Carga de caminhão',
                'plural' => 'Cargas de caminhão',
            ],
        ];
        // Insert data into the items table
        DB::table('packagetypes')->insert($pkg);
    }
}
