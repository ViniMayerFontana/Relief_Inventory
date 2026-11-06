<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Http\Controllers;

use App\Models\Printer;
use App\Services\Printing\DocumentRegistry;
use App\Services\PrintQueueService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/**
 * Web-UI half of the print queue: "send this document to that printer."
 * The PDF is rendered here, at submit time, from the same builder the
 * document's download route uses, then stored and queued for a print server
 * to claim (see DevicePrintJobController).
 */
class PrintController extends Controller
{
    public function store(Request $request, DocumentRegistry $registry, PrintQueueService $queue)
    {
        $data = $request->validate([
            'document' => 'required|string',
            'params' => 'nullable|array',
            'printer_id' => 'required|integer|exists:printers,id',
            'copies' => 'nullable|integer|min:1|max:99',
        ]);

        $definition = $registry->find($data['document']);
        if (! $definition) {
            throw ValidationException::withMessages(['document' => 'Documento desconhecido.']);
        }

        // Same bar as downloading the PDF itself — printing never widens access.
        $user = $request->user();
        if ($definition['permission'] && ! $user->hasPermission($definition['permission'])) {
            abort(403, 'Você não tem permissão para imprimir este documento.');
        }

        // validate() returns only the keys the document's rules name.
        $params = Validator::make($data['params'] ?? [], $definition['rules'])->validate();

        $printer = Printer::usable()->find($data['printer_id']);
        if (! $printer) {
            throw ValidationException::withMessages(['printer_id' => 'Essa impressora não está disponível.']);
        }
        if ($printer->media !== $definition['media']) {
            throw ValidationException::withMessages([
                'printer_id' => 'Essa impressora está carregada com '.($printer->media_label ?? 'um tipo de mídia diferente').', que não serve para este documento.',
            ]);
        }

        // Render before touching storage/the DB. abort()s inside a builder
        // (404 no pallets, 409 BOL not eligible) surface as their own status.
        $pdf = $registry->render($definition, $params)->generatePdfContent();
        $title = ($definition['title'])($params);

        $job = $queue->enqueue($printer, $data['document'], $title, $pdf, $data['copies'] ?? 1, Auth::id());

        return response()->json([
            'id' => $job->id,
            'status' => $job->status,
            'title' => $job->title,
            'printer' => ['id' => $printer->id, 'name' => $printer->name, 'status' => $printer->status, 'ready' => $printer->isReady()],
            'message' => $printer->isReady()
                ? "Enviado para {$printer->name}."
                : "Enfileirado para {$printer->name}, que está com status {$printer->status}; será impresso quando o servidor de impressão voltar.",
        ], 201);
    }

    /**
     * Print a PDF someone uploaded (manage-print-queue — it prints arbitrary content, so it is not a base-tier action). The
     * file is user data and is never rendered or interpreted here: it is checked to be a PDF, size-capped, and queued as
     * is for a print server to claim. It prints at its own page size (print servers use print-scaling=none), so it should
     * match what the printer is loaded with; any printer that is active, typed and sited is accepted whatever its media.
     */
    public function storeUpload(Request $request, PrintQueueService $queue)
    {
        $data = $request->validate([
            'file' => ['required', 'file', 'mimetypes:application/pdf', 'max:'.config('printing.upload_max_kb')],
            'printer_id' => 'required|integer|exists:printers,id',
            'copies' => 'nullable|integer|min:1|max:99',
        ]);

        $printer = Printer::usable()->find($data['printer_id']);
        if (! $printer) {
            throw ValidationException::withMessages(['printer_id' => 'Essa impressora não está disponível.']);
        }

        $bytes = $request->file('file')->get();
        // The mime type comes from the content, but check the signature too: a PDF starts with %PDF- (within the first KB).
        if (! str_contains(substr($bytes, 0, 1024), '%PDF-')) {
            throw ValidationException::withMessages(['file' => 'Este arquivo não é um PDF.']);
        }

        // The filename is untrusted text, shown as the job's title: drop any path, control characters and excess length.
        $name = preg_replace('/[\x00-\x1F\x7F]/u', '', basename(str_replace('\\', '/', (string) $request->file('file')->getClientOriginalName()))) ?? '';
        $title = Str::limit(trim($name) !== '' ? trim($name) : 'PDF enviado', 120, '');

        $job = $queue->enqueue($printer, 'uploaded-pdf', $title, $bytes, $data['copies'] ?? 1, Auth::id());

        return response()->json([
            'id' => $job->id,
            'status' => $job->status,
            'title' => $job->title,
            'printer' => ['id' => $printer->id, 'name' => $printer->name, 'status' => $printer->status, 'ready' => $printer->isReady()],
            'message' => $printer->isReady()
                ? "{$job->title} enviado para {$printer->name}."
                : "{$job->title} enfileirado para {$printer->name}, que está com status {$printer->status}; será impresso quando o servidor de impressão voltar.",
        ], 201);
    }
}
