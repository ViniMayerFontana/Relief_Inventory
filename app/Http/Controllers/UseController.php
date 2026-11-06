<?php

namespace App\Http\Controllers;

use App\Models\UseModel;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UseController extends Controller
{
    private const validation = [
        'use' => 'required|string|max:255|unique:uses,use',
    ];

    /**
     * Retrieve all uses.
     *
     * @return JsonResponse
     */
    public function index()
    {
        $uses = UseModel::all();
        $templates = [
            '_default' => [
                'use' => '',
            ],
        ];

        return response()->json([
            'records' => $uses,
            'templates' => $templates,
        ]);
    }

    /**
     * Store a new use.
     *
     * @return JsonResponse
     */
    public function store(Request $request)
    {
        $data = $request->validate(self::validation);
        $use = UseModel::create($data);

        return response()->json([
            'message' => 'Uso criado com sucesso.',
            'record' => $use,
        ], 201);
    }

    /**
     * Update an existing use.
     *
     * @param  int  $id
     * @return JsonResponse
     */
    public function update(Request $request, $id)
    {
        $use = UseModel::findOrFail($id);

        $data = $request->validate(self::validation + [
            'use' => "required|string|max:255|unique:uses,use,$id",
        ]);

        $use->update($data);

        return response()->json([
            'message' => 'Uso atualizado com sucesso.',
            'record' => $use,
        ], 200);
    }

    /**
     * Delete an existing use.
     *
     * @param  int  $id
     * @return JsonResponse
     */
    public function destroy($id)
    {
        try {
            $use = UseModel::findOrFail($id);
            $use->delete();

            return response()->json([
                'success' => true,
                'message' => 'Uso excluído com sucesso.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir o uso: '.$e->getMessage(),
            ], 500);
        }
    }
}
