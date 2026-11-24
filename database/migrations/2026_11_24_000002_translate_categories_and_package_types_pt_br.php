<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-24): traduz na instância existente os dados semeados EN
 * (15 categorias + 11 package types; Box→"Caixa de papelão" aprovado (distinção de Case)). down() restaura os EN literais.
 * RISCO ACEITO PELO USUÁRIO: importadores Flowtrac casam por name/singular EN
 * e podem recriar os registros EN após o translate.
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('categories')->where('name', 'Animal products & durable medical')->update(['name' => 'Produtos animais e médico-hospitalares duráveis']);
        DB::table('categories')->where('name', 'Food & water')->update(['name' => 'Alimentos e água']);
        DB::table('categories')->where('name', 'Personal care, pharmacy & safety')->update(['name' => 'Higiene pessoal, farmácia e segurança']);
        DB::table('categories')->where('name', 'Paper & disposables')->update(['name' => 'Papel e descartáveis']);
        DB::table('categories')->where('name', 'Baby & child')->update(['name' => 'Bebê e criança']);
        DB::table('categories')->where('name', 'Bedding & linens')->update(['name' => 'Cama, mesa e banho']);
        DB::table('categories')->where('name', 'Kitchen & dining')->update(['name' => 'Cozinha e alimentação']);
        DB::table('categories')->where('name', 'Cleaning & household')->update(['name' => 'Limpeza e utilidades domésticas']);
        DB::table('categories')->where('name', 'Clothing & accessories')->update(['name' => 'Roupas e acessórios']);
        DB::table('categories')->where('name', 'Outdoor, emergency & tools')->update(['name' => 'Ar-livre, emergência e ferramentas']);
        DB::table('categories')->where('name', 'Appliances, large (team-lift)')->update(['name' => 'Eletrodomésticos grandes (transporte em equipe)']);
        DB::table('categories')->where('name', 'Appliances, small (countertop)')->update(['name' => 'Eletroportáteis (de bancada)']);
        DB::table('categories')->where('name', 'Building supplies')->update(['name' => 'Materiais de construção']);
        DB::table('categories')->where('name', 'Furniture')->update(['name' => 'Móveis']);
        DB::table('categories')->where('name', 'Holy Bible')->update(['name' => 'Bíblia Sagrada']);
        DB::table('packagetypes')->where('singular', 'Unit')->update(['singular' => 'Unidade', 'plural' => 'Unidades']);
        DB::table('packagetypes')->where('singular', 'Case')->update(['singular' => 'Caixa', 'plural' => 'Caixas']);
        DB::table('packagetypes')->where('singular', 'Box')->update(['singular' => 'Caixa de papelão', 'plural' => 'Caixas de papelão']);
        DB::table('packagetypes')->where('singular', 'Bag')->update(['singular' => 'Saco', 'plural' => 'Sacos']);
        DB::table('packagetypes')->where('singular', 'Pallet')->update(['singular' => 'Pallet', 'plural' => 'Pallets']);
        DB::table('packagetypes')->where('singular', 'Each')->update(['singular' => 'Unidade', 'plural' => 'Unidade']);
        DB::table('packagetypes')->where('singular', 'Gaylord')->update(['singular' => 'Gaylord', 'plural' => 'Gaylords']);
        DB::table('packagetypes')->where('singular', 'Roll')->update(['singular' => 'Rolo', 'plural' => 'Rolos']);
        DB::table('packagetypes')->where('singular', 'Gallon')->update(['singular' => 'Galão', 'plural' => 'Galões']);
        DB::table('packagetypes')->where('singular', 'Ton')->update(['singular' => 'Tonelada', 'plural' => 'Toneladas']);
        DB::table('packagetypes')->where('singular', 'Shipping Container')->update(['singular' => 'Contêiner de expedição', 'plural' => 'Contêineres de expedição']);
        DB::table('packagetypes')->where('singular', 'Truckload')->update(['singular' => 'Carga de caminhão', 'plural' => 'Cargas de caminhão']);
    }

    public function down(): void
    {
        DB::table('categories')->where('name', 'Produtos animais e médico-hospitalares duráveis')->update(['name' => 'Animal products & durable medical']);
        DB::table('categories')->where('name', 'Alimentos e água')->update(['name' => 'Food & water']);
        DB::table('categories')->where('name', 'Higiene pessoal, farmácia e segurança')->update(['name' => 'Personal care, pharmacy & safety']);
        DB::table('categories')->where('name', 'Papel e descartáveis')->update(['name' => 'Paper & disposables']);
        DB::table('categories')->where('name', 'Bebê e criança')->update(['name' => 'Baby & child']);
        DB::table('categories')->where('name', 'Cama, mesa e banho')->update(['name' => 'Bedding & linens']);
        DB::table('categories')->where('name', 'Cozinha e alimentação')->update(['name' => 'Kitchen & dining']);
        DB::table('categories')->where('name', 'Limpeza e utilidades domésticas')->update(['name' => 'Cleaning & household']);
        DB::table('categories')->where('name', 'Roupas e acessórios')->update(['name' => 'Clothing & accessories']);
        DB::table('categories')->where('name', 'Ar-livre, emergência e ferramentas')->update(['name' => 'Outdoor, emergency & tools']);
        DB::table('categories')->where('name', 'Eletrodomésticos grandes (transporte em equipe)')->update(['name' => 'Appliances, large (team-lift)']);
        DB::table('categories')->where('name', 'Eletroportáteis (de bancada)')->update(['name' => 'Appliances, small (countertop)']);
        DB::table('categories')->where('name', 'Materiais de construção')->update(['name' => 'Building supplies']);
        DB::table('categories')->where('name', 'Móveis')->update(['name' => 'Furniture']);
        DB::table('categories')->where('name', 'Bíblia Sagrada')->update(['name' => 'Holy Bible']);
        DB::table('packagetypes')->where('singular', 'Unidade')->update(['singular' => 'Unit', 'plural' => 'Units']);
        DB::table('packagetypes')->where('singular', 'Caixa')->update(['singular' => 'Case', 'plural' => 'Cases']);
        DB::table('packagetypes')->where('singular', 'Caixa de papelão')->update(['singular' => 'Box', 'plural' => 'Boxes']);
        DB::table('packagetypes')->where('singular', 'Saco')->update(['singular' => 'Bag', 'plural' => 'Bags']);
        DB::table('packagetypes')->where('singular', 'Pallet')->update(['singular' => 'Pallet', 'plural' => 'Pallets']);
        DB::table('packagetypes')->where('singular', 'Unidade')->update(['singular' => 'Each', 'plural' => 'Each']);
        DB::table('packagetypes')->where('singular', 'Gaylord')->update(['singular' => 'Gaylord', 'plural' => 'Gaylords']);
        DB::table('packagetypes')->where('singular', 'Rolo')->update(['singular' => 'Roll', 'plural' => 'Rolls']);
        DB::table('packagetypes')->where('singular', 'Galão')->update(['singular' => 'Gallon', 'plural' => 'Gallons']);
        DB::table('packagetypes')->where('singular', 'Tonelada')->update(['singular' => 'Ton', 'plural' => 'Tons']);
        DB::table('packagetypes')->where('singular', 'Contêiner de expedição')->update(['singular' => 'Shipping Container', 'plural' => 'Shipping Containers']);
        DB::table('packagetypes')->where('singular', 'Carga de caminhão')->update(['singular' => 'Truckload', 'plural' => 'Truckloads']);
    }
};
