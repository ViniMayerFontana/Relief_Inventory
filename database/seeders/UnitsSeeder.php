<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UnitsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Sample data for the `items` table — pt-BR (2026-11-19): apenas o
        // campo `name` é traduzido; `abbreviation` e `type` são técnicos
        // (referenciados por selects/relatórios e pela UI) e permanecem.
        $units = [
            [
                'abbreviation' => 'lb',
                'name' => 'libra',
                'type' => 'weight',
            ],
            [
                'abbreviation' => 'oz',
                'name' => 'onça',
                'type' => 'weight',
            ],
            [
                'abbreviation' => 'kg',
                'name' => 'quilograma',
                'type' => 'weight',
            ],
            [
                'abbreviation' => 'g',
                'name' => 'grama',
                'type' => 'weight',
            ],
            [
                'abbreviation' => 'gal',
                'name' => 'galão',
                'type' => 'volume',
            ],
            [
                'abbreviation' => 'each',
                'name' => 'unidade',
                'type' => 'each',
            ],
            [
                'abbreviation' => 'unknown',
                'name' => 'desconhecida',
                'type' => 'other',
            ],
        ];
        // Insert data into the items table
        DB::table('units')->insert($units);
    }
}
