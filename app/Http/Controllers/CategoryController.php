<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    private const validation = [
        'name' => 'required|string|unique:categories,name',
    ];

    /**
     * Retrieve all categories.
     *
     * @return JsonResponse
     */
    public function index()
    {
        $categories = Category::all();

        return response()->json([
            'records' => $categories,
            'templates' => [
                '_default' => [
                    'name' => '',
                ],
            ],
        ]);
    }

    /**
     * Store a new category.
     *
     * @return JsonResponse
     */
    public function store(Request $request)
    {
        $data = $request->validate(self::validation);
        $category = Category::create($data);

        return response()->json([
            'message' => 'Categoria criada com sucesso.',
            'category' => $category,
        ], 201);
    }

    /**
     * Update an existing category.
     *
     * @param  int  $id
     * @return JsonResponse
     */
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);
        $data = $request->validate(self::validation);

        $category->update($data);

        return response()->json([
            'message' => 'Categoria atualizada com sucesso.',
            'category' => $category,
        ], 200);
    }

    /**
     * Delete a category.
     *
     * @param  int  $id
     * @return JsonResponse
     */
    public function destroy($id)
    {
        try {
            $category = Category::findOrFail($id);
            $category->delete();

            return response()->json([
                'success' => true,
                'message' => 'Categoria excluída com sucesso.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir a categoria: '.$e->getMessage(),
            ], 500);
        }
    }
}
